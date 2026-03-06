package be.openint.pxltraining;

import be.openint.pxltraining.generated.TicketInventory;
import io.quarkus.arc.lookup.LookupIfProperty;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericDatumReader;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.io.DecoderFactory;
import org.apache.avro.io.JsonDecoder;
import org.apache.camel.builder.RouteBuilder;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.InputStream;

@LookupIfProperty(name = "kafka.enabled", stringValue = "true")
@ApplicationScoped
public class TicketInventoryEventsRoute extends RouteBuilder {

    @ConfigProperty(name = "kafka.festival.purchases.inventory.topic")
    private String topicName;

    @ConfigProperty(name = "kafka.festival.purchases.inventory.client.id")
    private String clientId;

    @ConfigProperty(name = "kafka.festival.purchases.inventory.sasl-jaas-config")
    private String saslJaasConfig;

    @Inject
    TicketInventoryCache ticketInventoryCache;

    static final Logger LOG = Logger.getLogger(TicketInventoryEventsRoute.class);

    @Override
    public void configure() throws Exception {

        InputStream avroSchemaIS = getClass().getResourceAsStream("/schema/schema-inventoryUpdated.avsc");
        Schema schema = new Schema.Parser().parse(avroSchemaIS);

            from("kafka:" + topicName + "?clientId=" + clientId + "&saslJaasConfig=" + saslJaasConfig + "&seekTo=BEGINNING")
                .routeId(getClass().getSimpleName())
                .process(exchange -> {
                    JsonDecoder decoder = DecoderFactory.get().jsonDecoder(schema, exchange.getIn().getBody(String.class));
                    GenericDatumReader<GenericRecord> reader = new GenericDatumReader<>(schema);
                    GenericRecord ticketInventoryRecord = reader.read(null, decoder);

                    LOG.infof("receiving inventory update: %s", ticketInventoryRecord.toString());

                    String ticketType = ticketInventoryRecord.get("ticketType").toString();
                    Integer availableCount = Integer.valueOf(ticketInventoryRecord.get("availableCount").toString());
                    TicketInventory ticketInventory = new TicketInventory();
                    ticketInventory.setTicketType(ticketType);
                    ticketInventory.setAvailableCount(availableCount);
                    ticketInventoryCache.put(ticketInventory.getTicketType(), ticketInventory);
                });
    }
}