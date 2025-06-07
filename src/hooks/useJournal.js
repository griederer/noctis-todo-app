import { useState, useEffect, useCallback } from 'react';
import { 
  createJournalEntry, 
  updateJournalEntry, 
  deleteJournalEntry, 
  subscribeJournalEntries 
} from '../firebase/journal';

export const useJournal = (userId) => {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }

    const unsubscribe = subscribeJournalEntries(userId, (fetchedEntries) => {
      setEntries(fetchedEntries);
      setLoading(false);
    }, (error) => {
      console.error('Error loading journal entries:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [userId]);

  const createEntry = useCallback(async (entryData) => {
    try {
      const newEntry = await createJournalEntry(userId, {
        title: entryData.title || 'New Entry',
        content: entryData.content || '# New Entry\n\nStart writing...',
        date: new Date().toISOString(),
        ...entryData
      });
      return newEntry;
    } catch (error) {
      console.error('Error creating journal entry:', error);
      throw error;
    }
  }, [userId]);

  const updateEntry = useCallback(async (entryId, updates) => {
    try {
      await updateJournalEntry(entryId, updates);
    } catch (error) {
      console.error('Error updating journal entry:', error);
      throw error;
    }
  }, []);

  const deleteEntry = useCallback(async (entryId) => {
    try {
      await deleteJournalEntry(entryId);
    } catch (error) {
      console.error('Error deleting journal entry:', error);
      throw error;
    }
  }, []);

  const formatDate = useCallback((dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }, []);

  return {
    entries,
    loading,
    createEntry,
    updateEntry,
    deleteEntry,
    formatDate
  };
};