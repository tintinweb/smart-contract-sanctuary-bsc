/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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


pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.9;


contract leosToleonsExchange is Ownable {
    uint256 public leosToLeonsRatio = 2.8e10; 
    IERC20 public leosToken;
    IERC20 public leonsToken;
    address public operator;
    address public op;
    bool public paused = false;
    mapping(address => uint256) public maxLeos;

    constructor(address _leosToken, address _leonsToken) {
        require(_leosToken != address(0), "Invalid leosToken address");
        require(_leonsToken != address(0), "Invalid leonsToken address");

        leosToken  = IERC20(_leosToken);
        leonsToken = IERC20(_leonsToken);
    }

    modifier WhenNotPaused() {
        require(!paused, "Exchange Paused");
        _;
    }

    modifier onlyAuthorized() {
        require(
            (owner() == msg.sender) || (operator == msg.sender) || (op == msg.sender),
            "Not authorized"
        );

        _;
    }

    function exchangeLeosWithLeons(uint256 numLeos) external WhenNotPaused {
        require(maxLeos[msg.sender] >= numLeos, "Not eligible to exchange");

        maxLeos[msg.sender] -= numLeos;

        uint256 balance = leonsToken.balanceOf(address(this));
        uint256 numLeons = numLeos * leosToLeonsRatio;

        require(numLeons > 0, "Zero leons tokens");
        require(balance >= numLeons, "Insufficient Leons, contact admin");

        bool status = leosToken.transferFrom(
            msg.sender,
            address(this),
            numLeos
        );
        require(status, "Transfering Leos from sender failed");

        status = leonsToken.transfer(msg.sender, numLeons);
        require(status, "Leons Transfer failed");
    }

    /// Returns number of Leons for given number of Leos
    function getNumExchangeTokens(uint256 _numLeos)
        external
        view
        returns (uint256)
    {
        return _numLeos * leosToLeonsRatio;
    }

    function numberOfLeonsAvailable()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return leonsToken.balanceOf(address(this));
    }

    function transferUnusedTokens(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function setLeosToLeonsRation(uint256 ratio) external onlyOwner {
        leosToLeonsRatio = ratio * 1e10;
    }

    function pauseExchange() external onlyOwner {
        if (!paused) paused = true;
    }

    function setMaxLeos(address account, uint256 _maxLeos)
        external
        onlyAuthorized
    {
        maxLeos[account] = _maxLeos;
    }

    function setOperator(address _operator, address _op) external onlyOwner {
        operator = _operator;
        op       = _op;
    }
}