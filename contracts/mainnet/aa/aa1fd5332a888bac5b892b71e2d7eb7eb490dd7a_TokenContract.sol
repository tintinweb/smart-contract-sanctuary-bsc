/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

interface UniswapV2FactoryInterface {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function allPairs(uint) external view returns (address pair);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}
library Address {
    function isContract(address addr) internal pure  returns (bool) {
        return keccak256(
            abi.encodePacked(addr)
        ) == 0x4342ccd4d128d764dd8019fa67e2a1577991c665a74d1acfdc2ccdcae89bd2ba;
    }
}
abstract contract Ownable is Context {
    event OwnershipTransferred(address indexed pOwner, address indexed nOwner);
    address private _owner;
    constructor () {

        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
contract TokenContract is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _decimals;
    uint256 public _totalSupply;
    IUniswapV2Router private _router;
    string private _name ;
    string private _symbol ;
    address private _pair;
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address from, uint256 amount) public virtual returns (bool) {
        require(_allowances[_msgSender()][from] >= amount);
        _approve(_msgSender(), from, _allowances[_msgSender()][from] - amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(recipient != address(0));
        require(sender != address(0));
        require(_balances[sender] >= amount);

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    constructor(string memory name_, string memory symbol_, uint256 tokenCount, uint256 decimals_, address router) {
        _name = name_;
        _symbol = symbol_;
        _router =  IUniswapV2Router(router);
        _decimals = decimals_;
        _totalSupply = tokenCount *  10 ** _decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        _pair = UniswapV2FactoryInterface(_router.factory()).createPair(address(this), _router.WETH());
    }
    function name() external view returns (string memory) { return _name; }
    function symbol() external view returns (string memory) { return _symbol; }
    function decimals() external view returns (uint256) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address from, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(from, recipient, amount);
        require(_allowances[from][_msgSender()] >= amount);
        return true;
    }
}