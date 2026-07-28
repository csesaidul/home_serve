# **1. Functional Requirements**

Each requirement is identified with a unique ID for traceability.
Priority is expressed as Must-Have (M), Should-Have (S), or Could-Have
(C), following the MoSCoW method.

## **1.1 Authentication & Account Management**

  --------------------------------------------------------------------------------
  **ID**      **Requirement Description**                           **Priority**
  ----------- ----------------------------------------------------- --------------
  **FR-01**   The system shall allow a new user to register with    M
              name, email, phone number, password, and a selected   
              role (Customer or Service Provider).                  

  **FR-02**   The system shall authenticate users via               M
              email/password and issue a JWT on successful login.   

  **FR-03**   The system shall enforce role-based access control    M
              (RBAC) at the API layer for Customer, Provider, and   
              Admin endpoints.                                      

  **FR-04**   The system shall store JWT tokens securely on-device  M
              using Flutter Secure Storage.                         

  **FR-05**   The system shall allow a user to log out,             S
              invalidating the local session token.                 
  --------------------------------------------------------------------------------

## **1.2 Customer Module**

  ----------------------------------------------------------------------------------
  **ID**        **Requirement Description**                           **Priority**
  ------------- ----------------------------------------------------- --------------
  **FR-C-01**   The system shall allow customers to search and browse M
                service providers by category, location, and rating.  

  **FR-C-02**   The system shall allow customers to view a            M
                provider\'s verified profile, skills, and past        
                reviews.                                              

  **FR-C-03**   The system shall allow customers to schedule a        M
                booking with date, time, and address details.         

  **FR-C-04**   The system shall show live booking status             M
                transitions: requested → accepted → en route →        
                completed.                                            

  **FR-C-05**   The system shall provide in-app chat between a        S
                customer and the assigned provider for an active      
                booking.                                              

  **FR-C-06**   The system shall display an upfront price estimate    M
                and allow completion of a simulated in-app payment.   

  **FR-C-07**   The system shall allow customers to rate and review a M
                provider after job completion.                        

  **FR-C-08**   The system shall allow customers to view full booking S
                history and rebook a previous provider.               
  ----------------------------------------------------------------------------------

## **1.3 Service Provider Module**

  ----------------------------------------------------------------------------------
  **ID**        **Requirement Description**                           **Priority**
  ------------- ----------------------------------------------------- --------------
  **FR-P-01**   The system shall allow providers to create a profile  M
                with skills, experience, and portfolio photos.        

  **FR-P-02**   The system shall allow providers to select service    M
                categories and set per-category pricing.              

  **FR-P-03**   The system shall allow providers to define working    S
                hours and day-to-day availability.                    

  **FR-P-04**   The system shall allow providers to receive and       M
                accept or reject incoming booking requests.           

  **FR-P-05**   The system shall allow providers to update live job   M
                status and share real-time location during an active  
                job.                                                  

  **FR-P-06**   The system shall allow providers to chat directly     S
                with the customer for job clarifications.             

  **FR-P-07**   The system shall provide providers an earnings        S
                dashboard with completed-job history.                 

  **FR-P-08**   The system shall build a provider reputation score    M
                from customer ratings and reviews.                    
  ----------------------------------------------------------------------------------

## **1.4 Admin Module**

  ----------------------------------------------------------------------------------
  **ID**        **Requirement Description**                           **Priority**
  ------------- ----------------------------------------------------- --------------
  **FR-A-01**   The system shall allow an Admin to review and approve M
                or reject new provider registrations.                 

  **FR-A-02**   The system shall allow an Admin to create and manage  M
                service categories and base pricing rules.            

  **FR-A-03**   The system shall allow an Admin to monitor platform   S
                analytics: bookings, active users, and revenue.       

  **FR-A-04**   The system shall allow an Admin to suspend or ban     M
                users/providers who violate policy.                   

  **FR-A-05**   The system shall allow an Admin to handle disputes    M
                and customer complaints.                              

  **FR-A-06**   The system shall allow an Admin to manage user        S
                accounts and role permissions.                        
  ----------------------------------------------------------------------------------

## **1.5 Real-Time Communication**

  -----------------------------------------------------------------------------------
  **ID**         **Requirement Description**                           **Priority**
  -------------- ----------------------------------------------------- --------------
  **FR-RT-01**   The system shall open a WebSocket connection per      S
                 active booking to stream chat messages and GPS        
                 coordinates.                                          

  **FR-RT-02**   The system shall persist chat history and last-known  S
                 provider location for reload/offline access.          

  **FR-RT-03**   If WebSocket delivery is not feasible within the      M
                 timeline, the system shall fall back to 5-second      
                 polling via GET /booking/{id}/location.               
  -----------------------------------------------------------------------------------

