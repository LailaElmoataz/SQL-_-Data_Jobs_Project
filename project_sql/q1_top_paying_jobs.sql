/*
 Question: What are the top-paying data analyst jobs?
 - Identify the top 10 highest-paying Data Analyst roles that are available remotely.
 - Remove job postings that do not mention salary.
 - Filter to remote and junior opportunities
 */
SELECT job_id,
    job_title,
    name AS company_name,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM job_postings_fact
    LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
WHERE job_title_short = 'Data Analyst'
    AND job_title LIKE '%Junior%'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE
ORDER BY salary_year_avg DESC
LIMIT 10;