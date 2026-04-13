import React, { useState, createContext, useContext } from 'react';

const NotificationContext = createContext();

export const NotificationProvider = ({ children }) => {
  const [notifs, setNotifs] = useState([]);
  const notify = (msg, type = 'info') => {
    const id = Date.now();
    setNotifs(prev => [...prev, { id, msg, type }]);
    setTimeout(() => setNotifs(prev => prev.filter(n => n.id !== id)), 5000);
  };
  return (
    <NotificationContext.Provider value={notify}>
      {children}
      <div className="fixed top-4 right-4 z-50 flex flex-col gap-2">
        {notifs.map(n => (
          <div key={n.id} className="p-4 rounded-lg bg-white shadow-lg border border-slate-200 text-xs font-bold">
            {n.msg}
          </div>
        ))}
      </div>
    </NotificationContext.Provider>
  );
};

export const useNotify = () => useContext(NotificationContext);
