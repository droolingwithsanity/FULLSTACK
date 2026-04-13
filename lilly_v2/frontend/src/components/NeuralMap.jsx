import React, { useState, useEffect } from 'react';
import ForceGraph2D from 'react-force-graph-2d';

export default function NeuralMap() {
  const [data, setData] = useState({ 
    nodes: [{ id: 'Master', name: 'Lilly_Syncing...', group: 1, val: 20 }], 
    links: [] 
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        // We use the host IP or localhost to bridge the Docker gap
        const response = await fetch('http://localhost:4001/api/topology');
        if (!response.ok) throw new Error("API_OFFLINE");
        const json = await response.json();
        setData(json);
      } catch (err) {
        console.warn("Using_Static_Topology_Fallback");
        setData({
          nodes: [
            { id: 'Master', name: 'Lilly_Master', group: 1, val: 20 },
            { id: 'Offline', name: 'Watcher_Offline', group: 3, status: 'exited', val: 10 }
          ],
          links: [{ source: 'Master', target: 'Offline' }]
        });
      }
    };

    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="h-[500px] w-full bg-[#050505] border border-white/5 rounded-[40px] overflow-hidden relative shadow-2xl shadow-orange-600/5">
      <ForceGraph2D
        graphData={data}
        nodeLabel="name"
        backgroundColor="rgba(0,0,0,0)"
        linkColor={() => 'rgba(234, 88, 12, 0.2)'}
        nodeCanvasObject={(node, ctx, globalScale) => {
          const label = node.name;
          const fontSize = 12/globalScale;
          ctx.font = `${fontSize}px "Inter", sans-serif`;
          ctx.textAlign = 'center';
          ctx.fillStyle = node.group === 1 ? '#ea580c' : 'rgba(255,255,255,0.4)';
          ctx.fillText(label, node.x, node.y + 14);
          
          ctx.beginPath();
          ctx.arc(node.x, node.y, 5, 0, 2 * Math.PI, false);
          ctx.fillStyle = node.group === 1 ? '#ea580c' : (node.status === 'running' ? '#22c55e' : '#ef4444');
          ctx.fill();
          
          if (node.group === 1) {
            ctx.shadowBlur = 15;
            ctx.shadowColor = '#ea580c';
          }
        }}
      />
      <div className="absolute top-6 left-6 pointer-events-none">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 bg-orange-600 rounded-full animate-ping" />
          <p className="text-[8px] font-black text-orange-600 uppercase tracking-[0.4em]">Neural_Link_Established</p>
        </div>
      </div>
    </div>
  );
}
