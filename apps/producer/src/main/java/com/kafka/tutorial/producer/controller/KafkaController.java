package com.kafka.tutorial.producer.controller;

import com.kafka.tutorial.producer.dtos.KafkaRequestDto;
import com.kafka.tutorial.producer.dtos.KafkaResponseDto;
import com.kafka.tutorial.producer.service.kafka.KafkaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("test")
public class KafkaController {

    @Autowired
    KafkaService testService;

    @PostMapping
    public KafkaResponseDto publish(@RequestBody KafkaRequestDto requestDto)
    {
        return testService.publish(requestDto);
    }
}
