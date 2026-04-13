import React, { useState } from 'react';
import { ShieldAlert, Send, RefreshCw } from 'lucide-react';

export default function WarRoomPanel({ isConsultMode }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");

  const triggerConsult = async () => {
    if (!input) return;
    setMessages(prev => [...prev, { agent: 'User', content: input, role: 'Chairman' }]);
    
    // Connect to the Backend Master (Port 8000)
    const eventSource = new EventSource(`http://100.93.131.114:4001/api/war-room/stream?prompt=${encodeURIComponent(input)}&mode=consult`);
    
    eventSource.onmessage = (e) => {
      const data = JSON.parse(e.data);
      if (data.status === 'complete') {
        setMessages(prev => [...prev, data]);
      }
    };
    setInput("");
  };
// Add this inside your Warroom.jsx state
const [notifications, setNotifications] = useState([]);

// Trigger this when Stage 3 is complete
const handleAppReady = (appName) => {
  setNotifications([...notifications, {
    id: Date.now(),
    title: "Project Ready",
    text: `${appName} is now live on Port 8081.`,
    action: "Download Files",
    link: `http://localhost:5000/api/forge/download/${appName}`
  }]);
};
  return (
    <div className="space-y-8 animate-in fade-in duration-700">
      <div className="bg-white p-10 rounded-[40px] border border-[#e6e2d3] shadow-sm flex flex-col h-[60vh]">
        <div className="flex-1 overflow-y-auto space-y-6 mb-8 pr-4 scrollbar-hide">
          {messages.length === 0 && (
            <div className="h-full flex flex-col items-center justify-center opacity-20 italic">
              <ShieldAlert size={48} strokeWidth={1} className="mb-4" />
              <p className="text-sm">Initiate consultation to engage the Neural Agents</p>
            </div>
          )}
          {messages.map((m, i) => (
            <div key={i} className={`flex flex-col ${m.agent === 'User' ? 'items-end' : 'items-start'}`}>
              <span className="text-[9px] font-bold uppercase tracking-widest mb-2 opacity-30 px-4">{m.agent}</span>
              <div className={`p-6 rounded-[2rem] text-sm max-w-[80%] ${m.agent === 'User' ? 'bg-[#f0ece0] text-[#1d1b16]' : 'bg-[#fdfcf7] border border-[#e6e2d3] text-slate-600'}`}>
                {m.content}
              </div>
            </div>
          ))}
        </div>

        <div className="flex gap-3">
          <input 
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && triggerConsult()}
            placeholder="Type a colab question or end-goal..."
            className="flex-1 bg-[#fdfcf7] border border-[#e6e2d3] rounded-[2rem] px-8 py-5 text-sm outline-none focus:border-cyan-200 transition-all"
          />
          <button onClick={triggerConsult} className="p-5 bg-[#1d1b16] text-white rounded-[2rem] hover:bg-cyan-600 transition-all">
            <Send size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}

