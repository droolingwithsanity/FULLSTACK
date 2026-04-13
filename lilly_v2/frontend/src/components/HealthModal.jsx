import React from 'react';
import { X, Cpu, HardDrive, Thermometer } from 'lucide-react';

export default function HealthModal({ onClose }) {
  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in">
      <div className="w-full max-w-sm bg-[var(--color-brand-card)] border border-[var(--color-brand-border)] rounded-3xl p-6 shadow-2xl">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-sm font-black uppercase tracking-widest text-white">Node_Vitals</h2>
          <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-full"><X size={18}/></button>
        </div>
        
        <div className="space-y-4">
          <div className="flex justify-between items-center p-3 rounded-xl bg-black/40 border border-white/5">
            <div className="flex items-center gap-3 text-emerald-500"><Cpu size={16}/> <span className="text-xs font-bold uppercase">CPU_Load</span></div>
            <span className="text-xs font-mono text-white">12%</span>
          </div>
          <div className="flex justify-between items-center p-3 rounded-xl bg-black/40 border border-white/5">
            <div className="flex items-center gap-3 text-blue-500"><HardDrive size={16}/> <span className="text-xs font-bold uppercase">RAM_Usage</span></div>
            <span className="text-xs font-mono text-white">4.2GB</span>
          </div>
          <div className="flex justify-between items-center p-3 rounded-xl bg-black/40 border border-white/5">
            <div className="flex items-center gap-3 text-orange-500"><Thermometer size={16}/> <span className="text-xs font-bold uppercase">Temp</span></div>
            <span className="text-xs font-mono text-white">42°C</span>
          </div>
        </div>
        
        <div className="mt-6 pt-4 border-t border-[var(--color-brand-border)] text-[10px] text-center text-slate-600 font-mono">
          Uptime: 14h 22m 11s // Innisfil_Node_01
        </div>
      </div>
    </div>
  );
}
