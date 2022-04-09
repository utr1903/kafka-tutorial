package com.kafka.tutorial.producer.service;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.stereotype.Service;

import java.util.Properties;

@Service
public class TestService {

    public TestService(){}

    public String publish(String value)
    {
        try
        {
            Properties properties = setProperties();

            KafkaProducer<String, String> producer
                    = new KafkaProducer<>(properties);

            ProducerRecord<String, String> record
                    = new ProducerRecord<>("first", value);

            producer.send(record);

            producer.flush();
        }
        catch (Exception e)
        {
            System.out.println(e);
            return "Fail";
        }

        return "Success";
    }

    private Properties setProperties()
    {
        Properties properties = new Properties();
        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka-0:9092");
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());

        return properties;
    }
}
