# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```python
   # Testable
   def process_order(order, payment_gateway): ...

   # Hard to test
   def process_order(order):
       gateway = StripeGateway()  # hidden dependency
   ```

2. **Return results, don't produce side effects**

   ```python
   # Testable
   def calculate_discount(cart) -> Discount: ...

   # Hard to test
   def apply_discount(cart) -> None:
       cart.total -= discount  # mutates in place, hard to assert
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup
