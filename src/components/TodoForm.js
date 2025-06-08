import React, { useState } from 'react';
import '../styles/TodoForm.css';

function TodoForm({ onAddTodo }) {
  const [title, setTitle] = useState('');
  const [priority, setPriority] = useState('medium');
  const [dueDate, setDueDate] = useState('');
  const [dueTime, setDueTime] = useState('');

  // Generate time options in 30-minute intervals
  const generateTimeOptions = () => {
    const times = [];
    for (let hour = 0; hour < 24; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        const timeString = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        const displayTime = new Date(`2000-01-01T${timeString}`).toLocaleTimeString([], { 
          hour: '2-digit', 
          minute: '2-digit',
          hour12: true 
        });
        times.push({ value: timeString, display: displayTime });
      }
    }
    return times;
  };

  const timeOptions = generateTimeOptions();

  const handleSubmit = (e) => {
    e.preventDefault();
    if (title.trim()) {
      const todoData = {
        title: title.trim(),
        priority,
        completed: false
      };

      // Add due date/time if provided
      if (dueDate) {
        todoData.dueDate = dueDate;
        if (dueTime) {
          todoData.dueTime = dueTime;
          // Create full datetime for sorting
          todoData.dueDateTime = new Date(`${dueDate}T${dueTime}`);
        }
      }

      onAddTodo(todoData);
      setTitle('');
      setPriority('medium');
      setDueDate('');
      setDueTime('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="todo-form">
      <div className="todo-form-header">
        <h3 className="todo-form-title">New Task Entry</h3>
        <span className="todo-form-legend">Document ID: {Date.now().toString(36)}</span>
      </div>
      
      <div className="todo-form-grid">
        <div className="todo-form-full">
          <div className="todo-input-group">
            <label className="todo-input-label">Task Description</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Enter detailed task description..."
              className="todo-input"
              autoFocus
            />
          </div>
        </div>
        
        <div className="todo-input-group">
          <label className="todo-input-label">Priority Classification</label>
          <div className="todo-priority-group">
            {['low', 'medium', 'high'].map(priorityLevel => (
              <button
                key={priorityLevel}
                type="button"
                className={`todo-priority-option ${priority === priorityLevel ? 'selected' : ''}`}
                onClick={() => setPriority(priorityLevel)}
              >
                {priorityLevel.charAt(0).toUpperCase() + priorityLevel.slice(1)}
              </button>
            ))}
          </div>
        </div>
        
        <div className="todo-input-group">
          <label className="todo-input-label">Due Date & Time</label>
          <div className="todo-datetime-group">
            <input
              type="date"
              value={dueDate}
              onChange={(e) => setDueDate(e.target.value)}
              className="todo-date-input"
              min={new Date().toISOString().split('T')[0]}
            />
            
            <select
              value={dueTime}
              onChange={(e) => setDueTime(e.target.value)}
              className="todo-time-input"
              disabled={!dueDate}
            >
              <option value="">Time</option>
              {timeOptions.map(time => (
                <option key={time.value} value={time.value}>
                  {time.display}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>
      
      <div className="todo-form-actions">
        <button type="button" className="todo-btn-secondary" onClick={() => {
          setTitle('');
          setPriority('medium');
          setDueDate('');
          setDueTime('');
        }}>
          Clear
        </button>
        <button type="submit" className="todo-btn-primary">
          Add Task Entry
        </button>
      </div>
    </form>
  );
}

export default TodoForm; 