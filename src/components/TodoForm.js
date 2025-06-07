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
      <div className="form-input-container">
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Add a new task..."
          className="todo-input"
          autoFocus
        />
        
        <div className="form-row">
          <select
            value={priority}
            onChange={(e) => setPriority(e.target.value)}
            className="priority-select"
          >
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </select>
          
          <input
            type="date"
            value={dueDate}
            onChange={(e) => setDueDate(e.target.value)}
            className="date-input"
            min={new Date().toISOString().split('T')[0]}
            placeholder="Due date"
          />
          
          <select
            value={dueTime}
            onChange={(e) => setDueTime(e.target.value)}
            className="time-select"
            disabled={!dueDate}
          >
            <option value="">Select time</option>
            {timeOptions.map(time => (
              <option key={time.value} value={time.value}>
                {time.display}
              </option>
            ))}
          </select>
        </div>
        
        <button type="submit" className="add-button">
          Add Task
        </button>
      </div>
    </form>
  );
}

export default TodoForm; 