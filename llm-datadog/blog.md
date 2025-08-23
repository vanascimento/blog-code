# Datadog for LLM langchain/langgraph observability

## How to use Datadog for collecting logs, tracing, and token usage metrics to operate LLM applications with excellence

### Scenario

We need to deploy a LangChain application for reading utility bill data for our clients. Occasionally in production, errors occur and we need to add observability to track token usage, input and response data, and audit trails to improve our clients' experience.

Today, our application is an AWS Lambda function that uses LangChain to invoke a custom LLM. Our mission is to instrument this aws lambda with
datadog to reading the telemetry data
