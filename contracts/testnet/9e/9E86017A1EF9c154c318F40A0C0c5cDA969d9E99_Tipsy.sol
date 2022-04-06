/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract ERC20 {
    function totalSupply() public virtual  returns (uint);
    function balanceOf(address tokenOwner) public virtual  returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual  returns (uint remaining);
    function transfer(address to, uint tokens) public virtual  returns (bool success);
    function approve(address spender, uint tokens) public virtual  returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual  returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Tipsy is SafeMath {

    constructor (uint _baseFee)  {
        require(_baseFee > 0);
        require(_baseFee < 100);
        owner = msg.sender;
        baseFee = _baseFee;
    }

    struct TipInfo {
        uint fee;
        uint ammount;
        address tokenAddress;
        uint timestamp ;
        uint feeAmmount;
        uint finalDonationAmmount;
    }

    address owner;
    uint baseFee = 3;

    mapping(address => mapping(address => mapping(bytes32 => TipInfo))) public tips;
    mapping(address => uint) public balance;

    function approve(address _tokenAddress, uint _ammount) public returns (bool success) {
        ERC20(_tokenAddress).approve(msg.sender, _ammount);
        return true;
    }

    function tip(address _tokenAddress, uint _ammount, address _recieverAddress) public returns (bytes32 _tipId) {
        require(_recieverAddress != address(0));
        require(_tokenAddress != address(0));
        require(_ammount > 0);

        uint _feeAmmount = safeDiv(safeMul(_ammount, baseFee), 100);
        uint _finalDonationAmmount = safeSub(_ammount, _feeAmmount);

        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _feeAmmount);
        ERC20(_tokenAddress).transferFrom(msg.sender, _recieverAddress, _finalDonationAmmount);

        _tipId = keccak256(abi.encodePacked(msg.sender, _recieverAddress, block.timestamp));

        tips[msg.sender][_recieverAddress][_tipId] = TipInfo({ fee: baseFee, ammount: _ammount, tokenAddress: _tokenAddress, timestamp: block.timestamp, feeAmmount: _feeAmmount, finalDonationAmmount: _finalDonationAmmount });
        
        if(balance[_tokenAddress] == 0){
            balance[_tokenAddress] = _feeAmmount;
        } else{
            balance[_tokenAddress] = safeAdd(balance[_tokenAddress], _feeAmmount);
        }
        return _tipId;
    }

    function getTipInfo(address _senderAddress, address _recieverAddress, bytes32 _tipId) public 

    view returns(address tokenAddress, uint fee, uint ammount, uint feeAmmount, uint finalDonationAmmount, uint timestamp){
        fee = tips[_senderAddress][_recieverAddress][_tipId].fee;
        ammount = tips[_senderAddress][_recieverAddress][_tipId].ammount;
        tokenAddress = tips[_senderAddress][_recieverAddress][_tipId].tokenAddress;
        timestamp = tips[_senderAddress][_recieverAddress][_tipId].timestamp;
        feeAmmount = tips[_senderAddress][_recieverAddress][_tipId].feeAmmount;
        finalDonationAmmount = tips[_senderAddress][_recieverAddress][_tipId].finalDonationAmmount;
        return (tokenAddress, fee, ammount, feeAmmount, finalDonationAmmount, timestamp);
    }

    function withdrawToken(address _tokenAddress) external {
        require(msg.sender == owner);
        require(_tokenAddress != address(0));
        ERC20(_tokenAddress).transfer(msg.sender, balance[_tokenAddress]);
        balance[_tokenAddress] = 0;
    }
}