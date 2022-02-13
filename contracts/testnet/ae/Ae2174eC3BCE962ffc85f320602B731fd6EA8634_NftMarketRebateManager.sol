// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./access/Ownable.sol";
import "./token/BEP20/IBEP20.sol";

contract NftMarketRebateManager is Ownable {
    struct PendingRebate {
        uint256 amount;             // The number of tokens for this rebate
        uint    claimTime;          // Timestamp of when the rebate is claimable
    }

    IBEP20  public zmbe;            // The zombie token
    uint    public vestingPeriod;   // The vesting period that tokens should be locked

    mapping (address => PendingRebate[])    public pendingRebates;      // List of pending rebates for users
    mapping (address => bool)               public marketWhitelist;     // Whitelist of market contracts allowed to add rebates

    // Events for sending out notifications when rewards are added and claimed
    event PendingRewardAdded(address indexed _user, uint _timestamp, uint256 _amount);
    event ClaimedReward(address indexed _user, uint256 _amount);

    // Constructor for initializing the contract with base values
    constructor(address _zmbe, uint _vestingPeriod) {
        zmbe = IBEP20(_zmbe);
        vestingPeriod = _vestingPeriod;
    }

    // Function for the contract owner to set the vesting period
    function setVestingPeriod(uint _vestingPeriod) public onlyOwner() {
        vestingPeriod = _vestingPeriod;
    }

    // Function for the contract owner to whitelist a market contract
    function whitelistMarket(address _market, bool _whitelisted) public onlyOwner() {
        marketWhitelist[_market] = _whitelisted;
    }

    // Function to get the calculated totals for a user
    function getUserValues(address _user) public view returns (uint256, uint256, uint256) {
        if (pendingRebates[_user].length == 0) return (0, 0, 0);

        uint256 totalPending = 0;
        uint256 available = 0;
        uint256 locked = 0;

        for (uint256 i = 0; i <= pendingRebates[_user].length - 1; i++) {
            totalPending += pendingRebates[_user][i].amount;
            if (block.timestamp >= pendingRebates[_user][i].claimTime) 
                available += pendingRebates[_user][i].amount;
            else 
                locked += pendingRebates[_user][i].amount;
        }

        return (totalPending, available, locked);
    }

    // Function for the market contract to add a rebate for a user
    function addUserRebate(address _user, uint _timestamp, uint256 _amount) public {
        require(marketWhitelist[msg.sender], 'Request from non whitelisted address');
        
        uint256 initialBalance = zmbe.balanceOf(address(this));
        zmbe.transferFrom(msg.sender, address(this), _amount);
        require((zmbe.balanceOf(address(this)) - initialBalance) >= _amount, 'Zombie token transfer failure');
        
        pendingRebates[_user].push(PendingRebate({
            amount: _amount,
            claimTime: _timestamp + vestingPeriod
        }));

        emit PendingRewardAdded(_user, _timestamp, _amount);
    }

    // Function for a user to claim a specific rebate
    function claimReward(uint _id) public {
        require(pendingRebates[msg.sender].length > 0, 'User has no pending rebates');
        require((pendingRebates[msg.sender].length - 1) >= _id, 'Invalid pending reward ID');
        require(block.timestamp >= pendingRebates[msg.sender][_id].claimTime, 'Pending reward is not available for claiming yet');
        
        uint256 initialBalance = zmbe.balanceOf(address(this));
        require(initialBalance >= pendingRebates[msg.sender][_id].amount, 'Insufficient Zombie balance');
        
        zmbe.transfer(msg.sender, pendingRebates[msg.sender][_id].amount);
        require((initialBalance - zmbe.balanceOf(address(this))) >= pendingRebates[msg.sender][_id].amount, 'Zombie token transfer failure');

        emit ClaimedReward(msg.sender, pendingRebates[msg.sender][_id].amount);

        pendingRebates[msg.sender][_id] = pendingRebates[msg.sender][pendingRebates[msg.sender].length - 1];
        pendingRebates[msg.sender].pop();
    }

    // Function for a user to claim all of their rebates
    function claimAll() public {
        uint256 claimable = 0;

        for (uint256 i = pendingRebates[msg.sender].length; i > 0; i--) {
            uint256 index = i - 1;
            if (block.timestamp >= pendingRebates[msg.sender][index].claimTime) {
                claimable += pendingRebates[msg.sender][index].amount;
                pendingRebates[msg.sender][index] = pendingRebates[msg.sender][pendingRebates[msg.sender].length - 1];
                pendingRebates[msg.sender].pop();
            }
        }
        
        require(claimable > 0, 'No claimable pending rewards');
        
        uint256 initialBalance = zmbe.balanceOf(address(this));
        require(initialBalance >= claimable, 'Insufficient zombie balance');

        zmbe.transfer(msg.sender, claimable);
        require((initialBalance - zmbe.balanceOf(address(this))) >= claimable, 'Zombie token transfer failure');
        
        emit ClaimedReward(msg.sender, claimable);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}