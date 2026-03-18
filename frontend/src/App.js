import { useState, useEffect, useCallback } from "react";

const API = "http://localhost:8000/api/v1";
const SPRING = "http://localhost:8080/api/v1";

const styles = `
  @import url('https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Syne:wght@400;600;700;800&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg: #0a0a0f;
    --bg2: #12121a;
    --bg3: #1a1a26;
    --border: rgba(255,255,255,0.07);
    --border-bright: rgba(255,255,255,0.15);
    --accent: #7c6dfa;
    --accent2: #fa6d6d;
    --accent3: #6dfabd;
    --text: #f0f0f8;
    --muted: #6b6b88;
    --mono: 'DM Mono', monospace;
    --sans: 'Syne', sans-serif;
  }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: var(--sans);
    min-height: 100vh;
    overflow-x: hidden;
  }

  .app {
    display: flex;
    min-height: 100vh;
  }

  /* Sidebar */
  .sidebar {
    width: 220px;
    flex-shrink: 0;
    background: var(--bg2);
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    padding: 28px 0;
    position: fixed;
    top: 0; left: 0; bottom: 0;
    z-index: 10;
  }

  .sidebar-logo {
    padding: 0 24px 32px;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    color: var(--accent);
    font-family: var(--mono);
  }

  .sidebar-logo span {
    display: block;
    font-size: 10px;
    color: var(--muted);
    font-weight: 400;
    margin-top: 4px;
    letter-spacing: 0.1em;
  }

  .nav-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 11px 24px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    color: var(--muted);
    transition: all 0.15s;
    border-left: 2px solid transparent;
    letter-spacing: 0.02em;
  }

  .nav-item:hover { color: var(--text); background: rgba(255,255,255,0.03); }
  .nav-item.active { color: var(--text); border-left-color: var(--accent); background: rgba(124,109,250,0.08); }

  .nav-dot {
    width: 6px; height: 6px;
    border-radius: 50%;
    background: currentColor;
    flex-shrink: 0;
  }

  .nav-item.active .nav-dot { background: var(--accent); box-shadow: 0 0 8px var(--accent); }

  /* Main */
  .main {
    margin-left: 220px;
    flex: 1;
    padding: 40px 48px;
    max-width: calc(100vw - 220px);
  }

  .page-header {
    margin-bottom: 40px;
  }

  .page-title {
    font-size: 32px;
    font-weight: 800;
    letter-spacing: -0.02em;
    line-height: 1;
    margin-bottom: 8px;
  }

  .page-sub {
    font-size: 13px;
    color: var(--muted);
    font-family: var(--mono);
  }

  /* Cards grid */
  .cards-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-bottom: 32px;
  }

  .stat-card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px;
    position: relative;
    overflow: hidden;
    transition: border-color 0.2s;
  }

  .stat-card:hover { border-color: var(--border-bright); }

  .stat-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 2px;
  }

  .stat-card.c1::before { background: var(--accent); }
  .stat-card.c2::before { background: var(--accent2); }
  .stat-card.c3::before { background: var(--accent3); }
  .stat-card.c4::before { background: #fad96d; }

  .stat-label {
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--muted);
    font-family: var(--mono);
    margin-bottom: 12px;
  }

  .stat-value {
    font-size: 36px;
    font-weight: 800;
    letter-spacing: -0.03em;
    line-height: 1;
    margin-bottom: 6px;
  }

  .stat-meta {
    font-size: 11px;
    color: var(--muted);
    font-family: var(--mono);
  }

  /* Section */
  .section {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: 12px;
    margin-bottom: 20px;
    overflow: hidden;
  }

  .section-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 18px 24px;
    border-bottom: 1px solid var(--border);
  }

  .section-title {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--muted);
    font-family: var(--mono);
  }

  .section-body { padding: 24px; }

  /* Trigger buttons */
  .trigger-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }

  .trigger-btn {
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 18px 20px;
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    text-align: left;
    font-family: var(--sans);
  }

  .trigger-btn:hover:not(:disabled) {
    border-color: var(--accent);
    background: rgba(124,109,250,0.08);
  }

  .trigger-btn:disabled { opacity: 0.5; cursor: not-allowed; }

  .trigger-btn-label {
    font-size: 13px;
    font-weight: 700;
    color: var(--text);
    letter-spacing: 0.02em;
  }

  .trigger-btn-sub {
    font-size: 11px;
    color: var(--muted);
    font-family: var(--mono);
  }

  .trigger-status {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 10px;
    font-family: var(--mono);
    font-weight: 500;
    padding: 3px 8px;
    border-radius: 4px;
    margin-top: 4px;
  }

  .trigger-status.idle { background: rgba(107,107,136,0.2); color: var(--muted); }
  .trigger-status.running { background: rgba(124,109,250,0.2); color: var(--accent); }
  .trigger-status.done { background: rgba(109,250,189,0.2); color: var(--accent3); }
  .trigger-status.error { background: rgba(250,109,109,0.2); color: var(--accent2); }

  .pulse {
    width: 6px; height: 6px;
    border-radius: 50%;
    background: currentColor;
    animation: pulse 1s infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
  }

  /* Keywords */
  .keyword-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .keyword-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 6px;
    font-size: 12px;
    font-family: var(--mono);
    font-weight: 500;
    color: var(--text);
    transition: all 0.15s;
  }

  .keyword-chip:hover {
    border-color: var(--accent);
    color: var(--accent);
    cursor: pointer;
  }

  .keyword-chip .kw-num {
    font-size: 10px;
    color: var(--muted);
  }

  /* Cluster vis */
  .cluster-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .cluster-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.15s;
  }

  .cluster-row:hover { border-color: var(--border-bright); }
  .cluster-row.expanded { border-color: var(--accent); }

  .cluster-name {
    font-size: 12px;
    font-family: var(--mono);
    font-weight: 500;
    color: var(--muted);
    width: 120px;
    flex-shrink: 0;
  }

  .cluster-bar-wrap {
    flex: 1;
    height: 6px;
    background: var(--bg);
    border-radius: 3px;
    overflow: hidden;
  }

  .cluster-bar {
    height: 100%;
    border-radius: 3px;
    background: var(--accent);
    transition: width 0.5s ease;
  }

  .cluster-count {
    font-size: 11px;
    font-family: var(--mono);
    color: var(--muted);
    width: 40px;
    text-align: right;
    flex-shrink: 0;
  }

  .cluster-items {
    padding: 8px 16px 14px;
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }

  .cluster-item-tag {
    font-size: 11px;
    padding: 4px 8px;
    background: rgba(124,109,250,0.1);
    border: 1px solid rgba(124,109,250,0.2);
    border-radius: 4px;
    color: var(--text);
    font-family: var(--mono);
  }

  /* Table */
  .search-row {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
  }

  .search-input {
    flex: 1;
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 10px 16px;
    color: var(--text);
    font-family: var(--mono);
    font-size: 13px;
    outline: none;
    transition: border-color 0.15s;
  }

  .search-input:focus { border-color: var(--accent); }
  .search-input::placeholder { color: var(--muted); }

  .filter-select {
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 10px 14px;
    color: var(--text);
    font-family: var(--mono);
    font-size: 12px;
    outline: none;
    cursor: pointer;
  }

  .table-wrap {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  th {
    text-align: left;
    padding: 10px 14px;
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--muted);
    font-family: var(--mono);
    border-bottom: 1px solid var(--border);
  }

  td {
    padding: 12px 14px;
    border-bottom: 1px solid rgba(255,255,255,0.04);
    font-size: 12px;
    font-family: var(--mono);
    vertical-align: middle;
  }

  tr:hover td { background: rgba(255,255,255,0.02); }

  .badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 600;
    letter-spacing: 0.05em;
    text-transform: uppercase;
  }

  .badge-brand { background: rgba(124,109,250,0.15); color: var(--accent); border: 1px solid rgba(124,109,250,0.25); }
  .badge-source { background: rgba(109,250,189,0.1); color: var(--accent3); border: 1px solid rgba(109,250,189,0.2); }

  .pagination {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 0 0;
    font-size: 12px;
    font-family: var(--mono);
    color: var(--muted);
  }

  .page-btns { display: flex; gap: 6px; }

  .page-btn {
    padding: 6px 12px;
    background: var(--bg3);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-family: var(--mono);
    font-size: 12px;
    cursor: pointer;
    transition: all 0.15s;
  }

  .page-btn:hover:not(:disabled) { border-color: var(--accent); color: var(--accent); }
  .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }

  /* Toast */
  .toast {
    position: fixed;
    bottom: 24px;
    right: 24px;
    background: var(--bg2);
    border: 1px solid var(--border-bright);
    border-radius: 10px;
    padding: 14px 18px;
    font-size: 13px;
    font-family: var(--mono);
    z-index: 100;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.4);
    animation: slideUp 0.3s ease;
  }

  @keyframes slideUp {
    from { transform: translateY(20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
  }

  .toast.success { border-color: rgba(109,250,189,0.3); }
  .toast.error { border-color: rgba(250,109,109,0.3); }

  .empty {
    text-align: center;
    padding: 48px;
    color: var(--muted);
    font-family: var(--mono);
    font-size: 13px;
  }

  .spinner {
    width: 16px; height: 16px;
    border: 2px solid var(--border);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
    display: inline-block;
  }

  @keyframes spin { to { transform: rotate(360deg); } }

  .two-col {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 20px;
  }

  .layout-row {
    display: grid;
    grid-template-columns: 1fr 1.4fr;
    gap: 20px;
    margin-bottom: 20px;
  }
`;

