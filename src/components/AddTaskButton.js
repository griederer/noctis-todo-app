import React, { useState } from 'react';

const AddTaskButton = ({ onAddTask }) => {
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [project, setProject] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (title.trim()) {
      const todoData = {
        title: title.trim(),
        completed: false,
        createdAt: new Date().toISOString()
      };
      
      // Only add project if it has a value (Firebase doesn't allow undefined)
      if (project.trim()) {
        todoData.project = project.trim();
      }
      
      onAddTask(todoData);
      setTitle('');
      setProject('');
      setShowForm(false);
    }
  };

  const handleCancel = () => {
    setTitle('');
    setProject('');
    setShowForm(false);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Escape') {
      handleCancel();
    }
  };

  if (showForm) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-20 flex items-end justify-center p-4 z-50 md:items-center">
        <div className="w-full max-w-md bg-white rounded-lg shadow-lg animate-slide-in">
          <form onSubmit={handleSubmit} className="add-task-form" onKeyDown={handleKeyDown}>
            <div className="mb-4">
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="What needs to be done?"
                className="task-input"
                autoFocus
              />
              <input
                type="text"
                value={project}
                onChange={(e) => setProject(e.target.value)}
                placeholder="Project (optional)"
                className="task-meta-input"
              />
            </div>
            
            <div className="form-actions">
              <button 
                type="button" 
                onClick={handleCancel}
                className="btn btn-secondary"
              >
                Cancel
              </button>
              <button 
                type="submit" 
                className="btn btn-primary"
                disabled={!title.trim()}
              >
                Add Task
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  return (
    <button
      onClick={() => setShowForm(true)}
      className="add-task-btn"
      aria-label="Add new task"
    >
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <line x1="12" y1="5" x2="12" y2="19"></line>
        <line x1="5" y1="12" x2="19" y2="12"></line>
      </svg>
    </button>
  );
};

export default AddTaskButton;