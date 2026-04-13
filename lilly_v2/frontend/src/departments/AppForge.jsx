import React, { useState } from 'react';
import { Hammer, Play, Download, CheckCircle } from 'lucide-react';

export default function AppForge() {
  const [status, setStatus] = useState('Idle');

  const startForge = async () => {
    setStatus('Forging...');
    // API Call to backend/forge/create would go here
    setTimeout(() => setStatus('Ready on Port 8081'), 3000);
  };

  return (
    <div className="p-12 text-white bg-zinc-950 h-full">
      <h1 className="text-4xl font-black uppercase italic mb-8 flex items-center gap-4">
        <Hammer className="text-emerald-500" /> App_Forge_B44
      </h1>
      <div className="bg-white/5 border border-white/10 p-8 rounded-[3rem]">
        <p className="text-zinc-500 mb-6 font-mono text-sm">Design and create new entities for the LillyOS ecosystem.</p>
        <button onClick={startForge} className="bg-emerald-500 text-black px-8 py-4 rounded-2xl font-black uppercase flex items-center gap-3 hover:scale-105 transition-all">
          <Play size={18} /> Execute_Creativity
        </button>
        
        {status !== 'Idle' && (
          <div className="mt-8 p-6 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex justify-between items-center animate-in zoom-in-95">
             <div className="flex items-center gap-4">
               <CheckCircle className="text-emerald-500" />
               <div>
                 <p className="font-black text-xs uppercase">{status}</p>
                 <a href="http://localhost:8081" target="_blank" className="text-[10px] text-zinc-500 underline">View Live Preview</a>
               </div>
             </div>
             <button className="bg-white/10 p-3 rounded-xl hover:bg-white/20"><Download size={16}/></button>
          </div>
        )}
      </div>
    </div>
  );
}
