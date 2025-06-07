import React from 'react';
import '../styles/GeometricPattern.css';

function GeometricPattern() {
  return (
    <div className="geometric-pattern">
      {/* Animated geometric lines */}
      <div className="geometric-line" style={{ top: '10%', animationDelay: '0s' }}></div>
      <div className="geometric-line" style={{ top: '30%', animationDelay: '2s' }}></div>
      <div className="geometric-line" style={{ top: '50%', animationDelay: '4s' }}></div>
      <div className="geometric-line" style={{ top: '70%', animationDelay: '6s' }}></div>
      <div className="geometric-line" style={{ top: '90%', animationDelay: '8s' }}></div>
      
      {/* Interference pattern circles */}
      <div className="interference-pattern">
        <div className="interference-circle"></div>
        <div className="interference-circle"></div>
        <div className="interference-circle"></div>
      </div>
    </div>
  );
}

export default GeometricPattern; 