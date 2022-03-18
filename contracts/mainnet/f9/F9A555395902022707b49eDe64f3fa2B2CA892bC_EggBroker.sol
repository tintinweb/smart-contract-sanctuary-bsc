// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract EggBroker is Ownable {
    using SafeMath for uint8;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public mebTokenAddress = 0x7268B479eb7CE8D1B37Ef1FFc3b82d7383A1162d;
    address public uCashMebPairAddress = 0x3E179eD23e9289e05D65b832b925EdCE44dC7f6f;
    address public uCashTokenAddress = 0x51160f5bD8b2f9284fE3200d256F2263098B5F44;

    mapping(address => bool) public allAccounts;
    address _creator;

    uint8 exchangeBuyRate = 15;
    uint8 exchangeSellRate = 5;
    uint8 standardTransferRate = 5;

    uint8 levelOneFriendRate = 5;
    uint8 levelTwoFriendRate = 3;
    uint8 levelThreeFriendRate = 1;
    uint256[2] levelOneFriendBalanceLimit = [1000 * 10**18, 10000 * 10**18];
    uint256[2] levelTwoFriendBalanceLimit = [2000 * 10**18, 20000 * 10**18];
    uint256[2] levelThreeFriendBalanceLimit = [3000 * 10**18, 30000 * 10**18];

    EnumerableSet.AddressSet private agentAddressSet;
    EnumerableSet.AddressSet private levelOneCountBiggerThan50AgentSet;
    mapping(address => address) public accountParentAddress;
    mapping(address => uint256) public levelOneFriendCount;
    mapping(address => uint256) public levelTwoFriendCount;
    mapping(address => uint256) public levelThreeFriendCount;

    mapping(address => uint256) public availableRewardBalance;
    mapping(address => uint256) public totalRewardBalance;

    uint8 treasuryRate = 2;
    uint256 public treasuryBalance = 0;

    uint8 initTreasuryRate = 1;
    uint256 public initTreasuryBalance = 0;

    uint8 creationMemberRate = 1;
    EnumerableSet.AddressSet private creationMemberSet;
    uint256 public creationMemberBalance = 0;

    uint8 globalRewardRate = 3;
    uint256 public globalRewardBalance = 0;

    uint8 lpHoldersBuyRate = 1;
    uint8 lpHoldersSellRate = 2;
    uint256 public lpHoldersBalance = 0;

    uint8 techRate = 1;
    uint256 public techBalance = 0;

    constructor() {
        _creator = msg.sender;
    }

    function rewardWithdraw() public {
        require(agentAddressSet.contains(msg.sender), "you are not agent yet");
        require(_verifySatisfyAgentLevel(msg.sender, 1), "You are no longger a agent");
        uint256 withdrawRewardBalance = availableRewardBalance[msg.sender];
        require(withdrawRewardBalance > 0, "Insufficient of available reward balance");
        availableRewardBalance[msg.sender] = 0;
        IERC20(address(uCashTokenAddress)).transfer(msg.sender, withdrawRewardBalance);
    }

    function setParentAddress(address parentAddress) public {
        require(parentAddress != msg.sender, "ParentAddress can`t set youself");
        require(accountParentAddress[parentAddress] != address(0) || parentAddress == _creator, "Parent account is not actived");
        require(accountParentAddress[msg.sender] == address(0), "AccountParentAddress is exist");
        accountParentAddress[msg.sender] = parentAddress;

        levelOneFriendCount[parentAddress] = levelOneFriendCount[parentAddress].add(1);
        if (levelOneFriendCount[parentAddress] >= 50 && !levelOneCountBiggerThan50AgentSet.contains(parentAddress)) {
            levelOneCountBiggerThan50AgentSet.add(parentAddress);
        }
        address levelTwoFriendAddress = accountParentAddress[parentAddress];
        if (levelTwoFriendAddress != address(0)) {
            levelTwoFriendCount[levelTwoFriendAddress] = levelTwoFriendCount[levelTwoFriendAddress].add(1);
        }
        address levelThreeFriendAddress = accountParentAddress[levelTwoFriendAddress];
        if (levelThreeFriendAddress != address(0)) {
            levelThreeFriendCount[levelThreeFriendAddress] = levelThreeFriendCount[levelThreeFriendAddress].add(1);
        }
    }

    function accountInvite(address inviteAddress) public {
        require(inviteAddress != msg.sender, "Can`t invite youself");
        require(!allAccounts[inviteAddress], "Account is exist");
        require(accountParentAddress[msg.sender] != address(0), "Your account is not actived");
        require(accountParentAddress[inviteAddress] == address(0), "account`s parent address is already exist");
        accountParentAddress[inviteAddress] = msg.sender;

        levelOneFriendCount[msg.sender] = levelOneFriendCount[msg.sender].add(1);
        if (levelOneFriendCount[msg.sender] >= 50 && !levelOneCountBiggerThan50AgentSet.contains(msg.sender)) {
            levelOneCountBiggerThan50AgentSet.add(msg.sender);
        }
        address levelTwoFriendAddress = accountParentAddress[msg.sender];
        if (levelTwoFriendAddress != address(0)) {
            levelTwoFriendCount[levelTwoFriendAddress] = levelTwoFriendCount[levelTwoFriendAddress].add(1);
        }
        address levelThreeFriendAddress = accountParentAddress[levelTwoFriendAddress];
        if (levelThreeFriendAddress != address(0)) {
            levelThreeFriendCount[levelThreeFriendAddress] = levelThreeFriendCount[levelThreeFriendAddress].add(1);
        }
    }

    function applyAgent() public {
        require(!agentAddressSet.contains(msg.sender), "You are already an agent");
        require(accountParentAddress[msg.sender] != address(0), "Your account is not actived");
        require(IERC20(mebTokenAddress).balanceOf(msg.sender) >= levelOneFriendBalanceLimit[0], "Insufficient Balance of MEB");
        require(IERC20(uCashTokenAddress).balanceOf(msg.sender) >= levelOneFriendBalanceLimit[1], "Insufficient Balance of XU");
        agentAddressSet.add(msg.sender);
    }

    function queryAgent(address _address) public view returns (bool) {
        return agentAddressSet.contains(_address);
    }

    function addCreationMemberAddress(address creationMemberAddress) public onlyOwner {
        require(!creationMemberSet.contains(creationMemberAddress), "Mcash: Address is already exist");
        creationMemberSet.add(creationMemberAddress);
    }

    function removeCreationMemberAddress(address creationMemberAddress) public onlyOwner {
        require(creationMemberSet.contains(creationMemberAddress), "Mcash: Address is not exist");
        creationMemberSet.remove(creationMemberAddress);
    }

    function allCreationMemberAddress() public view returns (address[] memory) {
        return creationMemberSet.values();
    }

    function processCreationMemberFee() public {
        require(creationMemberBalance > 0, "Insufficient Balance of creationMemberBalance");
        require(creationMemberSet.length() > 0, "CreationMember is empty");
        uint256 perCreationMemberAmount = creationMemberBalance.div(creationMemberSet.length());
        creationMemberBalance = 0;
        for (uint256 i = 0; i < creationMemberSet.length(); i++) {
            availableRewardBalance[creationMemberSet.at(i)] = availableRewardBalance[creationMemberSet.at(i)].add(perCreationMemberAmount);
            totalRewardBalance[creationMemberSet.at(i)] = totalRewardBalance[creationMemberSet.at(i)].add(perCreationMemberAmount);
        }
    }

    function processLpHoldersBalanceFee() public {
        require(lpHoldersBalance > 0, "Insufficient Balance of lpHoldersBalance");
        require(agentAddressSet.length() > 0, "AgentAddressSet is empty");
        uint256 totalUCashMebLPAmount = 0;
        for (uint256 i = 0; i < agentAddressSet.length(); i++) {
            totalUCashMebLPAmount = totalUCashMebLPAmount.add(_getMcashMebLpBalance(agentAddressSet.at(i)));
        }
        uint256 perLpHoldersAmount = lpHoldersBalance.div(totalUCashMebLPAmount);
        lpHoldersBalance = 0;
        for (uint256 i = 0; i < agentAddressSet.length(); i++) {
            uint256 agentRewardAmount = perLpHoldersAmount.mul(_getMcashMebLpBalance(agentAddressSet.at(i)));
            availableRewardBalance[agentAddressSet.at(i)] = availableRewardBalance[agentAddressSet.at(i)].add(agentRewardAmount);
            totalRewardBalance[agentAddressSet.at(i)] = totalRewardBalance[agentAddressSet.at(i)].add(agentRewardAmount);
        }
    }

    function processTreasuryBalanceFee(address _toAddress, uint256 _amount) public onlyOwner {
        require(treasuryBalance > 0, "Insufficient of treasury balance");
        IERC20(address(uCashTokenAddress)).transfer(_toAddress, _amount);
        treasuryBalance = treasuryBalance.sub(_amount);
    }

    function processInitTreasuryBalanceFee(address _toAddress, uint256 _amount) public onlyOwner {
        require(initTreasuryBalance > 0, "Insufficient of initTreasury balance");
        IERC20(address(uCashTokenAddress)).transfer(_toAddress, _amount);
        initTreasuryBalance = initTreasuryBalance.sub(_amount);
    }

    function processTechBalanceFee(address _toAddress, uint256 _amount) public onlyOwner {
        require(techBalance > 0, "Insufficient of treasury balance");
        IERC20(address(uCashTokenAddress)).transfer(_toAddress, _amount);
        techBalance = techBalance.sub(_amount);
    }

    function initUCashAddress(address _uCashTokenAddress, address _uCashMebPairAddress) public onlyOwner {
        require(uCashTokenAddress != _uCashTokenAddress, "UCashTokenAddress is already the value");
        require(uCashMebPairAddress != _uCashMebPairAddress, "UCashMebPairAddress is already the value");
        uCashTokenAddress = _uCashTokenAddress;
        uCashMebPairAddress = _uCashMebPairAddress;
    }

    function initParentAddress(address[] calldata _address, address[] calldata _parentAddress) public onlyOwner {
        require(_address.length == _parentAddress.length, "size error");
        for (uint256 i = 0; i < _address.length; i++) {
            if (_address[i] == _parentAddress[i]) {
                continue;
            }
            if (accountParentAddress[_address[i]] != address(0)) {
                continue;
            }
            accountParentAddress[_address[i]] = _parentAddress[i];

            levelOneFriendCount[_parentAddress[i]] = levelOneFriendCount[_parentAddress[i]].add(1);
            if (levelOneFriendCount[_parentAddress[i]] >= 50 && !levelOneCountBiggerThan50AgentSet.contains(_parentAddress[i])) {
                levelOneCountBiggerThan50AgentSet.add(_parentAddress[i]);
            }
            address levelTwoFriendAddress = accountParentAddress[_parentAddress[i]];
            if (levelTwoFriendAddress != address(0)) {
                levelTwoFriendCount[levelTwoFriendAddress] = levelTwoFriendCount[levelTwoFriendAddress].add(1);
            }
            address levelThreeFriendAddress = accountParentAddress[levelTwoFriendAddress];
            if (levelThreeFriendAddress != address(0)) {
                levelThreeFriendCount[levelThreeFriendAddress] = levelThreeFriendCount[levelThreeFriendAddress].add(1);
            }
        }
    }

    function resetParentAddress(address _addr) public onlyOwner {
        require(accountParentAddress[_addr] != address(0), "This account is not actived");

        address levelOneFriendAddress = accountParentAddress[_addr];
        accountParentAddress[_addr] = address(0);
        if (levelOneFriendAddress != address(0) && levelOneFriendCount[levelOneFriendAddress] > 0) {
            levelOneFriendCount[_addr] = levelOneFriendCount[levelOneFriendAddress].sub(1);
            if (levelOneFriendCount[levelOneFriendAddress] < 50 && levelOneCountBiggerThan50AgentSet.contains(levelOneFriendAddress)) {
                levelOneCountBiggerThan50AgentSet.remove(levelOneFriendAddress);
            }
        }
        address levelTwoFriendAddress = accountParentAddress[levelOneFriendAddress];
        if (levelTwoFriendAddress != address(0) && levelTwoFriendCount[levelTwoFriendAddress] > 0) {
            levelTwoFriendCount[levelTwoFriendAddress] = levelTwoFriendCount[levelTwoFriendAddress].sub(1);
        }
        address levelThreeFriendAddress = accountParentAddress[levelTwoFriendAddress];
        if (levelThreeFriendAddress != address(0) && levelThreeFriendCount[levelThreeFriendAddress] > 0) {
            levelThreeFriendCount[levelThreeFriendAddress] = levelThreeFriendCount[levelThreeFriendAddress].sub(1);
        }
    }

    function _processBuyExchangeFee(address to, uint256 amount) external returns (uint256 exchangeBuyFee) {
        exchangeBuyFee = amount.mul(exchangeBuyRate).div(100);
        uint256 levelOneFriendFee = exchangeBuyFee.mul(levelOneFriendRate).div(exchangeBuyRate);
        uint256 levelTwoFriendFee = exchangeBuyFee.mul(levelTwoFriendRate).div(exchangeBuyRate);
        uint256 levelThreeFriendFee = exchangeBuyFee.mul(levelThreeFriendRate).div(exchangeBuyRate);
        uint256 creationMemberFee = exchangeBuyFee.mul(creationMemberRate).div(exchangeBuyRate);
        uint256 lpHoldersFee = exchangeBuyFee.mul(lpHoldersBuyRate).div(exchangeBuyRate);
        uint256 initTreasuryFee = exchangeBuyFee.mul(initTreasuryRate).div(exchangeBuyRate);
        uint256 globalRewardFee = exchangeBuyFee.mul(globalRewardRate).div(exchangeBuyRate);

        address levelOneFriend = accountParentAddress[to];
        if (levelOneFriend != address(0) && _verifySatisfyAgentLevel(levelOneFriend, 1)) {
            availableRewardBalance[levelOneFriend] = availableRewardBalance[levelOneFriend].add(levelOneFriendFee);
            totalRewardBalance[levelOneFriend] = totalRewardBalance[levelOneFriend].add(levelOneFriendFee);
        } else {
            treasuryBalance = treasuryBalance.add(levelOneFriendFee);
        }
        address levelTwoFriend = accountParentAddress[levelOneFriend];
        if (levelTwoFriend != address(0) && _verifySatisfyAgentLevel(levelTwoFriend, 2)) {
            availableRewardBalance[levelTwoFriend] = availableRewardBalance[levelTwoFriend].add(levelTwoFriendFee);
            totalRewardBalance[levelTwoFriend] = totalRewardBalance[levelTwoFriend].add(levelTwoFriendFee);
        } else {
            treasuryBalance = treasuryBalance.add(levelTwoFriendFee);
        }
        address levelThreeFriend = accountParentAddress[levelTwoFriend];
        if (levelThreeFriend != address(0) && _verifySatisfyAgentLevel(levelThreeFriend, 3)) {
            availableRewardBalance[levelThreeFriend] = availableRewardBalance[levelThreeFriend].add(levelThreeFriendFee);
            totalRewardBalance[levelThreeFriend] = totalRewardBalance[levelThreeFriend].add(levelThreeFriendFee);
        } else {
            treasuryBalance = treasuryBalance.add(levelThreeFriendFee);
        }

        creationMemberBalance = creationMemberBalance.add(creationMemberFee);
        lpHoldersBalance = lpHoldersBalance.add(lpHoldersFee);
        initTreasuryBalance = initTreasuryBalance.add(initTreasuryFee);
        globalRewardBalance = globalRewardBalance.add(globalRewardFee);

        if (!allAccounts[to]) {
            allAccounts[to] = true;
        }
    }

    function _processSellExchangeFee(uint256 amount) external returns (uint256 exchangeSellFee) {
        exchangeSellFee = amount.mul(exchangeSellRate).div(100);
        uint256 treasuryFee = exchangeSellFee.mul(treasuryRate).div(exchangeSellRate);
        uint256 lpHoldersFee = exchangeSellFee.mul(lpHoldersSellRate).div(exchangeSellRate);
        uint256 techFee = exchangeSellFee.mul(techRate).div(exchangeSellRate);
        treasuryBalance = treasuryBalance.add(treasuryFee);
        lpHoldersBalance = lpHoldersBalance.add(lpHoldersFee);
        techBalance = techBalance.add(techFee);
    }

    function _processStandardTransferFee(address to, uint256 amount) external returns (uint256 standardTransferFee) {
        standardTransferFee = amount.mul(standardTransferRate).div(100);
        if (levelOneCountBiggerThan50AgentSet.length() == 0) {
            treasuryBalance = treasuryBalance.add(standardTransferFee);
        } else {
            uint256 awardPerAgent = standardTransferFee.div(levelOneCountBiggerThan50AgentSet.length());
            for (uint256 i = 0; i < levelOneCountBiggerThan50AgentSet.length(); i++) {
                availableRewardBalance[levelOneCountBiggerThan50AgentSet.at(i)] = availableRewardBalance[levelOneCountBiggerThan50AgentSet.at(i)].add(awardPerAgent);
                totalRewardBalance[levelOneCountBiggerThan50AgentSet.at(i)] = totalRewardBalance[levelOneCountBiggerThan50AgentSet.at(i)].add(awardPerAgent);
            }
        }
        if (!allAccounts[to]) {
            allAccounts[to] = true;
        }
    }

    function _getMcashMebLpBalance(address _address) internal view returns (uint256) {
        return IERC20(uCashMebPairAddress).balanceOf(_address);
    }

    function _verifySatisfyAgentLevel(address _address, uint8 _rewardLevel) internal returns (bool) {
        if (!agentAddressSet.contains(_address)) {
            return false;
        }
        uint256 mebTokenBalance = IERC20(mebTokenAddress).balanceOf(_address);
        uint256 xuTokenBalance = IERC20(uCashTokenAddress).balanceOf(_address);
        if (mebTokenBalance >= levelThreeFriendBalanceLimit[0] && xuTokenBalance >= levelThreeFriendBalanceLimit[1]) {
            return _rewardLevel <= 3;
        } else if (mebTokenBalance >= levelTwoFriendBalanceLimit[0] && xuTokenBalance >= levelTwoFriendBalanceLimit[1]) {
            return _rewardLevel <= 2;
        } else if (mebTokenBalance >= levelOneFriendBalanceLimit[0] && xuTokenBalance >= levelOneFriendBalanceLimit[1]) {
            return _rewardLevel <= 1;
        } else {
            agentAddressSet.remove(_address);
            if (levelOneCountBiggerThan50AgentSet.contains(_address)) {
                levelOneCountBiggerThan50AgentSet.remove(_address);
            }
            return false;
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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