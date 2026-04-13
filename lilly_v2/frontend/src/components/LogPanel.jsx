import React, { useState, useEffect, useRef } from 'react';

export default function LogPanel() {
  const [logs, setLogs] = useState([]);
  const [selectedContainer, setSelectedContainer] = useState('larlab_backend');
  const scrollRef = useRef(null);

  useEffect(() => {
    const eventSource = new EventSource(`/api/logs/${selectedContainer}`);
    
    eventSource.onmessage = (e) => {
      setLogs((prev) => [...prev.slice(-100), e.data]); // Keep last 100 lines
    };

    return () => eventSource.close();
  }, [selectedContainer]);

  useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [logs]);

  return (
    <div className="h-full bg-white border-l border-gray-200 flex flex-col">
      <div className="p-4 border-b border-gray-200 flex justify-between items-center">
        <h3 className="text-xs font-bold text-slate-500 uppercase tracking-widest">System Logs</h3>
        <select 
          className="text-xs bg-gray-50 border border-gray-200 rounded px-2 py-1 outline-none"
          value={selectedContainer}
          onChange={(e) => { setLogs([]); setSelectedContainer(e.target.value); }}
        >
          <option value="larlab_backend">Backend</option>
          <option value="larlab_frontend">Frontend</option>
          <option value="ollama">Ollama</option>
        </select>
      </div>
      
      <div 
        ref={scrollRef}
        className="flex-1 p-4 font-mono text-[10px] overflow-y-auto bg-gray-50 m-4 rounded-xl border border-gray-100 scrollbar-hide"
      >
        {logs.map((log, i) => (
          <div key={i} className="mb-1 text-slate-500 border-b border-gray-100 pb-1 last:border-0">
            <span className="text-cyan-600 mr-2">[{new Date().toLocaleTimeString()}]</span>
            {log}
          </div>
        ))}
      </div>
    </div>
  );
}
