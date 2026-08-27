const labels = {
  OPEN: "진행 중", ON_HOLD: "보류", COMPLETED: "완료", CANCELLED: "취소", ARCHIVED: "보관",
  NORMAL: "정상", ATTENTION: "확인 필요", URGENT: "즉시 조치",
  PREPARATION: "준비", BOOKING: "부킹", DEPARTED: "출발", IN_TRANSIT: "운송 중",
  ARRIVED: "도착", CUSTOMS: "통관", DELIVERY: "배송",
};

export const displayLabel = (value) => labels[value] || value || "—";

export default function StatusBadge({ value }) {
  return <span className={`badge badge-${String(value).toLowerCase().replace("_", "-")}`}>{displayLabel(value)}</span>;
}
