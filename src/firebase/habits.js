import { 
  collection, 
  doc, 
  addDoc, 
  updateDoc, 
  query, 
  where, 
  orderBy, 
  onSnapshot,
  serverTimestamp,
  getDocs
} from 'firebase/firestore';
import { db } from './config';

// Collection reference
const habitsCollection = collection(db, 'habits');
const habitLogsCollection = collection(db, 'habitLogs');

// Predefined habits with scoring
export const PREDEFINED_HABITS = {
  // Sleep & Rest (High Impact)
  'consistent-sleep': { name: 'Consistent Sleep Schedule', points: 40, category: 'Sleep & Rest', description: '7-9 hours sleep at consistent times' },
  'quality-sleep': { name: 'Quality Sleep (7+ hours)', points: 35, category: 'Sleep & Rest', description: 'Get at least 7 hours of sleep' },
  'no-screens-bed': { name: 'No Screens Before Bed', points: 20, category: 'Sleep & Rest', description: 'Avoid screens 1 hour before sleep' },
  
  // Physical Health (High Impact)
  'daily-exercise': { name: 'Daily Exercise (30+ min)', points: 50, category: 'Physical Health', description: 'Any form of physical activity for 30+ minutes' },
  'walk-10k-steps': { name: 'Walk 10,000 Steps', points: 30, category: 'Physical Health', description: 'Reach 10,000 steps daily' },
  'stretch-morning': { name: 'Morning Stretching', points: 15, category: 'Physical Health', description: '10 minutes of stretching' },
  'drink-water': { name: 'Drink 8 Glasses Water', points: 20, category: 'Physical Health', description: 'Stay properly hydrated' },
  
  // Mental Wellness (High Impact)
  'meditation': { name: 'Meditation/Mindfulness', points: 35, category: 'Mental Wellness', description: '10+ minutes of meditation or mindfulness' },
  'journaling': { name: 'Daily Journaling', points: 25, category: 'Mental Wellness', description: 'Write thoughts, gratitude, or reflections' },
  'gratitude-practice': { name: 'Gratitude Practice', points: 20, category: 'Mental Wellness', description: 'List 3 things you\'re grateful for' },
  'limit-social-media': { name: 'Limit Social Media (< 1 hour)', points: 25, category: 'Mental Wellness', description: 'Keep social media under 1 hour' },
  
  // Nutrition (Medium Impact)
  'healthy-breakfast': { name: 'Healthy Breakfast', points: 20, category: 'Nutrition', description: 'Nutritious start to the day' },
  'eat-vegetables': { name: 'Eat 5 Servings Fruits/Vegetables', points: 25, category: 'Nutrition', description: 'Include variety of fruits and vegetables' },
  'avoid-processed-food': { name: 'Avoid Processed Foods', points: 30, category: 'Nutrition', description: 'Choose whole, unprocessed foods' },
  'mindful-eating': { name: 'Mindful Eating', points: 15, category: 'Nutrition', description: 'Eat without distractions, chew slowly' },
  
  // Productivity (Medium Impact)
  'deep-work-session': { name: 'Deep Work Session (2+ hours)', points: 40, category: 'Productivity', description: 'Focused work without distractions' },
  'read-30-min': { name: 'Read for 30+ Minutes', points: 25, category: 'Productivity', description: 'Educational or personal development reading' },
  'plan-tomorrow': { name: 'Plan Tomorrow', points: 15, category: 'Productivity', description: 'Review and plan next day tasks' },
  'inbox-zero': { name: 'Achieve Inbox Zero', points: 20, category: 'Productivity', description: 'Clear and organize email inbox' },
  
  // Social Connection (Medium Impact)
  'call-friend-family': { name: 'Call Friend/Family', points: 25, category: 'Social Connection', description: 'Meaningful conversation with loved ones' },
  'quality-time-family': { name: 'Quality Time with Family', points: 30, category: 'Social Connection', description: 'Undivided attention with family members' },
  'help-someone': { name: 'Help Someone', points: 20, category: 'Social Connection', description: 'Perform an act of kindness' },
  
  // Creative/Learning (Medium Impact)
  'learn-something-new': { name: 'Learn Something New', points: 30, category: 'Creative/Learning', description: 'Skill development or new knowledge' },
  'creative-hobby': { name: 'Creative Hobby', points: 25, category: 'Creative/Learning', description: 'Art, music, writing, or crafts' },
  'practice-instrument': { name: 'Practice Musical Instrument', points: 25, category: 'Creative/Learning', description: 'Musical skill development' },
  
  // Environment (Low Impact)
  'make-bed': { name: 'Make Bed', points: 10, category: 'Environment', description: 'Start day with organized space' },
  'organize-workspace': { name: 'Organize Workspace', points: 15, category: 'Environment', description: 'Clean and organize work area' },
  'time-in-nature': { name: 'Spend Time in Nature', points: 20, category: 'Environment', description: '20+ minutes outdoors in natural setting' },
  'declutter-space': { name: 'Declutter Living Space', points: 15, category: 'Environment', description: 'Remove unnecessary items from living area' }
};

