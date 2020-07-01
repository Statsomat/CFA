# Continuity definition
cutoffcont <- function(n){
  
  # Cutoff for continuity f(n)=a*log10(n)+b, f(10)=0.75, f(>=100)=0.25
  
  b=125
  a=-50
  
  if (n<=100) {  
    cut <- min(1,(a*log10(n)+b)/100)
  } else {
    # 25 unique values for sample sizes greater than 100
    cut <- 25/n
  }
  return(cut)
}


# Compute outliers by knn proximity based method, liberal 
# For x,y variable pair
knnoutlier <- function(x,y){
  data<-data.frame(x,y)
  data<-data[complete.cases(data),]
  outliers_scores <- LOOP(data, k=5, lambda=3)
  outliers <- outliers_scores[which(outliers_scores>0.90)]
  if (length(outliers>0))
    return(TRUE)
    
} 


# Check normality of one variable r
normality <- function(r){
  
  qq <- qqnorm(r,plot=FALSE)
  qqcor <- with(qq,cor(x,y))
  
  # Shapiro
  if (length(r) < 5000){
    if (shapiro.test(r)$p.value > 0.01) {
      return(TRUE)
    } else if (qqcor >=0.98){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  # Ad 
  if (length(r) >= 5000){
    if (ad.test(r)$p.value > 0.01) {
      return(TRUE)
    } else if (qqcor >=0.95){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
    
  
}
  

# p-value format
pformat<-function(p){
  if (p<0.001) return("<0.001") else return (round(p,3))
}



# Weight for chi2 index 
weightchi2 <- function(n,nfactors,loadings){
  
  if ((n<=250 && nfactors <=4 && loadings %in% c(0.4,0.5)) || (n %in% c(251,500) && nfactors <=4 && loadings <=0.4) || (n <=250 && nfactors %in% c(5,8) && loadings <=0.4)) {
    weightchi2=0.5
  } else if (n<=250 && nfactors <=4 && loadings <=0.4) {
    weightchi2=1
  } else {
    weightchi2=0
} 
 return(weightchi2)
}


