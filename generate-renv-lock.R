#!/usr/bin/env Rscript

# Script to generate renv.lock from installed R packages using the renv package

# Initialize renv in the current directory if not already initialized
if (!file.exists("renv.lock")) {
  message("Initializing renv and creating renv.lock...")
  renv::init(bare = TRUE, restart = FALSE)
} else {
  message("Updating renv.lock...")
}

# Create a snapshot of the current package library
renv::snapshot(prompt = FALSE, force = TRUE)

message("Successfully updated renv.lock")
