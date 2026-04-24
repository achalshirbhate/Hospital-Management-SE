package com.telepatient.auth.entity;

import jakarta.persistence.*;

@Entity
public class PatientProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private Integer age;
    private String logoUrl;

    @Column(columnDefinition = "TEXT")
    private String medicalHistory;

    @ManyToOne
    @JoinColumn(name = "current_doctor_id")
    private User currentDoctor;

    public PatientProfile() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private User user, currentDoctor;
        private Integer age; private String logoUrl, medicalHistory;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder user(User u) { this.user = u; return this; }
        public Builder age(Integer a) { this.age = a; return this; }
        public Builder logoUrl(String l) { this.logoUrl = l; return this; }
        public Builder medicalHistory(String m) { this.medicalHistory = m; return this; }
        public Builder currentDoctor(User d) { this.currentDoctor = d; return this; }
        public PatientProfile build() {
            PatientProfile p = new PatientProfile();
            p.id = id; p.user = user; p.age = age; p.logoUrl = logoUrl;
            p.medicalHistory = medicalHistory; p.currentDoctor = currentDoctor;
            return p;
        }
    }

    public Long getId() { return id; }
    public User getUser() { return user; }
    public Integer getAge() { return age; }
    public String getLogoUrl() { return logoUrl; }
    public String getMedicalHistory() { return medicalHistory; }
    public User getCurrentDoctor() { return currentDoctor; }

    public void setId(Long id) { this.id = id; }
    public void setUser(User u) { this.user = u; }
    public void setAge(Integer a) { this.age = a; }
    public void setLogoUrl(String l) { this.logoUrl = l; }
    public void setMedicalHistory(String m) { this.medicalHistory = m; }
    public void setCurrentDoctor(User d) { this.currentDoctor = d; }
}
