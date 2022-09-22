/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/* JadeMine - Mine Jade, Earn BNB. Repeat */

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
    address public _marketing;
    address public _team;
    address public _web;

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
        _marketing = 0xDA838Ac665370A05F775849E2fEa403561a55D70;
        _team = 0x136B250ddd3f76fbFF8F1360f5Ca73fA596DFe12;
        _web = 0x5EBB970dEc61E336e293F292Bfe99Ef715F14edf;
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

contract JadeMine is Context, Ownable {
    using SafeMath for uint256;

    uint256 private JADES_TO_HATCH_1MINERS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private marketingFeeVal = 2;
    uint256 private webFeeVal = 2;
    uint256 private teamFeeVal = 2;
    bool private initialized = false;
    address payable private recAdd;
    address payable private marketingAdd;
    address payable private teamAdd;
    address payable private webAdd;
    mapping(address => uint256) private jadeMiners;
    mapping(address => uint256) private claimedJade;
    mapping(address => uint256) private lastHarvest;
    mapping(address => address) private referrals;
    uint256 private marketJades;

    constructor() {
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketing);
        teamAdd = payable(_team);
        webAdd = payable(_web);
    }

    function harvestJades(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 jadesUsed = getMyJades(msg.sender);
        uint256 newMiners = SafeMath.div(jadesUsed, JADES_TO_HATCH_1MINERS);
        jadeMiners[msg.sender] = SafeMath.add(
            jadeMiners[msg.sender],
            newMiners
        );
        claimedJade[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;

        //send referral jades
        claimedJade[referrals[msg.sender]] = SafeMath.add(
            claimedJade[referrals[msg.sender]],
            SafeMath.div(jadesUsed, 8)
        );

        //boost market to nerf miners hoarding
        marketJades = SafeMath.add(marketJades, SafeMath.div(jadesUsed, 5));
    }

    function sellJades() public {
        require(initialized);
        uint256 hasJades = getMyJades(msg.sender);
        uint256 jadeValue = calculateJadeSell(hasJades);
        uint256 fee1 = devFee(jadeValue);
        uint256 fee2 = marketingFee(jadeValue);
        uint256 fee3 = webFee(jadeValue);
        uint256 fee4 = teamFee(jadeValue);
        claimedJade[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketJades = SafeMath.add(marketJades, hasJades);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);
        payable(msg.sender).transfer(SafeMath.sub(jadeValue, fee1));
    }

    function jadeRewards(address adr) public view returns (uint256) {
        uint256 hasJades = getMyJades(adr);
        uint256 jadeValue = calculateJadeSell(hasJades);
        return jadeValue;
    }

    function buyJades(address ref) public payable {
        require(initialized);
        uint256 jadesBought = calculateJadeBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );
        jadesBought = SafeMath.sub(jadesBought, devFee(jadesBought));
        jadesBought = SafeMath.sub(jadesBought, marketingFee(jadesBought));
        jadesBought = SafeMath.sub(jadesBought, webFee(jadesBought));
        jadesBought = SafeMath.sub(jadesBought, teamFee(jadesBought));

        uint256 fee1 = devFee(msg.value);
        uint256 fee2 = marketingFee(msg.value);
        uint256 fee3 = webFee(msg.value);
        uint256 fee4 = teamFee(msg.value);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);

        claimedJade[msg.sender] = SafeMath.add(
            claimedJade[msg.sender],
            jadesBought
        );
        harvestJades(ref);
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

    function calculateJadeSell(uint256 rubies) public view returns (uint256) {
        return calculateTrade(rubies, marketJades, address(this).balance);
    }

    function calculateJadeBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketJades);
    }

    function calculateJadeBuySimple(uint256 eth) public view returns (uint256) {
        return calculateJadeBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function marketingFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, marketingFeeVal), 100);
    }

    function webFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, webFeeVal), 100);
    }

    function teamFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, teamFeeVal), 100);
    }

    function openMines() public payable onlyOwner {
        require(marketJades == 0);
        initialized = true;
        marketJades = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return jadeMiners[adr];
    }

    function getMyJades(address adr) public view returns (uint256) {
        return SafeMath.add(claimedJade[adr], getJadesSinceLastHarvest(adr));
    }

    function getJadesSinceLastHarvest(address adr)
        public
        view
        returns (uint256)
    {
        uint256 secondsPassed = min(
            JADES_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHarvest[adr])
        );
        return SafeMath.mul(secondsPassed, jadeMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}