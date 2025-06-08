import React from 'react';
import TodoItem from './TodoItem';
import '../styles/TodoList.css';

const TodoList = React.memo(({ todos, onToggleComplete, onDelete, onEdit }) => {
  if (todos.length === 0) {
    return (
      <div className="todo-empty-state">
        <div className="todo-empty-state-icon">📋</div>
        <h3 className="todo-empty-state-title">No Task Entries Found</h3>
        <p className="todo-empty-state-message">
          Begin documenting your objectives using the form above.<br />
          All entries will be catalogued and tracked systematically.
        </p>
      </div>
    );
  }

  return (
    <ul className="todo-list">
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
    </ul>
  );
});

TodoList.displayName = 'TodoList';

export default TodoList; 