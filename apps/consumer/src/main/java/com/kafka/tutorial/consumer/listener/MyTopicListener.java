package com.kafka.tutorial.consumer.listener;

import com.kafka.tutorial.consumer.constant.Constants;
import com.kafka.tutorial.consumer.newrelic.NewRelicTracer;
import com.newrelic.api.agent.Trace;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class MyTopicListener {

    private final Logger logger = LoggerFactory.getLogger(MyTopicListener.class);
    private static final String TOPIC = "mytopic";

    @Autowired
    private NewRelicTracer newRelicTracer;

    public MyTopicListener()
    {
    }

    @Trace(dispatcher = true)
    @KafkaListener(topics = TOPIC, groupId = Constants.GROUP_ID)
    public void listen(
        ConsumerRecord<String, String> record
    )
    {
        newRelicTracer.track(record);

        logger.info("Message key: " + record.key());
        logger.info("Message value: " + record.value());
    }
}
