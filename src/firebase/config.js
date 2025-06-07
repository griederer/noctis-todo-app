import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// Tu configuración de Firebase
// Estas variables deben estar en un archivo .env.local
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "AIzaSyB2nRD2qLBXcX77b0a2uDXdKtldKuhIyBI",
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN || "noctis-todo.firebaseapp.com",
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID || "noctis-todo",
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET || "noctis-todo.firebasestorage.app",
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID || "157304233437",
  appId: process.env.REACT_APP_FIREBASE_APP_ID || "1:157304233437:web:3d76b88dc4ba96d53daa34"
};

// Debug: Verificar configuración
console.log('Firebase Config Loaded:', {
  hasApiKey: firebaseConfig.apiKey.length > 10,
  authDomain: firebaseConfig.authDomain,
  projectId: firebaseConfig.projectId
});

// Initialize Firebase
let app;
try {
  app = initializeApp(firebaseConfig);
  // console.log('Firebase initialized successfully'); // Comentado
} catch (error) {
  console.error('Error initializing Firebase:', error);
}

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);
export const googleProvider = new GoogleAuthProvider();

// Initialize Cloud Firestore and get a reference to the service
export const db = getFirestore(app);

export default app; 