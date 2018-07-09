library(tidyverse)
library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(caret)
library(broom)

########################################
# LOAD AND PARSE ARTICLES
########################################

# read in the business and world articles from files
# combine them both into one data frame called articles
business <- read_tsv('nyt_business.tsv',quote = "\'")
world <- read_tsv('nyt_world.tsv', quote = "\'")
articles <- rbind(business, world)

# create a corpus from the article snippets
# using the Corpus and VectorSource functions
corpus <- Corpus(VectorSource(articles$snippet))

# create a DocumentTermMatrix from the snippet Corpus
# remove stopwords, punctuation, and numbers
dtm <- DocumentTermMatrix(corpus, list(weighting=weightBin,
                                       stopwords=T,
                                       removePunctuation=T,
                                       removeNumbers=T))

# convert the DocumentTermMatrix to a sparseMatrix
X <- sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)

# set a seed for the random number generator so we all agree
set.seed(42)

########################################
# YOUR SOLUTION BELOW
########################################

# create a train / test split
train_index <- sample(1:nrow(X), 0.8*nrow(X))
trainX <- X[train_index, ]
trainY <- articles$section_name[train_index]
test_index <- setdiff(seq(1,2000), train_index)
testX <- X[test_index, ]
testY <- data.frame("section" = articles$section_name[test_index])

# cross-validate logistic regression with cv.glmnet (family="binomial"), measuring auc
glm <- cv.glmnet(trainX, trainY, family = "binomial", type.measure = "auc")

# plot the cross-validation curve
plot(glm)

# evaluate performance for the best-fit model
# note: it's useful to explicitly cast glmnet's predictions
# use as.numeric for probabilities and as.character for labels for this
testY$pred <- as.numeric(predict(glm, testX, type = "response"))
testY$label <- as.factor(predict(glm, testX, type = "class"))

# compute accuracy
testY %>% summarize(acc = mean(label == section))

# look at the confusion matrix
confusionMatrix(data = as.factor(testY$section), reference = as.factor(testY$label))

# plot an ROC curve and calculate the AUC
# (see last week's notebook for this)
pred <- prediction(testY$pred, testY$section)
perf <- performance(pred, measure = 'tpr', x.measure = 'fpr')
plot(perf)
performance(pred, 'auc')

# show weights on words with top 10 weights for business
# use the coef() function to get the coefficients
# and tidy() to convert them into a tidy data frame
wordCoef <- tidy(coef(glm)) 
wordCoef %>% filter(value < 0) %>% arrange(value) %>% head(10) %>% View()

# show weights on words with top 10 weights for world
wordCoef %>% arrange(desc(value)) %>% head(10) %>% View()
