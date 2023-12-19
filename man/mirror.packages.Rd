\name{mirror.packages}
\alias{mirror.packages}
\title{ Mirror R packages from remote R repository to local R repository }
\description{
  For provided package names in \code{pkgs} argument, the function will examine all recursive dependencies (according to \code{which} argument). Then it will download all packages sources or binaries (according to \code{type} argument) to local directory retaining CRAN directory structure and creating PACKAGES index file.
}
\usage{
mirror.packages(pkgs,
  which = "strong",
  repos = getOption("repos"),
  type = c("source", "mac.binary", "win.binary"),
  repodir,
  except.repodir = repodir,
  except.priority = "base",
  quiet = TRUE,
  \ldots
)
}
\arguments{
  \item{pkgs}{ Character vector packages names. }
  \item{which}{ a character vector listing the types of dependencies, a subset of \code{c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")}. Character string \code{"all"} is shorthand for that vector, character string \code{"most"} for the same vector without \code{"Enhances"}, character string \code{"strong"} (default) for the first three elements of that vector. }
  \item{repos}{ Character vector, specifies remote R packages repository, usually CRAN. }
  \item{type}{ Character scalar, one of \code{"source", "mac.binary", "win.binary"}. Default (unless on Windws) \code{"source"} downloads \emph{tar.gz} archive of packages sources, \code{"mac.binary"} downloads \emph{tgz} archive of macos binaries, \code{"win.binary"} downloads \emph{zip} archive of windows binaries. }
  \item{repodir}{ Character scalar, path where local R packages repository should be created. }
  \item{except.repodir}{ Character scalar, default to \code{repodir} argument value, used to skip packages that are already present in repository specified in \code{except.repodir}. }
  \item{except.priority}{ Character vector, accepts \code{"base"} (default), \code{"recommended"}" or both. }
  \item{quiet}{ Logical, If TRUE (default), suppress status messages (if any), and the progress bar, passed to \code{\link[utils]{download.file}}. }
  \item{\ldots}{ Extra arguments passed to \code{\link[tools]{write_PACKAGES}} function. }
}
\note{
  Argument \code{type="mac.binary"} has not been tested.
}
\value{
  Character matrix, as returned from internally used \code{\link[utils]{download.packages}} function.
}
\seealso{
  \code{\link{packages.dcf}}, \code{\link{repos.dcf}}
}
\examples{
if (requireNamespace("Matrix", quietly=TRUE)) {

dcf.path <- system.file("DESCRIPTION", package="Matrix")
deps <- packages.dcf(dcf.path, which="most")
repos <- c("https://cloud.r-project.org", repos.dcf(dcf.path))

repodir <- "Matrix_CRAN"
mirror.packages(deps, repos=repos, repodir=repodir, type="source", addFiles=TRUE)
mirror.packages(deps, repos=repos, repodir=repodir, type="win.binary", addFiles=TRUE)

localrepos <- file.path("file:", normalizePath(repodir))
available.packages(type="source", repos=localrepos)[,c("Package","Repository","File")]
available.packages(type="win.binary", repos=localrepos)[,c("Package","Repository","File")]

unlink(repodir, recursive=TRUE)

}
}
\keyword{ data }