INSERT INTO retail_source (name, source_key, crawler_type, priority) VALUES
    ('네이버쇼핑', 'naver_shopping', 'API', 100),
    ('쿠팡',       'coupang',        'CRAWL', 80),
    ('11번가',     '11st',           'API', 60),
    ('G마켓',      'gmarket',        'CRAWL', 40);

INSERT INTO wholesale_source (name, source_key, country, crawler_type) VALUES
    ('도매꾹',         'domeggook',  'KR', 'API'),
    ('도매매',         'domeme',     'KR', 'API'),
    ('오너클랜',       'ownerclan',  'KR', 'CRAWL'),
    ('알리익스프레스', 'aliexpress', 'CN', 'API');

INSERT INTO operation_rule (
    rule_code, name, description, issue_type, severity, rule_type, configuration
) VALUES
    ('ETA_PASSED_WITHOUT_ARRIVAL', 'ETA 경과 후 미도착', 'ETA가 지났지만 도착 이벤트가 없는 화물', 'ETA_DELAY', 'URGENT', 'THRESHOLD', '{"graceHours": 6}'),
    ('ETD_PASSED_WITHOUT_DEPARTURE', 'ETD 경과 후 미출항', 'ETD가 지났지만 출항 이벤트가 없는 화물', 'ETD_DELAY', 'ATTENTION', 'THRESHOLD', '{"graceHours": 6}'),
    ('ARRIVED_WITHOUT_CUSTOMS_DECLARATION', '입항 후 신고 미진행', '입항 후 수입신고 이벤트가 없는 화물', 'CUSTOMS_DELAY', 'URGENT', 'THRESHOLD', '{"graceHours": 12}'),
    ('PACKING_LIST_MISSING_BEFORE_ETD', '선적 전 PL 미수신', 'ETD가 임박했지만 Packing List가 없는 화물', 'DOCUMENT_MISSING', 'ATTENTION', 'THRESHOLD', '{"beforeEtdHours": 24}'),
    ('OPEN_TASK_OVERDUE', '업무 기한 초과', '완료되지 않은 업무가 기한을 초과함', 'TASK_OVERDUE', 'ATTENTION', 'THRESHOLD', '{"graceHours": 0}'),
    ('CUSTOMS_HOLD_DETECTED', '통관 보류 감지', '외부 통관 이벤트에서 보류 상태가 감지됨', 'CUSTOMS_HOLD', 'URGENT', 'EVENT', '{}');
