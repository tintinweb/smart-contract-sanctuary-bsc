//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/IPaymentRegistry.sol";
import "./interface/IUserRegistry.sol";
import "./interface/IProjectRegistry.sol";
import "./interface/ITaskRegistry.sol";
import "./libraries/KPILibrary.sol";

contract PaymentRegistry is IPaymentRegistry {
    using SafeERC20 for IERC20;

    address public owner;
    address public taskRegistry;
    address public userRegistry;
    address public projectRegistry;

    constructor(
        address _projectRegistry,
        address _taskRegistry,
        address _userRegistry
    ) {
        owner = msg.sender;
        taskRegistry = _taskRegistry;
        userRegistry = _userRegistry;
        projectRegistry = _projectRegistry;
    }

    mapping(address => mapping(uint256 => address)) alternateAddress;

    function depositTask(
        uint256 projectID,
        uint256 taskID,
        address depositor,
        uint256 amount
    ) public override onlyTaskContract {
        (, , address tokenAddress, , , , ) = IProjectRegistry(projectRegistry)
            .getProject(projectID);
        safeTransferFrom(tokenAddress, depositor, msg.sender, amount);
        (, , , , , uint256 totalReward, , , uint256 remaining, ) = ITaskRegistry(
            taskRegistry
        ).getTask(taskID);
        ITaskRegistry(taskRegistry).setTotalReward(
            taskID,
            totalReward + amount
        );
        ITaskRegistry(taskRegistry).setRemaining(taskID, remaining + amount);

        emit Deposit(depositor, amount);
    }

    function withdrawTask(
        uint256 projectID,
        uint256 taskID,
        address receiver
    ) public override onlyTaskContract returns (uint256) {
        (
            ,
            ,
            ,
            ,
            ,
            ,
            uint8 status,
            uint256 claimed,
            uint256 claimable,

        ) = ITaskRegistry(taskRegistry).getTask(taskID);
        require(claimable > 0);
        ITaskRegistry(taskRegistry).setClaimed(taskID, 1);
        ITaskRegistry(taskRegistry).setRemaining(taskID, 0);
        (, , address tokenAddress, , , address _owner, ) = IProjectRegistry(
            projectRegistry
        ).getProject(projectID);
        if (status == 4 && claimed == 0) {
            (uint256 remaining, uint256 refundAmount) = KPILibrary
                .decrease80percent(claimable);
            IUserRegistry(userRegistry).completeTask(
                receiver,
                taskID,
                projectID,
                remaining
            );
            receiver = getAlternateAddress(receiver, projectID);
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                receiver,
                remaining
            );
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                _owner,
                refundAmount
            );
            emit Withdraw(receiver, remaining);
            emit Withdraw(_owner, refundAmount);
        }
        if ((status == 3 || status == 5) && claimed == 0) {
            IUserRegistry(userRegistry).completeTask(
                receiver,
                taskID,
                projectID,
                claimable
            );
            receiver = getAlternateAddress(receiver, projectID);
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                receiver,
                claimable
            );
            emit Withdraw(receiver, claimable);
        }

        return 0;
    }

    function depositGuaranteeAmount(uint256 projectID, address depositor)
        public
        override
        onlyTaskContract
    {
        (, , address tokenAddress, uint256 amount, , , ) = IProjectRegistry(
            projectRegistry
        ).getProject(projectID);
        safeTransferFrom(tokenAddress, depositor, msg.sender, amount);
        IUserRegistry(userRegistry).setStaffBalance(
            depositor,
            projectID,
            amount
        );

        emit Deposit(depositor, amount);
    }

    function withdrawGuaranteeAmount(uint256 projectID, address receiver)
        public
        override
        onlyTaskContract
        returns (uint256)
    {
        uint256 balance = IUserRegistry(userRegistry).getStaffBalance(
            receiver,
            projectID
        );

        (, , address tokenAddress, uint256 amount, , , ) = IProjectRegistry(
            projectRegistry
        ).getProject(projectID);
        require(balance >= amount, "Insufficient ballance");
        IUserRegistry(userRegistry).setStaffBalance(receiver, projectID, 0);
        safeTransferFrom(tokenAddress, msg.sender, receiver, balance);

        emit Withdraw(receiver, balance);
        return balance;
    }

    function penalized(uint256 taskID)
        public
        override
        onlyTaskContract
        returns (uint256)
    {
        (
            uint256 projectID,
            ,
            ,
            address assignee,
            ,
            ,
            ,
            ,
            uint256 remaining,

        ) = ITaskRegistry(taskRegistry).getTask(taskID);
        require(remaining > 0);
        (
            ,
            ,
            address tokenAddress,
            uint256 amount,
            ,
            address _owner,

        ) = IProjectRegistry(projectRegistry).getProject(projectID);
        safeTransferFrom(
            tokenAddress,
            msg.sender,
            _owner,
            remaining + amount
        );
        ITaskRegistry(taskRegistry).setClaimed(taskID, 1);
        ITaskRegistry(taskRegistry).setRemaining(taskID, 0);
        IUserRegistry(userRegistry).penalizeTask(assignee, taskID, projectID);

        return remaining + amount;
    }

    function canceled(uint256 taskID) public override onlyTaskContract {
        (uint256 projectID, , , , , , , , uint256 remaining, ) = ITaskRegistry(
            taskRegistry
        ).getTask(taskID);
        require(remaining > 0);
        (, , address tokenAddress, , , address _owner, ) = IProjectRegistry(
            projectRegistry
        ).getProject(projectID);
        ITaskRegistry(taskRegistry).setClaimed(taskID, 1);
        ITaskRegistry(taskRegistry).setRemaining(taskID, 0);
        safeTransferFrom(tokenAddress, msg.sender, _owner, remaining);
    }

    function resetTask(
        uint256 taskID,
        address depositor,
        uint256 newAmount
    ) public override onlyTaskContract {
        (uint256 projectID, , , , , , , , , ) = ITaskRegistry(taskRegistry)
            .getTask(taskID);
        (, , address tokenAddress, , , , ) = IProjectRegistry(projectRegistry)
            .getProject(projectID);
        safeTransferFrom(tokenAddress, depositor, msg.sender, newAmount);
        ITaskRegistry(taskRegistry).setClaimed(taskID, 0);
        ITaskRegistry(taskRegistry).setRemaining(taskID, newAmount);
    }

    function autoTransfer(
        uint256 projectID,
        uint256 taskID,
        address receiver
    ) public override onlyTaskContract {
        (, , address tokenAddress, , , address _owner, ) = IProjectRegistry(
            projectRegistry
        ).getProject(projectID);
        (
            ,
            ,
            ,
            ,
            ,
            ,
            uint8 status,
            uint256 claimed,
            uint256 claimable,
            
        ) = ITaskRegistry(taskRegistry).getTask(taskID);
        require(claimable > 0);
        ITaskRegistry(taskRegistry).setClaimed(taskID, 1);
        ITaskRegistry(taskRegistry).setRemaining(taskID, 0);
        if (status == 4 && claimed == 0) {
            (uint256 remaining, uint256 refundAmount) = KPILibrary
                .decrease80percent(claimable);
            IUserRegistry(userRegistry).completeTask(
                receiver,
                taskID,
                projectID,
                remaining
            );
            receiver = getAlternateAddress(receiver, projectID);
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                receiver,
                remaining
            );
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                _owner,
                refundAmount
            );
            emit Withdraw(receiver, remaining);
            emit Withdraw(_owner, refundAmount);
        }
        if ((status == 3 || status == 5) && claimed == 0) {
            IUserRegistry(userRegistry).completeTask(
                receiver,
                taskID,
                projectID,
                claimable
            );
            receiver = getAlternateAddress(receiver, projectID);
            safeTransferFrom(
                tokenAddress,
                msg.sender,
                receiver,
                claimable
            );
            emit Withdraw(receiver, claimable);
        }
    }

    function setAlternateAddress(
        address user,
        uint256 projectID,
        address _alternateAddress
    ) public override {
        require(
            IUserRegistry(userRegistry).checkStaffInProject(
                msg.sender,
                projectID
            ),
            "Not a member"
        );
        alternateAddress[user][projectID] = _alternateAddress;
    }

    function getAlternateAddress(address user, uint256 projectID)
        internal
        view
        returns (address)
    {
        if (alternateAddress[user][projectID] != address(0)) {
            return alternateAddress[user][projectID];
        }
        return user;
    }

    function safeTransferFrom(
        address tokenAddress,
        address sender,
        address receiver,
        uint256 amount
    ) public onlyContract {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(sender, receiver, amount);
    }

    modifier onlyContract() {
        require(msg.sender == address(this) || msg.sender == taskRegistry);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyTaskContract() {
        require(msg.sender == taskRegistry);
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setTaskRegistry(address _taskRegistry) public onlyOwner {
        taskRegistry = _taskRegistry;
    }

    function setUserRegistry(address _userRegistry) public onlyOwner {
        userRegistry = _userRegistry;
    }

    function setProjectRegistry(address _projectRegistry) public onlyOwner {
        projectRegistry = _projectRegistry;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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