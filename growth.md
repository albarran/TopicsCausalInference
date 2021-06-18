---
title: "Growth example"
output: html_document
---

# The standard growth convergence empirical model

<img src="https://render.githubusercontent.com/render/math?math=Y_{i,T}=\alpha_{0}+\alpha_{1} Y_{i,0}+\sum_{j=1}^{k} \beta_{j} X_{i j}+\varepsilon_{i},\quad i=1,\dots,n">

where 

  - <img src="https://render.githubusercontent.com/render/math?math=Y_{i,T}"> national growth rates in GDP per capita for the periods 1965-1975 and 1975-1985.

  - <img src="https://render.githubusercontent.com/render/math?math=Y_{i,0}"> is the log of the initial level of GDP at the beginning of the specified decade.

  - <img src="https://render.githubusercontent.com/render/math?math=X_{ij}"> covariates which might influence growth.


* The growth convergence hypothesis implies that <img src="https://render.githubusercontent.com/render/math?math=\alpha_1<0">.


# Growth data

To test the growth convergence hypothesis, we will make use of the Barro and Lee (1994) dataset

  * [Growth Data](https://github.com/albarran/TopicsCausalInference/raw/main/data/GrowthData.csv)

Also available in R

```
data("GrowthData")
```

The data contain macroeconomic information for large set of countries over several decades. In particular,

- n = 90 countries
- k = 60 country features

Not so big...

Nevertheless, the number of covariates is large relative to the sample size, so variable selection is important!


   * [R code](https://github.com/albarran/TopicsCausalInference/blob/main/code/Growth.R)
   
   * [Stata code](https://github.com/albarran/TopicsCausalInference/blob/main/code/growth.do)

   * [Python code](https://github.com/albarran/TopicsCausalInference/blob/main/code/growth.do)   
   
   