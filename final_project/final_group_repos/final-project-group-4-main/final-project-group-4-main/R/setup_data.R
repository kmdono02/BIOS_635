require(tidyverse)
require(data.table)
require(caret)
require(splines)
require(glmnet)
require(pROC)


## Import & format values for R ##$##$
suppressWarnings(load("./Inputs/v_t2.Rdata"))

setDT(v_t2)
v_t2[v_t2==""] <- NA
v_t2[VAX_MANU == "PFIZER\\BIONTECH", VAX_MANU := "PFIZER"] 



## Predictors ##$##$#
xvars <- c("SEX", "VAX_MANU", "VAX_DOSE_SERIES", "PriorAllergy", "PriorVaxAE", 
           "cur_htn", "cur_dm", "cur_copd", "cur_cancer", "cur_hf", "cur_MI", 
           "cur_ckd", "cur_dialysis", "cur_stroke", "AGE_YRS")

## Select columns and factor categorical variables ##$
catvars <- xvars[xvars != "AGE_YRS"]
dat_all <- v_t2[, c("VAERS_ID", "SeriousEvent", "NUMDAYS", xvars), with=F] %>% 
  mutate_at(eval(catvars), factor) %>%
  setDT()



## DATA FOR ANALYSIS ##$##$
dat <- dat_all[, ':='(event_asfac = relevel(factor(SeriousEvent), ref="0"),
                      event_asnum = as.numeric(as.character(SeriousEvent)))
][NUMDAYS <= 4] # ONLY USE 4 OR LESS DAYS BW VAX AND EVENT 

rm(v_t2, dat_all); gc()



