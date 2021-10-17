library(ggplot2)
library(BayesFactor)
library(emmeans)
library(reshape)
library(ggpubr)
library(car)
library(PairedData)
rm(list = ls()) # clears environment
cat("\f") # clears console
dev.off() # clears graphics device
graphics.off() #clear plots
options(scipen = 999) #0 = re-enable. Add to ~/.RProfile to set as default.

#---- Setup ----#
# wd <- "/imaging/ek03/MVB/FreeSelection/MVB/R"
wd = dirname(rstudioapi::getActiveDocumentContext()$path); setwd(wd)
rawDir = "csv"
outImageDir = 'images'
dir.create(outImageDir)

#---- Load Data ----#
rawD <- read.csv(file.path(rawDir,'data_taskDiff_wide_absErr.csv'), header=TRUE,sep=",")
df = rawD
df = subset(df, select = -c(PP_session1,PP_session2,AP_session1,AP_session2) ) 
df <- melt(df,id=c('ID_num','PrismGroup'))

names(df)[1] <- "ID_num"
names(df)[2] <- "PrismGroup"
names(df)[3] <- "Task"
names(df)[4] <- "Diff"

df$ID_num = as.factor(df$ID_num)
df$Task = as.factor(df$Task)
df$PrismGroup = as.factor(df$PrismGroup)
df = na.omit(df)
sapply(df, class)

### 
## Effect of task (ttest method - Too crude - not using!)
tmpDf = as.data.frame(df$Diff[1:23])
tmpDf[,2] = as.data.frame(df$Diff[24:46])
names(tmpDf)[1] <- "PP"
names(tmpDf)[2] <- "AP"
t.test(tmpDf$PP, tmpDf$AP, paired = TRUE)
#Bayes Factor
bf10 = ttestBF(x = tmpDf$PP, tmpDf$AP); bf10
bf01 = 1/bf10;bf01
#plot
pd = paired(tmpDf_PP,tmpDf_AP)
plot(pd, type = "profile") + theme_bw()

  



lmmodel = lm(Diff ~ Task,
             data = df); summary(lmmodel)
#Get Bayes Factor
full = lmBF(Diff ~ Task,
     data = df)

bf10 = full[4] / null[3]
bf01 = 1/bf10; bf01

#Interaction
#standard lm approach
lmmodel = lm(Diff ~ Task * PrismGroup,
             data = df); summary(lmmodel)
#replicate with car anova package
a <- Anova(aov(Diff ~ Task * PrismGroup, data = df),type = 3); a
#Get Bayes Factor
full = anovaBF(Diff ~ Task * PrismGroup,
               data = df)
null = anovaBF(Diff ~ Task + PrismGroup,
               data = df)
bf10 = full[4] / null[3]
bf01 = 1/bf10; bf01
#Plot
ggline(df, x = "Task", y = "Diff", color = 'PrismGroup',
       add = c("jitter",'mean_ci','violin'),
       palette = c('darkorchid4', 'darkturquoise'))


