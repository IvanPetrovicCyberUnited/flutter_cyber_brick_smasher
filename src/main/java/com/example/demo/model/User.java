package com.example.demo.model;

import java.util.Set;

public record User(String id, String username, String password, Set<String> roles) {}
