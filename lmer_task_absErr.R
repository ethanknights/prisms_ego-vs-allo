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
levels(df$Session) <- c('Pre','Post')       #make emmeans readable
levels(df$task) <- c('Pro','Anti')          #make emmeans readable
levels(df$PrismGroup) <- c('Left','Right')  #make emmeans readable


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
#Effect size (Rsuqared for fixed effects of model (cant get for particular effects))
r.squaredGLMM(full)
#Pairwise posthoc
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
             data = df); summary(model)
em = emmeans(model, pairwise ~ Session * task * PrismGroup,
             adjust = 'bonferroni',
             pbkrtest.limit = 7696); em
out = as.data.frame(em$contrasts)
write.csv(out,'results/task-PPAP_meas-absErr_analysis-pairwise-sessionBYtaskBYPrismgroup.csv')
#Bayes ttest: Pre Anti Right - Post Anti Right
adf = as.data.frame(aggregate(df$AbsErr,
                              by = list(df$subNum, df$Session, df$task, df$PrismGroup),
                              FUN = mean)); 
colnames(adf) <- c('subNum','Session','task','PrismGroup','AbsErr')
adf <- adf[with(adf, PrismGroup == 'Right'),]
tmpA <- adf[with(adf, Session == 'Pre'),]
tmpB <- adf[with(adf, Session == 'Post'),]
tmpA <- tmpA[with(tmpA, task == 'Anti'),]; tmpB <- tmpB[with(tmpB, task == 'Anti'),]
tmpA = tmpA$AbsErr; tmpB = tmpB$AbsErr # so convoluted
bf10 = ttestBF(tmpA, tmpB, paired = TRUE); bf01 = 1 / bf10; bf01
#Plot - Builtin
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target),
             data = df); 
dfPlot <- ggpredict(model, terms = c('Session', 'PrismGroup','task'), type = 'random')
p = plot(dfPlot,connect.lines = TRUE,
         ci.style = 'errorbar',
         colors = c('darkorchid4', 'darkturquoise')); p
p = p +  # Format
  scale_color_manual(values=c('darkorchid4', 'darkturquoise')) +
  labs(x = "Session",
       y = "Absolute Error (mm)",
       title = 'Pro- & Anti-pointing - Accuracy') +
  scale_y_continuous(breaks = seq(0, 100, 25), limits = c(-5, 100)) +
  scale_x_continuous(labels = c('Pre-Sham','Post-Sham','Pre-Prism','Post-Prism'),breaks = c(1,2,3,4)) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text = element_text(colour = 'black'),
        axis.text.x = element_text(angle = -45, vjust = 0.5, hjust=0.5),
        axis.line = element_line(colour = 'black',size = 0.75), 
        axis.ticks = element_line(colour = 'black', size = 0.75),
        text = element_text(colour = 'black', size=18),
        strip.background = element_blank(),
        legend.position = 'none'); p
ggsave(file.path(outImageDir,'PPAP-meas-absErr_stat-sessionBYtaskBYprismGroup.tiff'),
       plot = p, width = 12, height = 14, units = 'cm', dpi = 300)



#Plot - Custom (given up with geom_line)
model = lmer(AbsErr ~ Session * task * PrismGroup + (1|ID_num) + (1|Target), data = df)
gdf = ggemmeans(model, terms = c('Session','task','PrismGroup'), type = 'random')


p = ggplot(data = gdf, aes(x = x, y = predicted, color = facet, group = interaction(x, group))) +
  geom_point() +
  geom_line(aes(group = )); p



p = ggplot(data = gdf, aes(x = x, y = predicted, color = facet)) +
  geom_point() +
  geom_line(aes(group = gdf$x)); p


p = ggplot(data = gdf, aes(x = x, y = predicted, color = facet)) +
  geom_point() +
  geom_line(group = gdf$x); p
  
            
            
          
            size= 0.8, position = position_dodge(width = 0.4)) +
  facet_wrap(~group); p
+
  geom_errorbar(aes(ymin = gdf$predicted - gdf$std.error), ymax = gdf$predicted + gdf$std.error,
    width = 0.8,
    position = position_dodge(width = 0.4)); p

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


