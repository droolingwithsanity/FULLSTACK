import React, { useState } from "react";

import Sidebar from "./components/Sidebar";
import LilSysStatus from "./components/LilSysStatus";

import Warroom from "./departments/Warroom";
import AgentHive from "./departments/AgentHive";
import AppForge from "./departments/AppForge";

export default function App() {
  const [dept, setDept] = useState("warroom");
  const [isProcessing, setIsProcessing] = useState(false);
  const isOnline = true;

  return (
    <div className={`h-screen w-screen flex p-6 gap-6 overflow-hidden font-sans transition-colors duration-500 ${
      dept === "warroom" ? "bg-black" : "bg-[#f0f2f5]"
    }`}>

      {/* SIDEBAR */}
      <Sidebar isOnline={isOnline} />

      {/* NAV PANEL */}
      <aside className={`w-64 rounded-[3.5rem] border flex flex-col p-8 shrink-0 relative transition-all ${
        dept === "warroom"
          ? "bg-zinc-900 border-white/10 text-white"
          : "bg-white border-white shadow-2xl text-slate-900"
      }`}>

        <div className="flex items-center gap-3 mb-10 text-xl font-black italic tracking-tighter">
          <div className="w-10 h-10 bg-emerald-500 rounded-2xl flex items-center justify-center text-black shadow-xl text-[10px] font-black">
            L-OS
          </div>
          LillyOS
        </div>

        <nav className="flex-1 space-y-3">
          {[
            { id: "warroom", label: "War Room", icon: "📡" },
            { id: "hive", label: "Agent Hive", icon: "🐝" },
            { id: "forge", label: "App Forge", icon: "⚒️" }
          ].map((item) => (
            <button
              key={item.id}
              onClick={() => setDept(item.id)}
              className={`w-full flex items-center justify-between px-6 py-4 rounded-2xl transition-all duration-300 ${
                dept === item.id
                  ? "bg-emerald-500 text-black shadow-2xl scale-105"
                  : "text-zinc-500 hover:bg-white/5"
              }`}
            >
              <span className="text-[10px] font-black uppercase tracking-widest">
                {item.label}
              </span>
              <span className="text-xs">{item.icon}</span>
            </button>
          ))}
        </nav>
      </aside>

      {/* MAIN WORKSPACE */}
      <main className={`flex-1 flex flex-col min-w-0 rounded-[4rem] border shadow-inner overflow-hidden relative transition-all ${
        dept === "warroom"
          ? "bg-transparent border-white/5"
          : "bg-zinc-950 border-white/50"
      }`}>

        {/* SYSTEM STATUS */}
        <div className="absolute top-8 right-10 z-50">
          <LilSysStatus
            isOnline={isOnline}
            isProcessing={isProcessing}
          />
        </div>

        {/* ROUTING */}
        <div className="absolute inset-0">
          {dept === "warroom" && (
            <Warroom
              isOnline={isOnline}
              setGlobalProcessing={setIsProcessing}
            />
          )}

          {dept === "hive" && (
            <AgentHive
              isOnline={isOnline}
              setGlobalProcessing={setIsProcessing}
            />
          )}

          {dept === "forge" && (
            <AppForge isOnline={isOnline} />
          )}
        </div>
      </main>
    </div>
  );
}
