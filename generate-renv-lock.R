#!/usr/bin/env Rscript

# Script to generate renv.lock from installed R packages
# This creates an renv.lock file compatible with the renv package manager

# Get all installed packages
packages <- installed.packages()

# Filter out base R packages (those in base, recommended, etc.)
base_packages <- c(
  "base", "compiler", "datasets", "graphics", "grDevices",
  "grid", "methods", "parallel", "splines", "stats", "stats4",
  "tcltk", "tools", "utils"
)

# Get user-installed packages (excluding base packages)
user_packages <- packages[!packages[, "Package"] %in% base_packages & 
                          !packages[, "Priority"] %in% c("base", "recommended"), ]

# Create the renv.lock structure
lock_data <- list(
  R = list(
    Version = paste(R.version$major, R.version$minor, sep = "."),
    Repositories = list(
      list(
        Name = "CRAN",
        URL = "https://cloud.r-project.org"
      )
    )
  ),
  Packages = list()
)

# Add each package to the lock file
for (i in seq_len(nrow(user_packages))) {
  pkg_name <- user_packages[i, "Package"]
  pkg_version <- user_packages[i, "Version"]
  
  # Try to get package source information
  pkg_desc <- tryCatch(
    packageDescription(pkg_name),
    error = function(e) NULL
  )
  
  package_entry <- list(
    Package = pkg_name,
    Version = pkg_version,
    Source = "Repository",
    Repository = "CRAN"
  )
  
  # Add optional fields if available
  if (!is.null(pkg_desc)) {
    if (!is.na(pkg_desc$RemoteType) && !is.null(pkg_desc$RemoteType)) {
      package_entry$Source <- pkg_desc$RemoteType
    }
    if (!is.na(pkg_desc$Repository) && !is.null(pkg_desc$Repository)) {
      package_entry$Repository <- pkg_desc$Repository
    }
  }
  
  lock_data$Packages[[pkg_name]] <- package_entry
}

# Write to renv.lock file
output_file <- "renv.lock"
cat("Generating renv.lock with", length(lock_data$Packages), "packages...\n")

# Write JSON with pretty formatting
json_output <- jsonlite::toJSON(
  lock_data,
  auto_unbox = TRUE,
  pretty = TRUE,
  null = "null"
)

writeLines(json_output, output_file)

cat("Successfully created", output_file, "\n")
cat("\nPackages included:\n")
for (pkg in names(lock_data$Packages)) {
  cat("  -", pkg, lock_data$Packages[[pkg]]$Version, "\n")
}
