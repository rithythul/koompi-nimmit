---
name: nimmit-education
description: Use for school and university operations — scheduling, curriculum planning, student progress, parent communication, exams, and content generation.
---

# Education Skill

Assist schools and educational institutions with teaching, administration, and communication. Adapt language and formality to the institution's culture.

## Heartbeat

When activated during a heartbeat cycle:

1. **Upcoming events?** Exams, holidays, parent meetings in next 7 days → flag and prepare
2. **Attendance concerns?** Students with >3 consecutive or >5/month absences → alert
3. **Overdue grades or reports?** Flag teachers or departments behind schedule
4. **Parent messages pending?** Draft responses for unanswered inquiries
5. **Content due?** Newsletters, announcements, social media posts scheduled
6. If nothing needs attention → `HEARTBEAT_OK`

## Scheduling

- **Academic calendar:** Maintain term dates, exam periods, holidays, events
- **Timetables:** Period allocation, room conflicts, teacher load balancing
- **Standard day:** Morning sessions + afternoon sessions, 40-50 min periods
- Flag conflicts automatically. No teacher double-booked, no room overlap.

## Curriculum & Lesson Planning

When asked to create a lesson plan:

```
Subject / Grade / Topic / Duration
Objectives (2-3 learning outcomes)
Activities:
  - Warm-up (5 min)
  - Instruction (20-25 min)
  - Practice (10 min)
  - Assessment (5 min)
Materials needed
Assessment method
```

Adapt to the curriculum framework the school follows. Ask if unclear.

## Student Progress

**Tracking:**
- Attendance: daily per class, monthly summaries
- Grades: per subject, per term, trend over time
- Flag: failing students, attendance drops, sudden grade changes

**Progress reports:** Per-student with grades, attendance, teacher notes. Keep factual — let teachers add subjective observations.

## Parent Communication

- Match the school's tone: some formal, some friendly. Ask if unsure.
- Always include: school name, date, clear purpose, action required, contact info
- Common needs: absence inquiry, meeting invitation, fee reminder, event announcement, progress update
- Respond within 24h to parent messages. Acknowledge immediately if answer needs time.

## Exam Workflows

- Generate exams matching the school's format with point values + answer key
- Balance difficulty: ~30% easy, ~50% medium, ~20% challenging
- Rubrics for essays/projects with clear criteria and weights
- Result processing: class averages, pass rates, distribution charts
- Flag students scoring <50% in 2+ subjects

## Content Generation

- Worksheets, quizzes, flash cards — match vocabulary to grade level
- Newsletters: keep to 1 page, lead with what parents need to know
- Social media: school events, achievements, enrollment info
- Announcements: clear, actionable, include dates and deadlines
