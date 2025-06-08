import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  PREDEFINED_HABITS,
  createUserHabit,
  logHabitCompletion,
  subscribeUserHabits,
  getTodayHabitLogs,
  calculateDailyScore,
  getHabitCategories,
  getHabitsByCategory,
  calculateHabitScore
} from '../firebase/habits';
import '../styles/HabitsSection.css';

function HabitsSection() {
  const { user } = useAuth();
  const [userHabits, setUserHabits] = useState([]);
  const [todayLogs, setTodayLogs] = useState([]);
  const [dailyScore, setDailyScore] = useState({ totalScore: 0, possibleScore: 0, percentage: 0 });
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [showAddHabit, setShowAddHabit] = useState(false);
  const [loading, setLoading] = useState(true);

  const categories = ['All', ...getHabitCategories()];

  // Define loadTodayData function first
  const loadTodayData = useCallback(async () => {
    if (!user) return;
    
    try {
      const logs = await getTodayHabitLogs(user.uid);
      setTodayLogs(logs);
      
      const score = await calculateDailyScore(user.uid);
      setDailyScore(score);
    } catch (error) {
      console.error('Error loading today\'s data:', error);
    }
  }, [user]);

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    // Subscribe to user habits
    const unsubscribe = subscribeUserHabits(user.uid, (habits) => {
      setUserHabits(habits);
      setLoading(false);
      // Load today's data when habits change
      loadTodayData();
    }, (error) => {
      console.error('Error loading habits:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user, loadTodayData]);

  // Separate effect for loading today's data
  useEffect(() => {
    if (user) {
      loadTodayData();
    }
  }, [user, loadTodayData]);

  const handleAddHabit = async (habitId) => {
    console.log('Adding habit:', habitId);
    console.log('User ID:', user.uid);
    console.log('Current habits before add:', userHabits);
    
    try {
      const newHabit = await createUserHabit(user.uid, habitId);
      console.log('Habit added successfully:', newHabit);
      console.log('Habit document created with data:', newHabit);
      
      setShowAddHabit(false);
      
      // Force reload of habits
      setTimeout(() => {
        console.log('Current habits after add:', userHabits);
      }, 1000);
    } catch (error) {
      console.error('Error adding habit:', error);
      alert('Failed to add habit. Check console for details.');
    }
  };

  const handleCompleteHabit = async (habitId) => {
    try {
      await logHabitCompletion(user.uid, habitId);
      await loadTodayData(); // Refresh today's data
    } catch (error) {
      console.error('Error completing habit:', error);
    }
  };

  const isHabitCompleted = (habitId) => {
    return todayLogs.some(log => log.habitId === habitId && log.completed);
  };

  const getAvailableHabits = () => {
    const userHabitIds = userHabits.map(h => h.habitId);
    return Object.entries(PREDEFINED_HABITS)
      .filter(([id, _]) => !userHabitIds.includes(id))
      .map(([id, habit]) => ({ id, ...habit }));
  };

  const getFilteredHabits = () => {
    if (selectedCategory === 'All') return userHabits;
    return userHabits.filter(habit => habit.category === selectedCategory);
  };

  const getScoreColor = (percentage) => {
    if (percentage >= 80) return '#22c55e'; // Green
    if (percentage >= 60) return '#eab308'; // Yellow
    if (percentage >= 40) return '#f97316'; // Orange
    return '#ef4444'; // Red
  };

  if (loading) {
    return (
      <div className="habits-section-loading">
        <div className="loading-spinner"></div>
      </div>
    );
  }

  return (
    <div className="habits-section">
      {/* Mathematical annotations */}
      <div className="math-formula formula-1">∑habits = progress</div>
      <div className="math-formula formula-2">streak × consistency = growth</div>
      <div className="math-formula formula-3">∂progress/∂time = habits</div>
      
      
      {/* Header with Daily Score */}
      <div className="habits-header">
        <div className="header-content">
          <h1 className="habits-title">Habit Tracker</h1>
          <div className="daily-score-card">
            <div className="score-circle" style={{ '--score-color': getScoreColor(dailyScore.percentage) }}>
              <div className="score-number">{dailyScore.percentage}%</div>
              <div className="score-label">Daily Score</div>
            </div>
            <div className="score-details">
              <div className="score-stat">
                <span className="stat-number">{dailyScore.totalScore}</span>
                <span className="stat-label">Points Earned</span>
              </div>
              <div className="score-stat">
                <span className="stat-number">{dailyScore.completedHabits?.length || 0}</span>
                <span className="stat-label">Habits Completed</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Category Filters */}
      <div className="category-filters">
        {categories.map(category => (
          <button
            key={category}
            className={`category-btn ${selectedCategory === category ? 'active' : ''}`}
            onClick={() => setSelectedCategory(category)}
          >
            {category}
          </button>
        ))}
      </div>

      {/* Habits Grid */}
      <div className="habits-content">
        <div className="habits-grid">
          {getFilteredHabits().length > 0 ? (
            getFilteredHabits().map(habit => {
              const completed = isHabitCompleted(habit.habitId);
              const score = completed ? calculateHabitScore(habit.habitId, true, habit.currentStreak) : 0;
              
              return (
                <div 
                  key={habit.id} 
                  className={`habit-card ${completed ? 'completed' : ''}`}
                >
                  <div className="habit-header">
                    <h3 className="habit-name">{habit.name}</h3>
                    <div className="habit-score">
                      {score > 0 && <span className="score-badge">+{score}</span>}
                      <span className="base-points">{habit.points}pts</span>
                    </div>
                  </div>
                  
                  <p className="habit-description">{habit.description}</p>
                  
                  <div className="habit-stats">
                    <div className="stat">
                      <span className="stat-value">{habit.currentStreak || 0}</span>
                      <span className="stat-label">Streak</span>
                    </div>
                    <div className="stat">
                      <span className="stat-value">{habit.category}</span>
                      <span className="stat-label">Category</span>
                    </div>
                  </div>
                  
                  <button
                    className={`complete-btn ${completed ? 'completed' : ''}`}
                    onClick={() => !completed && handleCompleteHabit(habit.habitId)}
                    disabled={completed}
                  >
                    {completed ? '✓ Completed' : 'Mark Complete'}
                  </button>
                </div>
              );
            })
          ) : (
            <div className="empty-habits">
              <div className="empty-icon">📊</div>
              <h3>No habits in this category</h3>
              <p>Add some habits to start tracking your progress!</p>
            </div>
          )}
        </div>

        {/* Add Habit Section */}
        <div className="add-habit-section">
          <button 
            className="add-habit-btn"
            onClick={() => {
              console.log('Add Habit button clicked, current state:', showAddHabit);
              setShowAddHabit(!showAddHabit);
            }}
          >
            + Add New Habit
          </button>
          
          {showAddHabit && (
            <div className="add-habit-modal" style={{ display: 'flex', position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.8)', zIndex: 9999 }}>
              <div className="modal-content" style={{ margin: 'auto', backgroundColor: '#1a1a1a', padding: '2rem', borderRadius: '12px', maxWidth: '800px', maxHeight: '80vh', overflow: 'auto' }}>
                <div className="modal-header">
                  <h3>Choose a Habit to Track</h3>
                  <button 
                    className="close-btn"
                    onClick={() => setShowAddHabit(false)}
                    style={{ float: 'right', background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer' }}
                  >
                    ×
                  </button>
                </div>
                
                <div className="available-habits">
                  {getHabitCategories().map(category => {
                    const categoryHabits = getHabitsByCategory(category)
                      .filter(habit => !userHabits.some(uh => uh.habitId === habit.id));
                    
                    if (categoryHabits.length === 0) return null;
                    
                    return (
                      <div key={category} className="category-section">
                        <h4 className="category-title">{category}</h4>
                        <div className="habits-list">
                          {categoryHabits.map(habit => (
                            <div key={habit.id} className="available-habit">
                              <div className="habit-info">
                                <h5>{habit.name}</h5>
                                <p>{habit.description}</p>
                                <span className="points">{habit.points} points</span>
                              </div>
                              <button
                                className="select-habit-btn"
                                onClick={() => handleAddHabit(habit.id)}
                              >
                                Add
                              </button>
                            </div>
                          ))}
                        </div>
                      </div>
                    );
                  })}
                  
                  {getAvailableHabits().length === 0 && (
                    <div className="no-available-habits">
                      <p>You're tracking all available habits! 🎉</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default HabitsSection;