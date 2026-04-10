package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.LaunchpadDTO;
import com.telepatient.auth.entity.SocialPost;
import java.util.List;

public interface SharedService {
    List<SocialPost> getSocialFeed();
    void submitLaunchpadIdea(LaunchpadDTO dto);
}
