-- case_info definition

DROP TABLE case_info;

CREATE TABLE case_info(
  "id" INTEGER,
  "case_number" TEXT,
  "caption" TEXT,
  "date_filed" TEXT,
  "status" TEXT,
  "case_type" TEXT,
  "prior_jurisdiction" TEXT,
  "bad_response_text" TEXT
);

CREATE INDEX case_info_case_number_IDX ON case_info (case_number);

-- case_jurisdiction definition

DROP TABLE case_jurisdiction;

CREATE TABLE case_jurisdiction(
  "case_number" TEXT,
  "jurisdiction_name" TEXT,
  "county" TEXT,
  "prior_decision_date" TEXT,
  "prior_case_numbers" TEXT
);

CREATE INDEX case_jurisdiction_case_number_IDX ON case_jurisdiction (case_number);
CREATE INDEX case_jurisdiction_name_IDX ON case_jurisdiction (jurisdiction_name);
CREATE INDEX case_jurisdiction_county_IDX ON case_jurisdiction (county);

-- docket_item definition

DROP TABLE docket_item;

CREATE TABLE docket_item(
  "case_number" TEXT,
  "id" INTEGER,
  "description" TEXT,
  "code" TEXT,
  "type" TEXT,
  "date_filed" TEXT,
  "document_name" TEXT,
  "filing_parties" TEXT
);

CREATE INDEX docket_item_case_number_IDX ON docket_item (case_number);

-- decision_item definition

DROP TABLE decision_item;

CREATE TABLE decision_item(
  "case_number" TEXT,
  "description" TEXT,
  "release_date" TEXT,
  "disposes_case" INTEGER,
  "document_name" TEXT,
  "filing_parties" TEXT
);

CREATE INDEX decision_item_case_number_IDX ON decision_item (case_number);

-- party definition

DROP TABLE party;

CREATE TABLE party(
  "case_number" TEXT,
  "party_name" TEXT,
  "pro_se" INTEGER,
  "type" TEXT
);

CREATE INDEX party_case_number_IDX ON party (case_number,party_name);
CREATE INDEX party_pro_se_IDX ON party (pro_se);

-- party_attorney definition

DROP TABLE party_attorney;

CREATE TABLE party_attorney(
  "case_number" TEXT,
  "party_name" TEXT,
  "attorney_name" TEXT,
  "attorney_registration_number" TEXT,
  "counsel_of_record" INTEGER
);

CREATE INDEX party_attorney_case_number_IDX ON party_attorney (case_number,party_name);
CREATE INDEX party_attorney_name_IDX ON party_attorney (attorney_name);
