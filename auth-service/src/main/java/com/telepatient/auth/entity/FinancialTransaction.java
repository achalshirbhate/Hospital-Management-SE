package com.telepatient.auth.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class FinancialTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;

    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private String description;
    private LocalDateTime transactionDate;

    public FinancialTransaction() {}

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id; private Double amount; private TransactionType type;
        private String description; private LocalDateTime transactionDate;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder amount(Double a) { this.amount = a; return this; }
        public Builder type(TransactionType t) { this.type = t; return this; }
        public Builder description(String d) { this.description = d; return this; }
        public Builder transactionDate(LocalDateTime d) { this.transactionDate = d; return this; }
        public FinancialTransaction build() {
            FinancialTransaction f = new FinancialTransaction();
            f.id = id; f.amount = amount; f.type = type;
            f.description = description; f.transactionDate = transactionDate;
            return f;
        }
    }

    public Long getId() { return id; }
    public Double getAmount() { return amount; }
    public TransactionType getType() { return type; }
    public String getDescription() { return description; }
    public LocalDateTime getTransactionDate() { return transactionDate; }

    public void setId(Long id) { this.id = id; }
    public void setAmount(Double a) { this.amount = a; }
    public void setType(TransactionType t) { this.type = t; }
    public void setDescription(String d) { this.description = d; }
    public void setTransactionDate(LocalDateTime d) { this.transactionDate = d; }
}
