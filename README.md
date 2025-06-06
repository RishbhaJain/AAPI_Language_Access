# Language & Equity Analysis (IPUMS ACS)

Analyzes English proficiency, education, and health insurance by race using IPUMS ACS microdata to support policy evaluation (e.g., CA AB 413).

## Steps to Run

1. Install R packages:
   ```r
   install.packages(c("ipumsr", "janitor", "tidyverse", "ggplot2", "dplyr", "haven"))
2.Download usa_00002.xml and .dat.gz from ipums.org.
3. Run the script.

## Output

1. Education and insurance plots
2. Pie chart of top LEP languages in CA
3. Chi-square tests + regression summary

