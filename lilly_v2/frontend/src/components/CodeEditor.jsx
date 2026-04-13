import React, { useState } from 'react';
import Editor from '@monaco-editor/react';

export default function CodeEditor({ initialCode, onCommit }) {
  const [code, setCode] = useState(initialCode);

  return (
    <div className="editor-window card bg-dark border-primary">
      <div className="card-header d-flex justify-content-between align-items-center">
        <span className="text-white">Live Forge Editor</span>
        <button className="btn btn-sm btn-success" onClick={() => onCommit(code)}>
          🚀 Commit to Production (8081)
        </button>
      </div>
      <Editor
        height="400px"
        defaultLanguage="javascript"
        theme="vs-dark"
        value={code}
        onChange={(value) => setCode(value)}
      />
    </div>
  );
}

