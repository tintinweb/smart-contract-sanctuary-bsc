/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/TransferHelper.sol



pragma solidity ^0.8.13;


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// File: contracts/ISTRTXCREO.sol



pragma solidity ^0.8.13;

interface ISTRTXCREO {
    function checkTgeStatus(address) external view returns(bool);
    function userTotalLocks(address) external view returns(uint256);
    function userLockConsents(address, uint256) external view returns(bool);
    function userLocksPerConsent(address, uint256) external view returns(uint256);
}

// File: contracts/Vesting.sol



pragma solidity ^0.8.13;






contract VestingSTRTxCREO_V2 is Ownable, ReentrancyGuard {

    struct UserVesting {
        uint256 totalReward;
        bool tgeStatus;
        uint256 lastRound;
    }

    mapping(address => mapping(uint256 => uint256)) public userTotalClaimed;
    
    uint256 public tge;
    uint256 public startLinear;
    address public creoToken;
    address public strtToken;

    uint256 public ratio;
    uint256 public maxReward;
    uint256 public lockableLength;
    address public locking; 

    mapping(uint256 => uint256) public linear_dateTime;
    mapping(address => mapping(uint256 => UserVesting)) public userVestingDetails;

    constructor(uint256 _tge, uint256 _startLinear, uint256 _ratio, uint256 _maxReward, address _locking, address _creoToken, address _strtToken) {
        tge = _tge;
        startLinear = _startLinear;
        ratio = _ratio;
        maxReward = _maxReward;
        locking = _locking;
        creoToken = _creoToken;
        strtToken = _strtToken;

        for(uint256 i = 1; i <= 6; i++){ 
            if(i == 1){
                linear_dateTime[i] = _startLinear;
            }
            else{
                linear_dateTime[i] = linear_dateTime[i-1] + 30 days; 
            }
        }
    }

    /**
     * @dev Records data of claimed tokens
     */
    event Claimed(
        address indexed _of,
        uint256 _lockable,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Get the linear round
     */
    function linearRound() public view returns(uint256){
        for(uint256 i = 1; i <= 6; i++){ 
            if (i < 6 && block.timestamp >= linear_dateTime[i] && block.timestamp <= linear_dateTime[i+1]) {
                return i;
            } else if (i >= 6 && block.timestamp >= linear_dateTime[6]) {
                return 6;
            }
        }
        return 0;
    }

    /**
     * @dev Claim token reward
     */
    function claim(uint256 _lockable) external nonReentrant {
        require(block.timestamp >= tge, "Can't be claimed yet");

        uint256 totalReward = userVestingDetails[msg.sender][_lockable].totalReward;
        if (totalReward == 0) {
            totalReward = calculateTotalReward(msg.sender, _lockable);
            userVestingDetails[msg.sender][_lockable].totalReward = totalReward;
        }

        require(totalReward > 0, "No rewards");
        require(userTotalClaimed[msg.sender][_lockable] < totalReward, "All claimed");

        uint256 amount = check(msg.sender, _lockable);
        require(amount > 0, "No rewards yet");

        if(!userVestingDetails[msg.sender][_lockable].tgeStatus){
            userVestingDetails[msg.sender][_lockable].tgeStatus = true;
        }

        uint256 round = linearRound();
        if(round > 0){
            userVestingDetails[msg.sender][_lockable].lastRound = round;
        }

        require(amount > 0 && IERC20Metadata(creoToken).balanceOf(address(this)) >= amount, "Not enough");
        userTotalClaimed[msg.sender][_lockable] += amount;

        TransferHelper.safeTransfer(creoToken, msg.sender, amount);

        emit Claimed(msg.sender, _lockable, amount, round);
    }

    /**
     * @dev Check available token reward
     * @param _sender address
     * @param _lockable Locking group type enum
     */
    function check(address _sender, uint256 _lockable) public view returns(uint256 amount) {
        if(block.timestamp < tge){
            return 0;
        }

        uint256 totalReward = calculateTotalReward(_sender, _lockable);
        if(totalReward == 0) {
            return 0;
        }

        if(!userVestingDetails[_sender][_lockable].tgeStatus){
            amount += (totalReward * 10) / 100; 
        }

        uint256 round = linearRound();
        if(round > 0){
            if (round == 6) { 
                amount = totalReward - userTotalClaimed[_sender][_lockable];
            } else {
                amount += (((totalReward * 90) / 100) / 6) * (round - userVestingDetails[_sender][_lockable].lastRound); 
            }
        }

        return amount;
    }

    /**
     * @dev Check total reward
     * @param _sender address
     * @param _lockable Locking group type enum
     */
    function calculateTotalReward(address _sender, uint256 _lockable) public view returns(uint256 totalReward){
        totalReward = userVestingDetails[_sender][_lockable].totalReward;
        if (totalReward == 0) {

            uint256 creoDecimal = IERC20Metadata(creoToken).decimals();
            uint256 strtDecimal = IERC20Metadata(strtToken).decimals();
            if (ISTRTXCREO(locking).userLockConsents(_sender, _lockable)) {
                totalReward = (ISTRTXCREO(locking).userLocksPerConsent(_sender, _lockable) / ratio) * 10**creoDecimal / 10**strtDecimal;
            }
        }
    }

    function saveLockingAddress(address _locking) external onlyOwner {
        locking = _locking;
    } 

    function setTge(uint256 _tge) external onlyOwner {
        tge = _tge;
    }

    function setLinear(uint256 _startLinear) external onlyOwner {
        for(uint256 i = 1; i <= 6; i++){ 
            if(i == 1){
                linear_dateTime[i] = _startLinear;
            }
            else{
                linear_dateTime[i] = linear_dateTime[i-1] + 30 days; 
            }
        }
    }

    function setMaxReward(uint256 _maxReward) external onlyOwner {
        maxReward = _maxReward;
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = IERC20Metadata(creoToken).balanceOf(address(this));
        require(balance > 0, "no amount to withdraw");
        TransferHelper.safeTransfer(creoToken, _to, balance);
    }
}