
library(twitteR)
library(ROAuth)

my.key<-"
my.secret<- ""
accesstoken<-"-"
tokensecret<-""
setup_twitter_oauth(consumer_key=my.key, consumer_secret=my.secret, access_token=accesstoken, access_secret=tokensecret)

stocktweets=searchTwitter("#stock", n=10000, lang="en")
stocktweets[[2]]
library(plyr)
class(stocktweets) #list
stocktweets = laply(stocktweets,function(x) x$getText())
class(stocktweets) # no longer a list but character
`Encoding<-`(stocktweets,"UTF-8")
stocktweets = iconv(enc2utf8(stocktweets), sub = "byte")
stocktweets
length(stocktweets)
#removes retweets,RT@ etc.
stocktweets = laply(stocktweets, function(x) gsub("[@][^ ]*", " ", x))
#removes url's
stocktweets = laply(stocktweets, function(x) gsub("[h][t][t][[p][^ ]*", " ", x))
stocktweets = laply(stocktweets, function(x) gsub("[â] [€])*", " ", x))
library(stringr)
stocktweets = str_replace_all(stocktweets,"[^[:graph:]]", " ") 
#clean tweets and create corpus
library(tm)
library(SnowballC)
stockcorpus = Corpus(VectorSource(stocktweets))
stockcorpus = tm_map(stockcorpus,tolower)
stockcorpus = tm_map(stockcorpus,removePunctuation)
stockcorpus = tm_map(stockcorpus,removeNumbers)
#stemming
stockstem<-tm_map(stockcorpus,stemDocument)
dtm = DocumentTermMatrix(stockcorpus)
tweetsdf = as.data.frame(as.matrix(dtm))
inspect(dtm[1:5,1:7])
sparse = removeSparseTerms(dtm,0.99)
tweetsSparse = as.data.frame(as.matrix(sparse))
colnames(tweetsSparse) = make.names(colnames(tweetsSparse))
#wordcloud
library(wordcloud)
wordcloud(colnames(tweetsSparse),colSums(tweetsSparse),scale=c(10.5,0.5),min.freq=3)
bb.frequent<- sort(rowSums(as.matrix(dtm)), decreasing = TRUE)
#find minimum frequncy
findFreqTerms(dtm,lowfreq=60)
findAssocs(dtm,"predict",0.5)
#converttweetsintodataframe save to local
write.csv(stocktweets, "/Downloads/stock.csv")

positiveWords = scan(“positive-words.txt”,what=“character”,comment.char=“;”) 
negativeWords = scan(“negative-words.txt”,what=“character”,comment.char=“;”) 
negativeWords = c(negativeWords,“wtf”)

library(stringr); library(plyr)
score = laply(stocktweets,function(x){
  x = gsub('[[:punct:]]', '', x)
  x = gsub('[[:cntrl:]]', '', x)
  x = gsub('\\d+', '', x)
  xList = str_split(x,"\\s+")
  y = unlist(xList)
  y = iconv(enc2utf8(y), sub = "byte") #convert non UTF-8 char
  y =tolower(y)
  sum(!is.na(match(y,positiveWords))) - sum(!is.na(match(y,negativeWords)))
})
delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

# plot delays
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)
