import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

from sklearn.linear_model import LassoCV
from doubleml import DoubleMLPLR
from doubleml import DoubleMLData

# data
GrowthData=pd.read_csv('https://github.com/albarran/TopicsCausalInference/raw/main/data/GrowthData.csv')


y = GrowthData['Outcome']
X = GrowthData.iloc[:,1:63]

# OLS 
model = sm.OLS(y,X)
results = model.fit()
print(results.summary())

#Double ML
columns=list(X.columns[2:])

# Data and Variables for the causal model
dml_GrowthData = DoubleMLData(GrowthData,
                              y_col='Outcome',
                              d_cols='gdpsh465',
                              x_cols=columns)



y_model = LassoCV()
d_model = LassoCV()

np.random.seed(3141)

obj_dml_plr_bonus = DoubleMLPLR(dml_GrowthData, y_model, d_model)

obj_dml_plr_bonus.fit()

print(obj_dml_plr_bonus)
