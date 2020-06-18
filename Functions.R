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


knnoutlier <- function(x,y){
  
  # Compute outliers by knn proximity based method, liberal 
  data<-data.frame(x,y)
  data<-data[complete.cases(data),]
  outliers_scores <- LOOP(data, k=5, lambda=3)
  outliers <- outliers_scores[which(outliers_scores>0.90)]
  
  if (length(outliers>0))
    
    return(TRUE)
    
} 


# Check linearity by boxcox
linearity <- function(x,y){
  
  # Compute outliers by knn proximity based method, liberal 
  data<-data.frame(x,y)
  data<-data[complete.cases(data),]
  outliers_scores <- LOOP(data, k=5, lambda=3)
  outliers <- outliers_scores[which(outliers_scores>0.90)]
  
  if (length(outliers>0)){
    dataclean <- data[-outliers, ]
  } else dataclean<-data
  
  xclean<-dataclean[,1]
  yclean<-dataclean[,2]
  
  
  # Boxcox without outliers
  # Just positive allowed 
   if (!all(yclean>0, na.rm=TRUE)) {
      y1 <- yclean+abs(min(yclean,na.rm=TRUE))+0.01*(max(yclean,na.rm=TRUE)-min(yclean,na.rm=TRUE))
   } else {y1 <- yclean}
    trafo <- boxcox(y1 ~ xclean, lambda = seq(-6,6,0.05), plotit = FALSE)
    vec<-trafo$x[trafo$y > max(trafo$y) - 1/2 * qchisq(.999,1)]
    vec2<-c(0.75,0.80,0.85,0.90,0.95,1.00,1.05,1.10,1.15,1.20,1.25) %in% round(vec,2)
    boxcoxtest1 <- sum(vec2)
  
  # Just positive allowed 
    if (!all(xclean>0, na.rm=TRUE)) {
     x1 <- xclean+abs(min(xclean,na.rm=TRUE))+0.01*(max(xclean,na.rm=TRUE)-min(xclean,na.rm=TRUE))
    } else {x1 <- xclean}
    trafo <- boxcox(x1 ~ yclean, lambda = seq(-6,6,0.05), plotit = FALSE)
    vec<-trafo$x[trafo$y > max(trafo$y) - 1/2 * qchisq(.999,1)]
    vec2<-c(0.75,0.80,0.85,0.90,0.95,1.00,1.05,1.10,1.15,1.20,1.25) %in% round(vec,2)
    boxcoxtest2 <- sum(vec2)
  
  if (boxcoxtest1 >0L & boxcoxtest2 >0L){

    return(TRUE)
  } else {
    return(FALSE)
  }

}

# Autocorrelation test, TRUE means no autocorrelation detected 
autocorr <- function(x,y){
  
  # Breusch-Godfrey Test
  bg1 <- bgtest(x~y, order=2)
  bg2 <- bgtest(y~x, order=2)
  
  r2 <- min(bg1$statistic/length(y),bg2$statistic/length(y))
  
  if (bg1$p.value > 0.01 & bg2$p.value > 0.01) {
    return(TRUE)
  } else if (r2 < 0.1) {return(TRUE)}
  else {return(FALSE)}
}


