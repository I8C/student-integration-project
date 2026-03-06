# Exercise 1 step 3

## Define your Json Schema

The Json format of the request body is defined in the openapi/Festival_Ticket_Sales_API.json file.  
We will use it to validate the input and create the PurchaseRequest object from the body.  


1. In the TicketPurchaseAPIRoute class, in your route change
   ```java
   restConfiguration()
       .apiContextPath("/api-doc");
   ```
   into  
   
   ```java
   restConfiguration()
       .apiContextPath("/api-doc")
	   .bindingMode(RestBindingMode.json);
   ```
   **and**  
   ```java
   .routeId(getClass().getSimpleName())
   .log("body of ticket purchase\n${body}")
   // https://camel.apache.org/components/4.4.x/log-component.html
   .to("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig);
   ```
   into
   ```java
   .inputType(be.openint.pxltraining.generated.PurchaseRequest.class)
   .routeId(getClass().getSimpleName())
   .log("body of ticket purchase\n${body}")
   // https://camel.apache.org/components/4.4.x/log-component.html
   .to("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig);
   ``` 
   This code deserializes the JSON body in a PurchaseRequest bean thanks to the JSON binding mode and the generation 
   of the beans from the specification

   
2. test that you are sending something to Kafka using the quarkus dev service for kafka.  
   Start your application with 'quarkus dev' and send a ticket purchase request to your application with postman.
   Ticket as json example:  
   ```json
   {
     "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
     "quantity": 1,
     "ticketType": "normal"
   }
   ```
   Check on the quarkus dev dashboard that the request was sent on the kafka topic at http://localhost:8080/q/dev-ui/quarkus-kafka-client/topics

## Define your Avro Schema

Avro is a serialization format supported by kafka.  
To create your Avro Schema from the avro definition:
1. In the TicketPurchaseAPIRoute class, in your Route configuration method, read you definition and load it.  
   Put this before `from("direct:purchaseTicket")`
   ```java
   InputStream avroSchemaIS = getClass().getResourceAsStream("/schema/schema-ticketPurchase.avsc");
   Schema schema = new Schema.Parser().parse(avroSchemaIS);
   ```
   The IDE will complain that you have an unhandled exception.  
   Add it to the method signature using Intellij's suggestion
2. Use the schema in your route to serialize the request body and transform it in a binary Avro output ready for Kafka.  
   This piece of code takes the PurchaseRequest bean from the request and creates a new JSON object from it.  
   It also adds a purchaseId and a timestamp to fulfill the Avro schema contract.  
   That JSON object is then serialized with the avro schema to be sent to kafka.
   After `.log("body of ticket purchase\n${body}")` add a processor that will handle that logic:  
   ```java
      .process(exchange -> {
          //TODO
          UUID purchaseId = UUID.randomUUID();
          exchange.setProperty("purchaseId", purchaseId);
          PurchaseRequest purchaseRequest = exchange.getIn().getBody(PurchaseRequest.class);
          
          ObjectNode ticketPurchaseJson = mapper.createObjectNode();
          ticketPurchaseJson.put("purchaseId", purchaseId.toString());
          ticketPurchaseJson.put("userId", purchaseRequest.getUserId().toString());
          ticketPurchaseJson.put("ticketType", purchaseRequest.getTicketType().getValue());
          ticketPurchaseJson.put("quantity", purchaseRequest.getQuantity());
          ticketPurchaseJson.put("timestamp", Instant.now().getLong(ChronoField.INSTANT_SECONDS));
          // Deserialize the JSON string into an Avro GenericRecord
          Decoder decoder = DecoderFactory.get().jsonDecoder(schema, mapper.writeValueAsString(ticketPurchaseJson));
          DatumReader<GenericRecord> reader = new GenericDatumReader<>(schema);
          GenericRecord result = reader.read(null, decoder);

          LOG.infof("receiving ticket purchase request for userId %s", purchaseRequest.getUserId().toString());

          // Serialize the Avro GenericRecord to bytes
          ByteArrayOutputStream baos = new ByteArrayOutputStream();
          Encoder encoder = EncoderFactory.get().jsonEncoder(schema, baos);
          DatumWriter<GenericRecord> writer = new GenericDatumWriter<>(schema);
          writer.write(result, encoder);
          encoder.flush();
          baos.close();

          exchange.getIn().setBody(baos.toByteArray());
      })
   ```  
   The correct classes to be imported from the Avro library are already imported for you in the class.  
   This is the list for you record:
   ```java
   import org.apache.avro.Schema;
   import org.apache.avro.generic.GenericDatumReader;
   import org.apache.avro.generic.GenericDatumWriter;
   import org.apache.avro.generic.GenericRecord;
   import org.apache.avro.io.*;
   ```
3. Run the application with 'quarkus dev' to verify it's working with the avro schema serialization
4. Run the integration test 'TicketPurchaseAPIRouteITest' from the test sources to run the route.  
   That test is using the TestContainer technology to create a Kafka container and connect to it.  
   **Your Docker/Podman desktop has to run.**  
   It will use the configuration in application.properties in the test resources in the src/test/resources directory.
   The test has to succeed and somewhere in the logs you should find you log "body of ticket purchase" with the body on the nex lines.
5. Send a POST request with a body conform to the OpenAPI specification (see previous point for an example) otherwise you'll get an error because the input is invalid.
6. Check that you see the log "receiving ticket purchase request for userId 3fa85f64-5717-4562-b3fc-2c963f66afa6" with your id and that the ticket is in Kafka
   
    [to step 4](exercise-1-step-4) 
