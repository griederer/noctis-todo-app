import { 
  collection, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  doc, 
  query, 
  where, 
  onSnapshot,
  serverTimestamp 
} from 'firebase/firestore';
import { db } from './config';

const TODOS_COLLECTION = 'todos';

// Create a new todo
export const createTodo = async (userId, todoData) => {
  try {
    const docRef = await addDoc(collection(db, TODOS_COLLECTION), {
      ...todoData,
      userId,
      completed: false,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    });
    return docRef.id;
  } catch (error) {
    console.error('Error creating todo:', error);
    throw error;
  }
};

// Update a todo
export const updateTodo = async (todoId, updates) => {
  try {
    const todoRef = doc(db, TODOS_COLLECTION, todoId);
    await updateDoc(todoRef, {
      ...updates,
      updatedAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error updating todo:', error);
    throw error;
  }
};

// Delete a todo
export const deleteTodo = async (todoId) => {
  try {
    await deleteDoc(doc(db, TODOS_COLLECTION, todoId));
  } catch (error) {
    console.error('Error deleting todo:', error);
    throw error;
  }
};

// Subscribe to user's todos
export const subscribeTodos = (userId, callback, errorCallback) => {
  const q = query(
    collection(db, TODOS_COLLECTION),
    where('userId', '==', userId)
  );
  
  return onSnapshot(q, (snapshot) => {
    const todos = [];
    snapshot.forEach((doc) => {
      todos.push({ id: doc.id, ...doc.data() });
    });
    // Sort in memory if createdAt exists
    todos.sort((a, b) => {
      const aTime = a.createdAt?.seconds || a.createdAt?.getTime?.() || 0;
      const bTime = b.createdAt?.seconds || b.createdAt?.getTime?.() || 0;
      return bTime - aTime;
    });
    callback(todos);
  }, (error) => {
    console.error('Error in todos subscription:', error);
    if (errorCallback) errorCallback(error);
    // Fallback: call with empty array to stop loading
    callback([]);
  });
}; 