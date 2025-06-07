import { useState, useCallback } from 'react';

export const useErrorHandler = () => {
  const [error, setError] = useState(null);

  const handleError = useCallback((error, userMessage = null) => {
    console.error('Error caught:', error);
    
    const message = userMessage || 
      (error.message || 'An unexpected error occurred');
    
    setError(message);
    
    // Auto-clear error after 5 seconds
    setTimeout(() => setError(null), 5000);
    
    return message;
  }, []);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const withErrorHandling = useCallback((asyncFn, userMessage = null) => {
    return async (...args) => {
      try {
        return await asyncFn(...args);
      } catch (error) {
        handleError(error, userMessage);
        throw error;
      }
    };
  }, [handleError]);

  return {
    error,
    handleError,
    clearError,
    withErrorHandling
  };
};