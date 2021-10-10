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
# lm_model = lm(MouseClick1RT ~ Session,
#               data = df); summary(lm_model)
# emmeans(lm_model, pairwise ~ Session,
#         adjust = 'bonferroni')

# # Session 5
# lm_model = lm(MouseClick1RT ~ Session * PrismGroup,
#               data = df); summary(lm_model)
# emmeans(lm_model, pairwise ~ Session,
#         adjust = 'bonferroni')


#preliminary assumptions lienar regression
lm_model = lm(MouseClick1RT ~ Session + PrismGroup,
              data = df); summary(lm_model)
par(mfrow = c(2, 2))
plot(lm_model)
shapiro.test(residuals(lm_model))

#df$MouseClick1RT_log = log(df$MouseClick1RT +1) #deal with homogeneity problem (+1 to deal true 0 inf, due to no error)
lm_model = lm(MouseClick1RT_log ~ Session + PrismGroup,
              data = df); summary(lm_model)
par(mfrow = c(2, 2))
plot(lm_model)


#Test for Main Effect of Session
#=====================
full = lmer(MouseClick1RT ~ Session + (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(full)
null = lmer(MouseClick1RT ~ (1|ID_num) + (1|Target),
            data = df,
            REML = FALSE); summary(null)
a = anova(null,full); a
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
library("MuMIn")
r.squaredGLMM(full)


## Pairwise posthoc
model = lmer(MouseClick1RT ~ Session + (1|ID_num),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session,
        adjust = 'bonferroni'); em

out = em$contrasts
write.csv(out,'results/Results_PostHoc_OL_MT.csv')

