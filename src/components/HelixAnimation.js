import React, { useEffect, useRef } from 'react';

const HelixAnimation = () => {
  const canvasRef = useRef(null);
  const animationFrameRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.width = window.innerWidth;
    const height = canvas.height = window.innerHeight;

    // Core variables
    const particles = [];
    let helixPoints = [];
    const numParticles = 60;
    const TWO_PI = Math.PI * 2;

    // Helper functions
    const random = (min, max) => {
      if (max === undefined) {
        max = min;
        min = 0;
      }
      return Math.random() * (max - min) + min;
    };

    const map = (value, start1, stop1, start2, stop2) => {
      return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
    };

    const dist = (x1, y1, z1, x2, y2, z2) => {
      const dx = x2 - x1;
      const dy = y2 - y1;
      const dz = z2 - z1;
      return Math.sqrt(dx * dx + dy * dy + dz * dz);
    };

    // HelixParticle class
    class HelixParticle {
      constructor(initialPhase) {
        this.phase = initialPhase || random(TWO_PI);
        this.radius = random(90, 110);
        this.yOffset = random(-300, 300);
        this.ySpeed = random(0.3, 0.6) * (random() > 0.5 ? 1 : -1);
        this.rotationSpeed = random(0.005, 0.0075);
        this.size = random(3, 6);
        this.opacity = random(120, 180);
        this.strength = random(0.8, 1);
      }

      update() {
        this.phase += this.rotationSpeed * this.strength;
        this.yOffset += this.ySpeed;

        if (this.yOffset > 350) this.yOffset = -350;
        if (this.yOffset < -350) this.yOffset = 350;

        const x = width / 2 + Math.cos(this.phase) * this.radius;
        const y = height / 2 + this.yOffset;
        const z = Math.sin(this.phase) * this.radius;

        return { x, y, z, strength: this.strength, size: this.size, opacity: this.opacity };
      }
    }

    // Create helix particles
    for (let i = 0; i < numParticles; i++) {
      const initialPhase = (i / numParticles) * TWO_PI * 3;
      particles.push(new HelixParticle(initialPhase));
    }

    // Frame rate control
    const targetFPS = 30;
    const frameInterval = 1000 / targetFPS;
    let lastFrameTime = 0;

    const animate = (currentTime) => {
      if (!lastFrameTime) {
        lastFrameTime = currentTime;
        animationFrameRef.current = requestAnimationFrame(animate);
        return;
      }

      const deltaTime = currentTime - lastFrameTime;
      
      if (deltaTime >= frameInterval) {
        const remainder = deltaTime % frameInterval;
        lastFrameTime = currentTime - remainder;
        
        // Clear with slight transparency for trails effect
        ctx.fillStyle = 'rgba(240, 238, 230, 0.8)';
        ctx.fillRect(0, 0, width, height);

        helixPoints = particles.map(particle => particle.update());
        helixPoints.sort((a, b) => a.z - b.z);

        // Draw connections
        ctx.lineWidth = 1.2;

        for (let i = 0; i < helixPoints.length; i++) {
          const hp1 = helixPoints[i];

          for (let j = 0; j < helixPoints.length; j++) {
            if (i !== j) {
              const hp2 = helixPoints[j];
              const d = dist(hp1.x, hp1.y, hp1.z, hp2.x, hp2.y, hp2.z);

              if (d < 120) {
                const opacity = map(d, 0, 120, 40, 10) * 
                              map(Math.min(hp1.z, hp2.z), -110, 110, 0.3, 1);

                ctx.strokeStyle = `rgba(20, 20, 20, ${opacity / 255})`;
                ctx.beginPath();
                ctx.moveTo(hp1.x, hp1.y);
                ctx.lineTo(hp2.x, hp2.y);
                ctx.stroke();
              }
            }
          }
        }

        // Draw points
        for (let i = 0; i < helixPoints.length; i++) {
          const hp = helixPoints[i];
          const sizeMultiplier = map(hp.z, -110, 110, 0.6, 1.3);
          const adjustedOpacity = map(hp.z, -110, 110, hp.opacity * 0.4, hp.opacity);

          ctx.fillStyle = `rgba(10, 10, 10, ${adjustedOpacity / 255})`;
          ctx.beginPath();
          ctx.arc(hp.x, hp.y, (hp.size * sizeMultiplier) / 2, 0, TWO_PI);
          ctx.fill();
        }

        // Draw spine
        ctx.strokeStyle = 'rgba(0, 0, 0, 0.118)';
        ctx.lineWidth = 2;

        const sortedByY = [...helixPoints].sort((a, b) => a.y - b.y);

        for (let i = 0; i < sortedByY.length - 1; i++) {
          const p1 = sortedByY[i];
          const p2 = sortedByY[i + 1];

          if (Math.abs(p1.y - p2.y) < 30) {
            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.stroke();
          }
        }
      }

      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    // Handle window resize
    const handleResize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    window.addEventListener('resize', handleResize);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
      window.removeEventListener('resize', handleResize);
      if (canvas && ctx) {
        ctx.clearRect(0, 0, width, height);
      }
    };
  }, []);

  return (
    <canvas 
      ref={canvasRef} 
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        zIndex: 0,
        pointerEvents: 'none'
      }}
    />
  );
};

export default HelixAnimation; 