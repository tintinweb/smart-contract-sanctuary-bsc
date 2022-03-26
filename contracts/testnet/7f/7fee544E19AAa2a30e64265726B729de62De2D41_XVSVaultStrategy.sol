pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "../../Vault/Utils/SafeBEP20.sol";
import "../../Vault/Utils/IBEP20.sol";
import "../../Vault/Utils/ReentrancyGuard.sol";
import "./XVSVaultStrategyProxy.sol";
import "./XVSVaultStrategyStorage.sol";
import "./XVSVault.sol";

contract XVSVaultStrategy is XVSVaultStrategyStorage, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    /// @notice Event emitted on aXVS deposit
    event Deposit(address indexed user, uint256 amount);

    /// @notice Event emitted when execute withrawal
    event ExecutedWithdrawal(address indexed user, uint256 amount);

    /// @notice Event emitted when request withrawal
    event WithdrawalRequested(address indexed user, uint256 amount);

    /// @notice Event emitted on aXVS deposit
    event DepositATL(address indexed user, uint256 amount);

    /// @notice Event emitted when withrawal
    event WithdrawATL(address indexed user, uint256 amount);

    /// @notice Event emitted when claiming XVS rewards
    event Claim(address indexed user, uint256 amount);

    /// @notice Event emitted when Atlantis contract address is updated
    event ATLAddressUpdated(address oldAtlantis, address newAtlantis);

    /// @notice Event emitted when vault is paused
    event VaultPaused(address indexed admin);

    /// @notice Event emitted when vault is resumed after pause
    event VaultResumed(address indexed admin);

    /// @notice Event emitted when deposit limit is updated
    event DepositLimitUpdated(uint256 maxDepositPercentage, uint256 amountATL);

    /// @notice Event emitted when is resumed is resumed after pause
    event CompoundingResumed(address indexed user);

    /// @notice Event emitted when compounding is stopt is resumed after pause
    event CompoundingPaused(address indexed user);

    /// @notice Event emitted when compounding is stopt is resumed after pause
    event CompoundingExecuted(address indexed user);

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can");
        _;
    }

    modifier isActive() {
        require(vaultPaused == false, "Vault is paused");
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }

    modifier userHasPosition(address userAddress) {
        UserInfo storage user = userInfo[userAddress];
        require(user.userAddress != address(0) && user.contractAddress != address(0), "No position in the XVS Vault");
        _;
    }

    modifier hasValideDepositLimit(uint256 _depositAmount) {
        UserInfo storage user = userInfo[msg.sender];
        (uint256 newDepositPercentage, uint256 roundedMaxDepositPercentage, uint256 requiredATL) = this.calculateUserDepositAllowance(user.userAddress, _depositAmount);

        require(user.amountATL >= requiredATL && newDepositPercentage <= roundedMaxDepositPercentage, "increase deposit limit");
        _;
    }

    function deposit(uint256 depositAmount) external nonReentrant isActive hasValideDepositLimit(depositAmount) {
        require(depositAmount > 0, "zero amount");

        UserInfo storage user = userInfo[msg.sender];
        if (user.userAddress == address(0)) {
            user.contractAddress = address(initializeXVSVaultContract());
            user.userAddress = msg.sender;
        }

        // Transfer XVS from the user wallet to the user vault contract
        IBEP20(xvs).safeTransferFrom(address(msg.sender), address(user.contractAddress), depositAmount);

        // Transfer XVS from user vault contract to Venus XVS Vault
        IXVSVaultItem(address(user.contractAddress)).deposit(depositAmount);

        // Request withdrawal
        IXVSVaultItem(address(user.contractAddress)).requestWithdrawal(depositAmount);

        emit Deposit(user.userAddress, depositAmount);
    }

    function withdraw() external nonReentrant userHasPosition(msg.sender) {
        address userAddress = msg.sender;
        UserInfo storage user = userInfo[userAddress];

        // get the current available amount to be withdrawn
        uint256 eligibleWithdrawalAmount = IXVSVault(xvsVault).getEligibleWithdrawalAmount(xvs, pid, user.contractAddress);
        require(eligibleWithdrawalAmount > 0, "Nothing to withdraw");

        // Transfer the staked XVS from user vault contract to the user wallet
        IXVSVaultItem(address(user.contractAddress)).executeWithdrawal(user.userAddress);

        emit ExecutedWithdrawal(userAddress, eligibleWithdrawalAmount);
    }

    // This function is used for requesting withdrawal of all available XVS from the Venus XVS Vault
    // This is mostly used when auto compounding is active.
    function requistWithdrawal() external nonReentrant userHasPosition(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        (uint256 amount, , uint256 pendingWithdrawals) = IXVSVault(xvsVault).getUserInfo(xvs, pid, user.contractAddress);

        // calculate the current available amount which is not yet requested to be withdrawn
        uint256 userStakeAmount = amount.sub(pendingWithdrawals);
        require(userStakeAmount > 0, "Nothing to withdraw");

        // Request withdrawal
        IXVSVaultItem(address(user.contractAddress)).requestWithdrawal(userStakeAmount);

        emit WithdrawalRequested(msg.sender, userStakeAmount);
    }

    function compound(address[] calldata users) external nonReentrant {
        for (uint256 i = 0; i < users.length; ++i) {
            UserInfo storage user = userInfo[users[i]];
             (uint256 amount, ,) = IXVSVault(xvsVault).getUserInfo(xvs, pid, user.contractAddress);
            if (user.amountATL >= minRequiredATLForCompounding && amount > 0) {
                /*
                    1. claim all pending rewards
                    2. deposit the claimed rewards back to the XVS Vault
                */
                IXVSVaultItem(address(user.contractAddress)).compoundRewards();
                emit CompoundingExecuted(user.userAddress);
            }
        }
    }

    function claim() external nonReentrant userHasPosition(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];

        uint256 pendingRewards = IXVSVault(xvsVault).pendingReward(xvs, pid, user.contractAddress);
        IXVSVaultItem(address(user.contractAddress)).claimRewards(user.userAddress);

        emit Claim(user.userAddress, pendingRewards);
    }

    function depositATL(uint256 amount) external nonReentrant isActive {
        require(address(msg.sender) != address(0), "zero address");
        require(amount > 0, "zero amount");

        UserInfo storage user = userInfo[msg.sender];
        if (user.userAddress == address(0)) {
            user.contractAddress = address(initializeXVSVaultContract());
            user.userAddress = msg.sender;
        }

        user.amountATL = user.amountATL.add(amount);

        // Transfer ATL from user wallet to the vault
        IBEP20(atlantis).safeTransferFrom(user.userAddress, address(this), amount);

        emit DepositATL(user.userAddress, amount);
    }

    // Withdraw all ATL and transfer it to the user wallet
    function withdrawATL() external nonReentrant {
        require(address(msg.sender) != address(0), "zero address");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amountATL > 0, "nothing to withdraw");

        uint256 _amountATL = user.amountATL;
        user.amountATL = 0;

        // (uint256 amount, , ) = IXVSVault(xvsVault).getUserInfo(xvs, pid, user.contractAddress);
        // require(amount == 0, "You first need to stop compounding and withdraw all XVS");
        // require(user.amountATL <= IBEP20(atlantis).balanceOf(address(this)), "Not enough ATL balance");

        // Transfer ATL back to the user wallet
        IBEP20(atlantis).safeTransferFrom(address(this), user.userAddress, _amountATL);

        emit WithdrawATL(user.userAddress, _amountATL);
    }

    // Get user info with some extra data
    function getUserInfo(address _user) external view returns (UserInfoLens memory) {
        UserInfoLens memory userInfoLens;

        UserInfo storage user = userInfo[_user];
        userInfoLens.contractAddress = user.contractAddress;
        userInfoLens.userAddress = user.userAddress;
        userInfoLens.amountATL = user.amountATL;
        userInfoLens.compounding = user.amountATL >= minRequiredATLForCompounding;
        userInfoLens.pendingReward = IXVSVault(xvsVault).pendingReward(xvs, pid, user.contractAddress);

        (uint256 _amount, , uint256 _pendingWithdrawals) = IXVSVault(xvsVault).getUserInfo(xvs, pid, user.contractAddress);
        userInfoLens.amount = _amount;
        userInfoLens.pendingWithdrawals = _pendingWithdrawals;
        userInfoLens.stakeAmount = _amount.sub(_pendingWithdrawals);

        userInfoLens.eligibleWithdrawalAmount = IXVSVault(xvsVault).getEligibleWithdrawalAmount(xvs, pid, user.contractAddress);

        (uint256 _usedDepositPercentage, uint256 _maxDepositPercentage, uint256 _requiredATL) = this.calculateUserDepositAllowance(user.userAddress, 0);
        userInfoLens.usedDepositPercentage = _usedDepositPercentage;
        userInfoLens.maxDepositPercentage = _maxDepositPercentage;
        userInfoLens.requiredATL = _requiredATL;

        userInfoLens.withdrawalRequest = IXVSVault(xvsVault).getWithdrawalRequests(xvs, pid, user.contractAddress);

        return userInfoLens;
    }

    function getPoolInfo()
        external
        view
        returns (
            uint256 rewardTokenAmountsPerBlock,
            uint256 totalAllocPoints,
            uint256 allocPoint,
            uint256 totalStaked
        )
    {
        rewardTokenAmountsPerBlock = IXVSVault(xvsVault).rewardTokenAmountsPerBlock(xvs);
        totalAllocPoints = IXVSVault(xvsVault).totalAllocPoints(xvs);
        IXVSVault.PoolInfo memory pool = IXVSVault(xvsVault).poolInfos(xvs, pid);
        allocPoint = pool.allocPoint;
        totalStaked = IBEP20(xvs).balanceOf(xvsVault);
    }

    function calculateUserDepositAllowance(address _userAddress, uint256 _depositAmount)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        UserInfo storage user = userInfo[_userAddress];
        uint256 userWalletBalance = IBEP20(xvs).balanceOf(user.userAddress);

        (uint256 amount, , ) = IXVSVault(xvsVault).getUserInfo(xvs, pid, user.contractAddress);

        uint256 roundedDepositedATL = user.amountATL.sub(user.amountATL.mod(10));
        if (userWalletBalance == 0 && amount == 0) {
            return (0, depositAllowanceData[roundedDepositedATL], roundedDepositedATL);
        }

        uint256 newDepositPercentage = amount.add(_depositAmount).mul(DENOMINATOR).div(amount.add(userWalletBalance)).div(100);
        return (newDepositPercentage, depositAllowanceData[roundedDepositedATL], roundedDepositedATL);
    }

    /*** Admin Functions ***/

    function _become(XVSVaultStrategyProxy xvsVaultStrategyProxy) public {
        require(msg.sender == xvsVaultStrategyProxy.admin(), "only proxy admin can change brains");
        xvsVaultStrategyProxy._acceptImplementation();
    }

    function setAtlantisAddress(address _atlantis) external onlyAdmin {
        address oldAtlantisContract = atlantis;
        atlantis = _atlantis;

        _notEntered = true;
        emit ATLAddressUpdated(oldAtlantisContract, atlantis);
    }

    function pause() external onlyAdmin {
        require(vaultPaused == false, "Vault is already paused");
        vaultPaused = true;
        emit VaultPaused(msg.sender);
    }

    function resume() external onlyAdmin {
        require(vaultPaused == true, "Vault is not paused");
        vaultPaused = false;
        emit VaultResumed(msg.sender);
    }

    function setDepositLimit(uint256 _requiredATL, uint256 _maxDepositPercentage) external onlyAdmin {
        require(_maxDepositPercentage >= 10 && _maxDepositPercentage <= 100, "Must be between 10 and 100");
        depositAllowanceData[_requiredATL] = _maxDepositPercentage;
        emit DepositLimitUpdated(_requiredATL, _maxDepositPercentage);
    }

    function setMinRequiredATLForCompounding(uint256 _minRequiredATLForCompounding) external onlyAdmin {
        minRequiredATLForCompounding = _minRequiredATLForCompounding;
    }

    function initializeXVSVaultContract() internal returns (address) {
        XVSVault xvsVault = new XVSVault();
        XVSVaultStrategyProxy proxy = new XVSVaultStrategyProxy();
        proxy._setPendingImplementation(address(xvsVault));
        xvsVault._become(proxy);
        proxy._setPendingAdmin(admin); // for future upgrades
        IXVSVaultItem(address(proxy)).setAdminVault(address(this));
        return address(proxy);
    }
}

