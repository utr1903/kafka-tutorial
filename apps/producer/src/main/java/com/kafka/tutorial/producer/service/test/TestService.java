package com.kafka.tutorial.producer.service.test;

import com.kafka.tutorial.producer.dtos.TestRequestDto;
import com.kafka.tutorial.producer.dtos.TestResponseDto;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Properties;

@Service
public class TestService {

    KafkaProducer<String, String> producer;

    public TestService()
    {
        initializeKafkaProducer();
    }

    public TestResponseDto publish(
        TestRequestDto requestDto
    )
    {
        TestResponseDto responseDto = new TestResponseDto();

        ProducerRecord<String, String> record =
                new ProducerRecord<>(
                        requestDto.getTopic(),
                        requestDto.getValue()
                );

        PublishModel model = new PublishModel();

        producer.send(record, (recordMetadata, e) -> {
            model.setTopic(requestDto.getTopic());
            model.setPartition(recordMetadata.partition());
            model.setTimestamp(recordMetadata.timestamp());

            if (e == null)
            {
                System.out.println("Success");
                responseDto.setStatusCode(HttpStatus.OK.value());
                responseDto.setMessage("Success");
            }
            else
            {
                System.out.println(e);
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
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka-0.kafka.svc.cluster.local:9092");
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());

        return properties;
    }
}
