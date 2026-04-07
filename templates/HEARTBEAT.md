---
name: heartbeat
description: Heartbeat configuration — defines when and how proactive checks run
---

# Heartbeat Configuration

## Schedule

- Morning briefing: {{BRIEFING_TIME}} {{TIMEZONE}}
- Quiet hours: 23:00–06:30 (do not send messages during quiet hours unless urgent)

## Behavior

Run heartbeat checks at configured intervals. Each installed skill pack defines its own heartbeat cycle — check them in order.

### Rules

- If all skill heartbeat checks return HEARTBEAT_OK, stay quiet.
- Never send empty briefings or status updates with no content.
- Batch related alerts into a single message rather than sending many small ones.
- Mark items as urgent only when they require action within 24 hours.
- For non-urgent items, queue them for the next morning briefing.
