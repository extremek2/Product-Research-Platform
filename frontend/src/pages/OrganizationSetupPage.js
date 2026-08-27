import { useState } from "react";
import { createOrganization } from "../api/organizationApi";
import { useWorkspace } from "../context/WorkspaceContext";
import { ErrorMessage } from "../components/Feedback";

export default function OrganizationSetupPage() {
  const { setWorkspace } = useWorkspace();
  const [form, setForm] = useState({ name: "", businessNumber: "", ownerName: "", ownerEmail: "", ownerPhone: "" });
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const change = (e) => setForm({ ...form, [e.target.name]: e.target.value });
  const submit = async (e) => {
    e.preventDefault(); setSubmitting(true); setError("");
    try {
      const result = await createOrganization({ ...form, organizationType: "SHIPPER" });
      setWorkspace({ organizationId: result.organizationId, ownerUserId: result.ownerUserId,
        organizationName: result.name, ownerEmail: result.ownerEmail });
    } catch (err) { setError(err.message); } finally { setSubmitting(false); }
  };
  return (
    <div className="setup-page">
      <div className="setup-copy"><span className="eyebrow">SHIPPER WORKSPACE</span><h1>수많은 B/L 중<br/>지금 볼 것만 남깁니다.</h1>
        <p>화주 조직을 먼저 만들고 실제 화물 데이터를 등록해 기초 업무 흐름을 확인해 보세요.</p></div>
      <form className="panel setup-form" onSubmit={submit}>
        <div><span className="eyebrow">01 · 시작하기</span><h2>화주 조직 생성</h2><p className="muted">인증 적용 전까지 이 브라우저에 임시 작업 공간이 저장됩니다.</p></div>
        <ErrorMessage message={error} />
        <label>회사명<input name="name" value={form.name} onChange={change} required placeholder="예: ABC Trading" /></label>
        <label>사업자번호 <span className="optional">선택</span><input name="businessNumber" value={form.businessNumber} onChange={change} /></label>
        <div className="form-grid two"><label>담당자명<input name="ownerName" value={form.ownerName} onChange={change} required /></label>
          <label>연락처 <span className="optional">선택</span><input name="ownerPhone" value={form.ownerPhone} onChange={change} /></label></div>
        <label>담당자 이메일<input type="email" name="ownerEmail" value={form.ownerEmail} onChange={change} required placeholder="ops@example.com" /></label>
        <button className="button primary wide" disabled={submitting}>{submitting ? "생성 중…" : "작업 공간 만들기"}</button>
      </form>
    </div>
  );
}
