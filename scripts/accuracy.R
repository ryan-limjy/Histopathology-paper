##API sensitivity
# NOTE: In the original analysis, 200 samples were drawn.
# The dummy dataset contains only 10 rows and will cause sampling errors.
# This script is included to illustrate the logic, not to be run as-is.

library(dplyr)       
library(purrr)

set.seed(123) 
#Example:
#benign = c("DCIS", ADH", "ALH")


#200 stratified samples 
#Dataset is divided into 8 bins
#0, 1, 2, >2 benign features present * length of freetext (greater or less than 4000 words)
df <- df %>%
  mutate(
    benign_bin = case_when(
      n_benign == 0 ~ "0",
      n_benign == 1 ~ "1",
      n_benign == 2 ~ "2",
      n_benign >= 3 ~ "3+"
    ),
    length_bin = if_else(nchar < 4000, "short", "long"),
    stratum = interaction(benign_bin, length_bin, drop = TRUE)
  )

#15 samples from each bin (120 total)
fixed_ids <- df %>%
  group_by(stratum) %>%
  slice_sample(n = 15) %>%
  ungroup() %>%
  select(ID)

#remaining 80 samples drawn based on quantiles of the bins
remaining_df <- df %>%
  filter(!ID %in% fixed_ids$ID)

stratum_sizes <- remaining_df %>%
  count(stratum, name = "N_total")

prop_samples <- stratum_sizes %>%
  mutate(
    prop = N_total / sum(N_total),
    n_alloc = round(prop * 80)
  )

remaining_with_alloc <- remaining_df %>%
  left_join(prop_samples, by = "stratum")

prop_ids <- remaining_with_alloc %>%
  group_split(stratum) %>%
  map_dfr(~ slice_sample(.x, n = .x$n_alloc[1])) %>%
  select(ID)

sampled_ids <- bind_rows(fixed_ids, prop_ids)
sampled_freetext = freetext %>% filter(ID %in% sampled_ids$ID) %>% arrange(ID)
sampled_API = df %>% filter(ID %in% sampled_ids$ID) %>% select(all_of(c("ID", benign))) #benign is a vector of all the benign features


#Just to change "True" to T (boolean)
sampled_API <- sampled_API %>%
  mutate(across(-ID, ~ .x == "True"))

#import the results from expert verification
#verified = read.csv(...) 


#combined dataframe of both the API and verified 200 samples
combined <- sampled_API %>%
  rename_with(~ paste0(.x, "_api"), -ID) %>%
  inner_join(
    verified %>% rename_with(~ paste0(.x, "_human"), -ID),
    by = "ID"
  )

#all accuracy metric reported are calculated here
sensitivity <- lapply(benign, function(f) {
  api_col <- paste0(f, "_api")
  human_col <- paste0(f, "_human")
  
  api_vals <- combined[[api_col]]
  human_vals <- combined[[human_col]]
  
  TP <- sum(api_vals & human_vals) #true positive
  TN <- sum(!api_vals & !human_vals) #true negative
  FP <- sum(api_vals & !human_vals) #false positive
  FN <- sum(!api_vals & human_vals) #false negative
  
  sensitivity <- TP / (TP + FN)
  specificity <- TN / (TN + FP)
  ppv <- TP / (TP + FP)
  npv <- TN / (TN + FN)
  accuracy <- (TP + TN) / (TP + TN + FP + FN)
  
  data.frame(
    Feature = f,
    Sensitivity = round(sensitivity, 3),
    Specificity = round(specificity, 3),
    PPV = round(ppv, 3),
    NPV = round(npv, 3),
    Accuracy = round(accuracy, 3),
    TP = TP, FP = FP, FN = FN, TN = TN
  )
}) %>%
  bind_rows()