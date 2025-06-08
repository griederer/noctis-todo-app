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
import '../styles/DailyDashboard.css';

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
      const [habitsData, todosData, journalData] = await Promise.all([
        getSimpleDailyHabits(user.uid, dateString),
        getDailyTodos(user.uid, dateString),
        getTodayJournalEntry(user.uid, dateString)
      ]);
      
      setHabits(habitsData || {});
      setTodos(todosData || []);
      setJournalEntry(journalData || '');
    } catch (error) {
      console.error('Error loading day data:', error);
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

  if (loading) {
    return (
      <div className="daily-dashboard loading">
        <div className="loading-apparatus">
          <div className="apparatus-frame">
            <div className="loading-nodes"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="daily-dashboard">
      {/* Scientific Grid Background */}
      <div className="scientific-grid"></div>
      
      {/* Laboratory Frame */}
      <div className="lab-frame">
        
        {/* Date Navigation Header */}
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
              {isToday ? 'Today' : 'Day View'}
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

        {/* Central Control Panel */}
        <div className="control-panel">
          
          {/* Daily Score Observatory */}
          <div className="score-observatory">
            <div className="observatory-frame">
              <div className="score-lens" style={{ '--score': overallScore }}>
                <div className="score-reading">
                  <span className="score-value">{overallScore}%</span>
                  <span className="score-unit">daily</span>
                </div>
              </div>
              <div className="observatory-label">Overall Progress</div>
            </div>
            
            {/* Connection Lines to Sections */}
            <svg className="connection-lines" viewBox="0 0 800 600">
              <defs>
                <marker id="arrowhead" markerWidth="10" markerHeight="7" 
                        refX="10" refY="3.5" orient="auto">
                  <polygon points="0 0, 10 3.5, 0 7" fill="rgba(255,255,255,0.3)" />
                </marker>
              </defs>
              
              {/* Lines connecting to each section */}
              <line x1="400" y1="150" x2="200" y2="300" 
                    stroke="rgba(255,255,255,0.2)" strokeWidth="1" 
                    markerEnd="url(#arrowhead)" />
              <line x1="400" y1="150" x2="400" y2="300" 
                    stroke="rgba(255,255,255,0.2)" strokeWidth="1" 
                    markerEnd="url(#arrowhead)" />
              <line x1="400" y1="150" x2="600" y2="300" 
                    stroke="rgba(255,255,255,0.2)" strokeWidth="1" 
                    markerEnd="url(#arrowhead)" />
              
              {/* Scientific annotations */}
              <text x="100" y="20" fill="rgba(255,255,255,0.4)" fontSize="12" fontFamily="monospace">
                ∑(habits + tasks + reflection) = daily_progress
              </text>
              <text x="500" y="580" fill="rgba(255,255,255,0.4)" fontSize="12" fontFamily="monospace">
                δ/δt = continuous_improvement
              </text>
            </svg>
          </div>

          {/* Three Main Apparatus Sections */}
          <div className="apparatus-sections">
            
            {/* Today's Focus Apparatus */}
            <div className="apparatus-section focus-apparatus">
              <div className="apparatus-housing">
                <div className="section-label">
                  <div className="label-text">Today's Focus</div>
                  <div className="label-metric">{completedTodos}/{todos.length}</div>
                  <div className="progress-indicator" style={{ '--progress': todosScore }}></div>
                </div>
                
                <div className="apparatus-content">
                  <div className="todo-input-chamber">
                    <input
                      type="text"
                      value={newTodo}
                      onChange={(e) => setNewTodo(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && addTodo()}
                      placeholder="Add focus item for today..."
                      className="focus-input"
                    />
                    <button onClick={addTodo} className="add-focus-btn">+</button>
                  </div>
                  
                  <div className="focus-items">
                    {todos.map((todo, index) => (
                      <div key={todo.id} className={`focus-item ${todo.completed ? 'completed' : ''}`}>
                        <div className="item-node" onClick={() => toggleTodo(todo.id)}>
                          <div className="node-indicator">
                            {todo.completed ? '●' : '○'}
                          </div>
                        </div>
                        <div className="item-text">{todo.text}</div>
                        <div className="item-index">#{index + 1}</div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Habits Measurement Device */}
            <div className="apparatus-section habits-apparatus">
              <div className="apparatus-housing">
                <div className="section-label">
                  <div className="label-text">Daily Habits</div>
                  <div className="label-metric">{completedHabits}/{DAILY_HABITS.length}</div>
                  <div className="progress-indicator" style={{ '--progress': habitsScore }}></div>
                </div>
                
                <div className="apparatus-content">
                  <div className="habits-grid">
                    {DAILY_HABITS.map((habit, index) => (
                      <div 
                        key={habit.id} 
                        className={`habit-node ${habits[habit.id] ? 'active' : ''}`}
                        onClick={() => toggleHabit(habit.id)}
                        title={habit.text}
                      >
                        <div className="node-core">
                          <div className="node-icon">{habit.icon}</div>
                          <div className="node-state">
                            {habits[habit.id] ? '●' : '○'}
                          </div>
                        </div>
                        <div className="node-label">{habit.short}</div>
                        <div className="node-index">{index + 1}</div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Journal Recording Apparatus */}
            <div className="apparatus-section journal-apparatus">
              <div className="apparatus-housing">
                <div className="section-label">
                  <div className="label-text">Daily Reflection</div>
                  <div className="label-metric">{journalEntry.length} chars</div>
                  <div className="progress-indicator" style={{ '--progress': journalScore }}></div>
                </div>
                
                <div className="apparatus-content">
                  <div className="journal-chamber">
                    <textarea
                      value={journalEntry}
                      onChange={(e) => setJournalEntry(e.target.value)}
                      onBlur={saveJournal}
                      placeholder="Record today's observations, thoughts, and reflections..."
                      className="journal-input"
                      rows="6"
                    />
                    <div className="journal-metadata">
                      <div className="metadata-item">
                        Date: {dateString}
                      </div>
                      <div className="metadata-item">
                        Auto-saved
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Scientific Measurements Display */}
        <div className="measurements-panel">
          <div className="measurement-reading">
            <span className="reading-label">H</span>
            <span className="reading-value">{habitsScore}%</span>
            <span className="reading-unit">habits</span>
          </div>
          <div className="measurement-reading">
            <span className="reading-label">T</span>
            <span className="reading-value">{todosScore}%</span>
            <span className="reading-unit">tasks</span>
          </div>
          <div className="measurement-reading">
            <span className="reading-label">J</span>
            <span className="reading-value">{journalScore}%</span>
            <span className="reading-unit">journal</span>
          </div>
        </div>

        {/* Frame Corners and Scientific Details */}
        <div className="frame-corners">
          <div className="corner top-left">
            <div className="corner-detail"></div>
            <span className="corner-label">α</span>
          </div>
          <div className="corner top-right">
            <div className="corner-detail"></div>
            <span className="corner-label">β</span>
          </div>
          <div className="corner bottom-left">
            <div className="corner-detail"></div>
            <span className="corner-label">γ</span>
          </div>
          <div className="corner bottom-right">
            <div className="corner-detail"></div>
            <span className="corner-label">δ</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DailyDashboard;