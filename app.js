// Estado de la aplicación
const state = {
    posts: [],
    currentPost: null,
    animationId: null
};

// Elementos del DOM
const elements = {
    newPostBtn: document.getElementById('newPostBtn'),
    editorSection: document.getElementById('editorSection'),
    closeEditorBtn: document.getElementById('closeEditorBtn'),
    postForm: document.getElementById('postForm'),
    postsContainer: document.getElementById('postsContainer'),
    previewBtn: document.getElementById('previewBtn'),
    previewModal: document.getElementById('previewModal'),
    closePreviewBtn: document.getElementById('closePreviewBtn'),
    previewContent: document.getElementById('previewContent'),
    
    // Campos del formulario
    postTitle: document.getElementById('postTitle'),
    codeEditor: document.getElementById('codeEditor'),
    descriptionEditor: document.getElementById('descriptionEditor'),
    languageSelect: document.getElementById('languageSelect'),
    visualizationType: document.getElementById('visualizationType')
};

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
    loadPosts();
    setupEventListeners();
    initializeDemoAnimation();
});

// Event Listeners
function setupEventListeners() {
    elements.newPostBtn.addEventListener('click', showEditor);
    elements.closeEditorBtn.addEventListener('click', hideEditor);
    elements.postForm.addEventListener('submit', handleSubmit);
    elements.previewBtn.addEventListener('click', showPreview);
    elements.closePreviewBtn.addEventListener('click', hidePreview);
    
    // Cerrar modal al hacer clic fuera
    elements.previewModal.addEventListener('click', (e) => {
        if (e.target === elements.previewModal) {
            hidePreview();
        }
    });
}

// Mostrar/Ocultar editor
function showEditor() {
    elements.editorSection.classList.remove('hidden');
    elements.postTitle.focus();
}

function hideEditor() {
    elements.editorSection.classList.add('hidden');
    resetForm();
}

// Resetear formulario
function resetForm() {
    elements.postForm.reset();
    state.currentPost = null;
}

// Manejar envío del formulario
function handleSubmit(e) {
    e.preventDefault();
    
    const post = {
        id: state.currentPost?.id || Date.now(),
        title: elements.postTitle.value,
        code: elements.codeEditor.value,
        description: elements.descriptionEditor.value,
        language: elements.languageSelect.value,
        visualizationType: elements.visualizationType.value,
        date: new Date().toISOString().split('T')[0]
    };
    
    if (state.currentPost) {
        // Actualizar post existente
        const index = state.posts.findIndex(p => p.id === state.currentPost.id);
        if (index !== -1) {
            state.posts[index] = post;
        }
    } else {
        // Agregar nuevo post
        state.posts.unshift(post);
    }
    
    savePosts();
    renderPosts();
    hideEditor();
    showNotification('Post guardado exitosamente');
}

// Vista previa
function showPreview() {
    const post = {
        title: elements.postTitle.value,
        code: elements.codeEditor.value,
        description: elements.descriptionEditor.value,
        language: elements.languageSelect.value,
        visualizationType: elements.visualizationType.value,
        date: new Date().toISOString().split('T')[0]
    };
    
    elements.previewContent.innerHTML = renderPost(post, true);
    elements.previewModal.classList.remove('hidden');
    
    // Aplicar syntax highlighting
    Prism.highlightAllUnder(elements.previewContent);
    
    // Inicializar visualización si existe
    if (post.visualizationType !== 'none') {
        initializeVisualization(post, 'preview');
    }
}

function hidePreview() {
    elements.previewModal.classList.add('hidden');
    elements.previewContent.innerHTML = '';
}

