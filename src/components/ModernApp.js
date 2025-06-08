import React, { useState, useCallback } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useTodos } from '../hooks/useTodos';
import { useErrorHandler } from '../hooks/useErrorHandler';

// Components
import Sidebar from './Sidebar';
import TodoDetailView from './TodoDetailView';
import AddTaskButton from './AddTaskButton';
import TodoItem from './TodoItem';
import LoadingSpinner from './LoadingSpinner';
import ErrorNotification from './ErrorNotification';
import Login from './Login';
import ErrorBoundary from './ErrorBoundary';
import ModernJournalSection from './ModernJournalSection';
import ModernSimpleHabitsSection from './ModernSimpleHabitsSection';

// Styles
import '../styles/ModernClean.css';

const TodoView = ({ 
  todos, 
  title, 
  subtitle, 
  onToggleComplete, 
  onDelete, 
  onEdit, 
  selectedTodo, 
  onSelectTodo,
  onAddTask 
}) => {
  return (
    <>
      <div className="main-content">
        <div className="main-header">
          <h1 className="main-title">{title}</h1>
          {subtitle && <p className="main-subtitle">{subtitle}</p>}
        </div>
        
        <div className="main-body">
          {todos.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <div className="text-6xl mb-4">📝</div>
              <h3 className="text-lg font-semibold text-text-primary mb-2">No tasks yet</h3>
              <p className="text-text-secondary mb-6">Click the + button to add your first task</p>
            </div>
          ) : (
            <div className="space-y-2">
              {/* Group by sections if needed */}
              <div className="todo-section-header">
                <h2 className="section-title">
                  <span className="section-title-icon">📋</span>
                  Tasks
                </h2>
              </div>
              
              {todos.map((todo, index) => (
                <TodoItem
                  key={todo.id}
                  todo={todo}
                  onToggleComplete={onToggleComplete}
                  onDelete={onDelete}
                  onEdit={onEdit}
                  onSelect={onSelectTodo}
                  isSelected={selectedTodo?.id === todo.id}
                  index={index}
                />
              ))}
            </div>
          )}
        </div>
      </div>
      
      <AddTaskButton onAddTask={onAddTask} />
    </>
  );
};

