#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly= TRUE)

df <- read.csv(args[1],sep = " ")

jpg_filename <- paste(args[1],".jpg",sep = "")

jpeg(file=jpg_filename)
plot(df[,1],df[,2],type = "l", xaxt = 'n', yaxt = 'n', ann = FALSE)
