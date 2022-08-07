/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
        _transferOwnership(address(0));
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract IERC20Extented is IERC20 {
    function decimals() external view virtual returns (uint8);
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
}

contract Corki is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    string private constant _name = "corki";
    string private constant _symbol = "CORKI";
    uint8 private constant _decimals = 18;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant _tTotal = 100000000000 * 10**18; // 100 Bilion
    uint256 public _maxWalletAmount;


    // fees
    uint256 public _liquidityFee = 2; // divided by 100
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _marketingFee = 5; // divided by 100
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 public _teamFee = 1; // divided by 100
    uint256 private _previousTeamFee = _teamFee;
    uint256 public _stakingPoolFee = 2; // divided by 100
    uint256 private _previousStakingPoolFee = _stakingPoolFee;
    
    
    uint256 private _marketingPercent = 625;
    uint256 private _teamPercent = 125;
    uint256 private _stakingPoolPercent = 250;

    address payable public _marketingAddress = payable(0x660f4E98f8DF215C957B47C5cBB7216c13cC8102);
    address payable public _teamAddress = payable(0x64BB98901B75a995F71Ae6d0EA3fa436406DA43f);
    address payable public _stakingPoolAddress = payable(0xb68236E44bB7bd7552Ba45a3a15Da39f77aDCCfa);
    IPancakeRouter02 private pancakeRouter;
    address public pancakePair;
    uint256 public _maxTxAmount;
    bool public swapAndLiquifyEnabled = false;
    uint256 public _minTokenBeforeSwap = 10000 * 10**18;

    bool private inSwap = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    event PercentsUpdated(uint256 _marketingPercent, uint256 _teamPercent, uint256 _stakingPoolPercent);
    event FeesUpdated(uint256 _marketingFee, uint256 _liquidityFee, uint256 _teamFee, uint256 _stakingPoolFee);
    event MaxWalletAmountUpdated(uint256 amount);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event ExcludedFromFees(address account);
    event IncludedInFees(address account);
    event StakingPoolUpdated(address stakingPool);
    event MarkettingAddressUpdated(address markettingAddress);
    event TeamAddressUpdated(address teamAddress);


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeRouter = _pancakeRouter;
        _approve(address(this), address(pancakeRouter), _tTotal);
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        IERC20(pancakePair).approve(address(pancakeRouter),type(uint256).max);

        _maxTxAmount = _tTotal.div(100); // start off transaction limit at 1% of total supply
        _maxWalletAmount = _tTotal.mul(3).div(100); // 3%

        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() override external pure returns (string memory) {
        return _name;
    }

    function symbol() override external pure returns (string memory) {
        return _symbol;
    }

    function decimals() override external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function removeAllFee() private {
        if (_marketingFee == 0 && _liquidityFee == 0 && _teamFee == 0 && _stakingPoolFee == 0) return;
        _previousMarketingFee = _marketingFee;
        _previousLiquidityFee = _liquidityFee;
        _previousTeamFee = _teamFee;
        _previousStakingPoolFee = _stakingPoolFee;
        
        _marketingFee = 0;
        _liquidityFee = 0;
        _teamFee = 0;
        _stakingPoolFee = 0;
    }
    
    function restoreAllFee() private {
        _marketingFee = _previousMarketingFee;
        _liquidityFee = _previousLiquidityFee;
        _teamFee = _previousTeamFee;
        _stakingPoolFee = _previousStakingPoolFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;
        if (from != owner() && to != owner() && from != address(this) && to != address(this) ) {
            require(amount <= _maxTxAmount, "Amount exceeds Max Transaction Amount");

            if (from == pancakePair && to != address(pancakeRouter)) {//buys
                require(balanceOf(to).add(amount) <= _maxWalletAmount, "wallet balance after transfer must be less than max wallet amount");
            }

            if (!inSwap && from != pancakePair) { //sells, transfers
                    
                if(to != pancakePair) {      
                    require(balanceOf(to).add(amount) <= _maxWalletAmount, "wallet balance after transfer must be less than max wallet amount");
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance > _minTokenBeforeSwap && swapAndLiquifyEnabled) {
                    swapAndLiquify(contractTokenBalance); 
                }

                uint256 contractBNBBalance = address(this).balance;
                if (contractBNBBalance > 0) {
                    sendBNBToFee(address(this).balance);
                }              
            } 
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        
        _tokenTransfer(from, to, amount, takeFee);
        restoreAllFee();
    }

    function swapTokensForBNB(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        _approve(address(this), address(pancakeRouter), tokenAmount);
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeRouter), tokenAmount);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: bnbAmount}(
              address(this),
              tokenAmount,
              0, // slippage is unavoidable
              0, // slippage is unavoidable
              address(this),
              block.timestamp
          );
    }
  
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 autoLPamount = _liquidityFee.mul(contractTokenBalance).div(_marketingFee.add(_teamFee).add(_stakingPoolFee).add(_liquidityFee));

        // split the contract balance into halves
        uint256 half =  autoLPamount.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBNB(otherHalf); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = ((address(this).balance.sub(initialBalance)).mul(half)).div(otherHalf);

        // add liquidity to pancakeswap
        addLiquidity(half, newBalance);
    }

    function sendBNBToFee(uint256 amount) private {
        uint256 markettingAmount = amount.mul(_marketingPercent).div(1000);
        uint256 teamAmount = amount.mul(_teamPercent).div(1000);
        uint256 stakingPoolAmount = amount.mul(_stakingPoolPercent).div(1000);

        (bool sent1,) = _marketingAddress.call{value: markettingAmount}("");
        (bool sent2,) = _teamAddress.call{value: teamAmount}("");
        (bool sent3,) = _stakingPoolAddress.call{value: stakingPoolAmount}("");

        require(sent1 && sent2 && sent3 , "Failed to send BNB");  
    }

    function manualTrigger() external {
        require(_msgSender() == _marketingAddress, "Caller is not authorised");
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance > 0) {
            swapAndLiquify(contractBalance);
            uint256 contractBNBBalance = address(this).balance;
            if(contractBNBBalance > 0) {
                sendBNBToFee(contractBNBBalance);
            }
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) { 
                removeAllFee();
        }
        _transferStandard(sender, recipient, amount);
        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        uint256 tMarketing = amount.mul(_marketingFee).div(100);
        uint256 tLiquidity = amount.mul(_liquidityFee).div(100);
        uint256 tTeam = amount.mul(_teamFee).div(100);
        uint256 tStakingPool = amount.mul(_stakingPoolFee).div(100);
        
        uint256 tAmount = amount.sub(tMarketing).sub(tLiquidity).sub(tTeam).sub(tStakingPool);
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tAmount);
        _balances[address(this)] = _balances[address(this)].add(tMarketing.add(tLiquidity).add(tTeam).add(tStakingPool));
        
        emit Transfer(sender, recipient, tAmount);
        emit Transfer(sender, address(this), tMarketing.add(tLiquidity).add(tTeam).add(tStakingPool));
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        require(swapAndLiquifyEnabled != _enabled, "Value already exists!");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}
    fallback() external payable {}

    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
    }
    
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount > _tTotal.div(10000), "Amount must be greater than 0.01% of supply");
        require(maxTxAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxTxAmount = maxTxAmount;
        emit MaxTxAmountUpdated(_maxTxAmount);
    }

    function setMaxWalletAmount(uint256 maxWalletAmount) external onlyOwner() {
        require(maxWalletAmount > _tTotal.div(200), "Amount must be greater than 0.5% of supply");
        require(maxWalletAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxWalletAmount = maxWalletAmount;
        emit MaxWalletAmountUpdated(_maxWalletAmount);
    }

    function setTaxes(uint256 marketingFee, uint256 liquidityFee, uint256 teamFee, uint256 stakingPoolFee) external onlyOwner() {
        uint256 totalFee = marketingFee.add(liquidityFee).add(teamFee).add(stakingPoolFee);
        require(totalFee <= 15, "Sum of fees must be less than or equals to 15");

        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _teamFee = teamFee;
        _stakingPoolFee = stakingPoolFee;
        
        _previousMarketingFee = _marketingFee;
        _previousLiquidityFee = _liquidityFee;
        _previousTeamFee = _teamFee;
        _previousStakingPoolFee = _stakingPoolFee;
        
        uint256 totalBNBfees = _marketingFee.add(_teamFee).add(_stakingPoolFee);
        
        _marketingPercent = (_marketingFee.mul(1000)).div(totalBNBfees);
        _teamPercent = (_teamFee.mul(1000)).div(totalBNBfees);
        _stakingPoolPercent = (_stakingPoolFee.mul(1000)).div(totalBNBfees);
        
        emit FeesUpdated(_marketingFee, _liquidityFee, _teamFee, _stakingPoolFee);
    }

    function updateMinTokenBeforeSwap(uint256 minTokenBeforeSwap) external onlyOwner() {
        _minTokenBeforeSwap = minTokenBeforeSwap;
        emit MinTokensBeforeSwapUpdated(_minTokenBeforeSwap);
    }

    function updatestakingPoolAddress(address payable stakingPoolAddress) external onlyOwner() {
        _stakingPoolAddress = stakingPoolAddress;
        emit StakingPoolUpdated(_stakingPoolAddress);
    }
    
    function updateMarketingAddress(address payable marketingAddress) external onlyOwner() {
        _marketingAddress = marketingAddress;
        emit MarkettingAddressUpdated(_marketingAddress);
    }
    
    function updateTeamAddress(address payable teamAddress) external onlyOwner() {
        _teamAddress = teamAddress;
        emit TeamAddressUpdated(_teamAddress);
    }
}