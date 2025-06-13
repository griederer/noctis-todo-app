import Foundation
import FirebaseFirestore
import Combine

class TodoFirebaseRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let authService = AuthenticationService.shared
    
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to authentication state changes
        authService.$currentUser
            .sink { [weak self] user in
                if user != nil {
                    self?.startListening()
                } else {
                    self?.stopListening()
                    self?.todos = []
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Real-time Listening
    private func startListening() {
        guard let userId = authService.currentUser?.id else {
            Logger.shared.dataError("No user ID available for listening to todos")
            return
        }
        
        stopListening() // Stop any existing listener
        
        Logger.shared.dataInfo("Starting to listen for todos for user: \(userId)")
        
        listener = db.collection("users").document(userId).collection("todos")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.setError("Failed to fetch todos: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.setError("No todos found")
                        return
                    }
                    
                    self?.todos = documents.compactMap { document in
                        do {
                            var todo = try document.data(as: Todo.self)
                            return todo
                        } catch {
                            Logger.shared.dataError("Failed to decode todo: \(error)")
                            return nil
                        }
                    }
                    
                    Logger.shared.dataInfo("Fetched \(self?.todos.count ?? 0) todos")
                    self?.clearError()
                }
            }
    }
    
    private func stopListening() {
        listener?.remove()
        listener = nil
        Logger.shared.dataInfo("Stopped listening for todos")
    }
    
    // MARK: - CRUD Operations
    func addTodo(_ todo: Todo) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("todos")
                .document(todo.id).setData(from: todo) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to add todo: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Todo added successfully: \(todo.title)")
                            AnalyticsService.shared.trackTodoCreated()
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode todo: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func updateTodo(_ todo: Todo) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("todos")
                .document(todo.id).setData(from: todo) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to update todo: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Todo updated successfully: \(todo.title)")
                            AnalyticsService.shared.trackTodoEdited()
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode todo: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        db.collection("users").document(userId).collection("todos")
            .document(todo.id).delete { [weak self] error in
                DispatchQueue.main.async {
                    self?.setLoading(false)
                    
                    if let error = error {
                        self?.setError("Failed to delete todo: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                    } else {
                        Logger.shared.dataInfo("Todo deleted successfully: \(todo.title)")
                        AnalyticsService.shared.trackTodoDeleted()
                        self?.clearError()
                    }
                }
            }
    }
    
    func toggleTodoCompletion(_ todo: Todo) {
        var updatedTodo = todo
        updatedTodo.toggleCompletion()
        
        updateTodo(updatedTodo)
        
        if updatedTodo.isCompleted {
            AnalyticsService.shared.trackTodoCompleted()
        }
    }
    
    func updateTodoPriority(_ todo: Todo, priority: Priority) {
        var updatedTodo = todo
        updatedTodo.update(priority: priority)
        
        updateTodo(updatedTodo)
        AnalyticsService.shared.trackTodoPriorityChanged(priority: priority.rawValue)
    }
    
    // MARK: - Filtering and Searching
    func filteredTodos(showCompleted: Bool = true, priority: Priority? = nil, searchText: String = "") -> [Todo] {
        var filtered = todos
        
        // Filter by completion status
        if !showCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Filter by priority
        if let priority = priority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                (todo.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered
    }
    
    // MARK: - Statistics
    var totalTodos: Int {
        todos.count
    }
    
    var completedTodos: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    var pendingTodos: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    var highPriorityTodos: Int {
        todos.filter { $0.priority == .high && !$0.isCompleted }.count
    }
    
    var completionRate: Double {
        guard totalTodos > 0 else { return 0 }
        return Double(completedTodos) / Double(totalTodos)
    }
    
    // MARK: - Bulk Operations
    func deleteCompletedTodos() {
        let completedTodos = todos.filter { $0.isCompleted }
        
        guard !completedTodos.isEmpty else {
            setError("No completed todos to delete")
            return
        }
        
        setLoading(true)
        
        let batch = db.batch()
        
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            setLoading(false)
            return
        }
        
        for todo in completedTodos {
            let docRef = db.collection("users").document(userId).collection("todos").document(todo.id)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { [weak self] error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Failed to delete completed todos: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    Logger.shared.dataInfo("Deleted \(completedTodos.count) completed todos")
                    AnalyticsService.shared.trackCustomEvent(name: "bulk_delete_completed_todos", parameters: ["count": completedTodos.count])
                    self?.clearError()
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    private func setError(_ message: String) {
        errorMessage = message
        Logger.shared.dataError(message)
    }
    
    private func clearError() {
        errorMessage = nil
    }
}