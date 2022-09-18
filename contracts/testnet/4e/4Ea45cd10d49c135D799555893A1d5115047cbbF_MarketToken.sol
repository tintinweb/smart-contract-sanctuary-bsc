/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract ERC721{
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
}

abstract contract Panel{
    function isMember(address member) external virtual returns (bool flag);
    function isBlack(address member) external virtual returns (bool flag);
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
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(){
        owner = msg.sender;
        _status = _NOT_ENTERED;
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

/** 兑换交易 **/
contract MarketToken is Comn {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    mapping(address => bool) private callerMap;     //调用者权限集合

    modifier isCaller(){
        require(callerMap[msg.sender] || msg.sender == owner,"Modifier: No casting permission");
        _;
    }

    modifier isMember(){
        bool _isMember = Panel(panelContract).isMember(msg.sender);
        require(_isMember,"Modifier: Not a member");
        _;
    }

    modifier isBlack(){
        bool _isBlack = Panel(panelContract).isBlack(msg.sender);
        require(!_isBlack,"Modifier: No permission");
        _;
    }
    
    function setCaller(address _address,bool _bool) external onlyOwner(){
        callerMap[_address] = _bool;
    }

    function buyChip(uint number) external isRuning isMember isBlack nonReentrant{
        _payIds.increment();
        uint index = _payIds.current()%chipComns.length;
        uint buyAmountToWei = number.mul(chip2TokenPrice);

        ERC20(chipBuyContract).transferFrom(msg.sender, chipComns[index], buyAmountToWei);
    }

    function usdtToNus(uint nusAmountToWei) external isRuning isMember isBlack nonReentrant{
        _payIds.increment();
        uint usdtIndex = _payIds.current() % usdtComns.length;
        uint nusIndex = _payIds.current() % nusComns.length;
        uint usdtAmountToWei = nusAmountToWei.mul(nus2UsdtPrice).backWei(18);
        
        ERC20(usdtContract).transferFrom(msg.sender, usdtComns[usdtIndex], usdtAmountToWei);
        ERC20(nusContract).transferFrom(nusComns[nusIndex], msg.sender, nusAmountToWei);
    }

    function nusToUsdt(uint usdtAmountToWei) external isRuning isMember isBlack nonReentrant{
        _payIds.increment();
        uint usdtIndex = _payIds.current() % usdtComns.length;
        uint nusIndex = _payIds.current() % nusComns.length;
        uint nusAmountToWei = usdtAmountToWei.divFloat(nus2UsdtPrice,18);

        ERC20(usdtContract).transferFrom(usdtComns[usdtIndex], msg.sender, usdtAmountToWei);
        ERC20(nusContract).transferFrom(msg.sender, nusComns[nusIndex], nusAmountToWei);
    }

    
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    Counters.Counter private _payIds;
    address[] private nusComns;                    //nus公共地址池
    address[] private usdtComns;                   //usdt公共地址池
    address[] private chipComns;                   //chip公共地址池

    address private panelContract;                 //面板合约
    address private usdtContract;                  //usdt合约地址
    address private nusContract;                   //nus合约地址
    address private chipBuyContract;               //碎片支付合约地址

    uint private nus2UsdtPrice;                    //nus/usdt价格(100 : 1 NUS = 100 USDT)
    uint private chip2TokenPrice;                  //chip/token价格(100 : 1 CHIP = 100 TOKEN)


    /*
     * 初始配置
     * @param _panelContract 面板合约
     * @param _usdtContract usdt合约地址
     * @param _nusContract nus合约地址
     * @param _chipBuyContract 碎片支付合约地址
     * @param _nus2UsdtPrice nus/usdt价格
     * @param _chip2TokenPrice chip/token价格
     */
    function setConfig(address _panelContract,address _usdtContract,address _nusContract,address _chipBuyContract,uint _nus2UsdtPrice,uint _chip2TokenPrice) public onlyOwner {
        panelContract = _panelContract;
        usdtContract = _usdtContract;
        nusContract = _nusContract;
        chipBuyContract = _chipBuyContract;
        nus2UsdtPrice = _nus2UsdtPrice;
        chip2TokenPrice = _chip2TokenPrice;
    }

    /*
     * 设置nus公共地址池
     * @param _address 公共地址池
     */
    function setNusComns(address[] memory _address) public onlyOwner {
        nusComns = _address;
    }

    /*
     * 设置usdt公共地址池
     * @param _address 公共地址池
     */
    function setUsdtComns(address[] memory _address) public onlyOwner {
        usdtComns = _address;
    }

    /*
     * 设置chip公共地址池
     * @param _address 公共地址池
     */
    function setChipComns(address[] memory _address) public onlyOwner {
        chipComns = _address;
    }

    /*
     * 添加nus公共地址
     * @param _address 公共地址
     */
    function addNusComn(address _address) public onlyOwner {
        nusComns.push(_address);
    }

    /*
     * 添加usdt公共地址
     * @param _address 公共地址
     */
    function addUsdtComn(address _address) public onlyOwner {
        usdtComns.push(_address);
    }

    /*
     * 添加chip公共地址
     * @param _address 公共地址
     */
    function addChipComn(address _address) public onlyOwner {
        chipComns.push(_address);
    }

    /*
     * 移除nus公共地址
     * @param _address 公共地址
     */
    function removeNusComn(address _address) public onlyOwner {
        uint length = nusComns.length;
        for(uint i = 0;i < length; i++){
            if(nusComns[0] == _address){
                nusComns[i] = nusComns[length-1];
                nusComns.pop();//删除末尾
                break;
            }
        }
    }

    /*
     * 移除nus公共地址
     * @param _address 公共地址
     */
    function removeUsdtComn(address _address) public onlyOwner {
        uint length = usdtComns.length;
        for(uint i = 0;i < length; i++){
            if(usdtComns[0] == _address){
                usdtComns[i] = usdtComns[length-1];
                usdtComns.pop();//删除末尾
                break;
            }
        }
    }

    /*
     * 移除chip公共地址
     * @param _address 公共地址
     */
    function removeChipComn(address _address) public onlyOwner {
        uint length = chipComns.length;
        for(uint i = 0;i < length; i++){
            if(chipComns[0] == _address){
                chipComns[i] = chipComns[length-1];
                chipComns.pop();//删除末尾
                break;
            }
        }
    }

}