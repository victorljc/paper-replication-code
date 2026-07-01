# paper-replication-code
Replication code and shareable processed data for the manuscript.
# Replication Code and Data

This repository contains the replication code, data documentation,
and shareable processed data for the manuscript:

"Green finance curbs direct carbon emissions but exacerbates lifecycle carbon emissions in China's electricity sector"

## Repository structure

（1）Original carbon data from CEADS is carbon_sum.xlsx
 (2) code pdf is the smcl file.
## Software requirements

The analysis was conducted using Stata 18.0.

### 

The CEADs emission data and the Peking University Digital Financial Inclusion Index used in this study are available from their original providers, subject to the corresponding terms of use and citation requirements. Based on the permitted use and redistribution conditions of CEADs, the authors have publicly released the author-generated electricity-sector lifecycle carbon-emission dataset constructed from CEADs data.

Data obtained from the Wind Database, the China Electricity Council, and published statistical yearbooks are subject to third-party licensing or copyright restrictions and therefore cannot be redistributed by the authors. The public replication repository provides detailed variable definitions, data-source information, code files, and step-by-step instructions for reconstructing the analytical dataset after users have independently obtained the restricted source data from the relevant providers.

The source code in this repository is licensed under the MIT License.The author-generated electricity-sector lifecycle emissions dataset is provided subject to the attribution and reuse conditions stated in its accompanying data-use notice. Third-party data, including data from Wind, the China Electricity Council, the Peking University Digital Financial Inclusion Index, and published statistical yearbooks, are not covered by the repository license.

`RandomForestRegressor.py` documents the machine-learning-based procedure used to address missing values in the `carbon_sum` dataset. A random forest regression model is employed to predict eligible missing observations, thereby producing the balanced panel dataset used in the subsequent analysis.



## Contact

For questions about the code and data, please contact the corresponding author.
