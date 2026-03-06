# Exercise 1 step 2

## Send an event to a local Kafka container

1. In the TicketPurchaseAPIRoute class, change the producer of your route to one sending to kafka: https://camel.apache.org/components/4.4.x/kafka-component.html.  
   Overwrite the line `.to("log:be.openint.pxltraining");` with:  
   ```java
   ...
   .to("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig);
   ```
   For your information for later steps, you configure the 'topicName' value in you configuration (resources/application.properties) by setting the 'kafka.festival.purchases.topic' property value.
   In the same configuration you'll find the quarkus configuration ready for the use of a kafka client: _camel.component.kafka.brokers_.
   Currently, it's commented to benefit from the Quarkus dev services that starts a Kafka container if it does not find a configured URL.
   The value is the URL to connect to kafka.
   The other parameter of the kafka producer 'clientId' and 'saslJaasConfig' are already there for the next steps and will be explained then.  
   In the meantime change the value of the property _'kafka.festival.purchases.client.id'_ in the application.properties.
   Change the value _[YOUR_FIRST_NAME_HERE]_ with your firstname.

2. The current state of the route overwrites the message body to ">>>>>>>>> hello world! <<<<<<<<<<".  
   We want to keep the body we have received from the REST endpoint. Fix that by changing the line
   '.setBody(constant(">>>>>>>>> hello world! <<<<<<<<<<"))' of your route with a log to verify that you are passing inside it:  
   ```java
   .log("body of ticket purchase\n${body}")
   ```
## Send an event to Kafka started for you automatically by Quarkus

Now lets send an event on local Kafka container.

1. start the application with 'quarkus dev' if it did not reload     
2. navigate to http://localhost:8080/q/dev-ui/quarkus-kafka-client/topics
3. create a topic with the same name as the value of your configuration 'kafka.festival.purchases.topic'. It's "TICKET.PURCHASE.REQUESTED_PRODUCED" if you did not change anything. Click the "+" icon on the bottom right, enter the topic name and confirm (click "create").
4. send a request on you API using Postman: 
   - POST to "localhost:8080/v1/tickets/:ticketId/purchase"
   - set the ticket id param (Params tab) to a number
   - set the body to whatever JSON value you want, it's not verified yet. Example: {"foo":"bar"}
   - send the request
5. you should see the log of your route in the Quarkus output log
6. you should see the content of your request body as a new entry in the Kafka topic on the dashboard at http://localhost:8080/q/dev-ui/quarkus-kafka-client/topics  
   
    [to step 3](exercise-1-step-3) 