# Check normality 
normality <- function(x,y){
  
  data<-data.frame(x,y)
  data<-data[complete.cases(data),]
  
  qq1 <- qqnorm(residuals(lm(x~y)),plot=FALSE)
  qq2 <- qqnorm(residuals(lm(y~x)),plot=FALSE)
  qqcor <- min(with(qq1,cor(x,y)),with(qq2,cor(x,y)))
   
  # Shapiro
  if (nrow(data) < 150){
    if (shapiro.test(x)$p.value > 0.05 & shapiro.test(y)$p.value > 0.05 & qqcor>0.9) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  
  # Shapiro
  if (nrow(data)>=150 & nrow(data)<5000){
    if (shapiro.test(x)$p.value > 0.01 & shapiro.test(y)$p.value > 0.01) {
      return(TRUE)
    } else if (qqcor >=0.99){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  # Ad 
  if (nrow(data)>= 5000){
    if (ad.test(x)$p.value > 0.01 & ad.test(x)$p.value > 0.01) {
      return(TRUE)
    } else if (qqcor >=0.99){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
}

normality2 <- function(r){
  
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
  

pearsoncorr <- function(data,i){
  
  # Define pearson correlation for bootstrap statistic
  d <- data[i, ]
  return(cor(d, use="complete.obs", method="pearson")[1,2])
}


interpret_p <- function(rho, pvalue){
  
  if (pvalue>0.05) {
    cat("Interpretation: ")
    cat("By using the Pearson correlation coefficient, we do not find a statistically significant linear relationship between the variables.")
    cat("\\newline",fill=TRUE)
  } else {
  
      if (abs(rho)<0.1){
        cat("Nevertheless, the estimated Pearson correlation coefficient is very small in size and may have no practical meaning.", fill=TRUE)
        cat("\\newline",fill=TRUE)
      }  
      
      if (abs(rho)>=0.1 & abs(rho)<0.3){
        cat("Interpretation: ")
        cat("The estimated Pearson correlation coefficient is small in size. ", fill=TRUE)
      } 
      
      if (abs(rho)>=0.3 & abs(rho)<0.5){
        cat("Interpretation: ")
        cat("The estimated Pearson correlation coefficient is medium in size. ", fill=TRUE)
      }
      
      if (abs(rho)>=0.5){
        cat("Interpretation: ")
        cat("The estimated Pearson correlation coefficient is large in size. ", fill=TRUE)
      }
        
      cat(round(rho**2*100,1),"% of the variation in one variable may be attributed to the variation in the other variable. ", fill=TRUE) 
      
      if (rho <= -0.1){
        cat("There is a linearly decreasing relationship between the variables. If one variables increases in value, then the other one decreases. ")
        cat("\\newline",fill=TRUE)
      } 
      
      if (rho >= -0.1){
        cat("There is a linearly increasing relationship between the variables. If one variables increases in value, then the other one increases too. ") 
        cat("\\newline",fill=TRUE)
      }
  
   }
}



interpret_sp <- function(rho, pvalue){
  
  if (pvalue>0.05) {
    cat("Interpretation: ")
    cat("By using the Spearman rank correlation coefficient, we do not find a statistically significant monotonic relationship between the the variables.")
    cat("\\newline",fill=TRUE)
  } else {
    
    if (abs(rho)<0.1){
      cat("Nevertheless, the estimated Spearman rank correlation coefficient is very small in size and may have no practical meaning. ", fill=TRUE)
      cat("\\newline",fill=TRUE)
    }  
    
    if (abs(rho)>=0.1 & abs(rho)<0.3){
      cat("Interpretation: ")
      cat("The estimated Spearman rank correlation coefficient is small in size. ", fill=TRUE)
    } 
    
    if (abs(rho)>=0.3 & abs(rho)<0.5){
      cat("Interpretation: ")
      cat("The estimated Spearman rank correlation coefficient is medium in size. ", fill=TRUE)
    }
    
    if (abs(rho)>=0.5){
      cat("Interpretation: ")
      cat("The estimated Spearman rank correlation coefficient is large in size. ", fill=TRUE)
    }
    
    if (rho <= -0.1){
      cat("There is a significant, monotonic, decreasing relationship between the variables. If one variables increases in value, then the other one decreases. ")
      cat("\\newline",fill=TRUE)
    } 
    
    if (rho >= 0.1){
      cat("There is a significant, monotonic, increasing relationship between the variables. If one variables increases in value, then the other one increases too. ") 
      cat("\\newline",fill=TRUE)
    }
  }
}


interpret_ken <- function(tau,pvalue){
  
  if (pvalue>0.05) {
    cat("Interpretation: ")
    cat("We can conclude that the number of concordant data pairs is not statistically different from the number of disconcordant data pairs.", fill=TRUE)
    cat("\\newline",fill=TRUE)
    
  } else {
    
    if (tau <= -0.1){
      cat("There is a significant, monotonic, decreasing relationship between the variables. The number of disconcordant pairs is larger than the number of concordant pairs. ", fill=TRUE)
      cat("\\newline",fill=TRUE)
    } 
    
    if (tau >= 0.1){
      cat("There is a significant, monotonic, increasing relationship between the variables. The number of concordant pairs is larger than the number of disconcordant pairs. ", fill=TRUE) 
      cat("\\newline",fill=TRUE)
    }
    
    if (abs(tau)<0.1){
      cat("Nevertheless, the estimated Kendalls's Tau correlation coefficient is very small in size and may have no practical meaning. ", fill=TRUE)
      cat("\\newline",fill=TRUE)
    }
    
  }
  
}




# Other dependence 
dependence <- function(x,y){
  
  data<-data.frame(x,y)
  data<-data[complete.cases(data),]
  
  if (nrow(temp) <= 80){
    mic<- testforDEP(x,y, test="MIC", rm.na=TRUE, p.opt="MC")
  } else {
    mic<- testforDEP(x,y, test="MIC", rm.na=TRUE, p.opt="table")
  }
  
  dist <- dcor.test(data[,1],data[,2], R=100)
  
  if ((mic@TS>=0.3 & mic@p_value <= 0.05) || (dist$statistic >=0.3 & dist$p.value <= 0.05)){
    return(TRUE)
  } else {return(FALSE)}
  
}


# p-value format:
pformat<-function(p){
  if (p<0.001) return("<0.001") else return (round(p,3))
}



