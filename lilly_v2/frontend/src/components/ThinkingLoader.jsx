import React from 'react';

const ThinkingLoader = () => {
  return (
    <div className="flex items-center gap-1.5 px-3 py-2 bg-slate-100 rounded-full w-fit">
      <div className="w-2.5 h-2.5 bg-cyan-500 rounded-full animate-pulse [animation-delay:-0.3s]"></div>
      <div className="w-2.5 h-2.5 bg-cyan-500 rounded-full animate-pulse [animation-delay:-0.15s]"></div>
      <div className="w-2.5 h-2.5 bg-cyan-500 rounded-full animate-pulse"></div>
    </div>
  );
};

export default ThinkingLoader;
