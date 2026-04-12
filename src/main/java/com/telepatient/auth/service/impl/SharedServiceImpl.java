package com.telepatient.auth.service.impl;

import com.telepatient.auth.dto.request.LaunchpadDTO;
import com.telepatient.auth.entity.LaunchpadSubmission;
import com.telepatient.auth.entity.SocialPost;
import com.telepatient.auth.entity.User;
import com.telepatient.auth.repository.LaunchpadSubmissionRepository;
import com.telepatient.auth.repository.SocialPostRepository;
import com.telepatient.auth.repository.UserRepository;
import com.telepatient.auth.service.SharedService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SharedServiceImpl implements SharedService {

    private final SocialPostRepository socialRepo;
    private final LaunchpadSubmissionRepository launchpadRepo;
    private final UserRepository userRepo;

    @Override
    public List<SocialPost> getSocialFeed() {
        return socialRepo.findAllByOrderByPostedAtDesc();
    }

    @Override
    public void submitLaunchpadIdea(LaunchpadDTO dto) {
        User submitter = userRepo.findById(dto.getSubmitterId()).orElseThrow();
        LaunchpadSubmission submission = LaunchpadSubmission.builder()
                .submitter(submitter)
                .ideaTitle(dto.getIdeaTitle())
                .description(dto.getDescription())
                .domain(dto.getDomain())
                .contactInfo(dto.getContactInfo())
                .submittedAt(LocalDateTime.now())
                .build();
        launchpadRepo.save(submission);
    }
}
