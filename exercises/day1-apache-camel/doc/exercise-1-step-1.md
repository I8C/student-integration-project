# Exercise 1 step 1

## Get to know a camel route

1. Clone the base project: git@github.com:I8C/student-integration-project.git  
2. The code lies under the exercises/day1-apache-camel directory in the main branch  
3. Open the project subdirectory in Intellij  
4. Ensure Docker or Podman is running
5. Run the application:  
	- in Git-bash, go to your application directory: cd /c/path/to/your/repository/**exercises/day1-apache-camel**  
	- run: quarkus dev  
      This will start your application in dev mode which comes with the handy dashboard that you can find from http://localhost:8080 in your browser.
      It comes with automatic reload of your code as well.
6. When the application runs, somewhere at the end of the logs in the console you should see a log entry with the text ">>>>>>>>> hello world! <<<<<<<<<<"  

## Expose a REST API

A Camel route is the configuration of Camel behaviour with Java.  
This means that once you are running your application and put a breakpoint in the route, when sending a message in it, the breakpoint will never be hit.  
Keep this in mind when you configure/program a route.  
For your information, some classes (PurchaseAcceptedResponse, PurchaseRequest, ...) will appear in red (=error) because they are not found. This is normal, they will be generated for the OpenApi specification file after the 1st compilation of the code.  
You can ignore those errors until you have compiled your code for the 1st time.

1. In the TicketPurchaseAPIRoute class, define a REST route with the REST DSL Contract first approach: https://camel.apache.org/manual/rest-dsl-openapi.html  
   Pass the _openApiFilename_ variable to the rest configuration. The _openApiFilename_ is set to the value of _ticket-purchase.openapi.filename_ configuration from the _resources/application.properties_ configuration file. That is the path the the file containing the OpenApi specification.  
   To do this, paste this a the begin of the existing `public void configure()` method:
   
   ```java
   rest()
      .openApi(openApiFilename).getOpenApi().setMissingOperation("ignore");
   ```
   
   Thanks to the contract first approach, Camel will expect to have a route with a specific URI prefixed with "direct:" followed by operationId from the OpenAPI spec to handle API requests for that "operation".
2. Create the route that will receive the API request based on the operationId of the ticket purchase request in the OpenApi specification.  
   Replace `from("scheduler:...")` with the expected route name based on the operationId 'purchaseTicket' of the purchase request in the specification:  
   ```java
   from("direct:purchaseTicket")
   ```

3. Run the application ('quarkus dev' command from the directory of the application) and test it with postman.  
   In postman, create an HTTP POST request to http://localhost:8080/v1/tickets/:ticketId/purchase.  
   In the "Params" tab, set a value for the "Path Variables" "ticketId". 123 for example.
   Set the request header 'Content-Type' to 'application/json'.  
   Define a random Json body and send the request.  
   Example:
   ```json
   {
     "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
     "quantity": 1,
     "ticketType": "normal"
   }
   ```
   The response will be '>>>>>>>>> hello world! <<<<<<<<<<' because that part is still unchanged.  
   
4. Expose the OpenSpecs.  
Configure Camel rest to define an api context: https://github.com/apache/camel/blob/camel-4.2.x/components/camel-openapi-java/src/main/docs/openapi-java.adoc#using-openapi-in-rest-dsl.  
   `.apiContextPath("/api-doc")` exposes the specs at the "/api-doc" path.  
   Paste this a the begin of the existing `public void configure()` method:

   ```java
     restConfiguration()
       .apiContextPath("/api-doc");
   ```
   Quarkus should reload the change automatically. Once restarted, navigate to http://localhost:8080/api-doc to see the result.
   
    [to step 2](exercise-1-step-2) 