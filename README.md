# AAPI_Language_Access
Language Access and Policy Impact Analysis Using IPUMS Census Data
This project analyzes the relationship between English language proficiency and key socio-economic outcomes—specifically education and health insurance coverage—across major racial groups in the U.S. The analysis is contextualized within the framework of California Assembly Bill AB 413, which mandates language access in housing notices.

📁 Project Structure
graphql
Copy
Edit
.
├── usa_00002.xml              # IPUMS DDI metadata file
├── usa_00002.dat.gz           # IPUMS data file (must be downloaded from IPUMS USA)
├── analysis.R                 # Main analysis script
├── education_plot.png         # Output: Education vs English proficiency plot
├── insurance_plot.png         # Output: Insurance vs English proficiency plot
└── README.md                  # This file
🚀 Objectives
Summarize the number and distribution of non-English speakers across racial groups.

Quantify how language proficiency impacts:

Educational attainment

Health insurance coverage

Support policy analysis of AB 413 using empirical evidence from microdata.

Highlight limitations and areas for improvement in current policy frameworks.

📦 Dependencies
Ensure you have the following R packages installed:

r
Copy
Edit
install.packages(c("ipumsr", "janitor", "tidyverse", "ggplot2", "dplyr", "haven"))
🧠 Data Source
IPUMS USA (ACS samples): https://usa.ipums.org/usa/

Key variables used:

SPEAKENG — English proficiency

EDUC — Educational attainment

HCOVANY — Health insurance status

RACE — Race

LANGUAGE — Primary language spoken at home

📊 How to Run
Download your IPUMS extract (include relevant variables and PUMAs for California).

Place the *.dat.gz and *.xml files in your working directory.

Run the analysis.R script in R or RStudio.

The script will:

Clean and filter the dataset.

Generate plots for education and insurance outcomes.

Conduct Chi-square tests to measure statistical significance.

Save visualizations as PNGs.

📈 Outputs
education_plot.png: Stacked bar chart of education levels by English proficiency and race.

insurance_plot.png: 100% stacked bar chart of insurance coverage by English proficiency and race.

Chi-square test outputs for both education and insurance.

📝 Policy Relevance
The analysis supports evaluation of AB 413 by:

Demonstrating how limited English proficiency correlates with lower access to education and healthcare.

Revealing gaps in language access protections, especially for smaller or less visible AAPI subgroups.

Providing evidence to guide more inclusive and effective implementation strategies.

🇮🇳 Author Perspective
As an international student from India, I bring a firsthand understanding of how language can act as both a barrier and bridge to opportunity. This project reflects a broader commitment to data-driven, inclusive policymaking.

