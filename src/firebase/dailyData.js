import { 
  collection, 
  doc, 
  setDoc, 
  getDoc
} from 'firebase/firestore';
import { db } from './config';

// Collection references
const dailyTodosCollection = collection(db, 'dailyTodos');
const dailyJournalCollection = collection(db, 'dailyJournal');

// Save daily todos for a specific date
export const saveDailyTodos = async (userId, dateString, todos) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(dailyTodosCollection, docId);
    
    await setDoc(docRef, {
      userId,
      date: dateString,
      todos,
      updatedAt: new Date()
    });
    
    console.log('Daily todos saved for', dateString);
    return true;
  } catch (error) {
    console.error('Error saving daily todos:', error);
    throw error;
  }
};

// Get daily todos for a specific date
export const getDailyTodos = async (userId, dateString) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(dailyTodosCollection, docId);
    
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      const data = docSnap.data();
      return data.todos;
    } else {
      return [];
    }
  } catch (error) {
    console.error('Error getting daily todos:', error);
    throw error;
  }
};

// Save today's journal entry
export const saveTodayJournalEntry = async (userId, dateString, content) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(dailyJournalCollection, docId);
    
    await setDoc(docRef, {
      userId,
      date: dateString,
      content,
      updatedAt: new Date(),
      wordCount: content.trim().split(/\s+/).length
    });
    
    console.log('Journal entry saved for', dateString);
    return true;
  } catch (error) {
    console.error('Error saving journal entry:', error);
    throw error;
  }
};

// Get today's journal entry
export const getTodayJournalEntry = async (userId, dateString) => {
  try {
    const docId = `${userId}_${dateString}`;
    const docRef = doc(dailyJournalCollection, docId);
    
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      const data = docSnap.data();
      return data.content;
    } else {
      return '';
    }
  } catch (error) {
    console.error('Error getting journal entry:', error);
    throw error;
  }
};

// Get daily summary data for analytics
export const getDailySummary = async (userId, dateString) => {
  try {
    const [todos, journal] = await Promise.all([
      getDailyTodos(userId, dateString),
      getTodayJournalEntry(userId, dateString)
    ]);
    
    const completedTodos = todos.filter(todo => todo.completed).length;
    const todoScore = todos.length > 0 ? Math.round((completedTodos / todos.length) * 100) : 0;
    const journalScore = journal.trim() ? 100 : 0;
    
    return {
      date: dateString,
      todos: {
        total: todos.length,
        completed: completedTodos,
        score: todoScore
      },
      journal: {
        hasEntry: !!journal.trim(),
        wordCount: journal.trim().split(/\s+/).length,
        score: journalScore
      }
    };
  } catch (error) {
    console.error('Error getting daily summary:', error);
    throw error;
  }
};

// Get data for a range of dates (for calendar view)
export const getDailyDataRange = async (userId, startDate, endDate) => {
  try {
    const results = {};
    const current = new Date(startDate);
    
    while (current <= endDate) {
      const dateString = current.toDateString();
      const summary = await getDailySummary(userId, dateString);
      results[dateString] = summary;
      current.setDate(current.getDate() + 1);
    }
    
    return results;
  } catch (error) {
    console.error('Error getting daily data range:', error);
    throw error;
  }
};