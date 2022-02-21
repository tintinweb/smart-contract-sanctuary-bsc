/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-12
 */

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
        address from,
        address to,
        uint256 value
    ) external returns (bool ok);
}

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenAirdrop is Ownable {
    using SafeMath for uint256;

    IBEP20 public airToken;

    uint256 public startDate = 1645385000; // Sunday, Feb 20 2022 07:23:20 PM UTC
    uint256 public endDate = 1645885000; // Saturday, Feb 26, 2022 02:16:40 PM UTC

    uint16 public constant AIRDROP_MULTIPLY = 150; // Airdrop 1.5x of transferred amount

    uint256 public totalDropped;

    mapping(address => uint256) public userInfo;
    mapping(address => bool) public whitelist;

    event TokensDropped(
        address indexed user,
        uint256 amount,
        uint256 amountBack
    );

    constructor(IBEP20 _airToken) public {
        airToken = _airToken;
    }

    // Claim tokens
    function claim(uint256 _amount) external {
        require(now >= startDate && now <= endDate, "Airdrop not opened");
        require(_amount > 0, "Invalid zero amount");
        require(whitelist[msg.sender], "Not white-listed account");
        require(userInfo[msg.sender] == 0, "Already claimed");

        uint256 balanceBefore = airToken.balanceOf(address(this));
        airToken.transferFrom(msg.sender, address(this), _amount);
        _amount = airToken.balanceOf(address(this)).sub(balanceBefore);

        uint256 amountBack = _amount.mul(AIRDROP_MULTIPLY).div(100);
        require(
            airToken.balanceOf(address(this)) >= amountBack,
            "Insufficient balance"
        );

        totalDropped = totalDropped.add(amountBack);
        userInfo[msg.sender] = userInfo[msg.sender].add(amountBack);
        airToken.transfer(msg.sender, amountBack);

        emit TokensDropped(msg.sender, _amount, amountBack);
    }

    // Exclude bulk accounts from whitelist
    // only owner can call this function
    function excludeBulkWhitelist(address[] memory _whitelist) external onlyOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = false;
        }
    }

    // Include bulk accounts from whitelist
    // only owner can call this function
    function includeBulkWhitelist(address[] memory _whitelist) external onlyOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    // Exclude an account from whitelist
    // only owner can call this function
    function excludeWhitelist(address _account) external onlyOwner {
        require(whitelist[_account], "Not white-listed before");
        require(userInfo[_account] == 0, "Already claimed tokens");
        whitelist[_account] = false;
    }

    // Include an account into whitelist
    // only owner can call this function
    function includeWhitelist(address _account) external onlyOwner {
        require(!whitelist[_account], "Already white-listed");
        whitelist[_account] = true;
    }

    // Set airdrop start date
    // only owner can call this function
    function setStartDate(uint256 _startDate) external onlyOwner {
        require(now <= startDate, "Airdrop started already");
        require(
            now <= _startDate,
            "Start date should be future date"
        );
        require(_startDate <= endDate, "Start date should be before end date");
        startDate = _startDate;
    }

    // Set airdrop end date
    // only owner can call this function
    function setEndDate(uint256 _endDate) external onlyOwner {
        require(now <= _endDate, "End date should be future date");
        require(startDate <= _endDate, "End date should be after start date");
        endDate = _endDate;
    }

    // End airdrop
    // only owner can call this function
    function endAirdrop() external onlyOwner {
        require(now < endDate, "Airdrop ended already");
        endDate = now;
    }

    // Withdraw remained tokens
    // only owner can call this function
    function withdrawRemainedTokens() external onlyOwner {
        uint256 remainedTokens = airToken.balanceOf(address(this));
        require(remainedTokens > 0, "No tokens remained");
        airToken.transfer(owner(), remainedTokens);
    }
}