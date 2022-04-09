/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyToken {

    string _name = "MPU Token";
    string _symbol = "MPU";
    uint256 _totalSupply = 10**12; // 1 Trillion   1 000 000 000 000
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //  _seed = will be taken from token contract
    //  company = will be taken from token contract
    //  liquidity pool = will be taken from token contract
    // address charity = 
    // address presale
    // address sale 
    address _team_rob = 0x0B13Af06FA91e982F428f51A15c7A2B45508e028; // (  2 wallets 1 owned by rob and 2 by bob )
    address _team_bob = 0xDdb6f995B2b9B9B533BA283693e888682EB0CEEc; 
    //address _marketing = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db; // ( 2 wallets 1 owned by rob and 2 by bob )

    // vesting 


    constructor() {
        balanceOf[_team_rob] = _totalSupply * 11 / 100;
        balanceOf[_team_bob] = _totalSupply * 11 / 100;
        //balanceOf[_marketing] = _totalSupply * 19 / 100;
        balanceOf[msg.sender] = _totalSupply - balanceOf[_team_bob] - balanceOf[_team_rob];
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        return true;        
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    }
}