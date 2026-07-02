global class WorkPlanStepPropagator {

    @InvocableMethod(
        label='Propagate New Work Step to Existing Work Plans'
        description='Adds a new Work Step to all open Work Plans linked to a Work Plan Template'
        category='Field Service'
    )
    global static void propagateWorkStep(List<WorkPlanEntryInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            return;
        }

        // ── STEP 1: Collect all unique Work Plan Template Ids ──
        Set<Id> templateIds = new Set<Id>();
        for (WorkPlanEntryInput inp : inputs) {
            templateIds.add(inp.workPlanTemplateId);
        }

        // ── STEP 2: Get all eligible WorkPlan records ──
        List<WorkPlan> existingWorkPlans = [
            SELECT Id, WorkPlanTemplateId
            FROM WorkPlan
            WHERE WorkPlanTemplateId IN :templateIds
            LIMIT 10000
        ];

        if (existingWorkPlans.isEmpty()) {
            return;
        }

        // ── STEP 3: Build map of templateId → list of WorkPlan Ids ──
        Map<Id, List<Id>> templateToWorkPlanIds = new Map<Id, List<Id>>();
        for (WorkPlan wp : existingWorkPlans) {
            Id tmplId = wp.WorkPlanTemplateId;
            if (!templateToWorkPlanIds.containsKey(tmplId)) {
                templateToWorkPlanIds.put(tmplId, new List<Id>());
            }
            templateToWorkPlanIds.get(tmplId).add(wp.Id);
        }

        // ── STEP 4: Collect ALL WorkPlan Ids ──
        Set<Id> allWorkPlanIds = new Set<Id>();
        for (List<Id> ids : templateToWorkPlanIds.values()) {
            allWorkPlanIds.addAll(ids);
        }

        // ── STEP 5: Duplicate check query based on Name ──
        Set<String> allNames = new Set<String>();
        for (WorkPlanEntryInput inp : inputs) {
            allNames.add(inp.name);
        }

        List<WorkStep> existingSteps = [
            SELECT Id, WorkPlanId, Name
            FROM WorkStep
            WHERE WorkPlanId IN :allWorkPlanIds
            AND Name IN :allNames
        ];

        // ── STEP 6: Build O(1) lookup set for duplicate checking ──
        Set<String> existingCombos = new Set<String>();
        for (WorkStep ws : existingSteps) {
            existingCombos.add(ws.WorkPlanId + '|' + ws.Name);
        }

        // ── STEP 7: Build all new WorkStep records ──
        List<WorkStep> stepsToInsert = new List<WorkStep>();

        for (WorkPlanEntryInput inp : inputs) {
            List<Id> workPlanIds = templateToWorkPlanIds.get(inp.workPlanTemplateId);
            if (workPlanIds == null) continue;

            for (Id wpId : workPlanIds) {
                String comboKey = wpId + '|' + inp.name;
                if (existingCombos.contains(comboKey)) continue;

                WorkStep newStep = new WorkStep();
                newStep.WorkPlanId = wpId;
                newStep.Name = inp.name;
                newStep.ExecutionOrder = inp.executionOrder;
                newStep.Status = 'New';
                
                stepsToInsert.add(newStep);
            }
        }

        // ── STEP 8: Bulk Insert ──
        if (!stepsToInsert.isEmpty()) {
            insert stepsToInsert;
        }
    }
}