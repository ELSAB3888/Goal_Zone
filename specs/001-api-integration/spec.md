# Feature Specification: API Integration

**Feature Branch**: `[N/A]`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "راجع الخطه" (Integrate REST APIs into Goal Zone App based on the Postman Collection)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Authentication (Priority: P1)

As a user, I want to be able to register and log in to the application so that my data is securely saved and I can book stadiums.

**Why this priority**: Authentication is the foundation. Without it, users cannot be uniquely identified for their bookings, nor can they receive personalized data.

**Independent Test**: Can be fully tested by attempting to register a new account, and logging in with those credentials. Valid login should grant a session token.

**Acceptance Scenarios**:

1. **Given** I am on the login screen, **When** I enter valid credentials, **Then** I am authenticated and navigated to the Home Screen.
2. **Given** I am on the registration screen, **When** I provide valid new user details, **Then** my account is created and I am logged in.
3. **Given** I enter an invalid email or password, **When** I attempt to log in, **Then** I see an error message indicating invalid credentials.

---

### User Story 2 - Browsing Playgrounds (Priority: P1)

As a user, I want to see a real-time list of all available play grounds so that I can choose one to book.

**Why this priority**: Users need to see what is available before they can make a booking. This is the core offering of the application.

**Independent Test**: Can be fully tested by launching the app and observing the Home and Play Ground screens populated with real data from the server.

**Acceptance Scenarios**:

1. **Given** I am on the Home Screen, **When** the screen loads, **Then** I see the featured play grounds fetched from the live database.
2. **Given** I am on the Play Ground screen, **When** I search for "Ahly", **Then** the list filters based on the live data matching the query.

---

### User Story 3 - Making a Booking (Priority: P1)

As a user, I want to select a date and time to book a specific play ground so that I can secure my game time.

**Why this priority**: This is the primary business value of the application (booking a stadium).

**Independent Test**: Can be fully tested by selecting a stadium, picking an available time slot from the server, and confirming the booking.

**Acceptance Scenarios**:

1. **Given** I am viewing a specific play ground, **When** I select a date, **Then** the app queries the server and displays only the available time slots.
2. **Given** I have selected an available time slot, **When** I confirm the booking, **Then** the booking is created on the server and I see a success confirmation with a QR code.

---

### User Story 4 - Managing My Bookings (Priority: P2)

As a user, I want to view my upcoming and past bookings, and cancel or reschedule them if needed.

**Why this priority**: Enhances user experience by giving them control over their reservations.

**Independent Test**: Can be fully tested by navigating to the "My Bookings" screen and ensuring the lists (Upcoming, Completed, Cancelled) reflect the user's actual history from the server.

**Acceptance Scenarios**:

1. **Given** I have an upcoming booking, **When** I navigate to the My Bookings screen, **Then** I see the booking listed under the "Upcoming" tab.
2. **Given** I want to cancel a booking, **When** I click cancel and confirm, **Then** the status updates on the server and moves to the "Cancelled" tab.

### Edge Cases

- What happens when the user's internet connection drops during an API call?
- How does the system handle an expired authentication token (e.g., auto-logout)?
- What happens if two users try to book the exact same time slot simultaneously?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST communicate with the `https://goalzone-api.vercel.app/api` backend for all data operations.
- **FR-002**: System MUST securely store the user's JWT authentication token on the device for persistent login.
- **FR-003**: System MUST attach the authentication token as a Bearer token in the header of all protected API requests.
- **FR-004**: System MUST handle network timeouts and server errors gracefully, showing user-friendly error messages.
- **FR-005**: System MUST fetch available time slots dynamically from the server based on the selected date before allowing a booking.
- **FR-006**: System MUST allow users to cancel their bookings via the provided API endpoint.

### Key Entities

- **User**: Represents the authenticated person (ID, Name, Email, Role).
- **Playground**: Represents the stadium (ID, Name, Location, Price, Images).
- **Booking**: Represents a reservation (ID, UserID, PlaygroundID, Date, TimeSlot, Status).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of all mock data references (e.g., hardcoded stadiums) are removed from the application's source code.
- **SC-002**: API requests complete successfully with a 200/201 status code under normal network conditions.
- **SC-003**: Users are successfully prevented from booking a time slot that is already reserved (handled by backend, verified by app).
- **SC-004**: App successfully maintains a user's session across app restarts (persistent token).

## Assumptions

- The backend API (`https://goalzone-api.vercel.app/api`) is stable, running, and accessible from the mobile device.
- The `dio` package will be used for all HTTP networking.
- Error messages returned from the backend are sufficient for display to the user, or standard fallback messages will be used.
