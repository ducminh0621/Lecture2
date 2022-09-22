// --------------------------------------------------------------------------------------------------------------------
// TopModule
// --------------------------------------------------------------------------------------------------------------------
##CPP-HEADER
#include "CommonStateManager.h"
#include "BroadcastManager.h"

// --------------------------------------------------------------------------------------------------------------------

mx_bool TopModuleIsOpen();

void TopModuleOpen();

void TopModuleClose();

mx_bool TopModuleUpdate();

mx_bool TopModulePhaseReadyUpdate();

mx_bool TopModulePhaseCloseUpdate();

mx_bool TopModulePhaseOpenUpdate();

void TopModuleEventProcess();

void TopModulePostProcess();

// --------------------------------------------------------------------------------------------------------------------
##CPP-SRC
//include lower module header file.
#include "TopMenuModule.h"

// State Phase
const int STATE_PHASE_READY         = STATE_PHASE_USER + 0;
const int STATE_PHASE_CLOSE         = STATE_PHASE_USER + 1;
const int STATE_PHASE_OPEN          = STATE_PHASE_USER + 2;

// Member
static StateRecord mState;

/*********************************************************************************************************************
 * Returns true if A has been opened.
 *********************************************************************************************************************/
mx_bool TopModuleIsOpen()
{
	if (StateGetPhase(&mState) != STATE_PHASE_READY) {
		return true;
	}
	else {
		return false;
	}
}

/*********************************************************************************************************************
 * Open upper module
 *********************************************************************************************************************/
void TopModuleOpen()
{
	StateInitialize(&mState, STATE_PHASE_OPEN);
}

/*********************************************************************************************************************
 * Close upper module
 *********************************************************************************************************************/
void TopModuleClose()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		StateSetPhase(&mState, STATE_PHASE_CLOSE);
	}
}

/*********************************************************************************************************************
 * Update upper module
 * Returns true if Module has been closed.
 *********************************************************************************************************************/
mx_bool TopModuleUpdate()
{
	while (true) {
		switch (StateGetPhase(&mState)) {
			case STATE_PHASE_READY:
				if (TopModulePhaseReadyUpdate()) {
					continue;
				}
				return true;
			
			case STATE_PHASE_CLOSE:
				if (TopModulePhaseCloseUpdate()) {
					continue;
				}
				break;

			case STATE_PHASE_OPEN:
				if (TopModulePhaseOpenUpdate()) {
					continue;
				}
				break;
		}
		break;
	}
	return false;
}

/*********************************************************************************************************************
 * Update upper module(STATE_PHASE_READY)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool TopModulePhaseReadyUpdate()
{
	return false;
}

/*********************************************************************************************************************
 * Update upper module(STATE_PHASE_CLOSE)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool TopModulePhaseCloseUpdate()
{
	switch(StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Close lower module
			TopMenuModuleClose();
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Wait until lower module is closed and transition to ready state
			if (TopMenuModuleUpdate()) {
				StateSetPhase(&mState, STATE_PHASE_READY);
				return true;
			}
			break;
		break;
	}
	return false;
}

/*********************************************************************************************************************
 * Update upper module(STATE_PHASE_OPEN)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool TopModulePhaseOpenUpdate()
{
	switch (StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Open lower module
			TopMenuModuleOpen();
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Update lower module
			TopMenuModuleUpdate();
			break;
	}
	return false;
}

/*********************************************************************************************************************
 * Event process
 *********************************************************************************************************************/
void TopModuleEventProcess()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		//Call lower module event process
		TopMenuModuleEventProcess();
	}
}

/*********************************************************************************************************************
 * Post process
 *********************************************************************************************************************/
void TopModulePostProcess()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		//Call lower module post process
		TopMenuModulePostProcess();
	}
}

// --------------------------------------------------------------------------------------------------------------------
