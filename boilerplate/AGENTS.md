# BookingTime Scheduling System - Agent Guidelines

## Agent Roles and Responsibilities

### Primary Agents

#### Organizer Agent

**Purpose**: Manages the meeting scheduling lifecycle from creation to confirmation.

**Core Functions**:

- Create meeting requests with participants, date ranges, and duration
- Monitor response rates and identify non-responders
- View aggregated availability intersections across required participants
- Select optimal time slots and meeting rooms
- Execute final confirmation with room booking and calendar registration
- Send targeted reminders to specific participants

**API Interactions**:

- `POST /meeting-requests` - Create new scheduling request
- `GET /meeting-requests` - List requests with filters
- `GET /meeting-requests/:id` - Request details and status
- `GET /meeting-requests/:id/availability` - Computed intersection availability
- `POST /meeting-requests/:id/remind` - Send reminders
- `POST /meeting-requests/:id/confirm` - Finalize meeting

#### Participant Agent

**Purpose**: Enables easy availability submission without full system access.

**Core Functions**:

- Access scheduling request via secure, time-bounded link
- View meeting details and required participants
- Mark unavailable time slots using negative selection model
- Submit availability with single action
- Receive confirmation and thank you acknowledgment

**API Interactions**:

- `GET /r/:token` - Retrieve request details and availability grid
- `POST /r/:token/response` - Submit unavailable time slots

### System Agents

#### Availability Calculator Agent

**Purpose**: Computes time slot intersections across multiple participants.

**Core Functions**:

- Aggregate individual participant availabilities
- Apply business rules (business hours, lunch breaks, holidays)
- Pre-block system-known unavailable times (PTO, weekends)
- Generate candidate time slots for organizer selection
- Handle edge cases (timezone conversions, partial responses)

#### Room Reservation Agent

**Purpose**: Manages meeting room booking with conflict resolution.

**Core Functions**:

- Check room availability for selected time slots
- Execute reservation with retry logic on conflicts
- Handle booking failures and provide alternatives
- Maintain reservation numbers and confirmation details
- Coordinate with calendar system for event creation

#### Notification Agent

**Purpose**: Handles all outbound communications through messenger system.

**Core Functions**:

- Generate notification payloads (text + URLs only)
- Enforce throttling rules (10-minute cooldown per recipient)
- Track delivery status and retry failed sends
- Support notification types: REQUEST, REMIND, CONFIRM
- Maintain audit trail of all communications

## Agent Coordination Protocols

### Meeting Creation Flow

1. **Organizer Agent** creates request via API
2. **System** generates participant tokens and sends notifications via **Notification Agent**
3. **Availability Calculator Agent** pre-processes known conflicts

### Response Collection Flow

1. **Participant Agent** submits availability via tokenized link
2. **System** validates token and updates participant status
3. **Availability Calculator Agent** recomputes intersections
4. **Organizer Agent** can view updated availability in real-time

### Confirmation Flow

1. **Organizer Agent** selects time slot and room
2. **Room Reservation Agent** attempts booking with retry logic
3. **System** creates calendar event and updates meeting status
4. **Notification Agent** sends confirmation to all participants
5. **Failure handling**: If room booking fails, return to organizer with alternatives

## Agent Error Handling

### Retry Strategies

- **Room Reservation**: Immediate retry with alternative rooms, then exponential backoff
- **External APIs**: Circuit breaker pattern with fallback to manual handling
- **Notifications**: Queue-based retry with dead letter handling

### Fallback Behaviors

- Room booking unavailable: Show conflict to organizer for manual resolution
- Calendar sync failure: Confirm meeting but flag for manual calendar entry
- Notification delivery failure: Log error but don't block main flow

### Monitoring and Alerts

- Track agent success/failure rates
- Alert on room booking conflicts > threshold
- Monitor participant response completion rates
- Log timing metrics for performance optimization

## Agent Testing Strategy

### Unit Tests

- Individual agent business logic validation
- Time zone handling and edge cases
- Token generation and validation
- Availability calculation algorithms

### Integration Tests

- Agent-to-agent communication flows
- External API integration with mocking
- End-to-end meeting lifecycle scenarios
- Error handling and recovery paths

### Load Tests

- Concurrent meeting request creation
- High-volume participant responses
- Room booking contention scenarios
- Notification throughput under load
