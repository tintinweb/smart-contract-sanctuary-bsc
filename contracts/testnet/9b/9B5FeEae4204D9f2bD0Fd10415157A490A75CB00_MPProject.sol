/**
 *Submitted for verification at BscScan.com on 2022-11-10
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

    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

contract MPProject is Modifier, Util {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private tradeId;
    
    mapping(address => address) private invitationMapping;

    mapping(uint256 => TradeInfo) private hangSellMapping;
    mapping(uint256 => mapping(address => uint256)) private hangSellRecord;
    mapping(address => uint256) private blindBoxMapping;
    mapping(uint256 => bool) private hangSellStatus;
    mapping(uint256 => bool) private upgradeStatus;
    mapping(address => uint256) private composeMapping;
    mapping(address => uint256) private splitMapping;
    mapping(address => uint256) private applyNodeMapping;

    address [] private receiveAddress;
    address private destroyAddress;
    address private swapRouter;

    uint256 public receiveIndex;

    bool openStatus = true;

    struct TradeInfo {
        uint256 id;
        address seller;
        uint256 nftId;
        uint256 amount;
        uint256 status; // 0 1 2
    }
    TradeInfo tradeInfo;

    ERC20 private usdtToken;
    ERC20 private mpToken;

    constructor() {

        tradeId.increment();

        destroyAddress = 0x000000000000000000000000000000000000dEaD;

        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        mpToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        swapRouter = 0x1f3B4C66ab241608740333B9D7C1D6Ba431968c5;
    }

    function setTokenContract(address _usdtToken, address _mpToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        mpToken = ERC20(_mpToken);
    }

    function setOpenStatus(bool _status) public onlyApprove {
        openStatus = _status;
    }

    function setReceiveAddress(address [] memory addresses) public onlyOwner {
        for(uint8 i=0; i<addresses.length; i++) {
            receiveAddress.push(addresses[i]);
        }
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setSwapRouter(address _address) public onlyOwner {
        swapRouter = _address;
    }

    function buy(uint256 amountToWei, address sellerAddress, uint256 _tradeId) public isRunning nonReentrant returns (bool) {
        if(!openStatus) { 
            _status = _NOT_ENTERED;
            revert("MP: Not started");
        }

        if(hangSellMapping[_tradeId].seller != sellerAddress) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid id");
        }

        if(hangSellMapping[_tradeId].amount != amountToWei) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid amount");
        }

        if(hangSellMapping[_tradeId].status != 0) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid status");
        }

        usdtToken.transferFrom(msg.sender, address(this), amountToWei);
        usdtToken.transfer(sellerAddress, amountToWei);

        hangSellMapping[_tradeId].status = 1;

        return true;
    }

    function hangSell(uint256 myNftId, uint256 nftId, uint256 amountToWei) public isRunning returns (bool) {
        
        if(hangSellStatus[myNftId]) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid myNftId");
        }

        tradeInfo = TradeInfo(tradeId.current(), msg.sender, nftId, amountToWei, 0);
        hangSellMapping[tradeId.current()] = tradeInfo;
        hangSellRecord[block.number][msg.sender] = tradeId.current();

        tradeId.increment();
        hangSellStatus[myNftId] = true;

        return true;
    }

    function upgrade(uint256 myNftId, uint256 usdtToWei, uint256 mpToWei,
        uint256 newNftId, uint256 amountToWei) public isRunning returns (bool) {

        if(upgradeStatus[myNftId]) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid myNftId");
        }
        
        usdtToken.transferFrom(msg.sender, address(this), usdtToWei);
        if(receiveIndex >= receiveAddress.length) {
            receiveIndex = 0;
        }
        usdtToken.transfer(receiveAddress[receiveIndex], usdtToWei);

        mpToken.transferFrom(msg.sender, address(this), mpToWei);
        mpToken.transfer(destroyAddress, mpToWei);

        tradeInfo = TradeInfo(tradeId.current(), msg.sender, newNftId, amountToWei, 0);
        hangSellMapping[tradeId.current()] = tradeInfo;
        hangSellRecord[block.number][msg.sender] = tradeId.current();

        tradeId.increment();

        upgradeStatus[myNftId] = true;

        return true;
    }

    function compose(uint256 myNftId, uint256 amountToWei) public isRunning returns (bool) {
        mpToken.transferFrom(msg.sender, address(this), amountToWei);
        if(receiveIndex >= receiveAddress.length) {
            receiveIndex = 0;
        }
        mpToken.transfer(receiveAddress[receiveIndex], amountToWei);
        composeMapping[msg.sender] = myNftId;
        return true;
    }

    function split(uint256 myNftId) public isRunning returns (bool) { 
        splitMapping[msg.sender] = myNftId;
        return true;
    }

    function applyNode(uint256 myNftId) public isRunning returns (bool) { 
        applyNodeMapping[msg.sender] = myNftId;
        return true;
    }

    function cancel(uint256 _tradeId) public onlyApprove { 
        hangSellMapping[_tradeId].status = 2;
    }

    function openBlindBox(uint256 count) public isRunning returns (bool) {
        blindBoxMapping[msg.sender] = count;
        return true;
    }
 
    function getHangSellRecord(uint256 _number, address _address) public view returns (uint256) {
        return hangSellRecord[_number][_address];
    }

    function bindInviter(address inviterAddress) public isRunning nonReentrant {

        if(invitationMapping[inviterAddress] == address(0) && inviterAddress != address(this)) {
            _status = _NOT_ENTERED;
            revert("MP: Inviter is invalid");
        }

        if(invitationMapping[msg.sender] == address(0)) {
            invitationMapping[msg.sender] = inviterAddress;
        }
    }

    function updateInviter(address _address, address inviterAddress) public onlyApprove {
        invitationMapping[_address] = inviterAddress;
    }

    function getBindStatus() public view returns(bool status) {
        if(invitationMapping[msg.sender] == address(0)) {
            return false;
        }
        return true;
    }

    function getInviter(address _address) public view returns(address) {
        return invitationMapping[_address];
    }

    function getOpenStatus() public view returns(bool status) {
        return openStatus;
    }

    // 1MP = ? U
    function queryMpToUsdtPrice() public view returns (uint256) {
        uint256 reserveA = mpToken.balanceOf(swapRouter);
        uint256 reserveB = usdtToken.balanceOf(swapRouter);
        return Util.mathDivisionToFloat(reserveB, reserveA, 18);
    }

    function updateInviterByList(address [] memory addressList, address [] memory inviterAddressList) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            invitationMapping[addressList[i]] = inviterAddressList[i];
        }
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}