library(ggplot2)
library(data.table)
library(gtools)
library(dplyr)

# all barcode-related r script removed. I am assuming the barcode was correctly 
# processed.
a=read.csv('C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/Tile3/Library3-LV384/barcode-key.tile3.lv384.csv',header=TRUE,stringsAsFactors=FALSE)
names(a$count)<-'counts'

setwd("C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/sort-files/")
qc_counts<-2
# read barcode counts from experiment 
# negative AF647: NO KCNH2 surface expression
neg<-read.csv("11247-AS-0008_S1_L005.sorted_bc.processed.csv",header=TRUE,stringsAsFactors=FALSE)
neg<-neg[neg$count>qc_counts,]
colnames(neg)<-c('extra', "bc", "CountNeg") # added another column name because of silly proc.sh script (hopefully won't need to do in future)
neg<-neg[,c("bc", "CountNeg")]

# Low AF647: Low KCNH2 surface expression
low<-read.csv("11247-AS-0007_S1_L005.sorted_bc.processed.csv",header=TRUE,stringsAsFactors=FALSE)
low<-low[low$count>qc_counts,]
colnames(low)<-c('extra', "bc", "CountLow") # added another column name because of silly proc.sh script (hopefully won't need to do in future)
low<-low[,c("bc", "CountLow")]

# medium AF647: medium KCNH2 surface expression
med<-read.csv("11247-AS-0006_S1_L005.sorted_bc.processed.csv",header=TRUE,stringsAsFactors=FALSE)
med<-med[med$count>qc_counts,]
colnames(med)<-c('extra', "bc", "CountMed") # added another column name because of silly proc.sh script (hopefully won't need to do in future)
med<-med[,c("bc", "CountMed")]

# High AF647: high KCNH2 surface expression
high<-read.csv("11247-AS-0005_S1_L005.sorted_bc.processed.csv",header=TRUE,stringsAsFactors=FALSE)
high<-high[high$count>qc_counts,]
colnames(high)<-c('extra', "bc", "CountHigh") # added another column name because of silly proc.sh script (hopefully won't need to do in future)
high<-high[,c("bc", "CountHigh")]

# merge all barcode counts from subassembly and from 
b<-merge(a,neg,all.x = T,all.y = T)
b<-b[!is.na(b$variant),]
c<-merge(b,low,all.x = T,all.y = T)
c<-c[!is.na(c$variant),]
d<-merge(c,med,all.x = T,all.y = T)
d<-d[!is.na(d$variant),]
e<-merge(d,high,all.x = T,all.y = T)
e=e[!is.na(e$variant),]
e=e[!(is.na(e$CountNeg) & is.na(e$CountLow) & is.na(e$CountMed) & is.na(e$CountHigh)),]
e<-unique(e)

tot_countNeg<-sum(e$CountNeg, na.rm = TRUE)
tot_countLow<-sum(e$CountLow, na.rm = TRUE)
tot_countMed<-sum(e$CountMed, na.rm = TRUE)
tot_countHigh<-sum(e$CountHigh, na.rm = TRUE)
e[is.na(e$CountNeg),"CountNeg"]<-0
e[is.na(e$CountLow),"CountLow"]<-0
e[is.na(e$CountMed),"CountMed"]<-0
e[is.na(e$CountHigh),"CountHigh"]<-0
e$CountTotal<-e$CountNeg/tot_countNeg+e$CountLow/tot_countLow+e$CountMed/tot_countMed+e$CountHigh/tot_countHigh
#e$r.max<-pmax(e$CountHigh/e$CountTotal, e$CountLow/e$CountTotal, e$CountMed/e$CountTotal)#, e$CountNeg/e$CountTotal)
#e<-e[e$r.max<1,]
#e<-e[log10(e$CountTotal)<4,]
e$score<-((1*e$CountNeg/tot_countNeg+2*e$CountLow/tot_countLow+3*e$CountMed/tot_countMed+4*e$CountHigh/tot_countHigh)/e$CountTotal)
e$res<-paste(e$resnum-17,e$wtAA)
e<-e[!is.na(e$wtAA),]

# somewhat logical ordering of amino acids
aas<-c("A","V","I","L","M","F","Y","W","P","G","C","S","T","N","Q","H","R","K","D","E","X")

x<-data.frame(0,0)
i<-1
colnames(x)<-c("res","mutAA")
for (r in unique(e$res)){
  for (aa in aas){
    x[i,c("mutAA","res")]<-c(aa,r)
    i=i+1
  }
}


e<-bind_rows(e,x)
e$type<-"missense"
e[e$mutAA=="X" & !is.na(e$wtAA),"type"]<-"nonsense"
e[e$mutAA==e$wtAA & !is.na(e$wtAA),"type"]<-"synonymous"
ave<-mean(e[e$type=="synonymous","score"])
e$score<-100*(e$score-1)/(ave-1)

mat = e[!is.na(e$mutAA),c("res", "mutAA", "resnum", "score", "CountTotal", "counts", "type")]
f<-aggregate(cbind(mat$score,mat$count), list(res=mat$res,Mut=mat$mutAA,type=mat$type), median, na.rm =T)
colnames(f)[4:5]<-c("score","subcount")

write.csv(e,file = "C:/Users/KRONCKE/OneDrive - VUMC/Kroncke_Lab/kcnh2/sequencing/VANTAGE/DrugRescue/alex/sort-files/11247_e_e4031.csv")

f<-f[,c("res","Mut","score","subcount","type")]
f$res<-as.character(f$res)
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


f$type<-factor(f$type, levels = c( "synonymous","nonsense", "missense"))

p <- ggplot(f, aes(x=type,y=score)) + 
  geom_violin(scale = "width")
p + geom_boxplot(width=0.1) + geom_jitter(shape=16, position=position_jitter(0.1))




f.m<-melt(f,c("res","Mut"),"subcount")
f.m[f.m$value==0,"value"]<-NA
f.m$value<-log10((f.m$value))
p<-ggplot(f.m, aes(ordered(Mut, levels = aas),ordered(res, levels = rev(mixedsort(unique(res))))))+ geom_tile(aes(fill = value), color = "white") + scale_fill_gradient(low = "white", high = "steelblue") 
base_size<-9
p+ theme_grey(base_size = base_size) + labs(x = "", y = "") + 
  scale_x_discrete(expand = c(0, 0)) + 
  scale_y_discrete(expand = c(0, 0)) + theme(legend.position = "none", axis.text.x.top = element_text(angle = 90, vjust=0.5, hjust=0)) + scale_x_discrete(position = "top")



