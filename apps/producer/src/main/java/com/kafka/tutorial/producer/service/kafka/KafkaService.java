package com.kafka.tutorial.producer.service.kafka;

import com.kafka.tutorial.producer.dtos.KafkaRequestDto;
import com.kafka.tutorial.producer.dtos.KafkaResponseDto;
import com.newrelic.api.agent.NewRelic;
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

import java.util.Properties;

@Service
public class KafkaService {

    private final Logger logger = LoggerFactory.getLogger(KafkaService.class);

    private KafkaProducer<String, String> producer;

    public KafkaService()
    {
        initializeKafkaProducer();
    }

    public KafkaResponseDto publish(
        KafkaRequestDto requestDto
    )
    {
        var traceId = NewRelic.getAgent().getTraceMetadata().getTraceId();

        var headers = new RecordHeaders();
        headers.add(new RecordHeader("traceId", traceId.getBytes()));

        var record = new ProducerRecord<>(
            requestDto.getTopic(),
            null,
            "value",
            requestDto.getValue(),
            headers
        );

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
