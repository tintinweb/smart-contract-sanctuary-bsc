/**
 *Submitted for verification at BscScan.com on 2022-11-28
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

contract MYShopping is Modifier, StringUtil {

    using SafeMath for uint256;

    mapping(uint256 => bool) private orderStatus;

    address public secretSigner;
    address private receiveAddress;

    uint256 private sellerRatio;

    ERC20 private usdtToken;
    ERC20 private myToken;

    event PayOrder(address indexed user, uint256 amount, uint256 orderId);

    constructor() {
        secretSigner = 0x221893a8810981Da72B8293CE922Dded3AC9e7dF;
        receiveAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        sellerRatio = 900;
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        myToken = ERC20(0x910CfF6Cf54955Df6e9CAA58a08a07fD61384A07);
    }

    function setTokenContract(address _usdtToken, address _myToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        myToken = ERC20(_myToken);
    }

    function setSecretSigner(address _address) public onlyOwner {
        secretSigner = _address;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function setSellerRatio(uint256 _ratio) public onlyOwner {
        sellerRatio = _ratio;
    }

    function payOrder(uint256 _orderId, string memory orderIdToStr, string memory payType, address sellerAddress, string memory amountToStr, string memory seed, bytes32 _r, bytes32 _s, uint8 _v) external isRunning nonReentrant {

        if(orderStatus[_orderId]) {
            _status = _NOT_ENTERED;
            revert("MY: Invalid status");
        }

        uint256 amountToWei = stringToUint(amountToStr);
        if(amountToWei <= 0) {
            _status = _NOT_ENTERED;
            revert("MY: amountToWei <= 0");
        }
        
        string memory _sellerAddress = toString(sellerAddress);

        bytes32 msgHash = keccak256(abi.encodePacked(orderIdToStr, payType, _sellerAddress, amountToStr, seed));
        
        if(verifyMessage(msgHash, _v, _r, _s) != secretSigner) {
            _status = _NOT_ENTERED;
            revert("MY : signer error");
        }

        uint256 sellerAmount = amountToWei.mul(sellerRatio).div(1000);
        if(stringToUint(payType) == 0) {
            usdtToken.transferFrom(msg.sender, address(this), amountToWei);
            usdtToken.transfer(sellerAddress, sellerAmount);
            usdtToken.transfer(receiveAddress, amountToWei.sub(sellerAmount));
        } else {
            myToken.transferFrom(msg.sender, address(this), amountToWei);
            myToken.transfer(sellerAddress, sellerAmount);
            myToken.transfer(receiveAddress, amountToWei.sub(sellerAmount));
        }

        orderStatus[_orderId] = true;

        emit PayOrder(sellerAddress, amountToWei, _orderId);

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