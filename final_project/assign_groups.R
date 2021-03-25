library(tidyverse)

roster <- read_csv("roster.csv") %>%
  select(Name, `github id`, number) %>%
  drop_na()

# Randomly assign to 6 groups of ~4
groups <- data.frame(cbind("Name"=sample(x=roster$Name, size=length(roster$Name)),
      "group"=c(rep(1, 4), rep(2, 4), rep(3, 4), 
                rep(4, 4), rep(5, 4), rep(6, 3))))

write_csv(x=groups, file="group_assignments.csv")