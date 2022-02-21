pragma solidity ^0.5.16;

import "../Utils/SafeBEP20.sol";
import "../Utils/IBEP20.sol";
import "./VRTVaultProxy.sol";
import "./VRTVaultStorage.sol";
import "../Utils/WithAdmin.sol";
import "../Utils/ReentrancyGuard.sol";

contract VRTVault is WithAdmin, ReentrancyGuard, VRTVaultStorage {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    /// @notice Event emitted when admin changed
    event AdminTransfered(address indexed oldAdmin, address indexed newAdmin);

    /// @notice Event emitted on VRT deposit
    event Deposit(address indexed user, uint256 amount);

    /// @notice Event emitted when accruedInterest and VRT PrincipalAmount is withrawn
    event Withdraw(address indexed user, uint256 withdrawnAmount, uint256 totalPrincipalAmount, uint256 accruedInterest);

    /// @notice Event emitted when Admin withdraw BEP20 token from contract
    event WithdrawToken(address indexed tokenAddress, address indexed receiver, uint256 amount);

    /// @notice Event emitted when accruedInterest is claimed
    event Claim(address indexed user, uint256 interestAmount);

    constructor() public ReentrancyGuard() WithAdmin(msg.sender) {
        admin = msg.sender;
    }

    function initialize(address _vrtAddress, uint256 _interestRatePerBlock) public {
        require(msg.sender == admin, "only admin may initialize the Vault");
        require(interestRatePerBlock == 0, "Vault may only be initialized once");

        // Set initial exchange rate
        interestRatePerBlock = _interestRatePerBlock;
        require(interestRatePerBlock > 0, "interestRate Per Block must be greater than zero.");

        // Set the VRT
        vrt = IBEP20(_vrtAddress);

        _notEntered = true;
    }

    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Address cannot be Zero");
        _;
    }

    modifier userHasPosition(address userAddress) {
        UserInfo storage user = userInfo[userAddress];
        require(user.userAddress != address(0), "User doesnot have any position in the Vault.");
        _;
    }

    /**
     * @notice Deposit VRT to VRTVault for a fixed-interest-rate
     * @param depositAmount The amount to deposit to vault
     */
    function deposit(uint256 depositAmount) public nonReentrant {
        require(depositAmount > 0, "Deposit amount must be non-zero");

        address userAddress = msg.sender;
        UserInfo storage user = userInfo[userAddress];

        if(user.userAddress == address(0)){
            user.userAddress = userAddress;
            user.totalPrincipalAmount = depositAmount;
        } else{
            // accrue Interest and transfer to the user
            uint256 accruedInterest = computeAccruedInterest(user.totalPrincipalAmount, user.accrualStartBlockNumber);

            user.totalPrincipalAmount = user.totalPrincipalAmount.add(depositAmount);

            if(accruedInterest > 0){
                uint256 vrtBalance = vrt.balanceOf(address(this));
                require(vrtBalance >= accruedInterest, "Failed to transfer accruedInterest, Insufficient VRT in Vault.");
                user.totalInterestAmount = user.totalInterestAmount.add(accruedInterest);
                emit Claim(userAddress, accruedInterest);
                vrt.safeTransfer(user.userAddress, accruedInterest);
            }
        }

        user.accrualStartBlockNumber = getBlockNumber();
        emit Deposit(userAddress, depositAmount);
        vrt.safeTransferFrom(userAddress, address(this), depositAmount);
    }

    /**
     * @notice get accruedInterest of the user's VRTDeposits in the Vault
     * @param userAddress Address of User in the the Vault
     */
    function getAccruedInterest(address userAddress) public view nonZeroAddress(userAddress) returns (uint256) {
        UserInfo memory user = userInfo[userAddress];
        if(user.accrualStartBlockNumber == 0){
            return 0;
        }

        return computeAccruedInterest(user.totalPrincipalAmount, user.accrualStartBlockNumber);
    }

    /**
     * @notice get accruedInterest of the user's VRTDeposits in the Vault
     * @param totalPrincipalAmount of the User
     * @param accrualStartBlockNumber of the User
     */
    function computeAccruedInterest(uint256 totalPrincipalAmount, uint256 accrualStartBlockNumber) internal view returns (uint256) {
        
        uint256 blockNumber = getBlockNumber();

        if(accrualStartBlockNumber == 0 || accrualStartBlockNumber == blockNumber){
            return 0;
        }

        //number of blocks Since Deposit
        uint256 blockDelta = blockNumber.sub(accrualStartBlockNumber);
        uint256 accruedInterest = (totalPrincipalAmount.mul(interestRatePerBlock).mul(blockDelta)).div(1e18);
        return accruedInterest;
    }

    /**
     * @notice claim the accruedInterest of the user's VRTDeposits in the Vault
     */
    function claim() external nonReentrant userHasPosition(msg.sender) {
        address userAddress = msg.sender;
        uint256 accruedInterest = getAccruedInterest(userAddress);
        if(accruedInterest > 0){
            UserInfo storage user = userInfo[userAddress];
            user.totalInterestAmount = user.totalInterestAmount.add(accruedInterest);
            uint256 vrtBalance = vrt.balanceOf(address(this));
            require(vrtBalance >= accruedInterest, "Failed to transfer VRT, Insufficient VRT in Vault.");
            emit Claim(userAddress, accruedInterest);
            user.accrualStartBlockNumber = getBlockNumber();
            vrt.safeTransfer(user.userAddress, accruedInterest);
        }
    }

    /**
     * @notice withdraw accruedInterest and totalPrincipalAmount of the user's VRTDeposit in the Vault
     */
    function withdraw() external nonReentrant userHasPosition(msg.sender) {
        address userAddress = msg.sender;
        uint256 accruedInterest = getAccruedInterest(userAddress);

        UserInfo storage user = userInfo[userAddress];

        if(accruedInterest > 0){
            user.totalInterestAmount = user.totalInterestAmount.add(accruedInterest);
        }

        uint256 totalPrincipalAmount = user.totalPrincipalAmount;
        uint256 vrtForWithdrawal = accruedInterest.add(totalPrincipalAmount);

        uint256 vrtBalance = vrt.balanceOf(address(this));
        require(vrtBalance >= vrtForWithdrawal, "Failed to transfer VRT, Insufficient VRT in Vault.");

        emit Withdraw(userAddress, vrtForWithdrawal, totalPrincipalAmount, accruedInterest);
        vrt.safeTransfer(user.userAddress, vrtForWithdrawal);
    }

    /**
     * @notice withdraw BEP20 tokens from the contract to a recipient address.
     * @param tokenAddress address of the BEP20 token
     * @param receiver recipient of the BEP20 token
     * @param amount tokenAmount
     */
    function withdrawBep20(address tokenAddress, address receiver, uint256 amount) onlyAdmin nonZeroAddress(tokenAddress) nonZeroAddress(receiver) public {
        require(amount > 0 , "amount is invalid");
        IBEP20 token = IBEP20(tokenAddress);
        require(amount <= token.balanceOf(address(this)), "Insufficient amount in Vault");
        emit WithdrawToken(tokenAddress, receiver, amount);
        token.safeTransfer(receiver, amount);
    }

    /**
     * @dev Returns the address of the current admin
     */
    function getAdmin() public view returns (address) {
        return admin;
    }

    /**
     * @dev Burn the current admin
     */
    function burnAdmin() public onlyAdmin {
        emit AdminTransfered(admin, address(0));
        admin = address(0);
    }

    /**
     * @dev Set the current admin to new address
     */
    function setNewAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "new owner is the zero address");
        emit AdminTransfered(admin, newAdmin);
        admin = newAdmin;
    }

    /*** Admin Functions ***/

    function _become(VRTVaultProxy vrtVaultProxy) public {
        require(msg.sender == vrtVaultProxy.admin(), "only proxy admin can change brains");
        vrtVaultProxy._acceptImplementation();
    }

    function setVenusInfo(address _vrt) public onlyAdmin {
        vrt = IBEP20(_vrt);

        _notEntered = true;
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}

