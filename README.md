# paper-replication-code
Replication code and shareable processed data for the manuscript.
# Replication Code and Data

This repository contains the replication code, data documentation, and shareable processed data for the manuscript:

"Green finance curbs direct carbon emissions but exacerbates lifecycle carbon emissions in China's electricity sector"

Data obtained from the Wind Database, the China Electricity Council, and published statistical yearbooks are subject to third-party licensing or copyright restrictions and therefore cannot be redistributed by the authors. The public replication repository provides detailed variable definitions, data-source information, code files, and step-by-step instructions for reconstructing the analytical dataset after users have independently obtained the restricted source data from the relevant providers. Code123 file is the running stata docode.

`RandomForestRegressor.py` documents the machine-learning-based procedure used to address missing values in the `carbon_sum` dataset. A random forest regression model is employed to predict eligible missing observations, thereby producing the balanced panel dataset used in the subsequent analysis.


For questions about the code and data, please contact the corresponding author jl3a17soton@gmail.com
