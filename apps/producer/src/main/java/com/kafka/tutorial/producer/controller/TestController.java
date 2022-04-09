package com.kafka.tutorial.producer.controller;

import com.kafka.tutorial.producer.model.TestModel;
import com.kafka.tutorial.producer.service.TestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("test")
public class TestController {

    @Autowired
    TestService testService;

    @PostMapping
    public String publish(@RequestBody TestModel requestDto)
    {
        String value = requestDto.getValue();
        System.out.println(value);

        String response = testService.publish(value);
        return response;
    }
}
