-- How many jobs do we have in the job_postings_fact dataset?
SELECT COUNT(*) job_count
FROM job_postings_fact;
-- Get the earliest and latest job_posted_date
SELECT MIN(job_posted_date)::date earliest_job_posted_date,
    MAX(job_posted_date)::date latest_job_posted_date
FROM job_postings_fact;
-- Get the number of jobs posted per month
SELECT TO_CHAR(job_posted_date, 'Month') job_posted_month,
    COUNT(job_id) jobs_count
FROM job_postings_fact
GROUP BY job_posted_month
ORDER BY jobs_count DESC;
-- What are the most advertised job titles?
SELECT job_title_short,
    COUNT(*) job_title_count,
    TO_CHAR((COUNT(*) / (SUM(COUNT(*)) OVER()) * 100), '99%') AS job_title_pct
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY job_title_count DESC
LIMIT 5;
--Calculate summary statistics for the annual salary of the most frequent job titles
SELECT job_title_short,
    ROUND(MIN(salary_year_avg), 0)::money min_sal,
    ROUND(
        PERCENTILE_CONT(.25) WITHIN GROUP (
            ORDER BY salary_year_avg
        )::numeric,
        0
    )::money pct_25_sal,
    ROUND(
        PERCENTILE_CONT(.5) WITHIN GROUP (
            ORDER BY salary_year_avg
        )::numeric,
        0
    )::money pct_50_sal,
    ROUND(AVG(salary_year_avg), 0)::money avg_sal,
    ROUND(
        PERCENTILE_CONT(.75) WITHIN GROUP (
            ORDER BY salary_year_avg
        )::numeric,
        0
    )::money pct_75_sal,
    ROUND(MAX(salary_year_avg), 0)::money max_sal
FROM job_postings_fact
WHERE job_title_short IN (
        'Data Analyst',
        'Data Engineer',
        'Data Scientist'
    )
    AND salary_year_avg IS NOT NULL
GROUP BY job_title_short;
-- What is the percentage of jobs that mention a degree requirement?
-- Show how the percentage varies between Data Analyst positions and the other roles.
WITH job_title_degree_data AS (
    SELECT CASE
            WHEN job_title_short = 'Data Analyst' THEN 'Data Analyst'
            ELSE 'Other'
        END AS job_category,
        job_no_degree_mention
    FROM job_postings_fact
)
SELECT job_category,
    job_no_degree_mention,
    COUNT(*) AS jobs_count,
    TO_CHAR(
        (
            COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY job_category) * 100
        ),
        '99%'
    ) AS pct
FROM job_title_degree_data
GROUP BY job_category,
    job_no_degree_mention
ORDER BY job_category,
    pct DESC;
-- Get the top 10 companies for volume of job postings along with the countries where these jobs are posted.
SELECT name AS company_name,
    COUNT(jobs.job_id) jobs_count,
    jobs.job_country
FROM job_postings_fact AS jobs
    JOIN company_dim AS companies ON jobs.company_id = companies.company_id
GROUP BY company_name,
    job_country
ORDER BY jobs_count DESC
LIMIT 10;
-- Get the distinct values of skills type
SELECT DISTINCT type
FROM skills_dim;