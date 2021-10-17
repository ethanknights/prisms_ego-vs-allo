library(ggplot2)
library(BayesFactor)
library(lme4)
library(emmeans)
library(MuMIn)
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
rawD <- read.csv(file.path(rawDir,'data_task_long.csv'), header=TRUE,sep=",")
df = rawD
df$ID_num = as.factor(df$ID_num)
df$Session = as.factor(df$Session)
df$PrismGroup = as.factor(df$PrismGroup)
df$Target = as.factor(df$Target)
df$task = as.factor(df$task)
df = na.omit(df)

#Test for Main Effect of Session
#=====================
full = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-PPAP_meas-absErr_analysis-pairwise-session.csv')

#Test for Main Effect of Task
#=====================
full = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ task,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-PPAP_meas-absErr_analysis-pairwise-task.csv')

#Test for Main Effect of Prism Group
#=====================
full = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + task + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
anova(null,full)
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session + task + PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + task + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[8] / null[3]
bf01 = 1/bf10; bf01

#Test for Session * Task Interaction
#=====================
full = lmer(AbsErr ~ Session * task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ Session * task + PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session * task,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-PPAP_meas-absErr_analysis-pairwise-sessionBYtask.csv')


#Test for Session * PrismGroup Interaction
#=====================
full = lmer(AbsErr ~ Session * PrismGroup + task + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + PrismGroup + task + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session * PrismGroup + task + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + PrismGroup + task + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[9] / null[8]
bf01 = 1/bf10; bf01

#Test for Session * task * PrismGroup Interaction
#=====================
full = lmer(AbsErr ~ Session * task * PrismGroup + task + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + task + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session * PrismGroup * task + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + PrismGroup + task + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[18] / null[8]
bf01 = 1/bf10; bf01

#=================================================================================
#Difference tests?