pragma solidity ^0.5.16;

import "./IBEP20.sol";
import "../../SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for BEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeBEP20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

pragma solidity ^0.5.16;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {BEP20Detailed}.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.5.16;

import "./XVSVaultStrategyStorage.sol";

contract XVSVaultStrategyProxy is XVSVaultStrategyAdminStorage {
    /**
     * @notice Emitted when pendingImplementation is changed
     */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
     * @notice Emitted when pendingImplementation is accepted, which means Community Vault implementation is updated
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Emitted when pendingAdmin is changed
     */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Emitted when pendingAdmin is accepted, which means admin is updated
     */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        require(msg.sender != address(0), "Zero address not allowed");
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) external {
        require(msg.sender == admin, "Only admin can set Pending Implementation");

        address oldPendingImplementation = pendingImplementation;

        pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);
    }

    /**
     * @notice Accepts new implementation of XVS Vault Strategy. msg.sender must be pendingImplementation
     * @dev Admin function for new implementation to accept it's role as implementation
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _acceptImplementation() external {
        // Check caller is pendingImplementation
        require(msg.sender == pendingImplementation, "only address marked as pendingImplementation can accept Implementation");

        // Save current values for inclusion in log
        address oldImplementation = implementation;
        address oldPendingImplementation = pendingImplementation;

        implementation = pendingImplementation;
        pendingImplementation = address(0);

        emit NewImplementation(oldImplementation, implementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);
    }

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @param newPendingAdmin New pending admin.
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _setPendingAdmin(address newPendingAdmin) external {
        // Check caller = admin
        require(msg.sender == admin, "only admin can set pending admin");
        require(newPendingAdmin != pendingAdmin, "New pendingAdmin can not be same as the previous one");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
     * @dev Admin function for pending admin to accept role and update admin
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _acceptAdmin() external {
        // Check caller is pendingAdmin
        require(msg.sender == pendingAdmin, "only address marked as pendingAdmin can accept as Admin");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    function() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize)
            }
            default {
                return(free_mem_ptr, returndatasize)
            }
        }
    }
}

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "../../SafeMath.sol";
import "../../Vault/Utils/IBEP20.sol";

contract XVSVaultStrategyAdminStorage {
    /**
     * @notice Administrator for this contract
     */
    address public admin;

    /**
     * @notice Pending administrator for this contract
     */
    address public pendingAdmin;

    /**
     * @notice Active brains of XVS Vault Strategy
     */
    address public implementation;

    /**
     * @notice Pending brains of XVS Vault Strategy
     */
    address public pendingImplementation;
}

