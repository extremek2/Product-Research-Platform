import { useWorkspace } from "../context/WorkspaceContext";

const navigation = [
  { path: "/", label: "화물 현황" },
  { path: "/shipments/new", label: "화물 등록" },
  { path: "/research", label: "상품 리서치" },
];

export default function AppLayout({ path, navigate, children }) {
  const { workspace, setWorkspace } = useWorkspace();
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <button className="brand" onClick={() => navigate("/")}>
          <span className="brand-mark">T</span>
          <span>Trade Ops<small>B/L operation hub</small></span>
        </button>
        <nav>
          {navigation.map((item) => (
            <button key={item.path} className={`nav-link ${path === item.path ? "active" : ""}`}
                    onClick={() => navigate(item.path)}>{item.label}</button>
          ))}
        </nav>
        {workspace && (
          <div className="workspace-card">
            <span>현재 조직</span>
            <strong>{workspace.organizationName}</strong>
            <small>{workspace.ownerEmail}</small>
            <button onClick={() => setWorkspace(null)}>조직 전환</button>
          </div>
        )}
      </aside>
      <main className="content">{children}</main>
    </div>
  );
}
