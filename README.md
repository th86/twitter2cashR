twitter2cash in R

====

A minimalist model that fetches a VIP's twitter feed without login, infers the VIP's mood about the company in the tweet, checks the quote and other information of the stock, and makes investing decisions. The decision making subroutine may be hooked to an online broker's API.

This project is inspired by [trump2cash](https://github.com/maxbbraun/trump2cash), which is far more powerful and complicated. 

## Required Libraries and Resources ##

RCurl, XML, jsonlite.

The word database for sentiment analysis may be derived from [jeffreybreen's tutorial](https://github.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107/tree/master/data/opinion-lexicon-English). The ticker symbol database may be derived from [NASDAQ](ftp://ftp.nasdaqtrader.com/symboldirectory/).

## License ##

This project is licensed under the MIT license.