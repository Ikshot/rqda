CaseNamesUpdate <- function(CaseNamesWidget=.rqda$.CasesNamesWidget,sortByTime=FALSE,decreasing=FALSE,...)
{
  if (isIdCurrent(.rqda$qdacon)){
##  CaseName <- dbGetQuery(.rqda$qdacon, "select name, id,date from cases where status=1 order by lower(name)")
  CaseName <- dbGetQuery(.rqda$qdacon, "select name, id,date from cases where status=1")
  if (nrow(CaseName)==0) {
    case <- NULL
  } else {
    case <- CaseName$name
    Encoding(case) <- "UTF-8"
    if (!sortByTime) {case <- sort(case)} else {
    case <- case[OrderByTime(CaseName$date,decreasing=decreasing)]
    }
  }
     tryCatch(CaseNamesWidget[] <- case, error=function(e){})
  }
}

#################
###############
AddCase <- function(name,conName="qdacon",assignenv=.rqda,...) {
  if (name != ""){
    con <- get(conName,assignenv)
    maxid <- dbGetQuery(con,"select max(id) from cases")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    if (nextid==1){
      write <- TRUE
    } else {
      dup <- dbGetQuery(con,sprintf("select name from cases where name=='%s'",name))
      if (nrow(dup)==0) write <- TRUE
    }
    if (write ) {
      dbGetQuery(con,sprintf("insert into cases (name, id, status,date,owner)
                                            values ('%s', %i, %i,%s, %s)",
                             name,nextid, 1, shQuote(date()),shQuote(.rqda$owner)))
    }
  }
}


AddFileToCaselinkage <- function(Widget=.rqda$.fnames_rqda){
  ## filenames -> fid -> selfirst=0; selend=nchar(filesource)
  filename <- svalue(Widget)
  Encoding(filename) <- "unknown"
  query <- dbGetQuery(.rqda$qdacon,sprintf("select id, file from source where name in (%s) and status=1",
  paste("'",filename,"'",sep="",collapse=",")))
  fid <- query$id
  Encoding(query$file) <- "UTF-8"
  selend <- nchar(query$file)

  ## select a case name -> caseid
  cases <- dbGetQuery(.rqda$qdacon,"select id, name from cases where status=1")
  if (nrow(cases)!=0){
    Encoding(cases$name) <- "UTF-8"
##    ans <- select.list(cases$name,multiple=FALSE)
    CurrentFrame <- sys.frame(sys.nframe())

    RunOnSelected(cases$name,multiple=FALSE,enclos=CurrentFrame,expr={
      if (Selected!=""){
        ##Selected <- iconv(Selected,to="UTF-8")
        Encoding(Selected) <- "UTF-8"
        caseid <- cases$id[cases$name %in% Selected]
        exist <- dbGetQuery(.rqda$qdacon,sprintf("select fid from caselinkage where status=1 and fid in (%s) and caseid=%i",paste("'",fid,"'",sep="",collapse=","),caseid))
        if (nrow(exist)!=length(fid)){
          ## write only when the selected file associated with specific case is not in the caselinkage table
          DAT <- data.frame(caseid=caseid, fid=fid[!fid %in% exist$fid], selfirst=0, selend=selend[!fid %in% exist$fid], status=1,owner=.rqda$owner,data=date(),memo='')
          success <- dbWriteTable(.rqda$qdacon,"caselinkage",DAT,row.name=FALSE,append=TRUE)
          ## write to caselinkage table
          if (!success) gmessage("Fail to write to database.")
        }
      }
    }
                  )
  }
}



UpdateFileofCaseWidget <- function(con=.rqda$qdacon,Widget=.rqda$.FileofCase){
  Selected <- svalue(.rqda$.CasesNamesWidget)
  if (length(Selected)!=0){
    caseid <- dbGetQuery(.rqda$qdacon,sprintf("select id from cases where status=1 and name='%s'",Selected))[,1]
    ## Encoding(Selected) <- "UTF-8"
    Total_fid <- dbGetQuery(con,sprintf("select fid from caselinkage where status==1 and caseid==%i",caseid))
    if (nrow(Total_fid)!=0){
      items <- dbGetQuery(con,"select name,id,date from source where status==1")
      if (nrow(items)!=0) {
        items <- items[items$id %in% Total_fid$fid,c("name","date")]
        items <- items$name[OrderByTime(items$date)]
        Encoding(items) <- "UTF-8"
      } else items <- NULL
    } else items <- NULL
  } else items <- NULL
  tryCatch(Widget[] <- items,error=function(e){})
}

HL_Case <- function(){
    if (is_projOpen(env=.rqda,conName="qdacon")) {
        con <- .rqda$qdacon
        SelectedFile <- svalue(.rqda$.root_edit)
        ## Encoding(SelectedFile) <- "UTF-8"
        currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
        W <- .rqda$.openfile_gui
        if (length(currentFid)!=0) {
            caseName <- svalue(.rqda$.CasesNamesWidget)
            caseid <- dbGetQuery(con,sprintf("select id from cases where name=='%s'",caseName))[,1]
            mark_index <-
                dbGetQuery(con,sprintf("select selfirst,selend from caselinkage where fid=%i and status==1 and caseid=%i",currentFid,caseid))
            if (nrow(mark_index)!=0){
                ClearMark(W ,0 , max(mark_index$selend),clear.fore.col = FALSE, clear.back.col = TRUE)
                HL(W,index=mark_index,fore.col=NULL,back.col=.rqda$back.col)
            }
        }
    }
}


