\name{repos.dcf}
\alias{repos.dcf}
\title{ Extracts Additional_repositories field from DESCRIPTION file }
\description{
  \code{Additional_repositories} is a field that can be used in \emph{DESCRIPTION} file to provide non-CRAN and non-BioC repository url for package dependencies not available in mainstream repositories. This function is a helper function to extra url(s) from provided DESCRIPTION file(s).
}
\usage{
repos.dcf(file = "DESCRIPTION")
}
\arguments{
  \item{file}{ Character vector of file path(s) to DESCRIPTION file(s). }
}
\value{
  Character vector of repository urls, possibly of length 0, when no non-mainstream repositories were specified in DESCRIPTION file(s).
}
\seealso{
  \code{\link{packages.dcf}}, \code{\link{mirror.packages}}
}
\examples{
dcf.path <- system.file("DESCRIPTION", package="Matrix")
repos.dcf(dcf.path)

tmp.file <- tempfile()
writeLines("Additional_repositories: https://jangorecki.github.io/pkgup",
           tmp.file)
repos.dcf(tmp.file)
unlink(tmp.file)
}
\keyword{ data }