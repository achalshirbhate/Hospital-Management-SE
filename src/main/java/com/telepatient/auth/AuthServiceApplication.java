package com.telepatient.auth;

import com.telepatient.auth.entity.Role;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class AuthServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApplication.class, args);
    }

    @Bean
    public CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            try {
                // Create admin user if not exists
                if (userRepository.findByEmail("admin@123").isEmpty()) {
                    User admin = new User();
                    admin.setFullName("System Administrator");
                    admin.setEmail("admin@123");
                    admin.setPassword(passwordEncoder.encode("admin"));
                    admin.setRole(Role.MAIN_DOCTOR);
                    userRepository.save(admin);
                    System.out.println("✓ Default admin user created: admin@123 / admin");
                }

                // Create doctor user if not exists
                if (userRepository.findByEmail("doctor@123").isEmpty()) {
                    User doctor = new User();
                    doctor.setFullName("Dr. Smith");
                    doctor.setEmail("doctor@123");
                    doctor.setPassword(passwordEncoder.encode("doctor"));
                    doctor.setRole(Role.DOCTOR);
                    userRepository.save(doctor);
                    System.out.println("✓ Default doctor user created: doctor@123 / doctor");
                }
            } catch (Exception e) {
                System.out.println("! Database initialization skipped (database may not be accessible yet)");
            }
        };
    }
}
