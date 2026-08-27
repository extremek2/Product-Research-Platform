const API_URL = process.env.REACT_APP_API_URL || "http://localhost:8080/api/v1";
let accessToken = null;

export function setAccessToken(token) { accessToken = token; }

export class ApiError extends Error {
  constructor(message, status) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

export async function apiRequest(path, options = {}, retry = true) {
  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
      ...options.headers,
    },
    credentials: "include",
  });
  if (response.status === 401 && retry && !path.startsWith("/auth/")) {
    const refreshed = await refreshAccessToken();
    if (refreshed) return apiRequest(path, options, false);
  }
  const payload = await response.json().catch(() => null);
  if (!response.ok || payload?.success === false) {
    throw new ApiError(payload?.message || "API 요청에 실패했습니다.", response.status);
  }
  return payload?.data;
}

export async function refreshAccessToken() {
  const response = await fetch(`${API_URL}/auth/refresh`, { method: "POST", credentials: "include", headers: { "Content-Type": "application/json" } });
  const payload = await response.json().catch(() => null);
  if (!response.ok || !payload?.data) { setAccessToken(null); return null; }
  setAccessToken(payload.data.accessToken);
  return payload.data;
}
