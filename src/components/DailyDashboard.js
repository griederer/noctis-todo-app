import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { 
  getSimpleDailyHabits,
  saveSimpleDailyHabits 
} from '../firebase/simpleHabits';
import {
  getDailyTodos,
  saveDailyTodos,
  getTodayJournalEntry,
  saveTodayJournalEntry
} from '../firebase/dailyData';
import '../styles/ScientificManuscript.css';

const DAILY_HABITS = [
  { id: 'water', icon: '💧', text: 'Drink 8 glasses of water', short: 'Water' },
  { id: 'exercise', icon: '🏃', text: 'Exercise for 30 minutes', short: 'Exercise' },
  { id: 'sleep', icon: '😴', text: 'Get 7+ hours of sleep', short: 'Sleep' },
  { id: 'nutrition', icon: '🥗', text: 'Eat 5 servings fruits/vegetables', short: 'Nutrition' },
  { id: 'meditate', icon: '🧘', text: 'Meditate for 10 minutes', short: 'Meditate' },
  { id: 'read', icon: '📚', text: 'Read for 20 minutes', short: 'Read' },
  { id: 'screens', icon: '📱', text: 'No screens 1 hour before bed', short: 'Digital' },
  { id: 'bed', icon: '🛏️', text: 'Make your bed', short: 'Order' },
  { id: 'gratitude', icon: '🙏', text: 'Write 3 things you\'re grateful for', short: 'Gratitude' },
  { id: 'walk', icon: '🚶', text: 'Take a 10-minute walk outside', short: 'Nature' }
];

