//package be.openint.pxltraining;
//
//import be.openint.pxltraining.configuration.KafkaTestContainerResource;
//import io.quarkus.test.common.WithTestResource;
//import io.quarkus.test.junit.QuarkusTest;
//import jakarta.inject.Inject;
//import net.javacrumbs.jsonunit.assertj.JsonAssertions;
//import org.apache.camel.EndpointInject;
//import org.apache.camel.Exchange;
//import org.apache.camel.ProducerTemplate;
//import org.apache.camel.builder.RouteBuilder;
//import org.apache.camel.component.mock.MockEndpoint;
//import org.apache.camel.quarkus.test.CamelQuarkusTestSupport;
//import org.eclipse.microprofile.config.inject.ConfigProperty;
//import org.junit.jupiter.api.Test;
//
//import java.io.IOException;
//import java.net.URISyntaxException;
//import java.net.URL;
//import java.nio.file.Files;
//import java.nio.file.Paths;
//
///**
// * an integration test using a kafka container.
// * The "sendBody(...)" triggers the route and is expecting that the route consumer (from) has the uri: "direct:purchaseTicket".
// * The test checks that exactly one event was sent to the topic and that the body of the event is the same as the one sent.
// */
//@QuarkusTest
//@WithTestResource(KafkaTestContainerResource.class)
//public class TicketPurchaseAPIRouteITest extends CamelQuarkusTestSupport {
//
//  //a utility to send messages on a route
//  @Inject
//  ProducerTemplate producerTemplate;
//
//  //a utility to mock an Camel consumer component
//  @EndpointInject("mock:consumeKafkaTopic")
//  private MockEndpoint messageConsumer;
//
//  @ConfigProperty(name = "kafka.festival.purchases.topic")
//  private String topicName;
//
//  @Test
//  public void testKafkaProduced() throws Exception {
//
//    //Dynamically add a route to consume the kafka topic where the event are sent
//    context.addRoutes(new RouteBuilder() {
//      @Override
//      public void configure() throws Exception {
//        //seekTo=BEGINNING ensure that all the events on the topic are read.
//        //This ensures that if this route is started after that the event was sent it will still be consumed
//        from("kafka:" + topicName + "?seekTo=BEGINNING")
//                .log("unmarshalling ===")
//                .to(messageConsumer);
//      }
//    });
//
//    //defining what is expected to happen on the mock
//    messageConsumer.expectedMessageCount(1);
//    //send the event to the route to test
//    producerTemplate.sendBody("direct:purchaseTicket", readRequestBodyAsAFile());
//
//    //verifies that the expectation were fulfilled
//    messageConsumer.assertIsSatisfied();
//
//    //verifying the request body is the one expected
//    Exchange exchange = messageConsumer.getExchanges().getFirst();
//    String body = exchange.getIn().getBody(String.class);
//    JsonAssertions.assertThatJson(body).isEqualTo(readRequestBodyAsAFile());
//  }
//
//  private static String readRequestBodyAsAFile() throws IOException, URISyntaxException {
//    URL jsonPayloadFile = TicketPurchaseAPIRoute.class.getResource("/samples/ticketPurchaseBody.json");
//    return Files.readString(Paths.get(jsonPayloadFile.toURI()));
//  }
//}