# Numerai Machine Learning Project
### by: Tony Silva
### email: tonysilva.ou@gmail.com

## Numerai Machine Learning Challenge
The Numerai Machine Learning Challenge is a relatively new challenge offered by the organization Numerai. The challenge can be found on https://numer.ai. The challenge attempts to bring many different data science minds together to make predictions against the same data set. Much like Kaggle, Numerai has a leader and the opportunity to win money by using Data Science skills.

In the Numerai Challenge, data scientists make predictions against Numerai's encrypted hedge fund data. Numerai then ensemble's the predictions provided by the data scientists in the challenge to generate a meta model. This meta model is then used to make predictions to improve Numerai's hedge fund. From the article, [Super Intelligence for The Stock Market](https://medium.com/numerai/invisible-super-intelligence-for-the-stock-market-3c64b57b244c), "Numerai is able to combine each model into a meta model just like Random Forests combine decision trees into a forest". With this ensemble of predictions Numerai is able to perform better than any one model given to them. They are not looking for "best" overall model but they are looking for many different "good" models that helps with their overall meta model.

Numerai has many different criteria to assess if a data scientist's predictions add to their meta model. 
* Log Loss - On average the model must perform better than -ln(.5) ~ .693.
* Originality - Predictions made must not correlate to other predictions already submitted.
* Concordance - Predictions made on the validation, test, and live data must come from the same model.
* Consistency - The model must perform better than .693 log loss on at least 75% of "eras".

## Machine Learning Approach
In this project both R and Python were utilized. R was utilized more for Feature Engineering, while Python was utilized for the creation of the predictive model. Usually, I would stick with one language for a project, however, for the sake of gaining more experience I utilized both. The machine learning problem for this challenge was binary classification.

### Exploratory Data Analysis
The data given by Numerai came in two different data sets. First, Numerai provided their "Training" data. The training data contained 108,405 observations. The second data set provided contained Numerai's "validation", "test", and "live" data. This data set was called their "Tournament Data". The validation data was used to utilized to determine position on the leaderboard. The test and live data set were used to assess performance on whether the data scientist received a payout. The training and validation data had target values labeled. The target value was labeled as 0 and 1. In the data set both target values had roguhly the same number of observations.

```
print(df.groupby(["target"]).count())
```

| Target        | Count         |
| ------------- |:-------------:|
| 0             | 62122         |
| 1             | 62969         |

Each of the data sets provided an id column, that labeled each observation. A data_type column specifiying what type of observation it was: train, validation, test or live. An era column, where the era specified was the time frame the observation was taken from. The challengers were told this column should not be utilized as a feature and the time frame between eras was not specified nor the distinction of what an era actually is. The data sets provided 21 features, labeled "feature1", "feature2" ... "feature21".

#### Missing Values
Thankfully there were no missing values found in the data set. I utilized the following command to find any.
```
print(df.isnull().sum())
```

All of the features' values fall between the range of [0,1]. For all of the features, the distributions appear to follow a normal distribution. The density plot of feature1 describes pretty well what is seen across all features, however, with different variability and size of the "bell" in the bell curve. An example can be seen below:

![feature1 distribution](https://github.com/silv6928/numerai/blob/master/images/distribution.jpg)

Density distributions for each target value were observed for each of the features. This could help determine if the different target values followed a different distribution for any of the features.

```
names <- colnames(X)
for (i in 1:(dim(X)[2]))
{
  if (names[i] != "target")
  {
    plot(density(X[X$target == 1,i]), main = names[i])
    lines(density(X[X$target == 0, i]))
  }
}
```

![feature6 density](https://github.com/silv6928/numerai/blob/master/images/density.jpg)

I would have hoped to have seen two different distinct normal curves. This would have told me that for a given feature we could derive a differing distribution between the target values. This could have helped generate our predictive model. However, from the plot above for each feature, the target values followed the same distribution. The next approach was to determine correlations between features.

```
library(ggplot2)
library(reshape2)
qplot(x=Var1, y=Var2, data=melt(cor(X[, !(names(X) %in% "target")])), fill = value, geom="tile")
```

or

```
plt.figure()
sns.heatmap(train.corr())
plt.show()
plt.close()
```

Produces the following Correlation Matrix.

![correlation matrix](https://github.com/silv6928/numerai/blob/master/images/correlations.png)

#### Feature Engineering
Unfortunately the data set was entirely encrypted and features were unnamed. This meant applying intuition around the project was impossible and generating new features would be a challenge. In order to determine important features and important interactions between features.

### Predictive Modeling

#### Sampling Approach

#### Neural Network Creation

#### Sampling Re-Approach &  K-Nearest Neighbors Classifier

## Final Performance

