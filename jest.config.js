module.exports = {
  testEnvironment: "node",
  testMatch: [
    "**/tests/**/*.test.js"
  ],
  verbose: true,
  collectCoverage: true,
  coverageDirectory: "coverage",
  globalTeardown: "<rootDir>/tests/jest.teardown.js"
};