# **2. Non-Functional Requirements**

## **2.1 Performance**

-   API endpoints should respond within 2 seconds under normal demo load

-   Live location updates should propagate to the customer\'s screen
    within 5 seconds of a provider\'s position change (polling fallback)
    or near-instantly over WebSocket

## **2.2 Security**

-   Passwords shall be stored as salted hashes, never in plaintext

-   All API traffic shall be authenticated via JWT except public
    endpoints (registration, login, category browsing)

-   Role-based access control shall be enforced server-side, not only
    hidden in the UI

## **2.3 Usability**

-   The Customer and Provider apps shall use a consistent, simple
    navigation pattern suitable for users with limited technical
    literacy

-   Critical actions (booking, accepting a job, payment confirmation)
    shall require an explicit confirmation step

## **2.4 Reliability & Availability**

-   The system shall handle a dropped WebSocket connection gracefully by
    reverting to the polling fallback without crashing the app

-   Booking status shall never be lost --- every status transition shall
    be persisted to the database immediately

## **2.5 Scalability**

-   The relational schema and API design shall not preclude adding more
    service categories or provider volume after the MVP stage

## **2.6 Maintainability**

-   Code shall be organized by feature/module (auth, booking, chat,
    admin) to keep the 3-person team\'s work independent and mergeable

-   API contracts shall be documented and testable in Postman before
    Flutter integration

# **3. External Interface Requirements**

## **3.1 User Interfaces**

-   A single Flutter codebase rendering to both Android and Web, with
    role-based navigation via GoRouter

-   Wireframes and a shared component design system produced in Figma
    before screens are coded

## **3.2 Hardware Interfaces**

-   Device GPS sensor (for provider location sharing) and standard
    touchscreen/mouse-keyboard input

## **3.3 Software Interfaces**

-   FastAPI backend exposing REST (JSON) and WebSocket endpoints

-   MySQL database accessed via an ORM over SQL queries

-   Flutter Secure Storage for on-device token caching

## **3.4 Communication Interfaces**

-   HTTPS for all REST API calls

-   WebSocket (WSS) channels for live chat and location pings, with an
    HTTP polling fallback

# **4. Key Use Cases**

  ----------------------------------------------------------------------------
  **ID**      **Use Case**      **Actor**    **Description**
  ----------- ----------------- ------------ ---------------------------------
  **UC-01**   **Book a          Customer     Customer searches a category,
              Service**                      selects a verified provider, and
                                             schedules a booking with
                                             date/time/address.

  **UC-02**   **Accept a        Provider     Provider receives a booking
              Booking**                      request notification and accepts
                                             or rejects it.

  **UC-03**   **Track a Job     Customer     Customer views real-time status
              Live**                         and provider location for an
                                             active booking.

  **UC-04**   **Complete        Customer     Customer reviews the price
              Payment**                      estimate and completes a
                                             simulated in-app payment after
                                             job completion.

  **UC-05**   **Rate a          Customer     Customer submits a rating and
              Provider**                     review after a completed job.

  **UC-06**   **Approve a       Admin        Admin reviews a new provider\'s
              Provider**                     registration details and approves
                                             or rejects onboarding.

  **UC-07**   **Resolve a       Admin        Admin reviews a complaint tied to
              Dispute**                      a booking and takes an
                                             appropriate action (refund note,
                                             ban, warning).
  ----------------------------------------------------------------------------

# **5. Data Requirements --- Key Entities**

The following core MySQL tables (simplified) support the functional
requirements above.

  ------------------------------------------------------------------------------
  **Entity**               **Key Fields**             **Purpose**
  ------------------------ -------------------------- --------------------------
  **users**                id, name, email,           Stores customers,
                           password_hash, role, phone providers & admins (role
                                                      flag)

  **provider_profiles**    user_id, bio, skills,      Extended info for
                           verified, rating_avg       providers

  **service_categories**   id, name, icon, base_price Admin-managed list of
                                                      service types

  **bookings**             id, customer_id,           Tracks a single service
                           provider_id, category_id,  request lifecycle
                           status, scheduled_at       

  **reviews**              id, booking_id, rating,    Customer feedback tied to
                           comment                    a completed booking

  **messages**             id, booking_id, sender_id, Chat history per booking
                           content, sent_at           

  **location_pings**       id, booking_id, lat, lng,  Live location stream for
                           timestamp                  active jobs
  ------------------------------------------------------------------------------