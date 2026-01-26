# Ruler (Project Rules) - BookingTime Scheduling System

This project uses https://github.com/intellectronica/ruler.

## BookingTime-Specific Rules

### Business Logic Constraints

- **Negative Selection Model**: Default availability 09:00-18:00 weekdays, participants only mark UNAVAILABLE
- **Time Slot Resolution**: 30-minute minimum granularity for availability
- **Concurrent Booking**: Room reservation happens only at final confirmation with retry logic
- **Response Tokens**: Single-use, time-bounded tokens for participant access
- **Notification Throttling**: Minimum 10-minute cooldown between reminders to same participant

### Data Model Rules

- All time fields stored in UTC with timezone conversion in service layer
- Meeting request status must progress: CREATED → IN_PROGRESS → CONFIRMED → CANCELLED
- Required participants cannot be excluded from availability calculations
- Room booking failures must rollback confirmed meeting state

## Coding Style

- Prefer small, testable functions.
- Keep files focused (one primary responsibility per file).
- Avoid hidden side effects; pass dependencies explicitly.
- No type-safety suppression (no `as any`, no `@ts-ignore`).

## JSON / DTO

- JSON field naming: prefer `snake_case` across the project.
- DTOs are for I/O boundaries only (HTTP request/response, DB row). Keep them separate from domain models.
- Time fields use ISO 8601 format: `2024-01-15T14:30:00Z`
- Duration fields use minutes: `duration_min: 60`

## API Conventions

- URL: kebab-case, versioning is optional (`/v1/...` if introduced).
- Avoid verb-heavy paths (prefer resources like `/meeting-requests`, `/participants`).
- DTO naming: `CreateMeetingRequestRequest`, `MeetingRequestResponse`, `ParticipantAvailabilityResponse`.
- Success response: JSON object with data wrapper.

### Error Model

All error responses should follow a standard structure:

```json
{ "error": { "code": "STRING", "message": "STRING", "trace_id": "STRING" } }
```

Common error codes:

- `ROOM_UNAVAILABLE`: Room booking conflict at confirmation
- `TOKEN_EXPIRED`: Participant response link no longer valid
- `INVALID_TIME_RANGE`: Start/end times outside business hours
- `REQUIRED_PARTICIPANT_MISSING`: Cannot confirm without all required responses

## Logging / Observability

- Error logs MUST include: `trace_id`, `message`, `error_name`.
- Propagate a request identifier (`x-request-id`) end-to-end.
- Log business events: `meeting_request_created`, `participant_responded`, `meeting_confirmed`, `room_booked`.
- Never log availability grid contents (PII); log summary metrics only.

## Security Guidelines

- JWT is validated at Ingress, not in this app.
- User identity is trusted only behind Ingress/internal network.
- Participant access via secure tokens with expiration and single-use validation.
- Never log credentials, tokens, or PII.
- Do not commit secrets (keys/tokens/passwords).
- Minimal input validation at I/O boundaries.

## Auth (Ingress JWT assumption)

- App does not verify JWT.
- `src/middlewares/userContext.ts` reads headers:
  - `x-user-id`
  - `x-user-email`
  - `x-user-roles`
- The middleware stores the user on `req.user`.
- Participant access uses separate token validation middleware for response links.

## Integration Rules

### External API Patterns

- **HR/PTO API**: Batch sync with exponential backoff on failures
- **Room Booking API**: Synchronous with immediate retry on conflict
- **Calendar API**: Async event creation with webhook confirmation
- **Messenger API**: Fire-and-forget with delivery tracking

### Database Rules

- Use database transactions for multi-table operations (meeting confirmation)
- Optimistic locking on meeting requests (version field)
- Indexes on: `request_id`, `user_id`, `status`, `token`, `date_range`
- Soft deletes for audit trail, hard deletes after retention period
