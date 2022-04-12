package com.kafka.tutorial.consumer.listener;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.Properties;

@Service
public class KafkaListener {

    private static final String TOPIC = "mytopic";
    private static final String GROUP_ID = "mygroup";

    private KafkaConsumer<String, String> consumer;

    public KafkaListener()
    {
        initializeKafkaConsumer();
    }

    private void initializeKafkaConsumer()
    {
        try
        {
            createConsumer();

            subscribeToTopic();

            System.out.println("Starting to poll ...");

            while (true)
            {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));

                for (ConsumerRecord<String, String> record : records)
                {
                    System.out.println("Value    : " + record.value());
                    System.out.println("Partition: " + record.partition());
                    System.out.println();
                }
            }
        }
        finally
        {
            closeConsumer();
        }
    }

    private void createConsumer()
    {
        System.out.println("Creating Kafka consumer ...");

        Properties properties = setProperties();
        consumer = new KafkaConsumer<>(properties);

        System.out.println(" -> Kafka consumer is created.");
    }

    private Properties setProperties()
    {
        Properties properties = new Properties();
        properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka.kafka.svc.cluster.local:9092");
        properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
        properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
        properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        properties.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");

        return properties;
    }

    private void subscribeToTopic()
    {
        System.out.println("Subscribing to topic" + TOPIC + "...");

        consumer.subscribe(List.of(TOPIC));

        System.out.println(" -> Topic is subscribed.");
    }

    private void closeConsumer()
    {
        System.out.println("Closing consumer ...");
        consumer.close();
        System.out.println("Consumer closed.");
    }
}
