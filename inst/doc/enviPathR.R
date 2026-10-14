## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

# Retrieve login credentials
username <- Sys.getenv("EP_USERNAME")
password <- Sys.getenv("EP_PASSWORD")

# Check if login credentials exist
is_active <- nzchar(username) && nzchar(password)

# If login credentials exist
if( is_active ){
    # Clear httptest cache
    unlink(
        system.file("vignettes/httptest"),
        recursive = TRUE,
        force = TRUE
    )
}

library(httptest2)

# Redact httptest output
set_redactor(function (x) {
    # Remove address prefix
    x <- httptest2::gsub_response(x, "envipath.org/api/legacy/", "")
    # Reduce unique identifiers
    x <- httptest2::gsub_response(x, "/(?:[0-9a-z]+-){2,}[0-9a-z]+/", "_")
    return(x)
})

start_vignette("httptest")

## ----install-release, eval = FALSE--------------------------------------------
# install.packages("enviPathR")

## ----install-devel, eval = FALSE----------------------------------------------
# remotes::install_github("enviPath/enviPathR")

## ----setup, message = FALSE---------------------------------------------------
library(enviPathR)
library(igraph)
library(knitr)

## ----types--------------------------------------------------------------------
types <- epTypes()

## ----types-listable-----------------------------------------------------------
# View listable object types
print(types$listable)

## ----types-linkable-----------------------------------------------------------
# View linkable object types
kable(types$linkable)

## ----types-plot---------------------------------------------------------------
# Convert edges data frame to igraph object
ep_graph <- graph_from_data_frame(types$linkable)

# Visualise database graph
plot(ep_graph)

## ----include = FALSE----------------------------------------------------------
change_state()

## ----login, eval = is_active--------------------------------------------------
# # Log into your enviPath account
# epLogin(username, password)

## ----list-pkg-----------------------------------------------------------------
# List available packages
pkg_df <- epList("package")

# Select reviewed packages
to_keep <- pkg_df$reviewStatus == "reviewed"
pkg_df <- pkg_df[to_keep, ]

# Remove lengthy description
pkg_df$description <- NULL

# View list of packages
kable(pkg_df)

## ----list-path----------------------------------------------------------------
# Select desired package
pkg_name <- "EAWAG-BBD"
pkg_id <- pkg_df$id[pkg_df$name == pkg_name]

# List pathways from desired package
path_df <- epList("pathway", pkg = pkg_id)

# View list of pathways
path_df |>
    head() |>
    kable()

## ----link-one-----------------------------------------------------------------
# Define reaction of interest
rxn_id <- "2b6bbcc5-77f4-4bed-92a9-731cdc978f6a"

# Map desired reaction to related compounds (educts and products)
rxn2cpd <- epLink("reaction", "compound", init = rxn_id)

# View reaction-to-compound mapping
kable(rxn2cpd)

## ----link-many----------------------------------------------------------------
# Select pathways of interest
path_ids <- path_df$id[1:2]

# Map desired pathways to related compounds (nodes)
path2cpd <- epLink("pathway", "compound", init = path_ids, pkg = pkg_id)

# View pathway-to-compound mapping
kable(path2cpd)

## ----get-one------------------------------------------------------------------
# Fetch reaction object
rxn <- epGet("reaction", rxn_id)

# View part of reaction data
rxn |>
    head() |>
    print()

## ----get-many-----------------------------------------------------------------
# Fetch multiple pathways
paths <- epGet("pathway", init = path_ids, pkg = pkg_id)

# View part of pathway data
paths |>
    lapply(head) |>
    print()

## ----get-property-------------------------------------------------------------
# Extract node property from pathway objects
nodes <- epGet("pathway", init = path_ids, pkg = pkg_id, property = "node")

# View nodes
print(nodes)

## ----model-setting------------------------------------------------------------
# List available model settings
set_df <- epList("setting")

# View list
kable(set_df)

## ----model-former-------------------------------------------------------------
# Define smiles of interest
smiles <- "ClC(Cl)=C(Cl)Cl"

# Perform pathway prediction with enviFormer
former_out <- epModel(smiles)

# View compounds in predicted pathway
kable(former_out$nodes)

# View reactions in predicted pathway
kable(former_out$edges)

## ----model-pepper-------------------------------------------------------------
# Set id for PEPPER model setting
set_name <- "Global Setting - ECC and App Domain - PEPPER"
set_id <- set_df$id[set_df$name == set_name]

# Perform pathway prediction with PEPPER
pepper_out <- epModel(smiles, set_id)

# View compounds in predicted pathway
kable(pepper_out$nodes)

# View reactions in predicted pathway
kable(pepper_out$edges)

## ----model-plot---------------------------------------------------------------
# Convert model output to igraph object
path_graph <- graph_from_data_frame(
    pepper_out$edges,
    vertices = pepper_out$nodes
)

# Visualise predicted pathway
plot(path_graph)

## ----model-ggraph, message = FALSE--------------------------------------------
library(ggraph)

ggraph(path_graph, layout = "sugiyama") +
    geom_edge_link(aes(colour = probability), arrow = arrow(type = "closed")) +
    geom_node_point(size = 3) +
    geom_node_text(aes(label = name), vjust = 2) +
    scale_edge_colour_continuous(limits = c(0, 1), low = "white", high = "red") +
    theme_graph(base_family = "")

## ----logout, eval = is_active-------------------------------------------------
# epLogout()

## ----include = FALSE----------------------------------------------------------
end_vignette()

## ----citation-----------------------------------------------------------------
citation("enviPathR")

## ----session-info-------------------------------------------------------------
sessionInfo()

