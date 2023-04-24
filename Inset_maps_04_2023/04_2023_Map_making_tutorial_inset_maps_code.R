## Packages that may be generally useful:
library(knitr)
library(ggplot2) 
library(dplyr)  
library(rgdal)  
library(raster) 
library(ggsn)
library(rworldmap)
library(sf)
#library(gdalUtils)
library(gdalUtilities)
library(ggspatial)
library(rgeos)
library(sp)
library(ggspatial)
#remotes::install_github("dieghernan/tidyterra")
library(tidyterra)
library(RColorBrewer)
library(shades)
library(elevatr)
#install.packages('terra', repos='https://rspatial.r-universe.dev')
library(terra)
#install.packages('raster')
library(raster)
library(tidyverse)


## We start with a completed sample map. If you've been following along with previous tutorials, this is the final map version that we created! We will be tailoring our sample data to make it more relevant to this tutorial, and then updating the map before creating an inset.
fullmapwithelevation <- ggplot() + geom_sf(data = aoi_boundary_YNP_NAD83, lwd=0,
    color = "grey17", fill=NA) + geom_raster(data = YNPrasterdf, aes(x, y, 
    fill = alt)) +geom_point(data = samplecoords3, size = 4, aes(x=x, y=y, 
    color=SPECIES)) + xlab("Longitude") + ylab("Latitude") + 
    scale_fill_hypso_tint_c(palette = "wiki-2.0_hypso", 
    breaks = c(2000, 2500, 3000, 3500)) + labs(fill = "m") + 
    geom_sf(fill = "transparent", color = "gray20", size = 1, 
    data = northernrange_NAD83) + theme_classic() + 
    theme(legend.position = "none")  
fullmapwithelevation
    
## Let's inspect how I've tailored the dataset used in the last tutorial. I'll create a column called "population" and assign each point to population "A" or "B." 
samples$population <- c("A", "B", "A", "A", "B", "A", "B", "B", "B", "B")
head(samples)
    
## Now, we create a new map, with points colored by population. I will also exclude the outline of the northern range in this version. This will be the map that we feed into code used to create an inset! Note that the map version you have at this step with will be fed directly into the code to make the inset, so make sure you like this version before proceeding :) 
fullmapwithelevation <- ggplot() + geom_sf(data = aoi_boundary_YNP_NAD83, lwd=0,
    color = "grey17", fill=NA) + geom_raster(data = YNPrasterdf, aes(x, y, 
    fill = alt)) +geom_point(data = samplecoords3, size = 4, aes(x=x, y=y, 
    color=population)) + xlab("Longitude") + ylab("Latitude") + 
    scale_fill_hypso_tint_c(palette = "wiki-2.0_hypso", 
    breaks = c(2000, 2500, 3000, 3500)) + labs(fill = "m") + theme_classic() +
    theme(legend.position = "none") 
fullmapwithelevation
    
## Say I wanted to zoom in on Population B, which has quite a bit of overlap between points on the map. I'll use the "geom_rect" function to define the area that I want to use for my bounding box. 
fullmapwithbox <- ggplot() + geom_sf(data = aoi_boundary_YNP_NAD83, lwd=0, 
    color = "grey17", fill=NA) + geom_raster(data = YNPrasterdf, 
    aes(x, y, fill = alt)) +geom_point(data = samplecoords3, size = 4, 
    aes(x=x, y=y, color=population)) +
    scale_color_manual(values = c("A" = "#F8766D", "B" = "#00BFC4")) + 
    xlab("Longitude") + ylab("Latitude") + 
    scale_fill_hypso_tint_c(palette = "wiki-2.0_hypso", 
    breaks = c(2000, 2500, 3000, 3500)) + labs(fill = "m") + 
    theme(legend.position = "none") + geom_rect(aes(xmin = -110.1, 
    xmax = -110.5, ymin = 44.98, ymax = 44.8), color = "black", fill = NA) + 
    theme_classic() + theme(legend.position = "none") 
fullmapwithbox
    
    ## Since my main motivation for including the larger map of Yellowstone in this figure is just to provide some context for the sampling area in my zoomed in plot, and the larger map will be reduced in size and placed in the corner of the figure, I am choosing to remove the axes and coordinate values from it. To do that, we will use the theme() argument to remove each element. I also place a border around the plot itself using theme(panel.border) which will help separate this part of the figure from the main map when we combine the two.
fullmapwithbox2 <- ggplot() + geom_sf(data = aoi_boundary_YNP_NAD83, lwd=0, 
    color = "grey17", fill=NA) + geom_raster(data = YNPrasterdf, 
    aes(x, y, fill = alt)) +geom_point(data = samplecoords3, size = 4, 
    aes(x=x, y=y, color=population)) + 
    scale_color_manual(values = c("A" = "#F8766D", "B" = "#00BFC4")) + 
    xlab("Longitude") + ylab("Latitude") + 
    scale_fill_hypso_tint_c(palette = "wiki-2.0_hypso", 
    breaks = c(2000, 2500, 3000, 3500)) + labs(fill = "m") + 
    theme(legend.position = "none") + geom_rect(aes(xmin = -110.1, 
    xmax = -110.5, ymin = 44.98, ymax = 44.8), color = "black", fill = NA)+ 
    theme(axis.line=element_blank(),axis.text.x=element_blank(),
    axis.text.y=element_blank(),axis.ticks=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),legend.position="none",
    panel.background=element_blank(),panel.border=element_blank(), 
    panel.grid.major=element_blank(), panel.grid.minor=element_blank(),
    plot.background=element_blank()) + 
    theme(panel.background = element_rect(fill = "white")) +
    theme(panel.border = element_rect(color = "black",fill = NA,linewidth = 1)) 
fullmapwithbox2

## Next, I will create a map of only the area included in that box, using xlim() and ylim() to confine the map area. Make sure that the same coordinates are used here as in the box in the above map. 
populationBmap <- ggplot() + geom_sf(data = aoi_boundary_YNP_NAD83, lwd=0, 
    color = "grey17", fill=NA) + geom_raster(data = YNPrasterdf, aes(x, y, 
    fill = alt)) +geom_point(data = samplecoords3, size = 4, aes(x=x, y=y, 
    color=population)) + 
    scale_color_manual(values = c("A" = "#F8766D", "B" = "#00BFC4")) + 
    xlab("Longitude") + ylab("Latitude") + scale_fill_hypso_tint_c(palette = 
    "wiki-2.0_hypso", breaks = c(2000, 2500, 3000, 3500)) + labs(fill = "m")+ 
    xlim(c(-110.5, -110.1)) + ylim(c(44.8, 44.98)) + 
    theme(panel.border = element_rect(color = "black",fill = NA, 
    linewidth = 1)) + theme_classic() + 
    theme(legend.position = "none") 
populationBmap

## We now have the basic components (full map of Yellowstone plus the specific area we want to zoom in on) of our future inset map. Next, we will combine the two plots and make adjustments to the placement of the full park map so that it fits into a corner and doesn't overlay any of our sample points. We will do this by using the print() function and defining the viewport (what are the x and y coordinates we want the smaller map to sit in?) and the size (width and height). We first call the map of our zoomed in sampling area, and then print the smaller map on top of it. Make sure to run these two lines of code together! 
populationBmap
print(fullmapwithbox2, vp = viewport(0.8, 0.75, width = 0.5, height = 0.5))

## We now have a figure that includes 1) a full map of Yellowstone National Park 2) a box around our sampling area that matches 3) the larger map featuring our zoomed-in sampling area (and sample points)!  
    
    