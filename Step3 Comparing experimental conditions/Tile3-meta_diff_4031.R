library(reshape2)
library(ggplot2)
library(gtools)
library(stringr)
library(dplyr)

d.e4031 <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-e4031.csv")
names(d.e4031)[5] <- "score.e4031"
names(d.e4031)[6] <- "score.se.e4031"
#d.dmso <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-dmso.csv")
d.dmso <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-dmso.csv")

names(d.dmso)[5] <- "score.dmso"
names(d.dmso)[6] <- "score.se.dmso"

d.tot <- merge(d.e4031,d.dmso)

d.tot$diff <- (d.tot$score.e4031 - d.tot$score.dmso)#*(d.tot$score.dmso-100)/(-100)

aas<-c("A","V","I","L","M","F","Y","W","P","G","C","S","T","N","Q","H","R","K","D","E","X")

# Filter data based on resnum range
d.tot <- d.tot[d.tot$resnum >= 536 & d.tot$resnum <= 628, ]

cutoff <- 10
change <- 10
# Create color column based on conditions
d.tot$color <- ifelse(d.tot$score.dmso < cutoff & d.tot$score.e4031 > cutoff + change, "blue",
                      ifelse(d.tot$score.dmso < cutoff, "black", "grey"))

# Filter rows with defined colors
d.tot <- d.tot[!is.na(d.tot$color), ]

# Melt the data for ggplot
f.m <- melt(d.tot, id.vars = c("res", "Mut", "color"), measure.vars = "diff")

# Create the heatmap with adjusted color scale
p <- ggplot(f.m, aes(ordered(Mut, levels = aas), ordered(res, levels = rev(mixedsort(unique(res)))))) +
  geom_tile(aes(fill = color), color = "white") +
  scale_fill_identity() +
  theme_grey(base_size = 9) +
  labs(x = "", y = "") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  theme(legend.position = "none", axis.text.x.top = element_text(angle = 90, vjust = 0.5, hjust = 0)) +
  scale_x_discrete(position = "top")

# Print the plot
print(p)