# Improving Resilience for Structured Output in Generative AI Applications

> **🚀 Transform your AI applications from fragile to bulletproof with proven resilience strategies that handle failures gracefully and maintain user experience under any circumstances.**

## Introduction

In the rapidly evolving landscape of Generative AI applications, one of the most critical challenges developers face is ensuring reliable and consistent structured output from Large Language Models (LLMs). While LLMs excel at generating human-like text, they can sometimes produce outputs that don't conform to expected schemas, leading to application failures and poor user experiences.

This blog post explores several robust approaches to improve resilience when working with structured outputs in Generative AI applications, using practical examples from a financial data extraction use case.

## Use Case Context

The examples and code demonstrations in this post are based on a real-world task: extracting structured data from **relevant fact reports** (fatos relevantes) published by Brazilian companies listed on the stock exchange. These reports contain critical financial information that must be accurately parsed and structured for investment analysis.

**Complete Implementation**: The full working code for all examples shown in this post can be found in the [GitHub repository](https://github.com/vanascimento/blog-code/tree/main/llm-structured-resilice).

## The Challenge: Unreliable Structured Output

When building production applications that rely on LLM-generated structured data, several issues commonly arise:

- **Schema Violations**: LLMs may return data that doesn't match the expected structure
- **Missing Fields**: Critical information might be omitted or returned as null
- **Type Mismatches**: Data types might not conform to the expected schema
- **Inconsistent Formatting**: Date formats, number representations, and other fields might vary
- **Partial Failures**: The LLM might succeed in extracting some information but fail on others

## Target Schema

Our target schema for extracting financial data includes:

```python
class RelevantFacts(BaseModel):
    Company: str
    Date: date
    Type: EventType
    Local: Address
    DividendInfo: Optional[DividentInfo]
```

Where the nested schemas are defined as:

```python
class Address(BaseModel):
    Country: str
    State: str
    City: str
    Street: str
    Number: str
    ZipCode: str

class DividentInfo(BaseModel):
    Type: StockType
    Divident: float
    Date: date
    PaymentDate: date

class EventType(str, Enum):
    DIVIDEND_PAYMENT = "Dividend Payment"
    RESULT_ANNOUNCEMENT = "Result Announcement"
    MERGER_ANNOUNCEMENT = "Merger Announcement"
    ACQUISITION_ANNOUNCEMENT = "Acquisition Announcement"
    OTHER = "Other"
```

## Approach 1: LangChain Structured Output

LangChain provides a built-in mechanism for structured output that offers basic resilience:

```python
from langchain_openai import ChatOpenAI
from pydantic import BaseModel

llm_with_structured_output = ChatOpenAI(
    model="gpt-4.1-mini",
    temperature=0
).with_structured_output(RelevantFacts)

response = llm_with_structured_output.invoke(messages)
```

**Pros:**

- Simple to implement
- Automatic schema validation
- Built-in error handling

**Cons:**

- Limited retry mechanisms
- No fallback strategies
- Basic error recovery

## Approach 2: Instructor with Retry Logic

The Instructor library provides more sophisticated retry mechanisms and better error handling:

```python
import instructor

client = instructor.from_provider("openai/gpt-4.1-mini")
response = client.chat.completions.create(
    response_model=RelevantFacts,
    messages=messages,
    max_retries=3  # Automatic retry on failures
)
```

**Pros:**

- Built-in retry mechanisms
- Better error handling
- Automatic schema validation
- More control over the extraction process

**Cons:**

- Requires additional dependency
- More complex setup
- Limited to OpenAI models

## Approach 3: TrustCall with Tool-Based Extraction

TrustCall offers a different approach using tool-based extraction, which can be more reliable for complex schemas:

```python
from trustcall import create_extractor

bound = create_extractor(
    llm,
    tools=[RelevantFacts],
    tool_choice="RelevantFacts",
)

response = bound.invoke(messages)
```

### Detailed Extraction Information

One of TrustCall's key advantages is that it provides comprehensive metadata about the extraction process. The response includes detailed information such as:

```python
{
    'messages': [...],  # Complete conversation history
    'responses': [RelevantFacts(...)],  # Parsed structured objects
    'response_metadata': [...],  # Tool call metadata
    'attempts': 2  # Number of extraction attempts made
}
```

**Example Response Structure:**

```python
{
    'messages': [
        AIMessage(
            content='',
            additional_kwargs={
                'tool_calls': [{
                    'id': 'call_CQVpJ2WAnzIfRluOIZIPPvTC',
                    'name': 'RelevantFacts',
                    'args': {
                        'Company': 'Petróleo Brasileiro S.A. - Petrobras',
                        'Date': '2025-08-07',
                        'Type': 'Dividend Payment',
                        'Local': {
                            'Country': 'Brazil',
                            'State': 'RJ',
                            'City': 'Rio de Janeiro',
                            'Street': 'Av. Henrique Valadares',
                            'Number': '28 - 9º andar',
                            'ZipCode': '20031-030'
                        },
                        'DividendInfo': {
                            'Type': 'ORDINARIA',
                            'Divident': 0.67192409,
                            'Date': '2025-11-21',
                            'PaymentDate': '2025-11-21'
                        }
                    }
                }]
            },
            response_metadata={
                'token_usage': {
                    'completion_tokens': 143,
                    'prompt_tokens': 1690,
                    'total_tokens': 1833
                },
                'model_name': 'gpt-4.1-mini-2025-04-14',
                'finish_reason': 'stop'
            }
        )
    ],
    'responses': [
        RelevantFacts(
            Company='Petróleo Brasileiro S.A. - Petrobras',
            Date=datetime.date(2025, 8, 7),
            Type=EventType.DIVIDEND_PAYMENT,
            Local=Address(...),
            DividendInfo=DividentInfo(...)
        )
    ],
    'attempts': 2
}
```

This detailed response structure enables:

- **Debugging**: Full visibility into what the model attempted
- **Cost Tracking**: Token usage information for each attempt
- **Retry Analysis**: Understanding how many attempts were needed
- **Quality Metrics**: Tracking extraction success patterns

**Pros:**

- Tool-based approach for better reliability
- Explicit schema definition
- Better handling of complex nested structures
- **Comprehensive extraction metadata and debugging information**
- **Built-in retry tracking and attempt counting**

**Cons:**

- Different paradigm from traditional chat completions
- May require prompt engineering adjustments
- More complex response structure to handle

## Advanced Resilience Strategies

### 1. Schema Validation and Fallbacks

Implement multiple validation layers:

```python
def extract_with_fallback(messages, primary_schema, fallback_schemas):
    for schema in [primary_schema] + fallback_schemas:
        try:
            response = extract_structured_data(messages, schema)
            if validate_response(response):
                return response
        except Exception as e:
            logger.warning(f"Schema {schema.__name__} failed: {e}")
            continue

    # Return partial data or raise custom exception
    raise ExtractionFailedException("All extraction attempts failed")
```

### 2. Field-Level Validation and Correction

Implement intelligent field correction:

```python
def validate_and_correct_dates(date_string):
    """Attempt to parse and correct various date formats"""
    common_formats = ["%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y", "%m/%d/%Y"]

    for fmt in common_formats:
        try:
            return datetime.strptime(date_string, fmt).date()
        except ValueError:
            continue

    # Use fuzzy parsing as last resort
    return parse_fuzzy_date(date_string)
```

### 3. Multi-Model Ensemble

Use multiple models for better reliability:

```python
def ensemble_extraction(messages, schemas):
    results = []
    models = ["gpt-4", "gpt-3.5-turbo", "claude-3-sonnet"]

    for model in models:
        try:
            result = extract_with_model(model, messages, schemas)
            results.append(result)
        except Exception as e:
            logger.error(f"Model {model} failed: {e}")

    # Return consensus result or best match
    return select_best_result(results)
```

### 4. Progressive Schema Relaxation

Start with strict validation and gradually relax constraints:

```python
def progressive_extraction(messages):
    # Start with strict schema
    strict_schema = RelevantFacts

    # If strict fails, try with optional fields
    relaxed_schema = RelevantFactsRelaxed

    # If still fails, try with minimal required fields
    minimal_schema = RelevantFactsMinimal

    for schema in [strict_schema, relaxed_schema, minimal_schema]:
        try:
            return extract_structured_data(messages, schema)
        except Exception:
            continue

    raise ExtractionFailedException("All extraction levels failed")
```

## Best Practices for Production

### 1. Comprehensive Logging

```python
import logging
import json

def log_extraction_attempt(messages, schema, result, duration, errors=None):
    log_data = {
        "timestamp": datetime.now().isoformat(),
        "schema": schema.__name__,
        "input_length": len(str(messages)),
        "extraction_duration": duration,
        "success": errors is None,
        "errors": errors,
        "result_summary": summarize_result(result)
    }

    logging.info(f"Extraction attempt: {json.dumps(log_data)}")
```

### 2. Circuit Breaker Pattern

Implement circuit breaker to prevent cascading failures:

```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=60)
def extract_structured_data(messages, schema):
    # Your extraction logic here
    pass
```

### 3. Rate Limiting and Backoff

```python
import time
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
def extract_with_backoff(messages, schema):
    return extract_structured_data(messages, schema)
```

## Monitoring and Alerting

### 1. Success Rate Tracking

```python
class ExtractionMetrics:
    def __init__(self):
        self.total_attempts = 0
        self.successful_extractions = 0
        self.failed_extractions = 0

    def record_attempt(self, success: bool):
        self.total_attempts += 1
        if success:
            self.successful_extractions += 1
        else:
            self.failed_extractions += 1

    @property
    def success_rate(self):
        return self.successful_extractions / self.total_attempts if self.total_attempts > 0 else 0
```

### 2. Performance Monitoring

```python
import time
from contextlib import contextmanager

@contextmanager
def measure_extraction_time():
    start_time = time.time()
    try:
        yield
    finally:
        duration = time.time() - start_time
        # Send to monitoring system (e.g., Prometheus, DataDog)
        record_extraction_duration(duration)
```

## Conclusion

Building resilient structured output systems for Generative AI applications requires a multi-layered approach:

1. **Start with robust schemas** using Pydantic or similar validation libraries
2. **Implement retry mechanisms** with exponential backoff
3. **Use multiple extraction strategies** as fallbacks
4. **Monitor and alert** on extraction failures
5. **Implement graceful degradation** when extraction fails
6. **Log comprehensively** for debugging and improvement

The examples in this post demonstrate that while no single approach is perfect, combining multiple strategies can significantly improve the reliability of your AI applications. The key is to understand your specific use case, implement appropriate fallbacks, and continuously monitor and improve your extraction pipeline.

Remember: resilience in AI applications is not about preventing all failures—it's about handling failures gracefully and maintaining a good user experience even when things go wrong.

## Resources

- [LangChain Documentation](https://python.langchain.com/)
- [Instructor Library](https://github.com/jxnl/instructor)
- [TrustCall Documentation](https://trustcall.ai/)
- [Pydantic Validation](https://docs.pydantic.dev/)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
