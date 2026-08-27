import { render, screen } from '@testing-library/react';
import App from './App';

beforeEach(() => { window.history.pushState({}, '', '/'); jest.restoreAllMocks(); });

test('세션이 없으면 로그인 화면을 표시한다', async () => {
  jest.spyOn(global, 'fetch').mockResolvedValue({ ok: false, status: 401, json: async () => ({ success: false }) });
  render(<App />);
  expect((await screen.findAllByRole('button', { name: '로그인' })).length).toBe(2);
  expect(screen.getByRole('button', { name: '화주 회원가입' })).toBeInTheDocument();
});

test('Refresh 세션이 있으면 인증된 조직의 화물을 표시한다', async () => {
  jest.spyOn(global, 'fetch').mockImplementation(async url => {
    if (String(url).includes('/auth/refresh')) return { ok: true, json: async () => ({ success: true, data: { accessToken: 'access-token', user: { organizationName: 'ABC Trading', email: 'ops@example.com', role: 'OWNER' } } }) };
    return { ok: true, json: async () => ({ success: true, data: [{ shipmentId:'shipment-id', caseNumber:'IMP-2026-001', priority:'URGENT', status:'OPEN', currentStage:'IN_TRANSIT', transportMode:'SEA', originLocationCode:'CNSHA', destinationLocationCode:'KRPUS' }] }) };
  });
  render(<App />);
  expect(await screen.findByText('IMP-2026-001')).toBeInTheDocument();
  expect(screen.getByText('ABC Trading')).toBeInTheDocument();
  expect(global.fetch).toHaveBeenCalledWith(expect.stringMatching(/\/shipments\?/), expect.objectContaining({ credentials:'include' }));
});
