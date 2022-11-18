/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

abstract contract MobToken {
    function queryUsdtToThisPrice() external virtual view returns (uint256);
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

    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
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

contract MPMinePool is Modifier, StringUtil {

    using SafeMath for uint256;

    mapping(uint256 => bool) private withdrawIdMapping;
    address public secretSigner;

    ERC20 private usdtToken;
    ERC20 private mpToken;

    event Withdraw(address indexed user, uint256 amount, uint256 withdrawId);

    constructor() {
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        mpToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        secretSigner = 0x1DA878464F2466036C74A9fFD7e89A181fBeBE5e;
    }

    function setContraceToken(address _usdtToken, address _mpToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        mpToken = ERC20(_mpToken);
    }

    function setSecretSigner(address _address) public onlyOwner {
        secretSigner = _address;
    }

    function withdraw(uint256 withdrawId, string memory withdrawIdToStr, string memory withdrawType, address _to, string memory amountToStr, string memory seed, bytes32 _r, bytes32 _s, uint8 _v) external isRunning nonReentrant {
        
        uint256 amountToWei = stringToUint(amountToStr);

        if(withdrawIdMapping[withdrawId]) {
            _status = _NOT_ENTERED;
            revert("Metaplayer: invalid withdrawId");
        }
        if(amountToWei <= 0) {
            _status = _NOT_ENTERED;
            revert("Metaplayer: amountToWei <= 0");
        }
        if(msg.sender != _to) {
            _status = _NOT_ENTERED;
            revert("Metaplayer : caller error");
        }

        string memory senderStr = toString(_to);

        bytes32 msgHash = keccak256(abi.encodePacked(withdrawIdToStr, withdrawType, senderStr, amountToStr, seed));
        address signer = verifyMessage(msgHash, _v, _r, _s);
        if(signer != secretSigner) {
            _status = _NOT_ENTERED;
            revert("Metaplayer : signer error");
        }

        if(stringToUint(withdrawType) == 0) {
            usdtToken.transfer(_to, amountToWei);
        } else {
            mpToken.transfer(_to, amountToWei);
        }

        withdrawIdMapping[withdrawId] = true;

        emit Withdraw(_to, amountToWei, withdrawId);

    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

}