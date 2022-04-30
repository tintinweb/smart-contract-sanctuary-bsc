/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT


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

pragma solidity 0.8.9;

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
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract BombBnb is Context, Ownable {
    using SafeMath for uint256;

    uint256 private BOMBS_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    bool private initialized = false;
    address payable private recAdd;
    mapping(address => uint256) private hatcheryMiners;
    uint256 public BOOST_FEE = 15000000000000000 wei;
    mapping(address => uint256) private claimedBombs;
    mapping(address => uint256) private lastHatch;
    uint256 private marketBombs;
    address private rugIncurance = 0x0FB4b4ce0A8B374A956deB45A044673f4783877A;

    struct Rewards {
        address ref;
        address upline1;
        address upline2;
        address upline3;
    }
    struct Timelock {
        address _userAddress;
        uint256 deadline;
    }

    struct AntiWhale {
        address _userTrackAddress;
        uint256 _amountInvest;
    }
    struct AntiWhaleOn {
        address _userAddressOn;
        uint256 status_id;
    }

    receive() external payable {}

    event NewUpline(
        address referal,
        address indexed upline1,
        address indexed upline2,
        address indexed upline3
    );

    mapping(address => Rewards) public rewards;
    mapping(address => Timelock) public timelock;
    mapping(address => AntiWhale) public antiwhale;
    mapping(address => AntiWhaleOn) public antiwhaleon;
    uint256 private boombsValue2 = 6;
    uint256 private plentyFeeVal = 40;

    constructor() {
        recAdd = payable(msg.sender);
    }

    function hatchBombs() public {
        require(initialized);
        uint256 bombsUsed = getMyBombs(msg.sender);
        uint256 newMiners = SafeMath.div(bombsUsed, BOMBS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiners
        );
        claimedBombs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        address upline1reward = rewards[msg.sender].upline1;
        address upline2reward = rewards[msg.sender].upline2;
        address upline3reward = rewards[msg.sender].upline3;

        //send referral bombs
      if (upline1reward != address(0)) {
            claimedBombs[upline1reward] = SafeMath.add(
                claimedBombs[upline1reward],
                SafeMath.div((bombsUsed * 7), 100)
            );
        }

        if (upline2reward != address(0)) {
            claimedBombs[upline2reward] = SafeMath.add(
                claimedBombs[upline2reward],
                SafeMath.div((bombsUsed * 5), 100)
            );
        }
        if (upline3reward != address(0)) {
            claimedBombs[upline3reward] = SafeMath.add(
                claimedBombs[upline3reward],
                SafeMath.div((bombsUsed * 3), 100)
            );
        }

        //boost market to nerf miners hoarding
        marketBombs = SafeMath.add(marketBombs, SafeMath.div(bombsUsed, 5));
    }

    function BoostBombs() public payable {
        // problem 3: this issue is fixed by me but please take a look okay
        require(initialized);
        require(msg.value == BOOST_FEE, "Insufficient funds");
        uint256 dev_Boost_treasury = SafeMath.div((msg.value * 40), 100);
        payable(rugIncurance).transfer(dev_Boost_treasury);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            500
        );
    }

    function sellBombs() public {
        require(initialized);
        // Timer to set again after withdraw
        require(
            block.timestamp > timelock[msg.sender].deadline,
            "You are not allowed to withdraw"
        );
        uint256 timer = block.timestamp + 0 days;
        timelock[msg.sender] = Timelock(msg.sender, timer);
        uint256 hasBombs = getMyBombs(msg.sender);
        uint256 bombValue = calculateBombSell(hasBombs);
        uint256 fee = devFee(bombValue);
        uint256 fee2 = plentyFee(bombValue);
        lastHatch[msg.sender] = block.timestamp;
        marketBombs = SafeMath.add(marketBombs, hasBombs);
        // Anti Whale Detection
        if (bombValue > antiwhale[msg.sender]._amountInvest) {
            if (antiwhaleon[msg.sender].status_id == 0) {
                recAdd.transfer(fee);
                uint256 bombRewardie = SafeMath.div((bombValue * 0), 100);
                // uint256 bombRewardie2 = SafeMath.div((bombRewardie*), 100);
                // claimedBombs[msg.sender] = bombRewardie2;
                uint256 finalReward = SafeMath.sub(bombValue, bombRewardie);
                claimedBombs[msg.sender] = bombRewardie;
                payable(msg.sender).transfer(SafeMath.sub(finalReward, fee));
            } else {
                // Anti Whale Detection Fee applied if he has disable the status of Anti Whale
                payable(recAdd).transfer(fee2);
                claimedBombs[msg.sender] = 0;
                payable(msg.sender).transfer(SafeMath.sub(bombValue, fee2));
            }
        } else {
            // those who has invested less go smooth trade. For Safety purpose.
            payable(recAdd).transfer(fee);
            claimedBombs[msg.sender] = 0;
            payable(msg.sender).transfer(SafeMath.sub(bombValue, fee));
        }
    }

    function bombRewards(address adr) public view returns (uint256) {
        uint256 hasBombs = getMyBombs(adr);
        uint256 bombValue = calculateBombSell(hasBombs);
        return bombValue;
    }

    function buyBombs(address ref) public payable {
        require(initialized);
        require(ref != msg.sender, "User can't refer themselves");
        uint256 bombsBought = calculateBombBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        bombsBought = SafeMath.sub(bombsBought, devFee(bombsBought));
        uint256 fee = bombValue2(msg.value);
        payable(rugIncurance).transfer(fee);
        claimedBombs[msg.sender] = SafeMath.add(
            claimedBombs[msg.sender],
            bombsBought
        );

        //antiwhale system
        uint256 investAmount = antiwhale[msg.sender]._amountInvest;
        uint256 investedAmount = SafeMath.add(msg.value, investAmount);
        // added values
        antiwhale[msg.sender] = AntiWhale(msg.sender, investedAmount);
        antiwhaleon[msg.sender] = AntiWhaleOn(msg.sender, 0);

        // antiwhale system end

        // Level 1 Detection
        address _upline1 = rewards[ref].ref;

        // level 2 detection
        address _upline2 = rewards[_upline1].upline1;

        // level 3 detection
        address _upline3 = rewards[_upline2].upline1;

        rewards[msg.sender] = Rewards(msg.sender, ref, _upline2, _upline3);
        emit NewUpline(msg.sender, ref, _upline2, _upline3);

        uint256 timer = block.timestamp + 0 days;
        timelock[msg.sender] = Timelock(msg.sender, timer);
    }

    function AntiWhaleStatusOff() public {
        antiwhaleon[msg.sender] = AntiWhaleOn(msg.sender, 1);
    }

    function AntiWhaleStatusOn() public {
        antiwhaleon[msg.sender] = AntiWhaleOn(msg.sender, 0);
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

    function calculateBombSell(uint256 bombs) public view returns (uint256) {
        return calculateTrade(bombs, marketBombs, address(this).balance);
    }

    function calculateBombBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketBombs);
    }

    function calculateBombBuySimple(uint256 eth) public view returns (uint256) {
        return calculateBombBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function bombValue2(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, boombsValue2), 100);
    }

    function plentyFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, plentyFeeVal), 100);
    }

    function seedMarket() public payable onlyOwner {
        require(marketBombs == 0);
        initialized = true;
        marketBombs = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return hatcheryMiners[adr];
    }

    function getMyBombs(address adr) public view returns (uint256) {
        return SafeMath.add(claimedBombs[adr], getBombsSinceLastHatch(adr));
    }

    function getBombsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            BOMBS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}