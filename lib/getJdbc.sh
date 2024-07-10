# Remove existing Postgres JAR files
rm postgres*.jar

# Get the latest version number from Maven repository
LATEST_VERSION=$(curl -s https://repo1.maven.org/maven2/org/postgresql/postgresql/maven-metadata.xml | grep -oPm1 "(?<=<latest>)[^<]+")

# Construct the download URL
DOWNLOAD_URL="https://repo1.maven.org/maven2/org/postgresql/postgresql/${LATEST_VERSION}/postgresql-${LATEST_VERSION}.jar"

# Download the latest version
wget ${DOWNLOAD_URL}
