import React, { useState, useEffect, Suspense } from 'react';
import { useAuth } from '../contexts/AuthContext';
import LoadingSpinner from './LoadingSpinner';

const NoctisEditor = React.lazy(() => import('./NoctisEditor'));
import { logout } from '../firebase/auth';
import { 
  createPage, 
  updatePage, 
  deletePage, 
  subscribePages, 
  subscribePage 
} from '../firebase/pages';
import '../styles/PageView.css';

const PageView = () => {
  const { user } = useAuth();
  const [pages, setPages] = useState([]);
  const [selectedPageId, setSelectedPageId] = useState(null);
  const [selectedPage, setSelectedPage] = useState(null);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [loading, setLoading] = useState(true);

  // Subscribe to all pages
  useEffect(() => {
    if (!user) return;

    const unsubscribe = subscribePages(user.uid, (fetchedPages) => {
      setPages(fetchedPages);
      setLoading(false);
      
      // If no page is selected and there are pages, select the first one
      if (!selectedPageId && fetchedPages.length > 0) {
        setSelectedPageId(fetchedPages[0].id);
      }
    });

    return () => unsubscribe();
  }, [user, selectedPageId]);

  // Subscribe to selected page
  useEffect(() => {
    if (!selectedPageId) {
      setSelectedPage(null);
      return;
    }

    const unsubscribe = subscribePage(selectedPageId, (page) => {
      setSelectedPage(page);
    });

    return () => unsubscribe();
  }, [selectedPageId]);

  const handleCreatePage = async () => {
    try {
      const newPageId = await createPage(user.uid, {
        title: 'New Page',
        content: { 
          blocks: [{
            type: 'paragraph',
            data: { text: '' }
          }]
        }
      });
      setSelectedPageId(newPageId);
    } catch (error) {
      console.error('Error creating page:', error);
    }
  };

  const handlePageSave = async (content) => {
    if (!selectedPageId) return;

    try {
      await updatePage(selectedPageId, { content });
    } catch (error) {
      console.error('Error saving page:', error);
    }
  };

  const handlePageTitleChange = async (pageId, newTitle) => {
    try {
      await updatePage(pageId, { title: newTitle });
    } catch (error) {
      console.error('Error updating page title:', error);
    }
  };

  const handleDeletePage = async (pageId) => {
    if (!window.confirm('Are you sure you want to delete this page?')) return;

    try {
      await deletePage(pageId);
      if (selectedPageId === pageId) {
        setSelectedPageId(pages.find(p => p.id !== pageId)?.id || null);
      }
    } catch (error) {
      console.error('Error deleting page:', error);
    }
  };

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  const buildPageTree = (pages, parentId = null) => {
    return pages
      .filter(page => page.parentId === parentId)
      .map(page => ({
        ...page,
        children: buildPageTree(pages, page.id)
      }));
  };

  const renderPageTree = (pageTree, level = 0) => {
    return pageTree.map(page => (
      <div key={page.id} className="page-tree-item" style={{ paddingLeft: `${level * 20}px` }}>
        <button
          className={`page-item ${selectedPageId === page.id ? 'selected' : ''}`}
          onClick={() => setSelectedPageId(page.id)}
        >
          <span className="page-icon">{page.icon}</span>
          <span className="page-title">{page.title}</span>
          <button
            className="page-delete"
            onClick={(e) => {
              e.stopPropagation();
              handleDeletePage(page.id);
            }}
          >
            ×
          </button>
        </button>
        {page.children.length > 0 && (
          <div className="page-children">
            {renderPageTree(page.children, level + 1)}
          </div>
        )}
      </div>
    ));
  };

  if (loading) {
    return (
      <div className="page-view">
        <LoadingSpinner size="large" message="Loading your pages..." />
      </div>
    );
  }

  const pageTree = buildPageTree(pages);

  return (
    <div className="page-view">
      {/* App Header */}
      <div className="app-header">
        <div className="app-title">
          <h1>Noctis</h1>
        </div>
        <div className="app-user">
          {user?.photoURL && (
            <img 
              src={user.photoURL} 
              alt={user.displayName || 'User'} 
              className="user-avatar"
            />
          )}
          <span className="user-name">{user?.displayName || user?.email}</span>
          <button className="logout-btn" onClick={handleLogout}>
            Sign out
          </button>
        </div>
      </div>

      <div className="page-content">
        {/* Sidebar */}
        <div className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
          <div className="sidebar-header">
            <h2>Pages</h2>
            <button 
              className="sidebar-toggle"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              {sidebarOpen ? '←' : '→'}
            </button>
          </div>
          
          <button className="new-page-button" onClick={handleCreatePage}>
            + New Page
          </button>

          <div className="pages-list">
            {pageTree.length > 0 ? (
              renderPageTree(pageTree)
            ) : (
              <div className="empty-pages">
                <p>No pages yet</p>
                <p className="hint">Click "New Page" to get started</p>
              </div>
            )}
          </div>
        </div>

        {/* Main Content */}
        <div className="main-content">
          {selectedPage ? (
            <>
              <div className="page-header">
                <input
                  type="text"
                  className="page-title-input"
                  value={selectedPage.title}
                  onChange={(e) => handlePageTitleChange(selectedPageId, e.target.value)}
                  placeholder="Untitled"
                />
              </div>
              <Suspense fallback={<LoadingSpinner size="medium" message="Loading editor..." />}>
                <NoctisEditor
                  pageId={selectedPageId}
                  initialData={selectedPage.content}
                  onSave={handlePageSave}
                />
              </Suspense>
            </>
          ) : (
            <div className="no-page-selected">
              <h2>No page selected</h2>
              <p>Select a page from the sidebar or create a new one</p>
              <button className="create-first-page" onClick={handleCreatePage}>
                Create your first page
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default PageView; 