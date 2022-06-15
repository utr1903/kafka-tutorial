package com.kafka.tutorial.producer.service.kafka;

import com.kafka.tutorial.producer.dtos.KafkaRequestDto;
import com.kafka.tutorial.producer.dtos.KafkaResponseDto;
import com.newrelic.api.agent.*;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.header.internals.RecordHeader;
import org.apache.kafka.common.header.internals.RecordHeaders;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Properties;

@Service
public class KafkaService {

    private final Logger logger = LoggerFactory.getLogger(KafkaService.class);

    private KafkaProducer<String, String> producer;

    public KafkaService()
    {
        initializeKafkaProducer();
    }

    @Trace(dispatcher = true)
    public KafkaResponseDto publish(
        KafkaRequestDto requestDto
    )
    {
        // Trace ID
        var traceId = NewRelic.getAgent().getTraceMetadata().getTraceId();
        logger.info("Trace ID: " + traceId);

        // Span ID
        var spanId = NewRelic.getAgent().getTraceMetadata().getSpanId();
        logger.info("Span ID: " + spanId);

        // Linking Metadata
        var linkingMetadata = NewRelic.getAgent().getLinkingMetadata();
        logger.info("Linking Metadata: " + linkingMetadata.toString());

        // Create Kafka producer record
        var record = new ProducerRecord<>(
            requestDto.getTopic(),
            "value",
            requestDto.getValue()
        );

        // Add New Relic headers
        var newrelicHeaders = ConcurrentHashMapHeaders.build(HeaderType.MESSAGE);
        NewRelic.getAgent().getTransaction().insertDistributedTraceHeaders(newrelicHeaders);

        // Retrieve the generated W3C Trace Context headers and
        // insert them into the ProducerRecord headers
        if (newrelicHeaders.containsHeader("traceparent")) {
            record.headers().add("traceparent",
                newrelicHeaders.getHeader("traceparent")
                    .getBytes(StandardCharsets.UTF_8));
        }

        if (newrelicHeaders.containsHeader("tracestate")) {
            record.headers().add("tracestate",
                newrelicHeaders.getHeader("tracestate")
                    .getBytes(StandardCharsets.UTF_8));
        }

        // Add Kafka headers
        var kafkaHeaders = new RecordHeaders();
        kafkaHeaders.add(new RecordHeader("traceId", traceId.getBytes()));

        for (var header : record.headers()) {
            String value = new String(header.value());
            logger.info("Header key  : " + header.key());
            logger.info("Header value: " + value);
        }

        var model = new PublishModel();

        var responseDto = new KafkaResponseDto();

        producer.send(record, (recordMetadata, e) -> {
            model.setTopic(requestDto.getTopic());
            model.setPartition(recordMetadata.partition());
            model.setTimestamp(recordMetadata.timestamp());

            if (e == null)
            {
                logger.info("Success");
                responseDto.setStatusCode(HttpStatus.OK.value());
                responseDto.setMessage("Success");
            }
            else
            {
                logger.info(e.getMessage());
                responseDto.setStatusCode(HttpStatus.INTERNAL_SERVER_ERROR.value());
                responseDto.setMessage(e.getMessage());
            }
        });

        producer.flush();

        responseDto.setStatusCode(HttpStatus.OK.value());
        responseDto.setMessage("Succeeded");
        responseDto.setData(model);

        return responseDto;
    }

    private void initializeKafkaProducer()
    {
        Properties properties = setProperties();
        producer = new KafkaProducer<>(properties);
    }

    private Properties setProperties()
    {
        Properties properties = new Properties();
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka.kafka.svc.cluster.local:9092");
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());

        return properties;
    }
}
