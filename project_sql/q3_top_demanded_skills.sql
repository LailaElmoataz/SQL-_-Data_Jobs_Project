/* 
 Question 3: What are the most in-demand skills for Data Analyst roles?
 - Identify the top 5 in-demand skills.
 - Show the frequency of these skills in data analyst jobs.
 - This will help us identify the must-have skills.
 */
WITH data_analyst_jobs AS (
    SELECT job_id
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
)
SELECT skills,
    COUNT(*) AS job_count,
    TO_CHAR(
        COUNT(*) * 100 / (
            SELECT COUNT(*)
            FROM data_analyst_jobs
        ),
        '99%'
    ) AS freq_pct
FROM data_analyst_jobs
    JOIN skills_job_dim ON data_analyst_jobs.job_id = skills_job_dim.job_id
    JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY skills
ORDER BY job_count DESC
LIMIT 5;