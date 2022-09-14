/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


contract Context {
    function _msgSender() internal view returns (address ) {
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

    constructor ()  {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender)
    external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)
    external returns (bool);
    function transferFrom(address from, address to, uint256 value)
    external returns (bool);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract Verify {

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}

contract TokenWithdraw is Ownable, Verify { 

    IERC20 public BUSD;
    address public signer;
 
    mapping (bytes32 => bool) public usedHash;
    mapping (address => bool) public claimedUser;
    
    
    constructor(address _signer){
        signer = _signer;
    }
  
    function ClaimReward(address _tokenAddress, uint256 _amount, uint256 _nonce, bytes memory signature) external {   
        bytes32 hash = keccak256(   
            abi.encodePacked(   
                toString(address(this)),   
                toString(msg.sender),   
                _amount,   
                _nonce   
            )   
        );   
        require(!usedHash[hash], "Invalid Hash");   
        require(recoverSigner(hash, signature) == signer, "Signature Failed");   
        usedHash[hash] = true; 
        claimedUser[msg.sender] = true;  
        IERC20(_tokenAddress).transfer(msg.sender, _amount);   
    }
  
    function changeSignatureAddress(address _signer) public onlyOwner {  
        signer = _signer;  
    }  

    function WithdrawBalance() public onlyOwner{
        uint256 balance = BUSD.balanceOf(address(this));
        BUSD.transfer(owner(), balance);
    }
 
}