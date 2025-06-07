// InfiniteVisualization.js - Infinite spirals visualization
// Minimal exploration of recursion and boundless expansion

const InfiniteVisualization = () => {
  const canvasRef = React.useRef(null);
  const animationFrameRef = React.useRef(null);
  
  React.useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    const width = canvas.width = 550;
    const height = canvas.height = 550;
    const centerX = width / 2;
    const centerY = height / 2;
    
    let time = 0;
    let isRunning = true;
    
    // Create minimal spiral systems
    const spiralSystems = [];
    const numSystems = 5;
    
    for (let i = 0; i < numSystems; i++) {
      spiralSystems.push({
        scale: 0.5 + (i / numSystems) * 1.2,
        rotation: (i / numSystems) * Math.PI * 2,
        armCount: 3 + Math.floor(i / 2),
        speed: 0.2 + i * 0.05,
        phase: i * Math.PI / 3,
        particleCount: 300 + i * 100,
        maxRadius: 60 + i * 20
      });
    }
    
    function drawMinimalSpirals() {
      // Clear with light background
      ctx.fillStyle = '#F8F7F4';
      ctx.fillRect(0, 0, width, height);
      
      // Draw subtle grid guides
      ctx.strokeStyle = 'rgba(200, 200, 200, 0.05)';
      ctx.lineWidth = 0.5;
      
      // Radial guides
      for (let i = 0; i < 12; i++) {
        const angle = (i / 12) * Math.PI * 2;
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.lineTo(
          centerX + Math.cos(angle) * 250,
          centerY + Math.sin(angle) * 250
        );
        ctx.stroke();
      }
      
      // Concentric circles
      for (let i = 1; i <= 5; i++) {
        ctx.beginPath();
        ctx.arc(centerX, centerY, i * 50, 0, Math.PI * 2);
        ctx.stroke();
      }
      
      // Draw spiral systems
      spiralSystems.forEach((system, systemIndex) => {
        const systemRotation = time * system.speed * 0.005 + system.rotation;
        
        // Draw spiral arms with dots
        for (let arm = 0; arm < system.armCount; arm++) {
          const armAngle = (arm / system.armCount) * Math.PI * 2 + systemRotation;
          
          // Create dots along each spiral arm
          for (let i = 0; i < system.particleCount / system.armCount; i++) {
            const progress = i / (system.particleCount / system.armCount);
            
            // Logarithmic spiral for more natural growth
            const angle = armAngle + progress * Math.PI * 6 * system.scale;
            const radius = progress * system.maxRadius * system.scale * 0.8;
            
            // Skip if too close to center or too far
            if (radius < 10 || radius > 220) continue;
            
            // Calculate position
            const x = centerX + Math.cos(angle) * radius;
            const y = centerY + Math.sin(angle) * radius;
            
            // Skip if outside canvas
            if (x < 0 || x > width || y < 0 || y > height) continue;
            
            // Distance-based properties
            const distanceFromCenter = Math.sqrt((x - centerX) ** 2 + (y - centerY) ** 2);
            const normalizedDistance = distanceFromCenter / 250;
            
            // Fade based on distance
            const fadeOut = Math.max(0, 1 - normalizedDistance);
            
            // Size and opacity
            const baseSize = 1 + (1 - systemIndex / numSystems) * 0.5;
            const size = baseSize * (1 - progress * 0.5) * fadeOut;
            const opacity = fadeOut * 0.3 * (0.5 + progress * 0.5);
            
            if (size > 0.2 && opacity > 0.02) {
              ctx.beginPath();
              ctx.arc(x, y, size, 0, Math.PI * 2);
              ctx.fillStyle = `rgba(140, 140, 140, ${opacity})`;
              ctx.fill();
            }
          }
        }
      });
      
      // Draw central infinity symbol (lemniscate)
      const infinityScale = 25 + Math.sin(time * 0.008) * 3;
      ctx.strokeStyle = 'rgba(100, 100, 100, 0.4)';
      ctx.lineWidth = 1.5;
      
      ctx.beginPath();
      for (let t = 0; t <= Math.PI * 2; t += 0.02) {
        const scale = infinityScale;
        const x = centerX + scale * Math.cos(t) / (1 + Math.sin(t) ** 2);
        const y = centerY + scale * Math.sin(t) * Math.cos(t) / (1 + Math.sin(t) ** 2);
        
        if (t === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.stroke();
      
      // Central point
      const pulseSize = 2 + Math.sin(time * 0.03) * 1;
      ctx.beginPath();
      ctx.arc(centerX, centerY, pulseSize, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(80, 80, 80, 0.5)';
      ctx.fill();
      
      // Subtle expanding rings
      for (let i = 1; i <= 3; i++) {
        const ringRadius = i * 30 + (time * 0.3) % 30;
        const ringOpacity = Math.max(0, 0.15 - (ringRadius / 150));
        
        if (ringOpacity > 0.01) {
          ctx.beginPath();
          ctx.arc(centerX, centerY, ringRadius, 0, Math.PI * 2);
          ctx.strokeStyle = `rgba(120, 120, 120, ${ringOpacity})`;
          ctx.lineWidth = 0.5;
          ctx.stroke();
        }
      }
      
      // Hexagonal frame
      if (Math.sin(time * 0.01) > 0.7) {
        ctx.strokeStyle = 'rgba(150, 150, 150, 0.1)';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        for (let i = 0; i < 6; i++) {
          const angle = (i / 6) * Math.PI * 2;
          const x = centerX + Math.cos(angle) * 240;
          const y = centerY + Math.sin(angle) * 240;
          if (i === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
        }
        ctx.closePath();
        ctx.stroke();
      }
    }
    
    function animate() {
      if (!isRunning) return;
      
      time += 1;
      drawMinimalSpirals();
      
      animationFrameRef.current = requestAnimationFrame(animate);
    }
    
    animate();
    
    return () => {
      isRunning = false;
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
      
      if (canvas && ctx) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      }
    };
  }, []);
  
  return React.createElement('div', {
    style: {
      width: '100%',
      height: '100%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#F8F7F4',
      margin: 0,
      overflow: 'hidden'
    }
  }, 
    React.createElement('canvas', {
      ref: canvasRef,
      style: {
        display: 'block',
        width: '550px',
        height: '550px',
        maxWidth: '90%',
        maxHeight: '90%',
        border: 'none'
      }
    })
  );
};

// Make the component available globally
window.InfiniteVisualization = InfiniteVisualization; 