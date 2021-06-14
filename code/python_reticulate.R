# https://rstudio.github.io/reticulate/articles/python_packages.html

library(reticulate)

# create a new environment 
conda_create("r-reticulate")

# install SciPy
conda_install("r-reticulate", "scipy", "pandas", "statsmodels")

conda_install("conda-forge", "statsmodels")
