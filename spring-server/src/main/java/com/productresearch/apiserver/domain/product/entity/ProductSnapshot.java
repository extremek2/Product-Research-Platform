package com.productresearch.apiserver.domain.product.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "product_snapshot")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Builder
@AllArgsConstructor
public class ProductSnapshot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    private Integer price;
    private Double rating;

    @Column(name = "review_count")
    private Integer reviewCount;

    @Column(name = "seller_name")
    private String sellerName;

    @Column(name = "crawled_at")
    private LocalDateTime crawledAt;

    @PrePersist
    protected void onCreate() {
        crawledAt = LocalDateTime.now();
    }
}