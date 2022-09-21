/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TodoList {
  uint public taskCount = 0;
   address public owner;

  struct Task {
    uint id;
    string content;
    bool completed;
  }

  mapping(uint => Task) public tasks;

  event TaskCreated(
    uint id,
    string content,
    bool completed
  );

  event TaskCompleted(
    uint id,
    bool completed
  );

  constructor() {
       owner = msg.sender;
  }

  function createTask(string memory _content) public {
    taskCount ++;
    tasks[taskCount] = Task(taskCount, _content, false);
    emit TaskCreated(taskCount, _content, false);
  }

  function toggleCompleted(uint _id) public {
    Task memory _task = tasks[_id];
    _task.completed = !_task.completed;
    tasks[_id] = _task;
    emit TaskCompleted(_id, _task.completed);
  }
 /* fetches all tasks */
    function fetchTasks() public view returns (Task[] memory) {
        Task[] memory _tasks = new Task[](taskCount);
        for (uint i = 0; i < taskCount; i++) {
            uint currentId = i + 1;
            Task storage currentItem = tasks[currentId];
            _tasks[i] = currentItem;
        }
        return _tasks;
    }
    function fetchPost(uint id) public view returns(Task memory){
      return tasks[id];
    }

      /* this modifier means only the contract owner can */
    /* invoke the function */
    modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }
}