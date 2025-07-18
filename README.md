# mthm503

This is a template for course MTHM503 "Applications of Data Science and Statistics".  You should fork this repository and use it for your work on this module

Note: in a professional setting, a DevOps engineer (or team of engineers) would be responsible for setting up infrastructure like this. You only have to operate within the infrastructure.  Therefore, you may find yourself working as follows:

1. Develop a script to perform some analysis task.
2. When you are happy with it, wrap it in a function and save it in the functions.R file.
3. You call this function from the _targets.R file in the form 
  tar_target(NAME OF THE OUTPUT, FUNCTION CALL(DATA AND OTHER ARGUMENTS))
4. Run tar_make() in the parent folder. 

# MTHM053 Applications of Data Science and Statistics Coursework

This repository contains my submission for the **MTHM053: Applications of Data Science and Statistics** module at the University of Exeter.

## 📌 Coursework Overview

This project consists of three main analytical tasks, all implemented in R using a reproducible pipeline (`targets`) and version-controlled workflow (`git`, `renv`):

1. **Supervised Classification**  
   Predicting the severity of pedestrian-involved accidents using features like weather, lighting, age, sex, and location.

2. **Regression Modelling**  
   Exploring the relationship between age, sex, and the method of extrication used by fire services after vehicle collisions.

3. **Unsupervised Learning**  
   Performing PCA and clustering on olive oil composition data to analyze natural variation among non-adulterated samples.

---

## 🧪 Workflow & Reproducibility

This project uses modern R tools for workflow management and reproducibility:

- [`targets`](https://books.ropensci.org/targets/) — pipeline management
- [`renv`](https://rstudio.github.io/renv/) — dependency management
- [`testthat`](https://testthat.r-lib.org/) — unit testing
- [`lintr`](https://github.com/r-lib/lintr) — style checking via GitHub Actions

To reproduce this project:

```r
# Clone the repo and open in RStudio
renv::restore()           # Restore package environment
targets::tar_make()       # Build the analysis pipeline



