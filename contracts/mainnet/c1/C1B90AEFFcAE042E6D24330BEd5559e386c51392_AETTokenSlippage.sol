/**
 *Submitted for verification at BscScan.com on 2022-07-14
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


contract AETTokenSlippage is Modifier, Util {
    using SafeMath for uint256;
    address private daoAddress; //dao归集地址
    address private destroyAddress; //销毁地址
    address private bCurrencyAddress; //卖A币归集地址
    address private lightNodeAddress; //轻节点归集地址
    address private supperNodeAddress; //超级节点归集地址
    
    
    uint256 private daoRatio; //dao归集比例
    uint256 private destroyRatio; //销毁归集比例
    uint256 private lightNodeRatio; //轻节点归集比例
    uint256 private supperNodeRatio; //超级节点归集比例
    uint256 private bCurrencyRatio; //卖A币归集比例
    uint256 private buyBCurrencyRatio; //买B池归集比例
    uint256 private sellBCurrencyRatio; //卖B池归集比例
    
    
    constructor() {
        /*设置默认值*/
        daoRatio = 10; //默认dao归集比例
        destroyRatio = 20; //默认销毁归集比例
        lightNodeRatio = 10; //默认轻节点归集比例
        bCurrencyRatio = 10; //默认卖A币归集比例
        supperNodeRatio = 10; //默认超级节点归集比例
        buyBCurrencyRatio = 30; //买 B币归集比例
        sellBCurrencyRatio = 100;//卖 B币归集比例
        
        daoAddress = 0x02e96fa61720Ee43AF48a4dC8a0BDB2a51c5d926; //dao收款地址
        destroyAddress = 0x000000000000000000000000000000000000dEaD; //默认销毁地址
        bCurrencyAddress = 0xCAb0b13A0EF348933546bb7AA0F654177b005fc4; //B币归集地址
        lightNodeAddress = 0xEb3201DAE88E80bFbe24380379fb66886299f27C;//默认轻节点归集地址
        supperNodeAddress = 0x04d66E55Fb7912b4488f9bf4e970F7E4dEa1dB84;//默认超级节点归集地址
    }


    /*卖代币滑点*/
    function sellSlippage(uint256 amountToWei) public view onlyApprove returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
         (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei,false);
     }

     /*买代币滑点*/
    function buySlippage(uint256 amountToWei) public view onlyApprove returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts){
         (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei,true);
    }

    // /*计算滑点*/
     function computeSlippage(uint256 amountToWei, bool doubleFlag) private view returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        if(doubleFlag){
             //买
            slippageAddresses = new address[](4);
            slippageAmounts = new uint256[](4);

            slippageAddresses[0] = daoAddress; //dao归集地址
            slippageAddresses[1] = destroyAddress; //销毁归集地址
            slippageAddresses[2] = lightNodeAddress; //轻节点归集地址
            slippageAddresses[3] = supperNodeAddress; //超级节点归集地址
            
            slippageAmounts[0] = amountToWei.mul(daoRatio).div(1000); //dao归集比例
            slippageAmounts[1] = amountToWei.mul(destroyRatio).div(1000); //销毁归集比例
            slippageAmounts[2] = amountToWei.mul(lightNodeRatio).div(1000); //轻节点归集比例
            slippageAmounts[3] = amountToWei.mul(supperNodeRatio).div(1000); //超级节点归集比例
         }else{
             //卖
             slippageAddresses = new address[](1);
             slippageAmounts = new uint256[](1);

             slippageAddresses[0] = bCurrencyAddress; //B币收款地址
             slippageAmounts[0] = amountToWei.mul(sellBCurrencyRatio).div(1000); //B币分配比例
         }
    }

 
    /*设置卖 B币归集比例*/
    function setSellBCurrencyRatio(uint256 _ratio) public onlyOwner{
        sellBCurrencyRatio = _ratio;
    }

    /*设置卖 B币归集比例*/
    function getSellBCurrencyRatio() public view returns(uint256){
        return sellBCurrencyRatio;
    }

    /*设置卖A币归集比例*/
    function setBuyBCurrencyRatio(uint256 _ratio) public onlyOwner{
        buyBCurrencyRatio = _ratio;
    }

    /*设置卖A币归集比例*/
    function getBuyBCurrencyRatio() public view returns(uint256){
        return buyBCurrencyRatio;
    }

    /*默认卖A币归集比例*/
    function setbCurrencyRatio(uint256 _ratio) public onlyOwner{
        bCurrencyRatio = _ratio;
    }

    /*获取卖A币归集比例*/
    function getbCurrencyRatio() public view returns(uint256){
        return bCurrencyRatio;
    }
        
    /*设置超级节点归集比例*/
    function setSupperNodeRatio(uint256 _ratio) public onlyOwner{
        supperNodeRatio = _ratio;
    }

    /*获取超级节点归集比例*/
    function getSupperNodeRatio() public view returns(uint256){
        return supperNodeRatio;
    }

    /*设置轻节点归集比例*/
    function setLightNodeRatio(uint256 _ratio) public onlyOwner{
        lightNodeRatio = _ratio;
    }

    /*获取轻节点归集比例*/
    function getLightNodeRatio() public view returns(uint256){
        return lightNodeRatio;
    }

    /*设置销毁归集比例*/
    function setdestroyRatio(uint256 _ratio) public onlyOwner{
        destroyRatio = _ratio;
    }

    /*获取销毁归集比例*/
    function getdestroyRatio() public view returns(uint256){
        return destroyRatio;
    }

    /*设置dao归集比例*/
    function setDaoRatio(uint256 _ratio) public onlyOwner{
        daoRatio = _ratio;
    }

    /*获取dao归集比例*/
    function getDaoRatio() public view returns(uint256){
        return daoRatio;
    }

    /*设置超级节点归集地址*/
    function setSupperNodeAddress(address _address) public onlyOwner{
        supperNodeAddress = _address;
    }

    /*获取超级节点归集地址*/
    function getSupperNodeAddress() public view returns(address){
        return supperNodeAddress;
    }

    /*设置轻节点归集地址*/
    function setLightNodeAddress(address _address) public onlyOwner{
        lightNodeAddress = _address;
    }

    /*获取轻节点归集地址*/
    function getLightNodeAddress() public view returns(address){
        return lightNodeAddress;
    }
      
    /*设置销毁归集地址*/
    function setDestroyAddress(address _address) public onlyOwner{
        destroyAddress = _address;
    }

    /*获取销毁归集地址*/
    function getDestroyAddress() public view returns(address){
        return destroyAddress;
    }

    /*设置卖A币归集地址*/
    function setbCurrencyAddress(address _address) public onlyOwner{
        bCurrencyAddress = _address;
    }

    /*获取卖A币归集地址*/
    function getbCurrencyAddress() public view returns(address){
        return bCurrencyAddress;
    }

    /*设置dao收款地址*/
    function setDaoAddress(address _address) public onlyOwner{
        daoAddress = _address;
    }

    /*获取到收款地址*/
    function getDaoAddress() public view returns(address){
        return daoAddress;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}