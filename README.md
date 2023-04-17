# PapaChallenge

Home Visit Service MVP Flowchart

```mermaid
---
title: Home Visit Service MVP
---
flowchart TD
    LP[Create Account or Login] -->|Create Account| CREATE_ACCOUNT_FORM
    LP[Create Account or Login] -->|Login| USER_DASHBOARD
    subgraph CREATE_ACCOUNT_FORM
        CAFORM("
        - First Name
        - Last Name
        - Email
        ")

    end
    CREATE_ACCOUNT_FORM --> USER_DASHBOARD
    USER_DASHBOARD -->|Pal Role| PAPA_PAL_TAB
    USER_DASHBOARD -->|Member Role| MEMBER_TAB
    subgraph PAPA_PAL_TAB
    PRD[["Displays: 
                Upcoming Visits:
                    Sort by:
                        - datetime desc (default)
                        - highest duration
                        - task difficulty
                Available Visits:
                    Sort by:
                        - datetime desc (default)
                        - highest duration
                        - task difficulty
                    Select a visit to fulfill
                Available Credits
     "]]
    end
    subgraph MEMBER_TAB
    MRD("Displays: 
                Request a visit button
                    Form contains:
                        - task (default duration)
                        - datetime
                        - estimated duration
                Available Credits
     ")
    end
    PAPA_PAL_TAB -->|Fulfills visit request| VISIT_FULFILLED_FORM
    MEMBER_TAB -->|Fulfills visit request| REQUEST_VISIT_FORM
    subgraph VISIT_FULFILLED_FORM
      VRFORM("
          - Duration (in minutes)
          ")

    end
    subgraph REQUEST_VISIT_FORM
      RVF("
          - Task(s)
          - Datetime
          ")
    end  
```

Post MVP Roadmap:

* do not allow Pals to select visits that overlap with another visit based on estimated duration and datetime
* password requirements
* forgot password
* 2FA / OTP
* RBAC
* more granular email validation
* admin dashboard to show metrics
  * visits this month
  * revenue to date
  * users
    * pals
    * members
  * top tasks
  * upcoming scheduled visits
  * most recently completed visits
* allow users to edit name and email
* allow users to upload avatar images
* require users to upload drivers license and selfie

  
To start this application:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Available APIs:

* /user
  * GET /user/<user_id>
  * GET /user/<user_id>/transactions
  * GET /user/<user_id>/visits
  * POST /user
  * POST /user/<user_id>
* /visit
  * GET  /visit/<visit_id>
  * POST /visit
  * POST /visit/<visit_id>
* /transaction
  * GET  /transaction/<transaction_id>
  * POST /transaction
  * POST /transaction/<transaction_id>
