import { useEffect,useRef } from "react"
import p5 from "p5"

export default function Visualizer({isSpeaking}){
  const ref=useRef()

  useEffect(()=>{
    const sketch=(p)=>{
      let t=0
      const baseRadius=180

      p.setup=()=>p.createCanvas(500,500)

      p.draw=()=>{
        p.background(255)
        p.translate(p.width/2,p.height/2)
        p.noFill()
        p.stroke(0)
        p.circle(0,0,baseRadius*2)

        p.beginShape()
        for(let a=0;a<p.TWO_PI;a+=0.1){
          let n=p.noise(Math.cos(a)+t,Math.sin(a)+t)
          let r=baseRadius+n*(isSpeaking?40:10)
          p.vertex(r*Math.cos(a),r*Math.sin(a))
        }
        p.endShape(p.CLOSE)

        t+=isSpeaking?0.08:0.01
      }
    }

    const instance=new p5(sketch,ref.current)
    return()=>instance.remove()
  },[isSpeaking])

  return <div ref={ref}></div>
}
