Objective:  
To predict an individual's income level based on demographic, educational, and employment characteristics. 

Predict Income Bracket: 
Determine whether a person earns more than $50,000 per year or less, utilizing features such as age, education, marital status, occupation, race, gender, capital gain, capital loss, hours per week, and native country.

Analyze Demographic Influence: 
Understand how different demographic and work-related factors contribute to an individual's income level, helping to uncover patterns and insights related to economic and social aspects.

Modelling:
Performed Proc Logistic Regression Model with the result of c-statistics above 0.885

Strong Predictive Relationship: The model exhibits a strong predictive relationship between the features and the target variable, as indicated by high Somers' D and Gamma values (approx. 0.77 for both)
suggests that the model accurately ranks the likelihood of outcomes.

Consistency Across Datasets: The similarity in performance metrics between the training and testing datasets, with high percent concordant and c-statistics (above 0.885), 
implies the model's robustness and reliability across different data samples.

Effective Differentiation: The low discordance rate (around 11.5% for training and 11.4% for testing) indicates the model's effectiveness in differentiating between binary outcomes.

Key Findings:
Strong correlation between education level and working hours.
Income distribution: More individuals earning <=50K.

Prescriptive Analysis:
Model Accuracy: The model demonstrates high accuracy in classifying and predicting outcomes, making it a reliable tool for decision-making where predicting the likelihood of the outcome is crucial.
Reliability and Generalization: The consistency in performance across both training and testing datasets indicates that the model generalizes well and is not overfitting.
Usefulness in Decision-Making: The strong performance metrics suggest the model's usefulness in contexts where understanding and predicting the binary outcome is important.




