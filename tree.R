install.packages("rattle")
install.packages("rpart.plot")
install.packages("rpart")
install.packages("earth")
install.packages("caTools")
install.packages("Metrics")
install.packages("caret")
install.packages("psych")
install.packages("xgboost")
install.packages("nnet")
library(rpart.plot)
library(rpart)
library(rattle)
library(caTools)
library(earth)
library(Metrics)
library(caret)
library(psych)
library(car)
library(ggplot2)
library(xgboost)

set.seed(1)
# Full Training Data
df <- read.table("C:/Users/Anthony Silva/silvat/numerai/numerai_training_data.csv", header=TRUE, sep=",")
df$target <- factor(df$target)
# Modeling Dataset
X <- df[, 4:25]
X[1:21] <- scale(X[1:21])
samp <- sample.split(X, SplitRatio = .7)
train <- subset(X, samp==TRUE)
test <- subset(X, samp==FALSE)
logmodel <- glm(target ~ ., data=train, family=binomial)
test$predict <- predict(logmodel, test, type = 'response')
logLoss(as.numeric(test$target), as.numeric(test$predict))
summary(logmodel)


# Generate simple decision tree to determine if any variables have interactions 
fit <- rpart(target ~ . , data=X , method="class", control=rpart.control(minsplit=1000, minbucket=1, cp=0.001))
summary(fit)
# Visualize the Decision Tree
prp(fit)
fancyRpartPlot(fit, sub = "")


# Look at the density of all the features
names <- colnames(X)
for (i in 1:(dim(X)[2]))
{
  if (names[i] != "target")
  {
    plot(density(X[X$target == 1,i]), main = names[i])
    lines(density(X[X$target == 0, i]))
  }
}

library(ggplot2)
library(reshape2)
qplot(x=Var1, y=Var2, data=melt(cor(X[, !(names(X) %in% "target")])), fill = value, geom="tile")


# Fit a XGBoost model to find more features
install.packages("DiagrammeR")
library(DiagrammeR)

train <- subset(X, samp==TRUE)
test <- subset(X, samp==FALSE)
y = train$target
y <- as.numeric(levels(y))[y]
trmat<- data.matrix(train[1:21])
temat<- data.matrix(test[1:21])
trmat <- xgb.DMatrix(data=trmat, label=y)
fit <- xgb.train(data=trmat, label=y, max.depth=1, eta=1,nthread=2,nrounds = 5, eval.metric = "logloss", objective="binary:logistic")
xgb.plot.tree(model = fit)
pred <- predict(fit, newdata=temat)
test$predict <- pred
# With a 1 depth tree we get log loss barely better than random guessing
# So there is some information to be gained from the features
logLoss(as.numeric(test$target), as.numeric(test$predict))


# Ran depth 2,3,4,5 trees to find reoccuring important interactions
fit <- xgb.train(data=trmat,label=y, max.depth=5, eta=1,nthread=2,nrounds = 2, eval.metric = "logloss", objective="binary:logistic")
xgb.plot.tree(model = fit)
pred <- predict(fit, newdata=temat)
test$predict <- pred
logLoss(as.numeric(test$target), as.numeric(test$predict))
importance_matrix <- xgb.importance(model = fit)
xgb.plot.importance(importance_matrix=importance_matrix)



### Feature Engineering from Decision Tree and XGBoost modeling ###
# To reset modeling dataset
X <- df[, 4:25]
X[1:21] <- scale(X[1:21])

# Create a function that will take a dataframe generate new features and then return dataframe.
feature_engineer<-function(X){
  X <- X[4:25]
  X[1:21] <- scale(X[1:21])
  # From Generic Decision Tree Relationships generate new features
  X$feat19sq <- round(X$feature19*X$feature19,5)
  X$feat10x19 <- round(X$feature10*X$feature19,5)
  X$feat10x8 <- round(X$feature10*X$feature8,5)
  X$feat19d10 <- round(X$feature19/X$feature10,5)
  X$feat9x19x10x8 <- round(X$feature9 * X$feature19 * X$feature10 * X$feature8,5)
  X$feat19x4 <- round(X$feature19*X$feature4,5)
  X$feat19x7x4x21 <- round(X$feature19 * X$feature7 * X$feature4 * X$feature21,5)
  X$feat4d7 <- X$feature4/X$feature7
  X$feat4d7[is.infinite(X$feat4d7)] <- 0
  
  # Ran XGBoost depth 1 trees to find reoccuring important features
  X$feat16sq <- X$feature16*X$feature16
  X$feat12sq <- X$feature12*X$feature12
  
  # Feature Interactions from XGBoost base modeling and Feature Importance
  X$feat7x13 <- X$feature7*X$feature13
  X$feat16x12 <- X$feature12*X$feature16
  X$feat13x4x11 <- X$feature11*X$feature13*X$feature4
  X$feat16x5x6 <- X$feature16*X$feature5*X$feature6
  X$feat15sq <- X$feature15*X$feature15
  X$feat11sq <- X$feature11*X$feature11
  X$feat5sq <- X$feature5*X$feature5
  X$feat15x11x5 <- X$feature15*X$feature11*X$feature5
  X$feat5x10x6 <- X$feature5*X$feature10*X$feature6
  return(X)
}
X <- feature_engineer(df)
# Determine if Log Regression performance improved
train <- subset(X, samp==TRUE)
test <- subset(X, samp==FALSE)
fit <- glm(target ~ ., data=train, family=binomial)
test$predict <- predict(fit, test, type = 'response')
#test$predict <- ifelse(predict > .5, 1, 0) # Used to get the actual values and not predicted probabilities.
# Performance stayed the same however, more of the features that were added are significant
logLoss(as.numeric(test$target), as.numeric(test$predict))
summary(fit)


# Build MARS model to identify important features and build potential model
library(earth)
train <- subset(X, samp==TRUE)
test <- subset(X, samp==FALSE)
fit <- earth(formula=target ~ ., data=train, degree = 6, trace=3 , thresh=0, glm=list(family=binomial))
#plotmo(fit)
test$predict <- predict(fit, test, type = 'response')
logLoss(as.numeric(test$target), as.numeric(test$predict))
#plot.earth.models(fit)
summary(fit)
evimp(fit)


# Use this to assess final predictions on tournament data set.
submit <- read.table("C:/Users/Anthony Silva/silvat/numerai/numerai_tournament_data.csv", header=TRUE, sep=",")
submit$target <- factor(submit$target)
final <- feature_engineer(submit)
submit$predict <- predict(fit, final, type= 'response')
logLoss(as.numeric(submit$target[submit$data_type == "validation"]), as.numeric(submit$predict[submit$data_type == "validation"]))



# Export for submition to leaderboard
export<- data.frame(submit$id, submit$predict)
colnames(export) <- c("id","probability")
export$probability <- format(export$probability, scientific = FALSE)
write.csv(export, "C:/Users/Anthony Silva/silvat/numerai/submit.csv", row.names = FALSE)
