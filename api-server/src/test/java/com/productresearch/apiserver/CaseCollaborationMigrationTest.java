package com.productresearch.apiserver;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import java.sql.*;
import static org.assertj.core.api.Assertions.*;

class CaseCollaborationMigrationTest extends PostgresTestSupport {
    @Test void legacyContactsParticipantsAndInvitationsRemainUnmapped() throws Exception {
        String schema="upgrade_case_collaboration";
        var configuration=Flyway.configure().dataSource(DATABASE.getJdbcUrl(),DATABASE.getUsername(),DATABASE.getPassword())
                .schemas(schema).defaultSchema(schema).locations("classpath:db/migration");
        configuration.target("16").load().migrate();
        try(Connection c=DriverManager.getConnection(DATABASE.getJdbcUrl(),DATABASE.getUsername(),DATABASE.getPassword());Statement sql=c.createStatement()) {
            c.setSchema(schema);
            sql.executeUpdate("INSERT INTO organization(name,organization_type) VALUES ('legacy','SHIPPER')");
            sql.executeUpdate("INSERT INTO app_user(email,name) VALUES ('legacy@example.test','legacy')");
            sql.executeUpdate("INSERT INTO shipment_case(owner_organization_id,case_number,direction,transport_mode,created_by) SELECT o.id,'legacy','IMPORT','SEA',u.id FROM organization o,app_user u");
            sql.executeUpdate("INSERT INTO external_contact(owner_organization_id,name,email,contact_type) SELECT id,'legacy contact','external@example.test','FORWARDER' FROM organization");
            sql.executeUpdate("INSERT INTO case_participant(shipment_case_id,external_contact_id,participant_role,access_level) SELECT s.id,e.id,'FORWARDER','EDITOR' FROM shipment_case s,external_contact e");
            sql.executeUpdate("INSERT INTO case_invitation(participant_id,token_hash,target_email,expires_at,created_by) SELECT p.id,'legacy-invitation','external@example.test',NOW()+INTERVAL '1 day',u.id FROM case_participant p,app_user u");
        }
        configuration.target("latest").load().migrate();
        try(Connection c=DriverManager.getConnection(DATABASE.getJdbcUrl(),DATABASE.getUsername(),DATABASE.getPassword());Statement sql=c.createStatement()) {
            c.setSchema(schema);
            try(ResultSet r=sql.executeQuery("SELECT p.case_partner_id,p.access_level,e.partner_company_id,i.token_hash FROM case_participant p JOIN external_contact e ON e.id=p.external_contact_id JOIN case_invitation i ON i.participant_id=p.id")) {
                assertThat(r.next()).isTrue(); assertThat(r.getObject(1)).isNull(); assertThat(r.getString(2)).isEqualTo("EDITOR");
                assertThat(r.getObject(3)).isNull(); assertThat(r.getString(4)).isEqualTo("legacy-invitation");
            }
            try(ResultSet r=sql.executeQuery("SELECT count(*) FROM case_partner")) {assertThat(r.next()).isTrue();assertThat(r.getInt(1)).isZero();}
        }
    }
}
