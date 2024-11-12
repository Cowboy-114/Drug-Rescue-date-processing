library(reshape2)
library(ggplot2)
library(gtools)
library(stringr)
library(dplyr)

f.out <- function(dt){
  mat = dt[!is.na(dt$mutAA),c("res","mutAA","score","CountTotal","count","resnum")]
  f<-aggregate(cbind(mat$score,mat$count), 
               list(res=mat$res,Mut=mat$mutAA,resnum=mat$resnum), median, na.rm =T)
  colnames(f)[3:5]<-c("resnum", "score","subcount")
  return(f)
}

setwd("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/sort-files/")
a<-read.csv("11529_e_e4031.csv", stringsAsFactors = F)
a<-a[!is.na(a$mutAA),]
a.f<-f.out(a)

b<-read.csv("11247_e_e4031.csv", stringsAsFactors = F)
b<-b[!is.na(b$mutAA),]
b.f<-f.out(b)

c<-read.csv("11463_e_e4031.csv", stringsAsFactors = F)
c<-c[!is.na(c$mutAA),]
c.f<-f.out(c)

g<-read.csv("11485_e_e4031.csv", stringsAsFactors = F)
g<-g[!is.na(g$mutAA),]
g.f<-f.out(g)

h<-read.csv("11362_e_e4031.csv", stringsAsFactors = F)
h<-h[!is.na(h$mutAA),]
h.f<-f.out(h)

j<-read.csv("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/pilot/Drug_Variant_Interaction/egly/9934/9934_e_e4031.csv", stringsAsFactors = F)
j<-j[!is.na(j$mutAA),]
names(j)[names(j) == "firstCount"] <- "count"
j.f<-f.out(j)

i<-rbind(a.f,b.f,c.f,g.f,h.f,j.f)
aas<-c("A","V","I","L","M","F","Y","W","P","G","C","S","T","N","Q","H","R","K","D","E","X")
x<-data.frame(0,0)
k<-0
colnames(x)<-c("res","Mut")
for (r in unique(i$res)){
  for (aa in aas){
    x[k,c("Mut","res")]<-c(aa,r)
    k=k+1
  }
}

i<-bind_rows(i,x)
mat = i[!is.na(i$Mut),c("res","Mut","score","subcount")]

library(dplyr)

# Define a function to calculate standard error
standard_error <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))
}

# Use dplyr to group by res and Mut, then summarise
f <- mat %>%
  group_by(res, Mut) %>%
  summarise(
    Median_score = median(score, na.rm = TRUE),
    score_SE = standard_error(score),
    Subcount_Median = median(subcount, na.rm = TRUE),
    Subcount_SE = standard_error(subcount)
  )
colnames(f)[3] <- "score"

d<-as.data.frame(f)

t<-str_split_fixed(d$res, "[0-9]+ ",2)
d$wt<-t[,2]

j<-str_split_fixed(d$res,"[A-Z]",3)
d$resnum<-as.integer(j[,1])
#d<-d[d$resnum>25 & d$resnum<104,]

d$type<-"missense"
d[d$Mut=="X","type"]<-"nonsense"
d[d$Mut==d$wt,"type"]<-"synonymous"

d$type<-factor(d$type, levels = c( "synonymous","nonsense", "missense"))

#Clean data for subsequent use
#Y475 is correct
d<-d[d$resnum>474 & d$resnum<638,]
d$var<-paste(d$wt,d$resnum,d$Mut,sep = '')

# Save output
write.csv(d[,c("resnum", "wt", "res", "Mut", "score", "score_SE", "type", "var")],"C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/Tile3-e4031.csv", row.names = F)

f.m<-melt(f,c("res","Mut"),"score")
p<-ggplot(f.m, aes(ordered(Mut, levels = aas),ordered(res, levels = rev(mixedsort(unique(res))))))+
  geom_tile(aes(fill = value), color = "white") +
  scale_fill_gradientn(colours = c("#C65911","#FFC000","#FFFFA8", "#FFFFFF","#BDD7EE"), values = c(0,0.25,0.5,0.70,1), na.value="grey50", guide = "colourbar") 
base_size<-9
p+ theme_grey(base_size = base_size) + labs(x = "", y = "") + 
  scale_x_discrete(expand = c(0, 0)) + 
  scale_y_discrete(expand = c(0, 0)) + 
  theme(legend.position = "none", axis.text.x.top = element_text(angle = 90, vjust=0.5, hjust=0)) + 
  scale_x_discrete(position = "top")


p <- ggplot(d, aes(x=type,y=score)) + 
  geom_violin(scale = "width")
p + geom_boxplot(width=0.1) + geom_jitter(shape=16, position=position_jitter(0.1))


d<-d[!is.na(d$resnum), c("resnum","score")]
c<-aggregate(cbind(d$score), list(resnum=d$resnum), median, na.rm =T)
names(c)[2]<-"score"
c<-c[c$resnum>477 & c$resnum<637,]
c$score<- (max(c$score)-c$score)
c$score<-round(c$score,1)



