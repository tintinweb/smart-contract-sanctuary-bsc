/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

library Counters {
    struct Counter {uint256 _value;}
    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}
    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}
    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}
    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
}

contract Comn {
    address internal owner;
    bool _isRuning;
    mapping(address => bool) private callerMap;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier isRuning(){
        require(_isRuning,"Modifier: Closed");
        _;
    }
    modifier isCaller(){
        require(callerMap[msg.sender] || msg.sender == owner,"Modifier: No call permission");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function setCaller(address _address,bool _bool) external onlyOwner(){
        callerMap[_address] = _bool;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public isCaller{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public isCaller{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Sell is Comn{
    using Counters for Counters.Counter;
    Counters.Counter private _payIds;
    using SafeMath for uint256;

    //购买代币
    function buyCoin(address caller,address payContrace,address coinContract,uint coinAmountToWei) external isRuning isCaller nonReentrant returns(uint payTotal){
        if(coinAmountToWei <= 0){ _status = _NOT_ENTERED; revert("Panel : coinAmountToWei must be greater than 0"); }
        if(sellMaxMap[coinContract] < coinAmountToWei.add(buyMaxMap[coinContract])){ _status = _NOT_ENTERED; revert("Panel : nsufficient supply"); }
        if(sellPriceMap[coinContract][payContrace] <= 0){ _status = _NOT_ENTERED; revert("Panel : Sales contract is not supported"); }

        _payIds.increment();
        uint payIndex = _payIds.current() % receivePool.length;
        payTotal = sellPriceMap[coinContract][payContrace].mul(coinAmountToWei).backWei(18);
        
        ERC20(payContrace).transferFrom(caller, receivePool[payIndex], payTotal);//支付
        ERC20(coinContract).transfer(caller, coinAmountToWei);//获得
        
        buyMaxMap[coinContract] = buyMaxMap[coinContract].add(coinAmountToWei);//记录代币购买总量
    }

    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    mapping(address => uint) private sellMaxMap;                       //[设置]  售卖总量
    mapping(address => mapping(address => uint)) private sellPriceMap; //[设置]  售卖单价
    mapping(address => uint) private buyMaxMap;                        //[设置]  购买总量
    address[] private receivePool;                                     //[设置]  收款地址池

    function setReceivePool(address[] memory _pool) public onlyOwner {
        receivePool = _pool;
    }
    function setSellMax(address _contract,uint _amountToWei) public onlyOwner {
        require(_amountToWei > buyMaxMap[_contract],"Panel : Amount is too small");
        sellMaxMap[_contract] = _amountToWei;
    }
    function setSellPrice(address _coinContract,address _payContract,uint _amountToWei) public onlyOwner {
        require(_amountToWei > 0,"Panel : Price must be greater than 0");
        sellPriceMap[_coinContract][_payContract] = _amountToWei;
    }
    
    function getSellMax(address _contract) external view returns(uint amountToWei){
        amountToWei = sellMaxMap[_contract];
    }
    function getSellPrice(address _coinContract,address _payContract) external view returns(uint amountToWei){
        amountToWei = sellPriceMap[_coinContract][_payContract];
    }
    function getBuyMax(address _contract) external view returns(uint amountToWei){
        amountToWei = buyMaxMap[_contract];
    }


}