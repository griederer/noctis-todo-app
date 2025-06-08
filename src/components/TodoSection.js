import React, { useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import TodoList from './TodoList';
import TodoForm from './TodoForm';
import FilterBar from './FilterBar';
import ErrorNotification from './ErrorNotification';
import LoadingSpinner from './LoadingSpinner';
import { useTodos } from '../hooks/useTodos';
import { useErrorHandler } from '../hooks/useErrorHandler';
import '../styles/VintageScientificTodos.css';
import '../styles/TodoSection.css';

function TodoSection() {
  const { user } = useAuth();
  const [filter, setFilter] = useState('all');
  const { error, clearError, withErrorHandling } = useErrorHandler();
  
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
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to delete todo')();
    }
  }, [deleteTodoById, withErrorHandling]);

  const handleEditTodo = useCallback(async (id, updates) => {
    try {
      await editTodo(id, updates);
    } catch (error) {
      withErrorHandling(() => { throw error; }, 'Failed to edit todo')();
    }
  }, [editTodo, withErrorHandling]);

  if (loading) {
    return (
      <div className="todo-section">
        <LoadingSpinner size="large" message="Loading your tasks..." />
      </div>
    );
  }

  const filteredTodos = getFilteredTodos(filter);
  const stats = todoStats();

  return (
    <div className="todo-section scientific-card fade-in">
      <ErrorNotification error={error} onClose={clearError} />
      
      <div className="todo-section-header">
        <h1 className="todo-section-title">Tasks & Objectives</h1>
        <p className="todo-section-subtitle">Scientific Task Management Protocol</p>
      </div>
      
      <TodoForm onAddTodo={handleAddTodo} />
      
      <FilterBar 
        filter={filter} 
        setFilter={setFilter} 
        todoCount={stats.total}
        activeCount={stats.active}
        completedCount={stats.completed}
      />
      
      <div className="todo-list-container">
        <TodoList 
          todos={filteredTodos}
          onToggleComplete={handleToggleComplete}
          onDelete={handleDeleteTodo}
          onEdit={handleEditTodo}
        />
      </div>
    </div>
  );
}

export default TodoSection;