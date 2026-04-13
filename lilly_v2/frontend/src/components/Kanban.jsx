import React, { useState } from 'react';
import { Plus, Clock, CheckCircle2, User } from 'lucide-react';

const INITIAL_TASKS = [
  { id: 1, title: 'API Integration', status: 'todo', owner: 'Alpha' },
  { id: 2, title: 'Mobile UI Polish', status: 'doing', owner: 'Beta' },
  { id: 3, title: 'Database Schema', status: 'done', owner: 'Gamma' },
];

export default function Kanban() {
  const [tasks, setTasks] = useState(INITIAL_TASKS);

  const columns = [
    { id: 'todo', label: 'Backlog', icon: <Plus size={14}/> },
    { id: 'doing', label: 'In Progress', icon: <Clock size={14}/> },
    { id: 'done', label: 'Completed', icon: <CheckCircle2 size={14}/> }
  ];

  return (
    <div className="flex flex-col h-full bg-[var(--color-brand-bg)] p-4 overflow-x-auto">
      <div className="flex gap-4 h-full min-w-[600px] md:min-w-0">
        {columns.map(col => (
          <div key={col.id} className="flex-1 flex flex-col bg-black/20 border border-[var(--color-brand-border)] rounded-2xl p-3">
            <div className="flex items-center gap-2 mb-4 px-2">
              <span className="text-emerald-500">{col.icon}</span>
              <h3 className="text-[10px] font-black uppercase tracking-widest text-slate-400">{col.label}</h3>
            </div>
            
            <div className="space-y-3">
              {tasks.filter(t => t.status === col.id).map(task => (
                <div key={task.id} className="p-3 bg-[var(--color-brand-card)] border border-[var(--color-brand-border)] rounded-xl shadow-sm hover:border-emerald-500/30 transition-all cursor-pointer">
                  <p className="text-xs font-bold text-white mb-3">{task.title}</p>
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20">
                      <User size={10} className="text-emerald-500" />
                      <span className="text-[9px] font-bold text-emerald-500">{task.owner}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
