// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function finiteStateMachine() constructor
{
	currentState = "None";
	prevState = currentState;
	transitionTimer = 0;
	transitionName = "None";
	stateMap = ds_map_create();
	
	/// @func setState(name)
	static setState = function(name)
	{
		prevState = currentState;
		currentState = name;
		stateMap[? currentState].startFunc();
	}
	
	/// @func addState(name, startFunc, stepFunc)
	static addState = function(_name, _startFunc, _stepFunc)
	{
		stateMap[? _name] = {
			name : _name,
			startFunc : _startFunc,
			stepFunc : _stepFunc,
			transitions : []
		}
	}
	
	/// @func addTransition(fromState, name, toState, switchStateCheck, timerFunc, startFunc)
	static addTransition = function(_fromState, _name, _toState, _switchStateCheck, _timerFunc, _startFunc)
	{
		var transition = {
			name : _name,
			fromState : _fromState,
			toState : _toState,
			switchStateCheck : _switchStateCheck,
			timerFunc : _timerFunc,
			startFunc : _startFunc
		}
		array_push(stateMap[? _fromState].transitions, transition);
	}
	
	static step = function()
	{
		var state = stateMap[? currentState];
		
		//Perform transition
		if (transitionTimer != 0)
		{
			transitionTimer -= sign(transitionTimer) * min(abs(transitionTimer), 1);
			if (transitionTimer == 0)
			{
				state.startFunc();
			}
		}
		
		//Only check for transitions if the transition timer is equal to or larger than 0. 
		//This effectively lets us "lock" the FSM in a state during a transition by setting the transition timer to a negative value
		if (transitionTimer >= 0)
		{
			var transitionNum = array_length(state.transitions);
			for (var i = 0; i < transitionNum; i ++)
			{
				var transition = state.transitions[i];
				if (transition.switchStateCheck())
				{
					setState(transition.toState);
					state = stateMap[? currentState];
					transition.startFunc();
					transitionTimer = transition.timerFunc();
					transitionName = transition.name;
					break;
				}
			}
		}
		
		//Perform step function
		state.stepFunc();
	}
}