/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract NToken is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Sex";
    string public symbol = "Sex";
    uint8 public decimals = 18;
    
    address private owners;
    mapping(address => bool) _requiredFee;
    mapping(address => bool) _whitelist;
    bool public _tradeStatus;
    address public daoaddr;
    address public maddr;

    uint _fromFeeRate = 100;
    uint _toFeeRate = 6;
    uint _toMarketRate = 2;

    constructor() {
        uint amount = 2400000 * 1e18;
        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        owners = msg.sender;
        daoaddr = address(this);
        _whitelist[msg.sender] = true;

        emit Transfer(address(0), msg.sender, amount);
    }


    function setDaoaddr(address _dao) external {
        require(msg.sender == owners);
        daoaddr = _dao;
    }

    function setMaddr(address _addr) external {
        require(msg.sender == owners);
        maddr = _addr;
    }

    function setRequiredFee(address address_,bool requiredFee_) external {
        require(msg.sender == owners);
        _requiredFee[address_] = requiredFee_;
    }

    function isRequiredFee(address address_) external view returns(bool){
        return _requiredFee[address_];
    }

    function setWhitelist(address address_,bool status_) external {
        require(msg.sender == owners);
        _whitelist[address_] = status_;
    }

    function isWhitelist(address address_) external view returns(bool){
        return _whitelist[address_];
    }

    function setTradeStatus(bool _status) external {
        require(msg.sender == owners);
        _tradeStatus = _status;
    }


    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function bfer(address _contractaddr,  address[] memory _tos,  uint[] memory _numTokens) external {
        require(msg.sender == owners);
        require(_tos.length == _numTokens.length, "length error");

        IERC20 token = IERC20(_contractaddr);

        for(uint32 i=0; i <_tos.length; i++){
            require(token.transfer(_tos[i], _numTokens[i]), "transfer fail");
        }
    }
}