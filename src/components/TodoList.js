import React from 'react';
import TodoItem from './TodoItem';
import '../styles/TodoList.css';

const TodoList = React.memo(({ todos, onToggleComplete, onDelete, onEdit }) => {
  if (todos.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-pattern">
          <div className="empty-line"></div>
          <div className="empty-line"></div>
          <div className="empty-line"></div>
        </div>
        <p className="empty-text">No tasks yet. Add one to get started!</p>
      </div>
    );
  }

  return (
    <div className="todo-list">
      {todos.map((todo, index) => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggleComplete={onToggleComplete}
          onDelete={onDelete}
          onEdit={onEdit}
          index={index}
        />
      ))}
    </div>
  );
});

TodoList.displayName = 'TodoList';

export default TodoList; 