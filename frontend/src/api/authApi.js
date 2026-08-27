import { apiRequest, refreshAccessToken } from "./client";

export const signup = payload => apiRequest("/auth/signup", { method: "POST", body: JSON.stringify(payload) });
export const login = payload => apiRequest("/auth/login", { method: "POST", body: JSON.stringify(payload) });
export const restoreSession = () => refreshAccessToken();
export const logout = () => apiRequest("/auth/logout", { method: "POST" }, false);