// Calculate habit score based on completion and streaks
export const calculateHabitScore = (habitId, completed, currentStreak = 0) => {
  const habit = PREDEFINED_HABITS[habitId];
  if (!habit || !completed) return 0;
  
  let score = habit.points;
  
  // Streak multipliers
  if (currentStreak >= 30) {
    score *= 2.0; // 30+ day streak
  } else if (currentStreak >= 14) {
    score *= 1.7; // 2+ week streak
  } else if (currentStreak >= 7) {
    score *= 1.5; // 1+ week streak
  } else if (currentStreak >= 3) {
    score *= 1.2; // 3+ day streak
  }
  
  return Math.round(score);
};

// Create a user's habit tracking entry
export const createUserHabit = async (userId, habitId) => {
  try {
    const habitData = PREDEFINED_HABITS[habitId];
    if (!habitData) throw new Error('Invalid habit ID');
    
    const docRef = await addDoc(habitsCollection, {
      userId,
      habitId,
      ...habitData,
      isActive: true,
      createdAt: serverTimestamp(),
      currentStreak: 0,
      longestStreak: 0,
      totalCompletions: 0
    });
    
    return { id: docRef.id, ...habitData, isActive: true, currentStreak: 0, longestStreak: 0, totalCompletions: 0 };
  } catch (error) {
    console.error('Error creating user habit:', error);
    throw error;
  }
};

// Log habit completion for a specific date
export const logHabitCompletion = async (userId, habitId, date = new Date(), notes = '') => {
  try {
    const dateStr = date.toDateString();
    
    // Check if already logged for this date
    const existingQuery = query(
      habitLogsCollection,
      where('userId', '==', userId),
      where('habitId', '==', habitId),
      where('date', '==', dateStr)
    );
    
    const existingLogs = await getDocs(existingQuery);
    
    if (!existingLogs.empty) {
      // Update existing log
      const logDoc = existingLogs.docs[0];
      await updateDoc(doc(habitLogsCollection, logDoc.id), {
        completed: true,
        notes,
        updatedAt: serverTimestamp()
      });
      return { id: logDoc.id, completed: true };
    } else {
      // Create new log
      const docRef = await addDoc(habitLogsCollection, {
        userId,
        habitId,
        date: dateStr,
        completed: true,
        notes,
        createdAt: serverTimestamp()
      });
      
      // Update the habit's streak
      const habitQuery = query(
        habitsCollection,
        where('userId', '==', userId),
        where('habitId', '==', habitId),
        where('isActive', '==', true)
      );
      const habitSnapshot = await getDocs(habitQuery);
      
      if (!habitSnapshot.empty) {
        const habitDoc = habitSnapshot.docs[0];
        const habitData = habitDoc.data();
        
        // Calculate new streak (simplified - just increment for now)
        const newStreak = (habitData.currentStreak || 0) + 1;
        const totalCompletions = (habitData.totalCompletions || 0) + 1;
        const longestStreak = Math.max(habitData.longestStreak || 0, newStreak);
        
        await updateDoc(doc(habitsCollection, habitDoc.id), {
          currentStreak: newStreak,
          totalCompletions: totalCompletions,
          longestStreak: longestStreak,
          lastCompletedAt: serverTimestamp()
        });
      }
      
      return { id: docRef.id, completed: true };
    }
  } catch (error) {
    console.error('Error logging habit completion:', error);
    throw error;
  }
};

