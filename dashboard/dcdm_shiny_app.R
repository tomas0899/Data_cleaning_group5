library(tidyverse)
library(shiny)

library(ggplot2)
library(matrixStats)

library(stringr)
library(dplyr)

library(tidyr)

library(factoextra)

#install.packages("DBI")

#source("OneDrive - King's College London/Desktop/Ms - Applied Bioinformatics/7BBG1003 Data Cleaning and Data Management/project2/readmes/dcdm_app/dcdm_shiny_app.R")
#setwd("C:/Users/jagmeet/dcdm_app")

# Load merged data from CSV
merged_df <- read.csv("/Users/tpocho/Desktop/Applied\ Bioinfo/Data_clean/Github/Data_cleaning_group5/scripts/R/merged_df.csv", header = TRUE, stringsAsFactors = FALSE)

## This section explains Part 1 of the app:
## Module 1 = plot all parameter_name values tested for each gene_symbol
## user selects a gene → app finds parameter_names → app finds significant p-values

# Extract p-values column for convenience
pvalue <- merged_df$pvalue 

# Standardize gene names: capitalize first letter of each gene
merged_df$gene_symbol <- str_to_sentence(merged_df$gene_symbol)

# Convert parameter names to lowercase for consistency
merged_df$parameter_name <- tolower(merged_df$parameter_name)

# Create lists of unique gene symbols and parameters for UI dropdown menus
gene_symbol_list <- unique(merged_df$gene_symbol)
parameter_name_list <- unique(merged_df$parameter_name)

# Create a list of possible cluster numbers for PCA tab
number_of_clusters <- 1:5


# --- UI SECTION ---
# fluidPage() defines the overall layout structure of the app
ui <- fluidPage(
  
  # Page title at the top of the app
  titlePanel("mouse data visualisations"),
  
  # Sidebar and main panel layout
  sidebarLayout(
    
    # All user inputs go into sidebarPanel()
    sidebarPanel(
      # Dropdown menu for selecting 1 of 4 query genes
      selectInput("query_gene",
                  "Select one of 4 query genes:",
                  choices  = c("Ica1", "Dclk1", "Lpcat1", "Irag2"),
                  multiple = FALSE),
      # Slider for significance threshold (Module 1)
      sliderInput("pvalue_1", 
                  "Significance threshold for gene → phenotype:",
                  min= 0,
                  max = 1,
                  value = 0.05),
      
      
      # Dropdown menu for selecting phenotypic parameter
      selectInput("parameter_name",
                  "select parameter_name:",
                  choices  = parameter_name_list,
                  multiple = FALSE),
      
      # Slider for significance threshold (Module 2)
      sliderInput("pvalue_2", 
                  "Significance threshold for phenotype → gene:",
                  min=0,
                  max = 1,
                  value = 0.05),
      
      
      
      # Selector for number of clusters in PCA tab
      selectInput("number_of_clusters",
                  "number_of_clusters :",
                  choices  = number_of_clusters,
                  multiple = FALSE),
      
      # Second selector: choose any gene from the full gene list (used by last plot)
      selectInput("gene_symbol",
                  "Select gene (from all genes):",
                  choices = gene_symbol_list),
      # Slider for significance threshold (Module 1)
      sliderInput("pvalue_3", 
                  "Significance threshold for gene → phenotype:",
                  min= 0,
                  max = 1,
                  value = 0.05),
      
    ),
    
    # Main output panel (plots)
    mainPanel(
      tabsetPanel(
        
        # Tab 1 = significant phenotypes for 1 of 4 query gene
        tabPanel("module 1 = significant phenotypes for 1 of 4 query gene", 
                 plotOutput("sig_ko")),
        
        # Tab 2 = significant genes for a phenotype
        tabPanel("module2 = significant gene knockout for selected paramater name", 
                 plotOutput("sig_gene_ko")),
        
        # Tab 3 = PCA plot
        tabPanel("PCA", 
                 plotOutput("PCA")),
        
        # Tab 4 = significant phenotypes for genes
        tabPanel("module 4 = significant phenotypes for selected gene", 
                 plotOutput("all_sig_ko")),
      )
    )
  )
)


# Shortcut reference to full dataset, used inside server
sig_rows <- merged_df


