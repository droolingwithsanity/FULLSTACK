/* Helper component for the Dossier View */
export const DossierStats = ({ agent, specialties }) => (
  <div className="grid grid-cols-2 gap-4 mt-6">
    <div className="p-4 bg-white/5 border border-white/10 rounded-2xl">
      <span className="text-[9px] font-black text-zinc-500 uppercase">Specialty_Field</span>
      <select className="w-full bg-transparent text-emerald-500 text-sm outline-none border-none">
        {specialties.map(s => <option key={s} value={s}>{s}</option>)}
      </select>
    </div>
    <div className="p-4 bg-white/5 border border-white/10 rounded-2xl">
      <span className="text-[9px] font-black text-zinc-500 uppercase">Node_Ping</span>
      <p className="text-sm font-mono text-white">12ms</p>
    </div>
  </div>
);
