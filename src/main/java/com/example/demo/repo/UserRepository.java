package com.example.demo.repo;

import com.example.demo.model.User;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository {
    private final Map<String, User> users = new ConcurrentHashMap<>();

    public UserRepository(PasswordEncoder encoder) {
        users.put("1", new User("1", "user", encoder.encode("password"), Set.of("ROLE_USER")));
        users.put("2", new User("2", "admin", encoder.encode("password"), Set.of("ROLE_ADMIN")));
    }

    public Optional<User> findByUsername(String username) {
        return users.values().stream().filter(u -> u.username().equals(username)).findFirst();
    }

    public Optional<User> findById(String id) {
        return Optional.ofNullable(users.get(id));
    }

    public long count() {
        return users.size();
    }
}
