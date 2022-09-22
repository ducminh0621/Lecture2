// --------------------------------------------------------------------------------------------------------------------
// CommonBgModule
// --------------------------------------------------------------------------------------------------------------------
##CPP-HEADER
#include "CommonStateManager.h"
#include "BroadcastManager.h"

// --------------------------------------------------------------------------------------------------------------------

mx_bool CommonBgModuleIsOpen();

void CommonBgModuleOpen();

void CommonBgModuleClose();

mx_bool CommonBgModuleUpdate();

void CommonBgModuleEventProcess();

void CommonBgModulePostProcess();

// --------------------------------------------------------------------------------------------------------------------
##CPP-SRC
//include GUIObject header file.
#include "PanelControl.h"

mx_bool CommonBgModulePhaseReadyUpdate();

mx_bool CommonBgModulePhaseCloseUpdate();

mx_bool CommonBgModulePhaseOpenUpdate();

// State Phase
const int STATE_PHASE_READY         = STATE_PHASE_USER + 0;
const int STATE_PHASE_CLOSE         = STATE_PHASE_USER + 1;
const int STATE_PHASE_OPEN          = STATE_PHASE_USER + 2;

// Member
static StateRecord mState;

/*********************************************************************************************************************
 * Returns true if A has been opened.
 *********************************************************************************************************************/
mx_bool CommonBgModuleIsOpen()
{
	if (StateGetPhase(&mState) != STATE_PHASE_READY) {
		return true;
	}
	else {
		return false;
	}
}

/*********************************************************************************************************************
 * Open lower module
 *********************************************************************************************************************/
void CommonBgModuleOpen()
{
	StateInitialize(&mState, STATE_PHASE_OPEN);
}

/*********************************************************************************************************************
 * Close lower module
 *********************************************************************************************************************/
void CommonBgModuleClose()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		StateSetPhase(&mState, STATE_PHASE_CLOSE);
	}
}

/*********************************************************************************************************************
 * Update lower module
 * Returns true if Module has been closed.
 *********************************************************************************************************************/
mx_bool CommonBgModuleUpdate()
{
	while (true) {
		switch (StateGetPhase(&mState)) {
			case STATE_PHASE_READY:
				if (CommonBgModulePhaseReadyUpdate()) {
					continue;
				}
				return true;
			
			case STATE_PHASE_CLOSE:
				if (CommonBgModulePhaseCloseUpdate()) {
					continue;
				}
				break;

			case STATE_PHASE_OPEN:
				if (CommonBgModulePhaseOpenUpdate()) {
					continue;
				}
				break;
		}
		break;
	}
	return false;
}

/*********************************************************************************************************************
 * Update lower module(STATE_PHASE_READY)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool CommonBgModulePhaseReadyUpdate()
{
	return false;
}

/*********************************************************************************************************************
 * Update lower module(STATE_PHASE_CLOSE)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool CommonBgModulePhaseCloseUpdate()
{
	switch(StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Deactivate control
			ControlDeactivate(ScoreNum(common_bg));
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Wait until control is deactivated and transition to ready state
			if (PanelControlIsActivated(ScoreNum(common_bg)) == false) {
				StateSetPhase(&mState, STATE_PHASE_READY);
				return true;
			}
			break;
		break;
	}
	return false;
}

/*********************************************************************************************************************
 * Update lower module(STATE_PHASE_OPEN)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool CommonBgModulePhaseOpenUpdate()
{
	switch (StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Activate control
			ControlActivate(ScoreNum(common_bg));
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			break;
	}
	return false;
}

/*********************************************************************************************************************
 * Event process
 *********************************************************************************************************************/
void CommonBgModuleEventProcess()
{
}

/*********************************************************************************************************************
 * Post process
 *********************************************************************************************************************/
void CommonBgModulePostProcess()
{
}
// --------------------------------------------------------------------------------------------------------------------