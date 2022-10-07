//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "./interface/ITaskRegistry.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IProjectRegistry.sol";
import "./libraries/KPILibrary.sol";
import "./interface/IUserRegistry.sol";
import "./interface/IPaymentRegistry.sol";
import "./interface/ITaskControl.sol";

contract TaskRegistry is ITaskRegistry {
    using Counters for Counters.Counter;
    Counters.Counter private _taskIds;
    // STATUS 0: TODO, 1: INPROGRESS, 2: WAITINGFORAPPROVAL, 3: DONE, 4: LATE, 5: NEARLYDONE, 6: CANCELED, 7: PENALTY

    struct Task {
        uint256 id;
        uint256 projectID;
        string description;
        uint8 status;
        uint256 startAt;
        uint256 deadline;
        address reviewer;
        address assignee;
        uint256 totalReward;
        uint256 claimed;
        uint256 remaining;
        bool isExist;
        bool autoClaim;
    }

    address public owner;
    address public projectRegistry;
    address public userRegistry;
    address public paymentRegistry;
    address public taskControl;

    mapping(uint256 => Task) taskById;
    mapping(uint256 => uint256[]) public tasks;
    uint256[] taskIds;

    constructor(address projectAddress, address _userRegistry) {
        projectRegistry = projectAddress;
        userRegistry = _userRegistry;
        owner = msg.sender;
    }

    function changeProjectRegistry(address newAddress) public onlyOwner {
        projectRegistry = newAddress;
    }

    function changeUserRegistry(address newAddress) public onlyOwner {
        userRegistry = newAddress;
    }

    function changePaymentRegistry(address newAddress) public onlyOwner {
        paymentRegistry = newAddress;
    }

    function changeTaskControl(address newAddress) public onlyOwner {
        taskControl = newAddress;
    }

    function changeOwner(address newAddress) public onlyOwner {
        owner = newAddress;
    }

    function createTask(
        uint256 _projectID,
        string memory _description,
        uint256 amount,
        uint256 deadline
    ) public override returns (uint256) {
        require(amount > 0);
        require(deadline > block.number);
        require(
            IProjectRegistry(projectRegistry).checkPO(msg.sender, _projectID)
        );

        _taskIds.increment();
        uint256 newTaskId = _taskIds.current();

        Task memory newTask = taskById[newTaskId];
        newTask.id = newTaskId;
        newTask.projectID = _projectID;
        newTask.description = _description;
        newTask.startAt = block.number;
        newTask.deadline = deadline;
        newTask.reviewer = msg.sender;
        newTask.isExist = true;
        taskById[newTaskId] = newTask;

        IPaymentRegistry(paymentRegistry).depositTask(
            _projectID,
            newTaskId,
            msg.sender,
            amount
        );

        taskIds.push(newTaskId);
        uint256[] storage tasksByProject = tasks[_projectID];
        tasksByProject.push(newTaskId);
        emit TaskCreated(_projectID, newTaskId, amount);

        return newTaskId;
    }

    function receiveTask(uint256 taskID, bool isAutoClaim) public override {
        require(checkExistedTask(taskID), "Not exist");
        Task storage task = taskById[taskID];
        require(
            KPILibrary.checkFreeTask(task.status, task.assignee, msg.sender),
            "Not available"
        );
        require(
            IUserRegistry(userRegistry).checkStaffInProject(
                msg.sender,
                task.projectID
            ),
            "Not member"
        );
        uint256 balance = IUserRegistry(userRegistry).getStaffBalance(
            msg.sender,
            task.projectID
        );
        if (balance == 0) {
            IPaymentRegistry(paymentRegistry).depositGuaranteeAmount(
                task.projectID,
                msg.sender
            );
        }
        task.status = 1;
        if (task.assignee == address(0)) {
            task.assignee = msg.sender;
        }
        task.autoClaim = isAutoClaim;
        IUserRegistry(userRegistry).receiveTask(msg.sender, task.projectID);
        ITaskControl(taskControl).receiveTask(msg.sender, taskID);
        emit TaskAssigned(taskID, msg.sender);
    }

    function withdrawGuaranteeAmount(uint256 projectID) public override {
        require(
            IUserRegistry(userRegistry).checkStaffInProject(
                msg.sender,
                projectID
            ),
            "Not a member"
        );
        require(
            IUserRegistry(userRegistry).getInProgressTask(
                msg.sender,
                projectID
            ) == 0,
            "Have unfinished task"
        );
        uint256 amount = IPaymentRegistry(paymentRegistry)
            .withdrawGuaranteeAmount(projectID, msg.sender);
        emit Withdrawal(projectID, amount, msg.sender);
    }

    function finishTask(uint256 taskID) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(task.status == 1);
        require(task.assignee == msg.sender);
        task.status = 2;
        ITaskControl(taskControl).finishTask(msg.sender, taskID);

        emit WaitingForApproval(taskID, task.status, task.reviewer);
    }

    function penalizeTask(uint256 taskID) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );
        require(task.assignee != address(0));
        require(task.status == 1 || task.status == 2);
        require(task.deadline < block.number);
        uint256 penalizedAmount = IPaymentRegistry(paymentRegistry).penalized(
            taskID
        );
        task.status = 7;
        ITaskControl(taskControl).penalizeTask(task.assignee, taskID);

        emit Penalized(taskID, penalizedAmount, task.assignee);
    }

    function cancelTask(uint256 taskID) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(task.status == 0 || task.status == 1 || task.status == 2);
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );
        IPaymentRegistry(paymentRegistry).canceled(taskID);
        if (task.assignee != address(0)) {
            IUserRegistry(userRegistry).taskCanceled(
                task.assignee,
                task.projectID
            );
            ITaskControl(taskControl).cancelTask(task.assignee, taskID);
            task.assignee = address(0);
        }
        task.status = 6;
        emit TaskCanceled(taskID);
    }

    function approveTask(uint256 taskID) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(task.status == 1 || task.status == 2);
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );
        if (task.deadline > block.number) {
            task.status = 4;
        } else {
            task.status = 3;
        }
        if (task.autoClaim) {
            IPaymentRegistry(paymentRegistry).autoTransfer(
                task.projectID,
                taskID,
                task.assignee
            );
        }
        ITaskControl(taskControl).approveTask(task.assignee, taskID);
    }

    function resetTask(
        uint256 taskID,
        uint256 newAmount,
        uint256 deadline
    ) public override {
        require(checkExistedTask(taskID));
        require(deadline > block.number, "Wrong deadline");
        Task storage task = taskById[taskID];
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            )
        );
        require(task.status == 7 || task.status == 6);
        IPaymentRegistry(paymentRegistry).resetTask(
            taskID,
            msg.sender,
            newAmount
        );
        ITaskControl(taskControl).resetTask(task.assignee, taskID);
        task.assignee = address(0);
        task.deadline = deadline;
        task.status = 0;
        task.totalReward = newAmount;
    }

    function forceDone(uint256 taskID) public override {
        require(checkExistedTask(taskID), "Not existed");
        Task storage task = taskById[taskID];
        require(task.claimed == 0, "Claimed");
        require(
            task.status == 4 || task.status == 2 || task.status == 1,
            "Cannot force done"
        );
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender),
            "Unauthorized or Not found"
        );
        task.status = 5;
        ITaskControl(taskControl).forceDone(task.assignee, taskID);
    }

    function setAssignee(uint256 taskID, address newAssignee) public override {
        require(checkExistedTask(taskID), "Not existed");
        Task storage task = taskById[taskID];
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender),
            "Unauthorized or Not found"
        );
        require(task.claimed == 0, "Claimed");
        require(task.assignee != newAssignee, "Same staff");
        require(
            IUserRegistry(userRegistry).checkStaffInProject(
                msg.sender,
                task.projectID
            ),
            "Not a member"
        );
        task.assignee = newAssignee;
        ITaskControl(taskControl).setAssignee(newAssignee, taskID);

        emit TaskAssigned(taskID, newAssignee);
    }

    function setDescription(uint256 taskID, string memory newDescription)
        public
        override
    {
        require(checkExistedTask(taskID), "Not existed");
        Task storage task = taskById[taskID];
        require(task.claimed == 0, "Claimed");
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );

        task.description = newDescription;
    }

    function setDeadline(uint256 taskID, uint256 newDeadline) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );
        require(task.claimed == 0, "Claimed");
        require(task.deadline > block.number, "Incorrect deadline");
        task.deadline = newDeadline;
    }

    function setReviewer(uint256 taskID, address newReviewer) public override {
        require(checkExistedTask(taskID));
        Task storage task = taskById[taskID];
        require(
            IProjectRegistry(projectRegistry).checkPO(
                msg.sender,
                task.projectID
            ) || KPILibrary.isReviewer(task.reviewer, msg.sender)
        );
        require(task.claimed == 0, "Claimed");

        task.reviewer = newReviewer;
    }

    function claimTask(uint256 taskID) public override {
        require(checkExistedTask(taskID), "Not existed");
        Task memory task = taskById[taskID];
        require(KPILibrary.claimTaskCondition(task.status), "Not done");
        require(task.assignee == msg.sender, "No permission");
        IPaymentRegistry(paymentRegistry).withdrawTask(
            task.projectID,
            taskID,
            msg.sender
        );
    }

    function deposit(uint256 taskID, uint256 amount) public override {}

    function setClaimed(uint256 taskID, uint256 claimed)
        public
        override
        onlyPayment
    {
        taskById[taskID].claimed = claimed;
    }

    function setTotalReward(uint256 taskID, uint256 newReward)
        public
        override
        onlyPayment
    {
        taskById[taskID].totalReward = newReward;
    }

    function setRemaining(uint256 taskID, uint256 remaining)
        public
        override
        onlyPayment
    {
        taskById[taskID].remaining = remaining;
    }

    function setAutoClaim(uint256 taskID, bool autoClaim) public override {
        taskById[taskID].autoClaim = autoClaim;
    }

    function checkExistedTask(uint256 taskID) internal view returns (bool) {
        return taskById[taskID].isExist;
    }

    function checkProjectExisted(uint256 taskID) internal view returns (bool) {
        Task memory task = taskById[taskID];
        return IProjectRegistry(projectRegistry).checkProject(task.projectID);
    }

    function getTasks(
        uint256 projectID,
        uint256 cursor,
        uint256 quantity
    )
        public
        view
        override
        returns (uint256[] memory taskId, uint256 newCursor)
    {
        require(quantity < 100);
        if (projectID == 0) {
            if (quantity > taskIds.length - cursor) {
                quantity = taskIds.length - cursor;
            }

            uint256[] memory values = new uint256[](quantity);
            for (uint256 i = 0; i < quantity; i++) {
                values[i] = taskIds[cursor + i];
            }

            return (values, cursor + quantity);
        } else {
            uint256[] memory tasksByProject = tasks[projectID];
            if (quantity > tasksByProject.length - cursor) {
                quantity = tasksByProject.length - cursor;
            }

            uint256[] memory values = new uint256[](quantity);
            for (uint256 i = 0; i < quantity; i++) {
                values[i] = tasksByProject[cursor + i];
            }

            return (values, cursor + quantity);
        }
    }

    function getTask(uint256 taskID)
        public
        view
        override
        returns (
            uint256 projectID,
            string memory description,
            uint256 deadline,
            address assignee,
            address reviewer,
            uint256 totalReward,
            uint8 status,
            uint256 claimed,
            uint256 remaining,
            bool isExist
        )
    {
        Task memory task = taskById[taskID];
        require(task.isExist, "Not exist");
        return (
            task.projectID,
            task.description,
            task.deadline,
            task.assignee,
            task.reviewer,
            task.totalReward,
            task.status,
            task.claimed,
            task.remaining,
            task.isExist
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPayment() {
        require(msg.sender == paymentRegistry);
        _;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITaskRegistry {
    /// @notice Emitted when the project owner create task
    /// @param projectID ID of the project
    /// @param taskID ID of the new created task
    /// @param reward Task reward
    event TaskCreated(
        uint256 projectID,
        uint256 indexed taskID,
        uint256 indexed reward
    );

    /// @notice Emitted when task is assigned to someone
    /// @param taskID ID of the task
    /// @param assignee Address of assignee
    event TaskAssigned(uint256 indexed taskID, address indexed assignee);

    /// @notice Emitted when a task is waiting for approval
    /// @param taskID ID of the task
    /// @param status Task status
    /// @param reviewer Reviewer of the task
    event WaitingForApproval(
        uint256 indexed taskID,
        uint8 indexed status,
        address indexed reviewer
    );

    /// @notice Emitted when a task is penalized
    /// @param taskID ID of the task
    /// @param amount Penalize amount
    /// @param assignee Task assignee
    event Penalized(
        uint256 indexed taskID,
        uint256 indexed amount,
        address indexed assignee
    );

    /// @notice Emitted when a task is canceled
    /// @param canceledTask ID of the canceled task
    event TaskCanceled(uint256 indexed canceledTask);

    /// @notice Emitted when a user withdraw from a project
    /// @param projectID ID of the project
    /// @param amount Withdrawal amount
    /// @param user Address of user
    event Withdrawal(
        uint256 indexed projectID,
        uint256 indexed amount,
        address indexed user
    );

    function createTask(
        uint256 projectID,
        string memory description,
        uint256 amount,
        uint256 deadline
    ) external returns (uint256);

    function receiveTask(uint256 taskID, bool isAutoClaim) external;

    function withdrawGuaranteeAmount(uint256 projectID) external;

    function claimTask(uint256 taskID) external;

    function finishTask(uint256 taskID) external;

    function penalizeTask(uint256 taskID) external;

    function cancelTask(uint256 taskID) external;

    function approveTask(uint256 taskID) external;

    function resetTask(
        uint256 taskID,
        uint256 newAmount,
        uint256 deadline
    ) external;

    function forceDone(uint256 taskID) external;

    function deposit(uint256 taskID, uint256 amount) external;

    function setAssignee(uint256 taskID, address assignee) external;

    function setDescription(uint256 taskID, string memory description) external;

    function setDeadline(uint256 taskID, uint256 deadline) external;

    function setReviewer(uint256 taskID, address newReviewer) external;

    function setClaimed(uint256 taskID, uint256 claimed) external;

    function setTotalReward(uint256 taskID, uint256 newReward) external;

    function setRemaining(uint256 taskID, uint256 remaining) external;

    function setAutoClaim(uint256 taskID, bool isAutoClaim) external;

    function getTasks(
        uint256 projectID,
        uint256 cursor,
        uint256 quantity
    ) external view returns (uint256[] memory taskID, uint256 newCursor);

    function getTask(uint256 taskID)
        external
        view
        returns (
            uint256 projectID,
            string memory description,
            uint256 deadline,
            address assignee,
            address reviewer,
            uint256 totalReward,
            uint8 status,
            uint256 isClaimed,
            uint256 remaining,
            bool isExist
        );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IProjectRegistry {
    /// @notice Emitted when a project is created
    /// @param projectID ID of the project
    /// @param guaranteeAmount Guarantee amount of the project
    /// @param owner Project owner
    event ProjectCreated(
        uint256 indexed projectID,
        uint256 indexed guaranteeAmount,
        address indexed owner
    );

    /// @notice Emitted when the owner of the contract is changed
    /// @param projectID ID of the project
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(
        uint256 indexed projectID,
        address indexed oldOwner,
        address indexed newOwner
    );

    /// @notice Emitted when set repository link to a project
    /// @param projectID ID of the project
    /// @param repository Link of the project's repository
    event RepositoryChanged(
        uint256 indexed projectID,
        string indexed repository
    );

    /// @notice Emitted when set new guarantee deposit amount for staff
    /// @param projectID ID of the project
    /// @param amount New amount of the guarantee deposit
    event GuaranteeAmountChanged(
        uint256 indexed projectID,
        uint256 indexed amount
    );

    function create(
        string memory name,
        address token,
        uint256 guaranteeAmount,
        string memory repository
    ) external returns (uint256 projectID);

    function addStaff(
        uint256 projectID,
        address staff,
        string memory name
    ) external;

    function removeStaff(uint256 projectID, address staff) external;

    function setRepository(uint256 projectID, string memory repository)
        external;

    function setGuaranteeAmount(uint256 projectID, uint256 amount) external;

    function setProjectOwner(uint256 projectID, address newOwner) external;

    function setName(uint256 projectID, string memory name) external;

    function getProject(uint256 projectID)
        external
        view
        returns (
            uint256 ID,
            string memory name,
            address token,
            uint256 guaranteeAmount,
            string memory repository,
            address owner,
            uint256 members
        );

    function getProjects(uint256 cursor, uint256 quantity)
        external
        view
        returns (uint256[] memory projectIDs, uint256 newCursor);

    function getStaffsAmount(uint256 projectID)
        external
        view
        returns (uint256 howMany);

    function staffsInProject(
        uint256 projectID,
        uint256 cursor,
        uint256 quantity
    ) external view returns (address[] memory staffs, uint256 newCursor);

    function checkProject(uint256 projectID) external view returns (bool);

    function checkPO(address user, uint256 projectID)
        external
        view
        returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// @title TaskLibrary
library KPILibrary {
    using SafeMath for uint256;

    function decrease80percent(uint256 amount)
        public
        pure
        returns (uint256, uint256)
    {
        uint256 remainingAmount = amount;
        remainingAmount = remainingAmount.mul(80);
        remainingAmount = remainingAmount.div(100);
        return (remainingAmount, amount - remainingAmount);
    }

    function checkFreeTask(
        uint8 status,
        address assignee,
        address user
    ) public pure returns (bool) {
        if (
            checkAvailableTaskStatus(status) == true &&
            (assignee == address(0) || assignee == user)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function checkAvailableTaskStatus(uint8 status) public pure returns (bool) {
        if (status == 0) {
            return true;
        } else {
            return false;
        }
    }

    function claimTaskCondition(uint8 status) public pure returns (bool) {
        if (status == 3 || status == 4 || status == 5) {
            return true;
        } else {
            return false;
        }
    }

    function checkPermissionToChangeStatus(
        address assignee,
        address reviewer,
        address _owner,
        address msgSender,
        uint8 newStatus
    ) public pure returns (bool) {
        bool isPermitted = false;
        if (
            isAssignee(assignee, msgSender) &&
            assigneeStatusPermission(newStatus)
        ) {
            isPermitted = true;
            return isPermitted;
        }

        if (msgSender == reviewer || msgSender == _owner) {
            isPermitted = true;
            return isPermitted;
        }

        return isPermitted;
    }

    function isAssignee(address assignee, address msgSender)
        public
        pure
        returns (bool)
    {
        bool result = false;

        if (msgSender == assignee) {
            result = true;
        }

        return result;
    }

    function assigneeStatusPermission(uint8 status) public pure returns (bool) {
        if (status == 1 || status == 2) {
            return true;
        } else {
            return false;
        }
    }

    function isReviewer(address reviewer, address msgSender)
        public
        pure
        returns (bool)
    {
        return reviewer == msgSender;
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IPaymentRegistry {
    /// @notice Emitted when a user withdraw
    /// @param user User address
    /// @param amount Withdraw amount
    event Withdraw(address user, uint256 amount);

    /// @notice Emitted when a user deposit
    /// @param user User address
    /// @param amount Deposit amount
    event Deposit(address user, uint256 amount);

    function depositTask(
        uint256 projectID,
        uint256 taskID,
        address depositor,
        uint256 amount
    ) external;

    function withdrawTask(
        uint256 projectID,
        uint256 taskID,
        address receiver
    ) external returns (uint256);

    function depositGuaranteeAmount(uint256 projectID, address depositor)
        external;

    function withdrawGuaranteeAmount(uint256 projectID, address receiver)
        external
        returns (uint256);

    function penalized(uint256 taskID) external returns (uint256);

    function canceled(uint256 taskID) external;

    function resetTask(
        uint256 taskID,
        address depositor,
        uint256 newAmount
    ) external;

    function autoTransfer(
        uint256 projectID,
        uint256 taskID,
        address receiver
    ) external;

    function setAlternateAddress(
        address user,
        uint256 projectID,
        address alternateAddress
    ) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}