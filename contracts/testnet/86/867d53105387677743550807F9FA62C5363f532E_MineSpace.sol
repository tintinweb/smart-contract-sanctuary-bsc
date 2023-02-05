//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return payable(_owner);
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract MineSpace is Context, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint16;
    uint256 public SECONDS_IN_A_DAY=86400;

    uint256 public DIVISOR = 1000;

    uint public depositCommission;
    uint public withdrawCommission;

    uint public firstLineReferralPercent = 8;
    uint public secondLineReferralPercent = 3;
    uint public thirdLineReferralPercent = 2;
    uint public fourthLineReferralPercent = 1;
    uint public fifthLineReferralPercent = 1;

    uint256 public countUsers;
    uint256 public countLevels;
    uint256 public countInvest;

    bool public initialized = false;

    address payable public ceoAddress;
    uint16[15] public percents;
    uint16[15] public prices;

    struct Starship {
        uint16 level;
        uint256 claimDate;
        uint256 refAmount;
        uint256 refCount;
        uint256 totalRefAmount;
        uint256 balance;
        uint16 percent;
        address[] referrals;
        address parent;
        uint256 activateTime;
        uint256 totalInvest;
    }

    mapping (address => Starship) public users;

    constructor() {
        ceoAddress = payable(msg.sender);
        depositCommission = 5;
        withdrawCommission = 5;
        countUsers = 0;
        users[msg.sender].activateTime = block.timestamp;
        users[msg.sender].parent = msg.sender;

        percents = [10, 11, 12, 13, 14, 16, 17, 18, 20, 25, 30, 33, 38, 42, 50];
        prices = [10, 20, 30, 40, 50, 80, 90, 100, 150, 200, 400, 800, 1600, 3200, 5000];
    }

    function getOwner() external view returns (address payable) {
        return owner();
    }

    function init() public onlyOwner {
        initialized = true;
    }

    function getCeoCommission(uint256 _amount, bool isWithdraw) private view returns(uint256) {
        if (isWithdraw) {
            return _amount.mul(withdrawCommission).div(DIVISOR);
        } else {
            return _amount.mul(depositCommission).div(DIVISOR);
        }
    }

    function getPrices() public view returns(uint16[15] memory) {
        return prices;
    }

    function getPercents() public view returns(uint16[15] memory) {
        return percents;
    }

    function getParent(address _user) public view returns (address) {
        address parent = users[_user].parent;
        return parent;
    }

    function setCeoAddress(address newCeoAddress) public onlyOwner {
        require(newCeoAddress != address(0), "newCeoAddress: new ceo address is the zero address");
        ceoAddress = payable(newCeoAddress);
    }

    function setDepositCommissionPercent(uint _newCommission) public onlyOwner {
        require(_newCommission >= 0);
        require(_newCommission <= 30, 'Commission should be less then or equal 30');
        depositCommission = _newCommission;
    }

    function setWithdrawCommissionPercent(uint _newCommission) public onlyOwner {
        require(_newCommission >= 0);
        require(_newCommission <= 30, 'Commission should be less then or equal 30');
        withdrawCommission = _newCommission;
    }

    function getStarShip() public view returns(Starship memory) {
        return users[msg.sender];
    }

    function getUserStarShip(address _user) public view onlyOwner returns(Starship memory) {
        return users[_user];
    }

    function getBalance(address user) public view returns(uint256) {
        return _calculateBalance(user);
    }

    function getMaxIncome(address _user) public view returns(uint256) {
        if (users[_user].level == 0) {
            return 0;
        }
        return (users[_user].totalInvest).mul(percents[(users[_user].level) - 1]).div(DIVISOR);
    }

    function _calculateBalance(address user) private view returns (uint256) {
        uint256 maxBalance = getMaxIncome(user);
        if (maxBalance == 0) {
            return maxBalance;
        }
        uint256 _now = block.timestamp;
        uint256 _seconds = _now - users[user].claimDate;
        uint16 percent = users[user].percent;

        uint256 income = users[user].balance;
        income = income.add(_seconds.mul(users[user].totalInvest).mul(percent).div(DIVISOR).div(SECONDS_IN_A_DAY));
        return min(income, maxBalance);
    }

    function invest(address ref, uint8 level) public payable {
        address user = msg.sender;
        uint256 amount = msg.value;
        uint256 _now = block.timestamp;

        require(initialized, "Invest: contract is not active");
        require(users[ref].activateTime > 0, 'Invest: parent is not active');
        require(amount == (prices[level - 1]).mul(10**18).div(DIVISOR), 'Invest: error amount');
        require(level <= 15 && level > 0, "Error level");
        if (users[user].level > 0) {
            require(users[user].level + 1 == level, "Error level (current level error)");
        } else {
            require(level == 1, "Error level (current level error)");
        }
        address currentRef = ref;
        if (currentRef == user) {
            currentRef = owner();
        }

        if (users[user].parent == address(0)) {
            countUsers = countUsers + 1;

            users[user].parent = currentRef;
            users[currentRef].referrals.push(user);
            users[currentRef].refCount = users[currentRef].refCount + 1;
        } else {
            ref = users[user].parent;
        }
        createReferralIncome(user, currentRef, amount);

        if (users[user].activateTime == 0) {
            users[user].activateTime = _now;
        }


        countLevels = countLevels + 1;
        countInvest = countInvest.add(amount);

        users[user].totalInvest = users[user].totalInvest + amount;
        users[user].balance = _calculateBalance(user);
        users[user].level = level;
        users[user].percent = percents[level - 1];
        users[user].claimDate = _now;
    }

    function makeRefIncome(address fromUser, address toUser, uint256 amount) private {
        if (users[fromUser].level > users[toUser].level) {
            toUser = owner();
        }
        users[toUser].totalRefAmount = users[toUser].totalRefAmount + amount;
        users[toUser].refAmount = users[toUser].refAmount + amount;
    }

    function createReferralIncome(address user, address parent, uint256 amount) private {
        address currentParent = parent;
        makeRefIncome(user, currentParent, amount.mul(firstLineReferralPercent).div(100));

        currentParent = users[currentParent].parent;
        makeRefIncome(user, currentParent, amount.mul(secondLineReferralPercent).div(100));

        currentParent = users[currentParent].parent;
        makeRefIncome(user, currentParent, amount.mul(thirdLineReferralPercent).div(100));

        currentParent = users[currentParent].parent;
        makeRefIncome(user, currentParent, amount.mul(fourthLineReferralPercent).div(100));

        currentParent = users[currentParent].parent;
        makeRefIncome(user, currentParent, amount.mul(fifthLineReferralPercent).div(100));
    }

    function withdraw() public {
        address payable user = payable(msg.sender);

        uint256 amountOnContract = address(this).balance;
        uint256 amountToWithdraw = min(getBalance(user), amountOnContract);
        uint256 _now = block.timestamp;

        users[user].claimDate = _now;
        users[user].balance = 0;

        uint256 fee = amountToWithdraw.mul(withdrawCommission).div(100);

        owner().transfer(fee);
        user.transfer(amountToWithdraw.sub(fee));
    }

    function withdrawRef() public {
        address payable user = payable(msg.sender);

        uint256 amountOnContract = address(this).balance;
        uint256 refAmount = users[user].refAmount;
        users[user].refAmount = 0;
        uint256 amountToWithdraw = min(amountOnContract, refAmount);

        uint256 fee = amountToWithdraw.mul(withdrawCommission).div(100);
        owner().transfer(fee);
        user.transfer(amountToWithdraw.sub(fee));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}