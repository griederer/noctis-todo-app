import { 
  collection, 
  doc, 
  setDoc, 
  getDoc
} from 'firebase/firestore';
import { db } from './config';

// Collection reference for simple daily habits
const simpleHabitsCollection = collection(db, 'simpleHabits');

// Save daily habits completion for a user and date
export const saveSimpleDailyHabits = async (userId, dateString, habitsData) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(simpleHabitsCollection, docId);
    
    await setDoc(docRef, {
      userId,
      date: dateString,
      habits: habitsData,
      updatedAt: new Date()
    });
    
    console.log('Simple habits saved for', dateString);
    return true;
  } catch (error) {
    console.error('Error saving simple habits:', error);
    throw error;
  }
};

// Get daily habits completion for a user and date
export const getSimpleDailyHabits = async (userId, dateString) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(simpleHabitsCollection, docId);
    
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      const data = docSnap.data();
      console.log('Simple habits loaded for', dateString, data.habits);
      return data.habits;
    } else {
      console.log('No habits data for', dateString);
      return {};
    }
  } catch (error) {
    console.error('Error getting simple habits:', error);
    throw error;
  }
};

// Get habits data for multiple dates (for future analytics)
export const getSimpleHabitsForRange = async (userId, dateStrings) => {
  try {
    const results = {};
    
    for (const dateString of dateStrings) {
      const habits = await getSimpleDailyHabits(userId, dateString);
      results[dateString] = habits;
    }
    
    return results;
  } catch (error) {
    console.error('Error getting habits range:', error);
    throw error;
  }
};

// Calculate simple stats
export const calculateSimpleStats = (habitsData) => {
  const dates = Object.keys(habitsData);
  if (dates.length === 0) return { totalDays: 0, averageScore: 0, bestDay: 0 };
  
  let totalCompleted = 0;
  let totalPossible = 0;
  let bestDayScore = 0;
  
  dates.forEach(date => {
    const dayHabits = habitsData[date];
    const completed = Object.values(dayHabits).filter(Boolean).length;
    const dayScore = Math.round((completed / 10) * 100);
    
    totalCompleted += completed;
    totalPossible += 10;
    bestDayScore = Math.max(bestDayScore, dayScore);
  });
  
  const averageScore = Math.round((totalCompleted / totalPossible) * 100);
  
  return {
    totalDays: dates.length,
    averageScore,
    bestDay: bestDayScore,
    totalCompleted,
    totalPossible
  };
};