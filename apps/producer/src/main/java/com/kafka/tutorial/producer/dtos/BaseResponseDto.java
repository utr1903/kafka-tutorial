package com.kafka.tutorial.producer.dtos;

public class BaseResponseDto<T> {

    protected int statusCode;
    protected String message;
    protected T data;

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getMessage() { return message; }

    public void setData(T data) { this.data = data; }

    public T getData() { return data; }
}
