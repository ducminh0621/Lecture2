// --------------------------------------------------------------------------------------------------------------------
// CommonModule
// --------------------------------------------------------------------------------------------------------------------
##CPP-HEADER
#include "CommonStateManager.h"
#include "BroadcastManager.h"

// --------------------------------------------------------------------------------------------------------------------

mx_bool CommonModuleIsOpen();

void CommonModuleOpen();

void CommonModuleClose();

mx_bool CommonModuleUpdate();

mx_bool CommonModulePhaseReadyUpdate();

mx_bool CommonModulePhaseCloseUpdate();

mx_bool CommonModulePhaseOpenUpdate();

void CommonModuleEventProcess();

void CommonModulePostProcess();

// --------------------------------------------------------------------------------------------------------------------
##CPP-SRC
//include lower module header file.
#include "CommonBgModule.h"

// State Phase
const int STATE_PHASE_READY         = STATE_PHASE_USER + 0;
const int STATE_PHASE_CLOSE         = STATE_PHASE_USER + 1;
const int STATE_PHASE_OPEN          = STATE_PHASE_USER + 2;

// Member
static StateRecord mState;

/*********************************************************************************************************************
 * Returns true if A has been opened.
 *********************************************************************************************************************/
mx_bool CommonModuleIsOpen()
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
void CommonModuleOpen()
{
	StateInitialize(&mState, STATE_PHASE_OPEN);
}

/*********************************************************************************************************************
 * Close upper module
 *********************************************************************************************************************/
void CommonModuleClose()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		StateSetPhase(&mState, STATE_PHASE_CLOSE);
	}
}

/*********************************************************************************************************************
 * Update upper module
 * Returns true if Module has been closed.
 *********************************************************************************************************************/
mx_bool CommonModuleUpdate()
{
	while (true) {
		switch (StateGetPhase(&mState)) {
			case STATE_PHASE_READY:
				if (CommonModulePhaseReadyUpdate()) {
					continue;
				}
				return true;
			
			case STATE_PHASE_CLOSE:
				if (CommonModulePhaseCloseUpdate()) {
					continue;
				}
				break;

			case STATE_PHASE_OPEN:
				if (CommonModulePhaseOpenUpdate()) {
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
mx_bool CommonModulePhaseReadyUpdate()
{
	return false;
}

/*********************************************************************************************************************
 * Update upper module(STATE_PHASE_CLOSE)
 * Returns true if Process is continue.
 *********************************************************************************************************************/
mx_bool CommonModulePhaseCloseUpdate()
{
	switch(StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Close lower module
			CommonBgModuleClose();
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Wait until lower module is closed and transition to ready state
			if (CommonBgModuleUpdate()) {
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
mx_bool CommonModulePhaseOpenUpdate()
{
	switch (StateGetStep(&mState)) {
		case STATE_STEP_INITIALIZE:
			//Open lower module
			CommonBgModuleOpen();
			StateSetStep(&mState, STATE_STEP_IDLE);
			return true;
		
		case STATE_STEP_IDLE:
			//Update lower module
			CommonBgModuleUpdate();
			break;
	}
	return false;
}

/*********************************************************************************************************************
 * Event process
 *********************************************************************************************************************/
void CommonModuleEventProcess()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		//Call lower module event process
		CommonBgModuleEventProcess();
	}
}

/*********************************************************************************************************************
 * Post process
 *********************************************************************************************************************/
void CommonModulePostProcess()
{
	if (StateGetPhase(&mState) == STATE_PHASE_OPEN) {
		//Call lower module post process
		CommonBgModulePostProcess();
	}
}

// --------------------------------------------------------------------------------------------------------------------
