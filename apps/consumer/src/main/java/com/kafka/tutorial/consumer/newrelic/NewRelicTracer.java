package com.kafka.tutorial.consumer.newrelic;

import com.newrelic.api.agent.ConcurrentHashMapHeaders;
import com.newrelic.api.agent.HeaderType;
import com.newrelic.api.agent.NewRelic;
import com.newrelic.api.agent.TransportType;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;

@Service
public class NewRelicTracer {

    private final Logger logger = LoggerFactory.getLogger(NewRelicTracer.class);

    public NewRelicTracer() {

    }

    public void track(
        ConsumerRecord<String, String> record
    ) {

        logger.info("Setting up Kafka trace with New Relic...");

        // Create a distributed trace headers map
        var headers = ConcurrentHashMapHeaders.build(HeaderType.MESSAGE);

        // Iterate through each record header and insert the trace headers into the headers map
        for (var header : record.headers()) {
            String headerValue = new String(header.value(), StandardCharsets.UTF_8);
            logger.info("Header key  : " + header.key());
            logger.info("Header value: " + headerValue);

            // using the newrelic key
            // if (header.key().equals("newrelic"))
            //  headers.addHeader("newrelic", headerValue);

            // or using the W3C keys
            if (header.key().equals("traceparent"))
                headers.addHeader("traceparent", headerValue);

            if (header.key().equals("tracestate"))
                headers.addHeader("tracestate", headerValue);
        }

        // Accept distributed tracing headers to link this request to the originating request
        NewRelic.getAgent().getTransaction().acceptDistributedTraceHeaders(TransportType.Kafka, headers);

        logger.info("Kafka trace with New Relic is set.");
    }
}
