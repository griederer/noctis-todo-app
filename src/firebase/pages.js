import { 
  collection, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  doc, 
  query, 
  where, 
  orderBy, 
  onSnapshot,
  serverTimestamp,
  getDoc 
} from 'firebase/firestore';
import { db } from './config';

const PAGES_COLLECTION = 'pages';

// Create a new page
export const createPage = async (userId, pageData) => {
  try {
    const docRef = await addDoc(collection(db, PAGES_COLLECTION), {
      title: pageData.title || 'Untitled',
      content: pageData.content || { blocks: [] },
      parentId: pageData.parentId || null,
      userId,
      icon: pageData.icon || '📄',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    });
    return docRef.id;
  } catch (error) {
    console.error('Error creating page:', error);
    throw error;
  }
};

// Update a page
export const updatePage = async (pageId, updates) => {
  try {
    const pageRef = doc(db, PAGES_COLLECTION, pageId);
    await updateDoc(pageRef, {
      ...updates,
      updatedAt: serverTimestamp()
    });
  } catch (error) {
    console.error('Error updating page:', error);
    throw error;
  }
};

// Delete a page
export const deletePage = async (pageId) => {
  try {
    await deleteDoc(doc(db, PAGES_COLLECTION, pageId));
  } catch (error) {
    console.error('Error deleting page:', error);
    throw error;
  }
};

// Get a single page
export const getPage = async (pageId) => {
  try {
    const docRef = doc(db, PAGES_COLLECTION, pageId);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    } else {
      return null;
    }
  } catch (error) {
    console.error('Error getting page:', error);
    throw error;
  }
};

// Subscribe to user's pages
export const subscribePages = (userId, callback) => {
  const q = query(
    collection(db, PAGES_COLLECTION),
    where('userId', '==', userId),
    orderBy('createdAt', 'desc')
  );
  
  return onSnapshot(q, (snapshot) => {
    const pages = [];
    snapshot.forEach((doc) => {
      pages.push({ id: doc.id, ...doc.data() });
    });
    callback(pages);
  });
};

// Subscribe to a single page
export const subscribePage = (pageId, callback) => {
  const docRef = doc(db, PAGES_COLLECTION, pageId);
  
  return onSnapshot(docRef, (doc) => {
    if (doc.exists()) {
      callback({ id: doc.id, ...doc.data() });
    } else {
      callback(null);
    }
  });
}; 