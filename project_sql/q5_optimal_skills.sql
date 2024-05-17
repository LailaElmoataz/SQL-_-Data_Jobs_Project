/*
 Question: What are the most optimal skills?
 - Identify skills that are both highly demanded and associated with high salaries
 */
WITH skills_demand AS (
    SELECT skills_job_dim.skill_id,
        COUNT(skills_job_dim.job_id) demand_count
    FROM job_postings_fact
        JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    WHERE skills_job_dim.job_id IN (
            SELECT job_id
            FROM job_postings_fact
            WHERE job_title_short = 'Data Analyst'
                AND salary_year_avg IS NOT NULL
        )
    GROUP BY skills_job_dim.skill_id
),
skills_salary AS (
    SELECT skills_job_dim.skill_id,
        skills,
        ROUND(AVG(salary_year_avg), 0)::money avg_year_salary
    FROM job_postings_fact
        JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
        JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
    GROUP BY skills_job_dim.skill_id,
        skills
)
SELECT skills,
    avg_year_salary,
    demand_count
FROM skills_demand
    JOIN skills_salary ON skills_demand.skill_id = skills_salary.skill_id
WHERE demand_count >= 50
ORDER BY avg_year_salary DESC
LIMIT 10;