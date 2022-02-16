// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

import "./Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

struct Packet {
    uint256 id;
    uint256 startTime;
    uint256 finishTime;
    uint256 paid;
    uint256 invested;
}

struct Investor {
    address referrer;
    uint256 totalInvested;
    uint256 earned;
    uint256 refReward;
    uint256 flRefs;
    uint256 slRefs;
    uint256 tlRefs;
}

struct Withdrawal {
    uint256 amount;
    uint256 timestamp;
    uint256 t; // 1 - earned withdrawals, 2 - referrals withdrawals
}

struct ReferralReward {
    address user;
    uint256 amount;
    uint256 timestamp;
}

contract RocketScience is Ownable {
    using SafeMath for uint256;

    uint256 public constant PACKET_LIFETIME = 15 * 60; //15 days;
    uint256 public constant DAY = 60; //1 days;
    uint256 public constant REF = 10;

    uint256 public constant DAILY_REWARD = 15; // %

    uint256 public totalInvest;
    uint256 public totalInvestors;

    mapping(address => Investor) investors;
    mapping(address => mapping(uint256 => uint256)) lastUpdate;

    mapping(address => uint256) refRewards;

    mapping(address => Withdrawal[]) withdrawals;
    mapping(address => ReferralReward[]) referralsRewards;

    mapping(address => mapping(address => bool)) referrals;

    mapping(address => Packet[]) userPackets;
    mapping(address => uint256) packetNumbers;

    constructor() {
        Investor memory _investorOwner;
        _investorOwner.referrer = address(this);

        investors[owner()] = _investorOwner;
        totalInvestors++;
    }

    function invest() public payable {
        require(
            msg.value >= 10000000000000000 &&
                msg.value <= 1000000000000000000000,
            "Wrong amount"
        );

        uint256 _packetId = packetNumbers[msg.sender];

        uint256 _earn = msg.value.mul(REF).div(100);

        address _referrer = investors[msg.sender].referrer;
        if (_referrer != address(0)) {
            _update(msg.sender, _referrer, _earn);
        } else {
            investors[msg.sender].referrer = owner();
            totalInvestors++;

            _update(msg.sender, owner(), _earn);
        }

        investors[msg.sender].totalInvested += msg.value;
        lastUpdate[msg.sender][_packetId] = block.timestamp;

        Packet memory _packet = Packet({
            id: _packetId,
            startTime: block.timestamp,
            finishTime: block.timestamp + PACKET_LIFETIME,
            invested: msg.value,
            paid: 0
        });

        userPackets[msg.sender].push(_packet);

        packetNumbers[msg.sender]++;
        totalInvest += msg.value;
        payable(owner()).transfer(msg.value.div(10));
    }

    function _update(
        address _user,
        address _referrer,
        uint256 _amount
    ) internal {
        if (_amount > 0) {
            ReferralReward memory _newReferralReward = ReferralReward({
                user: _user,
                amount: _amount,
                timestamp: block.timestamp
            });

            refRewards[_referrer] += _amount;
            investors[_referrer].refReward += _amount;
            referralsRewards[_referrer].push(_newReferralReward);

            if (!referrals[_referrer][_user]) {
                referrals[_referrer][_user] = true;
            }
        }
    }

    function investByRef(address _referrer) public payable {
        require(msg.sender != _referrer, "You can't invest to youself");
        require(
            msg.value >= 10000000000000000 &&
                msg.value <= 1000000000000000000000,
            "Wrong amount"
        );

        bool _isNew;
        if (investors[msg.sender].referrer == address(0)) _isNew = true;
        else _referrer = investors[msg.sender].referrer;

        if (_isNew) {
            investors[msg.sender].referrer = _referrer;
            totalInvestors++;
        }

        uint256 _packetId = packetNumbers[msg.sender];
        uint256 _earn = msg.value.mul(REF).div(100);
        _update(msg.sender, _referrer, _earn);

        investors[msg.sender].totalInvested += msg.value;

        lastUpdate[msg.sender][_packetId] = block.timestamp;

        Packet memory _packet = Packet({
            id: _packetId,
            startTime: block.timestamp,
            finishTime: block.timestamp + PACKET_LIFETIME,
            invested: msg.value,
            paid: 0
        });

        userPackets[msg.sender].push(_packet);

        packetNumbers[msg.sender]++;

        totalInvest += msg.value;
    }

    function takeInvestment(uint256 _packetId) public {
        require(packetNumbers[msg.sender] > _packetId, "Packet doesn't exist");

        uint256 _earned;
        if (
            block.timestamp > userPackets[msg.sender][_packetId].finishTime &&
            lastUpdate[msg.sender][_packetId] >
            userPackets[msg.sender][_packetId].finishTime
        ) {
            _earned = 0;
        } else if (
            block.timestamp > userPackets[msg.sender][_packetId].finishTime &&
            lastUpdate[msg.sender][_packetId] <
            userPackets[msg.sender][_packetId].finishTime
        ) {
            _earned = userPackets[msg.sender][_packetId].invested.mul(225).div(100).sub(
                userPackets[msg.sender][_packetId].paid
            );
        } else {
            _earned = userPackets[msg.sender][_packetId]
                .invested
                .mul(DAILY_REWARD)
                .mul(block.timestamp - lastUpdate[msg.sender][_packetId])
                .div(DAY)
                .div(100);
        }

        lastUpdate[msg.sender][_packetId] = block.timestamp;
        investors[msg.sender].earned += _earned;

        userPackets[msg.sender][_packetId].paid += _earned;

        payable(msg.sender).transfer(_earned);

        Withdrawal memory _withdrawal = Withdrawal({
            amount: _earned,
            timestamp: block.timestamp,
            t: 1
        });

        withdrawals[msg.sender].push(_withdrawal);
    }

    function totalClaimable(uint256 _packetId, address _user)
        public
        view
        returns (uint256)
    {
        require(packetNumbers[_user] > _packetId, "Packet doesn't exist");

        uint256 _earned;
        if (
            block.timestamp > userPackets[_user][_packetId].finishTime &&
            lastUpdate[_user][_packetId] >
            userPackets[_user][_packetId].finishTime
        ) {
            _earned = 0;
        } else if (
            block.timestamp > userPackets[_user][_packetId].finishTime &&
            lastUpdate[_user][_packetId] <
            userPackets[_user][_packetId].finishTime
        ) {
            _earned = userPackets[_user][_packetId].invested.mul(225).div(100).sub(
                userPackets[_user][_packetId].paid
            );
        } else {
            _earned = userPackets[_user][_packetId]
                .invested
                .mul(DAILY_REWARD)
                .mul(block.timestamp - lastUpdate[_user][_packetId])
                .div(DAY)
                .div(100);
        }

        return _earned;
    }

    function getReferralRewards() public {
        uint256 _reward = refRewards[msg.sender];

        refRewards[msg.sender] = 0;

        payable(msg.sender).transfer(_reward);

        Withdrawal memory _withdrawal = Withdrawal({
            amount: _reward,
            timestamp: block.timestamp,
            t: 2
        });

        withdrawals[msg.sender].push(_withdrawal);
    }

    function transfer() external payable {
        payable(msg.sender).transfer(msg.value);
    }

    function getInvestor(address _investor)
        public
        view
        returns (Investor memory)
    {
        return investors[_investor];
    }

    // function getAllPackets(address _user)
    //     public
    //     view
    //     returns (Packet[] memory)
    // {
    //     return userPackets[_user];
    // }

    function getActivePackets(address _user)
        public
        view
        returns (Packet[] memory)
    {
        Packet[] memory _allPackets = userPackets[_user];

        uint256 _size = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].finishTime > block.timestamp || _allPackets[i].paid < _allPackets[i].invested.mul(224).div(100)) {
                _size++;
            }
        }

        Packet[] memory _packets = new Packet[](_size);

        uint256 _id = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].finishTime > block.timestamp || _allPackets[i].paid < _allPackets[i].invested.mul(224).div(100)) {
                _packets[_id++] = _allPackets[i];
            }
        }

        return _packets;
    }

    function getCompletedPackets(address _user)
        public
        view
        returns (Packet[] memory)
    {
        Packet[] memory _allPackets =  userPackets[_user];

        uint256 _size = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].finishTime < block.timestamp && _allPackets[i].paid > _allPackets[i].invested.mul(224).div(100)) {
                _size++;
            }
        }

        Packet[] memory _packets = new Packet[](_size);

        uint256 _id = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].finishTime < block.timestamp && _allPackets[i].paid > _allPackets[i].invested.mul(224).div(100)) {
                _packets[_id++] = _allPackets[i];
            }
        }

        return _packets;
    }

    function getCurrentRefRewards(address _user) public view returns (uint256) {
        return refRewards[_user];
    }

    function getWithdrawals(address _user)
        public
        view
        returns (Withdrawal[] memory)
    {
        return withdrawals[_user];
    }

    function getReferralsRewards(address _user)
        public
        view
        returns (ReferralReward[] memory)
    {
        return referralsRewards[_user];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;

import "./Context.sol";


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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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