-- Use these statements to analyze the data.

SELECT COUNT(*)
FROM docket_item di 
WHERE di.filing_parties = 'DISPOSITIVE' 
AND di.document_name IS NOT NULL
AND di.document_name != '';

SELECT COUNT(*)
FROM decision_item di2 
WHERE di2.disposes_case = 1
AND di2.document_name IS NOT NULL
AND di2.document_name != '';

SELECT di.case_number, di.document_name, di.description, di2.description 
FROM docket_item di 
INNER JOIN decision_item di2 ON di.case_number = di2.case_number 
WHERE di.filing_parties = 'DISPOSITIVE' 
AND di.document_name IS NOT NULL
AND di.document_name != ''
AND di2.disposes_case = 1
AND di2.document_name IS NOT NULL
AND di2.document_name != '';

SELECT ci.case_type, COUNT(*) AS Cases
FROM case_info ci
GROUP BY ci.case_type
ORDER BY COUNT(*) DESC;

SELECT ci.status, COUNT(*) AS Cases
FROM case_info ci
GROUP BY ci.status
ORDER BY COUNT(*) DESC;

SELECT ci.case_type, COUNT(*),
SUM(CASE WHEN ci.status = 'Open' THEN 1 ELSE 0 END) AS 'Open',
SUM(CASE WHEN ci.status = 'Inactive' THEN 1 ELSE 0 END) AS Inactive,
SUM(CASE WHEN ci.status = 'Disposed' THEN 1 ELSE 0 END) AS Disposed,
SUM(CASE WHEN ci.status = '' THEN 1 ELSE 0 END) AS 'None'
FROM case_info ci
GROUP BY ci.case_type, ci.status
ORDER BY COUNT(*) DESC;
