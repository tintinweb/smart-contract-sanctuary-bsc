/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract TaskList  {

uint public TaskCounter = 0; 

struct TList {
    uint ID;
    string TaskDetail;
    bool TaskStatus;
}
mapping (uint => TList) public ToDo;

function addTask(string memory _TaskDetail) public {
    TaskCounter++;
    ToDo [TaskCounter] = TList(TaskCounter, _TaskDetail, false);
}
function getTask(uint _TaskCounter) public {
        ToDo [_TaskCounter].TaskStatus = !ToDo [_TaskCounter].TaskStatus;
    }

}