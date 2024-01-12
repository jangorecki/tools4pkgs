# tools4pkgs

This is a code taken out from base R branch [tools4pkgs](https://svn.r-project.org/R/branches/tools4pkgs/). It provides functions to ease administration tasks around packages development and distribution.

Example use cases:
- mirroring subset of CRAN into local environment: `mirror.packages()`
- freezing up R packages version for reproducible environment: `mirror.packages()`
- extracting package dependencies from DESCRIPTION file: `packages.dcf()`
- mixing use of private R repositories together with CRAN repositories: `repos.dcf()`

## Installation

```r
install.packages("tools4pkgs", repos="https://jangorecki.github.io/tools4pkgs")
```

## Usage

- Extract dependencies for `Matrix` package from its `DESCRIPTION` file.
- Download dependencies (including recursive) into local CRAN directory structure.

```r
library(tools4pkgs)
dcf.path <- system.file("DESCRIPTION", package="Matrix")
deps <- packages.dcf(dcf.path, which="most")
repos <- c(getOption("repos"), repos.dcf(dcf.path))

repodir <- "Matrix_CRAN"
mirror.packages(deps, repos=repos, repodir=repodir)
#     [,1]      [,2]                                           
#[1,] "lattice" "Matrix_CRAN/src/contrib/lattice_0.22-5.tar.gz"
#[2,] "MASS"    "Matrix_CRAN/src/contrib/MASS_7.3-60.tar.gz"   
#[3,] "sfsmisc" "Matrix_CRAN/src/contrib/sfsmisc_1.1-16.tar.gz"

list.files(repodir, recursive=TRUE)
#[1] "src/contrib/lattice_0.22-5.tar.gz" "src/contrib/MASS_7.3-60.tar.gz"    "src/contrib/PACKAGES"              "src/contrib/PACKAGES.gz"
#[5] "src/contrib/PACKAGES.rds"          "src/contrib/sfsmisc_1.1-16.tar.gz"

available.packages(repos = file.path("file:", normalizePath(repodir)))
#        Package   Version  Priority      Depends                                         Imports                                   LinkingTo
#lattice "lattice" "0.22-5" "recommended" "R (>= 4.0.0)"                                  "grid, grDevices, graphics, stats, utils" NA
#MASS    "MASS"    "7.3-60" "recommended" "R (>= 4.0), grDevices, graphics, stats, utils" "methods"                                 NA
#sfsmisc "sfsmisc" "1.1-16" NA            "R (>= 3.3.0)"                                  "grDevices, utils, stats, tools"          NA
#...
```

Description of all available features can be found in [package manual](https://jangorecki.github.io/tools4pkgs)
```r
library(tools4pkgs)
?tools4pkgs
```

## Notes

The code was meant to be added to base R `tools` package. As a result, it uses two internal function from `tools` package:
```r
tools:::.extract_dependency_package_names
tools:::.get_standard_package_names
```
