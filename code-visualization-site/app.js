// Función para crear el patrón geométrico hexagonal
function createGeometricPattern() {
    const svg = document.querySelector('.geometric-pattern');
    if (!svg) return;
    
    // Limpiar SVG
    svg.innerHTML = '';
    
    const centerX = 250;
    const centerY = 250;
    const hexSize = 30;
    const layers = 6;
    
    // Función para crear un hexágono
    function createHexagon(cx, cy, size, className = 'hex-pattern') {
        const points = [];
        for (let i = 0; i < 6; i++) {
            const angle = (Math.PI / 3) * i;
            const x = cx + size * Math.cos(angle);
            const y = cy + size * Math.sin(angle);
            points.push(`${x},${y}`);
        }
        
        const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygon.setAttribute('points', points.join(' '));
        polygon.setAttribute('class', className);
        return polygon;
    }
    
    // Función para crear líneas de conexión
    function createConnection(x1, y1, x2, y2) {
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', x1);
        line.setAttribute('y1', y1);
        line.setAttribute('x2', x2);
        line.setAttribute('y2', y2);
        line.setAttribute('class', 'hex-pattern');
        line.style.strokeWidth = '0.5';
        return line;
    }
    
    // Crear patrón de hexágonos en capas
    const hexagons = [];
    
    // Centro
    hexagons.push({ x: centerX, y: centerY, layer: 0 });
    svg.appendChild(createHexagon(centerX, centerY, hexSize));
    
    // Crear capas concéntricas
    for (let layer = 1; layer <= layers; layer++) {
        const radius = hexSize * 1.732 * layer; // 1.732 ≈ √3
        
        for (let i = 0; i < 6; i++) {
            const angle = (Math.PI / 3) * i;
            
            // Hexágonos en los vértices
            const vx = centerX + radius * Math.cos(angle);
            const vy = centerY + radius * Math.sin(angle);
            hexagons.push({ x: vx, y: vy, layer });
            svg.appendChild(createHexagon(vx, vy, hexSize));
            
            // Hexágonos intermedios
            if (layer > 1) {
                for (let j = 1; j < layer; j++) {
                    const nextAngle = (Math.PI / 3) * ((i + 1) % 6);
                    const t = j / layer;
                    const ix = centerX + radius * (Math.cos(angle) * (1 - t) + Math.cos(nextAngle) * t);
                    const iy = centerY + radius * (Math.sin(angle) * (1 - t) + Math.sin(nextAngle) * t);
                    hexagons.push({ x: ix, y: iy, layer });
                    svg.appendChild(createHexagon(ix, iy, hexSize));
                }
            }
        }
    }
    
    // Crear conexiones entre hexágonos cercanos
    for (let i = 0; i < hexagons.length; i++) {
        for (let j = i + 1; j < hexagons.length; j++) {
            const dist = Math.sqrt(
                Math.pow(hexagons[i].x - hexagons[j].x, 2) + 
                Math.pow(hexagons[i].y - hexagons[j].y, 2)
            );
            
            // Conectar hexágonos cercanos
            if (dist < hexSize * 2.2 && dist > hexSize * 0.5) {
                svg.appendChild(createConnection(
                    hexagons[i].x, hexagons[i].y,
                    hexagons[j].x, hexagons[j].y
                ));
            }
        }
    }
    
    // Agregar círculos decorativos en algunos hexágonos
    const decorativePositions = [
        { x: centerX, y: centerY },
        { x: centerX, y: centerY - hexSize * 3.464 },
        { x: centerX + hexSize * 3, y: centerY + hexSize * 1.732 },
        { x: centerX - hexSize * 3, y: centerY + hexSize * 1.732 },
        { x: centerX + hexSize * 3, y: centerY - hexSize * 1.732 },
        { x: centerX - hexSize * 3, y: centerY - hexSize * 1.732 },
    ];
    
    decorativePositions.forEach(pos => {
        const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        circle.setAttribute('cx', pos.x);
        circle.setAttribute('cy', pos.y);
        circle.setAttribute('r', hexSize * 0.3);
        circle.setAttribute('class', 'hex-center');
        svg.appendChild(circle);
    });
    
    // Agregar animación sutil
    const allElements = svg.querySelectorAll('.hex-pattern, .hex-center');
    allElements.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.animation = `fadeIn 1s ease-out ${index * 0.02}s forwards`;
    });
}

// Agregar estilos de animación
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: scale(0.9);
        }
        to {
            opacity: 0.8;
            transform: scale(1);
        }
    }
    
    .hex-center {
        animation: pulse 3s ease-in-out infinite;
    }
    
    @keyframes pulse {
        0%, 100% {
            opacity: 0.1;
        }
        50% {
            opacity: 0.3;
        }
    }
`;
document.head.appendChild(style);

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    createGeometricPattern();
    
    // Recrear el patrón si la ventana cambia de tamaño
    let resizeTimeout;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(createGeometricPattern, 250);
    });
});