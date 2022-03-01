//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

error IllegalArguments();
error InsufficientBalance();
error TransferFailed();
error Unauthorized();
error ZeroAddressError();

/** TODOS
 * - comment propely
 * - add queued valut withdraw and prevent creating requests with more than the total amount of tokens in queue
 */

contract UIMVaultSync is Ownable {
    struct WithdrawRequest {
        address payable destinationAddress;
        uint256 amountInWei;
        uint256 currentConfirmationCount;
        uint256 currentDenyCount;
        bool executed;
    }

    WithdrawRequest[] public withdrawalRequests;

    /**
     * @dev Allows this contrat to recieve Ether/BNB (used for testing purposes)
     */
    receive() external payable {}

    address public uimTokenAddress;

    mapping(uint256 => mapping(address => bool)) votedByOperator;
    mapping(address => bool) public contractOperator;
    mapping(address => uint256) public tokensDeposited;

    uint256 public neededConfirmationCount;

    event UimTokenDeposit(address depositor, uint256 amount);
    event WithdrawalRequestCreated(
        uint256 withdrawalRequestId,
        address destinationAddress,
        uint256 amountInWei
    );
    event WithdrawalRequestApproved(
        uint256 withdrawalRequestId,
        address contractOperator
    );
    event WithdrawalRequestDenied(
        uint256 withdrawalRequestId,
        address contractOperator
    );
    event WithdrawalRequestExecuted(
        uint256 withdrawalRequestId,
        address destinationAddress,
        uint256 amountInWei
    );
    event OperatorAccessChanged(address operatorAddress, bool newValue);
    event ConfirmationCountChanged(uint256 newValue);

    /**
     * @dev TODO: Needs commenting
     *
     */
    constructor(
        address _uimTokenAddress,
        address[] memory _contractOperators,
        uint256 _neededConfirmationCount
    ) {
        uimTokenAddress = _uimTokenAddress;
        for (uint8 i = 0; i < _contractOperators.length; i++) {
            contractOperator[_contractOperators[i]] = true;
        }
        neededConfirmationCount = _neededConfirmationCount;
    }

    /**
     * @dev Modifier which allows only certain addresses to perform contract
     * operations. Add allowed addresses using setContractOperator function.
     */

    modifier onlyOperator() {
        if (contractOperator[msg.sender] != true) revert Unauthorized();
        _;
    }

    /**
     * @dev Sets a target address `operatorAddress`'s operator access.
     * Only available to contract owner
     */

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        if (operatorAddress == address(0)) revert ZeroAddressError();
        contractOperator[operatorAddress] = value;
        emit OperatorAccessChanged(operatorAddress, value);
    }

    /**
     * @dev Sets confirmation count //TODO: comment 
 
     */

    function setConfirmationCount(uint256 _neededConfirmationCount)
        external
        onlyOwner
    {
        neededConfirmationCount = _neededConfirmationCount;
        emit ConfirmationCountChanged(_neededConfirmationCount);
    }

    /**
     * @dev Create a whithdrawal request with a `amountInWei` of UIM Tokens.
     * this withdrawal request must be accepted by
     */
    function createWithdrawalRequest(
        address payable _destinationAddress,
        uint256 _amountInWei
    ) external onlyOperator returns (uint256 withdrawalRequestId) {
        require(
            _destinationAddress != address(0),
            "Destination cannot be the zero-address"
        );
        require(_amountInWei > 0, "Amount must be > 0 wei");
        uint256 _withdrawalRequestId = withdrawalRequests.length;
        withdrawalRequests.push(
            WithdrawRequest(_destinationAddress, _amountInWei, 0, 0, false)
        );
        emit WithdrawalRequestCreated(
            _withdrawalRequestId,
            _destinationAddress,
            _amountInWei
        );
        return withdrawalRequestId;
    }

    /**
     * @dev Create a whithdrawal request with a `amountInWei` of UIM Tokens.
     * this withdrawal request must be accepted by
     */
    function approveWithdrawalRequest(uint256 withdrawalRequestId)
        external
        onlyOperator
        returns (bool)
    {
        require(
            withdrawalRequests[withdrawalRequestId].currentConfirmationCount +
                1 <=
                neededConfirmationCount,
            "This withdrawal request already has enough confirmations"
        );
        require(
            votedByOperator[withdrawalRequestId][msg.sender] != true,
            "You have already approved this withdrawal request."
        );
        withdrawalRequests[withdrawalRequestId].currentConfirmationCount += 1;
        votedByOperator[withdrawalRequestId][msg.sender] = true;
        emit WithdrawalRequestApproved(withdrawalRequestId, msg.sender);
        return true;
    }

    /**
     * @dev Create a whithdrawal request with a `amountInWei` of UIM Tokens.
     * this withdrawal request must be accepted by
     */
    function denyWithdrawalRequest(uint256 withdrawalRequestId)
        external
        onlyOperator
        returns (bool)
    {
      
        require(
            votedByOperator[withdrawalRequestId][msg.sender] == false,
            "You have already denied this withdrawal request."
        );
       withdrawalRequests[withdrawalRequestId].currentDenyCount += 1;
        votedByOperator[withdrawalRequestId][msg.sender] = true;
        emit WithdrawalRequestDenied(withdrawalRequestId, msg.sender);
        return true;
    }

    /**
     * @dev Create a whithdrawal request with a `amountInWei` of UIM Tokens.
     * this withdrawal request must be accepted by
     */
    function sendWithdrawalRequest(uint256 withdrawalRequestId)
        external
        returns (bool)
    {
        require(
            withdrawalRequests[withdrawalRequestId].currentConfirmationCount ==
                neededConfirmationCount,
            "This withdrawal request already hasn't got enough confirmations"
        );

        require(
            withdrawalRequests[withdrawalRequestId].executed == false,
            "This withdrawal request has been already executed"
        );

        withdrawalRequests[withdrawalRequestId].executed = true;

        bool sent = IERC20(uimTokenAddress).transfer(
            withdrawalRequests[withdrawalRequestId].destinationAddress,
            withdrawalRequests[withdrawalRequestId].amountInWei
        );

        if (!sent) {
            revert TransferFailed();
        }
        emit WithdrawalRequestExecuted(
            withdrawalRequestId,
            withdrawalRequests[withdrawalRequestId].destinationAddress,
            withdrawalRequests[withdrawalRequestId].amountInWei
        );
        return true;
    }

    /**
     * @dev Get approved counter for a WithdrawalRequest
     * returns uint 700 in case the transaction has been declined by too many operators and cannot be processed anymore.
     */
    function getWithdrawalRequestConfirmationCount(uint256 withdrawalRequestId)
        external
        view
        returns (uint256)
    {
        //TODO: implement if exists
        if(withdrawalRequests[withdrawalRequestId].currentDenyCount >= neededConfirmationCount) return 700;
        return
            withdrawalRequests[withdrawalRequestId].currentConfirmationCount -
            withdrawalRequests[withdrawalRequestId].currentDenyCount;
    }

    /**
     * @dev TODO: comment propely
     */
    function getWithdrawalRequestOperatorApproval(uint256 withdrawalRequestId)
        external
        view
        returns (bool)
    {
        //TODO: implement if exists
        return votedByOperator[withdrawalRequestId][msg.sender];
    }

    /**
     * @dev Deposits a UIM token `amountInWei` from the msg.sender to the contract
     */

    function depositUimToken(uint256 amountInWei)
        external
        payable
        returns (bool)
    {
        if (amountInWei < 0) revert IllegalArguments();
        if (IERC20(uimTokenAddress).balanceOf(msg.sender) < amountInWei)
            revert InsufficientBalance();
        if (
            IERC20(uimTokenAddress).allowance(address(this), msg.sender) >=
            amountInWei
        ) revert Unauthorized();

        tokensDeposited[msg.sender] += amountInWei;

        bool sent = IERC20(uimTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amountInWei
        );

        if (!sent) {
            revert TransferFailed();
        }

        emit UimTokenDeposit(msg.sender, amountInWei);

        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}