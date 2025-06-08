import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { 
  saveSimpleDailyHabits, 
  getSimpleDailyHabits 
} from '../firebase/simpleHabits';
import '../styles/SimpleHabitsSection.css';

const DAILY_HABITS = [
  { id: 'water', icon: '💧', text: 'Drink 8 glasses of water' },
  { id: 'exercise', icon: '🏃', text: 'Exercise for 30 minutes' },
  { id: 'sleep', icon: '😴', text: 'Get 7+ hours of sleep' },
  { id: 'nutrition', icon: '🥗', text: 'Eat 5 servings fruits/vegetables' },
  { id: 'meditate', icon: '🧘', text: 'Meditate for 10 minutes' },
  { id: 'read', icon: '📚', text: 'Read for 20 minutes' },
  { id: 'screens', icon: '📱', text: 'No screens 1 hour before bed' },
  { id: 'bed', icon: '🛏️', text: 'Make your bed' },
  { id: 'gratitude', icon: '🙏', text: 'Write 3 things you\'re grateful for' },
  { id: 'walk', icon: '🚶', text: 'Take a 10-minute walk outside' }
];

function SimpleHabitsSection() {
  const { user } = useAuth();
  const [completedHabits, setCompletedHabits] = useState({});
  const [loading, setLoading] = useState(true);

  const todayString = new Date().toDateString();

  useEffect(() => {
    const loadTodayHabits = async () => {
      if (!user) {
        setLoading(false);
        return;
      }
      
      try {
        const todayData = await getSimpleDailyHabits(user.uid, todayString);
        setCompletedHabits(todayData || {});
      } catch (error) {
        console.error('Error loading habits:', error);
        setCompletedHabits({});
      } finally {
        setLoading(false);
      }
    };

    loadTodayHabits();
  }, [user, todayString]);

  const toggleHabit = async (habitId) => {
    if (!user) return;

    const newCompletedHabits = {
      ...completedHabits,
      [habitId]: !completedHabits[habitId]
    };

    console.log('Toggling habit:', habitId, 'New state:', newCompletedHabits[habitId]);
    setCompletedHabits(newCompletedHabits);

    try {
      await saveSimpleDailyHabits(user.uid, todayString, newCompletedHabits);
      console.log('Habit saved successfully');
    } catch (error) {
      console.error('Error saving habit:', error);
      // Revert on error
      setCompletedHabits(completedHabits);
    }
  };

  const completedCount = Object.values(completedHabits).filter(Boolean).length;
  const score = Math.round((completedCount / DAILY_HABITS.length) * 100);
  
  console.log('Score calculation:', { completedHabits, completedCount, totalHabits: DAILY_HABITS.length, score });

  const getScoreColor = (percentage) => {
    if (percentage >= 80) return '#22c55e'; // Green
    if (percentage >= 60) return '#eab308'; // Yellow
    if (percentage >= 40) return '#f97316'; // Orange
    return '#ef4444'; // Red
  };

  if (loading) {
    return (
      <div className="simple-habits-loading">
        <div className="loading-spinner"></div>
      </div>
    );
  }

  return (
    <div className="simple-habits-section">
      {/* Mathematical annotations */}
      <div className="math-formula formula-1">∑habits = progress</div>
      <div className="math-formula formula-2">daily consistency = growth</div>
      <div className="math-formula formula-3">10 habits × focus = success</div>
      
      {/* Header with Daily Score */}
      <div className="simple-habits-header">
        <div className="header-content">
          <h1 className="habits-title">Daily Habits</h1>
          <div className="daily-score-card">
            <div className="score-circle" style={{ 
              '--score-color': getScoreColor(score),
              '--percentage': score
            }}>
              <div className="score-number">{score}%</div>
              <div className="score-label">Daily Score</div>
            </div>
            <div className="score-details">
              <div className="score-stat">
                <span className="stat-number">{completedCount}</span>
                <span className="stat-label">Completed</span>
              </div>
              <div className="score-stat">
                <span className="stat-number">{DAILY_HABITS.length - completedCount}</span>
                <span className="stat-label">Remaining</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Daily Habits Grid */}
      <div className="habits-content">
        <div className="daily-habits-grid">
          {DAILY_HABITS.map(habit => {
            const isCompleted = completedHabits[habit.id] || false;
            
            return (
              <div 
                key={habit.id} 
                className={`daily-habit-card ${isCompleted ? 'completed' : ''}`}
                onClick={() => toggleHabit(habit.id)}
              >
                <div className="habit-icon">{habit.icon}</div>
                <div className="habit-text">{habit.text}</div>
                <div className={`habit-checkbox ${isCompleted ? 'checked' : ''}`}>
                  {isCompleted && '✓'}
                </div>
                <div className="habit-points">+1</div>
              </div>
            );
          })}
        </div>

        {/* Progress Message */}
        <div className="progress-message">
          {score === 100 && (
            <div className="perfect-day">
              🎉 Perfect day! All habits completed!
            </div>
          )}
          {score >= 80 && score < 100 && (
            <div className="great-day">
              🌟 Great progress! Almost there!
            </div>
          )}
          {score >= 50 && score < 80 && (
            <div className="good-day">
              👍 Good work! Keep it up!
            </div>
          )}
          {score < 50 && completedCount > 0 && (
            <div className="getting-started">
              💪 Getting started! Every habit counts!
            </div>
          )}
          {score === 0 && (
            <div className="start-today">
              🌅 New day, new opportunities! Start with one habit.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default SimpleHabitsSection;