-- Key Performance Indicators Calculation
-- This query calculates core customer success metrics

WITH monthly_metrics AS (
    SELECT 
        DATE_TRUNC('month', created_date) AS month,
        COUNT(*) AS total_tickets,
        AVG(CASE WHEN satisfaction_score IS NOT NULL 
              THEN satisfaction_score END) AS avg_csat,
        AVG(TIMESTAMPDIFF(hour, created_date, first_response_date)) AS avg_first_response_time,
        AVG(TIMESTAMPDIFF(hour, created_date, resolved_date)) AS avg_resolution_time,
        COUNT(CASE WHEN escalated = TRUE THEN 1 END) AS escalated_tickets,
        COUNT(CASE WHEN status = 'closed' THEN 1 END) AS closed_tickets
    FROM support_tickets
    WHERE created_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY DATE_TRUNC('month', created_date)
)
SELECT 
    month,
    total_tickets,
    ROUND(avg_csat, 2) AS avg_csat_score,
    ROUND(avg_first_response_time, 2) AS avg_response_hours,
    ROUND(avg_resolution_time, 2) AS avg_resolution_hours,
    ROUND((escalated_tickets * 100.0 / total_tickets), 2) AS escalation_rate,
    ROUND((closed_tickets * 100.0 / total_tickets), 2) AS resolution_rate
FROM monthly_metrics
ORDER BY month DESC;
