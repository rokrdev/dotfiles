# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```python
# Easy to mock (Python)
def process_payment(order, payment_client):
    return payment_client.charge(order.total)

# Hard to mock
def process_payment(order):
    client = StripeClient(os.environ["STRIPE_KEY"])
    return client.charge(order.total)
```

```kotlin
// Easy to mock (Kotlin)
fun processPayment(order: Order, paymentClient: PaymentClient): Receipt =
    paymentClient.charge(order.total)

// Hard to mock
fun processPayment(order: Order): Receipt {
    val client = StripeClient(System.getenv("STRIPE_KEY"))
    return client.charge(order.total)
}
```

**2. Prefer specific operations over generic dispatchers**

Create specific functions/methods for each external operation instead of one generic dispatcher with conditional logic:

```python
# GOOD: Each function is independently mockable
class ApiClient:
    def get_user(self, id): ...
    def get_orders(self, user_id): ...
    def create_order(self, data): ...

# BAD: Mocking requires conditional logic inside the mock
class ApiClient:
    def fetch(self, endpoint, method="GET", body=None): ...
```

The specific-operation approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Stronger type contracts per operation
