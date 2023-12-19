\name{packages.dcf}
\alias{packages.dcf}
\title{ Extracts package R dependencies from DESCRIPTION file }
\description{
  For provided DESCRIPTION file(s) function extracts fields that specifies R dependencies and returns them as package names.
}
\usage{
packages.dcf(file = "DESCRIPTION", which = "strong", except.priority = "base")
}
\arguments{
  \item{file}{ Character vector of file path(s) to DESCRIPTION file(s). }
  \item{which}{ a character vector listing the types of dependencies, a subset of \code{c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")}. Character string \code{"all"} is shorthand for that vector, character string \code{"most"} for the same vector without \code{"Enhances"}, character string \code{"strong"} (default) for the first three elements of that vector. }
  \item{except.priority}{ Character vector, accepts \code{"base"} (default), \code{"recommended"}" or both. }
}
\value{
  Character vector of dependency packages names extracted from provided file(s).
}
\seealso{
  \code{\link{mirror.packages}}, \code{\link{repos.dcf}}
}
\examples{
dcf.path <- system.file("DESCRIPTION", package="Matrix")
packages.dcf(dcf.path)
packages.dcf(dcf.path, which="most")
packages.dcf(dcf.path, which="all")
packages.dcf(dcf.path, which="all", except.priority="recommended")
packages.dcf(dcf.path, which="all", except.priority=c("base","recommended"))
}
\keyword{ data }