// --------------------------------------------------------------------------------------------------------------------
// TopMenuModule
// --------------------------------------------------------------------------------------------------------------------
##CPP-HEADER
#include "CommonStateManager.h"
#include "BroadcastManager.h"

// --------------------------------------------------------------------------------------------------------------------

mx_bool TopMenuModuleIsOpen();

void TopMenuModuleOpen();

void TopMenuModuleClose();

mx_bool TopMenuModuleUpdate();

void TopMenuModuleEventProcess();

void TopMenuModulePostProcess();

// --------------------------------------------------------------------------------------------------------------------
##CPP-SRC
//include GUIObject header file.
#include "ButtonGroupControl.h"

mx_bool TopMenuModulePhaseReadyUpdate();

mx_bool TopMenuModulePhaseCloseUpdate();

mx_bool TopMenuModulePhaseOpenUpdate();

// State Phase
const int STATE_PHASE_READY         = STATE_PHASE_USER + 0;
const int STATE_PHASE_CLOSE         = STATE_PHASE_USER + 1;
const int STATE_PHASE_OPEN          = STATE_PHASE_USER + 2;

// Member
static StateRecord mState;

/*********************************************************************************************************************
 * Returns true if A has been opened.
 *********************************************************************************************************************/
mx_bool TopMenuModuleIsOpen()
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
void TopMenuModuleOpen()
{
	StateInitialize(&mState, STATE_PHASE_OPEN);
}

/*********************************************************************************************************************
 * Close lower module
 *********************************************************************************************************************/
void TopMenuModuleClose()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		StateSetPhase(&mState, STATE_PHASE_CLOSE);
	}
}

/*********************************************************************************************************************
 * Update lower module
 * Returns true if Module has been closed.
 *********************************************************************************************************************/
mx_bool TopMenuModuleUpdate()
{
	while (true) {
		switch (StateGetPhase(&mState)) {
			case STATE_PHASE_READY:
				if (TopMenuModulePhaseReadyUpdate()) {
					continue;
				}
				return true;
			
			case STATE_PHASE_CLOSE:
				if (TopMenuModulePhaseCloseUpdate()) {
					continue;
				}
				break;

			case STATE_PHASE_OPEN:
				if (TopMenuModulePhaseOpenUpdate()) {
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
mx_bool TopMenuModulePhaseReadyUpdate()
{
	return false;
}

/*********************************************************************************************************************
 * Update lower module(STATE_PHASE_CLOSE)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool TopMenuModulePhaseCloseUpdate()
{
	switch(StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Deactivate control
			ControlDeactivate(ScoreNum(top_menu));
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Wait until control is deactivated and transition to ready state
			if (ButtonGroupControlIsActivated(ScoreNum(top_menu)) == false) {
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
mx_bool TopMenuModulePhaseOpenUpdate()
{
	switch (StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Activate control
			ControlActivate(ScoreNum(top_menu));
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
void TopMenuModuleEventProcess()
{
}

/*********************************************************************************************************************
 * Post process
 *********************************************************************************************************************/
void TopMenuModulePostProcess()
{
}
// --------------------------------------------------------------------------------------------------------------------