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
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
#Pairwise posthoc
model = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session * PrismGroup,
             adjust = 'bonferroni'); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-OL_meas-absErr_analysis-pairwise-sessionBYPrismgroup.csv')
#Plot -  +/- 1 SE
model = lmer(AbsErr ~ Session * PrismGroup + (1|ID_num) + (1|Target), data = df)
gdf = ggemmeans(model, terms = c('Session','PrismGroup'), type = 'random')
gdf$x = as.numeric(gdf$x) #for rect
levels(gdf$group) <- c('Left','Right')
p = ggplot(data = gdf, aes(x = x, y = predicted, color = group, group = group)) +
  geom_point(size = 2.5, alpha = 0.8,
    position=position_dodge(width=0.4)) +
  geom_errorbar(
    # aes(ymin = gdf$predicted - gdf$std.error), ymax = gdf$predicted + gdf$std.error, # original
    aes(ymax = gdf$predicted + gdf$std.err, ymin = ifelse(gdf$predicted - gdf$std.err < 0, -0.1, gdf$predicted - gdf$std.err)), #capped
    width = 0.2,
    position = position_dodge(width = 0.4)) +
  geom_line(size= 0.8, position = position_dodge(width = 0.4)) + #; p
  geom_rect(mapping=aes(xmin = 0.6, xmax = 5.1, ymin = -1, ymax = 0), color = 'white', fill = 'white'); p
p = p +  # Format
  scale_color_manual(values=c('darkorchid4', 'darkturquoise')) +
  labs(x = "Session",
       y = "Absolute Error (mm)",
       title = "Open Loop Pointing - Accuracy") +
  scale_y_continuous(breaks = seq(0, 90, 15), limits = c(-1, 90)) +
  scale_x_continuous(labels = c('Pre-Sham','Post-Sham','Pre-Prism','Post-Prism','Late-Prism'),breaks = c(1,2,3,4,5)) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text = element_text(colour = 'black'),
        axis.text.x = element_text(angle = -45, vjust = 0.5, hjust=0.5),
        axis.line = element_line(colour = 'black',size = 0.75), 
        axis.ticks = element_line(colour = 'black', size = 0.75),
        text = element_text(colour = 'black', size=18),
        legend.position = 'none'); p
ggsave(file.path(outImageDir,'OL-meas-absErr_stat-sessionBYprismGroup.tiff'),
       plot = p, width = 15, height = 11, units = 'cm', dpi = 300)
