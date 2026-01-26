# BookingTime Scheduling System - Development Roadmap

## Overview

This roadmap outlines the development phases for implementing the BookingTime scheduling coordination system MVP v1, designed to reduce back-and-forth messaging for internal meeting scheduling through automated availability collection and room booking.

---

## Phase 1 - Foundation Setup (IN_PROGRESS)

**Goal**: Establish project infrastructure and core data models.

**Tasks**:

- Set up Express.js + TypeScript project structure
- Configure Prisma ORM with MySQL database
- Implement user context middleware for SSO integration
- Create base data models: meeting_requests, participants, time_slots, confirmed_meetings, notifications
- Set up basic health check endpoint
- Configure environment variables and logging infrastructure

**Verification**:

```bash
npm run build          # Verify TypeScript compilation
npm run db:migrate     # Verify database schema creation
npm run test:unit      # Run unit tests for models
curl http://localhost:3000/health  # Verify health endpoint
```

---

## Phase 2: Core Meeting Request API

**Goal**: Enable meeting request creation and participant management.

**Tasks**:

- Implement POST /meeting-requests endpoint
- Create meeting request validation and business logic
- Implement GET /meeting-requests with filtering support
- Create GET /meeting-requests/:id for request details
- Generate secure participant tokens with expiration
- Set up basic notification payload generation
- Implement participant invitation flow

**Verification**:

```bash
npm run test:integration  # Test meeting request CRUD operations
npm run test:e2e         # Test create request -> generate tokens flow
```

---

## Phase 3: Participant Response Interface

**Goal**: Build the participant availability submission system.

**Tasks**:

- Implement GET /r/:token endpoint for secure access
- Create availability grid UI (responsive mobile/desktop)
- Implement negative selection time slot marking
- Build POST /r/:token/response endpoint
- Add token validation and expiration logic
- Create thank you page and confirmation flow
- Implement availability aggregation service

**Verification**:

```bash
npm run test:e2e         # Test complete participant flow
npm run test:mobile      # Verify responsive design on mobile
```

---

## Phase 4: Availability Calculation & Intersection

**Goal**: Implement the core availability computation engine.

**Tasks**:

- Build Availability Calculator Agent
- Implement business hours filtering (09:00-18:00)
- Create holiday and weekend blocking logic
- Integrate HR/PTO API for leave data synchronization
- Implement intersection algorithm for required participants
- Add lunch break blocking (configurable)
- Create GET /meeting-requests/:id/availability endpoint

**Verification**:

```bash
npm run test:unit        # Test availability calculation edge cases
npm run test:integration # Test HR API integration
npm run verify:availability  # Test intersection accuracy with sample data
```

---

## Phase 5: Room Booking & Meeting Confirmation

**Goal**: Complete the meeting lifecycle with room reservation and calendar integration.

**Tasks**:

- Implement Room Reservation Agent with conflict handling
- Create room availability checking API integration
- Build POST /meeting-requests/:id/confirm endpoint
- Add calendar event creation (async with webhook confirmation)
- Implement reminder throttling and POST /meeting-requests/:id/remind
- Create confirmation notification system
- Add comprehensive error handling for booking failures

**Verification**:

```bash
npm run test:e2e         # Full end-to-end: create -> respond -> confirm
npm run test:room        # Test room booking conflict scenarios
npm run test:integration # Test calendar API integration
npm run verify:demo      # Run demo scenario from project description
```

---

## Success Criteria

The MVP is complete when the demo scenario works end-to-end:

1. Organizer creates request with participants/date range/duration ✓
2. Participant submits unavailable times via link + SSO ✓
3. Organizer sees response rate and non-responders ✓
4. System computes common availability for required participants ✓
5. Confirm triggers room reservation + calendar registration + notification ✓

---

## Future Enhancements (Post-MVP)

- AI-based time slot recommendations
- Natural language request creation
- External calendar integrations (Google, Outlook)
- Automatic room assignment optimization
- Mobile app for enhanced participant experience
