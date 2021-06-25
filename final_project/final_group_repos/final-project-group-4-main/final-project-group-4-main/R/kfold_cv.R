# Function to perform k-fold CV with functions above
# Output trained models, test set preds, and/or test set performance   

kfold_cv <- function(dat, k = 5, seed = NULL, pred_type = "response", y_class = NULL,
                    p_thresh=0.5, wt_sens=1, wt_spec=1,  # can set p_thresh to "roc"
                     ret_mods = FALSE, ret_preds = FALSE, # What to retur
                     # For no nest_tune() i.e., just fit_mod()
                     method = NULL,  use_tune = NULL, frmla=NULL, argmnts=NULL, 
                     # For nest_tune() 
                     args_tune=NULL, args_set=NULL, func_min=NULL) { 
  
  #### SET-UP #############################################
  setDT(dat)
  
  ## Create folds ##$##$##$##$
  # Get formula ##$
  find_frmla <- unlist(list(args_tune, args_set, frmla))
  frmla_forY <- find_frmla[sapply(find_frmla, is_formula)][[1]]
  y_vrbl <- all.vars(frmla_forY )[1]
  
  # Split ##$
  set.seed(seed)
  folds <- createFolds(y=unlist(dat[, eval(y_vrbl), with=F]), k=k)
  ##$##$##$##$##$##$##$
  
  
  ## Select function and arguments ##$##$##$##$
  # (this better than ifelse() within a loop)
  if(is.null(args_tune)) {
    func <- fit_mod
    all_args <- list(frmla=frmla, method=method, argmnts=argmnts, use_tune=use_tune)
  } else {
    func <- nest_tune
    all_args <- list(args_tune=args_tune, args_set=args_set, seed=seed, func_min=func_min)
  }
  ##$##$##$##$##$##$##$
  
  
  # In case new p from ROC ##$
  p <- p_thresh
  # What to return ##$
  out <-  c("mod_train", "preds_test", "perf_test")[c(ret_mods, ret_preds, TRUE)]
  ##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$
  
  
  
  #### LOOP FOLDS #############################################
  fold_res <- list()
  for(f in 1:k) {
    dat_train <- dat[ -folds[[f]], ]
    dat_test <- dat[ folds[[f]], ]
    
    ## Train model ##$##$
    # Fit ##$
    f_fit <- do.call(
      func, c(all_args, list(train_data = dat_train))
    )
    # Get final formula, wherever it is ##$
    frmla <- unlist(list(args_set$frmla, f_fit$cust_tune))[[1]]
    
    # If ROC for prob threshold ##$
    if(p_thresh == "roc") {
      p <- roc_thresh(mod = f_fit, train_data = dat_train, 
                      frmla = frmla, wt_sens = wt_sens, wt_spec = wt_spec)
      f_fit[["p_thresh"]] <- p
    }
    ##$##$##$##$##$##$##$
    
    
    ## Test model ##$##$
    # Predict ##$
    test_preds <- get_preds(mod = f_fit, new_dat = dat_test,
                            frmla=frmla, pred_type=pred_type)
    test_preds[, ':='(pred_raw = pred)] # keep original probabilities
    
    # Get acc/error ##$
    test_perf <- get_perf(test_preds, type=y_class, p_thresh=p)
    
    # Save model and predictions ##$
    fold_res[[paste0("fold", f)]] <- list(
      mod_train=f_fit, preds_test=test_preds, perf_test=test_perf
    )[out]
  
  } ## End loop ##$##$##$##$##$##$
  ##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$##$
  
  
  
  #### FORMAT OUTPUT #############################################
  ## List is nested by fold (length k = n folds) 
  ## Want it nested by `out` (length==length(out)) ##$##$
  all_res <- lapply(out, function(x) { lapply(fold_res, `[[`, x) })
  names(all_res) <- out
  
  ## Convert parts to data.table ##$##$
  all_res$perf_test <- rbindlist(all_res$perf_test, idcol="f")
  all_res$preds_test <- rbindlist(all_res$preds_test, idcol="f")
  
  return(all_res)
}
