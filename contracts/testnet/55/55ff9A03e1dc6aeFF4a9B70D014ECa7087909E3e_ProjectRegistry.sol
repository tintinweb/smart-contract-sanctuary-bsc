//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interface/IProjectRegistry.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IUserRegistry.sol";

contract ProjectRegistry is IProjectRegistry {
    using Counters for Counters.Counter;
    address public owner;
    address public userRegistry;
    address companyRegistryAddr;
    Counters.Counter private _projectIDs;

    constructor(address _userRegistry) {
        owner = msg.sender;
        userRegistry = _userRegistry;
    }

    struct Project {
        uint256 id;
        string name;
        uint256 guaranteeAmount;
        string repository;
        address owner;
        address token;
        uint256 members;
        mapping(uint256 => address) member;
        bool existed;
    }

    mapping(uint256 => Project) public projectByID;

    uint256[] projectList;

    function create(
        string memory _name,
        address _token,
        uint256 _guaranteeAmount,
        string memory _repository
    ) public override returns (uint256) {
        require(_guaranteeAmount >= 0, "Smaller than zero");
        _projectIDs.increment();
        uint256 projectID = _projectIDs.current();

        Project storage project = projectByID[projectID];
        project.existed = true;
        project.id = projectID;
        project.name = _name;
        project.guaranteeAmount = _guaranteeAmount;
        project.repository = _repository;
        project.owner = msg.sender;
        project.token = _token;

        IUserRegistry(userRegistry).addProjectPO(msg.sender, projectID);
        projectList.push(projectID);
        emit ProjectCreated(projectID, _guaranteeAmount, msg.sender);
        return projectID;
    }

    function addStaff(
        uint256 projectID,
        address staff,
        string memory name
    ) public override {
        require(checkProject(projectID), "Not found");
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");
        require(
            !IUserRegistry(userRegistry).checkStaffInProject(staff, projectID),
            "Existed"
        );
        Project storage project = projectByID[projectID];
        uint256 totalMember = project.members + 1;
        project.members = totalMember;
        project.member[totalMember] = staff;
        IUserRegistry(userRegistry).setStaffIsWorking(staff, projectID, true);
        IUserRegistry(userRegistry).changeWalletName(staff, name, projectID);
    }

    function removeStaff(uint256 projectID, address staff) public override {
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");
        require(
            IUserRegistry(userRegistry).checkStaffInProject(staff, projectID),
            "Not found"
        );

        IUserRegistry(userRegistry).setStaffIsWorking(staff, projectID, false);
    }

    function setRepository(uint256 projectID, string memory repository)
        public
        override
    {
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");

        Project storage _project = projectByID[projectID];
        _project.repository = repository;

        emit RepositoryChanged(projectID, repository);
    }

    function setGuaranteeAmount(uint256 projectID, uint256 amount)
        public
        override
    {
        require(amount >= 0, "Smaller than zero");
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");

        Project storage _project = projectByID[projectID];
        _project.guaranteeAmount = amount;

        emit GuaranteeAmountChanged(projectID, amount);
    }

    function setProjectOwner(uint256 projectID, address newOwner) public override {
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");

        Project storage _project = projectByID[projectID];
        _project.owner = newOwner;

        IUserRegistry(userRegistry).POLeaveProject(msg.sender, projectID);
        IUserRegistry(userRegistry).addProjectPO(newOwner, projectID);

        emit OwnerChanged(projectID, msg.sender, newOwner);
    }

    function setName(uint256 projectID, string memory name) public override {
        require(checkPO(msg.sender, projectID), "Unauthorize or not found");

        Project storage _project = projectByID[projectID];
        _project.name = name;
    }

    function getProject(uint256 projectID)
        public
        view
        override
        returns (
            uint256 ID,
            string memory name,
            address token,
            uint256 guaranteeAmount,
            string memory repository,
            address _owner,
            uint256 members
        )
    {
        Project storage _project = projectByID[projectID];
        return (
            _project.id,
            _project.name,
            _project.token,
            _project.guaranteeAmount,
            _project.repository,
            _project.owner,
            _project.members
        );
    }

    function getProjects(uint256 cursor, uint256 quantity)
        public
        view
        override
        returns (uint256[] memory IDs, uint256 newCursor)
    {
        require(quantity <= 100, "Greater than 100");
        if (quantity > projectList.length - cursor) {
            quantity = projectList.length - cursor;
        }

        uint256[] memory projectIDs = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            projectIDs[i] = projectList[cursor + i];
        }

        return (projectIDs, cursor + quantity);
    }

    function getStaffsAmount(uint256 projectID)
        public
        view
        override
        returns (uint256 howMany)
    {
        require(checkProject(projectID), "Not found");
        return projectByID[projectID].members;
    }

    function staffsInProject(
        uint256 projectID,
        uint256 cursor,
        uint256 quantity
    )
        public
        view
        override
        returns (address[] memory staffs, uint256 newCursor)
    {
        require(checkProject(projectID), "Not found");
        require(cursor != 0, "0 cursor");
        require(quantity <= 100, "Greater than 100");
        Project storage project = projectByID[projectID];
        uint256 totalMember = project.members;
        if (quantity > (totalMember + 1) - cursor) {
            quantity = (totalMember + 1) - cursor;
        }
        address[] memory _staffs = new address[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            _staffs[i] = project.member[cursor + i];
        }

        return (_staffs, cursor + quantity + 1);
    }

    function checkProject(uint256 projectID)
        public
        view
        override
        returns (bool)
    {
        return projectByID[projectID].existed;
    }

    function checkPO(address user, uint256 projectID)
        public
        view
        override
        returns (bool)
    {
        return
            projectByID[projectID].existed &&
            projectByID[projectID].owner == user;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setUserRegistry(address _userRegistry) public onlyOwner {
        userRegistry = _userRegistry;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
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