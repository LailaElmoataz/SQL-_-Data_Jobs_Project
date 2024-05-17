# Introduction

In this project I will explore the data job market with the aim of uncovering valuable insights about the top-paying Data Analyst jobs and the required skills for these jobs.

The questions I'll try to answer through my analysis are:
1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What are most demanded skills for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?


You can find the SQL queries used throughout the project here [here](https://github.com/LailaElmoataz/SQL-_-Data_Jobs_Project/tree/main/project_sql). <br>
This project is part of the [SQL for Data Analysis Course](https://www.lukebarousse.com/sql) by Luke Barousse and Kelly Adams.
<br><br>
# Tools & Language
* **SQL**: for querying and analysis of job posting data. 
* **PostgreSQL**: database management system for handling the job posting data.
* **VS Code**: code editor for developing and executing SQL queries.
* **Git & Github**: for version control, project tracking and sharing my scripts and analysis.
<br><br>
# Analysis
This project utilizes four relational tables to explore the data job market landscape. These tables are interconnected and provide a comprehensive view of job postings, associated companies, and required skills.

**Job Postings Table:** This table serves as the core of our analysis, containing detailed information about job postings. It includes columns such as job title, location, posting date, salary, and other relevant attributes that can be used to understand job market trends.

**Company Table:** This table stores information about the companies offering the jobs. It includes the company name, potentially website URL, and a thumbnail logo. 

**Skills Table**: This table contains the various skills sought after in the job market. It includes the skill name and a category that helps in classification (e.g.programming languages, data analysis tools, ... etc). 

**Skills-Job Link Table**: This table establishes the many-to-many relationship between skills and job postings. It acts as a bridge, allowing us to identify the specific skills required for each job.

I'll start the analysis with conducting Exploratory Data Analysis (EDA) to better understand our data.

Firstly, let's see how many jobs do we have?

```sql
SELECT COUNT(*) job_count
FROM job_postings_fact;
```
This gives us the result below. So, we have 787686 jobs.
| job_count | 
|---|
| 787686 |

Next up, let's see what the earliest and latest job posting date is in our dataset.

```sql
SELECT 
    MIN(job_posted_date)::date earliest_job_posted_date,
    MAX(job_posted_date)::date latest_job_posted_date
FROM job_postings_fact;
```
The query above generates the result below which shows that we have one year worth of job postings data starting from Dec 31st, 2022 up to Dec 31st, 2023.
|earliest_job_posted_date|latest_job_posted_date       |
|------------------------|-----------------------------|
|2022-12-31              |2023-12-31                   |

Let's find out what was the frequency of job postings throughout the year.
```sql
SELECT 
    TO_CHAR(job_posted_date, 'Month') job_posted_month,
    COUNT(job_id) jobs_count
FROM job_postings_fact
GROUP BY job_posted_month
ORDER BY jobs_count DESC;
```
We can see here that the month with the most jobs posted is January, followed by August, while the month with the least data jobs posted is May.<br>
It would've been interesting if we had data from previous years to see if we had a similar trend in the past years as well.
|job_posted_month|jobs_count                   |
|----------------|-----------------------------|
|January         |92266                        |
|August          |75067                        |
|October         |66601                        |
|February        |64560                        |
|November        |64404                        |
|March           |64158                        |
|July            |63855                        |
|April           |62915                        |
|September       |62433                        |
|June            |61500                        |
|December        |57692                        |
|May             |52235                        |

Now let's see what were the most advertised job titles.
```sql
SELECT 
    job_title_short,
    COUNT(*) job_title_count,
    TO_CHAR((COUNT(*) / (SUM(COUNT(*)) OVER()) * 100), '99%') AS job_title_pct
FROM job_postings_fact
GROUP BY job_title_short
ORDER BY job_title_count DESC
LIMIT 5;
```
We can see from the output below that **Data Analyst**, **Data Engineer**, and **Data Scientist** were the most demanded roles, collectively accounting for over 70% of the job postings.
|job_title_short|job_title_count              |job_title_pct|
|---------------|-----------------------------|-------------|
|Data Analyst   |196593                       | 25%         |
|Data Engineer  |186679                       | 24%         |
|Data Scientist |172726                       | 22%         |
|Business Analyst|49160                        |  6%         |
|Software Engineer|45019                        |  6%         |

Let's now take a look at some summary statistics for the salaries of the most frequent three roles.

```sql
SELECT 
    job_title_short,
    ROUND(MIN(salary_year_avg), 0):: money min_sal,
    ROUND(PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0)::money pct_25_sal,
    ROUND(PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0)::money pct_50_sal,
    ROUND(AVG(salary_year_avg), 0):: money avg_sal,
    ROUND(PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0)::money pct_75_sal,
    ROUND(MAX(salary_year_avg), 0):: money max_sal
FROM job_postings_fact
WHERE 
    job_title_short IN ('Data Analyst', 'Data Engineer', 'Data Scientist')
    AND salary_year_avg IS NOT NULL
GROUP BY job_title_short;
```
Looking at the results below, we can observe the following:
* All three roles have broad salary ranges with high salaries of few postings skewing the average salary upwards. Data Scientist salaries have the widest range with a minimum of $27,000 and a maximum of $960,000. 
* Factors such as geographical location, experience level, and industry are likely contributing to such spread in salary ranges.
* Generally, Data Scientists command the highest salaries, followed by Data Engineers and then Data Analysts.

|job_title_short|min_sal   |pct_25_sal |pct_50_sal |avg_sal    |pct_75_sal |max_sal    |
|---------------|----------|-----------|-----------|-----------|-----------|-----------|
|Data Analyst   |$25,000.00|$70,000.00 |$90,000.00 |$93,876.00 |$111,175.00|$650,000.00|
|Data Engineer  |$15,000.00|$100,000.00|$125,000.00|$130,267.00|$147,500.00|$525,000.00|
|Data Scientist |$27,000.00|$100,000.00|$127,500.00|$135,929.00|$158,858.00|$960,000.00|

The question of whether formal education is a necessary requirement for data jobs sparks an interesting debate. Let's take a look into the percentage of job postings that explicitly mentioned a degree requirement. Given my particular focus on Data Analyst roles, I will examine how the presence of a degree requirement varies between Data Analyst positions and the other roles.

```sql
WITH job_title_degree_data AS (
  SELECT
    CASE 
        WHEN job_title_short = 'Data Analyst' THEN 'Data Analyst' 
        ELSE 'Other' 
        END AS job_category,
    job_no_degree_mention
  FROM job_postings_fact
)
SELECT
    job_category,
    job_no_degree_mention,
    COUNT(*) AS jobs_count,
    TO_CHAR((COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY job_category) * 100), '99%') AS pct
FROM job_title_degree_data
GROUP BY job_category, job_no_degree_mention
ORDER BY job_category, pct DESC;
```
The results below show that a majority of the job postings in both categories do mention a degree requirement (indicated by a 0 in "job_no_degree_mention" column). <br>
However, it's worth noting that 61% of the job postings for Data Analyst positions mention a degree requirement, compared to 72% of the job postings for other positions. This might suggest that having a degree is less critical for Data Analyst positions compared to other roles.
|job_category|job_no_degree_mention|jobs_count|pct |
|------------|---------------------|----------|----|
|Data Analyst|0                    |120536    | 61%|
|Data Analyst|1                    |76057     | 39%|
|Other       |0                    |425793    | 72%|
|Other       |1                    |165300    | 28%|

Having explored our job postings, let's shift our focus to the companies offering these jobs as well as the skillsets they require.<br>
First, let's examine the most active companies in terms of job postings in our data, along with the countries where these jobs were posted.

```sql
SELECT 
    name AS company_name,
    COUNT(jobs.job_id) jobs_count,
    jobs.job_country
FROM job_postings_fact AS jobs
JOIN company_dim AS companies 
ON jobs.company_id = companies.company_id
GROUP BY company_name, job_country
ORDER BY jobs_count DESC
LIMIT 10;
```
The results below show **"Emprego"** as the company with the most job postings focusing on South American recruitment specifically in Peru & Argentina, followed by several US-based companies like **"Booz Allen Hamilton"**, **"Dice"**, as well as **"Confidenziale"** in Italy.

|company_name                           |jobs_count|country       |
|---------------------------------------|----------|--------------|
|Emprego                                |3571      |Peru          |
|Emprego                                |3071      |Argentina     |
|Booz Allen Hamilton                    |2508      |United States |
|Dice                                   |2498      |United States |
|Confidenziale                          |2039      |Italy         |
|Insight Global                         |1939      |United States |
|Capital One                            |1688      |United States |
|Guidehouse                             |1551      |United States |
|Robert Half                            |1512      |United States |
|UnitedHealth Group                     |1408      |United States |

Lastly, let's take a quick look at the skill categories listed in the skills_dim table.

```sql
SELECT DISTINCT type
FROM skills_dim;
```
We can see that we have 10 distinct skill categories, including "programming", "databases", and "analyst_tools" indicating the range of technical and analytical skills sought after by employers for the different data roles.

|type                                   |
|---------------------------------------|
|programming                            |
|sync                                   |
|analyst_tools                          |
|libraries                              |
|databases                              |
|webframeworks                          |
|os                                     |
|cloud                                  |
|other                                  |
|async                                  |
<br>
Through our initial exploration of the data, we've provided a quick overview of the data and gained valuable insights into the data jobs market by examining the job postings, their frequency, associated skills, company activity, and salary distribution. Now, let's delve deeper and address the first of our core questions:

## 1. What are the top-paying data analyst jobs?
In this query, I aim to identify the top 10 data analyst jobs based on yearly average salaries. I will focus on remote junior data analyst opportunities since this is my area of interest. 

```sql
SELECT 
    job_id,
    job_title,
    name AS company_name,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM job_postings_fact
LEFT JOIN company_dim 
ON company_dim.company_id = job_postings_fact.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_title LIKE '%Junior%' AND
    job_work_from_home = TRUE AND 
    salary_year_avg IS NOT NULL 
ORDER BY salary_year_avg DESC
LIMIT 10;
```
From the results below, we can see that the top 10 jobs were mostly posted in the third quarter of 2023. Salaries range from $60k to $82k. The highest-paying job mentions junior/mid/senior levels, so the salary might reflect an average across experience levels.

|job_id                                 |job_title                                                           |company_name                           |job_schedule_type|salary_year_avg|job_posted_date    |
|---------------------------------------|--------------------------------------------------------------------|---------------------------------------|-----------------|---------------|-------------------|
|463381                                 |Data Analyst (Junior/Mid/Senior) - Remote - Defense Manpower Data...|Get It Recruit - Information Technology|Full-time        |82000.0        |2023-06-25 09:00:11|
|550113                                 |Junior Data Analyst                                                 |Motion Recruitment                     |Full-time        |80000.0        |2023-06-20 07:01:39|
|564679                                 |Junior Data Analyst                                                 |Coders Data                            |Full-time        |80000.0        |2023-10-09 20:01:53|
|1170721                                |Junior Data BI Analyst                                              |Patterned Learning AI                  |Full-time        |75000.0        |2023-07-27 07:02:24|
|1321085                                |Junior Data Analyst - US/Canada                                     |Patterned Learning AI                  |Full-time        |75000.0        |2023-07-20 07:00:27|
|156786                                 |Junior Data Analyst                                                 |Patterned Learning AI                  |Full-time        |75000.0        |2023-07-26 07:02:26|
|432310                                 |Junior Business/Data Analyst                                        |Get It Recruit - Transportation        |Full-time        |72000.0        |2023-07-28 09:00:20|
|1264889                                |Junior Reporting Data Analyst                                       |Get It Recruit - Information Technology|Full-time        |70000.0        |2023-07-08 10:00:04|
|1441940                                |Junior Data Analyst                                                 |Get It Recruit - Information Technology|Full-time        |65000.0        |2023-07-22 08:01:52|
|143739                                 |Junior Data Analyst                                                 |TalentKompass Deutschland              |Full-time        |60000.0        |2023-05-31 07:37:04|

## 2. What skills are required for these top-paying jobs?
In this query, I want to gain more insight into what are the required skills and competencies for the top-paying jobs we reviewed above.
```sql
SELECT 
    DISTINCT skills,
    type
FROM skills_job_dim
JOIN skills_dim 
ON skills_job_dim.skill_id = skills_dim.skill_id
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
```
The results reveal a diverse range of skills that can be categorized into:
* **Programming Languages** like Python, SQL, R.
* **Analysis Tools & Libraries** like Excel, Power BI, Tableau, and Hadoop.
* **Cloud Platforms** like Oracle also appear indicating potential areas of specialization.
* **Asynchronous communication** like Jira and Confluence for project management, collaboration and communication.

|skills                                 |type                                                                |
|---------------------------------------|--------------------------------------------------------------------|
|confluence                             |async                                                               |
|excel                                  |analyst_tools                                                       |
|hadoop                                 |libraries                                                           |
|jira                                   |async                                                               |
|ms access                              |analyst_tools                                                       |
|nosql                                  |programming                                                         |
|oracle                                 |cloud                                                               |
|power bi                               |analyst_tools                                                       |
|powerpoint                             |analyst_tools                                                       |
|python                                 |programming                                                         |
|r                                      |programming                                                         |
|sharepoint                             |analyst_tools                                                       |
|sheets                                 |analyst_tools                                                       |
|sql                                    |programming                                                         |
|t-sql                                  |programming                                                         |
|tableau                                |analyst_tools                                                       |
|vba                                    |programming                                                         |
|visual basic                           |programming                                                         |
|word                                   |analyst_tools                                                       |

## 3. What are most demanded skills for data analysts?
The highest-paying jobs we explored above demanded a diverse mix of technical and analytical skills. <br>
This might seem like a lot to take in, so in the next query, I want to identify the **top 5 most frequently requested skills by employers**. I will focus on all data analyst positions, not just the high-paying remote ones. This will provide a clear focus on the must-have skills across the field.

```sql
WITH data_analyst_jobs AS (
    SELECT job_id
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
)
SELECT 
    skills,
    COUNT(*) AS job_count,
    TO_CHAR(
        COUNT(*) * 100 / (
            SELECT COUNT(*)
            FROM data_analyst_jobs
        ),
        '99%'
    ) AS freq_pct
FROM data_analyst_jobs
JOIN skills_job_dim 
ON data_analyst_jobs.job_id = skills_job_dim.job_id
JOIN skills_dim
ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY skills
ORDER BY job_count DESC
LIMIT 5;
```
The results below show that the most in-demand skills for data analysts are:
* **SQL** appears to be the most sought-after skill appearing in almost half (**47%**) of job postings, highlighting its importance for data querying, and analysis. 
* **Excel (34%)** remains a vital tool for data processing and manipulation, followed by **Python (29%)** as the most demanded programming language for data analysis and scripting.
* Data visualisation tools **Tableau & Power BI** round out the top 5 skills appearing in **23%** and **20%** of job postings respectively. 


|skills  |job_count|freq_pct|
|--------|---------|--------|
|sql     |92628    | 47%    |
|excel   |67031    | 34%    |
|python  |57326    | 29%    |
|tableau |46554    | 23%    |
|power bi|39468    | 20%    |

## 4. Which skills are associated with higher salaries?
Now that we have identified the top in-demand skills for data analysts, we want to shift focus back to the financial side. Beyond the basics, what skills can give analysts a competitive edge in the job market and translate to higher earning potential? <br>
In the next query, I will identify the **top 10 skills with the highest average yearly salaries for data analyst positions**. <br>
```sql
SELECT 
    skills,
    type,
    ROUND(AVG(salary_year_avg), 0)::money avg_year_salary
FROM job_postings_fact
JOIN skills_job_dim 
ON job_postings_fact.job_id = skills_job_dim.job_id
JOIN skills_dim 
ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL
GROUP BY skills, type
ORDER BY avg_year_salary DESC
LIMIT 10;
```
Looking at the results below we can notice some interesting trends, with some expected high-paying skills, but also a few surprises.
* The most surprising observation is the exceptionally high average salary (**$400k**) associated with a version control system in **SVN (Subversion)**. This is unexpected since it's not a skill directly related to data analysis tasks.<br>
It is likely to be an error in the data, or an outlier datapoint that skewed the average salary. However, it could also be a highly specialized role in a niche industry that values expertise in SVN.
* The remaining skills suggest a focus on niche areas within data analysis that can be quite lucrative. These areas include **data manipulation** with R package dplyr ($148k) and **deep learning** with MXNet ($149k), **programming languages** like Golang ($155k) & Solidity for data analysis on the Blockchain ($179k), **machine learning tools** like Datarobot ($155k), and **NoSQL databases** like Couchbase ($161k).

|skills|type                       |avg_year_salary|
|------|---------------------------|---------------|
|svn   |other                      |$400,000.00    |
|solidity|programming                |$179,000.00    |
|couchbase|databases                  |$160,515.00    |
|datarobot|analyst_tools              |$155,486.00    |
|golang|programming                |$155,000.00    |
|mxnet |libraries                  |$149,000.00    |
|dplyr |libraries                  |$147,633.00    |
|vmware|cloud                      |$147,500.00    |
|terraform|other                      |$146,734.00    |
|twilio|sync                       |$138,500.00    |

## 5. What are the most optimal skills to learn?
In the last stage of our analysis, I'll focus on identifying the **optimal skills** to pursue by exploring skills that are **both high-paying and appear in a significant number of job postings**. This will provide a more practical roadmap for data analysts. To do that, I'll set a minimum threshold of **50 job postings** to focus on skills with a significant demand in the market.

```sql
WITH skills_demand AS (
    SELECT 
        skills_job_dim.skill_id,
        COUNT(skills_job_dim.job_id) demand_count
    FROM job_postings_fact
    JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
    WHERE skills_job_dim.job_id IN (
            SELECT job_id
            FROM job_postings_fact
            WHERE job_title_short = 'Data Analyst'
                AND salary_year_avg IS NOT NULL
        )
    GROUP BY skills_job_dim.skill_id
),
skills_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        skills,
        ROUND(AVG(salary_year_avg), 0):: money avg_year_salary
    FROM job_postings_fact
    JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
    JOIN skills_dim 
    ON skills_dim.skill_id = skills_job_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
    GROUP BY skills_job_dim.skill_id, skills
)
SELECT 
    skills,
    avg_year_salary,
    demand_count
FROM skills_demand
JOIN skills_salary 
ON skills_demand.skill_id = skills_salary.skill_id
WHERE demand_count >= 50
ORDER BY avg_year_salary DESC
LIMIT 10;
```
Looking at the results below, we can observe the following:

* **Data Infrastructure Tools & Technologies** such as Airflow, Snowflake, Databricks & GCP (Google Cloud Platform) show significant demand with relatively high average salaries ranging from $111,578 to $116,387. This suggests a lucrative crossover between data analysis and engineering, and highlights the value of data pipeline management and cloud technologies.

* **Big Data Technologies** like Hadoop and Spark along with Sacala also have high demand with average salaries ranging between $110,888 and $115,480 pointing towards the growing importance of big data technologies in data analysis.

* **Essential Tools** for project management, collaboration as well as version control like Confluence and Git with average salaries of $114,883 and $112,250 suggest that proficiency in these areas can also enhance a data analyst's profile.

|skills|avg_year_salary            |demand_count   |
|------|---------------------------|---------------|
|airflow|$116,387.00                |71             |
|scala |$115,480.00                |59             |
|linux |$114,883.00                |58             |
|confluence|$114,153.00                |62             |
|gcp   |$113,065.00                |78             |
|spark |$113,002.00                |187            |
|databricks|$112,881.00                |102            |
|git   |$112,250.00                |74             |
|snowflake|$111,578.00                |241            |
|hadoop|$110,888.00                |140            |

# Conclusion

## Key Insights
This project set out to explore the data job market landscape, specifically focusing on Data Analyst roles with the aim of uncovering valuable insights that can guide the career development of aspiring professionals in this field.

Starting with the **top-paying roles**, the data revealed that the highest-earning remote junior data analyst positions offer salaries ranging from **$60,000 to $82,000** per year. These lucrative positions require a **diverse skill set** spanning programming languages, data analysis tools, cloud technologies, and project management tools.

Examining the broader landscape of data analyst jobs, the analysis identified the **most in-demand skills** across the market. Foundational competencies like **SQL, Excel, Python, Tableau, and Power BI** emerged as the most frequently requested by employers. Mastering these core skills should be the top priority for those seeking to build a robust data analysis skillset.

The analysis also uncovered a set of more **specialized skills that are associated with significantly higher average salaries**. These include expertise in specialized programming languages like Solidity, NoSQL Databases like Couchbase, and advanced analytics tools and frameworks like DataRobot and MXNet. Salaries for roles requiring proficiency in these skills can reach as high as $155,000 or more.

To **optimize career development**, the data suggests that data analysts should strive to strike a balance. **Building a strong foundation** in the essential skills should be the first step. But beyond that, **investing in high-demand, high-paying skills** in data infrastructure, big data, and specialized analytics tools can unlock significant earning potential and provide a competitive edge in the job market.

## Data Limitations & Future Analysis
While this analysis provides a comprehensive overview of the data analyst job market, it is important to note some limitations of the data and areas for future exploration:
* **Geographical Scope:** The current analysis focuses on the global market as a whole, but further segmentation by region or country could uncover differences in job opportunities, skill demands, and compensation levels.
* **Timeframe:** This dataset reflects job postings from January 2023 up to December 2023. Expanding the data source to include job postings from a wider and more up-to-date timeframe could reveal evolving trends across years.
* **Industry & Experience Level:** This dataset does not provide information on the industry of the employers or the required experience level. Incorporating these factors could provide deeper contextual understanding of the market.

:exclamation: If you find this repository helpful, please consider giving it a :star:. 
Thanks! :exclamation: