################################################################################
# global.R - functions and global data for shiny App

##LIBRARIES
is_installed <- function(mypkg) is.element(mypkg, installed.packages()[,1])
load_or_install<-function(package_names)  
{  
  for(package_name in package_names)  
  {  
    if(!is_installed(package_name))  
    {  
      install.packages(package_name,repos="http://cran.csiro.au/")  
    }  
    library(package_name,character.only=TRUE,quietly=TRUE,verbose=FALSE)  
  }  
}  

load_or_install(c("shiny", "ggplot2", "broom", "dplyr"))
                 

## GENERAL FUNCTIONS
# CSV import helpers (different date formats)
csvImportb5 <- function(x){
  df <- read.csv(x, header = TRUE, stringsAsFactors = FALSE)
  df$date <- as.Date(df$date, "%d/%m/%Y")
  df
}

csvImporth <- function(x){
  df <- read.csv(x, header = TRUE, stringsAsFactors = FALSE)
  df$date <- as.Date(df$date, "%Y-%m-%d")
  df
}

# Function to create named list for selectInput choices
choices <- function(x){
  hnames <- names(x)[-1]
  choices <- as.list(hnames)
  names(choices) <- hnames
}

# Function to create index for closest dates and return a df
df2model <- function(x, y, z){
  
  #specific data to wetland
  id5 <- match(x, bnames)#find b5 data
  b5 <- b5[,c(1,id5)]
  b5 <- b5[complete.cases(b5),]
  idh <- match(x, dnames)#find hdepth data
  hist <- hDepth[,c(1,idh)]
  hist <- hist[complete.cases(hist),]
  
  #trim hist data set
  mb5 <- min(b5$date)
  hist <- hist[hist$date >= mb5, ]
  names(hist) <- c("date_d", "depth")
  
  #b5 date only
  datelist <- b5$date
  
  #depth date only
  tomatch <- hist$date_d
  
  #index to closest match between hDepth and b5
  ind <- sapply(tomatch, function(x) which.min(abs(datelist-x)))
  
  #subset band 5 values according to closest match up
  b5M <- b5[ind,]
  names(b5M) <- c("date_b5", "b5")
  
  #combine matched band 5 values to depth values
  all <- cbind(b5M, hist)
  
  #reorder columns and calculate difference in dates
  all <- all%>%
    select(date_b5, date_d, b5, depth)%>%
    mutate(diff = abs(date_b5 - date_d))
  
  # data set with <= selected day differential
  df <- all%>%
    filter(diff <= y)%>%
    filter(depth >= z)
  # NA's removed
  df <- df[complete.cases(df), ]
  
  #add small amount (using gamma model)
  df$depth.i <- df$depth + 0.0001
  return(df)
}

# Function to create wetland specific depth df (used in pred plot)
dfpredhist <- function(x){
  idh <- match(x, dnames)#find hdepth data
  hist <- hDepth[,c(1,idh)]
  hist <- hist[complete.cases(hist),]
  names(hist) <- c("date", "depth")
  return(hist)
  
}

# Function to create wetland specific band 5 df (used in pred plot)
dfpredb5 <- function(x){
  id5 <- match(x, bnames)#find b5 data
  b5 <- b5[,c(1,id5)]
  b5 <- b5[complete.cases(b5),]
  names(b5) <- c("date", "b5")
  return(b5)
}

# Function to fit log model
mod <- function(df){
  fitexp <- lm(log(depth.i) ~ b5, data = df)
  return(fitexp)
}

# Function to return p.value from model (not used now)
lmp <- function (model) {
  if (class(model) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(model)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
}

# Function to create df of model (used in mod plot)
mData <- function(df, model){
  fitexp <- model
  MyData      <- data.frame(X1 = seq(range(df$b5)[1], range(df$b5)[2], 
                                     length = 40))# restrict to modelled data range
  X           <- model.matrix(~ X1, data = MyData) # obtain matrix
  MyData$eta  <- X %*% coef(fitexp)# matrix multiplication!!
  MyData$ExpY <- exp(MyData$eta)# account for log link
  MyData$SE   <- sqrt(diag(X %*% vcov(fitexp) %*% t(X)))
  MyData$ub   <- exp(MyData$eta + 1.96 * MyData$SE)
  MyData$lb   <- exp(MyData$eta - 1.96 * MyData$SE)
  
  return(MyData)
}

# Function to create df of prediction values (used in pred plot)
pData <- function(df, model){
  fitexp <- model
  predexp <- exp(predict(fitexp, data.frame(b5 = df$b5)))
  b5modelled <- data.frame(date = df$date, b5 = df$b5, exp = predexp)
  return(b5modelled)
}


## GLOBAL DATA
# Create global data sets
b5 <- csvImportb5("data/dfb5.csv")
hDepth <- csvImporth("data/dfhist.csv")
mychoices <- choices(hDepth)
bnames <- names(b5)
dnames <- names(hDepth)
