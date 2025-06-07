import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import ReactMarkdown from 'react-markdown';
import { 
  createJournalEntry, 
  updateJournalEntry, 
  deleteJournalEntry, 
  subscribeJournalEntries 
} from '../firebase/journal';
import '../styles/JournalSection.css';

function JournalSection() {
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
      const newEntry = await createJournalEntry(user.uid, {
        title: 'New Entry',
        content: '',
        date: new Date().toISOString()
      });
      setSelectedEntry(newEntry);
      setTitle('New Entry');
      setContent('');
      setIsEditing(true);
    } catch (error) {
      console.error('Error creating journal entry:', error);
    }
  };

  const handleSaveEntry = async () => {
    if (!selectedEntry) return;

    try {
      await updateJournalEntry(selectedEntry.id, {
        title: title || 'Untitled',
        content: content
      });
      setIsEditing(false);
    } catch (error) {
      console.error('Error saving journal entry:', error);
    }
  };

  const handleDeleteEntry = async (entryId) => {
    if (!window.confirm('Are you sure you want to delete this entry?')) return;

    try {
      await deleteJournalEntry(entryId);
      if (selectedEntry?.id === entryId) {
        setSelectedEntry(null);
        setContent('');
        setTitle('');
        setIsEditing(false);
      }
    } catch (error) {
      console.error('Error deleting journal entry:', error);
    }
  };

  const handleSelectEntry = (entry) => {
    setSelectedEntry(entry);
    setTitle(entry.title);
    setContent(entry.content || '');
    // Start in edit mode if the entry is empty or has minimal content
    const isEmpty = !entry.content || entry.content.trim() === '' || entry.content.length < 10;
    setIsEditing(isEmpty);
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="journal-section-loading">
        <div className="loading-spinner"></div>
      </div>
    );
  }

  return (
    <div className="journal-section">
      {/* Scientific decorative elements */}
      <div className="anatomical-eye"></div>
      <div className="math-annotation">∂f/∂x = lim h→0</div>
      <div className="math-annotation">∇²φ = 0</div>
      <div className="paper-texture"></div>
      <div className="technical-diagram compass"></div>
      
      <div className="journal-sidebar">
        <div className="journal-header">
          <h2>Journal Entries</h2>
          <button className="new-entry-btn" onClick={handleCreateEntry}>
            + New Entry
          </button>
        </div>
        <div className="entries-list">
          {entries.length > 0 ? (
            entries.map(entry => (
              <div 
                key={entry.id} 
                className={`entry-item ${selectedEntry?.id === entry.id ? 'selected' : ''}`}
                onClick={() => handleSelectEntry(entry)}
              >
                <h3>{entry.title}</h3>
                <p className="entry-date">{formatDate(entry.date)}</p>
              </div>
            ))
          ) : (
            <div className="empty-entries">
              <p>No entries yet</p>
              <p className="hint">Click "New Entry" to start writing</p>
            </div>
          )}
        </div>
      </div>
      
      <div className="journal-content">
        {selectedEntry ? (
          <>
            <div className="content-header">
              {isEditing ? (
                <input
                  type="text"
                  className="title-input"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Entry Title"
                />
              ) : (
                <h1 className="entry-title">{selectedEntry.title}</h1>
              )}
              <div className="content-actions">
                {isEditing ? (
                  <button className="save-btn" onClick={handleSaveEntry}>
                    Save
                  </button>
                ) : (
                  <button className="edit-btn" onClick={() => setIsEditing(true)}>
                    Edit
                  </button>
                )}
                <button 
                  className="delete-btn" 
                  onClick={() => handleDeleteEntry(selectedEntry.id)}
                >
                  Delete
                </button>
              </div>
            </div>
            
            <div className="content-body">
              {isEditing ? (
                <textarea
                  className="markdown-editor"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="Write in Markdown..."
                />
              ) : (
                <div className="markdown-preview">
                  {content && content.trim() && content.length > 5 ? (
                    <ReactMarkdown>{content}</ReactMarkdown>
                  ) : (
                    <div className="empty-preview">
                      <p>This entry is empty.</p>
                      <p>Click <strong>"Edit"</strong> to start writing.</p>
                    </div>
                  )}
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="no-entry-selected">
            <h2>No entry selected</h2>
            <p>Select an entry from the sidebar or create a new one</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default JournalSection;