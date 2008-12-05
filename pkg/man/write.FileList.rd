\name{write.FileList}
\alias{write.FileList}
\title{Import a batch of files to the source table}
\description{
If import individual file to the project, you can do it by clicking import button in the Files Tab. 
Sometimes, you want to import a batch of files quickly, you can do it by command. This function is 
used to import a batch of files into the source table in the *.rqda file.
}
\usage{
write.FileList(FileList, encoding = .rqda$encoding, con = .rqda$qdacon, ...)
}

\arguments{
  \item{FileList}{A list. Each element of the list is the file content, and the \code{names(FileList)} are the respective file name.}
  \item{encoding}{ Don't change this argument.}
  \item{con}{ Don't change this argument.}
  \item{\dots}{ \code{\dots} is not used.}
}

\value{
 This function is used for the side-effects. No value is return.
}
\author{Huang Ronggui}
\examples{
\dontrun{
Files <- list("File name one"="content of first File.","File name two"="content of the second File.")
write.FileList(Files) ## Please launch RQDA(), and open a project first.
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
