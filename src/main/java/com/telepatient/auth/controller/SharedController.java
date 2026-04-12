package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.LaunchpadDTO;
import com.telepatient.auth.entity.SocialPost;
import com.telepatient.auth.entity.LaunchpadSubmission;
import com.telepatient.auth.entity.Role;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.LaunchpadSubmissionRepository;
import com.telepatient.auth.repository.SocialPostRepository;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.service.SharedService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/shared")
@RequiredArgsConstructor
public class SharedController {

    private final SharedService sharedService;
    private final SocialPostRepository socialPostRepo;
    private final LaunchpadSubmissionRepository launchpadRepo;
    private final UserRepository userRepo;

    @GetMapping("/social")
    public ResponseEntity<List<SocialPost>> getSocialFeed() {
        return ResponseEntity.ok(sharedService.getSocialFeed());
    }

    @PostMapping("/launchpad")
    public ResponseEntity<String> submitIdea(@RequestBody LaunchpadDTO request) {
        sharedService.submitLaunchpadIdea(request);
        return ResponseEntity.ok("Idea submitted to LaunchPad successfully");
    }

    @DeleteMapping("/social/{postId}")
    public ResponseEntity<String> deleteSocialPost(@PathVariable Long postId,
                                                    @RequestParam Long requesterId) {
        SocialPost post = socialPostRepo.findById(postId)
            .orElseThrow(() -> new RuntimeException("Post not found"));
        User requester = userRepo.findById(requesterId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        boolean isOwner = post.getAuthor().getId().equals(requesterId);
        boolean isAdmin = requester.getRole() == Role.MAIN_DOCTOR;
        if (!isOwner && !isAdmin) return ResponseEntity.status(403).body("Unauthorized");
        socialPostRepo.deleteById(postId);
        return ResponseEntity.ok("Post deleted successfully");
    }

    @DeleteMapping("/launchpad/{ideaId}")
    public ResponseEntity<String> deleteLaunchpadIdea(@PathVariable Long ideaId,
                                                       @RequestParam Long requesterId) {
        LaunchpadSubmission idea = launchpadRepo.findById(ideaId)
            .orElseThrow(() -> new RuntimeException("Idea not found"));
        User requester = userRepo.findById(requesterId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        boolean isOwner = idea.getSubmitter().getId().equals(requesterId);
        boolean isAdmin = requester.getRole() == Role.MAIN_DOCTOR;
        if (!isOwner && !isAdmin) return ResponseEntity.status(403).body("Unauthorized");
        launchpadRepo.deleteById(ideaId);
        return ResponseEntity.ok("Idea deleted successfully");
    }
}
