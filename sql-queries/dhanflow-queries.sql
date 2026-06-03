-- Query 1: Total Loans Overview
SELECT 
    status,
    COUNT(*) as total_loans,
    SUM(loan_amount) as total_amount,
    AVG(loan_amount) as avg_amount
FROM loans
GROUP BY status;

-- Query 2: Disbursement Rate
SELECT 
    ROUND(COUNT(CASE WHEN status = 'disbursed' 
    THEN 1 END) * 100.0 / COUNT(*), 2) 
    AS disbursement_rate_percent,
    ROUND(COUNT(CASE WHEN status = 'rejected' 
    THEN 1 END) * 100.0 / COUNT(*), 2) 
    AS rejection_rate_percent,
    ROUND(COUNT(CASE WHEN status = 'pending' 
    THEN 1 END) * 100.0 / COUNT(*), 2) 
    AS pending_rate_percent
FROM loans;

-- Query 3: Monthly Disbursement Trend
SELECT 
    STRFTIME('%Y-%m', disbursed_date) as month,
    COUNT(*) as loans_disbursed,
    SUM(loan_amount) as total_disbursed_amount
FROM loans
WHERE status = 'disbursed'
GROUP BY STRFTIME('%Y-%m', disbursed_date)
ORDER BY month ASC;

-- Query 4: Rejection Analysis
SELECT 
    rejection_reason,
    COUNT(*) as total_rejections
FROM loans
WHERE status = 'rejected'
GROUP BY rejection_reason
ORDER BY total_rejections DESC;

-- Query 5: KYC Failure Rate
SELECT 
    kyc_status,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM kyc_verification), 2) 
    AS percentage
FROM kyc_verification
GROUP BY kyc_status;

-- Query 6: Overdue Repayments
SELECT 
    b.borrower_name,
    b.city,
    b.business_type,
    l.loan_amount,
    r.emi_amount,
    r.due_date,
    r.payment_status
FROM repayments r
JOIN loans l ON r.loan_id = l.loan_id
JOIN borrowers b ON l.borrower_id = b.borrower_id
WHERE r.payment_status = 'unpaid'
ORDER BY r.due_date ASC;

-- Query 7: Top Borrowers
SELECT 
    b.borrower_name,
    b.city,
    b.business_type,
    COUNT(l.loan_id) as total_loans,
    SUM(l.loan_amount) as total_borrowed
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
WHERE l.status = 'disbursed'
GROUP BY b.borrower_name, b.city, b.business_type
ORDER BY total_borrowed DESC;

-- Query 8: City Wise Distribution
SELECT 
    b.city,
    COUNT(l.loan_id) as total_loans,
    SUM(l.loan_amount) as total_amount
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
GROUP BY b.city
ORDER BY total_amount DESC;

-- Query 9: Repayment Health
SELECT 
    payment_status,
    COUNT(*) as total_emis,
    SUM(emi_amount) as total_amount,
    ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM repayments), 2) 
    AS percentage
FROM repayments
GROUP BY payment_status;

-- Query 10: Full Borrower Journey
SELECT 
    b.borrower_name,
    b.city,
    b.business_type,
    b.monthly_income,
    l.loan_amount,
    l.loan_purpose,
    l.status as loan_status,
    k.kyc_status,
    l.application_date,
    l.disbursed_date
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
JOIN kyc_verification k ON b.borrower_id = k.borrower_id
ORDER BY l.application_date ASC;
