# Do following only once for your system, then comment
# install.packages("renv")

# Do following only once for your project, then comment
# renv::init(bare = TRUE)

# Package installation (Optional here, can be installed using any methods)
required_packages <- c("shiny", "shinydashboard")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}
# Do following before each deployment
# renv::snapshot()

# Do following when install this project
#renv::restore()

