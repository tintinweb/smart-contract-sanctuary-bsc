/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 *Submitted for verification at BSCScan.com on 2022-04-16
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/*
SPACE RACE - BSC Opera $BSC miner
*/

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
     * @dev Gets a random number of the specified size
     *
     */
    function rand(uint256 _length) internal view returns (uint256) {
        uint256 random = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        return random % _length;
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SapceRace is Context, Ownable {
    struct WhiteList {
        bool isWhiteList;
        bool Bought;
    }

    using SafeMath for uint256;

    uint256 private SPACES_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 5;
    uint256 private BOOST_PERCENT = 525;
    uint256 private constant DEPOSIT_MAX_AMOUNT_15MINUTES = 0.5 ether;
    uint256 private constant DEPOSIT_MAX_AMOUNT_30MINUTES = 1 ether;
    bool private initialized = false;

    address payable private recAdd;
    mapping(address => uint256) private hatcheryMiners;
    mapping(address => uint256) private claimedSpaces;
    mapping(address => uint256) private lastHatch;
    mapping(address => address) private referrals;
    mapping(address => uint256) private rewardsMiner;
    mapping(address => uint256) private rewardsEarnings;
    uint256 private marketSpaces;
    uint256 private startTime = 0;
    uint256 private raffleLimit = 0;
    uint256 private userCount = 0;

    constructor() {
        recAdd = payable(msg.sender);
        transferOwnership(msg.sender);
    }

    function hatchSpaces(address ref, bool raffle) public returns (uint256) {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }
        uint256 res = 0;
        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 spacesUsed = getMySpaces(msg.sender);
        uint256 newMiners = SafeMath.div(spacesUsed, SPACES_TO_HATCH_1MINERS);
        if (raffle) {
            uint256 r = SafeMath.rand(1000);
            if (r < BOOST_PERCENT) {
                newMiners = 0;
                res = 1; //lost
            } else {
                newMiners = newMiners * 2;
                rewardsMiner[msg.sender] = SafeMath.add(
                    rewardsMiner[msg.sender],
                    newMiners
                );
                res = 2; //win
            }
        }
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiners
        );
        claimedSpaces[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        //send referral spaces
        claimedSpaces[referrals[msg.sender]] = SafeMath.add(
            claimedSpaces[referrals[msg.sender]],
            SafeMath.div(spacesUsed, 8)
        );

        //boost market to nerf miners hoarding
        marketSpaces = SafeMath.add(marketSpaces, SafeMath.div(spacesUsed, 5));
        return res;
    }

    function sellSpace(bool raffle) public returns (uint16) {
        require(initialized);
        uint16 res = 0;
        uint256 hasSpaces = getMySpaces(msg.sender);
        uint256 spaceValue = calculateSpacesSell(hasSpaces);
        uint256 fee = devFee(spaceValue);
        uint256 transferValue = SafeMath.sub(spaceValue, fee);
        uint256 remainder = spaceValue - raffleLimit;
        remainder = remainder > 0 ? remainder : 0;
        if (raffleLimit > 0 && raffle) {
            uint256 r = SafeMath.rand(1000);
            if (r < BOOST_PERCENT) {
                //lost
                transferValue = remainder;
                res = 1;
            } else {
                //win
                if (remainder > 0) {
                    transferValue = raffleLimit + spaceValue;
                    rewardsEarnings[msg.sender] = SafeMath.add(
                        rewardsEarnings[msg.sender],
                        raffleLimit
                    );
                } else {
                    transferValue = spaceValue * 2;
                    rewardsEarnings[msg.sender] = SafeMath.add(
                        rewardsEarnings[msg.sender],
                        spaceValue
                    );
                }
                fee = devFee(transferValue);
                fee = fee * 2;
                transferValue = SafeMath.sub(transferValue, fee);
                res = 2;
            }
        }

        claimedSpaces[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketSpaces = SafeMath.add(marketSpaces, hasSpaces);
        recAdd.transfer(fee);
        if (transferValue > 0) payable(msg.sender).transfer(transferValue);
        return res;
    }

    function beanRewards(address adr) public view returns (uint256) {
        uint256 hasSpaces = getMySpaces(adr);
        uint256 spaceValue = calculateSpacesSell(hasSpaces);
        return spaceValue;
    }

    function buySpaces(address ref) public payable {
        require(initialized);
        if (block.timestamp - startTime < 900) {
            require(
                msg.value <= DEPOSIT_MAX_AMOUNT_15MINUTES,
                "Amount must be less than 0.5"
            );
        }
        if (
            block.timestamp - startTime >= 900 &&
            block.timestamp - startTime < 1800
        ) {
            require(
                msg.value <= DEPOSIT_MAX_AMOUNT_30MINUTES,
                "Amount must be less than 1"
            );
        }
        uint256 spacesBought = calculateSpacesBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        userCount = userCount + 1;
        spacesBought = SafeMath.sub(spacesBought, devFee(spacesBought));
        uint256 fee = devFee(msg.value);
        recAdd.transfer(fee);
        claimedSpaces[msg.sender] = SafeMath.add(
            claimedSpaces[msg.sender],
            spacesBought
        );
        hatchSpaces(ref, false);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function checkLimit() public view returns (uint16) {
        if (startTime == 0) {
            // not start
            return 0;
        }
        if (block.timestamp - startTime > 1800) {
            // no limit
            return 1;
        }
        if (block.timestamp - startTime < 900) {
            // limit 0.5
            return 2;
        }
        return 3; //limit 1
    }

    function calculateSpacesSell(uint256 spaces) public view returns (uint256) {
        return calculateTrade(spaces, marketSpaces, address(this).balance);
    }

    function calculateSpacesBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketSpaces);
    }

    function calculateSpacesBuySimple(uint256 eth) public view returns (uint256) {
        return calculateSpacesBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function getRewardMiners(address adr) public view returns (uint256) {
        return rewardsMiner[adr];
    }

    function getRewardEarnings(address adr) public view returns (uint256) {
        return rewardsEarnings[adr];
    }

    function seedMarket() public payable onlyOwner {
        require(marketSpaces == 0);
        initialized = true;
        marketSpaces = 108000000000;
        startTime = block.timestamp;
    }

    function setRaffleLimit(uint256 value) public onlyOwner {
        raffleLimit = value;
    }

    function getRaffleLimit() public view returns (uint256) {
        return raffleLimit;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return hatcheryMiners[adr];
    }

    function getMySpaces(address adr) public view returns (uint256) {
        return SafeMath.add(claimedSpaces[adr], getSpacesSinceLastHatch(adr));
    }

    function getSpacesSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            SPACES_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}