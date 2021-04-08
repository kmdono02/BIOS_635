library(tidyverse)
library(caret)
library(DMwR)
library(pROC)
library(cutpointr)

ibis_data <- read_csv("../data/fyi_data.CSV") %>%
  filter(grepl("HR", `HR ASD versus HR_Neg`)) %>%
  mutate(asd_group = factor(ifelse(Groups=="HR_ASD", "HR_ASD", "HR_Neg"))) %>%
  select(FYIq_1:FYIq_60, asd_group)
ibis_data <- data.frame(lapply(ibis_data, as.factor))

test_roc <- list()
k=5
tt_indices <- createFolds(y=ibis_data$asd_group, k=k)

for(i in 1:k){
  train_data <- ibis_data[tt_indices[[i]],]
  test_data <- ibis_data[-tt_indices[[i]],]
  
  # SMOTE training set AFTER creating train and test sets
  train_smote <- SMOTE(asd_group~., data=train_data, perc.under = 150)
  
  # Use random forest for example
  rf_fit <- train(asd_group~., data = train_smote, 
                  method = "rf",
                  trControl=trainControl(method="cv", number=2))
  
  test_predict <- predict(rf_fit, newdata = test_data, type="prob")
  
  test_roc[[i]] <- data.frame("asd_group"=test_data$asd_group, 
                              "prob"=test_predict$HR_ASD,
                              "fold"=i)
}

all_test_data <- do.call("rbind", test_roc)

# Compute mean roc curve
mean_roc <- function(data, cutoffs = seq(from = 0, to = 1, by = 0.01)) {
  map_df(cutoffs, function(cp) {
    out <- cutpointr(data = data, x = prob, class = asd_group,
                     subgroup = fold, method = oc_manual, cutpoint = cp,
                     pos_class = "HR_ASD", direction = ">=")
    data.frame(cutoff = cp, 
               sensitivity = mean(out$sensitivity),
               specificity = mean(out$specificity))
  })
}
mr <- mean_roc(all_test_data)

# Plot
ggplot(data=mr, aes(x = 1 - specificity, y = sensitivity)) + 
  geom_step() +
  geom_abline(mapping=aes(intercept=0, slope=1), linetype="dashed") +
  theme(aspect.ratio = 1)

cutpointr(data = all_test_data, x = prob, class = asd_group,
          subgroup = fold,
          pos_class = "HR_ASD", direction = ">=") %>%
  plot_roc(display_cutpoint = F) +
  geom_abline(mapping=aes(intercept=0, slope=1), linetype="dashed") +
  geom_step(data=mr, aes(x = 1 - specificity, y = sensitivity), inherit.aes = FALSE) +
  theme(legend.position="none",
        aspect.ratio = 1)
ggsave("roc_example.jpg", scale=2, limitsize = FALSE)



