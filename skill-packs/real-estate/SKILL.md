```skill
---
name: real-estate
description: Use for real estate operations — listing management, client/lead pipelines, showing scheduling, contract handling, market analysis, transaction lifecycle, marketing, commission tracking, and compliance.
version: "0.1.0"
author: koompi
tags:
  - real-estate
  - listings
  - client-pipeline
  - contracts
  - showings
---

# Real Estate Operations Agent

Assist real estate professionals with the full transaction lifecycle — from lead capture to post-close follow-up. Manage listings, clients, showings, contracts, marketing, and compliance. Keep everything organized, timely, and actionable.

## Heartbeat

When activated during a heartbeat cycle:

1. **Listings needing attention?** Any active listings past 30 days without price adjustment review, stale photos, or expired status → flag with recommended action
2. **Follow-ups overdue?** Check lead pipeline and post-showing follow-ups — anything past 24h without contact → draft outreach
3. **Upcoming showings or deadlines?** Showings in next 48h without confirmation, or contract deadlines (inspection, appraisal, closing) within 72h → alert
4. **Pending transactions at risk?** Any deal with outstanding contingencies, missing documents, or approaching deadline → flag with status and next step
5. **New leads unworked?** Leads received without initial response within 5 minutes (hot) or 1 hour (warm) → draft immediate response
6. If nothing needs attention → `HEARTBEAT_OK`

## Listing Management

### Creating a Listing

Collect before going live:
- Property address, type (SFR, condo, townhome, multi-family, land, commercial)
- Bedrooms, bathrooms, square footage, lot size, year built
- Key features (garage, pool, renovations, views, HOA)
- Seller's motivation and timeline
- Listing price (based on CMA — see Market Analysis)
- Photography/videography scheduled date
- Disclosure documents received (Y/N)

### Listing Status Tracking

Track every listing through these stages:
```
COMING SOON → ACTIVE → SHOWING → UNDER CONTRACT → PENDING → SOLD
                                                          ↘ WITHDRAWN
                                                          ↘ EXPIRED
                                                          ↘ CANCELLED
```

For each active listing, maintain:
- Days on market (DOM)
- Number of showings
- Showing feedback summary
- Price adjustment history
- Online views/saves (if available)

### Price Adjustment Triggers

Review pricing when:
- 10+ showings, zero offers → price likely too high
- 0-2 showings in 14 days → price or marketing problem
- DOM exceeds area average by 50% → recommend adjustment
- Comparable sold below list → recalibrate

## Client & Lead Management

### Lead Pipeline Stages

```
NEW → CONTACTED → QUALIFYING → ACTIVE → UNDER CONTRACT → CLOSED → POST-CLOSE
                                                                  ↘ LOST (log reason)
```

### Lead Intake

Capture on first contact:
- Name, phone, email, preferred contact method
- Buyer or seller (or both)
- Timeline (immediate, 1-3 months, 3-6 months, exploring)
- Budget/price range
- Location preferences or property address (sellers)
- Lead source (referral, portal, sign call, open house, social media, sphere)
- Pre-approval status (buyers)

### Follow-Up Cadence

| Lead Temperature | First Contact | Follow-Up 2 | Follow-Up 3 | Ongoing |
|------------------|---------------|-------------|-------------|---------|
| Hot (ready now) | Within 5 min | Next day | Day 3 | Every 2-3 days |
| Warm (1-3 months) | Within 1 hour | Day 3 | Week 2 | Weekly |
| Nurture (3-6+ months) | Within 24 hours | Week 2 | Month 1 | Monthly |

Never let a lead go silent — if no response after 3 attempts across different channels, move to long-term nurture with monthly value touches.

### Buyer Qualification

Before first showing, confirm:
1. Pre-approval or proof of funds
2. Must-haves vs. nice-to-haves
3. Deal-breakers
4. Timeline and motivation
5. Other agents they're working with
6. Decision-makers (spouse, partner, family)

### Seller Consultation Prep

Before listing presentation:
1. CMA (see Market Analysis)
2. Suggested list price with rationale
3. Net sheet estimate
4. Marketing plan overview
5. Timeline to close (realistic)
6. Recommended repairs/staging

## Showing Management

### Scheduling

For each showing, record:
- Property address
- Date, time, duration
- Buyer name and agent (if applicable)
- Confirmation status (requested → confirmed → completed → no-show)
- Lockbox/access instructions
- Seller notification sent (Y/N)

### Pre-Showing Checklist (Seller's Agent)

- Seller notified 24h+ in advance
- Property clean, staged, lights on
- Pets secured, personal items stored
- Lockbox code current
- Showing instructions posted (shoes off, alarm code, etc.)

### Post-Showing Follow-Up

Within 24 hours of every showing:

**To buyer's agent:**
> "Thanks for showing [address]. Does your client have any feedback or interest in next steps?"

**To seller (after collecting feedback):**
> "Showing update for [address]: [buyer feedback summary]. [X] total showings this week. [Recommendation if any.]"

Track all feedback in a summary: positive comments, objections, price concerns, second-showing requests.

## Contracts & Documents

### Transaction Document Checklist

**Listing Side:**
- [ ] Listing agreement (signed)
- [ ] Seller disclosures (property condition, lead paint, HOA, natural hazards)
- [ ] MLS input sheet
- [ ] Photography/media release
- [ ] Marketing authorization

**Offer to Close:**
- [ ] Purchase agreement
- [ ] Earnest money receipt
- [ ] Counteroffers (if any)
- [ ] Inspection report
- [ ] Repair request / response
- [ ] Appraisal report
- [ ] Title commitment
- [ ] Loan approval / clear to close
- [ ] Closing disclosure (buyer and seller)
- [ ] Final walkthrough confirmation
- [ ] Closing statement (HUD-1 / settlement statement)
- [ ] Keys / access transfer

### Offer Review Template

When presenting or reviewing an offer:
```
OFFER SUMMARY — [Property Address]

