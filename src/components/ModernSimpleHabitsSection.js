import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { 
  saveSimpleDailyHabits, 
  getSimpleDailyHabits 
} from '../firebase/simpleHabits';

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

function ModernSimpleHabitsSection() {
  const { user } = useAuth();
  const [completedHabits, setCompletedHabits] = useState({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

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
    if (!user || saving) return;

    setSaving(true);
    const newCompletedHabits = {
      ...completedHabits,
      [habitId]: !completedHabits[habitId]
    };

    setCompletedHabits(newCompletedHabits);

    try {
      await saveSimpleDailyHabits(user.uid, todayString, newCompletedHabits);
    } catch (error) {
      console.error('Error saving habits:', error);
      // Revert on error
      setCompletedHabits(completedHabits);
    } finally {
      setSaving(false);
    }
  };

  const getCompletionStats = () => {
    const completed = Object.values(completedHabits).filter(Boolean).length;
    const total = DAILY_HABITS.length;
    const percentage = Math.round((completed / total) * 100);
    return { completed, total, percentage };
  };

  const formatDate = () => {
    return new Date().toLocaleDateString([], { 
      weekday: 'long',
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="text-text-secondary">Loading habits...</div>
      </div>
    );
  }

  const stats = getCompletionStats();

  return (
    <div className="max-w-2xl mx-auto">
      {/* Header with Stats */}
      <div className="bg-bg-secondary rounded-lg p-6 mb-6 border border-border-light">
        <div className="text-center">
          <h2 className="text-2xl font-semibold text-text-primary mb-2">Daily Habits</h2>
          <p className="text-text-secondary mb-4">{formatDate()}</p>
          
          {/* Progress Circle */}
          <div className="flex items-center justify-center mb-4">
            <div className="relative w-24 h-24">
              <svg className="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
                <circle
                  cx="50"
                  cy="50"
                  r="40"
                  stroke="var(--border-light)"
                  strokeWidth="8"
                  fill="transparent"
                />
                <circle
                  cx="50"
                  cy="50"
                  r="40"
                  stroke="var(--accent-blue)"
                  strokeWidth="8"
                  fill="transparent"
                  strokeDasharray={`${2 * Math.PI * 40}`}
                  strokeDashoffset={`${2 * Math.PI * 40 * (1 - stats.percentage / 100)}`}
                  className="transition-all duration-300"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-2xl font-bold text-text-primary">{stats.percentage}%</span>
              </div>
            </div>
          </div>
          
          <div className="text-lg font-medium text-text-primary">
            {stats.completed} of {stats.total} habits completed
          </div>
          
          {stats.percentage === 100 && (
            <div className="mt-3 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
              🎉 Perfect day!
            </div>
          )}
        </div>
      </div>

      {/* Habits Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {DAILY_HABITS.map((habit) => {
          const isCompleted = completedHabits[habit.id];
          
          return (
            <div
              key={habit.id}
              onClick={() => toggleHabit(habit.id)}
              className={`p-4 rounded-lg border transition-all cursor-pointer ${
                isCompleted
                  ? 'bg-accent-blue-light border-accent-blue'
                  : 'bg-bg-primary border-border-light hover:border-accent-blue hover:bg-bg-secondary'
              } ${saving ? 'opacity-50 pointer-events-none' : ''}`}
            >
              <div className="flex items-center space-x-3">
                <div className={`w-8 h-8 rounded-full border-2 flex items-center justify-center transition-all ${
                  isCompleted
                    ? 'bg-accent-blue border-accent-blue'
                    : 'border-border-main'
                }`}>
                  {isCompleted && (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                      <polyline points="20,6 9,17 4,12"></polyline>
                    </svg>
                  )}
                </div>
                
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    <span className="text-xl">{habit.icon}</span>
                    <span className={`font-medium ${
                      isCompleted ? 'text-text-primary' : 'text-text-primary'
                    }`}>
                      {habit.text}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Motivational Footer */}
      <div className="mt-8 text-center">
        <div className="bg-bg-secondary rounded-lg p-4 border border-border-light">
          <p className="text-text-secondary text-sm">
            {stats.percentage >= 80 
              ? "Outstanding! You're building amazing habits! 🌟" 
              : stats.percentage >= 50 
              ? "Great progress! Keep up the momentum! 💪"
              : "Every habit counts. Start small, build big! 🌱"
            }
          </p>
        </div>
      </div>
    </div>
  );
}

export default ModernSimpleHabitsSection;