// ─── API helpers ────────────────────────────────────────────────
async function fetchProducts(keyword = "", brand = "") {
  let url = `${SPRING}/products`;
  if (keyword) url = `${SPRING}/products/search?keyword=${encodeURIComponent(keyword)}`;
  else if (brand) url = `${SPRING}/products/brand/${encodeURIComponent(brand)}`;
  const r = await fetch(url);
  const j = await r.json();
  return j.data || [];
}

async function fetchClusters() {
  const r = await fetch(`${SPRING}/clusters`);
  const j = await r.json();
  return j.data || [];
}

async function fetchClusterItems(id) {
  const r = await fetch(`${SPRING}/clusters/${id}/items`);
  const j = await r.json();
  return j.data || [];
}

async function triggerTask(type, keyword = "") {
  let url, body;
  if (type === "trend") {
    url = `${API}/trend/trigger`;
    body = {};
  } else if (type === "crawl") {
    url = `${API}/crawl/trigger`;
    body = { keyword: keyword || "로봇청소기" };
  } else {
    url = `${API}/cluster/trigger`;
    body = {};
  }
  const r = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  return await r.json();
}

async function pollStatus(type, taskId) {
  const endpoint = type === "crawl" ? "crawl" : type === "trend" ? "trend" : "cluster";
  const r = await fetch(`${API}/${endpoint}/status/${taskId}`);
  return await r.json();
}

