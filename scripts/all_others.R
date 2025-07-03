##Code of all other plots given in the supplementary materials
library(dplyr)
library(ggplot2)
library(broom)
library(survival)
library(survminer)


#Hierarchical clustering
df_boolean = df[,benign] %>% mutate(across(everything(), ~ .x == "True"))*1
pearson_mat <- cor(df_boolean, method = "pearson") #here, we used pearson
pearson_dist <- as.dist(1 - pearson_mat)
hc_pearson <- hclust(pearson_dist, method = "ward.D2")  #there are other methods as well
plot(hc_pearson, main = "Hierarchical Clustering (1 - Pearson Correlation)") #produces figure in supplementary materials
clusters <- cutree(hc_pearson, k = 3) #creates the cluster based on the rules
table(clusters) 


#Kaplan-meier plots
km_fit <- survfit(Surv(trunc_OS, death) ~ lobular, data = df)

km1 = ggsurvplot(km_fit, data = df,
                 pval = TRUE,
                 pval.coord = c(0.75, 0.8),
                 conf.int = TRUE,
                 risk.table = TRUE,
                 legend.title = "Group",
                 legend.labs = c("Absent", "Present"),
                 ylim = c(0.65, 1),
                 palette = c("grey40", "steelblue"),
                 title = "Lobular neoplasia")


#Logistic/poisson regression between presence/number of benign feature against stage (tnm)
overreporting_test <- glm(any_benign ~ tnm, data = df, family = binomial)
summary(overreporting_test)
tidy(overreporting_test, exponentiate = TRUE, conf.int = TRUE)

pois_model = glm(n_benign ~ tnm, family = poisson(), data = df)
tidy(pois_model, exponentiate = TRUE, conf.int = TRUE)