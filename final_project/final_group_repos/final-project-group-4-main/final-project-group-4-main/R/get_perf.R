# Compute predictive error for continuous or categorical Y

get_perf <- function(dt, type= NULL, observed="obs", predicted="pred", p_thresh=0.5) {
  
  ### Set-up ##$##$##$##$##$##$##$##$##$##$##$##$
  setnames(setDT(dt), old=c(observed, predicted), new=c("obs", "pred"))
  
  ## Determine Y categorical or continuous
  if(is.null(type)) { 
    type <- ifelse(class(dt$obs) %in% c("factor", "character"), "categ", "cont")
  }
  
  
  ### Get performance ##$##$##$##$##$##$##$##$##$##$
  
  ## If continuous - use postResample()
  if(type=="cont") { 
    perf <- as.data.table(t( postResample(pred=dt$pred, obs=dt$obs) )) %>% 
      .[, .(RMSE, MSE=RMSE^2, R2=Rsquared, MAE)]
    
    ## If categorical - get by-class error
  } else if(type=="categ") {
    
    if(any(!unique(dt$pred) %in% unique(dt$obs))) {
      dt[, ':='( pred = as.numeric(pred>eval(p_thresh)))]
      # obs =  as.numeric(obs) - as.numeric(class(obs)=="numeric"),          
      #obs = ifelse(class(obs)=="numeric", obs, as.numeric(obs)-1),
    }
    
    perf <- dt[, correct := as.numeric(obs==pred)
    ][, .(Accuracy = mean(correct),
          Error = 1 - mean(correct)), by="obs"]
  }
  return(perf)
}


