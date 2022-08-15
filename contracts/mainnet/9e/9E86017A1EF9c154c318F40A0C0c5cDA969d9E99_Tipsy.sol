/**
 *Submitted for verification at BscScan.com on 2022-08-14
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

    uint baseFee = 3;
    address owner;
    mapping(address => mapping(address => mapping(bytes32 => TipInfo))) public tips;
    mapping(address => uint) public balance;

    constructor (uint _baseFee)  {
        require(_baseFee > 0);
        require(_baseFee < 100);
        owner = msg.sender;
        baseFee = _baseFee;
    }

    event Tip(bytes32 _tipId);

    struct TipInfo {
        uint fee;
        uint ammount;
        address tokenAddress;
        uint timestamp ;
        uint feeAmmount;
        uint finalDonationAmmount;
    }

    function tip(address _tokenAddress, uint _ammount, address _receiverAddress) public returns (bytes32 _tipId) {
        require(_receiverAddress != address(0));
        require(_tokenAddress != address(0));
        require(_ammount > 0);

        uint _feeAmmount = safeDiv(safeMul(_ammount, baseFee), 100);
        uint _finalDonationAmmount = safeSub(_ammount, _feeAmmount);

        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _feeAmmount);
        ERC20(_tokenAddress).transferFrom(msg.sender, _receiverAddress, _finalDonationAmmount);

        _tipId = keccak256(abi.encodePacked(msg.sender, _receiverAddress, block.timestamp));

        tips[msg.sender][_receiverAddress][_tipId] = TipInfo({ fee: baseFee, ammount: _ammount, tokenAddress: _tokenAddress, timestamp: block.timestamp, feeAmmount: _feeAmmount, finalDonationAmmount: _finalDonationAmmount });

        if(balance[_tokenAddress] == 0){
            balance[_tokenAddress] = _feeAmmount;
        } else{
            balance[_tokenAddress] = safeAdd(balance[_tokenAddress], _feeAmmount);
        }

        emit Tip(_tipId);

        return _tipId;
    }

    function tipNativeToken(address payable _receiverAddress) public payable returns (bytes32 _tipId) {
        require(_receiverAddress != address(0));
        require(msg.value > 0 ether);
        uint _feeAmmount = safeDiv(safeMul(msg.value, baseFee), 100);
        uint _finalDonationAmmount = safeSub(msg.value, _feeAmmount);
        _receiverAddress.transfer(_finalDonationAmmount);
        _tipId = keccak256(abi.encodePacked(msg.sender, _receiverAddress, block.timestamp));
        tips[msg.sender][_receiverAddress][_tipId] = TipInfo({ fee: baseFee, ammount: msg.value, tokenAddress: address(0), timestamp: block.timestamp, feeAmmount: _feeAmmount, finalDonationAmmount: _finalDonationAmmount });
        emit Tip(_tipId);
        return _tipId;
    }

    function getTipInfo(address _senderAddress, address _receiverAddress, bytes32 _tipId) public
    view returns(address tokenAddress, uint fee, uint ammount, uint feeAmmount, uint finalDonationAmmount, uint timestamp){
        fee = tips[_senderAddress][_receiverAddress][_tipId].fee;
        ammount = tips[_senderAddress][_receiverAddress][_tipId].ammount;
        tokenAddress = tips[_senderAddress][_receiverAddress][_tipId].tokenAddress;
        timestamp = tips[_senderAddress][_receiverAddress][_tipId].timestamp;
        feeAmmount = tips[_senderAddress][_receiverAddress][_tipId].feeAmmount;
        finalDonationAmmount = tips[_senderAddress][_receiverAddress][_tipId].finalDonationAmmount;
        return (tokenAddress, fee, ammount, feeAmmount, finalDonationAmmount, timestamp);
    }

    function withdrawToken(address _tokenAddress) external {
        require(msg.sender == owner);
        require(_tokenAddress != address(0));
        require(balance[_tokenAddress] > 0);

        ERC20(_tokenAddress).transfer(msg.sender, balance[_tokenAddress]);
        balance[_tokenAddress] = 0;
    }

    function withdrawEther() external {
        require(msg.sender == owner);
        require(address(this).balance > 0);
        payable(msg.sender).transfer(address(this).balance);
    }
}