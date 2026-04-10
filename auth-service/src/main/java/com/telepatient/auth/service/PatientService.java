package com.telepatient.auth.service;

import com.telepatient.auth.dto.request.TokenRequestDTO;
import com.telepatient.auth.dto.response.HistoryDTO;
import com.telepatient.auth.entity.CommunicationToken;
import java.util.List;

public interface PatientService {
    List<HistoryDTO> getPatientHistory(Long patientId);
    void requestCommunicationToken(TokenRequestDTO request);
    List<CommunicationToken> getPatientTokens(Long patientId);
}
