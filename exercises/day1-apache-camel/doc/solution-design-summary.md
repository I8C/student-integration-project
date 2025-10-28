### Solution Design — Summary

**Goal**: Implement an event-driven ticket sales integration with Apache Camel, exposing REST APIs and using Kafka for asynchronous processing and read-model updates.

**Core Concepts**
- **APIs (REST + Camel REST DSL)**: Submit purchases and query current inventory/payment status per OpenAPI (`Festival_Ticket_Sales_API`).
- **Events (Kafka + Avro)**: Purchases are emitted as events; downstream services emit inventory and payment status updates. Avro schemas ensure compatibility.
- **Read Models (Caches)**: In-memory caches hold the latest inventory by ticket type and payment status by purchase id for fast queries.

**Main Building Blocks**
- `TicketPurchaseAPIRoute`: POST purchase → validate → map to Avro → produce `ticketPurchase` topic.
- `TicketInventoryEventsRoute`: consume `inventoryUpdated` → update `TicketInventoryCache`.
- `TicketPurchaseStatusEventsRoute`: consume `paymentStatusUpdate` → update `TicketStatusCache`.
- `TicketInventoryAPIRoute` and `TicketPaymentStatusAPIRoute`: GET endpoints → read from caches → 404 on miss.

**Contracts and Topics**
- OpenAPI: defines REST payloads and responses.
- Avro: `schema-ticketPurchase.avsc`, `schema-inventoryUpdated.avsc`, `schema-paymentStatusUpdate.avsc`.
- Kafka topics: `ticketPurchase`, `inventoryUpdated`, `paymentStatusUpdate` (names configured via properties).

**Flow at a Glance**
1) Client POSTs purchase → event produced.
2) Downstream processes emit status/inventory updates.
3) Event routes update caches.
4) Client GETs inventory/status → served from caches.

**Error Handling & Consistency**
- Cache miss → domain exception → HTTP 404.
- Caches are eventually consistent with event streams; start empty and warm via events.

**What to Implement in Exercise**
- Wire REST routes per OpenAPI; produce purchase events.
- Consume inventory/payment events; maintain caches.
- Serve GET endpoints from caches with correct errors.

Reference implementation is available in `PXLExercice2025Solution/`.


