library(ggplot2)
library(BayesFactor)
library(lme4)
library(emmeans)
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


# ANOVA - 5way  Session 5
# lm_model = lm(AbsErr ~ Session,
#               data = df); summary(lm_model)
# emmeans(lm_model, pairwise ~ Session,
#         adjust = 'bonferroni')

# # Session 5
# lm_model = lm(AbsErr ~ Session * PrismGroup,
#               data = df); summary(lm_model)
# emmeans(lm_model, pairwise ~ Session,
#         adjust = 'bonferroni')


#preliminary assumptions lienar regression
lm_model = lm(AbsErr ~ Session + PrismGroup,
              data = df); summary(lm_model)
par(mfrow = c(2, 2))
plot(lm_model)
shapiro.test(residuals(lm_model))

#df$AbsErr_log = log(df$AbsErr +1) #deal with homogeneity problem (+1 to deal true 0 inf, due to no error)
lm_model = lm(AbsErr_log ~ Session + PrismGroup,
              data = df); summary(lm_model)
par(mfrow = c(2, 2))
plot(lm_model)


#Basic mixed Effects Model 
#=====================
lm_model = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
              data = df); summary(lm_model)

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
#Get same (stronger) BF01 if we forget about nuisance effects for a second:
full = anovaBF(AbsErr ~ Session * PrismGroup,
               data = df)
null = anovaBF(AbsErr ~ Session + PrismGroup,
               data = df)
bf10 = full[4] / null[3]
bf01 = 1/bf10; bf01

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

#Test for Main Effect of Session
#=====================
full = lmer(AbsErr ~ Session + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(AbsErr ~ (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Get Bayes Factor (following https://richarddmorey.github.io/BayesFactor/#mixed)
full = anovaBF(AbsErr ~ Session + PrismGroup + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
null = anovaBF(AbsErr ~ Session + ID_num + Target,
               whichRandom = c("ID_num","Target"),
               data = df)
bf10 = full[3] / null
bf01 = 1/bf10; bf01
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
library("MuMIn")
r.squaredGLMM(full)

#Could also do a 3way model comparison
# full = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
#             data = df,
#             REML = FALSE); summary(full)
# sess = lmer(AbsErr ~ Session + (1|ID_num) + (1|Target),
#             data = df,
#             REML = FALSE); summary(null)
# prism = lmer(AbsErr ~ PrismGroup + (1|ID_num) + (1|Target),
#              data = df,
#              REML = FALSE); summary(null)
# a  =anova(sess,prism,full); a
# a = anova(sess,full); a


## Pairwise posthoc
model = lmer(AbsErr ~ Session + (1|ID_num),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session,
        adjust = 'bonferroni'); em

out = em$contrasts
write.csv(out,'results/Results_PostHoc_OL_absError.csv')

