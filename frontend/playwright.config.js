const { defineConfig } = require("@playwright/test");
module.exports = defineConfig({
  testDir: "./e2e",
  fullyParallel: false,
  workers: 1,
  timeout: 60000,
  reporter: "list",
  use: { baseURL: "http://localhost:3000", channel: "chrome", headless: true, screenshot: "only-on-failure" },
  webServer: [
    { command: "./gradlew onboardingE2eServer --no-daemon", cwd: "../api-server", url: "http://127.0.0.1:18080/_e2e/ready", timeout: 180000, reuseExistingServer: false },
    { command: "npm start", url: "http://localhost:3000", timeout: 120000, reuseExistingServer: false,
      env: { BROWSER: "none", HOST: "localhost", PORT: "3000", REACT_APP_API_URL: "http://localhost:18080/api/v1" } },
  ],
});