# --- SERVER SECTION --- controls computational and plotting scripts
server <- function(input, output){
  
  # --- Module 1 reactive filter ---
  # Filters rows based on selected gene + significance threshold + ensures that it only works if there is an input
  filter_gene <- reactive({
    req(input$query_gene)
    sig_rows %>%
      filter(
        str_to_sentence(gene_symbol) == str_to_sentence(input$query_gene),  # match gene symbol
        pvalue < input$pvalue_1 # apply significance threshold
      )
  })
  
  
  # --- Plot for Module 1 ---
  output$sig_ko <- renderPlot({
    
    # Call reactive filtered dataset
    filter_gene_plot <- filter_gene()
    
    # inCASE: no significant phenotype parameters found
    if (nrow(filter_gene_plot) == 0) {
      return(
        plot(NULL, xlim=c(0, 1), ylim=c(0, 1), type='n', axes=FALSE, ann=FALSE) + 
          text(0.5, 0.5, "No significant phenotypes found for this gene.", cex=1.5)
      )
    } else{
      # Plot barplot of significant parameter_names for selected gene
      ggplot(filter_gene_plot,
             aes(x = reorder(parameter_name, -pvalue),  # order by significance
                 y = pvalue)) +  
        geom_col(color = "red")+              # draw bars
        coord_flip() +                                  # horizontal bars
        labs(x = "parameter_name", 
             y = "p val", 
             title = paste("Significant phenotypes for", input$gene_symbol)) + 
        theme_minimal()
    }
  })
  
  
  # --- Module 2: significant genes for selected phenotype ---
  
  # Put the phenotype filter outside the renderPlot (optional but cleaner)
  filter_pheno <- reactive({
    req(input$parameter_name)
    sig_rows %>%
      filter(
        tolower(parameter_name) == tolower(input$parameter_name),
        pvalue < input$pvalue_2
      )
  })
  
  # --- Plot for Module 2 ---
  
  output$sig_gene_ko <- renderPlot({
    
    filter_pheno_plot <- filter_pheno()
    
    # CASE: no genes significant for selected parameter
    if (nrow(filter_pheno_plot) == 0) {
      return(
        plot(NULL, xlim=c(0, 1), ylim=c(0, 1), type='n', axes=FALSE, ann=FALSE) + 
          text(0.5, 0.5, "No significant genes found for this parameter.", cex=1.5)
      )
    } else {
      # Barplot for significant genes
      ggplot(filter_pheno_plot,
             aes(x = reorder(gene_symbol, -pvalue),  # order by significance
                 y = pvalue)) +
        geom_col(color = "red")+          # draw bars
        coord_flip() +
        labs (x = "gene symbol",
              y = "p val", 
              title = paste("Significant genes for", input$parameter_name))+
        theme_minimal()
    }
  })
  
  # --- PCA MODULE ---
  output$PCA <- renderPlot({
    
    # Step 1: Filter rows where values are meaningful
    sig_rows <- merged_df %>%
      filter(
        gene_symbol != "", 
        parameter_name != "",
        pvalue > 0 & pvalue < 1
      )
    
    # Step 2: Summarise p-values → convert to -log10 scale per gene/parameter pair
    df <- sig_rows %>%
      group_by(gene_symbol, parameter_name) %>%
      summarise(logP = -log10(min(pvalue)), .groups = "drop")  # compute minimum p-value
    
    # Step 3: Pivot long → wide to create matrix: rows = genes, columns = parameters
    matrix_sig_rows <- df %>%
      pivot_wider(
        names_from = parameter_name,   # create a column for each parameter
        values_from = logP,            # fill with -log10(p)
        values_fill = 0                # fill missing values with 0 (P=1 → not significant)
      )
    
    # Step 4: Prepare matrix for PCA
    matrix_sig_rows <- as.data.frame(matrix_sig_rows)
    rownames(matrix_sig_rows) <- matrix_sig_rows$gene_symbol  # make gene names row labels
    matrix_sig_rows <- matrix_sig_rows[, -1]                  # drop gene_symbol column
    
    # Step 5: Run PCA on scaled matrix
    pca_res <- prcomp(matrix_sig_rows, scale = TRUE)
    
    # Step 6: Prepare PCA output + run K-means on PC1 & PC2
    pca_df <- data.frame(
      PC1 = pca_res$x[, 1],            # scores for principal component 1
      PC2 = pca_res$x[, 2],            # scores for principal component 2
      gene_symbol = rownames(matrix_sig_rows)
    )
    
    set.seed(888) # ensures reproducibility
    
    num_clusters <- as.integer(input$number_of_clusters)  # convert input to integer
    
    # Run K-means clustering
    my_kmeans <- kmeans(
      pca_df[, c("PC1", "PC2")],
      centers = num_clusters
    )
    
    pca_df$cluster <- as.factor(my_kmeans$cluster)         # add cluster membership
    
    # Step 7: Plot PCA with cluster colouring
    ggplot(pca_df, aes(x = PC1, y = PC2, color = cluster)) +
      geom_point(size = 3) +
      labs(title = "PCA of Gene Phenotype Signatures (-log10 P)",
           x = "PC1",
           y = "PC2") +
      theme_minimal()
  })
  
  
  
  
  output$all_sig_ko <- renderPlot({
    req(input$gene_symbol)
    
    # Filter by the full-gene selector & pvalue threshold (use same threshold as module1 or choose separate)
    filter_all_gene_plot <- sig_rows %>%
      filter(str_to_sentence(gene_symbol) == str_to_sentence(input$gene_symbol),
             pvalue < input$pvalue_3)  # using pvalue_3 threshold here; change if you want a different slider
    
    # CASE: no significant phenotype parameters found
    if (nrow(filter_all_gene_plot) == 0) {
      return(
        plot(NULL, xlim=c(0, 1), ylim=c(0, 1), type='n', axes=FALSE, ann=FALSE) + 
          text(0.5, 0.5, "No significant phenotypes found for this gene.", cex=1.5)
      )
    } else {
      # Plot barplot of significant parameter_names for selected gene
      ggplot(filter_all_gene_plot,
             aes(x = reorder(parameter_name, -pvalue),  # order by significance
                 y = pvalue)) +  
        
        geom_col(color = "red")+              # draw bars
        coord_flip() +                                  # horizontal bars
        labs(x = "parameter_name", 
             y = "p val", 
             title = paste("Significant phenotypes for", input$gene_symbol))+
        theme_minimal()
    }
  })
}

# Launch final Shiny app
shinyApp(ui = ui, server = server)