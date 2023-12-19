## code from this package was meant to be added to base R `tools` package
## as a result, it uses two internal function from `tools` package
.get_standard_package_names = tools:::.get_standard_package_names
.extract_dependency_package_names = tools:::.extract_dependency_package_names

packages.dcf <-
function(file = "DESCRIPTION",
         which = "strong",
         except.priority = "base") {
    if (!is.character(file) || !length(file) || !all(file.exists(file)))
        stop("file argument must be character of filepath(s) to existing DESCRIPTION file(s)")
    if (!is.character(except.priority) || !length(except.priority) || !all(except.priority %in% c("base","recommended")))
        stop("except.priority accept 'base', 'recommended' or both")
    which_all <- c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
    if (identical(which, "all"))
        which <- which_all
    else if (identical(which, "most"))
        which <- c("Depends", "Imports", "LinkingTo", "Suggests")
    else if (identical(which, "strong"))
        which <- c("Depends", "Imports", "LinkingTo")
    if (!is.character(which) || !length(which) || !all(which %in% which_all))
        stop("which argument accept only valid dependency relation: ", paste(which_all, collapse=", "))
    x <- unlist(lapply(file, function(f, which) {
        dcf <- tryCatch(read.dcf(f, fields = which),
                        error = identity)
        if (inherits(dcf, "error") || !length(dcf))
            warning(gettextf("error reading file '%s'", f),
                    domain = NA, call. = FALSE)
        else dcf[!is.na(dcf)]
    }, which = which), use.names = FALSE)
    x <- unlist(lapply(x, .extract_dependency_package_names)) ## .extract_dependency_package_names removes of 'R'
    except <- unlist(.get_standard_package_names()[except.priority], use.names = FALSE)
    setdiff(x, except) ## unique
}

repos.dcf <-
function(file = "DESCRIPTION") {
    if (!is.character(file) || !length(file) || !all(file.exists(file)))
        stop("file argument must be character of filepath(s) to existing DESCRIPTION file(s)")
    x <- unlist(lapply(file, function(f) {
        dcf <- tryCatch(read.dcf(f, fields = "Additional_repositories"),
                        error = identity)
        if (inherits(dcf, "error") || !length(dcf))
            warning(gettextf("error reading file '%s'", f),
                    domain = NA, call. = FALSE)
        else dcf[!is.na(dcf)]
    }), use.names = FALSE)
    x <- trimws(unlist(strsplit(trimws(x), ",", fixed = TRUE), use.names = FALSE))
    unique(x)
}

## Mirror subset of CRAN
## download dependencies recursively for provided packages
## put all downloaded packages into local repository
mirror.packages <-
function(pkgs,
         which = "strong",
         repos = getOption("repos"),
         type = c("source", "mac.binary", "win.binary"),
         repodir,
         except.repodir = repodir,
         except.priority = "base",
         quiet = TRUE,
         ...) {
    if (!length(pkgs)) ## edge case friendly
        return(structure(character(0), dim=c(0L,2L)))
    if (!is.character(pkgs))
        stop("pkgs argument must be character vector of packages to mirror from repository")
    if (missing(repodir) || !is.character(repodir) || length(repodir)!=1L)
        stop("repodir argument must be non-missing scalar character, local path to repo mirror")
    if (!dir.exists(repodir) && !dir.create(repodir, recursive = TRUE, showWarnings = FALSE))
        stop("Path provided in 'repodir' argument does not exists and could not be created")
    if (missing(type) && .Platform$OS.type == "windows")
        type <- "win.binary"
    type <- match.arg(type)
    destdir <- contrib.url(repodir, type = type)
    if (!dir.exists(destdir) && !dir.create(destdir, recursive = TRUE, showWarnings = FALSE))
        stop(sprintf("Repo directory provided in 'repodir' exists, but does not have '%s' dir tree and it could not be created", destdir))
    if (length(except.repodir) && (!is.character(except.repodir) || length(except.repodir)!=1L || !dir.exists(except.repodir)))
        stop("except.repodir argument must be non-missing scalar character, local path to existing directory")
    if (!is.character(except.priority) || !length(except.priority) || !all(except.priority %in% c("base","recommended")))
        stop("except.priority accepts 'base', 'recommended' or both")
    if (!is.logical(quiet) || length(quiet)!=1L || is.na(quiet))
        stop("quiet argument must be TRUE or FALSE")
    which_all <- c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
    if (identical(which, "all"))
        which <- which_all
    else if (identical(which, "most"))
        which <- c("Depends", "Imports", "LinkingTo", "Suggests")
    else if (identical(which, "strong"))
        which <- c("Depends", "Imports", "LinkingTo")
    if (!is.character(which) || !length(which) || !all(which %in% which_all))
        stop("which argument accept only valid dependency relations: ", paste(which_all, collapse=", "))
    ## possible interactive CRAN menu
    repos.url <- contrib.url(repos, type = type)
    db <- available.packages(repos.url, type = type)
    allpkgs <- c(pkgs, unlist(package_dependencies(unique(pkgs), db, which, recursive = TRUE), use.names = FALSE))
    except <- unlist(.get_standard_package_names()[except.priority], use.names = FALSE)
    if (length(except.repodir) && file.exists(file.path(contrib.url(except.repodir, type = type), "PACKAGES"))) {
        except.curl <- contrib.url(file.path("file:", normalizePath(except.repodir)), type = type)
        except <- c(except, rownames(available.packages(except.curl, type = type, fields = "Package")))
    }
    newpkgs <- setdiff(allpkgs, except)
    if (!all(availpkgs<-newpkgs %in% rownames(db)))
        stop(sprintf("Some packages could not be found in provided repos '%s': %s",
                     paste(repos, collapse = ", "), paste(newpkgs[!availpkgs], collapse = ", ")))

    pkgsext <- switch(type,
                      "source" = "tar.gz",
                      "mac.binary" = "tgz",
                      "win.binary" = "zip")
    pkgsver <- db[db[, "Package"] %in% newpkgs, c("Package", "Version"), drop=FALSE]
    dlfiles <- file.path(destdir, paste(paste(pkgsver[,"Package"], pkgsver[,"Version"], sep = "_"), pkgsext, sep = "."))
    unlink(dlfiles[file.exists(dlfiles)])
    ## repos argument is not used in download.packages, only as default for contriburl argument
    ## we provide contriburl to avoid interactive CRAN menu popup twice in mirror.packages
    dp <- download.packages(pkgs = newpkgs, destdir = destdir,
                            available = db, contriburl = repos.url,
                            type = type, quiet = quiet)
    write_PACKAGES(dir = destdir, type = type, ...)
    dp
}
