package com.productresearch.apiserver.domain.shipment.dto;

import com.productresearch.apiserver.domain.shipment.entity.TransportDocument;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

public record CreateTransportDocumentRequest(
        @NotNull TransportDocument.Type documentType, @NotBlank String documentNumber,
        String issuerName, LocalDateTime issuedAt, boolean primary
) {}
