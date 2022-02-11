/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: OSL 3.0 

/*
 
Our objective is to give a second chance
to folks who missed out on buying bitcoin
between 2009-2013. BitBull holders will be
able to earn BTC by holding and
mine as well through our mobile app.

Join Us : https://t.me/bitbullbsc

**/

pragma solidity 0.8.7; 

    contract BITBULL {
    string public name = "BITBULL";
    string public symbol = "BTCBULL";
    uint256 public totalSupply = 1000000000000000000; 
    uint8 public decimals = 9;
    
  
     event Transfer(address indexed _from, address indexed _to, uint256 _value);

   
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

 
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }


    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;                   // Automatic default tax is 10%
        emit Transfer(msg.sender, _to, _value);
        return true; 
        
       
    }


    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true; 
    }
}