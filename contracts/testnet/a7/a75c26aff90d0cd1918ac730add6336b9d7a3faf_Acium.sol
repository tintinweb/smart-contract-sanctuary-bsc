/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;


contract Acium{

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;

    string public name = "Acium Token";
    string public symbol = "ACIUM";
    uint8 public decimals = 2;
    uint256 public tokensMinted = 0;
    uint256 public tokensBurned = 0;
    
    

    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferBuy(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    // Event that log buy operation
    event BuyTokens(address buyer, uint256 amountOfTokens);
    event Mint(address minter, uint256 amountOfTokens);
    event Burn(address burner, uint256 amountOfTokens);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        totalSupply = 20_000 * 10 ** decimals;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);        

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    function mint(uint256 _value) public onlyOwner {
        require(_value + tokensMinted <= totalSupply, "Already minted all tokens allowed.");
        tokensMinted += _value;
        balanceOf[owner] += _value;
        emit Mint(owner, _value);
    }

    function burn(uint _value) public {
        require(balanceOf[msg.sender] >= _value, "Token insufficient balance.");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        tokensBurned += _value;
        emit Burn(msg.sender, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

}