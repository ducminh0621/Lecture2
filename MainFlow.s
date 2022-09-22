// --------------------------------------------------------------------------------------------------------------------
// Main Flow
// --------------------------------------------------------------------------------------------------------------------
##CPP-HEADER
#include "FrameworkBuildOption.h"
#include "CommonBasicFunction.h"
#include "CommonStateManager.h"
#include "BroadcastManager.h"

void MainFlowInitialize();

void MainFlowUpdate();

void MainFlowEventProcess();

void MainFlowPostProcess();

// State Phase
const int STATE_PHASE_TOP               = STATE_PHASE_USER + 0;

// --------------------------------------------------------------------------------------------------------------------
##CPP-SRC
//TODO include upper module header file.
#include "TopModule.h"
#include "CommonModule.h"
mx_bool MainFlowPhaseTopUpdate();

// State Step
const int STATE_STEP_CLOSE               = STATE_STEP_USER + 1;
const int STATE_STEP_CLOSE_POST_PROCESS  = STATE_STEP_USER + 2;

// Member
static StateRecord mState;

/*********************************************************************************************************************
 * Initialize flow
 *********************************************************************************************************************/
void MainFlowInitialize()
{
	//TODO Call open of common upper module

	StateInitialize(&mState, STATE_PHASE_Top);
}

/*********************************************************************************************************************
 * Update flow
 *********************************************************************************************************************/
void MainFlowUpdate()
{
	// Clear Broadcast Event
	BroadcastClear();
	
	while(true) {
		//TODO Call update of common upper module
        CommonModuleUpdate();
		switch(StateGetPhase(&mState)) {
			case STATE_PHASE_Top:
				if (MainFlowPhaseTopUpdate()) {
					continue;
				}
				break;

			default:
				break;
		}
		break;
	}
	
	// Event Process
	MainFlowEventProcess();
}

/*********************************************************************************************************************
 * Update flow(STATE_PHASE_Top)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool MainFlowPhaseTopUpdate()
{
	switch (StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//TODO Open upper module
			TopModuleOpen();
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//TODO Update upper module
			TopModuleUpdate();
			break;
			
		case STATE_STEP_CLOSE:
			//TODO Close upper module
			TopModuleClose();
			StateSetStep(&mState, STATE_STEP_CLOSE_POST_PROCESS);
			return true;
			
		case STATE_STEP_CLOSE_POST_PROCESS:
			//TODO Wait until upper module is closed and transition to next phase
			if (TopModuleUpdate()) {
			//	//TODO Next Phase Process
			}
			break;

		default:
			break;
	}
	return false;
}

/*********************************************************************************************************************
 * Event process
 *********************************************************************************************************************/
void MainFlowEventProcess()
{
	//TODO Call event processing of common upper module
    CommonModuleEventProcess();
	switch (StateGetPhase(&mState)) {
		case STATE_PHASE_Top:
			//TODO Call event processing of upper module belonging to STATE_PHASE_Top
			TopModuleEventProcess();
			break;

		default:
			break;
	}
}

/*********************************************************************************************************************
 * Post process
 *********************************************************************************************************************/
void MainFlowPostProcess()
{
	//TODO Call post processing of common upper module
    CommonModulePostProcess();
	switch (StateGetPhase(&mState)) {
		case STATE_PHASE_Top:
			//TODO Call post processing of upper module belonging to STATE_PHASE_Top
			TopModulePostProcess();
			break;

		default:
			break;
	}
}

// --------------------------------------------------------------------------------------------------------------------
