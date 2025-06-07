// ParticleSystem.js - A minimal particle system visualization
// Exploring emergent behavior through subtle interactions

const ParticleSystem = () => {
  const canvasRef = React.useRef(null);
  const animationFrameRef = React.useRef(null);
  const particlesRef = React.useRef([]);
  const mouseRef = React.useRef({ x: 0, y: 0 });
  
  React.useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    const width = canvas.width = 550;
    const height = canvas.height = 550;
    
    // Particle class
    class Particle {
      constructor(x, y) {
        this.x = x;
        this.y = y;
        this.vx = (Math.random() - 0.5) * 0.5;
        this.vy = (Math.random() - 0.5) * 0.5;
        this.radius = 1.5;
        this.connections = 0;
      }
      
      update() {
        // Very subtle movement
        this.x += this.vx;
        this.y += this.vy;
        
        // Soft boundaries
        if (this.x < 50 || this.x > width - 50) {
          this.vx *= -0.9;
        }
        if (this.y < 50 || this.y > height - 50) {
          this.vy *= -0.9;
        }
        
        // Keep particles in bounds
        this.x = Math.max(50, Math.min(width - 50, this.x));
        this.y = Math.max(50, Math.min(height - 50, this.y));
        
        // Very subtle gravity toward center
        const centerX = width / 2;
        const centerY = height / 2;
        const dx = centerX - this.x;
        const dy = centerY - this.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        if (distance > 100) {
          this.vx += (dx / distance) * 0.01;
          this.vy += (dy / distance) * 0.01;
        }
        
        // Friction
        this.vx *= 0.98;
        this.vy *= 0.98;
        
        // Mouse interaction - very subtle
        const mouseDx = mouseRef.current.x - this.x;
        const mouseDy = mouseRef.current.y - this.y;
        const mouseDistance = Math.sqrt(mouseDx * mouseDx + mouseDy * mouseDy);
        
        if (mouseDistance < 80 && mouseDistance > 0) {
          const force = (80 - mouseDistance) / 80;
          this.vx -= (mouseDx / mouseDistance) * force * 0.2;
          this.vy -= (mouseDy / mouseDistance) * force * 0.2;
        }
      }
      
      draw(ctx) {
        // Draw particle with varying opacity based on connections
        const opacity = 0.2 + Math.min(0.4, this.connections * 0.1);
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(120, 120, 120, ${opacity})`;
        ctx.fill();
      }
    }
    
    // Initialize particles in a structured pattern
    const particleCount = 100;
    const gridSize = 10;
    const spacing = 300 / gridSize;
    const offsetX = (width - 300) / 2;
    const offsetY = (height - 300) / 2;
    
    for (let i = 0; i < particleCount; i++) {
      const row = Math.floor(i / gridSize);
      const col = i % gridSize;
      const x = offsetX + col * spacing + (Math.random() - 0.5) * 20;
      const y = offsetY + row * spacing + (Math.random() - 0.5) * 20;
      particlesRef.current.push(new Particle(x, y));
    }
    
    // Mouse move handler
    const handleMouseMove = (event) => {
      const rect = canvas.getBoundingClientRect();
      mouseRef.current.x = (event.clientX - rect.left) * (width / rect.width);
      mouseRef.current.y = (event.clientY - rect.top) * (height / rect.height);
    };
    
    canvas.addEventListener('mousemove', handleMouseMove);
    
    let isRunning = true;
    let time = 0;
    
    // Animation loop
    function animate() {
      if (!isRunning) return;
      
      time += 0.01;
      
      // Clear canvas with light background
      ctx.fillStyle = '#F8F7F4';
      ctx.fillRect(0, 0, width, height);
      
      // Reset connection counts
      particlesRef.current.forEach(particle => {
        particle.connections = 0;
      });
      
      // Update and draw particles
      particlesRef.current.forEach(particle => {
        particle.update();
      });
      
      // Draw connections between nearby particles
      ctx.strokeStyle = 'rgba(140, 140, 140, 0.15)';
      ctx.lineWidth = 0.5;
      
      for (let i = 0; i < particlesRef.current.length; i++) {
        for (let j = i + 1; j < particlesRef.current.length; j++) {
          const p1 = particlesRef.current[i];
          const p2 = particlesRef.current[j];
          const dx = p1.x - p2.x;
          const dy = p1.y - p2.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          
          if (distance < 60) {
            const opacity = (1 - distance / 60) * 0.2;
            ctx.strokeStyle = `rgba(140, 140, 140, ${opacity})`;
            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.stroke();
            
            p1.connections++;
            p2.connections++;
          }
        }
      }
      
      // Draw particles after connections
      particlesRef.current.forEach(particle => {
        particle.draw(ctx);
      });
      
      // Draw subtle geometric guide
      const breathe = Math.sin(time * 0.5) * 0.1 + 0.9;
      ctx.strokeStyle = 'rgba(150, 150, 150, 0.05)';
      ctx.lineWidth = 0.5;
      
      // Central circle
      ctx.beginPath();
      ctx.arc(width / 2, height / 2, 150 * breathe, 0, Math.PI * 2);
      ctx.stroke();
      
      // Hexagonal boundary
      if (Math.sin(time * 0.3) > 0.5) {
        ctx.beginPath();
        for (let i = 0; i < 6; i++) {
          const angle = (i / 6) * Math.PI * 2;
          const x = width / 2 + Math.cos(angle) * 200 * breathe;
          const y = height / 2 + Math.sin(angle) * 200 * breathe;
          if (i === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
        }
        ctx.closePath();
        ctx.stroke();
      }
      
      animationFrameRef.current = requestAnimationFrame(animate);
    }
    
    animate();
    
    // Cleanup
    return () => {
      isRunning = false;
      canvas.removeEventListener('mousemove', handleMouseMove);
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
      particlesRef.current = [];
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
window.ParticleSystem = ParticleSystem; 