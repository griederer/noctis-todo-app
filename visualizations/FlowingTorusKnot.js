// FlowingTorusKnot.js - A Three.js visualization of dissolution and reformation
// Minimal aesthetic exploring continuous transformation

const FlowingTorusKnot = () => {
  const containerRef = React.useRef(null);

  React.useEffect(() => {
    if (!containerRef.current) return;

    // Check if Three.js is loaded
    if (typeof THREE === 'undefined') {
      console.error('Three.js is not loaded');
      return;
    }

    // Scene setup
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    
    renderer.setSize(550, 550);
    renderer.setClearColor(0xF8F7F4, 1);
    containerRef.current.appendChild(renderer.domElement);
    
    camera.position.z = 4;
    
    // Create torus knot geometry to extract vertices
    const knotGeometry = new THREE.TorusKnotGeometry(1.5, 0.1, 100, 16, 3, 4);
    const knotVertices = knotGeometry.attributes.position.array;
    const knotIndices = knotGeometry.index.array;
    
    // Create individual line segments that can detach
    const lineSegments = [];
    const segmentGroup = new THREE.Group();
    
    // Create lines from the geometry indices
    for (let i = 0; i < knotIndices.length; i += 3) {
      // Get the three vertices of the triangle
      const v1 = new THREE.Vector3(
        knotVertices[knotIndices[i] * 3],
        knotVertices[knotIndices[i] * 3 + 1],
        knotVertices[knotIndices[i] * 3 + 2]
      );
      const v2 = new THREE.Vector3(
        knotVertices[knotIndices[i + 1] * 3],
        knotVertices[knotIndices[i + 1] * 3 + 1],
        knotVertices[knotIndices[i + 1] * 3 + 2]
      );
      const v3 = new THREE.Vector3(
        knotVertices[knotIndices[i + 2] * 3],
        knotVertices[knotIndices[i + 2] * 3 + 1],
        knotVertices[knotIndices[i + 2] * 3 + 2]
      );
      
      // Create the three edges of the triangle
      const edges = [
        [v1, v2],
        [v2, v3],
        [v3, v1]
      ];
      
      edges.forEach((edge, edgeIndex) => {
        const lineGeometry = new THREE.BufferGeometry().setFromPoints(edge);
        const lineMaterial = new THREE.LineBasicMaterial({
          color: 0x999999,
          transparent: true,
          opacity: 0.3
        });
        
        const line = new THREE.Line(lineGeometry, lineMaterial);
        
        // Store animation properties
        line.userData = {
          originalPositions: edge.map(v => v.clone()),
          center: edge[0].clone().add(edge[1]).multiplyScalar(0.5),
          maxDetachment: 0.2 + Math.random() * 0.3,
          randomSeed: Math.random()
        };
        
        lineSegments.push(line);
        segmentGroup.add(line);
      });
    }
    
    scene.add(segmentGroup);
    
    // Create minimal particle system
    const particleCount = 200;
    const particleGeometry = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);
    const velocities = [];
    
    // Initialize particles along the torus knot path
    for (let i = 0; i < particleCount; i++) {
      const t = (i / particleCount) * Math.PI * 6;
      const r = 1.5, tube = 0.1;
      const p = 3, q = 4;
      
      // Position along torus knot path
      const x = (r + tube * Math.cos(q * t)) * Math.cos(p * t);
      const y = (r + tube * Math.cos(q * t)) * Math.sin(p * t);
      const z = tube * Math.sin(q * t);
      
      // Add small random offset inside the tube
      const randomOffset = 0.05;
      positions[i * 3] = x + (Math.random() - 0.5) * randomOffset;
      positions[i * 3 + 1] = y + (Math.random() - 0.5) * randomOffset;
      positions[i * 3 + 2] = z + (Math.random() - 0.5) * randomOffset;
      
      velocities.push({
        t: t,
        speed: 0.001 + Math.random() * 0.001,
        phase: Math.random() * Math.PI * 2,
        turbulence: Math.random() * 0.2
      });
    }
    
    particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    
    // Particle material - subtle gray dots
    const particleMaterial = new THREE.PointsMaterial({
      color: 0x888888,
      size: 0.015,
      transparent: true,
      opacity: 0.4,
      sizeAttenuation: true
    });
    
    const particles = new THREE.Points(particleGeometry, particleMaterial);
    scene.add(particles);
    
    // Animation
    let time = 0;
    let animationId;
    let isRunning = true;
    
    const animate = () => {
      if (!isRunning) return;
      
      time += 0.002;
      
      // Minimal rotation
      segmentGroup.rotation.x = Math.PI / 6 + Math.sin(time * 0.05) * 0.03;
      segmentGroup.rotation.y = time * 0.05;
      segmentGroup.rotation.z = Math.cos(time * 0.04) * 0.02;
      
      // Very gentle breathing scale
      const scale = 0.995 + 0.005 * Math.sin(time * 0.2);
      segmentGroup.scale.setScalar(scale);
      
      // Calculate cycle progress (slower, more contemplative)
      const cycleTime = 600; // 10 minutes for full cycle
      const currentCycleTime = (time * 60) % cycleTime;
      
      let globalDetachment;
      if (currentCycleTime < 300) {
        // First 5 minutes: gradually separate
        globalDetachment = currentCycleTime / 300;
      } else {
        // Second 5 minutes: gradually reform
        globalDetachment = 1 - ((currentCycleTime - 300) / 300);
      }
      
      // Smooth easing
      const smoothEase = (t) => {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      };
      
      const elegantDetachment = smoothEase(globalDetachment);
      
      // Animate individual line segments
      lineSegments.forEach((line, index) => {
        const userData = line.userData;
        
        // Staggered timing
        const segmentDelay = (index / lineSegments.length) * 0.3;
        let segmentProgress = elegantDetachment - segmentDelay;
        segmentProgress = Math.max(0, Math.min(1, segmentProgress / 0.7));
        
        // Calculate detachment
        const detachAmount = segmentProgress * userData.maxDetachment;
        
        // Detachment direction
        const center = userData.center;
        const detachDirection = center.clone().normalize();
        
        // Subtle randomization
        const seed = userData.randomSeed;
        const randomOffset = new THREE.Vector3(
          (Math.sin(seed * 12.9898) - 0.5) * segmentProgress * 0.1,
          (Math.sin(seed * 78.233) - 0.5) * segmentProgress * 0.1,
          (Math.sin(seed * 37.719) - 0.5) * segmentProgress * 0.1
        );
        
        const finalDirection = detachDirection.add(randomOffset);
        
        // Update line positions
        const positions = line.geometry.attributes.position.array;
        for (let i = 0; i < 2; i++) {
          const originalPos = userData.originalPositions[i];
          const detachedPos = originalPos.clone().add(finalDirection.clone().multiplyScalar(detachAmount));
          
          positions[i * 3] = detachedPos.x;
          positions[i * 3 + 1] = detachedPos.y;
          positions[i * 3 + 2] = detachedPos.z;
        }
        
        line.geometry.attributes.position.needsUpdate = true;
        
        // Subtle fade
        line.material.opacity = 0.3 - segmentProgress * 0.15;
      });
      
      // Update particles
      const positions = particleGeometry.attributes.position.array;
      for (let i = 0; i < particleCount; i++) {
        const vel = velocities[i];
        vel.t += vel.speed;
        
        // Loop the path
        if (vel.t > Math.PI * 6) {
          vel.t = 0;
        }
        
        const t = vel.t;
        const r = 1.5, tube = 0.1;
        const p = 3, q = 4;
        
        // Calculate position along the torus knot
        const x = (r + tube * Math.cos(q * t)) * Math.cos(p * t);
        const y = (r + tube * Math.cos(q * t)) * Math.sin(p * t);
        const z = tube * Math.sin(q * t);
        
        // Very subtle floating motion
        const floatX = Math.sin(time * 0.1 + vel.phase) * 0.005;
        const floatY = Math.cos(time * 0.12 + vel.phase + 1) * 0.005;
        const floatZ = Math.sin(time * 0.11 + vel.phase + 2) * 0.005;
        
        positions[i * 3] = x + floatX;
        positions[i * 3 + 1] = y + floatY;
        positions[i * 3 + 2] = z + floatZ;
      }
      
      particleGeometry.attributes.position.needsUpdate = true;
      
      renderer.render(scene, camera);
      animationId = requestAnimationFrame(animate);
    };
    
    animate();
    
    // Cleanup
    return () => {
      isRunning = false;
      if (animationId) {
        cancelAnimationFrame(animationId);
      }
      
      // Dispose of all geometries and materials
      knotGeometry.dispose();
      lineSegments.forEach(line => {
        line.geometry.dispose();
        line.material.dispose();
      });
      particleGeometry.dispose();
      particleMaterial.dispose();
      
      if (containerRef.current && renderer.domElement) {
        containerRef.current.removeChild(renderer.domElement);
      }
      
      renderer.dispose();
    };
  }, []);

  return React.createElement('div', {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '100%',
      height: '100%',
      backgroundColor: '#F8F7F4'
    }
  }, 
    React.createElement('div', {
      style: {
        width: '550px',
        height: '550px'
      }
    }, 
      React.createElement('div', {
        ref: containerRef,
        style: {
          width: '100%',
          height: '100%'
        }
      })
    )
  );
};

// Make the component available globally
window.FlowingTorusKnot = FlowingTorusKnot; 