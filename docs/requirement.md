> **Version:** 1.2
>
> **Created by:** [Akikul Haque Sajib](https://github.com/akikul-haque-sajib)
>
> **Reviewed by:** [Saidul Islam](https://github.com/csesaidul)
>
> **Updated by:** [Saidul Islam](https://github.com/csesaidul)
>
> **Last Updated:** 07-Aug-2026
>
> **Last Updates:** Updated Authentication flow and account profile related requirements, added 2FA, updated data requirements and key entities, added new use cases, updated non-functional requirements (by [Saidul Islam](https://github.com/csesaidul)).

# **1. Functional Requirements**

Each requirement is identified with a unique ID for traceability.
Priority is expressed as Must-Have (M), Should-Have (S), or Could-Have
(C), following the MoSCoW method.

## **1.1 Authentication & Account Management** *(Updated)*

| **ID** | **Requirement Description** | **Priority** |
|---|---|---|
| **FR-01** | The system shall allow a new user to register with phone number, name, gender, and password. No role shall be selected at registration — every new account is created as a plain, unverified Client by default. | M |
| **FR-02** | The system shall verify the registrant's phone number via a one-time password (OTP) sent through AWS SNS before the account becomes active. | M |
| **FR-03** | The system shall request location permission at the time of registration, so the account has an initial location on file from account creation. | M |
| **FR-04** | The system shall authenticate users via phone number + password and issue a JWT on successful login. | M |
| **FR-05** | The system shall allow a user to log in directly via phone number + OTP (via AWS SNS) as an alternative to password login (e.g., when the password is forgotten). | M |
| **FR-06** | The system shall request/refresh location access on every login, so nearby services can be shown based on the user's current location. | M |
| **FR-07** | The system shall re-sync the user's location during an active session if the user's position changes, so service search results stay current without requiring re-login. | S |
| **FR-08** | The system shall issue a JWT whose claims reflect the account's current capabilities (e.g., `client_verified`, `provider_verified`, `is_admin`) rather than a single fixed role, since one account may hold multiple capabilities simultaneously. | M |
| **FR-09** | The system shall enforce role/capability-based access control (RBAC) at the API layer for Client, Verified Client, Provider, and Admin endpoints, based on the dynamic capability claims in the JWT. | M |
| **FR-10** | The system shall store JWT tokens securely on-device using Flutter Secure Storage. | M |
| **FR-11** | The system shall allow a user to log out, invalidating the local session token. | S |
| **FR-12** | The system shall enforce a strong password policy at registration and password change (minimum length, complexity rules). | M |
| **FR-13** | The system shall allow a user to optionally enable two-factor authentication (2FA) from account settings for additional login security. | S |
| **FR-14** | The system shall require a user to complete Client Verification (submitting additional personal/security data — exact fields to be finalized) before hiring a provider for the first time. | M |
| **FR-15** | The system shall allow a user to apply to become a Service Provider by completing a Provider Profile (skills, category, pricing, portfolio) and submitting it for verification, without needing a separate account. | M |
| **FR-16** | The system shall store identity/security data collected during Client Verification and Provider Verification in a shared record, and reuse already-verified data so a user is not asked to resubmit the same information twice. | M |
| **FR-17** | The system shall route a submitted Provider Profile to Admin for approval before the account gains provider capability (see FR-A-01). | M |

## **1.2 Customer Module**

| **ID** | **Requirement Description** | **Priority** |
|---|---|---|
| **FR-C-01** | The system shall allow customers to search and browse service providers by category, location, and rating. | M |
| **FR-C-02** | The system shall allow customers to view a provider's verified profile, skills, and past reviews. | M |
| **FR-C-03** | The system shall allow customers to schedule a booking with date, time, and address details. | M |
| **FR-C-04** | The system shall show live booking status transitions: requested → accepted → en route → completed. | M |
| **FR-C-05** | The system shall provide in-app chat between a customer and the assigned provider for an active booking. | S |
| **FR-C-06** | The system shall display an upfront price estimate and allow completion of a simulated in-app payment. | M |
| **FR-C-07** | The system shall allow customers to rate and review a provider after job completion. | M |
| **FR-C-08** | The system shall allow customers to view full booking history and rebook a previous provider. | S |

## **1.3 Service Provider Module**

| **ID** | **Requirement Description** | **Priority** |
|---|---|---|
| **FR-P-01** | The system shall allow providers to create a profile with skills, experience, and portfolio photos. | M |
| **FR-P-02** | The system shall allow providers to select service categories and set per-category pricing. | M |
| **FR-P-03** | The system shall allow providers to define working hours and day-to-day availability. | S |
| **FR-P-04** | The system shall allow providers to receive and accept or reject incoming booking requests. | M |
| **FR-P-05** | The system shall allow providers to update live job status and share real-time location during an active job. | M |
| **FR-P-06** | The system shall allow providers to chat directly with the customer for job clarifications. | S |
| **FR-P-07** | The system shall provide providers an earnings dashboard with completed-job history. | S |
| **FR-P-08** | The system shall build a provider reputation score from customer ratings and reviews. | M |

## **1.4 Admin Module**

| **ID** | **Requirement Description** | **Priority** |
|---|---|---|
| **FR-A-01** | The system shall allow an Admin to review and approve or reject new provider profile submissions. | M |
| **FR-A-02** | The system shall allow an Admin to create and manage service categories and base pricing rules. | M |
| **FR-A-03** | The system shall allow an Admin to monitor platform analytics: bookings, active users, and revenue. | S |
| **FR-A-04** | The system shall allow an Admin to suspend or ban users/providers who violate policy. | M |
| **FR-A-05** | The system shall allow an Admin to handle disputes and customer complaints. | M |
| **FR-A-06** | The system shall allow an Admin to manage user accounts and capability permissions. | S |

## **1.5 Real-Time Communication**

| **ID** | **Requirement Description** | **Priority** |
|---|---|---|
| **FR-RT-01** | The system shall open a WebSocket connection per active booking to stream chat messages and GPS coordinates. | S |
| **FR-RT-02** | The system shall persist chat history and last-known provider location for reload/offline access. | S |
| **FR-RT-03** | If WebSocket delivery is not feasible within the timeline, the system shall fall back to 5-second polling via GET /booking/{id}/location. | M |

# **2. Non-Functional Requirements**

## **2.1 Performance**

- API endpoints should respond within 2 seconds under normal demo load
- Live location updates should propagate to the customer's screen within 5 seconds of a provider's position change (polling fallback) or near-instantly over WebSocket

## **2.2 Security** *(Updated)*

- Passwords shall be stored as salted hashes, never in plaintext, and shall meet a strong-password policy (minimum length and complexity) at creation
- Phone numbers shall be verified via OTP (AWS SNS) at registration; OTP shall also be usable as an alternative login method
- Users shall be able to optionally enable two-factor authentication (2FA) on their account
- All API traffic shall be authenticated via JWT except public endpoints (registration, OTP request/verify, login, category browsing)
- Role/capability-based access control shall be enforced server-side, not only hidden in the UI, based on dynamic JWT claims rather than a single static role field
- Identity/security data submitted for Client or Provider verification shall be stored once and shared between the two verification records to avoid duplicate collection and reduce exposure

## **2.3 Usability**

- The Customer and Provider apps shall use a consistent, simple navigation pattern suitable for users with limited technical literacy
- Critical actions (booking, accepting a job, payment confirmation, submitting verification data) shall require an explicit confirmation step

## **2.4 Reliability & Availability**

- The system shall handle a dropped WebSocket connection gracefully by reverting to the polling fallback without crashing the app
- Booking status shall never be lost — every status transition shall be persisted to the database immediately

## **2.5 Scalability**

- The relational schema and API design shall not preclude adding more service categories or provider volume after the MVP stage
- The dynamic-capability JWT model shall not preclude adding further account capabilities beyond Client/Provider/Admin in the future

## **2.6 Maintainability**

- Code shall be organized by feature/module (auth, booking, chat, admin) to keep the 3-person team's work independent and mergeable
- API contracts shall be documented and testable in Postman before Flutter integration

# **3. External Interface Requirements**

## **3.1 User Interfaces**

- A single Flutter codebase rendering to both Android and Web, with capability-based navigation via GoRouter
- Wireframes and a shared component design system produced in Figma before screens are coded

## **3.2 Hardware Interfaces**

- Device GPS sensor (for provider location sharing and customer location-based search) and standard touchscreen/mouse-keyboard input

## **3.3 Software Interfaces** *(Updated)*

- FastAPI backend exposing REST (JSON) and WebSocket endpoints
- MySQL database accessed via an ORM over SQL queries
- Flutter Secure Storage for on-device token caching
- AWS SNS for OTP delivery (registration verification, OTP login, and 2FA)

## **3.4 Communication Interfaces**

- HTTPS for all REST API calls
- WebSocket (WSS) channels for live chat and location pings, with an HTTP polling fallback

# **4. Key Use Cases** *(Updated)*

| **ID** | **Use Case** | **Actor** | **Description** |
|---|---|---|---|
| **UC-01** | **Book a Service** | Client | Client searches a category, selects a verified provider, and schedules a booking with date/time/address. |
| **UC-02** | **Accept a Booking** | Provider | Provider receives a booking request notification and accepts or rejects it. |
| **UC-03** | **Track a Job Live** | Client | Client views real-time status and provider location for an active booking. |
| **UC-04** | **Complete Payment** | Client | Client reviews the price estimate and completes a simulated in-app payment after job completion. |
| **UC-05** | **Rate a Provider** | Client | Client submits a rating and review after a completed job. |
| **UC-06** | **Approve a Provider** | Admin | Admin reviews a submitted provider profile and identity data, then approves or rejects provider capability. |
| **UC-07** | **Resolve a Dispute** | Admin | Admin reviews a complaint tied to a booking and takes an appropriate action (refund note, ban, warning). |
| **UC-08** | **Register & Verify Phone** | User | New user registers with phone/name/gender/password, grants location permission, and verifies the phone number via OTP. |
| **UC-09** | **Login (Password or OTP)** | User | Registered user logs in with phone + password, or phone + OTP if the password is forgotten; location is refreshed on login. |
| **UC-10** | **Complete Client Verification** | Client | Client submits required verification data the first time they attempt to hire a provider. |
| **UC-11** | **Apply as Service Provider** | Client | Client completes a provider profile/portfolio and submits identity data for admin approval, gaining provider capability alongside their existing client capability. |

# **5. Data Requirements — Key Entities** *(Updated)*

The following core MySQL tables (simplified) support the functional
requirements above.

| **Entity** | **Key Fields** | **Purpose** |
|---|---|---|
| **users** | id, name, gender, phone, phone_verified, password_hash, is_admin, twofa_enabled, last_known_lat, last_known_lng | Base account for every registered person. `is_admin` distinguishes internally-created Admin accounts; regular users are not assigned a fixed role — capabilities are tracked separately below. |
| **identity_verifications** | id, user_id, verification_type (client / provider / both), id_document, address_proof, emergency_contact, status, verified_at | Shared personal/security verification data, reused across client and provider verification so it is collected only once per user. |
| **client_profiles** | user_id, verified, verified_at | Marks a user as a verified Client once first-hire verification (FR-14) is complete; links to `identity_verifications`. |
| **provider_profiles** | user_id, bio, skills, categories, portfolio, verified, rating_avg | Extended info for users who have applied for and been approved for provider capability; links to `identity_verifications`. |
| **service_categories** | id, name, icon, base_price | Admin-managed list of service types |
| **bookings** | id, client_id, provider_id, category_id, status, scheduled_at | Tracks a single service request lifecycle |
| **reviews** | id, booking_id, rating, comment | Customer feedback tied to a completed booking |
| **messages** | id, booking_id, sender_id, content, sent_at | Chat history per booking |
| **location_pings** | id, booking_id, lat, lng, timestamp | Live location stream for active jobs |
| **otp_requests** | id, user_id, phone, purpose (registration / login / 2fa), code_hash, expires_at, verified | Tracks OTP issuance/verification via AWS SNS for registration, OTP login, and 2FA |

---

*Note: Client Verification (FR-14) fields are marked as TBD and should be finalized before database/API implementation begins.*