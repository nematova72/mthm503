# Load required libraries
library(DBI)
library(RPostgres)
library(dplyr)
library(ggplot2)
library(tidyr)
library(factoextra)
library(cluster)

# Connect to the database and load olive oil data
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  host = "aws-0-eu-west-2.pooler.supabase.com",
  port = 5432,
  user = "pgstudent.rvdwflidqvcvffdccwrh",
  password = "0%jkXK^tjMZwuG",
  sslmode = "require"
)

olive_data <- dbReadTable(con, "olive_oil")

dbDisconnect(con)

# Check data structure and get basic summary
str(olive_data)
summary(olive_data)

# Create boxplots to check the distribution of fatty acids before scaling
olive_long <- olive_data %>%
  pivot_longer(cols = where(is.numeric), names_to = "fatty_acid", values_to = "value")

ggplot(olive_long, aes(x = fatty_acid, y = value)) +
  geom_boxplot(fill = "lightgreen") +
  labs(title = "Fatty Acid Composition (Before Scaling)", x = "Fatty Acid", y = "Percentage") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Scale the data to standardize all variables
olive_scaled <- scale(select(olive_data, where(is.numeric)))

# Apply PCA for dimension reduction
pca_result <- prcomp(olive_scaled, center = TRUE, scale. = TRUE)

# Plot the variance explained by each principal component
fviz_eig(pca_result, addlabels = TRUE) +
  ggtitle("Variance Explained by PCA Components")

# Create a PCA biplot to visualize samples and variables
fviz_pca_biplot(pca_result, repel = TRUE, col.var = "blue", col.ind = "gray") +
  ggtitle("PCA Biplot of Olive Oil Data")

# Use elbow method to find the optimal number of clusters
fviz_nbclust(olive_scaled, kmeans, method = "wss") +
  labs(title = "Elbow Method")

# Use silhouette method for cluster validation
fviz_nbclust(olive_scaled, kmeans, method = "silhouette") +
  labs(title = "Silhouette Method")

# Set the number of clusters, for example k=3
set.seed(123)
kmeans_result <- kmeans(olive_scaled, centers = 3, nstart = 25)

# Print cluster sizes
table(kmeans_result$cluster)

# Visualize clusters on PCA plot
fviz_cluster(kmeans_result, data = olive_scaled, palette = "jco", ellipse.type = "convex") +
  ggtitle("K-means Clustering on PCA Components")

# Calculate silhouette scores to evaluate clustering quality
sil <- silhouette(kmeans_result$cluster, dist(olive_scaled))

# Plot silhouette scores
fviz_silhouette(sil) +
  ggtitle("Silhouette Plot")

# Print the average silhouette width
mean_sil <- mean(sil[, "sil_width"])
print(paste("Average Silhouette Width:", round(mean_sil, 3)))

# Add cluster labels to the original data
olive_clustered <- olive_data %>%
  mutate(cluster = as.factor(kmeans_result$cluster))

# Summarize the clusters to see the mean fatty acid values for each group
cluster_summary <- olive_clustered %>%
  group_by(cluster) %>%
  summarise(across(where(is.numeric), mean))

print(cluster_summary)
