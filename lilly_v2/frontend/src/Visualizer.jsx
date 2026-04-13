import { useEffect } from "react";

export default function Visualization({ state }) {

  useEffect(() => {
    // hook for future animation logic
    console.log("AI STATE:", state);
  }, [state]);

  return (
    <div style={{
      height: 120,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: 14,
      color: "#999"
    }}>
      {state === "thinking" && "🧠 Lilly is processing..."}
      {state === "idle" && "⚪ Lilly is idle"}
      {state === "speaking" && "🔊 Lilly speaking"}
    </div>
  );
}
