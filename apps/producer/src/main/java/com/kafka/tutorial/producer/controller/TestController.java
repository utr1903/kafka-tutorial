package com.kafka.tutorial.producer.controller;

import com.kafka.tutorial.producer.dtos.TestRequestDto;
import com.kafka.tutorial.producer.dtos.TestResponseDto;
import com.kafka.tutorial.producer.service.test.TestService;
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
    public TestResponseDto publish(@RequestBody TestRequestDto requestDto)
    {
        return testService.publish(requestDto);
    }
}