contract XVSVaultStrategyStorage is XVSVaultStrategyAdminStorage {
    /// @notice Guard variable for re-entrancy checks
    bool public _notEntered;

    /// @notice pause indicator for Vault
    bool public vaultPaused;

    /// @notice The Atlantis token address
    address public atlantis;

    /// @notice The XVS token address
    address public constant xvs = address(0xB9e0E753630434d7863528cc73CB7AC638a7c8ff);

    /// @notice The XVS Vault address
    address public constant xvsVault = address(0x9aB56bAD2D7631B2A857ccf36d998232A8b82280);

    /// @notice The XVS Vaut pair id
    uint8 public constant pid = 1;

    /// @notice The minimum amount of ATL required for an user to participate in auto compounding.
    uint256 public minRequiredATLForCompounding;

    uint256 public constant DENOMINATOR = 10000;

    /// @notice Info of each user.
    struct UserInfo {
        address contractAddress;
        address userAddress;
        uint256 amountATL;
    }

    /// Info of each user that stakes tokens.
    mapping(address => UserInfo) public userInfo;

    /// key = required ATL amount, value = max deposit allowance %
    mapping(uint256 => uint256) public depositAllowanceData;

    struct UserInfoLens {
        address contractAddress;
        address userAddress;
        uint256 amount;
        uint256 amountATL;
        bool compounding;
        uint256 pendingReward;
        uint256 pendingWithdrawals;
        uint256 eligibleWithdrawalAmount;
        uint256 stakeAmount;
        uint256 usedDepositPercentage;
        uint256 maxDepositPercentage;
        uint256 requiredATL;
        IXVSVault.WithdrawalRequest[] withdrawalRequest;
    }
}

