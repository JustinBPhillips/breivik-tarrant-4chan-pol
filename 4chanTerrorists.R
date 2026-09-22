rm(list=ls())
library(dplyr)
library(data.table)
library(tm)
library(wordcloud)

setwd("/home/justin/OneDrive/manuscripts/4chan/terrorists/data/")

breivik = fread("./pol_breivik.tsv",header=FALSE,quote="",sep="\t")
breivik$CLASS = as.factor(fread("./breivik_mallet_25000it.tsv",header=FALSE,sep="\t")$V1)
# small remove noise categories
breivik = filter(breivik,CLASS!=5,CLASS!=4)
breivik$CLASS = droplevels(breivik$CLASS)
summary(as.factor(breivik$CLASS))/length(breivik$CLASS)


sentences = data.frame(TEXT=breivik$V3,SENTENCES=breivik$V4,CLASS=breivik$CLASS)


sentences$CLASS <-
  plyr::revalue(
    sentences$CLASS,
    c(
      "0" = "Legal (12%)",
      "1" = "Conspiracy (5%)",
      "2" = "Debate (28%)",
      "3" = "Scolding (54%)"
    )) %>% factor()


theText = c()
theClass = c()
theUniques = unique(sentences$CLASS)

for(i in 1:length(theUniques)) {
  theText = c(theText,paste(filter(sentences,CLASS==theUniques[i])$TEXT, sep=" ",collapse=""))
  theClass = c(theClass,paste(theUniques[i],"",sep=""))
}
theClass = as.factor(theClass)
docs = Corpus(DataframeSource(data.frame(doc_id=theClass,text=theText)))
tdm <- TermDocumentMatrix(docs)
tdm = as.matrix(tdm)
# remove additional imbalance probably due to parsing
badIndex = match("anders",rownames(tdm))
tdm = tdm[-badIndex,]
badIndex = match("breivik",rownames(tdm))
tdm = tdm[-badIndex,]
badIndex = match("breivikbreivik",rownames(tdm))
tdm = tdm[-badIndex,]

# editor has asked for bad words to be removed
badwords = c("fuck","nigger","kike","faggot","cunt","shit")
replacements = c("f**k","n****r","k**e","f****t","c**t","s**t")
for(badword in 1:length(badwords)) {
    rownames(tdm) = str_replace(rownames(tdm),pattern = badwords[badword],replacements[badword])    
}

#col.order <- c("colname4","colname3","colname2","colname5","colname1")
#tdm = tdm[ , c("Scolding (54%)", "Debate (28%)", "Legal (12%)", "Conspiracy (4%)")]

colorPalette6 = c("#007113","#bc0064","#a58800","#176ae2","#92707c","#593f98","#938751")

ragg::agg_png("./comparisonCloud_breivik.png", width = 1000, height = 1000, units = "px", res = 300, scaling=0.55)
par(family = "Times")
comparison.cloud(tdm,max.words=2000,random.order=FALSE,color=colorPalette6, family = "CMU Serif", title.size=1.2, title.bg.colors='grey100')
dev.off()


### Tarrant

tarrant = fread("./pol_tarrant.tsv",header=FALSE,quote="",sep="\t")
tarrant$CLASS = as.factor(fread("./tarrant_mallet_25000it.tsv",header=FALSE,sep="\t")$V1)
tarrant = filter(tarrant,CLASS!=0,CLASS!=4)
tarrant$CLASS = droplevels(tarrant$CLASS)
summary(as.factor(tarrant$CLASS))/length(tarrant$CLASS)

sentences = data.frame(TEXT=tarrant$V3,SENTENCES=tarrant$V4,CLASS=tarrant$CLASS)


sentences$CLASS <-
  plyr::revalue(
    sentences$CLASS,
    c(
      "1" = "Conspiracy (12%)",
      "2" = "Features (13%)",
      "3" = "Scolding (37%)",
      "5" = "Debate (38%)"
    )) %>% factor()


theText = c()
theClass = c()
theUniques = unique(sentences$CLASS)

for(i in 1:length(theUniques)) {
  theText = c(theText,paste(filter(sentences,CLASS==theUniques[i])$TEXT, sep=" ",collapse=""))
  theClass = c(theClass,paste(theUniques[i],"",sep=""))
}
theClass = as.factor(theClass)
docs = Corpus(DataframeSource(data.frame(doc_id=theClass,text=theText)))
tdm <- TermDocumentMatrix(docs)
tdm = as.matrix(tdm)
# remove additional imbalance probably due to parsing
badIndex = match("tarrant",rownames(tdm))
tdm = tdm[-badIndex,]
badIndex = match("brenton",rownames(tdm))
tdm = tdm[-badIndex,]
# editor has asked for bad words to be removed
badwords = c("fuck","nigger","kike","faggot","cunt","shit")
replacements = c("f**k","n****r","k**e","f****t","c**t","s**t")
for(badword in 1:length(badwords)) {
  rownames(tdm) = str_replace(rownames(tdm),pattern = badwords[badword],replacements[badword])    
}

colorPalette6 = c("#007113","#bc0064","#a58800","#176ae2","#92707c","#593f98","#938751")

ragg::agg_png("./comparisonCloud_tarrant.png", width = 1000, height = 1000, units = "px", res = 300, scaling=0.55)
par(family = "Times")
comparison.cloud(tdm,max.words=2000,random.order=FALSE,color=colorPalette6, family = "CMU Serif", title.size=1.2, title.bg.colors='grey100')
dev.off()