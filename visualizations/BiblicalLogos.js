// BiblicalLogos.js - A React visualization component
// Minimal geometric patterns inspired by sacred geometry and divine order

const BiblicalLogos = () => {
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
    
    // Hexagonal grid system
    const hexRadius = 25;
    const hexagons = [];
    const rows = 11;
    const cols = 11;
    
    // Create hexagonal grid
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const x = col * hexRadius * 1.5;
        const y = row * hexRadius * Math.sqrt(3) + (col % 2) * hexRadius * Math.sqrt(3) / 2;
        
        // Center the grid
        const offsetX = x - (cols - 1) * hexRadius * 1.5 / 2;
        const offsetY = y - (rows - 1) * hexRadius * Math.sqrt(3) / 2;
        
        hexagons.push({
          x: centerX + offsetX,
          y: centerY + offsetY,
          radius: hexRadius,
          phase: Math.random() * Math.PI * 2,
          growthFactor: 0,
          opacity: 0
        });
      }
    }
    
    let time = 0;
    let isRunning = true;
    
    function drawHexagon(x, y, radius, rotation = 0) {
      ctx.beginPath();
      for (let i = 0; i < 6; i++) {
        const angle = (Math.PI / 3) * i + rotation;
        const px = x + radius * Math.cos(angle);
        const py = y + radius * Math.sin(angle);
        if (i === 0) {
          ctx.moveTo(px, py);
        } else {
          ctx.lineTo(px, py);
        }
      }
      ctx.closePath();
    }
    
    function animate() {
      if (!isRunning) return;
      
      time += 0.008;
      
      // Clear with subtle background
      ctx.fillStyle = '#F8F7F4';
      ctx.fillRect(0, 0, width, height);
      
      // Update and draw hexagons
      hexagons.forEach((hex, index) => {
        const distanceFromCenter = Math.sqrt(
          Math.pow(hex.x - centerX, 2) + 
          Math.pow(hex.y - centerY, 2)
        );
        
        // Wave propagation from center
        const wavePosition = (time * 50) % 300;
        const distanceDiff = Math.abs(distanceFromCenter - wavePosition);
        
        if (distanceDiff < 50) {
          hex.opacity = Math.min(0.3, (50 - distanceDiff) / 50 * 0.3);
          hex.growthFactor = (50 - distanceDiff) / 50;
        } else {
          hex.opacity *= 0.95; // Fade out
          hex.growthFactor *= 0.95;
        }
        
        // Sacred geometry: 7 central hexagons
        const isCentral = distanceFromCenter < hexRadius * 2;
        if (isCentral) {
          hex.opacity = Math.max(hex.opacity, 0.15 + Math.sin(time + hex.phase) * 0.05);
        }
        
        // Draw hexagon
        if (hex.opacity > 0.01) {
          const rotation = time * 0.1 + hex.phase;
          const currentRadius = hex.radius * (0.8 + hex.growthFactor * 0.2);
          
          // Outer stroke
          ctx.strokeStyle = `rgba(140, 140, 140, ${hex.opacity})`;
          ctx.lineWidth = 0.5;
          drawHexagon(hex.x, hex.y, currentRadius, rotation);
          ctx.stroke();
          
          // Inner pattern for central hexagons
          if (isCentral && hex.opacity > 0.1) {
            ctx.strokeStyle = `rgba(120, 120, 120, ${hex.opacity * 0.5})`;
            ctx.lineWidth = 0.3;
            
            // Draw inner triangular divisions
            for (let i = 0; i < 6; i++) {
              const angle = (Math.PI / 3) * i + rotation;
              ctx.beginPath();
              ctx.moveTo(hex.x, hex.y);
              const px = hex.x + currentRadius * Math.cos(angle);
              const py = hex.y + currentRadius * Math.sin(angle);
              ctx.lineTo(px, py);
              ctx.stroke();
            }
          }
        }
      });
      
      // Central breathing circle
      const breathe = Math.sin(time * 0.5) * 0.3 + 0.7;
      ctx.beginPath();
      ctx.arc(centerX, centerY, 8 * breathe, 0, Math.PI * 2);
      ctx.strokeStyle = `rgba(100, 100, 100, 0.3)`;
      ctx.lineWidth = 1;
      ctx.stroke();
      
      // Subtle radial guides
      if (Math.sin(time * 0.2) > 0.8) {
        ctx.strokeStyle = 'rgba(150, 150, 150, 0.05)';
        ctx.lineWidth = 0.5;
        for (let i = 0; i < 12; i++) {
          const angle = (i / 12) * Math.PI * 2;
          ctx.beginPath();
          ctx.moveTo(centerX + Math.cos(angle) * 20, centerY + Math.sin(angle) * 20);
          ctx.lineTo(centerX + Math.cos(angle) * 200, centerY + Math.sin(angle) * 200);
          ctx.stroke();
        }
      }
      
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
      position: 'relative'
    }
  }, 
    React.createElement('canvas', {
      key: 'canvas',
      ref: canvasRef,
      style: {
        display: 'block',
        width: '550px',
        height: '550px',
        maxWidth: '90%',
        maxHeight: '90%'
      }
    })
  );
};

// Make the component available globally
window.BiblicalLogos = BiblicalLogos; 