Buyer: [Name]
Offer Price: $[amount] (vs. list: $[list price] — [%] of list)
Earnest Money: $[amount]
Financing: [Cash / Conventional / FHA / VA / Other]
Down Payment: [%]
Pre-Approval: [Yes/No — lender name]
Closing Date: [date] ([X] days from acceptance)

Contingencies:
- Inspection: [days]
- Appraisal: [Yes/No]
- Financing: [days]
- Sale of buyer's home: [Yes/No]

Seller Concessions Requested: $[amount] or [description]
Inclusions/Exclusions: [list]

AGENT ASSESSMENT:
Strength: [Strong / Moderate / Weak] — [reason]
Risk factors: [list]
Recommendation: [Accept / Counter / Reject] — [reasoning]
```

### Counteroffer Drafting

When drafting a counter, specify only what changes:
- Price adjustment and rationale
- Contingency timeline changes
- Concession modifications
- Closing date adjustment
- Any added/removed terms

Keep counters clean — change as few terms as possible to keep momentum.

## Market Analysis

### Comparable Market Analysis (CMA)

Pull 3-6 comparable properties:
- **Sold comps** (last 90 days, within 0.5 mile, similar size/type): primary weight
- **Active comps**: establishes current competition
- **Pending comps**: signals current market absorption
- **Expired/withdrawn**: shows price ceiling

For each comp, note:
- Address, sale price, price per sq ft
- DOM, concessions, condition adjustments
- How it differs from subject property

**Output format:**
```
CMA — [Subject Property Address]

Subject: [beds/baths, sq ft, year built, lot size, condition]

Sold Comps:
1. [Address] — $[price] ($[per sq ft]) — [DOM] days — [key differences]
2. ...
3. ...

Suggested Price Range: $[low] – $[high]
Recommended List Price: $[price]
Rationale: [2-3 sentences]
```

### Market Snapshot

Weekly or on-demand summary for a target area:
- Active inventory count
- Median list price and price per sq ft
- Average DOM
- Months of supply (inventory ÷ monthly closings)
- Price trend (up/flat/down vs. 30/90 days ago)
- Buyer vs. seller market indicator

## Transaction Lifecycle

### Stage Tracking

Every transaction moves through defined stages. Track dates and responsible parties:

```
1. LISTING SIGNED        [date] — Listing agreement executed
2. LISTED ON MLS         [date] — Active on MLS, syndication live
3. SHOWINGS              [date range] — Record count and feedback
4. OFFER RECEIVED        [date] — Log all offers
5. UNDER CONTRACT        [date] — Accepted offer, earnest money deposited
6. INSPECTION PERIOD     [date range] — Inspection scheduled, report received
7. REPAIR NEGOTIATION    [date] — Request sent, response received
8. APPRAISAL             [date] — Ordered, completed, value: $[amount]
9. LOAN APPROVAL         [date] — Clear to close received
10. FINAL WALKTHROUGH    [date] — Completed, issues: [none / list]
11. CLOSING              [date] — Signed, funded, recorded
12. POST-CLOSE           [date] — Keys delivered, follow-up scheduled
```

### Deadline Calendar

Maintain a rolling calendar of all active transaction deadlines:
- Inspection deadline
- Repair negotiation deadline
- Appraisal deadline
- Financing contingency deadline
- Title objection deadline
- Closing date
- Possession date

Flag anything within 72 hours. Alert immediately if a deadline will be missed.

## Marketing

### Listing Description Template

Structure:
1. **Hook** — one compelling sentence (view, location, feature)
2. **Highlights** — 3-5 key selling points
3. **Room-by-room** — only notable features, skip generic descriptions
4. **Outdoor/lot** — yard, garage, parking, neighborhood
5. **Close** — call to action, showing instructions

Rules:
- No ALL CAPS, no exclamation overload
- Avoid: "charming," "cozy" (reads as small), "must see" (lazy)
- Include: specific details (quartz counters, not "updated kitchen")
- Match tone to price point (luxury = refined, starter = inviting/practical)

### Social Media Posts

**New listing:**
> 🏠 Just Listed — [neighborhood], [city]
> [beds]bd / [baths]ba · [sq ft] sq ft
> [One standout feature]
> $[price] · Link in bio / DM for details

**Open house:**
> 🔑 Open House — [day], [time range]
> [address]
> [One reason to visit]
> No appointment needed. See you there!

**Just sold:**
> 🎉 SOLD — [address]
> [days on market] days · [at/above/below] asking
> Congrats to [buyer/seller — first names only if permitted]
> Thinking about your next move? Let's talk.

**Market update:**
> 📊 [Area] Market Update — [Month]
> [Key stat 1]
> [Key stat 2]
> [What this means for buyers/sellers in 1 sentence]

### Open House Checklist

**Before:**
- [ ] Signs out (directional + yard)
- [ ] Listing sheets printed
- [ ] Sign-in sheet or digital capture ready
- [ ] Property staged, clean, lights on
- [ ] Refreshments (optional)

**During:**
- Greet everyone, collect contact info
- Note serious buyers vs. neighbors
- Answer questions, don't oversell

**After (within 24h):**
- Enter all contacts into CRM
- Send follow-up to every attendee
- Report to seller (attendance, feedback, interest level)

## Client Communication

### Seller Weekly Update

Send every [agreed day]:
```
📋 WEEKLY UPDATE — [Property Address]

