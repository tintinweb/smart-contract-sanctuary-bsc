//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interface/ITaskControl.sol";

contract TaskControl is ITaskControl {
    address public taskRegistry;
    address public owner;
    constructor(address _taskRegistry) {
        taskRegistry = _taskRegistry;
        owner = msg.sender;
    }

    struct AssignTask {
        bool owned;
        bool inProgress;
        bool done;
        bool penalized;
        bool canceled;
        bool waitingForApproval;
    }

    mapping(address => uint256[]) public tasksByUser;
    mapping(address => mapping(uint256 => AssignTask)) public assignTask;

    function receiveTask(address user, uint256 taskID) public override onlyTaskContract {
        tasksByUser[user].push(taskID);
        assignTask[user][taskID].owned = true;
        assignTask[user][taskID].inProgress = true;
    }

    function finishTask(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].inProgress = false;
        assignTask[user][taskID].waitingForApproval = true;
    }

    function penalizeTask(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].inProgress = false;
        assignTask[user][taskID].penalized = true;
    }

    function cancelTask(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].inProgress = false;
        assignTask[user][taskID].canceled = true;
    }

    function approveTask(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].inProgress = false;
        assignTask[user][taskID].done = true;
    }

    function resetTask(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].canceled = false;
        assignTask[user][taskID].penalized = false;
        assignTask[user][taskID].owned = false;
    }

    function forceDone(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].inProgress = false;
        assignTask[user][taskID].done = true;
    }

    function setAssignee(address user, uint256 taskID) public override onlyTaskContract {
        assignTask[user][taskID].owned = true;
        assignTask[user][taskID].inProgress = true;
    }

    function getTasksByStatus(
        address user,
        uint256 status,
        uint256 cursor,
        uint256 quantity
    )
        public
        view
        override
        returns (uint256[] memory _values, uint256 newCursor)
    {
        require(quantity <= 200);
        uint256[] memory _tasksByUser = tasksByUser[user];
        if (quantity > _tasksByUser.length - cursor) {
            quantity = _tasksByUser.length - cursor;
        }
        uint256[] memory values = new uint256[](quantity);
        uint256 count = 0;
        for (uint256 i = 0; i < quantity; i++) {
            if (status == 0) {
                if (assignTask[user][_tasksByUser[cursor + i]].owned) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            } else if (status == 1) {
                if (
                    assignTask[user][_tasksByUser[cursor + i]].owned &&
                    assignTask[user][_tasksByUser[cursor + i]].inProgress
                ) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            } else if (status == 2) {
                if (
                    assignTask[user][_tasksByUser[cursor + i]].owned &&
                    assignTask[user][_tasksByUser[cursor + i]].done
                ) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            } else if (status == 3) {
                if (
                    assignTask[user][_tasksByUser[cursor + i]].owned &&
                    assignTask[user][_tasksByUser[cursor + i]].penalized
                ) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            } else if (status == 4) {
                if (
                    assignTask[user][_tasksByUser[cursor + i]].owned &&
                    assignTask[user][_tasksByUser[cursor + i]].canceled
                ) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            } else if (status == 5) {
                if (
                    assignTask[user][_tasksByUser[cursor + i]].owned &&
                    assignTask[user][_tasksByUser[cursor + i]]
                        .waitingForApproval
                ) {
                    values[count] = _tasksByUser[cursor + i];
                    count++;
                }
            }
        }
        return (values, cursor + quantity);
    }

    function getTasksByUser(
        address user,
        uint256 cursor,
        uint256 quantity
    )
        public
        view
        override
        returns (uint256[] memory _values, uint256 newCursor)
    {
        require(quantity < 100);
        uint256[] memory _tasksByUser = tasksByUser[user];
        if (quantity > _tasksByUser.length - cursor) {
            quantity = _tasksByUser.length - cursor;
        }

        uint256[] memory values = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            values[i] = _tasksByUser[cursor + i];
        }

        return (values, cursor + quantity);
    }

    function setTaskRegistry(address newAddress) public onlyOwner {
        taskRegistry = newAddress;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyTaskContract {
        require(msg.sender == taskRegistry);
        _;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITaskControl {
    function receiveTask(address user, uint256 taskID) external;

    function finishTask(address user, uint256 taskID) external;

    function penalizeTask(address user, uint256 taskID) external;

    function cancelTask(address user, uint256 taskID) external;

    function approveTask(address user, uint256 taskID) external;

    function resetTask(address user, uint256 taskID) external;

    function forceDone(address user, uint256 taskID) external;
    
    function setAssignee(address user, uint256 taskID) external;

    function getTasksByStatus(
        address user,
        uint256 status,
        uint256 cursor,
        uint256 quantity
    ) external view returns (uint256[] memory taskIds, uint256 newCursor);

    function getTasksByUser(
        address user,
        uint256 cursor,
        uint256 quantity
    ) external view returns (uint256[] memory values, uint256 newCursor);
}