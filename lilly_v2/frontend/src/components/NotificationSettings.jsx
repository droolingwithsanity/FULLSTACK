import React from 'react';

export const NOTIF_TYPES = {
  FORGE: 'Forge Status',
  JANITOR: 'Cleanup Logs',
  NODE: 'Cluster Health',
  GIT: 'Deployment'
};

export default function NotificationToggles({ filters, setFilters }) {
  return (
    <div className="p-6 bg-white border border-[#e6e2d3] rounded-[32px] mb-8">
      <h4 className="text-[10px] font-bold uppercase tracking-widest opacity-40 mb-4">Signal Filters</h4>
      <div className="grid grid-cols-2 gap-3">
        {Object.entries(NOTIF_TYPES).map(([key, label]) => (
          <button
            key={key}
            onClick={() => setFilters(prev => ({...prev, [key]: !prev[key]}))}
            className={`px-4 py-2 rounded-full text-[10px] font-bold border transition-all ${
              filters[key] ? 'bg-slate-900 text-white border-slate-900' : 'bg-white text-slate-400 border-[#e6e2d3]'
            }`}
          >
            {label}
          </button>
        ))}
      </div>
    </div>
  );
}
