import React from 'react';

const LilSysStatus = ({ isOnline, isProcessing }) => {
  // Logic for the Status Ring
  let statusColor = "border-emerald-500"; // Green: Optimal
  let shadowColor = "shadow-emerald-500/20";
  let label = "Optimal";

  if (!isOnline) {
    statusColor = "border-rose-500 animate-pulse"; // Red: Issues
    shadowColor = "shadow-rose-500/40";
    label = "Critical";
  } else if (isProcessing) {
    statusColor = "border-blue-500 animate-spin-slow"; // Blue: Resources
    shadowColor = "shadow-blue-500/40";
    label = "Active";
  }

  return (
    <div className="relative group cursor-help">
      {/* Outer Status Ring */}
      <div className={`w-14 h-14 rounded-full border-4 ${statusColor} ${shadowColor} shadow-lg flex items-center justify-center transition-all duration-500`}>
        {/* Core Lil-sys Icon */}
        <div className="w-10 h-10 bg-slate-900 rounded-full flex items-center justify-center text-[10px] font-black text-white overflow-hidden border border-white/10">
           <img 
            src="/Agent1.png" 
            className="w-full h-full object-cover opacity-80" 
            alt="Lil-sys"
            onError={(e) => { e.target.style.display = 'none'; }}
           />
           <span className="absolute">LS</span>
        </div>
      </div>

      {/* Hover Status Label */}
      <div className="absolute top-16 left-1/2 -translate-x-1/2 px-3 py-1 bg-slate-900 text-white text-[8px] font-black uppercase tracking-[0.2em] rounded-lg opacity-0 group-hover:opacity-100 transition-all whitespace-nowrap z-50">
        Lil-sys: {label}
      </div>
    </div>
  );
};

export default LilSysStatus;
