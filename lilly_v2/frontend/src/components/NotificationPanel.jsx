import React from 'react';
import { X, Bell, CheckCircle, AlertTriangle } from 'lucide-react';

export default function NotificationPanel({ isOpen, onClose, alerts }) {
  return (
    <div className={`fixed inset-y-0 right-0 w-80 bg-[#0a0a0a] border-l border-white/10 z-[200] transform transition-transform duration-300 shadow-2xl ${isOpen ? 'translate-x-0' : 'translate-x-full'}`}>
      <div className="p-6 h-full flex flex-col">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-xs font-black uppercase tracking-widest text-emerald-500 flex items-center gap-2">
            <Bell size={14}/> Activity_Stream
          </h2>
          <button onClick={onClose} className="p-2 hover:bg-white/5 rounded-full text-zinc-500"><X size={18}/></button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-4 no-scrollbar">
          {alerts.length === 0 ? (
            <div className="text-center py-20 text-zinc-600 text-[10px] uppercase font-bold">No new pings.</div>
          ) : (
            alerts.map((a, i) => (
              <div key={i} className="p-4 rounded-2xl bg-white/5 border border-white/5 animate-in slide-in-from-right">
                <div className="flex gap-3">
                  <div className="mt-1">{a.type === 'success' ? <CheckCircle size={14} className="text-emerald-500"/> : <AlertTriangle size={14} className="text-orange-500"/>}</div>
                  <div>
                    <p className="text-[11px] font-bold text-white leading-tight">{a.message}</p>
                    <p className="text-[9px] text-zinc-500 mt-1 font-mono uppercase">{a.time}</p>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
        
        <button className="w-full py-3 bg-white/5 hover:bg-white/10 rounded-xl text-[10px] font-black uppercase text-zinc-400 transition-all border border-white/5">
          Clear All History
        </button>
      </div>
    </div>
  );
}
