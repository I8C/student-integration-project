## Solution Design — Festival Ticket Sales Integration (Apache Camel)

### Purpose
This document explains the target design for the exercise solution. It describes how the Apache Camel routes, REST APIs, Kafka topics, Avro schemas, and in-memory caches collaborate to implement the ticket sales integration.

### High-Level Overview
- **Domain**: Festival ticket sales with purchase, inventory, and payment status tracking.
- **Integration style**: Event-driven with Kafka topics and REST APIs exposed through Camel.
- **Data contracts**: OpenAPI for REST, Avro for Kafka messages.
- **State**: Read-optimized via small in-memory caches populated by event streams.

### Key Components (source under `src/main/java/be/openint/pxltraining`)
- **API Routes**:
  - `TicketPurchaseAPIRoute`: Exposes REST endpoint to submit a ticket purchase and produces a `ticketPurchase` event.
  - `TicketPaymentStatusAPIRoute`: Exposes REST endpoint to query payment status (served from cache).
  - `TicketInventoryAPIRoute`: Exposes REST endpoint to query ticket inventory (served from cache).
- **Event Routes**:
  - `TicketInventoryEventsRoute`: Consumes inventory update events and updates the inventory cache.
  - `TicketPurchaseStatusEventsRoute`: Consumes payment status updates and updates the status cache.
- **Caches**:
  - `TicketInventoryCache`: In-memory store of latest inventory by ticket type.
  - `TicketStatusCache`: In-memory store of latest purchase/payment status by purchase id.
- **Exceptions**:
  - `PurchaseNotFoundException`, `TicketInventoryNotFoundException` thrown by API routes when cache misses occur.

The solution project (`PXLExercice2025Solution/`) contains an equivalent, fully implemented reference.

### Contracts and Schemas
- **OpenAPI**: `src/main/openapi/Festival_Ticket_Sales_API.json` and `src/main/resources/schema/Festival_Ticket_Sales_API.yaml` define the REST contract for purchase submission and status retrieval.
- **Avro Schemas**: `src/main/resources/schema/`
  - `schema-ticketPurchase.avsc`: Event emitted when a purchase is created.
  - `schema-inventoryUpdated.avsc`: Event emitted when inventory counts change.
  - `schema-paymentStatusUpdate.avsc`: Event emitted when payment status is updated (e.g., SUCCEEDED/FAILED).

### Kafka Topics (conceptual)
- `ticketPurchase`: Produced by `TicketPurchaseAPIRoute` when a purchase is submitted.
- `inventoryUpdated`: Consumed by `TicketInventoryEventsRoute` to refresh inventory cache.
- `paymentStatusUpdate`: Consumed by `TicketPurchaseStatusEventsRoute` to refresh status cache.

Topic names and serialization are configured in `application.properties` under `src/main/resources/`.

### End-to-End Flows
1) Purchase submission
- Client calls REST `POST /purchase` (per OpenAPI). `TicketPurchaseAPIRoute` validates input and produces a `ticketPurchase` Avro message to Kafka.
- Downstream systems (out of scope here) perform reservation, payment processing, and inventory adjustments, then emit `paymentStatusUpdate` and `inventoryUpdated` events.

2) Inventory read
- Client calls REST `GET /inventory/{ticketType}`. `TicketInventoryAPIRoute` reads from `TicketInventoryCache`.
- On cache miss, `TicketInventoryNotFoundException` is raised (translates to 404 or domain-specific error).

3) Payment status read
- Client calls REST `GET /purchase/{purchaseId}/status`. `TicketPaymentStatusAPIRoute` reads from `TicketStatusCache`.
- On cache miss, `PurchaseNotFoundException` is raised.

### Route Responsibilities
- **`TicketPurchaseAPIRoute`**
  - Bind REST operation to Camel route.
  - Validate payload against OpenAPI model.
  - Transform to Avro record (`schema-ticketPurchase.avsc`).
  - Produce to Kafka `ticketPurchase`.

- **`TicketInventoryEventsRoute`**
  - Consume `inventoryUpdated` from Kafka.
  - Deserialize Avro using `schema-inventoryUpdated.avsc`.
  - Update `TicketInventoryCache` for the relevant ticket type.

- **`TicketPurchaseStatusEventsRoute`**
  - Consume `paymentStatusUpdate` from Kafka.
  - Deserialize Avro using `schema-paymentStatusUpdate.avsc`.
  - Update `TicketStatusCache` keyed by `purchaseId`.

- **`TicketInventoryAPIRoute` and `TicketPaymentStatusAPIRoute`**
  - Expose REST GET endpoints.
  - Read data from caches and map to REST DTOs.
  - Surface domain errors via exceptions.

### Error Handling
- Cache misses result in domain exceptions mapped to HTTP 404 or appropriate error codes.
- Deserialization and schema mismatches are handled by Camel/Kafka error handlers (configurable in routes/properties). The exercise focuses on the happy path with explicit domain errors for reads.

### State and Caching
- Caches are the read-models for the APIs. They are eventually consistent with event streams.
- Inventory is keyed by ticket type; status is keyed by purchase id.
- On start, caches are empty and fill as events arrive; design assumes events are the source of truth.

### Configuration and Contracts Mapping
- `application.properties` defines Kafka bootstrap servers, topics, and serializers/deserializers, as well as Camel REST configuration.
- OpenAPI operations are bound to Camel REST DSL in the API routes.
- Avro schemas underpin the Kafka message formats to ensure compatibility across services.

### Testing
- Integration tests under `src/test/java/...` exercise POST purchase and then GET endpoints, using sample payloads in `src/test/resources/samples/`.
- A Kafka testcontainer is used to emulate the broker during tests.

### Deployment Notes (solution reference)
- The solution project (`PXLExercice2025Solution`) includes guidance under `doc/deploy-solution-on-aws.md` for running with managed Kafka and containerized services.

### What You Implement in the Exercise
- Wire up the REST routes to conform to the OpenAPI spec.
- Publish `ticketPurchase` events on POST.
- Consume `inventoryUpdated` and `paymentStatusUpdate` events and update caches.
- Serve inventory and status reads from caches with correct error handling.

This design yields a clean separation of write (command/event) and read (query/cache) concerns and demonstrates a typical event-driven REST+Kafka integration with Apache Camel.


