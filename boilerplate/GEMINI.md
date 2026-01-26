# BookingTime Scheduling System - Gemini Instructions

## Project Overview

BookingTime is an internal meeting scheduling coordination system designed to eliminate back-and-forth messaging for interview and multi-party meeting scheduling. The system uses a negative selection availability model where business hours (09:00-18:00) are considered available by default, and participants only mark unavailable time slots.

## Key Concepts

### Negative Selection Model

- **Default State**: All business hours (Mon-Fri, 09:00-18:00) are AVAILABLE
- **Participant Action**: Only mark UNAVAILABLE time slots
- **System Blocking**: Pre-blocks PTO/leave, weekends, holidays, lunch breaks
- **Benefit**: Reduces cognitive load and response time for participants

### Agent-Based Architecture

The system operates through specialized agents:

- **Organizer Agent**: Creates requests, monitors responses, confirms meetings
- **Participant Agent**: Submits availability via secure links
- **Availability Calculator Agent**: Computes intersection of available times
- **Room Reservation Agent**: Handles booking with conflict resolution
- **Notification Agent**: Sends messenger notifications (text + URLs only)

### API-First Design

All functionality is exposed through RESTful APIs:

- Organizer APIs: `/meeting-requests`, `/meeting-requests/:id/*`
- Participant APIs: `/r/:token` (secure, time-bounded access)
- System APIs: `/health`, external integrations

## Technology Stack

- **Backend**: Express.js + TypeScript
- **Database**: MySQL with Prisma ORM
- **Authentication**: SSO-based (corporate identity provider)
- **Frontend**: Responsive web (mobile + desktop)
- **External APIs**: HR/PTO, Holiday data, Messenger bot, Room reservation, Calendar

## Core Business Rules

### Meeting Request Lifecycle

1. Organizer creates request → status: IN_PROGRESS
2. Participants receive secure links via messenger
3. Participants mark unavailable time slots
4. System computes availability intersections
5. Organizer selects time slot + room
6. System confirms meeting → status: CONFIRMED

### Concurrency & Conflict Handling

- Room booking happens only at confirmation time
- Immediate retry with alternative rooms on conflicts
- Optimistic locking for meeting request updates
- Notification throttling (10-minute cooldown per recipient)

### Security & Access Control

- Organizer access requires SSO authentication
- Participant access via single-use, time-bounded tokens
- No PII logged; user IDs only for audit trails
- External API access follows least privilege principle

## Development Guidelines

### Code Organization

```
src/
├── controllers/     # HTTP request handlers
├── services/        # Business logic and agent implementations
├── models/          # Prisma database models
├── middleware/      # Auth, validation, error handling
├── utils/           # Shared utilities and helpers
├── types/           # TypeScript type definitions
└── config/          # Configuration management
```

### API Design Patterns

- RESTful resource naming with kebab-case URLs
- Consistent JSON response format with data wrapper
- Standard error model: `{ error: { code, message, trace_id } }`
- Request/response DTOs for all API boundaries
- Snake_case for JSON field naming

### Data Modeling Principles

- All tables include: id, created_at, updated_at
- Foreign key constraints with proper indexing
- Soft deletes for audit trail, hard deletes after retention
- UTC timestamps with timezone conversion in service layer
- Optimistic locking via version fields

### Testing Strategy

- Unit tests for business logic and utilities
- Integration tests for API endpoints with database
- E2E tests for complete user flows
- Load tests for concurrent scenarios
- Mocked external APIs for reliable testing

## Common Implementation Patterns

### Token Generation for Participants

```typescript
// Generate secure, time-bounded tokens
const token = jwt.sign(
  { requestId, participantId, expiresAt },
  process.env.PARTICIPANT_TOKEN_SECRET,
  { expiresIn: "7d" },
);
```

### Availability Calculation

```typescript
// Negative selection: default AVAILABLE, mark UNAVAILABLE
const businessHours = generateBusinessHours(startDate, endDate);
const unavailable = await getParticipantUnavailable(participantId);
const available = businessHours.filter((slot) => !unavailable.includes(slot));
```

### Room Booking with Retry

```typescript
// Synchronous booking with immediate conflict handling
try {
  const reservation = await roomApi.book(roomId, startTime, endTime);
  await createCalendarEvent(meetingDetails);
  await updateMeetingStatus(requestId, "CONFIRMED");
} catch (conflict) {
  // Return alternative rooms to organizer
  const alternatives = await findAvailableRooms(startTime, endTime);
  throw new RoomBookingError(alternatives);
}
```

## Integration Patterns

### External API Communication

- **HR/PTO API**: Batch sync with exponential backoff
- **Room Booking API**: Synchronous with immediate retry
- **Calendar API**: Async event creation with webhooks
- **Messenger API**: Fire-and-forget with delivery tracking

### Error Handling

- Use standard error codes for common scenarios
- Implement circuit breakers for external APIs
- Log business events with correlation IDs
- Provide fallback behaviors for non-critical failures

### Monitoring & Observability

- Track business metrics: response rates, time-to-confirm
- Monitor technical metrics: API latency, error rates
- Log structured events with request tracing
- Alert on booking conflicts and response timeouts

## Success Verification

The MVP is successful when:

1. Organizer can create multi-participant requests
2. Participants can easily mark unavailable times via mobile
3. System accurately computes availability intersections
4. Room booking integrates seamlessly with confirmation
5. End-to-end flow completes within 1 hour (vs 1+ day manually)

Focus on reducing communication overhead and providing a unified scheduling experience that transforms the current fragmented process into a single, streamlined flow.
