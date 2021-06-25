BIOS 635 Final Project
Group 4
Chris Moore, Jose Lopez, Alice Yu, & Tian Wang


**  This README describes the workflow and files for our analysis  **



**OVERVIEW**
- The three R Markdown files in the parent directory can be used to conduct all analyses
	a) "Create_Table1.Rmd" generates a table with sample descriptive statistics (by TW)
	b) "Tune_Train_Test.Rmd" conducts all analyses for the random forest and logistic LASSO algorithms (by CM)
	c) "Summarize_Results.Rmd" creates all tables and figures besides Table 1 (by CM)

- All R scripts are located in the ./R directory and most contrain a single function. 
- Each R script is sourced within Markdown files b) and c) 


################################################################################################


**ANALYSES** 
(see "Tune_Train_Test.Rmd")

- Designed such that all tuning parameters and arguments for a given method (random forest or LASSO) can be set in the first corresponding code block
	- Remainder of code section can then be run using those inputs

- The `kfold_cv()` function is the primary function used for generating our results (see "./R/kfold_cv.R")
	- This function combines the other custom functions into a loop for the k folds
	- If reviewing all the functions nested within `kfold_cv()`, here a suggested order:
	a) Review `kfold_cv()` until lines 55:57, where `fit_mod()` or `nest_tune()` is called via `f_fit <- do.call(...)`
	b) Look at `nest_tune()` in "./R/nest_tune.R", which uses `lapply()` over custom tuning parmeters, applying `fit_mod()` each time
		- The output will just be a list of models. The user-specified `func_min()` is used to extract what should be minimized
	c) Go to `fit_mod()`, which provides a method of using the same function to fit different methods (mainly because glmnet requires matricies)
	d) Go back to `kfold_cv()` lines 55:57, and continue reviewing this and other functions as they are used
	e) `roc_thresh()` is used to get a probability threshold in lines 63:65 (if asked for)
	e) `get_preds()` is used to predict in lines 72:73
	f) `get_perf()` is used to get RMSE/MAE/R^2^ (if continuous) or per-class error (if categorical) in line 77
	g) Then finish reviewing `kfold_cv()`

- We ran the logistic LASSO section twice, once with wt_se=1; wt_sp=1 and once with wt_se=0.8; wt_sp=1.2


################################################################################################


**SUMMARIZE RESULTS** 
(see "Summarize_Results.Rmd")
- The code in this file is relatively straghtforward
- The input is three lists output by `kfold_cv()`


