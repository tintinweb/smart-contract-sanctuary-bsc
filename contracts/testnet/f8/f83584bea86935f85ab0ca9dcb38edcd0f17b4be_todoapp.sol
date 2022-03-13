/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract todoapp {

    uint public taskCount;

    struct task {
        uint ID;
        string content;
        bool completed;
    }

    mapping ( uint => task ) public tasks;

    event Taskcreated (
        uint ID,
        string content,
        bool completed
    );

    event TaskCompleted (
        uint ID,
        bool completed
    );

    function createtask( string memory _content ) public {

        taskCount++;
        tasks [taskCount] = task ( taskCount, _content, false );
        emit Taskcreated ( taskCount, _content, false );

    }

    function toggleCompleted( uint _ID ) public {

        task memory _task = tasks[ _ID ];
        _task.completed = !_task.completed;
        tasks[ _ID ] = _task;
        emit TaskCompleted ( _ID, _task.completed );

    }



}