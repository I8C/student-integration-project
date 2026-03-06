package be.openint.pxltraining;

import be.openint.pxltraining.generated.PurchaseStatus;
import io.quarkus.arc.lookup.LookupIfProperty;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericDatumReader;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.io.DecoderFactory;
import org.apache.avro.io.JsonDecoder;
import org.apache.camel.builder.RouteBuilder;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.InputStream;
import java.util.Arrays;
import java.util.UUID;

@LookupIfProperty(name = "kafka.enabled", stringValue = "true")
@ApplicationScoped
public class TicketPurchaseStatusEventsRoute extends RouteBuilder {

    @ConfigProperty(name = "kafka.festival.purchases.status.topic")
    private String topicName;

    @ConfigProperty(name = "kafka.festival.purchases.status.client.id")
    private String clientId;

    @ConfigProperty(name = "kafka.festival.purchases.status.sasl-jaas-config")
    private String saslJaasConfig;

    @Inject
    TicketStatusCache ticketStatusCache;

    static final Logger LOG = Logger.getLogger(TicketPurchaseStatusEventsRoute.class);

    @Override
    public void configure() throws Exception {

        InputStream avroSchemaIS = getClass().getResourceAsStream("/schema/schema-paymentStatusUpdate.avsc");
        Schema schema = new Schema.Parser().parse(avroSchemaIS);

            from("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig + "&seekTo=BEGINNING")
                .routeId(getClass().getSimpleName())
                .process(exchange -> {
                    JsonDecoder decoder = DecoderFactory.get().jsonDecoder(schema, exchange.getIn().getBody(String.class));
                    GenericDatumReader<GenericRecord> reader = new GenericDatumReader<>(schema);
                    GenericRecord ticketPurchaseRecord = reader.read(null, decoder);

                    LOG.infof("receiving payment status: %s", ticketPurchaseRecord.toString());

                    String purchaseId = ticketPurchaseRecord.get("purchaseId").toString();
                    PurchaseStatus purchaseStatus = new PurchaseStatus();
                    String status = ticketPurchaseRecord.get("status").toString();
                    if(Arrays.stream(PurchaseStatus.StatusEnum.values()).anyMatch(statusEnum -> statusEnum.toString().equals(status))) {
                        purchaseStatus.setStatus(PurchaseStatus.StatusEnum.valueOf(status));
                    } else {
                        purchaseStatus.setStatus(PurchaseStatus.StatusEnum.PENDING);
                        purchaseStatus.setPaymentStatus(String.format("unknown status '%s'", status));
                        LOG.infof("unknown status '%s'", status);
                    }
                    purchaseStatus.setPurchaseId(UUID.fromString(purchaseId));
                    ticketStatusCache.put(purchaseStatus.getPurchaseId(), purchaseStatus);
                });
    }
}