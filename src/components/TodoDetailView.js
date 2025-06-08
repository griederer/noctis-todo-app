import React, { useState, useEffect } from 'react';

const TodoDetailView = ({ todo, isOpen, onClose, onUpdate, onDelete }) => {
  const [notes, setNotes] = useState('');
  const [title, setTitle] = useState('');

  useEffect(() => {
    if (todo) {
      setTitle(todo.title || '');
      setNotes(todo.notes || '');
    }
  }, [todo]);

  const handleSave = () => {
    if (onUpdate && todo) {
      onUpdate(todo.id, { 
        title: title.trim(),
        notes: notes.trim() 
      });
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Escape') {
      onClose();
    }
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
      handleSave();
    }
  };

  if (!isOpen || !todo) {
    return null;
  }

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString([], { 
      weekday: 'long',
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  const formatTime = (timeString) => {
    if (!timeString) return '';
    const time = new Date(`2000-01-01T${timeString}`);
    return time.toLocaleTimeString([], { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: true 
    });
  };

  return (
    <div className={`detail-panel ${isOpen ? 'open' : ''}`} onKeyDown={handleKeyDown} tabIndex={-1}>
      <div className="detail-header">
        <h3 className="text-lg font-semibold text-text-primary">Task Details</h3>
        <button 
          className="detail-close-btn"
          onClick={onClose}
          aria-label="Close details"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      
      <div className="detail-body">
        {/* Task Title */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-text-secondary mb-2">
            Task Title
          </label>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            onBlur={handleSave}
            className="w-full text-xl font-semibold text-text-primary bg-transparent border-none outline-none"
            placeholder="Enter task title..."
          />
        </div>

        {/* Task Metadata */}
        <div className="mb-6 space-y-3">
          {todo.priority && (
            <div className="flex items-center">
              <span className="text-sm text-text-secondary font-medium mr-3">Priority:</span>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                todo.priority === 'high' ? 'bg-red-100 text-red-800' :
                todo.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                'bg-green-100 text-green-800'
              }`}>
                {todo.priority}
              </span>
            </div>
          )}
          
          {todo.dueDate && (
            <div className="flex items-center">
              <span className="text-sm text-text-secondary font-medium mr-3">Due:</span>
              <span className="text-sm text-text-primary">
                {formatDate(todo.dueDate)}
                {todo.dueTime && ` at ${formatTime(todo.dueTime)}`}
              </span>
            </div>
          )}
          
          <div className="flex items-center">
            <span className="text-sm text-text-secondary font-medium mr-3">Status:</span>
            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
              todo.completed ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
            }`}>
              {todo.completed ? 'Completed' : 'Active'}
            </span>
          </div>
          
          {todo.createdAt && (
            <div className="flex items-center">
              <span className="text-sm text-text-secondary font-medium mr-3">Created:</span>
              <span className="text-sm text-text-tertiary">
                {new Date(todo.createdAt).toLocaleDateString()}
              </span>
            </div>
          )}
        </div>

        {/* Notes Section */}
        <div className="mb-6">
          <label className="block text-sm font-medium text-text-secondary mb-3">
            Notes
          </label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            onBlur={handleSave}
            className="w-full h-48 p-4 text-sm text-text-primary bg-bg-secondary border border-border-light rounded-md resize-none outline-none focus:ring-2 focus:ring-accent-blue focus:border-transparent"
            placeholder="Add notes, details, or context for this task..."
          />
        </div>

        {/* Action Buttons */}
        <div className="space-y-2">
          <button
            onClick={() => onUpdate && onUpdate(todo.id, { completed: !todo.completed })}
            className={`w-full py-2.5 px-4 rounded-md font-medium text-sm transition-colors ${
              todo.completed
                ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                : 'bg-accent-blue text-white hover:bg-accent-blue-hover'
            }`}
          >
            {todo.completed ? 'Mark as Active' : 'Mark as Complete'}
          </button>
          
          <button
            onClick={() => {
              if (window.confirm('Are you sure you want to delete this task?')) {
                onDelete && onDelete(todo.id);
                onClose();
              }
            }}
            className="w-full py-2.5 px-4 rounded-md font-medium text-sm bg-red-50 text-red-700 hover:bg-red-100 transition-colors"
          >
            Delete Task
          </button>
        </div>

        {/* Keyboard Shortcuts */}
        <div className="mt-8 pt-6 border-t border-border-light">
          <h4 className="text-xs font-semibold text-text-secondary uppercase tracking-wide mb-2">
            Keyboard Shortcuts
          </h4>
          <div className="space-y-1 text-xs text-text-tertiary">
            <div>Escape — Close details</div>
            <div>⌘ + Enter — Save changes</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TodoDetailView;