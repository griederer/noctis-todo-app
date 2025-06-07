import React, { useEffect, useRef, useState } from 'react';
import EditorJS from '@editorjs/editorjs';
import Header from '@editorjs/header';
import List from '@editorjs/list';
import Code from '@editorjs/code';
import InlineCode from '@editorjs/inline-code';
import Marker from '@editorjs/marker';
import Delimiter from '@editorjs/delimiter';
import Paragraph from '@editorjs/paragraph';
import TodoBlock from '../editor/TodoBlock';
import '../styles/NoctisEditor.css';

const NoctisEditor = ({ pageId, initialData, onSave, readOnly = false }) => {
  const editorRef = useRef(null);
  const editorInstance = useRef(null);
  const [showSlashMenu, setShowSlashMenu] = useState(false);
  const [slashMenuPosition, setSlashMenuPosition] = useState({ x: 0, y: 0 });
  const [searchTerm, setSearchTerm] = useState('');

  const EDITOR_TOOLS = {
    paragraph: {
      class: Paragraph,
      inlineToolbar: true
    },
    header: {
      class: Header,
      config: {
        levels: [1, 2, 3, 4],
        defaultLevel: 2
      }
    },
    list: {
      class: List,
      inlineToolbar: true
    },
    code: Code,
    inlineCode: InlineCode,
    marker: Marker,
    delimiter: Delimiter,
    todoBlock: {
      class: TodoBlock,
      shortcut: 'CMD+SHIFT+T'
    }
  };

  const SLASH_COMMANDS = [
    { id: 'header', name: 'Heading', icon: 'H', description: 'Big section heading' },
    { id: 'todoBlock', name: 'To-do', icon: '☐', description: 'Track tasks with a checkbox' },
    { id: 'list', name: 'List', icon: '•', description: 'Simple bulleted list' },
    { id: 'code', name: 'Code', icon: '</>', description: 'Code block with syntax highlighting' },
    { id: 'delimiter', name: 'Divider', icon: '—', description: 'Horizontal divider' }
  ];

  useEffect(() => {
    if (!editorRef.current || editorInstance.current) return;

    // Initialize editor
    editorInstance.current = new EditorJS({
      holder: editorRef.current,
      tools: EDITOR_TOOLS,
      data: initialData || {
        blocks: [{
          type: 'paragraph',
          data: { text: '' }
        }]
      },
      readOnly,
      placeholder: 'Press "/" for commands or start typing...',
      onChange: async () => {
        if (onSave && editorInstance.current) {
          try {
            const data = await editorInstance.current.save();
            onSave(data);
          } catch (error) {
            console.error('Error saving:', error);
          }
        }
      },
      onReady: () => {
        // Add custom event handling for slash commands
        setupSlashCommands();
      }
    });

    return () => {
      if (editorInstance.current && typeof editorInstance.current.destroy === 'function') {
        try {
          editorInstance.current.destroy();
          editorInstance.current = null;
        } catch (error) {
          console.error('Error destroying editor:', error);
        }
      }
    };
  }, [pageId, readOnly]);

  const setupSlashCommands = () => {
    const editorElement = editorRef.current;
    if (!editorElement) return;

    // Use event delegation on the editor container
    editorElement.addEventListener('keydown', handleKeyDown, true);
  };

  const handleKeyDown = (e) => {
    if (e.key === '/' && !showSlashMenu) {
      e.preventDefault();
      showSlashMenuAtCursor();
    } else if (e.key === 'Escape' && showSlashMenu) {
      e.preventDefault();
      setShowSlashMenu(false);
      setSearchTerm('');
    }
  };

  const showSlashMenuAtCursor = () => {
    const selection = window.getSelection();
    if (!selection.rangeCount) return;
    
    const range = selection.getRangeAt(0);
    const rect = range.getBoundingClientRect();
    
    setSlashMenuPosition({
      x: rect.left,
      y: rect.bottom + window.scrollY + 5
    });
    setShowSlashMenu(true);
    setSearchTerm('');
  };

  const handleCommandSelect = async (command) => {
    setShowSlashMenu(false);
    setSearchTerm('');

    if (!editorInstance.current) return;

    try {
      const currentIndex = editorInstance.current.blocks.getCurrentBlockIndex();
      
      // Get current block and check if it's empty
      const currentBlock = editorInstance.current.blocks.getBlockByIndex(currentIndex);
      const isEmpty = !currentBlock || 
        (currentBlock.name === 'paragraph' && 
         (!currentBlock.holder.textContent || currentBlock.holder.textContent.trim() === '/'));

      if (isEmpty) {
        // Replace current block
        await editorInstance.current.blocks.delete(currentIndex);
        await editorInstance.current.blocks.insert(command.id, {}, {}, currentIndex);
        editorInstance.current.caret.setToBlock(currentIndex);
      } else {
        // Insert after current block
        await editorInstance.current.blocks.insert(command.id, {}, {}, currentIndex + 1);
        editorInstance.current.caret.setToBlock(currentIndex + 1);
      }
    } catch (error) {
      console.error('Error inserting block:', error);
    }
  };

  const filteredCommands = SLASH_COMMANDS.filter(cmd =>
    cmd.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    cmd.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Clean up event listeners
  useEffect(() => {
    return () => {
      const editorElement = editorRef.current;
      if (editorElement) {
        editorElement.removeEventListener('keydown', handleKeyDown, true);
      }
    };
  }, []);

  return (
    <div className="noctis-editor">
      <div ref={editorRef} className="editor-container" />
      
      {showSlashMenu && (
        <div 
          className="slash-menu"
          style={{
            position: 'absolute',
            left: slashMenuPosition.x,
            top: slashMenuPosition.y
          }}
        >
          <input
            type="text"
            className="slash-menu-search"
            placeholder="Search commands..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Escape') {
                setShowSlashMenu(false);
                setSearchTerm('');
              } else if (e.key === 'Enter' && filteredCommands.length > 0) {
                e.preventDefault();
                handleCommandSelect(filteredCommands[0]);
              }
            }}
            autoFocus
          />
          <div className="slash-menu-items">
            {filteredCommands.map((command) => (
              <button
                key={command.id}
                className="slash-menu-item"
                onClick={() => handleCommandSelect(command)}
              >
                <span className="slash-menu-icon">{command.icon}</span>
                <div className="slash-menu-text">
                  <div className="slash-menu-name">{command.name}</div>
                  <div className="slash-menu-description">{command.description}</div>
                </div>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default NoctisEditor; 