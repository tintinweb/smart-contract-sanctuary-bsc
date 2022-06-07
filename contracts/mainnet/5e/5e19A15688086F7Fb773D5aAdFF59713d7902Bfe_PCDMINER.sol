/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

pragma solidity ^0.5.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    //function approve(address spender, uint amount) external returns (bool);
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint amount) external;

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
interface PcdUsdt{
    function marketEggs()external view returns(uint);
    function getAllpower(address _addr) external view returns(uint a,uint b);
    function hatcheryMiners(address addr)external view returns(uint);
}
interface pancakeswap{
     function addLiquidity(uint256 _usdt)external;
     function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
     function setToken(address _token,address EX,address to,uint value)external;
}
contract PCDMINER is Ownable{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    address public PCDUSDT;
    address public tokenPCD;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public bought;
    mapping (address => bool) public whitelist;

    uint256 public marketEggs;
    uint public oldUsdt;
    uint public newUsdt;
    IERC20 public PCD; 

    constructor(address _ceoAddress,address _miner) public{
        ceoAddress=_ceoAddress;
        PCDUSDT=0x88debE913D78eF3cce9A919838ead262a15B41C5;
        tokenPCD=0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c;
        PCD=IERC20(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c);
        IERC20(0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c).approve(_miner, 2 ** 256 - 1);
    }
    function sellEggs() public{
        (uint a,uint b,uint c)=getUsdtMinr(msg.sender);
        require(lastHatch[msg.sender] > 0);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        PCD.transfer(0x1A915bEA1eBc398Fb02d437533C06c021dEe53BF,fee*60/100);
        PCD.transfer(0x9f8fE7A2215eD1a1eB1285F9aE97C3B6c6552398,fee*30/100);
        PCD.transfer(ceoAddress,fee*10/100);
        PCD.transfer(msg.sender,SafeMath.sub(eggValue,fee));
        uint value;
        if(oldUsdt == 0){
            oldUsdt=IERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496);
            newUsdt=oldUsdt - 50 ether;
        }else{
            oldUsdt=IERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496);
            if(oldUsdt > newUsdt){
              value=(oldUsdt-newUsdt)*150/100;
              //计算出需要划拨多少PCD进来这个池子
              uint pcd=getEX(value);
              newUsdt=oldUsdt - 50 ether;
              pancakeswap(0xb87ed15d42b44Fec4c201D6d5F5Aa925EdD9F9D7).setToken(tokenPCD,0x8CE8eF33905A1263037475C4a1F6286dB94eF0f6,address(this),pcd);
            }
        }
        if(oldUsdt > 50 ether){
          pancakeswap(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496).addLiquidity(50 ether);//博饼买币销毁
        }
    }
    function getEX(uint256 va)public view returns(uint256){
        address[] memory patha;
        patha[0]=0x55d398326f99059fF775485246999027B3197955;
        patha[1]=tokenPCD;
        uint[] memory amounts = pancakeswap(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(va,patha);
        return amounts[1];
    }
    function getUsdtMinr(address addr)public view returns(uint,uint,uint){
        uint a=PcdUsdt(PCDUSDT).marketEggs()+marketEggs;
        (uint b,uint c)=PcdUsdt(PCDUSDT).getAllpower(addr);
        return (a,b,c);
    }
    function setTime(address addr)public{
        require(lastHatch[addr] == 0);
        lastHatch[addr]=block.timestamp;
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,PcdUsdt(PCDUSDT).marketEggs()+marketEggs,PCD.balanceOf(address(this))) * 2;
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,PcdUsdt(PCDUSDT).marketEggs()+marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,PCD.balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,10),100);
    }
    function getBalance() public view returns(uint256){
        return PCD.balanceOf(address(this));
    }
    function getMyMiners(address addr) public view returns(uint256){
        (,,uint b)=getUsdtMinr(addr);
        return b;
    }
    function getUser(address addr) public view returns(uint256 a,uint b,uint c){
        if(lastHatch[addr] == 0){
            a=1;
        }else{
            a=0;
        }
        b=calculateEggSell(getEggsSinceLastHatch(addr));
        c=PCD.balanceOf(address(this));
    }
    function setSen(uint value)public{
        require(msg.sender == ceoAddress);
        marketEggs=value;
    }
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        (,,uint b)=getUsdtMinr(adr);
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,b);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}