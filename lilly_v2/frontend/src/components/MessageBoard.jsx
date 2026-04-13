import React, { useState } from 'react';
import { Mail, MessageSquare, BookOpen, Clock, ChevronRight, Send } from 'lucide-react';

export default function MessageBoard({ messages, onOpenChat }) {
  return (
    <div className="flex-1 flex flex-col bg-black/40 backdrop-blur-xl rounded-3xl border border-white/10 overflow-hidden">
      <div className="p-4 border-b border-white/5 bg-zinc-900/50 flex justify-between items-center">
        <h3 className="text-[10px] font-black uppercase text-emerald-500 tracking-tighter flex items-center gap-2">
          <Mail size={14} /> User_Command_Inbox
        </h3>
        <span className="text-[9px] font-mono text-zinc-500 italic">Auto-Archiving to Email: Enabled</span>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-3 custom-scroll">
        {messages.map((msg) => (
          <div 
            key={msg.id} 
            onClick={() => onOpenChat(msg)}
            className="group p-4 bg-white/[0.03] border border-white/5 rounded-2xl hover:border-emerald-500/50 transition-all cursor-pointer relative overflow-hidden"
          >
            <div className="flex justify-between items-start mb-2">
              <div className="flex items-center gap-2">
                {msg.type === 'course' ? <BookOpen size={12} className="text-blue-400" /> : <MessageSquare size={12} className="text-emerald-500" />}
                <span className="text-[10px] font-black uppercase text-zinc-400">{msg.sender}</span>
              </div>
              <span className="text-[9px] font-mono text-zinc-600">{msg.time}</span>
            </div>
            <p className="text-sm text-zinc-300 font-medium leading-snug">{msg.subject}</p>
            <p className="text-[11px] text-zinc-500 mt-1 line-clamp-1">{msg.preview}</p>
            <ChevronRight size={14} className="absolute right-4 bottom-4 text-zinc-700 group-hover:text-emerald-500 transition-colors" />
          </div>
        ))}
      </div>
    </div>
  );
}
