## Allows adding custom tuning parameters within the train set 

## args_tune list of length 2 e.g., list(param="frmla", vals=list_of_vals)
nest_tune <- function(args_tune, args_set, train_data, 
                      func_min = function(m) {1 - m[["results"]][["Accuracy"]]}, 
                      seed=NULL) { 
  
  req_args <- c("frmla", "fit_method", "train_data")
  
  tune_fits <- lapply(args_tune[["vals"]], function(val) {
    set.seed(seed)
    
    ls_tune <- list(val) %>% `names<-`(args_tune[["param"]])
    unlst_args <- c(list(train_data=train_data), ls_tune, args_set)
    
    fit <- do.call(
      fit_mod, c(unlst_args[req_args], 
                 list(argmnts = unlst_args[!names(unlst_args) %in% req_args]))
    )
    return(fit)
  })
  
  best_within <- lapply(tune_fits, function(x) { min(func_min(x)) })
  best_overall <- tune_fits[[ which.min(unlist(best_within)) ]]
  
  best_overall[["cust_tune"]] <- 
    args_tune[["vals"]][[ which.min(unlist(best_within)) ]]
  return(best_overall)
}


