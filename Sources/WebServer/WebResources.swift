// Static web resources as a separate enum for easy access

public enum WebResources {
    public static let indexHTML = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Model Explorer</title>
        <link rel="stylesheet" href="/style.css">
    </head>
    <body>
        <div class="container">
            <header>
                <h1>Model Explorer</h1>
                <span id="status" class="status">Checking...</span>
            </header>
            
            <main id="chat-container">
                <div id="messages"></div>
            </main>
            
            <footer>
                <form id="chat-form">
                    <textarea 
                        id="message-input" 
                        placeholder="Type a message..." 
                        rows="1"
                        autofocus
                    ></textarea>
                    <button type="submit" id="send-btn">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                        </svg>
                    </button>
                </form>
            </footer>
        </div>
        <script src="/app.js"></script>
    </body>
    </html>
    """
    
    public static let styleCSS = """
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    :root {
        --bg-primary: #1a1a1a;
        --bg-secondary: #2d2d2d;
        --bg-tertiary: #3d3d3d;
        --text-primary: #ffffff;
        --text-secondary: #a0a0a0;
        --accent: #007aff;
        --accent-hover: #0056b3;
        --user-bubble: #007aff;
        --assistant-bubble: #3d3d3d;
        --border: #404040;
    }
    
    @media (prefers-color-scheme: light) {
        :root {
            --bg-primary: #ffffff;
            --bg-secondary: #f5f5f5;
            --bg-tertiary: #e5e5e5;
            --text-primary: #1a1a1a;
            --text-secondary: #666666;
            --assistant-bubble: #e5e5e5;
            --border: #e0e0e0;
        }
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background: var(--bg-primary);
        color: var(--text-primary);
        height: 100vh;
        display: flex;
        flex-direction: column;
    }
    
    .container {
        display: flex;
        flex-direction: column;
        height: 100%;
        max-width: 800px;
        margin: 0 auto;
        width: 100%;
    }
    
