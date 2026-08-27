import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { ErrorMessage } from "../components/Feedback";

export default function AuthPage() {
  const { login, signup } = useAuth(); const [mode, setMode] = useState("login");
  const [form, setForm] = useState({ organizationName:"", businessNumber:"", name:"", email:"", password:"", phone:"" });
  const [error,setError]=useState(""); const [submitting,setSubmitting]=useState(false);
  const change=e=>setForm({...form,[e.target.name]:e.target.value});
  const submit=async e=>{e.preventDefault();setSubmitting(true);setError("");try{if(mode==="login") await login({email:form.email,password:form.password}); else await signup(form);}catch(err){setError(err.message);}finally{setSubmitting(false);}};
  return <div className="setup-page"><div className="setup-copy"><span className="eyebrow">SHIPPER WORKSPACE</span><h1>수많은 B/L 중<br/>지금 볼 것만 남깁니다.</h1><p>화주 중심으로 선적·통관·문서와 다음 조치를 한 업무 흐름에서 관리합니다.</p></div>
    <form className="panel setup-form" onSubmit={submit}><div className="auth-tabs"><button type="button" className={mode==="login"?"active":""} onClick={()=>setMode("login")}>로그인</button><button type="button" className={mode==="signup"?"active":""} onClick={()=>setMode("signup")}>화주 회원가입</button></div><ErrorMessage message={error}/>
      {mode==="signup"&&<><label>회사명<input name="organizationName" value={form.organizationName} onChange={change} required/></label><label>사업자번호 <span className="optional">선택</span><input name="businessNumber" value={form.businessNumber} onChange={change}/></label><div className="form-grid two"><label>담당자명<input name="name" value={form.name} onChange={change} required/></label><label>연락처 <span className="optional">선택</span><input name="phone" value={form.phone} onChange={change}/></label></div></>}
      <label>이메일<input type="email" name="email" value={form.email} onChange={change} required placeholder="ops@example.com"/></label><label>비밀번호<input type="password" name="password" minLength="8" maxLength="72" value={form.password} onChange={change} required placeholder="8자 이상"/></label>
      <button className="button primary wide" disabled={submitting}>{submitting?"처리 중…":mode==="login"?"로그인":"작업 공간 만들기"}</button></form></div>;
}
