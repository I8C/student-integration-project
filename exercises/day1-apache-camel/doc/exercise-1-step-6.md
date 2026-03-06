# Exercise 1 step 6

## deploy you application in the cloud

0. ask the DNS of your VM in the cloud, the private key to access it is available in the assets directory of this exercise
0. install java on your VM.
   In git bash: 
   a. Open a shell on your cloud VM: _ssh -i [PATH-TO-PEM-KEY] ec2-user@[YOUR-VM-DNS]_  
   The PATH-TO-PEM-KEY is *assets/PXL-key.pem* in the root directory of this exercises.
   b. Once logged on the remote VM, install java from the CLI: _sudo dnf install java-21-amazon-corretto-devel -y_
0. copy your kafka pem certificate received to your VM:    

   `scp path/to/kafka.pem i [PATH-TO-PEM-KEY] ec2-user@[YOUR-VM-DNS]:~/purchases.kafka.pem`  
   
   Set the value of the configuration camel.component.kafka.ssl-truststore-location to purchases.kafka.pem:  
   
   `camel.component.kafka.ssl-truststore-location=purchases.kafka.pem`
   
0. build your application as an executable jar in git bash.  
   From the root of your application run: `mvn clean package -DskipTests -Dquarkus.package.jar.type=uber-jar`  
0. copy the resulting jar to your VM:   
   `scp -i [PATH-TO-PEM-KEY] target/pxl-training-base-1.0-SNAPSHOT-runner.jar ec2-user@[YOUR-VM-DNS]:~`
0. run your application:  
   `nohup java -jar pxl-training-base-1.0-SNAPSHOT-runner.jar 2>&1 &`  
   You'll find a 'nohup.out' file in the same directory. It collects the output logs of your application.
   You can use it to follow what is going on by tailing it:  
   `tail -f nohup.out`  
   To stop tailing the logs it hit: ctrl + c
0. test your application. In postman, change localhost with http://[YOUR-VM-DNS]:8080. 
   Send a request with a valid body.
0. optionally, if you want to stop your java application you have to kill it.  
   Find the PID (process id). This is an example on a random VM:
   ```shell
   [ec2-user@ip-172-31-21-86 ~]$ ps -ef | grep java
   ec2-user  474523  474498 98 10:50 pts/0    00:00:03 java -jar /home/ec2-user/pxl-training-base-1.0-SNAPSHOT-runner.jar
   ec2-user  474538  474498  0 10:50 pts/0    00:00:00 grep --color=auto java
   ```
   In this example, the PID is 474523. Use it to kill your java process:  
   `kill -9 474523`

    [to step 7](exercise-1-step-7) 