// Get user's active habits
export const subscribeUserHabits = (userId, callback, errorCallback) => {
  const q = query(
    habitsCollection,
    where('userId', '==', userId),
    where('isActive', '==', true)
  );
  
  return onSnapshot(q, 
    (snapshot) => {
      const habits = [];
      snapshot.forEach((doc) => {
        habits.push({
          id: doc.id,
          ...doc.data()
        });
      });
      // Sort by createdAt manually after fetching
      habits.sort((a, b) => {
        const timeA = a.createdAt?.seconds || 0;
        const timeB = b.createdAt?.seconds || 0;
        return timeB - timeA;
      });
      callback(habits);
    },
    errorCallback
  );
};

// Get habit completion logs for a date range
export const getHabitLogs = async (userId, startDate, endDate) => {
  try {
    const startStr = startDate.toDateString();
    const endStr = endDate.toDateString();
    
    const q = query(
      habitLogsCollection,
      where('userId', '==', userId),
      where('date', '>=', startStr),
      where('date', '<=', endStr),
      orderBy('date', 'desc')
    );
    
    const snapshot = await getDocs(q);
    const logs = [];
    
    snapshot.forEach((doc) => {
      logs.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    return logs;
  } catch (error) {
    console.error('Error getting habit logs:', error);
    throw error;
  }
};

// Get today's habit completions
export const getTodayHabitLogs = async (userId) => {
  const today = new Date();
  return getHabitLogs(userId, today, today);
};

// Calculate daily score
export const calculateDailyScore = async (userId, date = new Date()) => {
  try {
    const dateStr = date.toDateString();
    
    // Get user's active habits
    const habitsQuery = query(
      habitsCollection,
      where('userId', '==', userId),
      where('isActive', '==', true)
    );
    const habitsSnapshot = await getDocs(habitsQuery);
    
    // Get completion logs for the date
    const logsQuery = query(
      habitLogsCollection,
      where('userId', '==', userId),
      where('date', '==', dateStr),
      where('completed', '==', true)
    );
    const logsSnapshot = await getDocs(logsQuery);
    
    let totalScore = 0;
    let possibleScore = 0;
    const completedHabits = [];
    
    // Calculate scores
    habitsSnapshot.forEach((habitDoc) => {
      const habit = habitDoc.data();
      
      // Check if this habit was completed today
      const completed = logsSnapshot.docs.some(logDoc => 
        logDoc.data().habitId === habit.habitId
      );
      
      if (completed) {
        const score = calculateHabitScore(habit.habitId, true, habit.currentStreak || 0);
        totalScore += score;
        possibleScore += score; // Use actual score for completed habits
        completedHabits.push({
          habitId: habit.habitId,
          name: habit.name,
          score
        });
      } else {
        possibleScore += habit.points || 0; // Use base points for incomplete habits
      }
    });
    
    return {
      totalScore,
      possibleScore,
      percentage: possibleScore > 0 ? Math.round((totalScore / possibleScore) * 100) : 0,
      completedHabits,
      totalHabits: habitsSnapshot.size
    };
  } catch (error) {
    console.error('Error calculating daily score:', error);
    throw error;
  }
};

// Update habit streak
export const updateHabitStreak = async (habitDocId, newStreak) => {
  try {
    const habitRef = doc(habitsCollection, habitDocId);
    await updateDoc(habitRef, {
      currentStreak: newStreak,
      longestStreak: newStreak, // Will be updated properly in a real implementation
      updatedAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error updating habit streak:', error);
    throw error;
  }
};

// Delete/deactivate habit
export const deactivateHabit = async (habitDocId) => {
  try {
    const habitRef = doc(habitsCollection, habitDocId);
    await updateDoc(habitRef, {
      isActive: false,
      updatedAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error deactivating habit:', error);
    throw error;
  }
};

// Get habit categories for organization
export const getHabitCategories = () => {
  const categories = new Set();
  Object.values(PREDEFINED_HABITS).forEach(habit => {
    categories.add(habit.category);
  });
  return Array.from(categories);
};

// Get habits by category
export const getHabitsByCategory = (category) => {
  return Object.entries(PREDEFINED_HABITS)
    .filter(([_, habit]) => habit.category === category)
    .map(([id, habit]) => ({ id, ...habit }));
};