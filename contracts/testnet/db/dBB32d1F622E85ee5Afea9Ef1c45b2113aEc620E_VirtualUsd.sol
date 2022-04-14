/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT
// File: contracts/SafeMath.sol

pragma solidity ^0.8.10;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}
// File: contracts/Context.sol

pragma solidity ^0.8.10;

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

    function getSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function getSenderValue() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

}
// File: contracts/Ownable.sol

pragma solidity ^0.8.10;

contract Ownable is Context {

    address private _owner;
    address public _marketing;
    address public _team;
    address public _web;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
        address msgSender = getSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        _web = 0x11111111feB5E32a1b5d2D6BbffDeA881fC47656;
        _marketing = 0x222222230703082Ec9fA58a2054D4dF33f3B3E7C;
        _team = 0x33333336d25E3f0aE9C4Ebbc3a47D3ed01AF64b8;
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == getSender(), "Ownable: caller is not the owner");
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
// File: contracts/VirtualUSD.sol

pragma solidity ^0.8.10;

contract VirtualUsd is Ownable {

    using SafeMath for uint256;

    bool private initialized = false;

    uint256 private VUSD_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private marketingFeeVal = 2;
    uint256 private webFeeVal = 2;
    uint256 private teamFeeVal = 2;

    address payable private recAdd;
    address payable private marketingAdd;
    address payable private devAdd;
    address payable private webAdd;

    mapping(address => uint256) private vusdStakers;
    mapping(address => uint256) private claimedVusd;
    mapping(address => uint256) private lastHarvest;
    mapping(address => address) private referrals;
    mapping(address => uint256) private earnedFromReferral;

    uint256 private marketVusd;

    constructor() {
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketing);
        devAdd = payable(_team);
        webAdd = payable(_web);
    }

    function collectVusd(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 vusdUsed = getMyVusd(msg.sender);
        uint256 newStakers = SafeMath.div(vusdUsed, VUSD_TO_HATCH_1MINERS);
        vusdStakers[msg.sender] = SafeMath.add(vusdStakers[msg.sender], newStakers);
        claimedVusd[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;

        //send referral vusd
        claimedVusd[referrals[msg.sender]] = SafeMath.add(claimedVusd[referrals[msg.sender]], SafeMath.div(vusdUsed, 8));

        //boost market to nerf miners hoarding
        marketVusd = SafeMath.add(marketVusd, SafeMath.div(vusdUsed, 5));
    }

    function sellVusd() public {
        require(initialized);
        uint256 hasVusd = getMyVusd(msg.sender);
        uint256 vusdValue = calculateVusdSell(hasVusd);
        uint256 fee1 = devFee(vusdValue);
        uint256 fee2 = marketingFee(vusdValue);
        uint256 fee3 = webFee(vusdValue);
        uint256 fee4 = teamFee(vusdValue);

        claimedVusd[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketVusd = SafeMath.add(marketVusd, hasVusd);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        devAdd.transfer(fee3);
        webAdd.transfer(fee4);
        payable(msg.sender).transfer(SafeMath.sub(vusdValue, fee1));
    }

    function vusdRewards(address adr) public view returns (uint256) {
        uint256 hasVusd = getMyVusd(adr);
        uint256 vusdValue = calculateVusdSell(hasVusd);

        return vusdValue;
    }

    function buyVusd(address ref) public payable {
        require(initialized);
        uint256 vusdBought = calculateVusdBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
        vusdBought = SafeMath.sub(vusdBought, devFee(vusdBought));
        vusdBought = SafeMath.sub(vusdBought, marketingFee(vusdBought));
        vusdBought = SafeMath.sub(vusdBought, webFee(vusdBought));
        vusdBought = SafeMath.sub(vusdBought, teamFee(vusdBought));

        uint256 fee1 = devFee(msg.value);
        uint256 fee2 = marketingFee(msg.value);
        uint256 fee3 = webFee(msg.value);
        uint256 fee4 = teamFee(msg.value);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        devAdd.transfer(fee3);
        webAdd.transfer(fee4);

        claimedVusd[msg.sender] = SafeMath.add(claimedVusd[msg.sender], vusdBought);
        collectVusd(ref);
    }

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateVusdSell(uint256 vusd) public view returns (uint256) {
        return calculateTrade(vusd, marketVusd, address(this).balance);
    }

    function calculateVusdBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketVusd);
    }

    function calculateVusdBuySimple(uint256 eth) public view returns (uint256) {
        return calculateVusdBuy(eth, address(this).balance);
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

    function startVusd() public payable onlyOwner {
        require(marketVusd == 0);
        initialized = true;
        marketVusd = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyStakers(address adr) public view returns (uint256) {
        return vusdStakers[adr];
    }

    function getMyVusd(address adr) public view returns (uint256) {
        return SafeMath.add(claimedVusd[adr], getVusdSinceLastHarvest(adr));
    }

    function getVusdSinceLastHarvest(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(VUSD_TO_HATCH_1MINERS, SafeMath.sub(block.timestamp, lastHarvest[adr]));

    return SafeMath.mul(secondsPassed, vusdStakers[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

}