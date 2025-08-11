# Develop a R application that does following 
# Load a CSV file and provide the user ability to specify column types
# Provide various visualization capability correlation maps, scatter plots, histogram etc
# Provide a basic machine learning features like linear regression
# Provide basic reporting features

# The UI will have four tabs load ,visualize, analyze and the report.

# Potential advanced features, including async processing.

# Main function?

print("Please input name of csv file: ")

csv_file_name <- readline()
table <- read.csv(csv_file)
