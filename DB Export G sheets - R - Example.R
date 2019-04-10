# comment
# BBDC Weekly Reporting Project

library(RMySQL)
mydb = dbConnect(MySQL(), user='username', password='password', dbname='kazaam', host='kenshooprd.local')

rs=dbSendQuery(mydb, 
               'SELECT cc.campaign_name,
               pbc.* from performance_by_campaign_id pbc
               JOIN customer_campaigns cc on cc.campaign_id = pbc.campaign_id
               WHERE (date >= (CURDATE() - INTERVAL 1 MONTH )
               GROUP BY cc.campaign_name')
data = fetch(rs, n=-1)

library(data.table)
data = as.data.table(data)

data.search = data[!grepl("FB",campaign_name)]

View(data)

data2 = data.search[,.(Impressions=sum(imps,na.rm = T),
                       Clicks=sum(clicks,na.rm=T),
                       Spend=round(sum(cost,na.rm=T,2)),
                       Sales=sum(conv,na.rm = T),
                       Revenue=sum(commission,na.rm = T)),
                    by=.(week(as.Date(date)))]


data2[,CPC:=round(Spend/Clicks,2)][,CTR:=round(Clicks/Impressions,4)][,CPA:=round(Spend/Sales,2)][,AOV:=round(Revenue/Sales,2)][,ROI:=round(Revenue/Spend,2)][,CR:=round(Sales/Clicks,2)]

install.packages("googlesheets")
install.packages("dplyr")

library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))

funkypigeon <- gs_title("Funky Pigeon - Weekly Reporting Template")

funkypigeon %>% gs_browse()
funkypigeon %>% gs_browse(ws = "R Test")

funkypigeon %>% gs_read(ws = "Funky Pigeon - Weekly Reporting", range = "A1:D8")

gs_edit_cells(funkypigeon, ws = "R Test", input = data2, anchor = "B8", byrow = FALSE,
              col_names = NULL, trim = FALSE, verbose = TRUE)

dbDisconnect(mydb)