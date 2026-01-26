# Project Description: BookingTime Scheduling Coordination System (MVP v1)

## Purpose

Reduce back-and-forth messaging for internal interview and multi-party meeting scheduling.
Collect availability automatically and provide a single flow from request creation to confirmation, room booking, and calendar registration.

Goals:
- Minimize communication cost (link-based responses + automatic aggregation)
- Improve time-to-confirm (manual 1+ day -> target within 1 hour)
- Unified UX (availability -> confirm -> book room -> calendar)

## Scope

### In scope (Phase 1 MVP)

Roles:
- Organizer: create scheduling request, monitor responses, send reminders, pick time/room, confirm
- Participant: open link (SSO), mark unavailable time only (negative selection), submit

Core policies and flow:
- Negative Selection: treat business hours (09:00-18:00) as AVAILABLE by default; participants only mark UNAVAILABLE
- System pre-blocks time it already knows:
  - PTO/leave from HR system
  - weekends/holidays from holiday calendar
  - lunch break (fixed policy or config)
- Response deadline: no forced timeout; the process ends when the organizer confirms
- Non-responders: not auto-excluded; organizer decides (remind or proceed without)
- Concurrency: on final confirm, call room reservation API
  - if room is taken at that moment, show error and return to room selection

Notifications:
- Internal messenger bot sends text + URL only (no in-app actions)
- Types: REQUEST / REMIND / CONFIRM
- Reminder throttling: do not allow re-sending to same person within 10 minutes (frontend disable + backend check)

UI / pages:
- Organizer
  - Dashboard: in-progress/completed requests, response rate cards, create new request
  - Detail/Confirm: participant status list, intersection availability list, room list, confirm
- Participant (Mobile/PC Web)
  - Response page: summary + time grid + submit
  - Thank you page

Data model (draft):
- meeting_requests: title, duration_min, start_date, end_date, organizer_id, status
- participants: request_id, user_id, is_required, response_status(PENDING/RESPONDED)
- time_slots: participant_id, slot_date, start_time, end_time, status(AVAILABLE/UNAVAILABLE/BLOCKED)
- confirmed_meetings: request_id, confirmed_start, confirmed_end, room_id, reservation_no
- notifications: request_id, recipient_id, type, sent_at

Demo/verification success criteria:
- Organizer can create a request with participants/date range/duration
- Participant can submit unavailable times via link + SSO
- Organizer can see response rate and non-responders
- System computes common availability (intersection) for required participants
- Confirm triggers room reservation + calendar registration + confirm notification (with failure recovery if room is taken)

### Out of scope (Phase 1)

- Messenger in-app buttons/forms
- Automatic exclusion of non-responders
- AI-based ranking/recommendations
- Natural-language request creation (chat prefill)
- External (public) calendar integrations
- Automatic room assignment optimization

## Non-functional Requirements

- Availability: internal MVP; HA is out of scope
- Performance: participant time grid must be responsive on mobile
- Security:
  - SSO required for participant access
  - link token must be validated and time-bounded and/or single-use
  - least privilege for HR/room/calendar integrations
- Observability:
  - log request creation, notifications, responses, confirmation, room booking failures

## Interfaces

Organizer API (draft):
- POST /meeting-requests
- GET /meeting-requests?status=IN_PROGRESS|DONE
- GET /meeting-requests/:id
- POST /meeting-requests/:id/remind
- GET /meeting-requests/:id/availability
- POST /meeting-requests/:id/confirm

Participant API (draft):
- GET /r/:token
- POST /r/:token/response

System:
- GET /health

Dependencies:
- Relational DB
- HR/PTO API
- Holiday data source
- Messenger bot API (text + URL)
- Room reservation API (availability + booking)
- Calendar API (event creation)
