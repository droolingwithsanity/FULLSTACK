import { useState } from "react"
import Visualizer from "./Visualizer"

export default function App(){
  const [isSpeaking,setIsSpeaking]=useState(false)
  const [persona,setPersona]=useState("You are Lilly.")
  const [message,setMessage]=useState("")

  const initAudio=(base64)=>{
    const audio=new Audio(base64)
    setIsSpeaking(true)
    audio.play()
    audio.onended=()=>setIsSpeaking(false)
  }

  const send=async()=>{
    const res=await fetch("/chat",{
      method:"POST",
      headers:{"Content-Type":"application/json"},
      body:JSON.stringify({message,persona})
    })
    const data=await res.json()
    initAudio(data.audio)
  }

  return(
    <div style={{padding:20}}>
      <h1>Lilly</h1>
      <Visualizer isSpeaking={isSpeaking}/>
      <textarea value={persona} onChange={e=>setPersona(e.target.value)}/>
      <input value={message} onChange={e=>setMessage(e.target.value)}/>
      <button onClick={send}>Speak</button>
    </div>
  )
}