const AppContent = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  const { error, clearError, withErrorHandling } = useErrorHandler();
  const [selectedTodo, setSelectedTodo] = useState(null);
  
  const {
    loading,
    addTodo,
    toggleComplete,
    deleteTodoById,
    editTodo,
    getFilteredTodos,
    todoStats
  } = useTodos(user?.uid);

  const handleAddTodo = useCallback(async (todoData) => {
    try {
      await addTodo(todoData);
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to create todo')();
    }
  }, [addTodo, withErrorHandling]);

  const handleToggleComplete = useCallback(async (id, completed) => {
    try {
      await toggleComplete(id, completed);
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to update todo')();
    }
  }, [toggleComplete, withErrorHandling]);

  const handleDeleteTodo = useCallback(async (id) => {
    try {
      await deleteTodoById(id);
      if (selectedTodo?.id === id) {
        setSelectedTodo(null);
      }
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to delete todo')();
    }
  }, [deleteTodoById, withErrorHandling, selectedTodo]);

  const handleEditTodo = useCallback(async (id, updates) => {
    try {
      await editTodo(id, updates);
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to edit todo')();
    }
  }, [editTodo, withErrorHandling]);

  const handleViewChange = (path) => {
    navigate(path);
  };

  const handleSelectTodo = (todo) => {
    setSelectedTodo(todo);
  };

  const handleCloseDetail = () => {
    setSelectedTodo(null);
  };

  const handleUpdateTodo = (id, updates) => {
    handleEditTodo(id, updates);
    // Update local selected todo state
    if (selectedTodo && selectedTodo.id === id) {
      setSelectedTodo({ ...selectedTodo, ...updates });
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <LoadingSpinner size="large" message="Loading your tasks..." />
      </div>
    );
  }

  const getTodosForCurrentView = () => {
    switch (location.pathname) {
      case '/today':
        return getFilteredTodos('today');
      case '/upcoming':
        return getFilteredTodos('upcoming');
      case '/completed':
        return getFilteredTodos('completed');
      case '/todo':
      default:
        return getFilteredTodos('all');
    }
  };

  const getViewTitle = () => {
    switch (location.pathname) {
      case '/today':
        return 'Today';
      case '/upcoming':
        return 'Upcoming';
      case '/completed':
        return 'Completed';
      case '/todo':
      default:
        return 'All Tasks';
    }
  };

  const getViewSubtitle = () => {
    const stats = todoStats();
    switch (location.pathname) {
      case '/today':
        return `${stats.today} tasks for today`;
      case '/upcoming':
        return `${stats.upcoming} upcoming tasks`;
      case '/completed':
        return `${stats.completed} completed tasks`;
      case '/todo':
      default:
        return `${stats.active} active tasks`;
    }
  };

  const currentTodos = getTodosForCurrentView();
  const stats = todoStats();

  return (
    <div className="app-layout">
      <ErrorNotification error={error} onClose={clearError} />
      
      {/* Left Sidebar */}
      <Sidebar 
        activeView={location.pathname}
        onViewChange={handleViewChange}
        todoStats={stats}
      />
      
      {/* Main Content */}
      <Routes>
        <Route path="/" element={<Navigate to="/today" />} />
        <Route 
          path="/today" 
          element={
            <TodoView
              todos={currentTodos}
              title={getViewTitle()}
              subtitle={getViewSubtitle()}
              onToggleComplete={handleToggleComplete}
              onDelete={handleDeleteTodo}
              onEdit={handleEditTodo}
              selectedTodo={selectedTodo}
              onSelectTodo={handleSelectTodo}
              onAddTask={handleAddTodo}
            />
          } 
        />
        <Route 
          path="/upcoming" 
          element={
            <TodoView
              todos={currentTodos}
              title={getViewTitle()}
              subtitle={getViewSubtitle()}
              onToggleComplete={handleToggleComplete}
              onDelete={handleDeleteTodo}
              onEdit={handleEditTodo}
              selectedTodo={selectedTodo}
              onSelectTodo={handleSelectTodo}
              onAddTask={handleAddTodo}
            />
          } 
        />
        <Route 
          path="/todo" 
          element={
            <TodoView
              todos={currentTodos}
              title={getViewTitle()}
              subtitle={getViewSubtitle()}
              onToggleComplete={handleToggleComplete}
              onDelete={handleDeleteTodo}
              onEdit={handleEditTodo}
              selectedTodo={selectedTodo}
              onSelectTodo={handleSelectTodo}
              onAddTask={handleAddTodo}
            />
          } 
        />
        <Route 
          path="/completed" 
          element={
            <TodoView
              todos={currentTodos}
              title={getViewTitle()}
              subtitle={getViewSubtitle()}
              onToggleComplete={handleToggleComplete}
              onDelete={handleDeleteTodo}
              onEdit={handleEditTodo}
              selectedTodo={selectedTodo}
              onSelectTodo={handleSelectTodo}
              onAddTask={handleAddTodo}
            />
          } 
        />
        <Route 
          path="/habits" 
          element={
            <div className="main-content">
              <div className="main-header">
                <h1 className="main-title">Habits</h1>
                <p className="main-subtitle">Track your daily habits</p>
              </div>
              <div className="main-body">
                <ModernSimpleHabitsSection />
              </div>
            </div>
          } 
        />
        <Route 
          path="/journal" 
          element={
            <div className="main-content">
              <div className="main-body" style={{ padding: 0 }}>
                <ModernJournalSection />
              </div>
            </div>
          } 
        />
      </Routes>
      
      {/* Right Detail Panel */}
      <TodoDetailView
        todo={selectedTodo}
        isOpen={!!selectedTodo}
        onClose={handleCloseDetail}
        onUpdate={handleUpdateTodo}
        onDelete={handleDeleteTodo}
      />
    </div>
  );
};

function ModernApp() {
  const { loading, isAuthenticated } = useAuth();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-bg-primary">
        <LoadingSpinner size="large" message="Initializing app..." />
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Login />;
  }

  return (
    <ErrorBoundary>
      <Router>
        <div className="app-container">
          <AppContent />
        </div>
      </Router>
    </ErrorBoundary>
  );
}

export default ModernApp;