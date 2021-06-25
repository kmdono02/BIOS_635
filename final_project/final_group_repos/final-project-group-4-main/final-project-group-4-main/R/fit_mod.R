# Fit with train(), cv.glmnet(), tune(), etc.

fit_mod <-  function(frmla, fit_method = "train", train_data, argmnts,
                     args_tune=NULL, use_tune = FALSE) {
  
  y_vrbl <- all.vars(frmla)[1]
  
  ### FOR CV.GLMNET ##################
  if(fit_method=="cv.glmnet") {
    x_train <- model.matrix(frmla, data=train_data)[, -1]
    func <- fit_method
    all_args <-  c(list(x = x_train, y = train_data[, get(y_vrbl)]), argmnts)
    
    ### FOR OTHER METHODS ##################
  } else {
    # If using tune() ##$
    if(use_tune == TRUE) {
      func <- "tune"
      all_args <-  c(list(eval(fit_method), frmla, data=train_data), argmnts)
      ## Else use func in `method` ##$
    } else {
      func <- fit_method
      all_args <- c(list(frmla, data=train_data), argmnts)
    }
  }
  mod <- do.call(get(fit_method), all_args)
  return(mod)
}