contract XVSVaultItemStorage is XVSVaultStrategyStorage {
    /// @notice This is the address of the xvs vault strategy contract (aka. parent contract)
    address public adminVault;
}

interface IAToken {
    function exchangeRateStored() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function _transferLiquidityToStrategyVault(uint256 tokensIn) external returns (uint256);

    function _transferLiquidityFromStrategyVault(uint256 tokensIn, uint256 amountIn) external;

    function getCash() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function interestRateModel() external view returns (address);

    function redeem(uint256 redeemTokens) external returns (uint256);
}

interface IJumpRateModelV2 {
    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external pure returns (uint256);
}

interface IXVSVaultItem {
    function deposit(uint256 amount) external;

    function requestWithdrawal(uint256 amount) external;

    function executeWithdrawal(address userAddress) external;

    function claimRewards(address userAddress) external;

    function compoundRewards() external;

    function setAdminVault(address adminVault) external;
}

interface IXVSVault {
    function deposit(
        address _rewardToken,
        uint256 _pid,
        uint256 _amount
    ) external;

    function requestWithdrawal(
        address _rewardToken,
        uint256 _pid,
        uint256 _amount
    ) external;

    function executeWithdrawal(address _rewardToken, uint256 _pid) external;

    struct WithdrawalRequest {
        uint256 amount;
        uint256 lockedUntil;
    }

