/*
 Question: Which skills are associated with higher salaries?
 - Get the average salary associated with each skill for Data Analyst roles.
 - Remove job postings that do not mention salary
 - We want to understand how different skills affect the expected salary level.
 */
SELECT skills,
    type,
    ROUND(AVG(salary_year_avg), 0)::money avg_year_salary
FROM job_postings_fact
    JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY skills,
    type
ORDER BY avg_year_salary DESC
LIMIT 10;