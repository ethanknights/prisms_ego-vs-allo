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
rawD <- read.csv(file.path(rawDir,'data_openloop_long.csv'), header=TRUE,sep=",")
df = rawD
df$ID_num = as.factor(df$ID_num)
df$Session = as.factor(df$Session)
df$PrismGroup = as.factor(df$PrismGroup)
df$Target = as.factor(df$Target)
df = na.omit(df)


#preliminary assumptions lienar regression
# lm_model = lm(AbsErr ~ Session + PrismGroup,
#               data = df); summary(lm_model)
# par(mfrow = c(2, 2))
# plot(lm_model)
# shapiro.test(residuals(lm_model))
#df$AbsErr_log = log(df$AbsErr +1) #deal with homogeneity problem (+1 to deal true 0 inf, due to no error)
# lm_model = lm(AbsErr_log ~ Session + PrismGroup,
#               data = df); summary(lm_model)
# par(mfrow = c(2, 2))
# plot(lm_model)


#Test for Main Effect of Session
#=====================
full = lmer(AbsErr ~ PrismGroup + Session + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ PrismGroup + Session + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-OL_meas-absErr_analysis-pairwise-session.csv')


#Test for Main Effect of Prism Group
#=====================
full = lmer(AbsErr ~ Session + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
anova(null,full)
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session + PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[3] / null
bf01 = 1/bf10; bf01


#Test for Session * Prism Interaction
#=====================
#Following bodowinter.com/tuorial/bw_LME_tutorial.pdf
full = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + PrismGroup + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
anova(null,full)
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session * PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[4] / null[3]
bf01 = 1/bf10; bf01


#============================================================================
#Additional
#============================================================================
# Retest for prism effects when only considering post-/-late-prism sessions
#=====================
#subset
#------
tmpDf <- df[with(df, Session == 4 | Session == 5),]
tmpDf$Session = as.factor(tmpDf$Session)

#Test for Main Effect of Prism Group
#------
full = lmer(AbsErr ~ Session + PrismGroup + (1|ID_num) + (1|Target),
            data = tmpDf,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + (1|ID_num) + (1|Target),
            data = tmpDf,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session + PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = tmpDf)
null = anovaBF(AbsErr ~ Session + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = tmpDf)
bf10 = full[3] / null
bf01 = 1/bf10; bf01

#Test for Interaction: Session * Prism Group
#------
full = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
            data = tmpDf,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ Session + PrismGroup + (1|ID_num) + (1|Target),
            data = tmpDf,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
## Pairwise posthoc
model = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
             data = tmpDf); summary(model)
em = emmeans(model, pairwise ~ Session * PrismGroup,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-OL_meas-absErr_analysis-pairwise-session_post-late-prismSessionOnly.csv')