// ─── Toast ──────────────────────────────────────────────────────
function Toast({ msg, type, onClose }) {
  useEffect(() => {
    const t = setTimeout(onClose, 3500);
    return () => clearTimeout(t);
  }, []);
  return (
    <div className={`toast ${type}`}>
      <span style={{ color: type === "success" ? "var(--accent3)" : "var(--accent2)" }}>
        {type === "success" ? "✓" : "✗"}
      </span>
      {msg}
    </div>
  );
}

// ─── Dashboard Page ──────────────────────────────────────────────
function Dashboard({ onNavigate }) {
  const [products, setProducts] = useState([]);
  const [clusters, setClusters] = useState([]);
  const [clusterItems, setClusterItems] = useState({});
  const [expandedCluster, setExpandedCluster] = useState(null);
  const [taskStatus, setTaskStatus] = useState({ trend: "idle", crawl: "idle", cluster: "idle" });
  const [toast, setToast] = useState(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [p, c] = await Promise.all([fetchProducts(), fetchClusters()]);
      setProducts(p);
      setClusters(c);
    } catch (e) {
      setToast({ msg: "API 연결 실패. 서버 확인 필요", type: "error" });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const handleTrigger = async (type) => {
    setTaskStatus(s => ({ ...s, [type]: "running" }));
    try {
      const res = await triggerTask(type);
      const taskId = res.task_id;
      // Poll every 2s up to 30s
      let tries = 0;
      const poll = async () => {
        tries++;
        const status = await pollStatus(type, taskId);
        if (status.status === "SUCCESS") {
          setTaskStatus(s => ({ ...s, [type]: "done" }));
          setToast({ msg: `${type} 완료!`, type: "success" });
          load();
          setTimeout(() => setTaskStatus(s => ({ ...s, [type]: "idle" })), 4000);
        } else if (status.status === "FAILURE") {
          setTaskStatus(s => ({ ...s, [type]: "error" }));
          setToast({ msg: `${type} 실패`, type: "error" });
          setTimeout(() => setTaskStatus(s => ({ ...s, [type]: "idle" })), 4000);
        } else if (tries < 15) {
          setTimeout(poll, 2000);
        }
      };
      setTimeout(poll, 1500);
    } catch {
      setTaskStatus(s => ({ ...s, [type]: "error" }));
      setToast({ msg: "트리거 실패", type: "error" });
    }
  };

  const toggleCluster = async (cluster) => {
    if (expandedCluster === cluster.id) { setExpandedCluster(null); return; }
    setExpandedCluster(cluster.id);
    if (!clusterItems[cluster.id]) {
      const items = await fetchClusterItems(cluster.id);
      setClusterItems(s => ({ ...s, [cluster.id]: items }));
    }
  };

  const brands = [...new Set(products.map(p => p.brand).filter(Boolean))];
  const sources = [...new Set(products.map(p => p.source).filter(Boolean))];
  const maxClusterSize = Math.max(...clusters.map(c => c.itemCount || 1), 1);

  // Fake trend keywords from product titles
  const keywords = ["로봇청소기", "견과류", "에어프라이어", "냄비", "가전"];

  const StatusBadge = ({ s }) => (
    <span className={`trigger-status ${s}`}>
      {s === "running" && <span className="pulse" />}
      {s === "idle" ? "대기" : s === "running" ? "실행중" : s === "done" ? "완료" : "오류"}
    </span>
  );

  return (
    <>
      <div className="page-header">
        <div className="page-title">대시보드</div>
        <div className="page-sub">product-research-platform — {new Date().toLocaleDateString("ko-KR")}</div>
      </div>

      {/* Stats */}
      <div className="cards-grid">
        <div className="stat-card c1">
          <div className="stat-label">수집 상품</div>
          <div className="stat-value">{loading ? "—" : products.length}</div>
          <div className="stat-meta">source_product 기준</div>
        </div>
        <div className="stat-card c2">
          <div className="stat-label">클러스터</div>
          <div className="stat-value">{loading ? "—" : clusters.length}</div>
          <div className="stat-meta">유사 상품 그룹</div>
        </div>
        <div className="stat-card c3">
          <div className="stat-label">브랜드</div>
          <div className="stat-value">{loading ? "—" : brands.length}</div>
          <div className="stat-meta">{brands.slice(0, 3).join(", ")}</div>
        </div>
        <div className="stat-card c4">
          <div className="stat-label">데이터 소스</div>
          <div className="stat-value">{loading ? "—" : sources.length}</div>
          <div className="stat-meta">{sources.join(", ")}</div>
        </div>
      </div>

      {/* Triggers + Keywords */}
      <div className="two-col">
        <div className="section">
          <div className="section-head">
            <span className="section-title">파이프라인 트리거</span>
            <button
              style={{ background: "none", border: "1px solid var(--border)", borderRadius: 6, padding: "4px 10px", color: "var(--muted)", fontSize: 11, cursor: "pointer", fontFamily: "var(--mono)" }}
              onClick={load}
            >↻ 새로고침</button>
          </div>
          <div className="section-body">
            <div className="trigger-grid">
              {[
                { key: "trend", label: "트렌드 수집", sub: "데이터랩 → 키워드 추출" },
                { key: "crawl", label: "상품 크롤링", sub: "네이버 쇼핑 API" },
                { key: "cluster", label: "클러스터링", sub: "임베딩 + cosine" },
              ].map(({ key, label, sub }) => (
                <button
                  key={key}
                  className="trigger-btn"
                  onClick={() => handleTrigger(key)}
                  disabled={taskStatus[key] === "running"}
                >
                  <div className="trigger-btn-label">{label}</div>
                  <div className="trigger-btn-sub">{sub}</div>
                  <StatusBadge s={taskStatus[key]} />
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="section">
          <div className="section-head">
            <span className="section-title">트렌드 키워드</span>
            <span style={{ fontSize: 10, fontFamily: "var(--mono)", color: "var(--muted)" }}>최근 수집 기준</span>
          </div>
          <div className="section-body">
            <div className="keyword-grid">
              {keywords.map((kw, i) => (
                <div key={kw} className="keyword-chip" onClick={() => onNavigate("products", kw)}>
                  <span>{kw}</span>
                  <span className="kw-num">#{i + 1}</span>
                </div>
              ))}
              {products.length > 0 && brands.map(b => (
                <div key={b} className="keyword-chip" onClick={() => onNavigate("products", b)}>
                  <span>{b}</span>
                  <span className="kw-num" style={{ color: "var(--accent)" }}>brand</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Clusters */}
      <div className="section">
        <div className="section-head">
          <span className="section-title">클러스터 현황</span>
          <span
            style={{ fontSize: 11, fontFamily: "var(--mono)", color: "var(--accent)", cursor: "pointer" }}
            onClick={() => onNavigate("products")}
          >상품 목록 보기 →</span>
        </div>
        <div className="section-body">
          {loading ? (
            <div className="empty"><span className="spinner" /></div>
          ) : clusters.length === 0 ? (
            <div className="empty">클러스터 없음. 클러스터링을 실행하세요.</div>
          ) : (
            <div className="cluster-list">
              {clusters.slice(0, 15).map((c) => (
                <div key={c.id}>
                  <div
                    className={`cluster-row ${expandedCluster === c.id ? "expanded" : ""}`}
                    onClick={() => toggleCluster(c)}
                  >
                    <div className="cluster-name">{c.clusterName || `cluster_${c.id}`}</div>
                    <div className="cluster-bar-wrap">
                      <div className="cluster-bar" style={{ width: `${((c.itemCount || 1) / maxClusterSize) * 100}%` }} />
                    </div>
                    <div className="cluster-count">{c.itemCount || "—"}</div>
                    <div style={{ fontSize: 10, color: "var(--muted)", fontFamily: "var(--mono)", width: 16 }}>
                      {expandedCluster === c.id ? "▾" : "▸"}
                    </div>
                  </div>
                  {expandedCluster === c.id && clusterItems[c.id] && (
                    <div className="cluster-items">
                      {clusterItems[c.id].map((item, idx) => (
                        <div key={idx} className="cluster-item-tag">
                          {item.product?.title
                            ? item.product.title.slice(0, 24) + (item.product.title.length > 24 ? "…" : "")
                            : `product_${item.productId}`}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {toast && <Toast msg={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </>
  );
}

// ─── Products Page ───────────────────────────────────────────────
function Products({ initialKeyword = "" }) {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState(initialKeyword);
  const [brandFilter, setBrandFilter] = useState("");
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 20;

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchProducts(search, brandFilter);
      setProducts(data);
      setPage(0);
    } finally {
      setLoading(false);
    }
  }, [search, brandFilter]);

  useEffect(() => { load(); }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    load();
  };

  const brands = [...new Set(products.map(p => p.brand).filter(Boolean))];
  const paged = products.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);
  const totalPages = Math.ceil(products.length / PAGE_SIZE);

  return (
    <>
      <div className="page-header">
        <div className="page-title">상품 목록</div>
        <div className="page-sub">Spring Boot API — {products.length}건</div>
      </div>

      <div className="section">
        <div className="section-body">
          <form className="search-row" onSubmit={handleSearch}>
            <input
              className="search-input"
              placeholder="상품명 검색..."
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            <select
              className="filter-select"
              value={brandFilter}
              onChange={e => { setBrandFilter(e.target.value); }}
            >
              <option value="">전체 브랜드</option>
              {brands.map(b => <option key={b} value={b}>{b}</option>)}
            </select>
            <button
              type="submit"
              style={{ padding: "10px 20px", background: "var(--accent)", border: "none", borderRadius: 8, color: "white", fontFamily: "var(--mono)", fontSize: 12, fontWeight: 600, cursor: "pointer" }}
            >검색</button>
          </form>

          {loading ? (
            <div className="empty"><span className="spinner" /></div>
          ) : paged.length === 0 ? (
            <div className="empty">결과가 없습니다</div>
          ) : (
            <>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>상품명</th>
                      <th>브랜드</th>
                      <th>카테고리</th>
                      <th>소스</th>
                      <th>수집일시</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paged.map(p => (
                      <tr key={p.id}>
                        <td style={{ color: "var(--muted)" }}>{p.id}</td>
                        <td style={{ maxWidth: 360, color: "var(--text)" }}>{p.title}</td>
                        <td>
                          {p.brand
                            ? <span className="badge badge-brand">{p.brand}</span>
                            : <span style={{ color: "var(--muted)" }}>—</span>}
                        </td>
                        <td style={{ color: "var(--muted)" }}>{p.category || "—"}</td>
                        <td><span className="badge badge-source">{p.source}</span></td>
                        <td style={{ color: "var(--muted)" }}>
                          {p.createdAt ? new Date(p.createdAt).toLocaleString("ko-KR").slice(0, 16) : "—"}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="pagination">
                <span>{page * PAGE_SIZE + 1}–{Math.min((page + 1) * PAGE_SIZE, products.length)} / {products.length}건</span>
                <div className="page-btns">
                  <button className="page-btn" onClick={() => setPage(p => p - 1)} disabled={page === 0}>← 이전</button>
                  <button className="page-btn" disabled style={{ color: "var(--accent)" }}>{page + 1} / {totalPages}</button>
                  <button className="page-btn" onClick={() => setPage(p => p + 1)} disabled={page >= totalPages - 1}>다음 →</button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}

// ─── App ─────────────────────────────────────────────────────────
export default function App() {
  const [page, setPage] = useState("dashboard");
  const [productKeyword, setProductKeyword] = useState("");

  const navigate = (target, keyword = "") => {
    setProductKeyword(keyword);
    setPage(target);
  };

  return (
    <>
      <style>{styles}</style>
      <div className="app">
        <aside className="sidebar">
          <div className="sidebar-logo">
            PRP
            <span>product research</span>
          </div>
          {[
            { key: "dashboard", label: "대시보드" },
            { key: "products", label: "상품 목록" },
          ].map(({ key, label }) => (
            <div
              key={key}
              className={`nav-item ${page === key ? "active" : ""}`}
              onClick={() => navigate(key)}
            >
              <span className="nav-dot" />
              {label}
            </div>
          ))}
        </aside>
        <main className="main">
          {page === "dashboard" && <Dashboard onNavigate={navigate} />}
          {page === "products" && <Products initialKeyword={productKeyword} key={productKeyword} />}
        </main>
      </div>
    </>
  );
}