pragma solidity ^0.5.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
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

pragma solidity ^0.5.0;

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

pragma solidity ^0.5.16;

import "./VRTVaultStorage.sol";

contract VRTVaultProxy is VRTVaultStorage {

    /**
      * @notice Emitted when pendingVRTVaultImplementation is changed
      */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
      * @notice Emitted when pendingVRTVaultImplementation is accepted, which means VRT Vault implementation is updated
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

    constructor(address implementation_, address vrtAddress_, uint256 interestRatePerBlock_) public {
        // Creator of the contract is admin during initialization
        admin = msg.sender;

        // First delegate gets to initialize the delegator (i.e. storage contract)
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,uint256)",
                                                            vrtAddress_,
                                                            interestRatePerBlock_));

        // New implementations always get set via the settor (post-initialize)
        _setPendingImplementation(implementation_);
    }

      /**
     * @notice Internal method to delegate execution to another contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param callee The contract to delegatecall
     * @param data The raw data to delegatecall
     * @return The returned bytes from the delegatecall
     */
    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) public {

        require(msg.sender == admin, "Only admin can set Pending Implementation");

        address oldPendingImplementation = pendingVRTVaultImplementation;

        pendingVRTVaultImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingVRTVaultImplementation);
    }

    /**
    * @notice Accepts new implementation of VRT Vault. msg.sender must be pendingImplementation
    * @dev Admin function for new implementation to accept it's role as implementation
    * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
    */
    function _acceptImplementation() public {
        // Check caller is pendingImplementation
        require(msg.sender == pendingVRTVaultImplementation, "only address marked as pendingImplementation can accept Implementation");

        // Save current values for inclusion in log
        address oldImplementation = vrtVaultImplementation;
        address oldPendingImplementation = pendingVRTVaultImplementation;

        vrtVaultImplementation = pendingVRTVaultImplementation;

        pendingVRTVaultImplementation = address(0);

        emit NewImplementation(oldImplementation, vrtVaultImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingVRTVaultImplementation);
    }


    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setPendingAdmin(address newPendingAdmin) public {
        // Check caller = admin
        require(msg.sender == admin, "only admin can set pending admin");

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
    function _acceptAdmin() public {
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
    function () external payable {
        // delegate all other functions to current implementation
        (bool success, ) = vrtVaultImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}

pragma solidity ^0.5.16;
import "../Utils/SafeMath.sol";
import "../Utils/IBEP20.sol";

contract VRTVaultAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of VRT Vault
    */
    address public vrtVaultImplementation;

    /**
    * @notice Pending brains of VAI Vault
    */
    address public pendingVRTVaultImplementation;
}

contract VRTVaultStorage is VRTVaultAdminStorage {

    /// @notice The VRT TOKEN!
    IBEP20 public vrt;

    /// @notice Guard variable for re-entrancy checks
    bool internal _notEntered;

    /// @notice interestRate for accrual - per Block
    uint256 public interestRatePerBlock;

    /// @notice Info of each user.
    struct UserInfo {
        address userAddress;
        uint256 accrualStartBlockNumber;
        uint256 totalInterestAmount;
        uint256 totalPrincipalAmount;
        uint256 totalWithdrawnAmount;
        uint256 lastWithdrawnBlockNumber;
    }

    // Info of each user that stakes tokens.
    mapping(address => UserInfo) public userInfo;
}

pragma solidity ^0.5.16;


contract WithAdmin {
    /// @notice Current admin address
    address public admin;

    /// @notice The one who can become admin by calling _acceptAdmin
    address public pendingAdmin;

    /// @notice Emitted when pendingAdmin is changed
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /// @notice Emitted when pendingAdmin is accepted, which means admin is updated
    event NewAdmin(address oldAdmin, address newAdmin);

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin allowed");
        _;
    }

    constructor(address admin_) internal {
        admin = admin_;
        pendingAdmin = address(0);
    }

    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      */
    function _setPendingAdmin(address newPendingAdmin) external onlyAdmin {
        emit NewPendingAdmin(pendingAdmin, newPendingAdmin);
        pendingAdmin = newPendingAdmin;
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      */
    function _acceptAdmin() external {
        require(msg.sender == pendingAdmin, "only pending admin allowed");

        emit NewPendingAdmin(pendingAdmin, address(0));
        emit NewAdmin(admin, pendingAdmin);

        admin = pendingAdmin;
        pendingAdmin = address(0);
    }
}

pragma solidity ^0.5.16;


contract ReentrancyGuard {
    bool public _notEntered;

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     */
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }

    constructor() internal {
        _notEntered = true;
    }
}

pragma solidity ^0.5.0;

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
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
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
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
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
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
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.5;

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