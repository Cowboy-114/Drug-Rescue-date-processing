library(reshape2)
library(ggplot2)
library(gtools)
library(stringr)
library(dplyr)

# Load data
d.eva <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-eva.csv")
names(d.eva)[5] <- "score.eva"
names(d.eva)[6] <- "score.se.eva"

d.dmso <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-dmso.csv")
names(d.dmso)[5] <- "score.dmso"
names(d.dmso)[6] <- "score.se.dmso"

d.e4031 <- read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-e4031.csv")
names(d.e4031)[5] <- "score.e4031"
names(d.e4031)[6] <- "score.se.e4031"

# Merge data
d.tot.ini <- merge(d.e4031, d.dmso)
d.tot <- merge(d.tot.ini, d.eva)

# Calculate differences
d.tot$diff.e4031 <- d.tot$score.e4031 - d.tot$score.dmso
d.tot$diff.eva <- d.tot$score.eva - d.tot$score.dmso

# Filter data based on resnum range
d.tot <- d.tot[d.tot$resnum >= 536 & d.tot$resnum <= 628, ]

cutoff <- 10
change <- 0


# Define the CMYK colors as RGB
CMYK_to_RGB <- function(c, m, y, k) {
  r <- 255 * (1 - c / 100) * (1 - k / 100)
  g <- 255 * (1 - m / 100) * (1 - k / 100)
  b <- 255 * (1 - y / 100) * (1 - k / 100)
  rgb(r, g, b, maxColorValue = 255)
}

# Update colors based on provided CMYK values
grey <- CMYK_to_RGB(10.59, 9.02, 15.29, 0)
black <- CMYK_to_RGB(28.63, 25.1, 32.16, 8)
yellow <- CMYK_to_RGB(1.96, 0.39, 41.57, 0)
red <- CMYK_to_RGB(0, 99.22, 54.9, 0)
blue <- CMYK_to_RGB(29.41, 0, 2.75, 0)

# Create color column based on conditions
d.tot$color <- ifelse(d.tot$score.dmso < cutoff & d.tot$score.eva > cutoff + change & d.tot$score.e4031 < cutoff + change, yellow,
                      ifelse(d.tot$score.dmso < cutoff & d.tot$score.e4031 > cutoff + change & d.tot$score.eva < cutoff + change, blue,
                             ifelse(d.tot$score.dmso < cutoff & d.tot$score.eva > cutoff + change & d.tot$score.e4031 > cutoff + change, red, 
                                    ifelse(d.tot$score.dmso > cutoff, "white", 
                                           ifelse(d.tot$score.dmso <= cutoff, black, NA)))))

# Filter rows with defined colors
d.tot <- d.tot[!is.na(d.tot$color), ]

# Melt the data for ggplot
f.m <- melt(d.tot, id.vars = c("res", "Mut", "color"), measure.vars = c("diff.e4031", "diff.eva"))

aas<-c("A","V","I","L","M","F","Y","W","P","G","C","S","T","N","Q","H","R","K","D","E","X")

# Create heatmap plot
p <- ggplot(f.m, aes(ordered(Mut, levels = aas), ordered(res, levels = rev(mixedsort(unique(res)))))) +
  geom_tile(aes(fill = color), color = "white") +
  scale_fill_identity() +
  theme_minimal(base_size = 9) +
  labs(x = "", y = "") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  theme(panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),
        legend.position = "none",
        axis.text.x.top = element_text(angle = 90, vjust = 0.5, hjust = 0)) +
  scale_x_discrete(position = "top")

# Print the plot
print(p)



# Create color column based on conditions
d.tot$color <- ifelse(d.tot$score.dmso > cutoff, "white", 
                      ifelse(d.tot$score.dmso <= cutoff, "black", NA))

# Filter rows with defined colors
d.tot <- d.tot[!is.na(d.tot$color), ]

# Melt the data for ggplot
f.m <- melt(d.tot, id.vars = c("res", "Mut", "color"), measure.vars = c("diff.e4031", "diff.eva"))

aas<-c("A","V","I","L","M","F","Y","W","P","G","C","S","T","N","Q","H","R","K","D","E","X")

# Create heatmap plot
p <- ggplot(f.m, aes(ordered(Mut, levels = aas), ordered(res, levels = rev(mixedsort(unique(res)))))) +
  geom_tile(aes(fill = color), color = "white") +
  scale_fill_identity() +
  theme_minimal(base_size = 9) +
  labs(x = "", y = "") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  theme(panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),
        legend.position = "none",
        axis.text.x.top = element_text(angle = 90, vjust = 0.5, hjust = 0)) +
  scale_x_discrete(position = "top")

# Print the plot
print(p)


