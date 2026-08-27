import { apiRequest } from "./client";

const query = (params) => new URLSearchParams(
  Object.entries(params).filter(([, value]) => value !== "" && value !== undefined && value !== null)
).toString();

export function getShipments(organizationId, filters = {}) {
  return apiRequest(`/shipments?${query({ organizationId, ...filters })}`);
}

export function getShipment(shipmentId, organizationId) {
  return apiRequest(`/shipments/${shipmentId}?${query({ organizationId })}`);
}

export function createShipment(payload) {
  return apiRequest("/shipments", { method: "POST", body: JSON.stringify(payload) });
}

export function updateShipment(shipmentId, organizationId, payload) {
  return apiRequest(`/shipments/${shipmentId}?${query({ organizationId })}`, {
    method: "PATCH", body: JSON.stringify(payload),
  });
}

export function archiveShipment(shipmentId, organizationId) {
  return apiRequest(`/shipments/${shipmentId}/archive?${query({ organizationId })}`, { method: "POST" });
}

export function addTransportDocument(shipmentId, organizationId, payload) {
  return apiRequest(`/shipments/${shipmentId}/documents?${query({ organizationId })}`, {
    method: "POST", body: JSON.stringify(payload),
  });
}
