/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

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

    function reset(Counter storage counter) internal {counter._value = 2590;}
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

contract StringUtil {
    //==============================string工具函数==============================
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    function toString(address account) internal  pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) internal  pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) internal pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringToUint(string memory s) internal pure returns(uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for(uint i = 0; i < b.length; i++) {
            if(uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }


    function stringToBytes32(string memory source) internal pure returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }

}

contract MPProject is Modifier, Util, StringUtil {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private tradeId;
    
    mapping(address => address) private invitationMapping;

    mapping(uint256 => TradeInfo) private hangSellMapping;
    mapping(uint256 => mapping(address => uint256)) private hangSellRecord;
    mapping(uint256 => bool) private hangSellStatus;
    mapping(uint256 => bool) private upgradeStatus;
    mapping(address => uint256) private composeMapping;

    address [] private receiveAddress;
    address private poolAddress;
    address private swapRouter;
    address public secretSigner;

    uint256 public receiveIndex;
    uint256 private poolRatio;

    bool openStatus = true;

    struct TradeInfo {
        uint256 id;
        address seller;
        uint256 amount;
        uint256 status; // 0 1 2
    }
    TradeInfo tradeInfo;

    ERC20 private usdtToken;
    ERC20 private mpToken;

    constructor() {
        tradeId.reset();
        poolRatio = 50;
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        mpToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        poolAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        swapRouter = 0x1f3B4C66ab241608740333B9D7C1D6Ba431968c5;
        secretSigner = 0x1DA878464F2466036C74A9fFD7e89A181fBeBE5e;
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

    function setPoolAddress(address _address) public onlyOwner {
        poolAddress = _address;
    }

    function setSwapRouter(address _address) public onlyOwner {
        swapRouter = _address;
    }

    function setSecretSigner(address _address) public onlyOwner {
        secretSigner = _address;
    }

    function setPoolRatio(uint256 _ratio) public onlyOwner {
        poolRatio = _ratio;
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

    function hangSell(uint256 myNftId, string memory myNftIdToStr, string memory amountToWeiStr, address _address, string memory seed, bytes32 _r, bytes32 _s, uint8 _v) public isRunning returns (bool) {
        
        if(hangSellStatus[myNftId]) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid myNftId");
        }
        if(msg.sender != _address) {
            _status = _NOT_ENTERED;
            revert("MP : Caller error");
        }

        uint256 amountToWei = stringToUint(amountToWeiStr);
        string memory senderStr = toString(_address);

        bytes32 msgHash = keccak256(abi.encodePacked(myNftIdToStr, senderStr, amountToWeiStr, seed));
        address signer = verifyMessage(msgHash, _v, _r, _s);
        if(signer != secretSigner) {
            _status = _NOT_ENTERED;
            revert("MP : Signer error");
        }

        tradeInfo = TradeInfo(tradeId.current(), msg.sender, amountToWei, 0);
        hangSellMapping[tradeId.current()] = tradeInfo;
        hangSellRecord[block.number][msg.sender] = tradeId.current();

        tradeId.increment();
        hangSellStatus[myNftId] = true;

        return true;
    }

    function upgrade(uint256 myNftId, string memory myNftIdToStr, string memory usdtToWeiStr, string memory amountToWeiStr, address _address, string memory seed, bytes32 _r, bytes32 _s, uint8 _v) public isRunning returns (bool) {

        if(upgradeStatus[myNftId]) {
            _status = _NOT_ENTERED;
            revert("MP: Invalid myNftId");
        }
        if(msg.sender != _address) {
            _status = _NOT_ENTERED;
            revert("MP : Caller error");
        }

        uint256 usdtToWei = stringToUint(usdtToWeiStr);
        uint256 amountToWei = stringToUint(amountToWeiStr);
        string memory senderStr = toString(_address);

        bytes32 msgHash = keccak256(abi.encodePacked(myNftIdToStr, senderStr, usdtToWeiStr, amountToWeiStr, seed));
        address signer = verifyMessage(msgHash, _v, _r, _s);
        if(signer != secretSigner) {
            _status = _NOT_ENTERED;
            revert("MP : Signer error");
        }

        privateUpgrade(myNftId, usdtToWei, amountToWei);

        return true;
    }

    function privateUpgrade(uint256 myNftId, uint256 usdtToWei, uint256 amountToWei) private {
        usdtToken.transferFrom(msg.sender, address(this), usdtToWei);
        if(receiveIndex >= receiveAddress.length) {
            receiveIndex = 0;
        }
        uint256 poolAmount = usdtToWei.mul(poolRatio).div(1000);
        usdtToken.transfer(poolAddress, poolAmount);
        usdtToken.transfer(receiveAddress[receiveIndex], usdtToWei.sub(poolAmount));

        tradeInfo = TradeInfo(tradeId.current(), msg.sender, amountToWei, 0);
        hangSellMapping[tradeId.current()] = tradeInfo;
        hangSellRecord[block.number][msg.sender] = tradeId.current();

        tradeId.increment();
        receiveIndex = receiveIndex + 1;

        upgradeStatus[myNftId] = true;
    }

    function setTradeInfo(uint256 _tradeId, address _address, uint256 amountToWei) public onlyApprove {
        tradeInfo = TradeInfo(_tradeId, _address, amountToWei, 0);
        hangSellMapping[_tradeId] = tradeInfo;
    }

    function setTradeInfoByList(uint256 [] memory tradeIdList, address [] memory addressList, uint256 [] memory amountList) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            tradeInfo = TradeInfo(tradeIdList[i], addressList[i], amountList[i], 0);
            hangSellMapping[tradeIdList[i]] = tradeInfo;
        }
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

    function cancel(uint256 _tradeId) public onlyApprove { 
        hangSellMapping[_tradeId].status = 2;
    }
 
    function getHangSellRecord(uint256 _number, address _address) public view returns (uint256) {
        return hangSellRecord[_number][_address];
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

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}