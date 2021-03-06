/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
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

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}


library PancakeLibrary {

    using SafeMath for uint;

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}

interface IUniswapV2Router01 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external view returns (address);
}


contract LphSpecialMallTransaction is Modifier, Util {

    using SafeMath for uint256;
    uint256 public lastDonate;
    uint256 public totalDonate;
    uint256 private donateLimit;
    mapping(address => bool) private _isBlacklist; //???????????????
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private addressTotalDonate;
    mapping(uint256 => mapping(address => uint256)) private addressPower;

    ERC20 private aetToken;
    ERC20 private usdtToken;
    address pancakePair;
    IUniswapV2Router02 public immutable uniswapV2Router;
    

     /*-------------------------------????????????-----------------------------------------*/

    //??????????????????
    address private shopAddress; //????????????????????????
    address private tenAddress; //10%????????????
    address private supernodeAddress; //????????????????????????
    address private lightNodeAddress; //?????????????????????
    address private directPushAddress; //??????????????????
    address private destroyAddress;

    //??????????????????
    uint256 private tenRatio; //10%????????????
    uint256 private supernodeRatio; //????????????????????????
    uint256 private lightNodeRatio; //?????????????????????

    uint256 private directPushAmount; //??????????????????

    /*-------------------------------????????????-----------------------------------------*/

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

        usdtToken = ERC20(0x416dD633c53e85099712bDfD28746A95291a9c37);
        aetToken = ERC20(0x6d2eA613694F288ba040CC16dA0363407E018EC4);
        pancakePair = 0x40cf74f6cEAe63EB5e7d599b5B1730b46777F7d7;

        //??????????????????
        destroyAddress = 0x000000000000000000000000000000000000dEaD;

        //????????????????????????
        shopAddress = 0xa6c406f2f55860920546c436DE92b29Df135d28c;
        //??????10%????????????
        tenAddress = 0xa09746F7bfDa96972C145603d8D7f4dB8CC1a947;
        //????????????????????????????????????
        supernodeAddress = 0x41A5A01c349A02f9F69afcC009D7Eaa300C2F0dA;
        //?????????????????????????????????
        lightNodeAddress = 0x6D1C3Fd1C31A6Ec8932a1707A57F29F13D7747aA;
        //??????????????????
        directPushAddress = 0x5fCaF1Da363B9F014f72a6D21Fa810D45b9dDEa4;
        
        //????????????10%????????????
        tenRatio = 10;
        //??????????????????????????????
        supernodeRatio = 1;
        //???????????????????????????
        lightNodeRatio = 1;
        //??????????????????
        directPushAmount = 60000000000000000000;
    }


    /*
     *  @name ????????????
     *  @param recipient ?????????
     *  @param amount ????????????
     *  @letInterestRate ?????????
     */
    function specialMallPurchase(address recipient, uint256 amount,uint256 letInterestRate) public isRunning returns(bool){
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlacklist[msg.sender] , "Transfer Restricted transfer amount");
        require(!_isBlacklist[recipient], "Transfer Restricted transfer amount");
       
        uint256 actualAmount = amount.sub(directPushAmount);
        
        //?????????????????????(?????????????????? * ?????????) 50
        uint256 letInterestRateAmount = actualAmount.mul(letInterestRate).div(100); 
        //??????????????????(?????????????????? - ???????????????) 50
        //???????????????????????????(???????????? * ??????????????????) 5
        uint256 superNodeAmount = actualAmount.mul(supernodeRatio).div(100); 
        //?????????????????????(???????????? * ???????????????) 5
        uint256 lightNodeAmount = actualAmount.mul(lightNodeRatio).div(100); 
        //????????????(?????????????????? - ??????????????? - ???????????????????????? - ?????????????????????) 40
        uint256 supplierAmount = actualAmount.sub(letInterestRateAmount).sub(superNodeAmount).sub(lightNodeAmount);
        // ?????????????????????????????????????????? (????????? / 2) 
        uint256 shopAmount = letInterestRateAmount.div(2);
        // ??????10%???????????? (????????? * 10%)
        uint256 tenAmount = letInterestRateAmount.mul(tenRatio).div(100);
        //??????Lp??????????????????(????????? /2 - 10%????????????)
        uint256 lpAmount = shopAmount.sub(tenAmount);

        _balances[recipient] = _balances[recipient].add(supplierAmount);
        _balances[shopAddress] = _balances[shopAddress].add(shopAmount);
        _balances[tenAddress] = _balances[tenAddress].add(tenAmount);
        _balances[supernodeAddress] = _balances[supernodeAddress].add(superNodeAmount);
        _balances[lightNodeAddress] = _balances[lightNodeAddress].add(lightNodeAmount);
        _balances[directPushAddress] = _balances[directPushAddress].add(directPushAmount);

        //??????????????????
        usdtToken.transferFrom(msg.sender,recipient,supplierAmount);
        usdtToken.transferFrom(msg.sender,shopAddress,shopAmount);
        usdtToken.transferFrom(msg.sender,tenAddress,tenAmount);
        usdtToken.transferFrom(msg.sender,supernodeAddress,superNodeAmount);
        usdtToken.transferFrom(msg.sender,lightNodeAddress,lightNodeAmount);
        usdtToken.transferFrom(msg.sender,directPushAddress,directPushAmount);
        //???????????????
        injectionPond(lpAmount);
        return true;
    }

    /*
     * @name ???????????????
     * @param amountToWei ????????????
     */
    function injectionPond(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        usdtToken.transferFrom(msg.sender, address(this), amountToWei);
        addressPower[block.number][msg.sender] = amountToWei;
        addressTotalDonate[msg.sender] = addressTotalDonate[msg.sender].add(amountToWei);
        totalDonate = totalDonate.add(amountToWei);
        swapUsdtToAet();
        addLiquidity();
        return true;
    }

    /*
     * @name ????????????
     */
    function swapUsdtToAet() private {
        uint256 oneAmount = usdtToken.balanceOf(address(this)).div(2);
        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(aetToken);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            oneAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /*
     * @name ???????????????
     */
    function addLiquidity() private {
        uint256 donateBalance = usdtToken.balanceOf(address(this));
        uint256 seedBalance = aetToken.balanceOf(address(this));
        uint256 reserveA = usdtToken.balanceOf(pancakePair);
        uint256 reserveB = aetToken.balanceOf(pancakePair);
        uint256 amountAOptimal = PancakeLibrary.quote(donateBalance, reserveA, reserveB);
        uint256 amountBOptimal = PancakeLibrary.quote(seedBalance, reserveB, reserveA);
        if(seedBalance > amountAOptimal) {
            uniswapV2Router.addLiquidity(
                address(usdtToken),
                address(aetToken),
                donateBalance,
                amountAOptimal,
                0,
                0,
                destroyAddress,
                block.timestamp
            );
        } else if(donateBalance > amountBOptimal) {
            uniswapV2Router.addLiquidity(
                address(aetToken),
                address(usdtToken),
                seedBalance,
                amountBOptimal,
                0,
                0,
                destroyAddress,
                block.timestamp
            );
        }
    }

    /*????????????????????????*/
    function setDirectPushAmount(uint256 _amount) public onlyOwner{
        directPushAmount = _amount;
    }

    function getDirectPushAmount() public view returns(uint256){
        return directPushAmount;
    }


    /*??????????????????????????????*/
    function setSupernodeRatio(uint256 ratio) public onlyOwner{
        supernodeRatio = ratio;
    }

    /*??????????????????????????????*/
    function getSupernodeRatio()public view returns(uint256){
        return supernodeRatio;
    }

    /*???????????????????????????*/
    function setLightNodeRatio(uint256 ratio) public onlyOwner{
        lightNodeRatio = ratio;
    }

    /*???????????????????????????*/
    function getLightNodeRatio()public view returns(uint256){
        return lightNodeRatio;
    }
  

    /*??????10%????????????*/
    function setTenRatio(uint256 ratio) public onlyOwner{
        tenRatio = ratio;
    }

    /*??????10%????????????*/
    function getTenRatio()public view returns(uint256){
        return tenRatio;
    }

    /*????????????????????????*/
    function setDirectPushAddress(address _address) public onlyOwner{
        directPushAddress = _address;
    }

    /*????????????????????????*/
    function getDappDirectPushAddress() public view returns(address){
        return directPushAddress;
    }

    /*??????????????????????????????*/
    function setSupernodeAddress(address _address) public onlyOwner{
        supernodeAddress = _address;
    }

    /*??????????????????????????????*/
    function getSuppernodeAddress() public view returns(address){
        return supernodeAddress;
    }

    /*???????????????????????????*/
    function setLightNodeAddress(address _address) public onlyOwner{
        lightNodeAddress = _address;
    }

    /*???????????????????????????*/
    function getLightNodeAddress() public view returns(address){
        return lightNodeAddress;
    }

    /*??????10%????????????*/
    function setTenAddress(address _address) public onlyOwner{
        tenAddress = _address;
    }

    /*??????10%????????????*/
    function getTenAddress() public view returns(address){
        return tenAddress;
    }

  


    /*??????usdt and aet????????????*/
    function setContractToken(address _usdtToken, address _aetToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        aetToken = ERC20(_aetToken);
    }

    /*??????????????????*/
    function setPancakePairContract(address contractAddress) public onlyOwner {
        pancakePair = contractAddress;
    }

    function getUsdtToken()  public view returns(ERC20){
        return usdtToken;
    }

    function getAetToken() public view returns(ERC20){
        return aetToken;
    }

    function getPancakePari() public view returns(address){
        return pancakePair;
    }


    function setDonateLimit(uint256 _donateLimit) public onlyOwner {
        donateLimit = _donateLimit;
    }

   
    /*??????USDT???AET?????????*/
    function approveToken() public onlyOwner {
        usdtToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        aetToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    /*???????????????*/
    function excludeCklist(address _address) public onlyOwner{
        _isBlacklist[_address] = true;
    }

    /*???????????????*/
    function includeCklist(address _address) public onlyOwner{
        _isBlacklist[_address] = false;
    }

     function isBlacklist(address _address) public view returns (bool) {
        return _isBlacklist[_address];
    }

    function getAddressDonate(address _address) public view returns(uint256 amountToWei) {
        amountToWei = addressTotalDonate[_address];
    }

    function getAddressPower(uint256 _number, address _address) public view returns(uint256 power) {
        return addressPower[_number][_address];
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}