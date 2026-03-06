# Exercise 1 step 5

## send your event to the real kafka

The real kafka is using enterprise requirements to connect.  
To be allowed to send events on it, you have to authenticate and to encrypt the connection. Follow these step to send event to kafka.

1. Ask for the broker url, and credentials to get access to it.
The pem file is located under src/main/resources/. Use the **absolute** path to it /path/to/your/repo/root/src/main/resources/ (use '/', the initial '/' is equivalent to 'C:\').  
Configure that in the configuration of your application.properties:  
     
    Replace [BROKER-URL], [YOUR-FIRSTNAME], [USER], [PASSWORD] and [PEM-FILENAME] with the corresponding values.  
       
    Those properties are already defined in your configuration and need to be adapted accordingly.  
	Uncomment them is necessary.  
	Don't pay attention to the other kafka configuration properties.
       
    ```properties
       #kafka producer client configuration
       camel.component.kafka.brokers=[BROKER-URL]
       camel.component.kafka.ssl-truststore-location=[PEM-FILENAME]
       camel.component.kafka.value-serializer=org.apache.kafka.common.serialization.ByteArraySerializer
       camel.component.kafka.security-protocol=SASL_SSL
       camel.component.kafka.sasl-mechanism=PLAIN
       camel.component.kafka.ssl-truststore-type=PEM
       
       kafka.festival.purchases.topic=ID_PRODUCE_PURCHASES
       kafka.festival.purchases.client.id=[YOUR_FIRST_NAME_HERE]
       kafka.festival.purchases.sasl-jaas-config=org.apache.kafka.common.security.plain.PlainLoginModule required username="[USER]" password="[PASSWORD]";
       ```
2. Run you application and send a valid request body to your API. Check (or ask to check if you don't have access) on the EEM dashboard if your event is present on the topic.  
   You'll find a valid dummy body in your test resources of the project at src/test/resources/samples/ticketPurchaseBody.json.  
   This time, the 'quarkus dev' command will not start a Kafka instance for you because you have configured an existing kafka to connect.
   
    [to step 6](exercise-1-step-6) 