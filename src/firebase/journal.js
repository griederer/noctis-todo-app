import { 
  collection, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  where, 
  onSnapshot,
  serverTimestamp 
} from 'firebase/firestore';
import { db } from './config';

const JOURNAL_COLLECTION = 'journal';

export const createJournalEntry = async (userId, entryData) => {
  try {
    const docRef = await addDoc(collection(db, JOURNAL_COLLECTION), {
      ...entryData,
      userId,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    });
    return { id: docRef.id, ...entryData, createdAt: serverTimestamp(), updatedAt: serverTimestamp() };
  } catch (error) {
    console.error('Error creating journal entry:', error);
    throw error;
  }
};

export const updateJournalEntry = async (entryId, updates) => {
  try {
    const entryRef = doc(db, JOURNAL_COLLECTION, entryId);
    await updateDoc(entryRef, {
      ...updates,
      updatedAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error updating journal entry:', error);
    throw error;
  }
};

export const deleteJournalEntry = async (entryId) => {
  try {
    await deleteDoc(doc(db, JOURNAL_COLLECTION, entryId));
  } catch (error) {
    console.error('Error deleting journal entry:', error);
    throw error;
  }
};

export const subscribeJournalEntries = (userId, callback, errorCallback) => {
  const q = query(
    collection(db, JOURNAL_COLLECTION),
    where('userId', '==', userId)
  );

  return onSnapshot(q, (snapshot) => {
    const entries = [];
    snapshot.forEach((doc) => {
      entries.push({ id: doc.id, ...doc.data() });
    });
    // Sort in memory if createdAt exists
    entries.sort((a, b) => {
      const aTime = a.createdAt?.seconds || a.createdAt?.getTime?.() || 0;
      const bTime = b.createdAt?.seconds || b.createdAt?.getTime?.() || 0;
      return bTime - aTime;
    });
    callback(entries);
  }, (error) => {
    console.error('Error in journal subscription:', error);
    if (errorCallback) errorCallback(error);
    // Fallback: call with empty array to stop loading
    callback([]);
  });
};