function DailyDashboard() {
  const { user } = useAuth();
  const [currentDate, setCurrentDate] = useState(new Date());
  const [habits, setHabits] = useState({});
  const [todos, setTodos] = useState([]);
  const [journalEntry, setJournalEntry] = useState('');
  const [newTodo, setNewTodo] = useState('');
  const [loading, setLoading] = useState(true);

  const dateString = currentDate.toDateString();
  const isToday = new Date().toDateString() === dateString;

  const loadDayData = useCallback(async () => {
    if (!user) {
      setLoading(false);
      return;
    }
    
    try {
      setLoading(true);
      console.log('Loading day data for:', dateString);
      
      const [habitsData, todosData, journalData] = await Promise.all([
        getSimpleDailyHabits(user.uid, dateString),
        getDailyTodos(user.uid, dateString),
        getTodayJournalEntry(user.uid, dateString)
      ]);
      
      console.log('Day data loaded successfully:', { habitsData, todosData, journalData });
      
      setHabits(habitsData || {});
      setTodos(todosData || []);
      setJournalEntry(journalData || '');
    } catch (error) {
      console.error('Error loading day data:', error);
      console.error('Error details:', error.message, error.stack);
      // Don't throw the error, just log it and continue with empty data
      setHabits({});
      setTodos([]);
      setJournalEntry('');
    } finally {
      setLoading(false);
    }
  }, [user, dateString]);

  useEffect(() => {
    loadDayData();
  }, [loadDayData]);

  const toggleHabit = async (habitId) => {
    if (!user) return;
    
    const newHabits = {
      ...habits,
      [habitId]: !habits[habitId]
    };
    
    setHabits(newHabits);
    
    try {
      await saveSimpleDailyHabits(user.uid, dateString, newHabits);
    } catch (error) {
      console.error('Error saving habit:', error);
      setHabits(habits);
    }
  };

  const addTodo = async () => {
    if (!user || !newTodo.trim()) return;
    
    const newTodoItem = {
      id: Date.now().toString(),
      text: newTodo.trim(),
      completed: false,
      createdAt: new Date().toISOString()
    };
    
    const updatedTodos = [...todos, newTodoItem];
    setTodos(updatedTodos);
    setNewTodo('');
    
    try {
      await saveDailyTodos(user.uid, dateString, updatedTodos);
    } catch (error) {
      console.error('Error saving todo:', error);
      setTodos(todos);
    }
  };

  const toggleTodo = async (todoId) => {
    if (!user) return;
    
    const updatedTodos = todos.map(todo => 
      todo.id === todoId ? { ...todo, completed: !todo.completed } : todo
    );
    
    setTodos(updatedTodos);
    
    try {
      await saveDailyTodos(user.uid, dateString, updatedTodos);
    } catch (error) {
      console.error('Error updating todo:', error);
      setTodos(todos);
    }
  };

  const saveJournal = async () => {
    if (!user) return;
    
    try {
      await saveTodayJournalEntry(user.uid, dateString, journalEntry);
    } catch (error) {
      console.error('Error saving journal:', error);
    }
  };

  const navigateDay = (direction) => {
    const newDate = new Date(currentDate);
    newDate.setDate(newDate.getDate() + direction);
    setCurrentDate(newDate);
  };

  const completedHabits = Object.values(habits).filter(Boolean).length;
  const habitsScore = Math.round((completedHabits / DAILY_HABITS.length) * 100);
  const completedTodos = todos.filter(todo => todo.completed).length;
  const todosScore = todos.length > 0 ? Math.round((completedTodos / todos.length) * 100) : 0;
  const journalScore = journalEntry.trim() ? 100 : 0;
  const overallScore = Math.round((habitsScore + todosScore + journalScore) / 3);

  const formatDate = (date) => {
    return new Intl.DateTimeFormat('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(date);
  };

  // Don't render if user is not authenticated
  if (!user) {
    return (
      <div className="daily-dashboard">
        <div className="loading-container">
          <div className="loading-dots">
            <div className="loading-dot"></div>
            <div className="loading-dot"></div>
            <div className="loading-dot"></div>
          </div>
          <div className="loading-text">
            Authentication required for experiment access
          </div>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="daily-dashboard">
        <div className="loading-container">
          <div className="loading-dots">
            <div className="loading-dot"></div>
            <div className="loading-dot"></div>
            <div className="loading-dot"></div>
          </div>
          <div className="loading-text">
            Initializing daily analysis apparatus...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="daily-dashboard" style={{ '--percentage': overallScore }}>
      {/* Technical Annotations */}
      <div className="technical-annotations">
        <div className="annotation top-left">
          Experiment: Daily Productivity Analysis<br/>
          Date: {new Date().toISOString().split('T')[0]}<br/>
          Subject: Personal Optimization
        </div>
        <div className="annotation top-right">
          δ/δt = progress_rate<br/>
          Σ(habits + tasks + journal) = total_score<br/>
          var(daily_performance)
        </div>
        <div className="annotation bottom-left">
          Coordinates: Daily View<br/>
          Scale: 1:1 (real-time)<br/>
          Units: percentage (%)
        </div>
        <div className="annotation bottom-right">
          Fig. {formatDate(currentDate)}<br/>
          Observer: {user?.email}<br/>
          Status: {isToday ? 'ACTIVE' : 'HISTORICAL'}
        </div>
      </div>

      {/* Scientific Measurement Lines */}
      <div className="measurement-lines">
        <div className="measure-line horizontal" style={{ top: '15%', left: '5%' }}></div>
        <div className="measure-line vertical" style={{ top: '10%', left: '10%' }}></div>
        <div className="measure-line diagonal" style={{ top: '20%', right: '8%', transform: 'rotate(45deg)' }}></div>
        <div className="measure-line horizontal" style={{ bottom: '25%', right: '12%' }}></div>
        <div className="measure-line vertical" style={{ bottom: '15%', left: '8%' }}></div>
      </div>
      
      <div className="dashboard-container">
        <div className="dashboard-header">
          <div className="date-navigation">
            <button 
              className="nav-arrow left" 
              onClick={() => navigateDay(-1)}
              aria-label="Previous day"
            >
              ←
            </button>
            <div className="date-display">
              <div className="date-label">
                {isToday ? 'Current Observation' : 'Historical Data'}
              </div>
              <div className="date-full">
                {formatDate(currentDate)}
              </div>
            </div>
            <button 
              className="nav-arrow right" 
              onClick={() => navigateDay(1)}
              aria-label="Next day"
            >
              →
            </button>
          </div>
          
          <div className="score-observatory">
            <div className="score-circle-container">
              <div className="score-circle" style={{ '--percentage': overallScore }}>
                <div className="score-display">
                  <div className="score-number">{overallScore}</div>
                  <div className="score-label">Efficiency</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="dashboard-grid">
          <div className="dashboard-module focus-module" data-module-id="A.1">
            <div className="module-header">
              <h2 className="module-title">Task Analysis</h2>
              <div className="module-metric">{completedTodos}/{todos.length}</div>
            </div>
            <div className="module-content">
              <div className="focus-input-container">
                <input
                  type="text"
                  value={newTodo}
                  onChange={(e) => setNewTodo(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && addTodo()}
                  placeholder="Add new task to analysis..."
                  className="focus-input"
                />
                <button onClick={addTodo} className="add-focus-btn">+</button>
              </div>
              
              <div className="focus-items">
                {todos.map((todo, index) => (
                  <div key={todo.id} className={`focus-item ${todo.completed ? 'completed' : ''}`} onClick={() => toggleTodo(todo.id)}>
                    <div className="focus-checkbox">
                      {todo.completed ? '✓' : (index + 1).toString().padStart(2, '0')}
                    </div>
                    <div className="focus-text">{todo.text}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="dashboard-module habits-module" data-module-id="B.1">
            <div className="module-header">
              <h2 className="module-title">Behavioral Matrix</h2>
              <div className="module-metric">{completedHabits}/{DAILY_HABITS.length}</div>
            </div>
            <div className="module-content">
              <div className="habits-grid">
                {DAILY_HABITS.map((habit, index) => (
                  <div 
                    key={habit.id} 
                    className={`habit-dot ${habits[habit.id] ? 'completed' : ''}`}
                    onClick={() => toggleHabit(habit.id)}
                    title={`${habit.text} [${(index + 1).toString().padStart(2, '0')}]`}
                  >
                    <div className="habit-icon">{habit.icon}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="dashboard-module journal-module" data-module-id="C.1">
            <div className="module-header">
              <h2 className="module-title">Daily Observations</h2>
              <div className="module-metric">{journalEntry.length > 0 ? Math.min(journalEntry.length, 999) : '000'}</div>
            </div>
            <div className="module-content">
              <textarea
                value={journalEntry}
                onChange={(e) => setJournalEntry(e.target.value)}
                onBlur={saveJournal}
                placeholder="Record experimental observations, hypotheses, and conclusions..."
                className="journal-textarea"
              />
              <div className="journal-metadata">
                <div>Timestamp: {dateString}</div>
                <div>Status: Auto-logged</div>
              </div>
            </div>
          </div>
        </div>

        <div className="measurements-bar">
          <div className="measurement-item">
            <div className="measurement-label">Behavioral</div>
            <div className="measurement-value measurement-habits">{habitsScore}%</div>
          </div>
          <div className="measurement-item">
            <div className="measurement-label">Productive</div>
            <div className="measurement-value measurement-tasks">{todosScore}%</div>
          </div>
          <div className="measurement-item">
            <div className="measurement-label">Reflective</div>
            <div className="measurement-value measurement-journal">{journalScore}%</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DailyDashboard;