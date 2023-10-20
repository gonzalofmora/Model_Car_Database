# Model Car Storage Analysis
## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning/Preparation](#data-cleaning/preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [References](#references)

### Project Overview
In this project we leveraged the power of data analysis techniques in order to provide data-driven insights that helped the model car company Mint Classics in their business decision of closing a storage facility


### Data Sources

Relational Database: [mintclassics.db](https://www.coursera.org/projects/showcase-analyze-data-model-car-database-mysql-workbench)

### Tools

- MySQL 


### Exploratory Data Analysis

EDA involved exploring the RDBM to answer key questions, such as:

- Which warehouse should be considered for closure based on data analysis and optimization of space and profits?
- What is the relationship between product sales, profitability, and warehouse performance?


### Data Analysis

To complete the project, we utilized a multifaceted data analysis approach. We started by extracting data from relevant tables and created temporary tables to store intermediate results. Then, we aggregated, transformed, and filtered data, focusing on completed orders. Data from multiple tables were joined to combine relevant information. While not present in the code, we prepared the data for potential visualization or reporting.
Leveraging these techniques, we successfully identified Warehouse C as the prime candidate for closure. This data-driven solution aligns with the project's objectives by providing actionable recommendations for inventory reduction and warehouse optimization, enhancing operational efficiency and profitability for Mint Classics Company.

### Recommendations

- Close Warehouse C: Given its underutilization and lower contribution to profits compared to other warehouses, consider closing Warehouse C. This will help optimize space and reduce operational costs.
- Redistribute Inventory: Distribute the inventory from Warehouse C to the remaining warehouses, prioritizing those with higher space utilization and profitability, like Warehouse B.
- Review Product Pricing: Analyze and potentially standardize product pricing to ensure consistency and fairness, considering quantity discounts to maximize revenue.
- Monitor Low-Demand Products: Continuously assess and consider discontinuing products with consistently low demand to streamline production and reduce storage costs.

### Limitations

- Limited Scope: The analysis is based on the data available up to a specific date and may not reflect the current state of the business.
- Assumptions: The project relies on certain assumptions about product demand, pricing, and cost, which may not hold true in practice.
- Cost Analysis: The project does not include a comprehensive cost analysis associated with warehouse closure and inventory redistribution, which is crucial in decision-making.
  
### Further improvements

Here are some question for further analysis:
- How can inventory be redistributed among the remaining warehouses to ensure efficient storage and order fulfillment? 
- Are there products with low demand that should be considered for discontinuation or removal from the production line?


### References

The Project problem and overview was from Coursera. [Link here](https://www.coursera.org/projects/showcase-analyze-data-model-car-database-mysql-workbench)
