##Odds/hazard ratio (Multinomial logistic regression & Cox proportional hazard)

#All odds/hazard ratios in the paper were calculated in this manner, results are derived by using 
#different datasets/adjustments
library(dplyr); library(nnet); library(broom); library(survival)

#Main function used to summarise results
#Converts list of all regression results into formatted table 
#FDR is also calculated using this function
process_results <- function(results_list, benign_levels) {
  final_results <- do.call(rbind, results_list) %>%
    mutate(
      OR_CI = sprintf("%.2f (%.2f, %.2f)", estimate, conf.low, conf.high),
      p_adj = p.adjust(p.value, method = "fdr"),
      significance = case_when(
        p.value < 0.05 & p_adj >= 0.05 ~ "Significant (raw p)",
        p_adj < 0.05 ~ "Significant (FDR)",
        TRUE ~ "NS"
      )
    ) %>%
    select(factor, OR_CI, significance) %>%
    mutate(factor = factor(factor, levels = benign_levels)) %>%
    arrange(factor)
  
  return(final_results)
}

#Univariate logistic regression is performed for a fixed outcome (y) against all the benign factors (x)
#In this example, the outcome is stage (tnm)
#benign is the list of all histopathology factors explored
#Example: 
#benign = c("ADH", "ALH")

benign = c("ADH", "ALH")
results_list <- list()
# Fit model for each benign factor
for (factor_var in benign) {
  formula <- as.formula(paste("tnm ~", factor_var, "+ age + race + menopause + famhx + child + dx_year")) #Adjust variables here
  model <- multinom(formula, data = df, trace = FALSE) #df is a placeholder for the dataframe
  tidy_model <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
  
  filtered <- subset(tidy_model, y.level == "Stage 2" & grepl(paste0("^", factor_var), term)) #For outcomes with multiple levels of interest, change y.level
  filtered$factor <- factor_var
  
  results_list[[factor_var]] <- filtered
}
final_results = process_results(results_list, benign) 


#Hazard ratios are calculated with coxph
#Survival is truncated to 10 years, hence trunc_OS

results_list <- list()
for (factor_var in benign) {
  formula <- as.formula(paste("Surv(trunc_OS, death) ~", factor_var, "+ age + dx_year")) #Adjust variables here
  model <- coxph(formula, data = df) #df is a placeholder for the dataframe
  tidy_model <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
  
  ph_test <- cox.zph(model)
  ph_pval <- tryCatch({
    ph_test$table[rownames(ph_test$table) == factor_var, "p"]
  }, error = function(e) NA)  
  
  filtered <- subset(tidy_model, grepl(paste0("^", factor_var), term))
  filtered$factor <- factor_var
  filtered$ph_pval <- ph_pval #proportional hazard assumption test p-value
  filtered$ph_ok <- ifelse(!is.na(ph_pval) & ph_pval > 0.05, TRUE, FALSE) #returns T if assumption is met
  
  results_list[[factor_var]] <- filtered
}
final_results = process_results(results_list, benign)