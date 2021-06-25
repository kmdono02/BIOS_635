# Predict with glmnet, caret, or other algorithms

get_preds <- function(mod, new_dat, frmla=NULL, pred_type="response") {
  y_vrbl <- all.vars(frmla)[1]
  preds <- data.table(obs = new_dat[, get(y_vrbl)])
  
  ## For glmnet ##$##$
  if(class(mod)[[1]] == "cv.glmnet") {
    x_test <- model.matrix(frmla, data=new_dat)[, -1]
    preds[, pred := predict(mod, s="lambda.min", newx=x_test, type=pred_type)]
    
    ## For usual predict() ##$##$
  } else {
    # Using 1 observation to get length bc predict.train can give 2 columns
    p <- length(predict(mod, newdata=new_dat[1], type=pred_type))
    
    preds[, pred := as.matrix(
      predict(mod, newdata=new_dat, type=pred_type)
    )[, p] ] # Use only last column if p > 1
    
  }
  return(preds)
}
