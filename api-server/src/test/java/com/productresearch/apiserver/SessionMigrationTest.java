package com.productresearch.apiserver;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import java.sql.*;
import static org.assertj.core.api.Assertions.*;

class SessionMigrationTest extends PostgresTestSupport {
    @Test void upgradesV13SessionsAndPreservesOrganizationOwnership() throws Exception {
        String schema = "upgrade_stage_one";
        var configuration = Flyway.configure().dataSource(DATABASE.getJdbcUrl(), DATABASE.getUsername(), DATABASE.getPassword())
                .schemas(schema).defaultSchema(schema).locations("classpath:db/migration");
        configuration.target("13").load().migrate();
        try (Connection connection = DriverManager.getConnection(DATABASE.getJdbcUrl(), DATABASE.getUsername(), DATABASE.getPassword());
             Statement sql = connection.createStatement()) {
            connection.setSchema(schema);
            sql.executeUpdate("INSERT INTO organization(name,organization_type) VALUES ('upgrade owner','SHIPPER')");
            sql.executeUpdate("INSERT INTO app_user(email,name) VALUES ('upgrade@example.com','owner')");
            sql.executeUpdate("INSERT INTO organization_member(organization_id,user_id,member_role) SELECT o.id,u.id,'OWNER' FROM organization o,app_user u WHERE o.name='upgrade owner' AND u.email='upgrade@example.com'");
            sql.executeUpdate("INSERT INTO refresh_session(user_id,organization_id,token_hash,expires_at) SELECT u.id,o.id,'legacy-hash',NOW()+INTERVAL '1 day' FROM organization o,app_user u WHERE o.name='upgrade owner' AND u.email='upgrade@example.com'");
        }
        configuration.target("latest").load().migrate();
        try (Connection connection = DriverManager.getConnection(DATABASE.getJdbcUrl(), DATABASE.getUsername(), DATABASE.getPassword());
             Statement sql = connection.createStatement()) {
            connection.setSchema(schema);
            try (ResultSet rows = sql.executeQuery("SELECT s.session_kind,s.public_id,m.member_role FROM refresh_session s JOIN organization_member m ON m.user_id=s.user_id AND m.organization_id=s.organization_id WHERE s.token_hash='legacy-hash'")) {
                assertThat(rows.next()).isTrue();
                assertThat(rows.getString(1)).isEqualTo("ORGANIZATION");
                assertThat(rows.getObject(2)).isNotNull();
                assertThat(rows.getString(3)).isEqualTo("OWNER");
            }
        }
    }
}
