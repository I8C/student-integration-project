# Prerequisites

To complete the exercises you need the following tools and set-up:

- **IDE:** Use IntelliJ Community Edition or another Java IDE of your choice.
- **Git client:**
  * Most IDEs include a built-in Git client.
  * Alternatively, install Git for Windows: https://git-scm.com/downloads and accept the default options. This allows you to follow the command-line instructions in the exercise.

- **Java JDK 21:** Install Java 21 using one of the following methods.

  **Manual installation**
  1. Download the latest JDK 21 from  
     https://adoptium.net/temurin/releases?version=21&os=windows&arch=any
  2. Extract the archive.
  3. Add the `bin` directory to your `PATH`.
  4. Set the root directory of the JDK as the value of the `JAVA_HOME` environment variable.
  5. Alternatively install the MSI version.

  **CLI installation (SDKMAN)**
  1. In Git-Bash run:
     curl -s "https://get.sdkman.io" | bash
  2. Install Java:   
     ```bash
	 sdk install java 21-tem
     sdk default java 21-tem
	 ```
  3. Initialize SDKMAN:
     `source "$HOME/.sdkman/bin/sdkman-init.sh"`
  4. Configure your IDE JDK to:
     `C:\Users\<your-user>\.sdkman\candidates\java\current`

- **Maven ≥ 3.9**

  **Manual**  
  Follow the instructions on:  
  https://maven.apache.org/install.html

  **CLI**  
  sdk install maven

- **Clone the repository and warm up the Maven cache**

  Replace `/path/to/your/code/root/directory` with the directory of your choice.
  ```bash
  mkdir -p /path/to/your/code/root/directory
  cd /path/to/your/code/root/directory
  git clone https://github.com/apache/camel-quarkus-examples
  
  cd camel-quarkus-examples/exercises/day1-apache-camel
  mvn package -DskipTests
  ```