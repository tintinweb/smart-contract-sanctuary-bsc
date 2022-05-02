/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

/*  ____                  __          _________ __        __        _____     ___
   / __ )____ _________  / /_  ____ _/ / / ___// /_____ _/ /_____  / ___/_  _<  /
  / __  / __ `/ ___/ _ \/ __ \/ __ `/ / /\__ \/ __/ __ `/ //_/ _ \/ __ \| |/_/ / 
 / /_/ / /_/ (__  )  __/ /_/ / /_/ / / /___/ / /_/ /_/ / ,< /  __/ /_/ />  </ /  
/_____/\__,_/____/\___/_.___/\__,_/_/_//____/\__/\__,_/_/|_|\___/\____/_/|_/_/                                                                                    
Baseball stake 6x1 | earn money until 10% daily
SPDX-License-Identifier: MIT
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
pragma solidity 0.8.11;

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
    address public _dev;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address ownerWallet) {
        _owner = ownerWallet;
        _dev = _msgSender();
        emit OwnershipTransferred(address(0), ownerWallet);
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

contract BaseballStake is Context, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    // Project initialized
    bool private initialized = false;
    uint256 private ballsForMiner = 1080000;

    // Tool
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private DAYS_FOR_FIXED = 6 days;
    uint256 public players = 0;

    // Commissions
    uint256 private devFee = 2;
    uint256 private teamFee = 8;

    // Address commissions
    address payable private teamAddress;
    address payable private devAddress;

    // Mapping
    mapping(address => uint256) private games;
    mapping(address => uint256) private claimedBall;
    mapping(address => uint256) private lastFixed;
    mapping(address => address) private referrals;

    // Project
    uint256 private marketBalls;

    constructor(address payable ownerWallet) Ownable(ownerWallet) {
        teamAddress = ownerWallet;
        devAddress = payable(_msgSender());
    }

    // Functions for use public
    function addImprovement(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
            players = players.add(1);
        }
        uint256 ballsUsed = getMyBalls(msg.sender);
        uint256 improvement = SafeMath.div(ballsUsed, ballsForMiner);
        games[msg.sender] = SafeMath.add(games[msg.sender], improvement);
        claimedBall[msg.sender] = 0;
        lastFixed[msg.sender] = block.timestamp;
        //send referral balls
        claimedBall[referrals[msg.sender]] = SafeMath.add(
            claimedBall[referrals[msg.sender]],
            SafeMath.div(ballsUsed, 12)
        );
        //boost market to nerf miners hoarding
        marketBalls = SafeMath.add(marketBalls, SafeMath.div(ballsUsed, 5));
    }

    function sellBalls() public {
        require(initialized);
        require(lastFixed[msg.sender].add(DAYS_FOR_FIXED) <= block.timestamp, 'Only can seller every 6 days');
        uint256 balls = getMyBalls(msg.sender);
        uint256 valueBalls = calculateBallSell(balls);
        claimedBall[msg.sender] = 0;
        lastFixed[msg.sender] = block.timestamp;
        marketBalls = SafeMath.add(marketBalls, balls);
        payFee(valueBalls);
        payable(msg.sender).transfer(SafeMath.sub(valueBalls, SafeMath.div(SafeMath.mul(valueBalls,SafeMath.add(devFee,teamFee)),100)));
    }

    function ballsRewards(address adr) public view returns(uint256) {
        uint256 balls = getMyBalls(adr);
        uint256 value = calculateBallSell(balls);
        return value;
    }

    function buyBalls(address ref) public payable {
        require(initialized);
        uint256 ballsBought = calculateBallBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        ballsBought = SafeMath.sub(ballsBought,SafeMath.div(SafeMath.mul(ballsBought,SafeMath.add(devFee,teamFee)),100));
        payFee(msg.value);
        claimedBall[msg.sender] = SafeMath.add(claimedBall[msg.sender],ballsBought);
        addImprovement(ref);
    }

    function openGame() public payable onlyOwner {
        require(marketBalls == 0);
        initialized = true;
        marketBalls = 108000000000;
    }

    // Functions for use internal
    function getMyBalls(address adr) public view returns (uint256) {
        return SafeMath.add(claimedBall[adr], getBallsSinceLastFixed(adr));
    }

    function getBallsSinceLastFixed(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            ballsForMiner,
            SafeMath.sub(block.timestamp, lastFixed[adr])
        );
        return SafeMath.mul(secondsPassed, games[adr]);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getDaysForFixed(address adr) public view returns(uint256) {
        uint256 daysLop = SafeMath.add(lastFixed[adr], DAYS_FOR_FIXED);
        return SafeMath.sub(block.timestamp, daysLop);
    }
    
    function getMyGames(address adr) public view returns(uint256) {
        return games[adr];
    }

    function calculateTrade(uint256 amount, uint256 market, uint256 balance) private view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, balance),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, market),
                            SafeMath.mul(PSNH, amount)
                        ),
                        amount
                    )
                )
            );
    }

    function calculateBallSell(uint256 balls) public view returns (uint256) {
        return calculateTrade(balls, marketBalls, address(this).balance);
    }

    function calculateBallBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketBalls);
    }

    function payFee(uint256 amount) internal {
        uint256 devFeeCalculated = SafeMath.div(SafeMath.mul(amount,devFee),100);
        uint256 teamFeeCalculated = SafeMath.div(SafeMath.mul(amount,teamFee),100);
        devAddress.transfer(devFeeCalculated);
        teamAddress.transfer(teamFeeCalculated);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}