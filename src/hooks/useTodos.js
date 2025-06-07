import { useState, useEffect, useCallback } from 'react';
import { 
  createTodo, 
  updateTodo, 
  deleteTodo, 
  subscribeTodos 
} from '../firebase/todos';

export const useTodos = (userId) => {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isAdding, setIsAdding] = useState(false);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }

    const unsubscribe = subscribeTodos(userId, (fetchedTodos) => {
      console.log('Received todos:', fetchedTodos);
      setTodos(fetchedTodos);
      setLoading(false);
    }, (error) => {
      console.error('Error loading todos:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [userId]);

  const addTodo = useCallback(async (todoData) => {
    try {
      setIsAdding(true);
      console.log('Creating todo with data:', todoData);
      const todoId = await createTodo(userId, todoData);
      console.log('Todo created with ID:', todoId);
    } catch (error) {
      console.error('Error creating todo:', error);
      throw new Error('Error creating todo: ' + error.message);
    } finally {
      setIsAdding(false);
    }
  }, [userId]);

  const toggleComplete = useCallback(async (id, completed) => {
    try {
      await updateTodo(id, { completed });
    } catch (error) {
      console.error('Error updating todo:', error);
      throw error;
    }
  }, []);

  const deleteTodoById = useCallback(async (id) => {
    try {
      await deleteTodo(id);
    } catch (error) {
      console.error('Error deleting todo:', error);
      throw error;
    }
  }, []);

  const editTodo = useCallback(async (id, updates) => {
    try {
      await updateTodo(id, updates);
    } catch (error) {
      console.error('Error editing todo:', error);
      throw error;
    }
  }, []);

  const getFilteredTodos = useCallback((filter) => {
    switch (filter) {
      case 'active':
        return todos.filter(todo => !todo.completed);
      case 'completed':
        return todos.filter(todo => todo.completed);
      default:
        return todos;
    }
  }, [todos]);

  const todoStats = useCallback(() => ({
    total: todos.length,
    active: todos.filter(t => !t.completed).length,
    completed: todos.filter(t => t.completed).length,
  }), [todos]);

  return {
    todos,
    loading,
    isAdding,
    addTodo,
    toggleComplete,
    deleteTodoById,
    editTodo,
    getFilteredTodos,
    todoStats
  };
};