// Renderizar posts
function renderPosts() {
    if (state.posts.length === 0) {
        elements.postsContainer.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-code fa-3x" style="opacity: 0.3; margin-bottom: 1rem;"></i>
                <p style="color: var(--text-secondary);">No hay posts todavía. ¡Crea el primero!</p>
            </div>
        `;
        return;
    }
    
    elements.postsContainer.innerHTML = state.posts.map(post => renderPost(post)).join('');
    
    // Aplicar syntax highlighting
    Prism.highlightAll();
    
    // Inicializar visualizaciones
    state.posts.forEach(post => {
        if (post.visualizationType !== 'none') {
            initializeVisualization(post, post.id);
        }
    });
}

// Renderizar un post individual
function renderPost(post, isPreview = false) {
    const visualizationHtml = getVisualizationHtml(post, isPreview);
    
    return `
        <article class="post-card" ${!isPreview ? `data-post-id="${post.id}"` : ''}>
            <div class="post-header">
                <h2 class="post-title">${escapeHtml(post.title)}</h2>
                <div class="post-meta">
                    <span class="post-date">${post.date}</span>
                    <span class="post-language">${post.language.toUpperCase()}</span>
                </div>
            </div>
            
            <div class="post-content">
                <div class="content-grid">
                    <div class="code-section">
                        <pre><code class="language-${post.language}">${escapeHtml(post.code)}</code></pre>
                    </div>
                    
                    <div class="description-section">
                        <div class="description-content">
                            <h3>Descripción</h3>
                            ${formatDescription(post.description)}
                        </div>
                        
                        ${visualizationHtml}
                    </div>
                </div>
            </div>
            
            ${!isPreview ? `
                <div class="post-actions" style="padding: 1rem; border-top: 1px solid var(--border-color); display: flex; gap: 0.5rem;">
                    <button class="btn btn-small btn-secondary" onclick="editPost(${post.id})">
                        <i class="fas fa-edit"></i>
                        Editar
                    </button>
                    <button class="btn btn-small btn-text" onclick="deletePost(${post.id})">
                        <i class="fas fa-trash"></i>
                        Eliminar
                    </button>
                </div>
            ` : ''}
        </article>
    `;
}

// Obtener HTML de visualización según el tipo
function getVisualizationHtml(post, isPreview) {
    if (post.visualizationType === 'none') return '';
    
    const id = isPreview ? 'preview' : post.id;
    
    switch (post.visualizationType) {
        case 'canvas':
            return `
                <div class="visualization-section">
                    <h4>Visualización</h4>
                    <canvas id="canvas-${id}" class="demo-canvas" width="400" height="300"></canvas>
                    <button class="btn btn-small" onclick="runVisualization(${id}, '${post.visualizationType}')">
                        <i class="fas fa-play"></i>
                        Ejecutar
                    </button>
                </div>
            `;
        case 'console':
            return `
                <div class="visualization-section">
                    <h4>Consola</h4>
                    <div id="console-${id}" class="console-output" style="background: var(--background); padding: 1rem; border-radius: 4px; font-family: var(--font-mono); font-size: 0.875rem; min-height: 100px; max-height: 300px; overflow-y: auto;"></div>
                    <button class="btn btn-small" onclick="runVisualization(${id}, '${post.visualizationType}')">
                        <i class="fas fa-play"></i>
                        Ejecutar
                    </button>
                </div>
            `;
        case 'html':
            return `
                <div class="visualization-section">
                    <h4>Resultado HTML</h4>
                    <div id="html-${id}" class="html-output" style="background: white; padding: 1rem; border-radius: 4px; min-height: 100px; color: black;"></div>
                    <button class="btn btn-small" onclick="runVisualization(${id}, '${post.visualizationType}')">
                        <i class="fas fa-play"></i>
                        Renderizar
                    </button>
                </div>
            `;
        default:
            return '';
    }
}

// Inicializar visualización
function initializeVisualization(post, id) {
    // Esta función se puede expandir para inicializar visualizaciones automáticamente
}

// Ejecutar visualización
window.runVisualization = function(postId, type) {
    const post = state.posts.find(p => p.id === postId) || {
        code: elements.codeEditor.value,
        language: elements.languageSelect.value
    };
    
    try {
        switch (type) {
            case 'canvas':
                runCanvasVisualization(postId, post.code);
                break;
            case 'console':
                runConsoleVisualization(postId, post.code);
                break;
            case 'html':
                runHtmlVisualization(postId, post.code);
                break;
        }
        showNotification('Código ejecutado', 'success');
    } catch (error) {
        showNotification('Error al ejecutar: ' + error.message, 'error');
        console.error(error);
    }
};

// Ejecutar visualización en Canvas
function runCanvasVisualization(id, code) {
    const canvas = document.getElementById(`canvas-${id}`);
    if (!canvas) return;
    
    // Crear un contexto seguro para ejecutar el código
    const ctx = canvas.getContext('2d');
    
    // Limpiar canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Ejecutar código en un try-catch
    try {
        // Crear función con el código y ejecutar
        const func = new Function('canvas', 'ctx', code);
        func(canvas, ctx);
    } catch (error) {
        throw new Error('Error en el código del canvas: ' + error.message);
    }
}

// Ejecutar visualización en Consola
function runConsoleVisualization(id, code) {
    const consoleEl = document.getElementById(`console-${id}`);
    if (!consoleEl) return;
    
    // Limpiar consola
    consoleEl.innerHTML = '';
    
    // Override temporal de console.log
    const originalLog = console.log;
    console.log = function(...args) {
        const line = args.map(arg => {
            if (typeof arg === 'object') {
                return JSON.stringify(arg, null, 2);
            }
            return String(arg);
        }).join(' ');
        
        consoleEl.innerHTML += `<div style="margin-bottom: 0.25rem;">${escapeHtml(line)}</div>`;
        originalLog.apply(console, args);
    };
    
    try {
        // Ejecutar código
        eval(code);
    } catch (error) {
        consoleEl.innerHTML += `<div style="color: var(--danger-color);">Error: ${escapeHtml(error.message)}</div>`;
    } finally {
        // Restaurar console.log
        console.log = originalLog;
    }
}

// Ejecutar visualización HTML
function runHtmlVisualization(id, code) {
    const htmlEl = document.getElementById(`html-${id}`);
    if (!htmlEl) return;
    
    // Si es código HTML, insertarlo directamente
    if (code.trim().startsWith('<')) {
        htmlEl.innerHTML = code;
    } else {
        // Si es JavaScript, ejecutarlo y capturar el resultado
        try {
            const result = eval(code);
            if (result !== undefined) {
                htmlEl.innerHTML = String(result);
            }
        } catch (error) {
            htmlEl.innerHTML = `<div style="color: red;">Error: ${escapeHtml(error.message)}</div>`;
        }
    }
}

// Editar post
window.editPost = function(postId) {
    const post = state.posts.find(p => p.id === postId);
    if (!post) return;
    
    state.currentPost = post;
    
    // Llenar formulario
    elements.postTitle.value = post.title;
    elements.codeEditor.value = post.code;
    elements.descriptionEditor.value = post.description;
    elements.languageSelect.value = post.language;
    elements.visualizationType.value = post.visualizationType;
    
    showEditor();
};

// Eliminar post
window.deletePost = function(postId) {
    if (!confirm('¿Estás seguro de eliminar este post?')) return;
    
    state.posts = state.posts.filter(p => p.id !== postId);
    savePosts();
    renderPosts();
    showNotification('Post eliminado');
};

// Guardar posts en localStorage
function savePosts() {
    localStorage.setItem('wayofcode_posts', JSON.stringify(state.posts));
}

// Cargar posts desde localStorage
function loadPosts() {
    const saved = localStorage.getItem('wayofcode_posts');
    if (saved) {
        state.posts = JSON.parse(saved);
        renderPosts();
    }
}

// Formatear descripción (convertir saltos de línea en párrafos)
function formatDescription(text) {
    return text
        .split('\n\n')
        .map(paragraph => `<p>${escapeHtml(paragraph).replace(/\n/g, '<br>')}</p>`)
        .join('');
}

// Escapar HTML
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Mostrar notificación
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 1rem 1.5rem;
        background-color: ${type === 'success' ? 'var(--success-color)' : 'var(--danger-color)'};
        color: white;
        border-radius: var(--radius);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        z-index: 1001;
        animation: slideIn 0.3s ease;
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Animación de demostración
function initializeDemoAnimation() {
    const canvas = document.getElementById('demoCanvas');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    const particles = [];
    
    // Crear partículas
    for (let i = 0; i < 20; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            vx: Math.random() * 4 - 2,
            vy: Math.random() * 4 - 2,
            radius: Math.random() * 3 + 1
        });
    }
    
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        particles.forEach(particle => {
            // Actualizar posición
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            // Rebotar en los bordes
            if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
            if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;
            
            // Dibujar partícula
            ctx.beginPath();
            ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
            ctx.fillStyle = '#3b82f6';
            ctx.fill();
        });
        
        state.animationId = requestAnimationFrame(animate);
    }
    
    // Función global para controlar la animación
    window.toggleAnimation = function() {
        if (state.animationId) {
            cancelAnimationFrame(state.animationId);
            state.animationId = null;
        } else {
            animate();
        }
    };
}

// Agregar estilos de animación
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .empty-state {
        text-align: center;
        padding: 4rem 2rem;
    }
`;
document.head.appendChild(style); 