Showings This Week: [X]
Total Showings: [X]
Days on Market: [X]

Feedback Summary:
- [Theme 1]
- [Theme 2]

Online Activity: [views, saves, inquiries if available]

Market Context: [any relevant changes]

Recommendation: [Continue as-is / Adjust price / Refresh photos / Other]

Next Steps: [specific actions this week]
```

### Buyer Search Update

After a round of showings or new matches:
```
📋 PROPERTY UPDATE — [Buyer Name]

New Matches: [X] properties meeting your criteria
Showings Scheduled: [list with dates]
Off-Market Opportunities: [if any]

Market Note: [relevant trend — inventory, rates, competition]

Action Needed: [review these listings / confirm showing times / etc.]
```

### Nurture Sequences

For long-term leads not ready to transact:
- **Monthly:** Market update for their area of interest
- **Quarterly:** Home value estimate (sellers) or rate/affordability check (buyers)
- **Milestone:** Anniversary of purchase, birthday, holiday
- **Trigger:** Major market shift, rate change, new inventory in their criteria

Content adds value — never just "checking in."

## Commission Tracking

### Per-Transaction Record

```
Transaction: [address]
Close Date: [date]
Sale Price: $[amount]
Commission Rate: [%]
Gross Commission: $[amount]
Split (brokerage): [%] → Agent: $[amount] / Brokerage: $[amount]
Referral Fee: $[amount] (if applicable)
Transaction Fee: $[amount] (if applicable)
Net to Agent: $[amount]
```

### Annual Summary

Track rolling totals:
- Transactions closed (YTD)
- Total volume (YTD)
- Gross commission earned
- Net commission after splits/fees
- Average commission per transaction
- Pipeline value (pending transactions)
- Projected annual income based on current pace

## Compliance & Disclosures

### Required Disclosures (General — Verify Local Requirements)

- Agency disclosure (who you represent)
- Property condition disclosure
- Lead-based paint disclosure (pre-1978 homes)
- Natural hazard / environmental disclosures
- HOA disclosures and documents
- Material facts known to agent
- Fair housing compliance (never steer, never discriminate)

### Fair Housing — Non-Negotiable

Never reference or factor in:
- Race, color, national origin
- Religion
- Sex, gender identity, sexual orientation
- Familial status
- Disability
- Any other protected class under local law

In listing descriptions, marketing, and client communications — describe the **property**, never the **neighborhood demographics**.

### Record Retention

Maintain transaction files for the period required by your jurisdiction (commonly 3-7 years). Include:
- All signed documents
- All written communication
- Showing records
- Disclosure acknowledgments
- Commission agreements

## CRM Workflows

### Lead Source Tracking

Tag every lead with source:
- Portal (Zillow, Realtor.com, Redfin, etc.)
- Social media (specify platform)
- Sign call
- Open house
- Referral (from whom)
- Sphere of influence
- Past client
- Website / landing page
- Other (specify)

Track conversion rate by source quarterly. Double down on what works.

### Automated Triggers

Set up actions based on events:
- **New lead** → Immediate response + add to pipeline
- **Showing completed** → 24h follow-up task
- **Offer submitted** → Daily status check until resolved
- **Under contract** → Populate deadline calendar
- **Closing in 7 days** → Final walkthrough reminder + closing prep checklist
- **Closed** → Thank you gift + review request (30 days) + 1-year check-in

### Pipeline Review

Weekly review of all active leads and transactions:
- New leads added this week
- Leads advanced to next stage
- Leads gone cold (no activity 14+ days) → re-engage or archive
- Active transactions → status and next deadline
- Projected closings this month and next
```
