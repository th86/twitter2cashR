## Twitter2Cash in R
## Feb. 18, 2017
## Tai-Hsien Ou Yang

library("RCurl")
library("XML")
library("jsonlite")

## Positions ##

portfolio=list()
#portfolio[["X"]]=30
#portfolio[["AET"]]=30

## PE ratio threshold ##

peThreshold=20

## VIP's twitter ##

twitterURL="https://twitter.com/<VIP_Twitter_Accout>"

## stock quote API ##
quoteAPI="http://www.google.com/finance/info?infotype=infoquoteall&q="

## NLP database ## 
positiveWordList<-read.table("positive-words.txt", skip=35, stringsAsFactors=FALSE)$V1
negativeWordList<-read.table("negative-words.txt", skip=35, stringsAsFactors=FALSE)$V1

symbolListNasdaqlisted<-read.table("nasdaqlisted.txt", sep="|",  header=TRUE, stringsAsFactors=FALSE)
symbolListOtherlisted<-read.table("otherlisted.txt", sep="|",  header=TRUE, stringsAsFactors=FALSE) #clean quotes and eof

#Preprocess the names
symbolListRaw<-tolower(c(symbolListNasdaqlisted$Security.Name, symbolListOtherlisted$Security.Name))
symbolListSecurityNameList<-strsplit(symbolListRaw, " " )
names(symbolListSecurityNameList)<-c(symbolListNasdaqlisted$Symbol, symbolListOtherlisted$ACT.Symbol)

#Parse the an incoming tweet 
tweetRaw <- htmlParse(paste(readLines(twitterURL, warn = FALSE), collapse = ""), asText = TRUE)
tweetParsed <- xpathSApply(tweetRaw, "//p", xmlValue)[3] #latest tweet
tweetParsedFilter<-gsub("@|[.]|'| and|and | for |the|inc.|stock|new|etf|msci|american| u.s. |mexico|ishares|just|common|first|time|south|north|east|west|corp.|ltd.|innovation|investment", " ",tolower(tweetParsed))
tweetSplit<- strsplit(  tweetParsedFilter, " " )[[1]] 
tweetSplitFiltered<-tweetSplit[which(nchar(tweetSplit)>2)]

#A simplest NLP model: inferring VIP's sentiment by the ratio of positive/negative words in a tweet.
WordCountPositive<-length( intersect( tweetSplitFiltered, positiveWordList  ) ) 
WordCountNegative<-length( intersect( tweetSplitFiltered, negativeWordList  ) ) 

#Filter the sentimental words out, so that we can infer the symbol
tweetSplitFilteredSymbol<-setdiff(tweetSplitFiltered, intersect( tweetSplitFiltered, positiveWordList  ) )

#Find the symbol from the database
symbolMatchCount<-rep(0, length(symbolListSecurityNameList) )
names(symbolMatchCount)<-names(symbolListSecurityNameList)
for( itr in names(symbolMatchCount) )
  symbolMatchCount[itr]<-length( intersect( tweetSplitFilteredSymbol,  symbolListSecurityNameList[[itr]]))

symbolList<-names(sort(symbolMatchCount,decreasing=TRUE))[1:length(which(symbolMatchCount>0))]

#A simple trading machine that gets you $$$
for(symbol in symbolList){
    currentQuote <- tryCatch(fromJSON(gsub("//","",readLines(paste( quoteAPI, symbol, sep="")))), error = function(e) {return=NULL})

    if(is.null(currentQuote)==FALSE){
      currentQuoteValue<-as.numeric(currentQuote$l) 
      currentQuotePE<-as.numeric(currentQuote$pe)

      if(currentQuoteValue>5 & is.na(currentQuotePE)==FALSE)
      #Buy
      if(WordCountPositive>WordCountNegative & currentQuoteValue<currentQuoteHi52 & currentQuotePE<peThreshold) 
        cat(as.character(Sys.time()), "BUY", symbol, "@", currentQuoteValue, "\n")
      #Sell
      if(symbol%in%names(portfolio))
      if(WordCountPositive<WordCountNegative & currentQuoteValue>portfolio[[symbol]] )
        cat(as.character(Sys.time()), "SELL", symbol, "@", currentQuoteValue, "\n")
    }
}


