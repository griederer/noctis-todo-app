import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import ReactMarkdown from 'react-markdown';
import { 
  createJournalEntry, 
  updateJournalEntry, 
  deleteJournalEntry, 
  subscribeJournalEntries 
} from '../firebase/journal';

function ModernJournalSection() {
  const { user } = useAuth();
  const [entries, setEntries] = useState([]);
  const [selectedEntry, setSelectedEntry] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [content, setContent] = useState('');
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }

    const unsubscribe = subscribeJournalEntries(user.uid, (fetchedEntries) => {
      setEntries(fetchedEntries);
      setLoading(false);
    }, (error) => {
      console.error('Error loading journal entries:', error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [user]);

  const handleCreateEntry = async () => {
    try {
      const entryData = {
        title: 'New Journal Entry',
        content: '',
        date: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      const entryId = await createJournalEntry(user.uid, entryData);
      const newEntry = { id: entryId, ...entryData };
      
      setSelectedEntry(newEntry);
      setTitle('New Journal Entry');
      setContent('');
      setIsEditing(true);
    } catch (error) {
      console.error('Error creating journal entry:', error);
    }
  };

  const handleSave = async () => {
    if (!selectedEntry) return;
    
    try {
      await updateJournalEntry(selectedEntry.id, {
        title: title.trim() || 'Untitled',
        content: content.trim(),
        updatedAt: new Date().toISOString()
      });
      setIsEditing(false);
    } catch (error) {
      console.error('Error saving journal entry:', error);
    }
  };

  const handleDelete = async (entryId) => {
    if (!window.confirm('Are you sure you want to delete this journal entry?')) {
      return;
    }
    
    try {
      await deleteJournalEntry(entryId);
      if (selectedEntry?.id === entryId) {
        setSelectedEntry(null);
        setIsEditing(false);
      }
    } catch (error) {
      console.error('Error deleting journal entry:', error);
    }
  };

  const selectEntry = (entry) => {
    setSelectedEntry(entry);
    setTitle(entry.title || '');
    setContent(entry.content || '');
    setIsEditing(false);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString([], { 
      weekday: 'long',
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="text-text-secondary">Loading journal entries...</div>
      </div>
    );
  }

  return (
    <div className="flex h-full">
      {/* Left Sidebar - Entries List */}
      <div className="w-80 border-r border-border-light bg-bg-secondary flex flex-col">
        <div className="p-6 border-b border-border-light">
          <button
            onClick={handleCreateEntry}
            className="w-full btn btn-primary flex items-center justify-center gap-2"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            New Entry
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto">
          {entries.length === 0 ? (
            <div className="p-6 text-center">
              <div className="text-6xl mb-4">📔</div>
              <h3 className="text-lg font-semibold text-text-primary mb-2">No journal entries yet</h3>
              <p className="text-text-secondary text-sm">Click "New Entry" to start writing</p>
            </div>
          ) : (
            <div className="p-4 space-y-2">
              {entries.map((entry) => (
                <div
                  key={entry.id}
                  onClick={() => selectEntry(entry)}
                  className={`p-4 rounded-md cursor-pointer transition-colors border ${
                    selectedEntry?.id === entry.id
                      ? 'bg-accent-blue-light border-accent-blue'
                      : 'bg-bg-primary border-transparent hover:bg-bg-secondary'
                  }`}
                >
                  <h4 className="font-medium text-text-primary mb-1 text-truncate">
                    {entry.title || 'Untitled'}
                  </h4>
                  <p className="text-xs text-text-secondary mb-2">
                    {formatDate(entry.date || entry.createdAt)}
                  </p>
                  <p className="text-sm text-text-secondary line-clamp-2">
                    {entry.content?.substring(0, 100) || 'No content...'}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Right Content Area */}
      <div className="flex-1 flex flex-col">
        {selectedEntry ? (
          <>
            {/* Header */}
            <div className="p-6 border-b border-border-light bg-bg-primary">
              <div className="flex items-center justify-between">
                <div className="flex-1">
                  {isEditing ? (
                    <input
                      type="text"
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                      className="text-xl font-semibold text-text-primary bg-transparent border-none outline-none w-full"
                      placeholder="Entry title..."
                    />
                  ) : (
                    <h1 className="text-xl font-semibold text-text-primary">
                      {selectedEntry.title || 'Untitled'}
                    </h1>
                  )}
                  <p className="text-sm text-text-secondary mt-1">
                    {formatDate(selectedEntry.date || selectedEntry.createdAt)}
                  </p>
                </div>
                
                <div className="flex items-center gap-2">
                  {isEditing ? (
                    <>
                      <button
                        onClick={() => setIsEditing(false)}
                        className="btn btn-secondary text-sm"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleSave}
                        className="btn btn-primary text-sm"
                      >
                        Save
                      </button>
                    </>
                  ) : (
                    <>
                      <button
                        onClick={() => setIsEditing(true)}
                        className="btn btn-secondary text-sm"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(selectedEntry.id)}
                        className="btn bg-red-50 text-red-700 hover:bg-red-100 text-sm"
                      >
                        Delete
                      </button>
                    </>
                  )}
                </div>
              </div>
            </div>

            {/* Content */}
            <div className="flex-1 p-6">
              {isEditing ? (
                <textarea
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  className="w-full h-full p-4 text-text-primary bg-bg-secondary border border-border-light rounded-md resize-none outline-none focus:ring-2 focus:ring-accent-blue focus:border-transparent"
                  placeholder="Write your thoughts here... (Markdown supported)"
                />
              ) : (
                <div className="prose prose-gray max-w-none">
                  {selectedEntry.content ? (
                    <ReactMarkdown className="text-text-primary">
                      {selectedEntry.content}
                    </ReactMarkdown>
                  ) : (
                    <p className="text-text-secondary italic">No content yet. Click "Edit" to start writing.</p>
                  )}
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center">
              <div className="text-6xl mb-4">✍️</div>
              <h3 className="text-lg font-semibold text-text-primary mb-2">Select an entry to view</h3>
              <p className="text-text-secondary">Choose a journal entry from the left sidebar or create a new one</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default ModernJournalSection;