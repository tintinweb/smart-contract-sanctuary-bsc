/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TodoList {
    address public owner;
    string public name = "Todo list";
    uint256 public taskCount;
    struct Task {
        uint256 id;
        string text;
        bool completed;
    }
    mapping(uint256 => Task) public tasks;

    event TaskCompleted(uint256 _id, string text, bool completed);
    event TaskCreated(uint256 _id, string text, bool completed);

    function createTask(string memory _text) public {
        taskCount++;
        tasks[taskCount] = Task(taskCount, _text, false);
        emit TaskCompleted(taskCount, _text, false);
    }

    function toggleTask(uint256 _id) public {
        Task memory _task = tasks[_id];
        _task.completed = true;
        tasks[_id] = _task;
        emit TaskCompleted(_id, _task.text, true);
    }
}