
setwd("F:/Northwestern - M.S. Predictive Analytics/Past Courses/Spring 2017_Course 410_Regression & Multivariate Analysis/Assignments/European/R EuropeanEmployment")

################################################################

my.data <- read.csv(file="EuropeanEmployment.csv",head=TRUE,sep=",")
str(my.data)
head(my.data)

##################################################################

require(cluster)
require(useful)
require(Hmisc)
library(HSAUR)
library(MVA)
library(HSAUR2)
library(fpc)
library(mclust)
library(lattice)
library(car)
require(ggplot2)

# EDA to do scatterplots - Task 2 and 3

ggplot(my.data, aes(x=SER, y=FIN, colour = Group, label= Country)) + 
  geom_point() + geom_text(aes(label=Country),hjust=0, vjust=0) +
  ggtitle("Scatter Plot Financial vs Services") +
  theme(plot.title=element_text(lineheight=0.8, face="bold", hjust=0.5))

ggplot(my.data, aes(x=MAN, y=FIN, colour = Group, label= Country)) + 
  geom_point() + geom_text(aes(label=Country),hjust=0, vjust=0) +
  ggtitle("Scatter Plot Financial vs Manufacturing") +
  theme(plot.title=element_text(lineheight=0.8, face="bold", hjust=0.5))

# Pairwise scatterplot
pairs(my.data[,-c(1,2)])

# Do PCA to reduce the dimension from 9 to 2 - Task 4

apply(my.data[,-c(1,2)],MARGIN=1,FUN=sum)
pca.out <- princomp(x=my.data[,-c(1,2)],cor=FALSE);
names(pca.out)

pc.1 <- pca.out$scores[,1];
pc.2 <- pca.out$scores[,2];
str(pc.1)
pcdf = data.frame(pc1=pc.1, pc2=pc.2)
pcdf1 = cbind(pcdf,my.data$Country)
pcdf2 = cbind(pcdf1,my.data$Group)
str(pcdf2)

ggplot(pcdf2, aes(x=pc1, y=pc2, colour = my.data$Group, label= my.data$Country)) + 
  geom_point() + geom_text(aes(label=my.data$Country),hjust=0, vjust=0) +
  ggtitle("Scatter Plot PC1 vs PC2") +
  theme(plot.title=element_text(lineheight=0.8, face="bold", hjust=0.5))

# Hirerarchical clustreing - Task 5

hier.dist = dist(my.data[,-c(1,2)])
require(maptree)
hclustmodel <- hclust(hier.dist, method = 'complete')
plot(hclustmodel,labels=my.data$Country)


# choose the number of clusters k = 3
cut.3 <- cutree(hclustmodel, k=3)
head(cut.3)
cut.3
pcdf3 <- cbind(pcdf2,cut.3)
pcdf3

# cross tab of clusters vs Group

table(pcdf3$'my.data$Group',pcdf3$cut.3)

# accuracy - Between % ss
subdat <- my.data[,-c(1,2)]
TSS <- (nrow(subdat)-1)*sum(apply(subdat,2,var))
TSS
require(fpc)
complete3 <- cutree(hclust(hier.dist),3)
WSS <- cluster.stats(hier.dist,complete3, alt.clustering=NULL)$within.cluster.ss
WSS
BetSSPer <- (TSS-WSS)/TSS
BetSSPer


# kmeans clustering with k=3 clusters - Task 6

clusterresults <- kmeans(my.data[,-c(1,2)],3)
names(clusterresults)
BetSSPer <- clusterresults$betweenss/clusterresults$totss
BetSSPer
clusterresults$totss

plot(clusterresults, data=my.data[,-c(1,2)])


# cluster plots for kmeans

library(cluster) 
clusplot(my.data[,-c(1,2)], clusterresults$cluster, color=TRUE, shade=TRUE, 
         labels=2, lines=0)


# Internal validation - Task 7

## K means clustering

wssplot <- function(subdat, nc=15, seed=1234) {
  wss <- (nrow(subdat)-1)*sum(apply(subdat,2,var))
  for (i in 2:nc) {
    set.seed(seed)
    wss[i] <- sum(kmeans(subdat, centers=i)$withinss)}
    rs <- (wss[1] - wss)/wss[1]
    plot(1:nc, wss, type="b", xlab="Number of Clusters",
         ylab="Within groups sum of squares")
    plot(1:nc, rs, type="b", xlab="Number of Clusters",
       ylab="% of Between SS")} 

wssplot(subdat)

## Hierarchical clustering

wssplot <- function(subdat, nc=15, seed=1234) {
  wss <- (nrow(subdat)-1)*sum(apply(subdat,2,var))
  for (i in 2:nc) {
    require(fpc)
    set.seed(seed)
    hier.dist <- dist(subdat)
    complete3 <- cutree(hclust(hier.dist),i)
  wss[i] <- cluster.stats(hier.dist,complete3, alt.clustering=NULL)$within.cluster.ss}
  rs <- (wss[1] - wss)/wss[1]
    plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
    plot(1:nc, rs, type="b", xlab="Number of Clusters",
         ylab="% of Between SS")
    return(wss)}

wssplot(subdat)


