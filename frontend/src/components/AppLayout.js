import { useAuth } from "../context/AuthContext";

const navigation = [
  { path: "/", label: "화물 현황" },
  { path: "/shipments/new", label: "화물 등록" },
  { path: "/research", label: "상품 리서치" },
];

export default function AppLayout({ path, navigate, children }) {
  const { user, logout } = useAuth();
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
        {user && (
          <div className="workspace-card">
            <span>현재 조직</span>
            <strong>{user.organizationName}</strong>
            <small>{user.email} · {user.role}</small>
            <button onClick={logout}>로그아웃</button>
          </div>
        )}
      </aside>
      <main className="content">{children}</main>
    </div>
  );
}
