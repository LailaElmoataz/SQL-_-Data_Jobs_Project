/*
 Question 2: What are the skills required for the top-paying Data Analyst jobs?
 - Using the first query that shows the top-paying jobs, we will look at the skills required for these jobs
 - This will help us understand what skills we need to develop
 */
SELECT DISTINCT skills,
    type
FROM skills_job_dim
    JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_id IN (
        SELECT job_id
        FROM job_postings_fact
            LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
        WHERE job_title_short = 'Data Analyst'
            AND job_title LIKE '%Junior%'
            AND salary_year_avg IS NOT NULL
            AND job_work_from_home = TRUE
        ORDER BY salary_year_avg DESC
        LIMIT 10
    );