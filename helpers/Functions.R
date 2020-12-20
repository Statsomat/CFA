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
pformat <- function(p){
  if (is.na(p)){
    return(NA)
  } else if (p<0.001){ 
    return("<0.001")
  } else return (round(p,3))
}


# Cutoff value chi2
cutchi2 <- function(n){
  if (n<300){
    return(0.05)
  } else {
    return(0.01)
  }
}


# Cutoff value srmr
cutsrmr <- function(n){
  if (n<300){
    return(0.1)
  } else if (n<500){
    return(0.08) 
  } else {
    return(0.06)
  }
}

# Standardized cov residuals larger than 2.58
stand_residuals <- function(x,sign){
  covstd <- resid(x, type="standardized")$cov # Std residuals on cov
  if (sign=="neg"){
    covstd = -covstd
  }
  m <- data.frame(which(covstd>=2.58, arr.ind=TRUE))
  size <- nrow(m)/2 + 1
  m <- m[size:nrow(m),]
  m <- m[order(m$row),]
  dimnames <- x@Model@dimNames[[1]][1][[1]]
  dimnames2 <- data.frame(dimnames[m[,1]],dimnames[m[,2]])
  dimnames2 <- dimnames2[complete.cases(dimnames2),]
  return(dimnames2)
}

# Corr residuals larger than 0.1
corr_residuals <- function(x,sign){
  covstd <- resid(x, "cor")$cov # Residuals 
  if (sign=="neg"){
    covstd = -covstd
  }
  m <- data.frame(which(covstd>=0.1, arr.ind=TRUE))
  size <- nrow(m)/2 + 1
  m <- m[size:nrow(m),]
  m <- m[order(m$row),]
  dimnames <- x@Model@dimNames[[1]][1][[1]]
  dimnames2 <- data.frame(dimnames[m[,1]],dimnames[m[,2]])
  dimnames2 <- dimnames2[complete.cases(dimnames2),]
  return(dimnames2)
}

# No Cross-loadings is TRUE
cross_loadings <- function(df){
  if (sum(duplicated(df[df$op=="=~",3])) == 0){
    return(TRUE) 
  } else {
    return(FALSE)}
}

# Error covariances existent? 
error_covariances <- function(df,fit){
  covariances_stand <- df[df$op=="~~",]
  covariances_stand <- covariances_stand[which(covariances_stand$lhs != covariances_stand$rhs),]
  ov <- fit@Model@dimNames[[4]][[1]]
  covariances_error <- covariances_stand[which(covariances_stand$lhs %in% ov),]
  if (nrow(covariances_error)>0){
    return(TRUE) 
  } else {
    return(FALSE)}
}


# Table Interpretation of Unstandardized Factor Loadings
text <-  function(df, cols){
  x <- df[df$op=="=~",3]
  duplicates <- which(duplicated(x))
  if (is.na(cols[4])){
    paste(cols[2],"is marker variable for",cols[1])
  } else if (cols[3]>=0){
    if (cols[2] %in% df[duplicates,3]){
      paste("A 1-unit increase in",cols[1],"leads to a",cols[3],"-unit increase in the",cols[2],"while the other factor(s) are held constant.")
    } else {
      paste("A 1-unit increase in",cols[1],"leads to a",cols[3],"-unit increase in the",cols[2])
    }
  } else {
    if (cols[2] %in% df[duplicates,3]){
      paste("A 1-unit increase in",cols[1],"leads to a",cols[3],"-unit decrease in the",cols[2],"while the other factor(s) are held constant.")
    } else {
      paste("A 1-unit increase in",cols[1],"leads to a",cols[3],"-unit decrease in the",cols[2])
    }
  }
}


# Cross-loadings rowwise 
cross_loadings_row <- function(df,cols){
  if (cols[2] %in% df[which(duplicated(df$Variable)),2]){
    paste("cross")
  } else {
    paste("x") }
  
}

