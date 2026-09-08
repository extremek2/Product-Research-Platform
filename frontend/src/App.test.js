import { render, screen } from '@testing-library/react';
import App from './App';

beforeEach(() => { window.scrollTo = jest.fn(); window.history.pushState({}, '', '/'); jest.restoreAllMocks(); });

test('세션이 없으면 로그인 화면을 표시한다', async () => {
  jest.spyOn(global, 'fetch').mockResolvedValue({ ok: false, status: 401, json: async () => ({ success: false }) });
  render(<App />);
  expect((await screen.findAllByRole('button', { name: '로그인' })).length).toBe(2);
  expect(screen.getByRole('button', { name: '화주 회원가입' })).toBeInTheDocument();
});

test('Refresh 세션이 있으면 인증된 조직의 화물을 표시한다', async () => {
  jest.spyOn(global, 'fetch').mockImplementation(async url => {
    if (String(url).includes('/auth/refresh')) return { ok: true, json: async () => ({ success: true, data: { accessToken: 'access-token', user: { sessionKind: 'ORGANIZATION', organizationName: 'ABC Trading', email: 'ops@example.com', role: 'OWNER' } } }) };
    return { ok: true, json: async () => ({ success: true, data: [{ shipmentId:'shipment-id', caseNumber:'IMP-2026-001', priority:'URGENT', status:'OPEN', currentStage:'IN_TRANSIT', transportMode:'SEA', originLocationCode:'CNSHA', destinationLocationCode:'KRPUS' }] }) };
  });
  render(<App />);
  expect(await screen.findByText('IMP-2026-001')).toBeInTheDocument();
  expect(screen.getByText('ABC Trading')).toBeInTheDocument();
  expect(global.fetch).toHaveBeenCalledWith(expect.stringMatching(/\/shipments\?/), expect.objectContaining({ credentials:'include' }));
});

test('운영 빌드에서 보류한 리서치 주소와 메뉴는 열리지 않는다', async () => {
  const previous = process.env.REACT_APP_RESEARCH_ENABLED;
  process.env.REACT_APP_RESEARCH_ENABLED = 'false';
  window.history.replaceState({}, '', '/research');
  jest.spyOn(global, 'fetch').mockImplementation(async url => ({ ok: true, json: async () => ({ success: true,
    data: String(url).includes('/auth/refresh') ? { accessToken: 'token', user: { sessionKind: 'ORGANIZATION', organizationName: '운영 화주', email: 'owner@example.test', role: 'OWNER' } } : [] }) }));
  try {
    render(<App/>);
    expect(await screen.findByText('운영 화주')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: '상품 리서치' })).not.toBeInTheDocument();
    expect(window.location.pathname).toBe('/');
    expect(global.fetch.mock.calls.some(([url]) => String(url).includes('8000'))).toBe(false);
  } finally {
    if (previous === undefined) delete process.env.REACT_APP_RESEARCH_ENABLED;
    else process.env.REACT_APP_RESEARCH_ENABLED = previous;
  }
});
