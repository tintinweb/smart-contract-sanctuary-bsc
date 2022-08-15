/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
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
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}
abstract contract Ownable {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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
contract TelegramX is Ownable, IBEP20 {
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    uint256 public buyFeeToWallet1 = 2;
    uint256 public buyFeeToWallet2 = 4;
    uint256 public buyFeeToLpDifidend = 2;

    uint256 public sellFeeToWallet1 = 2;
    uint256 public sellFeeToWallet2 = 4;
    uint256 public sellFeeToLpDifidend = 2;

    uint256 public feeToWallet1;
    uint256 public feeToWallet2;
    uint256 public feeToLpDifidend;

    uint256 public minAmountToSwapForWallet = 100;
    uint256 public minAmountToLpDifidend = 100;
    uint256 public minLPAmountForDifidend = 100;

    bool private isLiquidityAdded;
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public wallet1 = 0x37650a4a723827063E1129C3EE4D2BfEfaA16559;
    address public wallet2 = 0x2912a6E9A8714cde497fD2904AcbA52dE6b7a245;
    address private pair;
    address private lastPotentialLPHolder;
    address[] public tokenHolders;
    address[] public lpHolders;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _holderIsExist;
    mapping (address => bool) public _isLPHolderExist;
    mapping (address => bool) public exemptFee;
    IPancakeRouter02 private _router;
    usdtReceiver private _usdtReceiver;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    constructor() {
        _name = "Tai Yang Niao";
        _symbol = "TYN";
        _decimals = 18;
        _totalSupply = 2678 * (1e18); 
	    _balances[_owner] = _totalSupply;
        tokenHolders.push(_owner);
        _holderIsExist[_owner] = true;
        exemptFee[_owner] = true;
        exemptFee[address(this)] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver();
        _approve(address(this), address(pancakeRouterAddr), ~uint256(0));
	    emit Transfer(address(0), _owner, _totalSupply);  
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint256) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(amount > _balances[sender].div(100).mul(99)) {
            amount = _balances[sender].div(100).mul(99);
        }
        if(!isLiquidityAdded && recipient == pair) {
            isLiquidityAdded = true;
            lpHolders.push(sender);
            _isLPHolderExist[sender] = true;
        }
        if(!recipient.isContract() && recipient != address(0) && !_holderIsExist[recipient]) {
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }
        uint256 price = tokenPrice();
        if(sender != pair && recipient != pair && unlocked == 1 && feeToWallet1.mul(price).div(1e18) >= minAmountToSwapForWallet*(1e18)) {
            swapUSDTForWallet(wallet1);
        } 
        if(sender != pair && recipient != pair && unlocked == 1 && feeToWallet2.mul(price).div(1e18) >= minAmountToSwapForWallet*(1e18)) {
            swapUSDTForWallet(wallet2);
        } 
        if(sender != pair && recipient != pair && unlocked == 1 && feeToLpDifidend.mul(price).div(1e18) > minAmountToLpDifidend*(1e18)) {
            difidendToLPHolders();
        }
        uint256 fee;
        if(!exemptFee[sender] && !exemptFee[recipient]) {
            if(sender == pair) { // buy
                if(buyFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(buyFeeToWallet1);
                    fee = fee.add(feeWallet1);
                    _balances[address(this)] = _balances[address(this)].add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                    emit Transfer(sender, address(this), feeWallet1);
                }
                if(buyFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(buyFeeToWallet2);
                    fee = fee.add(feeWallet2);
                    _balances[address(this)] = _balances[address(this)].add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                    emit Transfer(sender, address(this), feeWallet2);
                }
                if(buyFeeToLpDifidend > 0) {
                    uint256 feeLPDifidend = amount.div(100).mul(buyFeeToLpDifidend);
                    fee = fee.add(feeLPDifidend);
                    _balances[address(this)] = _balances[address(this)].add(feeLPDifidend);
                    feeToLpDifidend = feeToLpDifidend.add(feeLPDifidend);
                    emit Transfer(sender, address(this), feeLPDifidend);
                }
            } else if(recipient == pair) { // sell or addLiquidity
                if(sellFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(sellFeeToWallet1);
                    fee = fee.add(feeWallet1);
                    _balances[address(this)] = _balances[address(this)].add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                    emit Transfer(sender, address(this), feeWallet1);
                }
                if(sellFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(sellFeeToWallet2);
                    fee = fee.add(feeWallet2);
                    _balances[address(this)] = _balances[address(this)].add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                    emit Transfer(sender, address(this), feeWallet2);
                }
                if(sellFeeToLpDifidend > 0) {
                    uint256 feeLPDifidend = amount.div(100).mul(sellFeeToLpDifidend);
                    fee = fee.add(feeLPDifidend);
                    _balances[address(this)] = _balances[address(this)].add(feeLPDifidend);
                    feeToLpDifidend = feeToLpDifidend.add(feeLPDifidend);
                    emit Transfer(sender, address(this), feeLPDifidend);
                }
            }
        } 
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance"); 
        uint256 finalAmount = amount.sub(fee);
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(recipient == pair && sender != address(this)) {
            lastPotentialLPHolder = sender;
        }  
    }
    function tokenPrice() private view returns(uint256){
        uint256 tokenAmount = _balances[pair];
        if(tokenAmount == 0) return 0;
        uint256 USDTAmount = IBEP20(usdt).balanceOf(pair);
        return USDTAmount.mul(1e18).div(tokenAmount);
    }
    function swapUSDTForWallet(address wallet) private lock {
        uint256 amount;
        if(wallet == wallet1) {
            amount = feeToWallet1;
        } else {
            amount = feeToWallet2;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            wallet,
            block.timestamp
        );
        if(wallet == wallet1) {
            feeToWallet1 = 0;
        } else {
            feeToWallet2 = 0;
        }
    }
    function difidendToLPHolders() private lock {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            feeToLpDifidend,
            0,
            path,
            address(_usdtReceiver),
            block.timestamp
        );
        feeToLpDifidend = 0;
        uint256 totalRewards = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        uint totalLPAmount = IBEP20(pair).totalSupply() - 1e3;
        for(uint256 i = 0; i < lpHolders.length; i++){
            uint256 LPAmount = IBEP20(pair).balanceOf(lpHolders[i]);
            if( LPAmount >= minLPAmountForDifidend) {
                uint256 reward = totalRewards.mul(LPAmount).div(totalLPAmount);
                if(reward == 0) continue;
                if(IBEP20(usdt).balanceOf(address(_usdtReceiver)) < reward) return;   
                IBEP20(usdt).transferFrom(address(_usdtReceiver),lpHolders[i], reward);
            }    
        }
    }
    function claimLeftUSDT() external onlyOwner {
        uint256 left = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), wallet1, left);
    }
    function viewBalanceOfReceiver() external view  returns(uint256){
        return IBEP20(usdt).balanceOf(address(_usdtReceiver));
    }
    function setMinAmountToSwapForWallet(uint256 value) external onlyOwner() { 
        minAmountToSwapForWallet = value;
    }
    function setMinLPAmountForDifidend(uint256 value) external onlyOwner() { 
        minLPAmountForDifidend = value;
    }
    function setMinAmountToLpDifidend(uint256 value) external onlyOwner() { 
        minAmountToLpDifidend = value;
    }
    function setExemptFee(address account, bool flag) external onlyOwner() {
        exemptFee[account] = flag;
    }
    function setNewWallet1(address account) external onlyOwner() {
        wallet1 = account;
    }
    function setNewWallet2(address account) external onlyOwner() {
        wallet2 = account;
    }
    function setBuyFeeToWallet1(uint256 value) external onlyOwner() {
        buyFeeToWallet1 = value;
    }
    function setBuyFeeToWallet2(uint256 value) external onlyOwner() {
        buyFeeToWallet2 = value;
    }
    function setSellFeeToWallet1(uint256 value) external onlyOwner() {
        sellFeeToWallet1 = value;
    }
    function setSellFeeToWallet2(uint256 value) external onlyOwner() {
        sellFeeToWallet2 = value;
    }
    function setBuyFeeToLpDifidend(uint256 value) external onlyOwner() { 
        buyFeeToLpDifidend = value;
    }
    function setSellFeeToLpDifidend(uint256 value) external onlyOwner() { 
        sellFeeToLpDifidend = value;
    }
}