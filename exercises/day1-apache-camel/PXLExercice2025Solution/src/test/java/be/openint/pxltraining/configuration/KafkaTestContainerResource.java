//package be.openint.pxltraining.configuration;
//
//import io.quarkus.test.common.QuarkusTestResourceLifecycleManager;
//import org.testcontainers.containers.KafkaContainer;
//import org.testcontainers.utility.DockerImageName;
//
//import java.util.Map;
//
//public class KafkaTestContainerResource implements QuarkusTestResourceLifecycleManager {
//    private KafkaContainer kafka;
//
//    @Override
//    public Map<String, String> start() {
//        kafka = new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:5.4.3"));
//        kafka.start();
//        return Map.of("camel.component.kafka.brokers", kafka.getBootstrapServers());
//    }
//
//    @Override
//    public void stop() {
//        kafka.stop();
//    }
//}
