// SPDX-License-Identifier: No License

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Presales is Ownable, ReentrancyGuard {

    IERC20 public BUSD;
    address public recipientAddress;
    uint256 public minContribution;      
    uint256 public maxContribution;   
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public totalRaised;
    uint256 public hardcap;

    mapping(address => uint256) public userContribution;
    address[] public participantAddressList;

    constructor(
        address _busd, address _recipientAddress, uint256 _minContribution, uint256 _maxContribution, 
        uint256 _startTimestamp, uint256 _endTimestamp, uint256 _hardcap) {

        BUSD = IERC20(_busd);
        recipientAddress = _recipientAddress;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        hardcap = _hardcap;  
    }

    function contribute(uint256 _contribution) external nonReentrant {
        require(block.timestamp >= startTimestamp, "Presale not started yet");
		require(block.timestamp <= endTimestamp, "Presale ended");
        require(totalRaised + _contribution <= hardcap, "Hardcap reached");
        require(BUSD.balanceOf(msg.sender) >= _contribution, "Insufficient BUSD");

        uint256 _totalContribution = userContribution[msg.sender] + _contribution;

        require(_totalContribution <= maxContribution, "Total contribution exceeded maximum contribution threshold");
        require(_totalContribution >= minContribution, "Contribution is lower than minimum contribution threshold");

        //Forward funds to treasury
        bool _status = forwardFunds(msg.sender, recipientAddress, _contribution);
        require(_status, "Failed to transfer fund");

        //Add participants count if participant never contribute before
        if(userContribution[msg.sender] == 0)
            participantAddressList.push(msg.sender);

        userContribution[msg.sender] += _contribution;
        totalRaised += _contribution;

        emit Contribute(msg.sender, _contribution);
    }

    function forwardFunds(address from, address to, uint256 amount) internal returns (bool) {
        bool _status = IERC20(BUSD).transferFrom(from, to, amount);

        emit ForwardFunds(from, to, amount);
        return _status;
    }

    function getTotalParticipants() external view returns (uint256) {
        return participantAddressList.length;
    }

    function setRecipientAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Zero address");
        recipientAddress = _newAddress;

        emit SetRecipientAddress(_newAddress);
    }

    function setContribution(uint256 _minContribution, uint256 _maxContribution) external onlyOwner {
        minContribution = _minContribution;
        maxContribution = _maxContribution;

        emit SetContribution(_minContribution, _maxContribution);
    }

    function setStartEndTime(uint256 _startTimestamp, uint256 _endTimestamp) external onlyOwner {
        require(_startTimestamp < _endTimestamp, "Start time must before end time");
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        
        emit SetStartEndTime(_startTimestamp, _endTimestamp);
    }

    function setHardcap(uint256 _hardcap) external onlyOwner {
        require(_hardcap >= 0, "Value must be larger than zero");
        hardcap = _hardcap;

        emit SetHardcap(hardcap);
    }

    function rescueToken(address _token, address _to) external onlyOwner {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);
    }

    event Contribute(address account, uint256 contribution);
    event ForwardFunds(address from, address to, uint256 amount);
    event SetRecipientAddress(address newAddress);
    event SetContribution(uint256 minContribution, uint256 maxContribution);
    event SetStartEndTime(uint256 startTimestamp, uint256 endTimestamp);
    event SetHardcap(uint256 hardcap);
    event RescueToken(address token, address to);
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

// SPDX-License-Identifier: MIT
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