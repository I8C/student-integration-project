# Exercise introduction

The goal of this exercise is to implement the presented integration logic using Apache Camel.

You start from a base project that already provides:

- All required dependencies for every step
- A simple "hello world" Camel route
- An integration test for Kafka

### Prerequisites

See [prerequisites.md](prerequisites.md)

### What you will build

1. Implement a REST API secured with OAuth2 to create ticket purchase orders and send them to Kafka.
2. Run a scheduled API request and send the response to Kafka.
3. Extra: consume Kafka events and send a notification for each of them.
4. Extra: error handling.

[→ Go to step 1](exercise-1-step-1)