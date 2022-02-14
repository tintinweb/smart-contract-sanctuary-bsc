/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000000 * 10 ** 18;
    string public name = "MongoToken";
    string public symbol = "MONG";
    uint public decimals = 18;
    
    // Token Distribution
  uint256 public DevTAXPercentage   = 10;
  address private _developmentWalletAddress = 0x341d7C5a040f0e9dc8C3782C0cf2DF8CbF4CE79a;
  uint256 public MarketingTaxPercentage    = 20;
  address private _MarketingWalletAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  uint256 public AutoBurn = 10;
  address private _AutoBurnWalletAddress = 0x000000000000000000000000000000000000dEaD;
  uint256 public CharityTaxPercentage    = 50;
  address private _CharityTaxWalletAddress = 0x24E35192b9684c26378d50Dd41C9814E7E3bEFE1;
  address private _OwnerWalletAddress = 0xAFB439447F256340AC73C6F35b198B859f9f448b;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}