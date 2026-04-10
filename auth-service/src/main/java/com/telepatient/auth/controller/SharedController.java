package com.telepatient.auth.controller;

import com.telepatient.auth.dto.request.LaunchpadDTO;
import com.telepatient.auth.entity.SocialPost;
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

    @GetMapping("/social")
    public ResponseEntity<List<SocialPost>> getSocialFeed() {
        return ResponseEntity.ok(sharedService.getSocialFeed());
    }

    @PostMapping("/launchpad")
    public ResponseEntity<String> submitIdea(@RequestBody LaunchpadDTO request) {
        sharedService.submitLaunchpadIdea(request);
        return ResponseEntity.ok("Idea submitted to LaunchPad successfully");
    }
}
