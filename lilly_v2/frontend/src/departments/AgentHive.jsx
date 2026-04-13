import React, { useState } from 'react';

const AgentHive = ({ isOnline }) => {
  const [mode, setMode] = useState('collective');
  const [activeId, setActiveId] = useState('Agent1');

  const agents = {
    Agent1: { name: "Lil-Dev", role: "Software Construction", color: "blue", bio: "Handles React components and FastAPI endpoints." },
    Agent2: { name: "Lil-Arch", role: "System Design", color: "purple", bio: "Optimizes the Supernova architecture and Docker mapping." },
    Agent3: { name: "Lil-Data", role: "Intelligence & Logs", color: "emerald", bio: "Sifts through Innisfil worker traffic and model outputs." },
    Agent4: { name: "Lil-Sec", role: "Security Ops", color: "amber", bio: "Monitors Tailscale encryption and port 3000/4001 integrity." }
  };

  return (
    <div className="flex h-full bg-white/40 backdrop-blur-3xl rounded-[4rem] overflow-hidden">
      {/* Social List */}
      <aside className="w-72 border-r border-white/50 flex flex-col p-8 bg-white/20">
        <button 
          onClick={() => setMode('collective')}
          className={`w-full py-5 rounded-[2.5rem] font-black text-[10px] tracking-[0.3em] mb-10 transition-all ${mode === 'collective' ? 'bg-slate-900 text-emerald-400 shadow-2xl scale-105' : 'bg-white text-slate-400 shadow-sm'}`}
        >
          THE HIVE
        </button>

        <div className="space-y-4">
          {Object.entries(agents).map(([id, a]) => (
            <button key={id} onClick={() => { setMode('individual'); setActiveId(id); }}
              className={`w-full flex items-center gap-4 p-4 rounded-3xl transition-all ${mode === 'individual' && activeId === id ? 'bg-white shadow-lg' : 'opacity-50 hover:opacity-100'}`}>
              <img src={`/${id}.png`} className="w-8 h-8 rounded-xl object-cover" alt={a.name} />
              <div className="text-left">
                <p className="font-bold text-xs text-slate-800">{a.name}</p>
                <p className="text-[8px] uppercase tracking-widest text-slate-400">Active</p>
              </div>
            </button>
          ))}
        </div>
      </aside>

      {/* Social Chat Display */}
      <div className="flex-1 p-12 flex flex-col">
        <header className="mb-10 flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-black tracking-tight">{mode === 'collective' ? 'The Collective Hive' : agents[activeId].name}</h2>
            <p className="text-xs text-slate-400 font-medium italic">{mode === 'collective' ? 'Synchronized Intelligence' : agents[activeId].role}</p>
          </div>
        </header>

        <div className="flex-1 space-y-6 overflow-y-auto pr-4">
          <div className={`p-8 bg-white rounded-[3rem] border-l-8 shadow-sm ${mode === 'collective' ? 'border-emerald-400' : `border-${agents[activeId].color}-400`}`}>
            <p className="text-sm leading-relaxed text-slate-700 font-medium">
              {mode === 'collective' 
                ? "The Hive is currently idling. All sub-systems (Dev, Arch, Data, Sec) are monitoring the Innisfil worker node." 
                : `Hello. I am ${agents[activeId].name}. ${agents[activeId].bio}`}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AgentHive;
