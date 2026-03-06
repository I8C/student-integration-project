# Pre requisite:
- an IDE: Intellij CE or the one of your choice,  
- a git client:  
    * the one in your IDE is fine  
	* Git-bash: if you want install it from   https://git-scm.com/downloads and use the default installation options.  
	  After that you will be **able to follow the CLI instructions** to install you environment  
- Java: jdk 21  
	* Manual  
	  1. download the latest jdk 21 from https://adoptium.net/temurin/releases?version=21&os=windows&arch=any  
	  2. unarchive it on your system and put the bin directory on your path as well as the root directory of the jdk a the value of JAVA_HOME environment variable  
	     OR install the msi version  
	* CLI  
	  1. in Git-bash (search for git on your OS)  
	  2. run:`curl -s "https://get.sdkman.io" | bash`  
	  3. then:  
		a. `sdk install java 21-tem`  
		b. `sdk default java 21-tem`  
	  4. `source "$HOME/.sdkman/bin/sdkman-init.sh"`  
	  5. point your IDE jdk to: C:\Users\<your-user>\.sdkman\candidates\java\current  
- maven: install version >= 3.9  
    * Manual  
	    Follow instruction on https://maven.apache.org/install.html  
	* CLI  
	    run: `sdk install maven`  
- clone the repository and warm up you maven cache  
  * CLI  
    In the instructions, change "/path/to/your/code/root/directory" to the one of your choice.  
    1. `mkdir -p /path/to/your/code/root/directory`  
	2. `cd /path/to/your/code/root/directory`  
    3. `git clone https://github.com/apache/camel-quarkus-examples`  
    4. `cd camel-quarkus-examples/exercises/day1-apache-camel`  
	5. `mvn package -DskipTests`  
