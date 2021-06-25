# Get a threshold from wtd sens and spec (default weight equiv to Youden's J)

roc_thresh <- function(mod, train_data, frmla=NULL, wt_sens=1, wt_spec=1) {
  
  preds <- get_preds(mod, new_dat=train_data, frmla=frmla)
  
  ## ROC Curve and Threshold ##$
  curve <- roc(obs ~ pred, data=preds, 
               levels=levels(as.factor(preds$obs)), direction = "<")
  all_thresh <- as.data.table(curve[c("thresholds", "sensitivities", "specificities")])
  
  ## Wtd sens and spec, default weight equiv to Youden's J ##$
  all_thresh[, wtd_sum := (wt_sens*sensitivities) + (wt_spec*specificities) - 1]
  
  # all_thresh[max(wtd_sum)==wtd_sum, thresholds]
  p_thresh <- all_thresh[order(-wtd_sum)][1, thresholds] # This seems faster
  
  return(p_thresh)
}