    header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 16px 20px;
        border-bottom: 1px solid var(--border);
    }
    
    header h1 {
        font-size: 1.25rem;
        font-weight: 600;
    }
    
    .status {
        font-size: 0.75rem;
        padding: 4px 8px;
        border-radius: 12px;
        background: var(--bg-tertiary);
    }
    
    .status.available {
        background: #22c55e20;
        color: #22c55e;
    }
    
    .status.unavailable {
        background: #ef444420;
        color: #ef4444;
    }
    
    main {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
    }
    
    #messages {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    .message {
        max-width: 80%;
        padding: 12px 16px;
        border-radius: 16px;
        line-height: 1.5;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
    
    .message.user {
        align-self: flex-end;
        background: var(--user-bubble);
        color: white;
        border-bottom-right-radius: 4px;
    }
    
    .message.assistant {
        align-self: flex-start;
        background: var(--assistant-bubble);
        border-bottom-left-radius: 4px;
    }
    
    .message.error {
        background: #ef444420;
        color: #ef4444;
    }
    
    .message .time {
        font-size: 0.65rem;
        opacity: 0.7;
        margin-top: 6px;
        display: block;
    }
    
    .message.streaming .cursor {
        animation: blink 1s infinite;
        color: var(--accent);
    }
    
    @keyframes blink {
        0%, 50% { opacity: 1; }
        51%, 100% { opacity: 0; }
    }
    
    .typing {
        display: flex;
        gap: 4px;
        padding: 16px;
    }
    
    .typing span {
        width: 8px;
        height: 8px;
        background: var(--text-secondary);
        border-radius: 50%;
        animation: bounce 1.4s infinite ease-in-out;
    }
    
    .typing span:nth-child(1) { animation-delay: -0.32s; }
    .typing span:nth-child(2) { animation-delay: -0.16s; }
    
    @keyframes bounce {
        0%, 80%, 100% { transform: scale(0); }
        40% { transform: scale(1); }
    }
    
    footer {
        padding: 16px 20px;
        border-top: 1px solid var(--border);
        background: var(--bg-secondary);
    }
    
    #chat-form {
        display: flex;
        gap: 12px;
        align-items: flex-end;
    }
    
    #message-input {
        flex: 1;
        background: var(--bg-primary);
        border: 1px solid var(--border);
        border-radius: 20px;
        padding: 12px 16px;
        font-size: 1rem;
        color: var(--text-primary);
        resize: none;
        max-height: 120px;
        font-family: inherit;
    }
    
    #message-input:focus {
        outline: none;
        border-color: var(--accent);
    }
    
    #message-input::placeholder {
        color: var(--text-secondary);
    }
    
    #send-btn {
        width: 44px;
        height: 44px;
        border: none;
        border-radius: 50%;
        background: var(--accent);
        color: white;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s;
    }
    
    #send-btn:hover {
        background: var(--accent-hover);
    }
    
    #send-btn:disabled {
        background: var(--bg-tertiary);
        cursor: not-allowed;
    }
    
    #send-btn svg {
        width: 20px;
        height: 20px;
    }
    """
    
    public static let appJS = """
    const messagesContainer = document.getElementById('messages');
    const chatForm = document.getElementById('chat-form');
    const messageInput = document.getElementById('message-input');
    const sendBtn = document.getElementById('send-btn');
    const statusEl = document.getElementById('status');
    
    let isLoading = false;
    let statusInfo = null;
    
    // Check API status
    async function checkStatus() {
        try {
            const res = await fetch('/api/status');
            statusInfo = await res.json();
            
            if (statusInfo.available) {
                statusEl.textContent = 'Available';
                statusEl.className = 'status available';
                statusEl.title = statusInfo.message;
            } else {
                statusEl.textContent = 'Unavailable';
                statusEl.className = 'status unavailable';
                statusEl.title = statusInfo.reason || statusInfo.message;
                
                // Show detailed error in chat
                addMessage(
                    `⚠️ ${statusInfo.message}\\n\\n${statusInfo.reason || 'Unknown reason'}`,
                    'assistant',
                    true
                );
            }
            sendBtn.disabled = !statusInfo.available;
        } catch {
            statusEl.textContent = 'Error';
            statusEl.className = 'status unavailable';
            statusEl.title = 'Failed to connect to server';
        }
    }
    
    // Add message to chat
    function addMessage(content, role, isError = false) {
        const div = document.createElement('div');
        div.className = `message ${role}${isError ? ' error' : ''}`;
        
        const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        div.innerHTML = `<span class="content">${escapeHtml(content)}</span><span class="time">${time}</span>`;
        
        messagesContainer.appendChild(div);
        div.scrollIntoView({ behavior: 'smooth' });
        return div;
    }
    
    // Create streaming message placeholder
    function createStreamingMessage() {
        const div = document.createElement('div');
        div.className = 'message assistant streaming';
        div.innerHTML = '<span class="content"></span><span class="cursor">▊</span>';
        messagesContainer.appendChild(div);
        div.scrollIntoView({ behavior: 'smooth' });
        return div;
    }
    
    // Update streaming message content
    function updateStreamingMessage(div, content) {
        const contentEl = div.querySelector('.content');
        if (contentEl) {
            contentEl.innerHTML = escapeHtml(content);
            div.scrollIntoView({ behavior: 'smooth' });
        }
    }
    
    // Finalize streaming message
    function finalizeStreamingMessage(div) {
        div.classList.remove('streaming');
        const cursor = div.querySelector('.cursor');
        if (cursor) cursor.remove();
        
        const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        div.innerHTML += `<span class="time">${time}</span>`;
    }
    
    // Escape HTML
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    // Send message with SSE streaming
    async function sendMessage(message) {
        if (isLoading || !message.trim()) return;
        
        isLoading = true;
        sendBtn.disabled = true;
        
        addMessage(message, 'user');
        const responseDiv = createStreamingMessage();
        
        try {
            const res = await fetch('/api/stream', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message })
            });
            
            if (!res.ok) {
                throw new Error(`HTTP ${res.status}`);
            }
            
            const reader = res.body.getReader();
            const decoder = new TextDecoder();
            let buffer = '';
            
            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                
                buffer += decoder.decode(value, { stream: true });
                const lines = buffer.split('\\n\\n');
                buffer = lines.pop() || '';
                
                for (const line of lines) {
                    if (line.startsWith('data: ')) {
                        try {
                            const event = JSON.parse(line.slice(6));
                            
                            if (event.type === 'content') {
                                updateStreamingMessage(responseDiv, event.content);
                            } else if (event.type === 'done') {
                                finalizeStreamingMessage(responseDiv);
                            } else if (event.type === 'error') {
                                responseDiv.classList.add('error');
                                updateStreamingMessage(responseDiv, event.content || 'An error occurred');
                                finalizeStreamingMessage(responseDiv);
                            }
                        } catch (e) {
                            console.error('Failed to parse SSE event:', e);
                        }
                    }
                }
            }
            
            // Ensure message is finalized
            if (responseDiv.classList.contains('streaming')) {
                finalizeStreamingMessage(responseDiv);
            }
            
        } catch (err) {
            responseDiv.classList.add('error');
            updateStreamingMessage(responseDiv, 'Failed to connect to server: ' + err.message);
            finalizeStreamingMessage(responseDiv);
        }
        
        isLoading = false;
        sendBtn.disabled = !statusInfo?.available;
        messageInput.focus();
    }
    
    // Event listeners
    chatForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const message = messageInput.value;
        messageInput.value = '';
        messageInput.style.height = 'auto';
        sendMessage(message);
    });
    
    messageInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            chatForm.dispatchEvent(new Event('submit'));
        }
    });
    
    messageInput.addEventListener('input', () => {
        messageInput.style.height = 'auto';
        messageInput.style.height = Math.min(messageInput.scrollHeight, 120) + 'px';
    });
    
    // Initialize
    checkStatus();
    """
}