    function getWithdrawalRequests(
        address _rewardToken,
        uint256 _pid,
        address _user
    ) external view returns (WithdrawalRequest[] memory);

    function getEligibleWithdrawalAmount(
        address _rewardToken,
        uint256 _pid,
        address _user
    ) external view returns (uint256 withdrawalAmount);

    function pendingReward(
        address _rewardToken,
        uint256 _pid,
        address _user
    ) external view returns (uint256);

    function getUserInfo(
        address _rewardToken,
        uint256 _pid,
        address _user
    )
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 pendingWithdrawals
        );

    struct PoolInfo {
        IBEP20 token; // Address of token contract to stake.
        uint256 allocPoint; // How many allocation points assigned to this pool.
        uint256 lastRewardBlock; // Last block number that reward tokens distribution occurs.
        uint256 accRewardPerShare; // Accumulated per share, times 1e12. See below.
        uint256 lockPeriod; // Min time between withdrawal request and its execution.
    }

    function poolInfos(address _rewardToken, uint256 index) external view returns (PoolInfo memory);

    function rewardTokenAmountsPerBlock(address _rewardToken) external view returns (uint256);

    function totalAllocPoints(address _rewardToken) external view returns (uint256);
}

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "../../Vault/Utils/Address.sol";
import "../../Vault/Utils/SafeBEP20.sol";
import "../../Vault/Utils/IBEP20.sol";
import "../../Vault/Utils/ReentrancyGuard.sol";
import "./XVSVaultStrategyProxy.sol";
import "./XVSVaultStrategyStorage.sol";

