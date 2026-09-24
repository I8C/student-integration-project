package be.openint.pxltraining;

import be.openint.pxltraining.generated.PurchaseAcceptedResponse;
import be.openint.pxltraining.generated.PurchaseStatus;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;
import org.jboss.logging.Logger;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.UUID;

/**
 * a route that receives a ticket purchase order and sends it to Kafka
 */
@ApplicationScoped
public class TicketPurchaseAPIRoute extends RouteBuilder {

//    @ConfigProperty(name = "kafka.festival.purchases.topic")
//    private String topicName;
//
//    @ConfigProperty(name = "kafka.festival.purchases.client.id")
//    private String clientId;
//
//    @ConfigProperty(name = "kafka.festival.purchases.sasl-jaas-config")
//    private String saslJaasConfig;

    @Inject
    ObjectMapper mapper;

    @Inject
    TicketStatusCache ticketStatusCache;

    static final Logger LOG = Logger.getLogger(TicketPurchaseAPIRoute.class);

    @Override
    public void configure() throws IOException, URISyntaxException {

        onException(IllegalArgumentException.class)
            .handled(true)
            .transform().simple("invalid input: ${body}")
            .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
            .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(400));

//        InputStream avroSchemaIS = getClass().getResourceAsStream("/schema/schema-ticketPurchase.avsc");
//        Schema schema = new Schema.Parser().parse(avroSchemaIS);

        from("direct:purchaseTicket")
            .inputType(be.openint.pxltraining.generated.PurchaseRequest.class)
            .routeId(getClass().getSimpleName())
            .log("body of ticket purchase\n${body}")
            .process(exchange -> {
                UUID purchaseId = UUID.randomUUID();
                exchange.setProperty("purchaseId", purchaseId);
//                PurchaseRequest purchaseRequest = exchange.getIn().getBody(PurchaseRequest.class);
//
//                ObjectNode ticketPurchaseJson = mapper.createObjectNode();
//                ticketPurchaseJson.put("purchaseId", purchaseId.toString());
//                ticketPurchaseJson.put("userId", purchaseRequest.getUserId().toString());
//                ticketPurchaseJson.put("ticketType", purchaseRequest.getTicketType().getValue());
//                ticketPurchaseJson.put("quantity", purchaseRequest.getQuantity());
//                ticketPurchaseJson.put("timestamp", Instant.now().getLong(ChronoField.INSTANT_SECONDS));
//                // Deserialize the JSON string into an Avro GenericRecord
//                Decoder decoder = DecoderFactory.get().jsonDecoder(schema, mapper.writeValueAsString(ticketPurchaseJson));
//                DatumReader<GenericRecord> reader = new GenericDatumReader<>(schema);
//                GenericRecord result = reader.read(null, decoder);
//
//                LOG.infof("receiving ticket purchase request for userId %s", purchaseRequest.getUserId().toString());
//
//                // Serialize the Avro GenericRecord to bytes
//                ByteArrayOutputStream baos = new ByteArrayOutputStream();
//                Encoder encoder = EncoderFactory.get().jsonEncoder(schema, baos);
//                DatumWriter<GenericRecord> writer = new GenericDatumWriter<>(schema);
//                writer.write(result, encoder);
//                encoder.flush();
//                baos.close();
//
//                exchange.getIn().setBody(baos.toByteArray());
            })
            // https://camel.apache.org/components/4.4.x/log-component.html
//            .to("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig)
            //.to("log:waiting-for-kafka")
            .process(exchange -> {
                String requestUrl = exchange.getIn().getHeader(Exchange.HTTP_URL, String.class);
                URI uri = URI.create(requestUrl);
                String basePath = uri.getScheme() + "://" + uri.getAuthority() + "/v1";
                UUID purchaseId = exchange.getProperty("purchaseId", UUID.class);
                String statusUrl = basePath + "/purchases/" + purchaseId;
                ticketStatusCache.put(purchaseId, new PurchaseStatus()
                        .purchaseId(purchaseId)
                        .status(PurchaseStatus.StatusEnum.PENDING)
                        .paymentStatus(PurchaseStatus.StatusEnum.PENDING.toString()));
                PurchaseAcceptedResponse acceptedResponse = new PurchaseAcceptedResponse();
                acceptedResponse.setPurchaseId(purchaseId);
                acceptedResponse.setStatusUrl(statusUrl);
                exchange.getIn().setBody(acceptedResponse);
            });
    }
}