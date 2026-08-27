import { createContext, useContext, useMemo, useState } from "react";

const STORAGE_KEY = "trade-operation-workspace";
const WorkspaceContext = createContext(null);

function loadWorkspace() {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY)); } catch { return null; }
}

export function WorkspaceProvider({ children }) {
  const [workspace, setWorkspaceState] = useState(loadWorkspace);
  const setWorkspace = (value) => {
    setWorkspaceState(value);
    if (value) localStorage.setItem(STORAGE_KEY, JSON.stringify(value));
    else localStorage.removeItem(STORAGE_KEY);
  };
  const value = useMemo(() => ({ workspace, setWorkspace }), [workspace]);
  return <WorkspaceContext.Provider value={value}>{children}</WorkspaceContext.Provider>;
}

export function useWorkspace() {
  const context = useContext(WorkspaceContext);
  if (!context) throw new Error("WorkspaceProvider가 필요합니다.");
  return context;
}
