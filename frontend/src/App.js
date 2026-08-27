import { useEffect, useState } from "react";
import AppLayout from "./components/AppLayout";
import { WorkspaceProvider, useWorkspace } from "./context/WorkspaceContext";
import OrganizationSetupPage from "./pages/OrganizationSetupPage";
import ShipmentDashboardPage from "./pages/ShipmentDashboardPage";
import ShipmentCreatePage from "./pages/ShipmentCreatePage";
import ShipmentDetailPage from "./pages/ShipmentDetailPage";
import ResearchPage from "./pages/ResearchPage";
import "./styles/app.css";

function usePath() {
  const [path, setPath] = useState(window.location.pathname);
  useEffect(() => { const handler = () => setPath(window.location.pathname); window.addEventListener("popstate", handler); return () => window.removeEventListener("popstate", handler); }, []);
  const navigate = next => { window.history.pushState({}, "", next); setPath(next); window.scrollTo(0, 0); };
  return [path, navigate];
}

function Routes() {
  const { workspace } = useWorkspace(); const [path, navigate] = usePath();
  if (!workspace) return <OrganizationSetupPage/>;
  let page;
  if (path === "/research") return <ResearchPage onExit={() => navigate("/")}/>;
  else if (path === "/shipments/new") page = <ShipmentCreatePage navigate={navigate}/>;
  else if (/^\/shipments\/[^/]+$/.test(path)) page = <ShipmentDetailPage shipmentId={path.split("/")[2]} navigate={navigate}/>;
  else page = <ShipmentDashboardPage navigate={navigate}/>;
  return <AppLayout path={path} navigate={navigate}>{page}</AppLayout>;
}

export default function App() { return <WorkspaceProvider><Routes/></WorkspaceProvider>; }
