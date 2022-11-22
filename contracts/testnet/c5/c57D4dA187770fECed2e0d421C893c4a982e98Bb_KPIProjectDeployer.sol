// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "../interface/project/IKPIProjectDeployer.sol";
import "../interface/project/IKPIProjectFactory.sol";
import "../project/KPIProject.sol";

contract KPIProjectDeployer is IKPIProjectDeployer {
    address public factory;
    struct Parameters {
        address factory;
        address token;
        bytes32 name;
        uint256 guaranteeAmount;
        address owner;
    }

    /// @inheritdoc IKPIProjectDeployer
    Parameters public override parameters;

    /// @inheritdoc IKPIProjectDeployer
    function deploy(
        address _factory,
        address token,
        bytes32 name,
        uint256 guaranteeAmount,
        address owner
    ) external override onlyFactory returns (address project) {
        parameters = Parameters({
            factory: _factory,
            token: token,
            name: name,
            guaranteeAmount: guaranteeAmount,
            owner: owner
        });
        project = address(new KPIProject());
        delete parameters;
    }

    constructor(address _factory) {
        factory = _factory;
        IKPIProjectFactory(factory).setProjectDeployerContract(
            msg.sender,
            address(this)
        );
    }

    modifier onlyFactory() {
        require(msg.sender == factory);
        _;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "./IKPIProjectActions.sol";
import "./IKPIProjectImmutables.sol";
import "./IKPIProjectStates.sol";
import "./IKPIProjectEvents.sol";

/// @title The interface for the KPI Project
/// @notice This contract is used to control tasks, members, and payments in a project
/// @author BARA
interface IKPIProject is
    IKPIProjectActions,
    IKPIProjectImmutables,
    IKPIProjectStates,
    IKPIProjectEvents
{

}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title Permissionless KPI project actions
/// @notice Contains project methods that can be called by owner and admins
/// @author BARA
interface IKPIProjectActions {
    /// @notice Deploy task on constructor
    /// @param token The token address to be used in this project
    /// @param projectContract The address of the project contract
    /// @param owner The owner address
    // function createTaskContract(
    //     address token,
    //     address projectContract,
    //     address owner
    // ) external returns (address task);

    /// @notice Add a new member to the project
    /// @param user The address of the new member
    /// @dev This function is called by owner and admins to add new member to the project
    function addMember(address user, bytes32 name) external;

    /// @notice Remove a member from the project
    /// @param user The address of the member
    /// @dev This function is called by owner and admins to remove (actually set isMember to false)
    /// a member from the project, if this member is admin, remove admin role too
    function removeMember(address user) external;

    /// @notice Add a new admin to the project
    /// @param user The address of the new admin
    /// @dev If admin is already a member, this function will not add a new member and set role to admin
    /// else it will add a new member and set that member to admin role
    function addAdmin(address user, bytes32 name) external;

    /// @notice Remove an admin from the project
    /// @param user The address of the admin
    /// @dev Remove admin role from a member, that admin is still a member
    function removeAdmin(address user) external;

    /// @notice Change a member name
    /// @param user The address of the member
    /// @param name The new name of the member
    /// @dev This function is called by admins to change member name
    function changeMemberName(address user, bytes32 name) external;

    /// @notice Change the alternate address of a member
    /// @param user The address of the member
    /// @param alternateAddress The new alternate address of the member
    /// @dev This alternate address is can be set only by that user
    function changeAlternate(address user, address alternateAddress) external;

    /// @notice Set project name
    /// @param name The new project name
    /// @dev This function is called only by owner
    function setName(bytes32 name) external;

    /// @notice Set guarantee amount
    /// @param amount The new guarantee amount
    /// @dev This function is called only by owner
    function setGuaranteeAmount(uint256 amount) external;

    /// @notice Set repository link
    /// @param repository The new repository link
    /// @dev This function is called only by owner
    function setRepository(bytes32 repository) external;

    /// @notice Set project owner
    /// @param newOwner The new project owner
    /// @dev This function is called only by owner
    function setOwner(address newOwner) external;

    /// @notice Get this project states
    /// @dev This function is called by anyone to get project states
    /// @return factory The project factory address, token The project token address, createdAt The project created time, name The project name, guaranteeAmount The project guarantee amount for a user to be able to receive task,
    /// repository The project repository link, members The number of members in this project, taskContract The task contract address, owner The project owner address, penaltyPercentage The project penalty rate
    function getProject()
        external
        view
        returns (
            address factory,
            address token,
            uint256 createdAt,
            bytes32 name,
            uint256 guaranteeAmount,
            bytes32 repository,
            uint256 members,
            address taskContract,
            address owner,
            uint256 penaltyPercentage
        );

    /// @notice Check a user is an admin of the project
    /// @param user The address of user
    function isAdmin(address user) external view returns (bool);

    /// @notice Check a user is a member of the project
    /// @param user The address of user
    function isMember(address user) external view returns (bool);

    /// @notice Factory set task contract
    /// @param task The task contract address
    function setTaskContract(address task) external;
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title An interface for a contract that is capable of deploying KPI Project contract
/// @notice A contract that constructs a project must implement this to pass arguments to the KPI project
/// @author BARA
interface IKPIProjectDeployer {
    /// @notice Get the parameters to be used in constructing a new project.
    /// @dev Called by the project factory contract constructor to fetch the parameters of the new project
    /// @return factory ProjectFactory address, token Token address to be used in this project, name Project name, guaranteeAmount Guarantee amount for a user to be able to receive task in this project,
    /// owner address of project owner
    function parameters()
        external
        view
        returns (
            address factory,
            address token,
            bytes32 name,
            uint256 guaranteeAmount,
            address owner
        );

    /// @notice Function to deploys a new project contract
    /// @dev This function is used from KPIProjectFactory to deploy a new project contract
    /// @param factory Address of Project factory
    /// @param token The token address to be used in this project
    /// @param name The name of project to be created
    /// @param guaranteeAmount The guarantee amount for a user to be able to receive task in this project
    /// @param owner The address of project owner
    function deploy(
        address factory,
        address token,
        bytes32 name,
        uint256 guaranteeAmount,
        address owner
    ) external returns (address project);
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title The interface for the KPI Project Events
/// @author BARA
interface IKPIProjectEvents {
    /// @notice Emitted when a new member is added to the project'
    /// @param project The project address
    /// @param member New member address
    /// @param name New member name
    event MemberAdded(
        address indexed project,
        address indexed member,
        bytes32 indexed name
    );

    /// @notice Emitted when a member is removed from the project
    /// @param project The project address
    /// @param member Removed member address
    event MemberRemoved(address indexed project, address indexed member);

    /// @notice Emitted when an admin is added
    /// @param project The project address
    /// @param admin New admin address
    /// @param name New admin name
    event AdminAdded(
        address indexed project,
        address indexed admin,
        bytes32 indexed name
    );

    /// @notice Emitted when an admin is removed
    /// @param project The project address
    /// @param admin Removed admin address
    event AdminRemoved(address indexed project, address indexed admin);

    /// @notice Emitted when guarantee amount of a project is changed by owner
    /// @param project The project address
    /// @param newAmount New guarantee amount
    event ProjectGuaranteeAmountChanged(
        address indexed project,
        uint256 indexed newAmount
    );

    /// @notice Emitted when project owner is changed
    /// @param project The project address
    /// @param oldOwner The old owner address
    /// @param newOwner The new owner address
    event OwnerChanged(
        address indexed project,
        address indexed oldOwner,
        address indexed newOwner
    );
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title The interface for the KPI Project Factory
/// @notice The KPI Project Factory facilitates creation of KPI Projects and control connection to others contracts
/// @author BARA
interface IKPIProjectFactory {
    /// @notice Returns the current owner of the factory
    /// @dev Can be change by the current owner via setOwner
    function owner() external view returns (address);

    /// @notice Get amount of all the projects created by the factory
    /// @dev start with 1
    function projectsCount() external view returns (uint256);

    /// @notice Get the address of the project by its index
    /// @param index The index of the project
    function getProject(uint256 index) external view returns (address);

    /// @notice Get number of projects a user is keeping
    /// @param user User address
    function userProjects(address user) external view returns (uint256);

    /// @notice Get project of a user by index
    /// @dev always start with 1
    /// @param user User address
    /// @param index Index in mapping userProjects
    function userProjectByIndex(address user, uint256 index)
        external
        view
        returns (address);

    /// @notice Get Project deployer contract
    function projectDeployerContract() external view returns (address);

    /// @notice Get Task deployer contract
    function taskDeployerContract() external view returns (address);

    /// @notice Get Task Control deployer contract
    function taskControlDeployerContract() external view returns (address);

    /// @notice Get Payment deployer contract
    function paymentDeployerContract() external view returns (address);

    /// @notice Create a new KPI Project
    /// @dev notice that a user can create only under uint256 limit of projects (65535)
    /// @param name The name of the project
    /// @param token The token address used to pay for tasks in the project
    /// @param guaranteeAmount The amount of guarantee deposit
    function createProject(
        bytes32 name,
        address token,
        uint256 guaranteeAmount
    ) external returns (address project);

    /// @notice onlyOwner call to set project deployer contract
    /// @param sender The address of the caller
    /// @param newAddress The address of the new project deployer contract
    function setProjectDeployerContract(address sender, address newAddress)
        external;

    /// @notice onlyOwner call to set task deployer contract
    /// @param sender The address of the caller
    /// @param newAddress The address of the new task deployer contract
    function setTaskDeployerContract(address sender, address newAddress)
        external;

    /// @notice onlyOwner call to set task control deployer contract
    /// @param sender The address of the caller
    /// @param newAddress The address of the new task control deployer contract
    function setTaskControlDeployerContract(address sender, address newAddress)
        external;

    /// @notice onlyOwner call to set payment deployer contract
    /// @param sender The address of the caller
    /// @param newAddress The address of the new payment deployer contract
    function setPaymentDeployerContract(address sender, address newAddress)
        external;

    /// @notice get projects of a user
    /// @param user user address
    /// @param cursor start at an index
    /// @param quantity amount to get
    function getProjectsByUser(
        address user,
        uint256 cursor,
        uint256 quantity
    )
        external
        view
        returns (address[] memory projectAddresses, uint256 newCursor);

    /// @notice add a user to a project to get projects of that user
    /// @param user User address
    /// @param project Project address
    function userAddedToProject(address user, address project) external;
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title Project state that never change
/// @notice These parameters are fixed for a project forever, i.e., the methods will always return the same values
/// @author BARA
interface IKPIProjectImmutables {
    /// @notice The contract that deployed the project
    function factory() external view returns (address);

    /// @notice The token address used to pay for tasks in the project
    function token() external view returns (address);

    /// @notice The project created time
    /// @dev Save this value with uint256 to minimize gas cost
    function createdAt() external view returns (uint256);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/// @title Project states that can change
/// @author BARA
interface IKPIProjectStates {
    /// @notice Member struct
    /// @param user The address of member
    /// @dev get member by members index
    /// @return name Member name, isMember is active member, alternate The alternate address that user want to receive reward instead of the current user address
    function getMember(address user)
        external
        view
        returns (
            bytes32 name,
            bool isMember,
            address alternate
        );

    /// @notice Get task contract address
    function taskContract() external view returns (address);

    /// @notice get project info
    /// @param projectName The project name
    /// @param repository repository link to the project's repository
    /// @param guaranteeAmount Current guarantee amount for a user to be able to receive task in this project
    /// @param members Project's members count, always start with 1
    /// @param penaltyPercentage Project's penalty rate
    /// @param owner Project's owner
    function projectInfo()
        external
        view
        returns (
            bytes32 projectName,
            bytes32 repository,
            uint256 guaranteeAmount,
            uint256 members,
            uint256 penaltyPercentage,
            address owner
        );
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

/**
 * @title Roles contract copy from @openzeppelin/contracts
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "../interface/project/IKPIProject.sol";
import "../interface/project/IKPIProjectDeployer.sol";
import "../interface/project/IKPIProjectFactory.sol";
import "../libraries/Roles.sol";

contract KPIProject is IKPIProject {
    using Roles for Roles.Role;
    Roles.Role private admins;
    /// @inheritdoc IKPIProjectImmutables
    address public override factory;
    /// @inheritdoc IKPIProjectImmutables
    address public override token;
    /// @inheritdoc IKPIProjectImmutables
    uint256 public override createdAt;
    /// @inheritdoc IKPIProjectStates
    address public override taskContract;

    struct Project {
        bytes32 projectName;
        bytes32 repository;
        uint256 guaranteeAmount;
        uint256 members;
        uint256 penaltyPercentage;
        address owner;
    }
    /// @inheritdoc IKPIProjectStates
    Project public override projectInfo;

    struct Member {
        bytes32 name;
        bool isMember;
        address alternate;
    }
    /// @inheritdoc IKPIProjectStates
    mapping(address => Member) public override getMember;

    constructor() {
        (
            address _factory,
            address _token,
            bytes32 projectName,
            uint256 guaranteeAmount,
            address owner
        ) = IKPIProjectDeployer(msg.sender).parameters();

        factory = _factory;
        token = _token;
        projectInfo.penaltyPercentage = 10;
        projectInfo.projectName = projectName;
        projectInfo.guaranteeAmount = guaranteeAmount;
        projectInfo.owner = owner;
        createdAt = block.timestamp;
    }

    /// @inheritdoc IKPIProjectActions
    function addMember(address user, bytes32 name) external override onlyAdmin {
        require(!isMember(user));
        projectInfo.members = projectInfo.members + 1;
        getMember[user] = Member({
            name: name,
            isMember: true,
            alternate: address(0)
        });
        IKPIProjectFactory(factory).userAddedToProject(user, address(this));
        emit MemberAdded(address(this), user, name);
    }

    /// @inheritdoc IKPIProjectActions
    function removeMember(address user) external override onlyAdmin {
        require(isMember(user));
        projectInfo.members = projectInfo.members - 1;
        getMember[user].isMember = false;
        if (isAdmin(user)) {
            require(msg.sender == projectInfo.owner);
            admins.remove(user);
            emit AdminRemoved(address(this), user);
        }
        emit MemberRemoved(address(this), user);
    }

    /// @inheritdoc IKPIProjectActions
    function addAdmin(address user, bytes32 name) external override onlyOwner {
        require(!isAdmin(user));
        if (!isMember(user)) {
            projectInfo.members = projectInfo.members + 1;
            getMember[user] = Member({
                name: name,
                isMember: true,
                alternate: address(0)
            });
            IKPIProjectFactory(factory).userAddedToProject(user, address(this));
            emit MemberAdded(address(this), user, name);
        }
        admins.add(user);
        emit AdminAdded(address(this), user, getMember[user].name);
    }

    /// @inheritdoc IKPIProjectActions
    function removeAdmin(address user) external override onlyOwner {
        require(isAdmin(user));
        admins.remove(user);
        emit AdminRemoved(address(this), user);
    }

    /// @inheritdoc IKPIProjectActions
    function changeMemberName(address user, bytes32 _name) external override {
        require(msg.sender == user, "1");
        getMember[user].name = _name;
    }

    /// @inheritdoc IKPIProjectActions
    function changeAlternate(address user, address alternateAddress)
        external
        override
    {
        require(msg.sender == user, "2");
        getMember[user].alternate = alternateAddress;
    }

    /// @inheritdoc IKPIProjectActions
    function setName(bytes32 newName) external override onlyOwner {
        projectInfo.projectName = newName;
    }

    /// @inheritdoc IKPIProjectActions
    function setGuaranteeAmount(uint256 newAmount) external override onlyOwner {
        projectInfo.guaranteeAmount = newAmount;
        emit ProjectGuaranteeAmountChanged(address(this), newAmount);
    }

    /// @inheritdoc IKPIProjectActions
    function setRepository(bytes32 _repository) external override onlyOwner {
        projectInfo.repository = _repository;
    }

    /// @inheritdoc IKPIProjectActions
    function setOwner(address _owner) external override onlyOwner {
        projectInfo.owner = _owner;
    }

    /// @inheritdoc IKPIProjectActions
    function getProject()
        external
        view
        virtual
        override
        returns (
            address _factory,
            address _token,
            uint256 _createdAt,
            bytes32 _name,
            uint256 _guaranteeAmount,
            bytes32 _repository,
            uint256 _members,
            address _taskContract,
            address _owner,
            uint256 penaltyPercentage
        )
    {
        return (
            factory,
            token,
            createdAt,
            projectInfo.projectName,
            projectInfo.guaranteeAmount,
            projectInfo.repository,
            projectInfo.members,
            taskContract,
            projectInfo.owner,
            projectInfo.penaltyPercentage
        );
    }

    function setTaskContract(address task) external override onlyFactory {
        taskContract = task;
    }

    /// @inheritdoc IKPIProjectActions
    function isAdmin(address user) public view override returns (bool) {
        return admins.has(user) || user == projectInfo.owner;
    }

    /// @inheritdoc IKPIProjectActions
    function isMember(address user) public view override returns (bool) {
        return getMember[user].isMember;
    }

    modifier onlyOwner() {
        require(msg.sender == projectInfo.owner);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == projectInfo.owner || admins.has(msg.sender));
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory);
        _;
    }
}