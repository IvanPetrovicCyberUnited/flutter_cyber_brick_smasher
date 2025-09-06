package com.example.demo.exception;

import java.time.Instant;

public record ApiError(Instant timestamp, String path, int code, String message, String correlationId) {}
