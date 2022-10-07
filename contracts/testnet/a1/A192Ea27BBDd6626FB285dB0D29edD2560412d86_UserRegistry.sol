//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "./interface/IUserRegistry.sol";

contract UserRegistry is IUserRegistry {
    address public owner;
    address public taskRegistry;
    address public projectRegistry;
    address public paymentRegistry;

    constructor() {
        owner = msg.sender;
    }

    struct Staff {
        uint256 completed;
        uint256 penalized;
        uint256 inProgress;
        uint256 earned;
        uint256 balance;
        bool working;
        mapping(uint256 => uint256) done;
        // Either completed or penalized
        mapping(uint256 => bool) taskByStaff;
    }

    struct ProductOwner {
        uint256 projects;
        mapping(uint256 => uint256) projectID;
        mapping(uint256 => bool) projectByPO;
    }
    //user address => projectID
    mapping(address => mapping(uint256 => Staff)) public accounts;
    mapping(address => ProductOwner) PO;
    mapping(address => string) walletName;

    function completeTask(
        address user,
        uint256 completeTaskID,
        uint256 projectID,
        uint256 reward
    )
        public
        override
        onlyContract
        returns (uint256 completedTasks, uint256 earned)
    {
        Staff storage _staff = accounts[user][projectID];

        uint256 _completedTasks = _staff.completed;
        if (_staff.taskByStaff[completeTaskID] == false) {
            _staff.taskByStaff[completeTaskID] = true;
            _completedTasks++;
            _staff.done[_completedTasks] = completeTaskID;
            _staff.completed = _completedTasks;
            _staff.inProgress = _staff.inProgress - 1;
        }
        uint256 earnedAmount = _staff.earned;
        earnedAmount += reward;
        _staff.earned = earnedAmount;

        emit TaskCompleted(user, completeTaskID);
        return (_completedTasks, earnedAmount);
    }

    function penalizeTask(
        address user,
        uint256 penalizeTaskID,
        uint256 projectID
    ) public override onlyContract returns (uint256 amount) {
        Staff storage _staff = accounts[user][projectID];
        require(_staff.taskByStaff[penalizeTaskID] == false, "Already existed");
        uint256 oldBalance = _staff.balance;
        _staff.balance = 0;
        _staff.taskByStaff[penalizeTaskID] = true;

        uint256 _penalizedTasks = _staff.penalized;
        _penalizedTasks++;
        _staff.penalized = _penalizedTasks;
        _staff.inProgress = _staff.inProgress - 1;

        emit BalanceChanged(user, 0, oldBalance);
        emit TaskPenalized(user, penalizeTaskID);
        return (_penalizedTasks);
    }

    function getCompletedTasks(address user, uint256 projectID)
        public
        view
        override
        returns (uint256[] memory taskIDs)
    {
        Staff storage _staff = accounts[user][projectID];
        uint256 completeTasks = _staff.completed;
        uint256[] memory _taskIDs = new uint256[](completeTasks + 1);
        for (uint256 i = 1; i <= completeTasks; i++) {
            _taskIDs[i] = _staff.done[i];
        }

        return _taskIDs;
    }

    function getPenalizedAmount(address user, uint256 projectID)
        public
        view
        override
        returns (uint256 amount)
    {
        return accounts[user][projectID].penalized;
    }

    function getInProgressTask(address user, uint256 projectID)
        public
        view
        override
        returns (uint256 howMany)
    {
        return accounts[user][projectID].inProgress;
    }

    function getEarnedAmount(address user, uint256 projectID)
        public
        view
        override
        returns (uint256 amount)
    {
        return accounts[user][projectID].earned;
    }

    function getStaffBalance(address user, uint256 projectID)
        public
        view
        override
        returns (uint256 balance)
    {
        return accounts[user][projectID].balance;
    }

    function checkStaffInProject(address user, uint256 projectID)
        public
        view
        override
        returns (bool)
    {
        return accounts[user][projectID].working;
    }

    function checkInProgressStaff(address user, uint256 projectID)
        public
        view
        override
        returns (uint256)
    {
        return accounts[user][projectID].inProgress;
    }

    function checkTaskByStaff(
        address user,
        uint256 projectID,
        uint256 taskID
    ) internal view returns (bool) {
        return accounts[user][projectID].taskByStaff[taskID];
    }

    function receiveTask(address user, uint256 projectID)
        public
        override
        onlyContract
    {
        Staff storage _staff = accounts[user][projectID];
        uint256 current = _staff.inProgress;
        _staff.inProgress = current + 1;
    }

    function taskCanceled(address user, uint256 projectID)
        public
        override
        onlyContract
    {
        Staff storage _staff = accounts[user][projectID];
        uint256 current = _staff.inProgress;
        _staff.inProgress = current - 1;
    }

    function setStaffIsWorking(
        address user,
        uint256 projectID,
        bool isWorking
    ) public override onlyContract {
        accounts[user][projectID].working = isWorking;
    }

    function setStaffBalance(
        address user,
        uint256 projectID,
        uint256 amount
    ) public override onlyContract {
        Staff storage _staff = accounts[user][projectID];
        uint256 oldBalance = _staff.balance;
        _staff.balance = amount;

        emit BalanceChanged(user, amount, oldBalance);
    }

    function getStaff(address user, uint256 projectID)
        public
        view
        override
        returns (
            uint256 completed,
            uint256[] memory tasksComplete,
            uint256 penalized,
            uint256 inProgress,
            uint256 earned,
            uint256 balance,
            bool isWorking
        )
    {
        Staff storage _staff = accounts[user][projectID];
        uint256 completeTasks = _staff.completed;
        uint256[] memory _taskIDs = new uint256[](completeTasks + 1);
        for (uint256 i = 1; i <= completeTasks; i++) {
            _taskIDs[i] = _staff.done[i];
        }
        return (
            _staff.completed,
            _taskIDs,
            _staff.penalized,
            _staff.inProgress,
            _staff.earned,
            _staff.balance,
            _staff.working
        );
    }

    function addProjectPO(address user, uint256 projectID)
        public
        override
        onlyContract
    {
        require(PO[user].projectByPO[projectID] == false, "Owned");
        ProductOwner storage _PO = PO[user];
        uint256 _projectIDs = _PO.projects;
        _projectIDs++;
        _PO.projectID[_projectIDs] = projectID;
        _PO.projectByPO[projectID] = true;
    }

    function POLeaveProject(address user, uint256 projectID)
        public
        override
        onlyContract
    {
        require(PO[user].projectByPO[projectID] == true, "Not owner");
        ProductOwner storage _PO = PO[user];
        _PO.projectByPO[projectID] = false;
    }

    function getPO(address user)
        public
        view
        override
        returns (uint256 amount, uint256[] memory projectIDs)
    {
        ProductOwner storage _PO = PO[user];
        uint256 _projects = _PO.projects;
        uint256[] memory _projectIDs = new uint256[](_projects + 1);
        for (uint256 i = 1; i <= _projects; i++) {
            _projectIDs[i] = _PO.projectID[i];
        }
        return (_projects, _projectIDs);
    }

    function changeWalletName(
        address user,
        string memory name,
        uint256 projectID
    ) public override {
        require(
            PO[msg.sender].projectByPO[projectID] == true ||
                msg.sender == projectRegistry
        );
        walletName[user] = name;
    }

    function getWalletName(address user)
        public
        view
        override
        returns (string memory name)
    {
        return walletName[user];
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyContract() {
        require(
            msg.sender == taskRegistry ||
                msg.sender == projectRegistry ||
                msg.sender == paymentRegistry
        );
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setTaskRegistry(address _taskRegistry) public onlyOwner {
        taskRegistry = _taskRegistry;
    }

    function setProjectRegistry(address _projectRegistry) public onlyOwner {
        projectRegistry = _projectRegistry;
    }

    function setPaymentRegistry(address _paymentRegistry) public onlyOwner {
        paymentRegistry = _paymentRegistry;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IUserRegistry {
    /// @notice Emitted when a task is completed by a user
    /// @param user User address
    /// @param completeTaskID ID of the completed task
    event TaskCompleted(address indexed user, uint256 indexed completeTaskID);

    /// @notice Emitted when a task is penalized
    /// @param user User address
    /// @param penalizeTaskID ID of the penalized task
    event TaskPenalized(address indexed user, uint256 indexed penalizeTaskID);

    /// @notice Emitted when a user balance is changed
    /// @param user User address
    /// @param newBalance User new balance amount
    /// @param oldBalance User old balance amount
    event BalanceChanged(
        address indexed user,
        uint256 indexed newBalance,
        uint256 indexed oldBalance
    );

    function completeTask(
        address user,
        uint256 completeTaskID,
        uint256 projectID,
        uint256 reward
    ) external returns (uint256 completedTasks, uint256 earned);

    function penalizeTask(
        address user,
        uint256 penalizeTaskID,
        uint256 projectID
    ) external returns (uint256 amount);

    function getCompletedTasks(address user, uint256 projectID)
        external
        view
        returns (uint256[] memory amount);

    function getPenalizedAmount(address user, uint256 projectID)
        external
        view
        returns (uint256 amount);

    function getInProgressTask(address user, uint256 projectID)
        external
        view
        returns (uint256 howMany);

    function receiveTask(address user, uint256 projectID) external;

    function getEarnedAmount(address user, uint256 projectID)
        external
        view
        returns (uint256 amount);

    function getStaffBalance(address user, uint256 projectID)
        external
        view
        returns (uint256 balance);

    function checkStaffInProject(address user, uint256 projectID)
        external
        view
        returns (bool);

    function checkInProgressStaff(address user, uint256 projectID)
        external
        view
        returns (uint256);

    function taskCanceled(address user, uint256 projectID) external;

    function setStaffIsWorking(
        address user,
        uint256 projectID,
        bool isWorking
    ) external;

    function setStaffBalance(
        address user,
        uint256 projectID,
        uint256 amount
    ) external;

    function getStaff(address user, uint256 projectID)
        external
        view
        returns (
            uint256 completed,
            uint256[] memory tasksComplete,
            uint256 penalized,
            uint256 inProgress,
            uint256 earned,
            uint256 balance,
            bool isWorking
        );

    function addProjectPO(address user, uint256 projectID) external;

    function POLeaveProject(address user, uint256 projectID) external;

    function getPO(address user)
        external
        view
        returns (uint256 amount, uint256[] memory projectIDs);

    function changeWalletName(
        address user,
        string memory name,
        uint256 projectID
    ) external;

    function getWalletName(address user)
        external
        view
        returns (string memory name);
}