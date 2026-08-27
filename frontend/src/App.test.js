import { render, screen } from '@testing-library/react';
import App from './App';

beforeEach(() => {
  localStorage.clear();
  window.history.pushState({}, '', '/');
  jest.restoreAllMocks();
});

test('조직이 없으면 화주 조직 생성 화면을 표시한다', () => {
  render(<App />);
  expect(screen.getByRole('heading', { name: '화주 조직 생성' })).toBeInTheDocument();
  expect(screen.getByRole('button', { name: '작업 공간 만들기' })).toBeInTheDocument();
});

test('조직 컨텍스트가 있으면 화물 현황과 API 데이터를 표시한다', async () => {
  localStorage.setItem('trade-operation-workspace', JSON.stringify({
    organizationId: 'org-public-id', ownerUserId: 'user-public-id',
    organizationName: 'ABC Trading', ownerEmail: 'ops@example.com',
  }));
  jest.spyOn(global, 'fetch').mockResolvedValue({
    ok: true,
    json: async () => ({ success: true, data: [{
      shipmentId: 'shipment-public-id', caseNumber: 'IMP-2026-001', priority: 'URGENT',
      status: 'OPEN', currentStage: 'IN_TRANSIT', direction: 'IMPORT', transportMode: 'SEA',
      originLocationCode: 'CNSHA', destinationLocationCode: 'KRPUS', eta: '2026-09-01T09:00:00',
    }] }),
  });

  render(<App />);

  expect(await screen.findByText('IMP-2026-001')).toBeInTheDocument();
  expect(screen.getByText('ABC Trading')).toBeInTheDocument();
  expect(global.fetch).toHaveBeenCalledWith(expect.stringContaining('organizationId=org-public-id'), expect.any(Object));
});
