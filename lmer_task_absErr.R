library(ggplot2)
library(BayesFactor)
library(lme4)
library(emmeans)
library(MuMIn)
library(sjPlot) #plot_model
library(ggeffects)
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
#Plot
plot_model(model, type = "pred", terms = c("Session", "task")) #same method!: plot_model(model, type = "int")
#expiermental plots (plot_model)
p = plot_model(model, type = "pred", terms = c("Session", "task"),
           line.size = 1,
           alpha = 100);
p + theme_sjplot(); p
p + scale_color_sjplot(); p
#experimenal plots (ggeffects)
dfPlot <- ggpredict(model, terms = c("Session", "task"))
plot(dfPlot,connect.lines = TRUE,
     colors = "reefs")
  



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
full = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
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
#effect size
drop1(model,scope = c('Session:task:PrismGroup'),test='Chisq')

#experimenal plots (ggeffects)
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
            data = df)
dfPlot <- ggpredict(model, terms = c("Session", "task",'PrismGroup'))
plot(dfPlot,connect.lines = TRUE,
     colors = c('darkorchid4', 'darkturquoise'))
#experimenal plots (ggeffects)
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
             data = df); 
dfPlot <- ggpredict(model, terms = c('Session', "task",'PrismGroup'), type = 'random')
p = plot(dfPlot,connect.lines = TRUE,
     colors = c('darkorchid4', 'darkturquoise'),
     ci.style = 'errorbar'); p
#experimenal plots (emmeans with ggplot2)
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
             data = df)
em = emmeans(model, pairwise ~ Session * task * PrismGroup,
             adjust = 'none'); em #no correction (as will apply only for the 4 comparisons we care about (rather than 30!))
emGrid = as.data.frame(em$emmeans)
out=emGrid
write.csv(out,'results/test.csv')
# emGrid = em$contrasts; emGrid = emGrid@grid
# SE = c(emGrid[2,],emGrid[14,])

#if ignoring BIC and looking at fulleffect modl (e.g. AIC favours full, so maybe BIC penalised!)
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session * task * PrismGroup,
             adjust = 'none'); em #no correction (as will apply only for the 4 comparisons we care about (rather than 30!))
#Session, task, prismGroup 
# LEFT PRISM GROUP
# propoint pre vs post = 			1 1 1 - 1 2 1 (row2)
# 1 1 1 - 1 2 1  -29.367 1.35 Inf -21.753 <.0001 
# antipoint pre vs post = 		1 2 1 - 2 2 1 (row14)
# 1 2 1 - 2 2 1   -4.903 1.36 Inf  -3.603 0.0003 
# RIGHT PRISM GROUP
# propoint pre vs post = 			1 1 1 - 1 2 2 (row6)
# 1 1 1 - 1 2 2  -32.239 5.15 Inf  -6.263 <.0001 
# antipoint pre vs post = 		1 2 1 - 2 2 2 (row18)
# 1 2 1 - 2 2 2   -2.738 5.15 Inf  -0.531 0.5953 
# [.0001, .0003, .0001, .593]
#0.05/4

#out = as.data.frame(em$contrasts)
#write.csv(out,'results/task-PPAP_meas-absErr_analysis-pairwise-sessionBYtaskByPrismGroup.csv')

#=================================================================================
#Difference tests?
