# Epic 2: Smart Triage System

**Epic Goal**: Implement intelligent case assessment system using proven Veterinary Triage List protocols with guided intake forms that help staff accurately evaluate case complexity and urgency for optimal specialist routing.

## Story 2.1: VTL Protocol Implementation
As a veterinary practice staff member,
I want standardized triage protocols built into the system,
so that I can consistently and accurately assess case urgency without relying on intuition.

**Acceptance Criteria**:
1. Veterinary Triage List (VTL) five-level system implemented (Red/Orange/Yellow/Green/Blue) with clear descriptions and criteria
2. ABCDE assessment protocol integrated (Airway, Breathing, Circulation, Disability, Environment) with guided evaluation steps
3. Six Perfusion Parameters assessment available (heart rate, pulse quality, mucous membrane color, capillary refill, temperature, blood pressure)
4. Triage decision logic implemented that combines multiple assessment factors into clear urgency recommendations
5. Override capability provided for veterinarian clinical judgment while maintaining audit trail of decisions
6. Triage results interface displays clear urgency level with supporting rationale and recommended timeframes

## Story 2.2: Guided Intake Questionnaire System
As a veterinary practice staff member,
I want intelligent questions that guide me to gather the right information,
so that I can identify case complexity and specialist needs without missing critical details.

**Acceptance Criteria**:
1. QuickForm integration creates dynamic questionnaire flows based on initial case information
2. Branching question logic adapts based on species, presenting symptoms, and preliminary urgency assessment
3. Smart question suggestions appear based on case type patterns and specialist matching requirements
4. Progress indicator shows completion status and estimated remaining questions for time management
5. Question validation prevents incomplete assessments and ensures all critical information is captured
6. Form state persistence allows interruption and resumption of intake process during busy periods

## Story 2.3: Case Complexity Scoring Algorithm
As a veterinary practice staff member,
I want automated analysis of case information,
so that the system can suggest appropriate specialists and priority levels based on medical evidence.

**Acceptance Criteria**:
1. Case complexity scoring algorithm analyzes symptoms, duration, species, and assessment results
2. Specialist requirement detection identifies potential need for surgery, internal medicine, dermatology, cardiology, etc.
3. Urgency vs. complexity matrix helps differentiate between emergency cases and complex routine cases
4. Machine learning foundation established to improve scoring accuracy based on outcome tracking
5. Transparency features explain scoring rationale to staff for educational value and confidence building
6. Manual score adjustment capability maintains clinical override while preserving automated recommendations
