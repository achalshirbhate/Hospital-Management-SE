package com.telepatient.auth.repository;

import com.telepatient.auth.entity.SocialPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SocialPostRepository extends JpaRepository<SocialPost, Long> {
    List<SocialPost> findAllByOrderByPostedAtDesc();
}
