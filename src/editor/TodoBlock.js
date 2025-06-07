export default class TodoBlock {
  static get toolbox() {
    return {
      title: 'To Do',
      icon: '<svg width="14" height="14" viewBox="0 0 14 14"><path d="M13 0H1C.448 0 0 .448 0 1v12c0 .552.448 1 1 1h12c.552 0 1-.448 1-1V1c0-.552-.448-1-1-1zM6.162 11.448L2.71 8.028l1.496-1.498 1.956 1.935 4.586-4.577 1.496 1.498-5.082 5.062z"/></svg>'
    };
  }

  constructor({ data, api }) {
    this.api = api;
    this.data = {
      text: data.text || '',
      checked: data.checked || false,
      id: data.id || Date.now().toString()
    };
    this.wrapper = null;
  }

  render() {
    this.wrapper = document.createElement('div');
    this.wrapper.classList.add('cdx-todo-block');
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = this.data.checked;
    checkbox.classList.add('cdx-todo-checkbox');
    checkbox.id = `todo-${this.data.id}`;
    
    const label = document.createElement('label');
    label.classList.add('cdx-todo-label');
    label.setAttribute('for', `todo-${this.data.id}`);
    
    const textInput = document.createElement('div');
    textInput.classList.add('cdx-todo-text');
    textInput.contentEditable = true;
    textInput.innerHTML = this.data.text;
    textInput.dataset.placeholder = 'To do...';
    
    // Update data on changes
    checkbox.addEventListener('change', (e) => {
      this.data.checked = e.target.checked;
      this.wrapper.classList.toggle('cdx-todo-checked', e.target.checked);
    });
    
    textInput.addEventListener('input', (e) => {
      this.data.text = e.target.innerHTML;
    });
    
    // Handle Enter key
    textInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.api.blocks.insert('todoBlock', {
          text: '',
          checked: false
        });
      }
    });
    
    label.appendChild(checkbox);
    label.appendChild(textInput);
    this.wrapper.appendChild(label);
    
    if (this.data.checked) {
      this.wrapper.classList.add('cdx-todo-checked');
    }
    
    return this.wrapper;
  }

  save() {
    return {
      text: this.data.text,
      checked: this.data.checked,
      id: this.data.id
    };
  }

  static get isReadOnlySupported() {
    return true;
  }
} 