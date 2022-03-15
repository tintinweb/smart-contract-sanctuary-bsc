/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract PancakePair {
    function getReserves() external virtual view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}


library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    /*
     * @dev wei convert
     * @param price
     * @param decimals
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

contract MobiusCircle is Modifier, Util {

    using SafeMath for uint;

    // mine pool
    uint private historyTotalPower; // total historical calculate power
    uint private currentTotalPower; // current total calculate power
    uint private joinCircleLimit;
    uint private minePoolRatio;
    mapping(address => uint) private addressPower;

    PancakePair pancakePair;
    ERC20 private mineToken;

    constructor() {
        joinCircleLimit = 100;
        minePoolRatio = 98;
    }

    /*
     * @dev Set up | Creator call | Set the token contract address
     * @param token Configure the address of the sell token contract
     */
    function setMineToken(address _token) public onlyOwner {
        mineToken = ERC20(_token);
    }

    /*
     * @dev Set up | Creator call | Set the Pancake trading pair contract address
     * @param contractAddress  Configure the Pancake trading pair contract address
     */
    function setPancakePairContract(address contractAddress) public onlyOwner {
        pancakePair = PancakePair(contractAddress);
    }

    /*
     * @dev Set up | Creator call | Set join circle limit
     * @param joinLimit  join circle limit
     */
    function setJoinCircleLimit(uint joinLimit) public onlyOwner {
        joinCircleLimit = joinLimit;
    }

    /*
     * @dev Set up | Creator call | Set mine pool ratio
     * @param ratio  Mine pool ratio
     */
    function setMinePoolRatio(uint ratio) public onlyOwner {
        minePoolRatio = ratio;
    }

    /*
     * @dev Update | All | Burn tokens to gain calculate power
     * @param burnNumber burn number
     */
    function joinCircle(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        uint price = queryUsdtToMobPrice(); // unit: wei
        uint circleLimit = price.mul(joinCircleLimit);
        if(amountToWei < circleLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The circle number is less than the limit");
        }
        uint power = amountToWei.div(price).mul(3);
        historyTotalPower = historyTotalPower.add(power);
        currentTotalPower = currentTotalPower.add(power);
        addressPower[msg.sender] = currentTotalPower;
        uint minePoolAmount = amountToWei.mul(minePoolRatio).div(100);
        mineToken.transferFrom(msg.sender, address(this), minePoolAmount);
        mineToken.transfer(0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD, amountToWei.sub(minePoolAmount));

        return true;
    }

    /*
     * @dev  Query | Internal call | Get the amount of MOB equivalent to 1 USDT
     */
    function queryUsdtToMobPrice() private view returns (uint256) {
        uint112 usdtSum; // LP USDT sum
        uint112 mobSum; // LP MOB sum
        uint32 lastTime; // Last trading time
        (usdtSum, mobSum, lastTime) = pancakePair.getReserves();
        uint256 usdtToMobPrice = Util.mathDivisionToFloat(mobSum, usdtSum, 18);
        return usdtToMobPrice;
    }

    function getAddressPower(address _address) public view returns(uint powerToWei) {
        return addressPower[_address];
    }

    function miningOutput(address miningAddress, uint amountToWei) public onlyApprove {
        mineToken.transfer(miningAddress, amountToWei);
    }

}