// This contract acts as a wrapper for user wallet interaction with the XVS Vault
contract XVSVault is XVSVaultItemStorage, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using Address for address;

    modifier onlyAdminVault() {
        require(msg.sender == adminVault, "only admin vault can");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can");
        _;
    }

    function deposit(uint256 amount) external nonReentrant onlyAdminVault {
        require(amount > 0, "Deposit amount must be non-zero");
        IBEP20(xvs).approve(xvsVault, 2**256 - 1);
        IXVSVault(xvsVault).deposit(xvs, pid, amount);
    }

    function requestWithdrawal(uint256 amount) external nonReentrant onlyAdminVault {
        require(amount > 0, "Requested withdrawal amount must be non-zero");
        IXVSVault(xvsVault).requestWithdrawal(xvs, pid, amount);
    }

    function claimRewards(address _userAddress) external nonReentrant onlyAdminVault {
        IXVSVault(xvsVault).deposit(xvs, pid, 0);

        // Transfer claimed XVS to the user wallet
        IBEP20(xvs).safeTransferFrom(address(this), _userAddress, IBEP20(xvs).balanceOf(address(this)));
    }

    function compoundRewards() external nonReentrant onlyAdminVault {
        uint256 pendingRewards = IXVSVault(xvsVault).pendingReward(xvs, pid, address(this));

        // claim the pending rewards
        IXVSVault(xvsVault).deposit(xvs, pid, 0);

        // deposit the claimed rewards back to the XVS Vault
        IXVSVault(xvsVault).deposit(xvs, pid, pendingRewards);
    }

    function executeWithdrawal(address _userAddress) external nonReentrant onlyAdminVault {
        IXVSVault(xvsVault).executeWithdrawal(xvs, pid);

        // Transfer XVS to user wallet
        IBEP20(xvs).safeTransferFrom(address(this), _userAddress, IBEP20(xvs).balanceOf(address(this)));
    }

    /*** Admin Functions ***/

    function _become(XVSVaultStrategyProxy xvsVaultStrategyProxy) public {
        require(msg.sender == xvsVaultStrategyProxy.admin(), "only proxy admin can change brains");
        xvsVaultStrategyProxy._acceptImplementation();
    }

    // Only allow to set the admin vault once. 
    function setAdminVault(address _adminVault) external nonReentrant {
        require(_adminVault != address(0), "Zero address");
        require(_adminVault.isContract(), "call to non-XVSVaultStrategy contract");
        require(adminVault == address(0), "Admin vault is already set");
        adminVault = _adminVault;
    }

    function emergencyTranfer() external nonReentrant onlyAdmin {
        uint256 eligibleWithdrawalAmount = IXVSVault(xvsVault).getEligibleWithdrawalAmount(xvs, pid, address(this));
        if (eligibleWithdrawalAmount > 0) {
            // Transfer the staked XVS from user vault contract to the user wallet
            IXVSVault(xvsVault).executeWithdrawal(xvs, pid);
        }

        // calculate the current available amount which is not yet requested to be withdrawn
        (uint256 amount, , uint256 pendingWithdrawals) = IXVSVault(xvsVault).getUserInfo(xvs, pid, address(this));
        uint256 stakeAmount = amount.sub(pendingWithdrawals);
        if (stakeAmount > 0) {
            IXVSVault(xvsVault).requestWithdrawal(xvs, pid, stakeAmount);
        }

        // Transfer XVS to admin wallet
        IBEP20(xvs).safeTransferFrom(address(this), admin, IBEP20(xvs).balanceOf(address(this)));
    }
}

pragma solidity ^0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }


    function ceil(uint a, uint m) internal pure returns (uint256) {
        return ((a + m - 1) / m) * m;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity ^0.5.16;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        // solium-disable-next-line security/no-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}