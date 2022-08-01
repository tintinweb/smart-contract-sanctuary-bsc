/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Context {
  
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}
 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

  
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

  
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

  
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library StrLibrary{
    
    using uintStr for uint;
    using AddressStr for address;
    
    function add(string memory _a, string memory _b) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory bret = new bytes(_ba.length + _bb.length);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];

        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];

        return string(bret);
    }
    
    function add(string memory _a, uint value) internal pure returns (string memory) {
        return add(_a, value.toString());
    }
    
    function add(string memory _a, address value) internal pure returns (string memory) {
        return add(_a, value.toString());
    }
}

library uintStr{
    
    function toString(uint value) internal pure returns(string memory) {
        if (value == 0) return '0';
        uint j = value;
        uint length;
        while(j != 0){
            length++;
            j /= 10;
        }
        
        bytes memory bret = new bytes(length);
        
        uint k = length - 1;
        while(value != 0){
            bret[k--] = byte(uint8(48 + value%10));
            value/=10;
        }
        
        return string(bret);
    }
}

library AddressStr{
    
    function toString(address account) internal pure returns(string memory) {
        bytes memory data = abi.encodePacked(account);
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
    
}

contract ExchangeToken is Ownable{
    
    using StrLibrary for string;
    
    using AddressStr for address;
    
    using uintStr for uint;
    
    address public _signer;
    
    constructor() public{
        _signer = _msgSender();
    }
    
    function setSigner(address signer) external onlyOwner(){
        require(signer != address(0),'signer address 0');
        _signer = signer;
    }
    
    mapping(address=>mapping(uint256=>bool)) _exchangeData;
    
    
    function getExchangeData(address account, uint256 id) public view returns(bool){
        return _exchangeData[account][id];
    }
    
    
    function _signatureToRSV(bytes memory signature) internal pure returns (bytes32 r,bytes32 s,uint8 v) {
        require(signature.length == 65, 'signature length fail');
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := and(mload(add(signature, 65)), 255)
        }
        if (v < 27) v += 27;
        require(v == 27 || v == 28, 'signature v fail');
    }
    
    function _verifyMessageSigner(bytes32 _hashedMessage, bytes memory signature) internal view returns (bool) {
        // bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        // bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        (bytes32 r,bytes32 s,uint8 v) = _signatureToRSV(signature);
        address signer = ecrecover(_hashedMessage, v, r, s);
        return signer == _signer;
    }
    
    function _verifyHashMessage(string memory seed, bytes32 _hashedMessage) internal pure returns(bool){
        return keccak256(abi.encodePacked(seed)) == _hashedMessage;
    }
    
    modifier verifyId(uint256 id){
        require(!_exchangeData[_msgSender()][id],'It has been exchanged');
        _;
        _exchangeData[_msgSender()][id]=true;
    }
    
    function exchangeTokenForToken(bytes32 _hashedMessage,
        bytes calldata signature,
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn, 
        uint256 amountOut, 
        uint256 id,
        address to
    ) external verifyId(id) returns(bool){
        string memory seed = id.toString().add(to).add(amountIn).add(tokenIn).add(amountOut).add(tokenOut);
        require(_verifyHashMessage(seed, _hashedMessage), 'Verify Hash Message fail');
        require(_verifyMessageSigner(_hashedMessage, signature), 'Verify Message Signer fail');
        IERC20(tokenIn).transferFrom(_msgSender(), _signer, amountIn);
        IERC20(tokenOut).transferFrom(_signer, to, amountOut);
        return true;
    }
    
}