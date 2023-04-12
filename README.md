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
                Available Requested Visits
                    Sort by:
                        - datetime
                        - highest estimated duration
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

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
