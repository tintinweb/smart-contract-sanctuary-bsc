/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
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


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until time lock");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


contract TeamMember is Context, Ownable {
    address[] private pvTeamMember;

    event TeamMemberAdd(address pvTeamMember);
    event TeamMemberRemove(address pvTeamMember);

    constructor () {
        pvTeamMember.push(_msgSender());
    }

    modifier teamMemberOnly() {
        bool allowedTeamMemberOnly = false;
        for(uint i = 0; i < pvTeamMember.length; i++) {
            if(pvTeamMember[i] == msg.sender) {
                allowedTeamMemberOnly = true;
            }
        }
        require(allowedTeamMemberOnly == true, 'only teammember allowed');
        _;
    }

    //ToDo: auf privat setzen oder der Transparenz wegen public lassen?
    function teamMemberExists(address _teammemberIsTeamMember) public view returns (bool){
        bool _exits = false;
        for(uint i = 0; i < pvTeamMember.length; i++) {
            if(pvTeamMember[i] == _teammemberIsTeamMember) {
                _exits = true;
            }
        }
        return _exits;
    }

    //ToDo: auf privat setzen oder der Transparenz wegen public lassen?
    function teamMemberGet(uint _i) public view virtual teamMemberOnly returns (address) {
        require(_i < pvTeamMember.length, 'Value is to heigh');
        return pvTeamMember[_i];
    }

    function teamMemberGetCount() public view virtual returns (uint256) {
        return pvTeamMember.length;
    }

    function teamMemberRemove(address _teammemberRemoveTeamMember) public virtual teamMemberOnly {
        require(teamMemberExists(_teammemberRemoveTeamMember), 'Account is no team member');
        require(_teammemberRemoveTeamMember != owner(),'Account is owner and cannot removed');
        for(uint i = 0; i < pvTeamMember.length; i++) {
            if (pvTeamMember[i] == _teammemberRemoveTeamMember) {
                delete pvTeamMember[i];
                break;
            }
        }
        emit TeamMemberRemove(_teammemberRemoveTeamMember);
    }

    function teamMemberSet(address _teammemberSetTeamMember) public virtual teamMemberOnly {
        require(!teamMemberExists(_teammemberSetTeamMember), 'Account is alreader a team member');
        pvTeamMember.push(_teammemberSetTeamMember);
        emit TeamMemberAdd(_teammemberSetTeamMember);
    }
}


contract TowerVerse is Context, IBEP20, Ownable, TeamMember {    
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _liquidityHolders;
    mapping(address => bool) private _isSniper;
    mapping(address => uint256) public dailySpent;
    mapping(address => uint256) public allowedTxAmount;
    mapping(address => uint256) public sellIntervalStart;
    mapping(address => bool) public _isMarketMaker;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**9 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public  _totalFeeBuy;
    uint256 public  _totalFeeSell;
    uint256 public  _totalFee;
    bool public _contractTokenBalanceIdenticalWithFee;

    string private _name = "TowerVerse";
    string private _symbol = "TOWERVERSE";
    uint8 private _decimals = 9;
    
    uint256 public swapAndLiquifycount = 0;
    uint256 public snipersCaught = 0;
    
    uint256 public _reflectionFee = 0;
    uint256 private _previousReflectionFee = _reflectionFee;
    
    uint256 public _liquidityFeeBuy = 0;
    uint256 private _previousLiquidityFeeBuy = _liquidityFeeBuy;
    uint256 public _liquidityFeeSell = 0;
    uint256 private _previousLiquidityFeeSell = _liquidityFeeSell;

    uint256 public div1Buy = 4;
    uint256 public div2Buy = 100;
    uint256 public div1Sell = 4;
    uint256 public div2Sell = 78;

    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap = 1 * 30 seconds;

    // Fee per address
    uint256 public _maxWallet = 20 * 10**6 * 10**9;
    uint256 public _maxTxAmount = 5 * 10**6 * 10**9;
    uint256 private minimumTokensBeforeSwap = 25 * 10**5 * 10**9;
    uint256 public launchedAt = 0;

    IPancakeRouter public pancakeRouter;
    address public pancakePair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private sniperProtection = true;
    bool public _hasLiqBeenAdded = false;
    bool public _tradingEnabled = false;

    address public currentLiqPair;
    address payable public buybackAddress = payable(0xe16f15968B7cCE71EB3d5312e008BEeA031Ed26c);
    address payable public marketingAddress = payable(0x3D02d6F1B203838D846Dca9a096b394D770028ED);
    address payable public lpAddress = payable(0xE795f9db4786cE0CDD8F41aDb21E95c4a6fdF4C3);
    address payable public stakingAddress = payable(0xD3f190d10E53B6685db2C8D1Ab584BBae440faD4);
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        transferOwnership(lpAddress);
        _rOwned[lpAddress] = _rTotal;     
        
        //kiemtienonline360 Router Testnet
        //https://pancake.kiemtienonline360.com
        //IPancakeRouter _pancakeRouter = IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //IPancakeRouter _pancakeRouter = IPancakeRouter(0x89556b652F24fbC10158D65dc0AD549bdBD053B7);

        //Pancakeswap Router Testnet
        //IPancakeRouter _pancakeRouter = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        //Pancakeswap Router Mainnet v2
        IPancakeRouter _pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        pancakePair = IPancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), _pancakeRouter.WETH());
        pancakeRouter = _pancakeRouter;

        _isMarketMaker[pancakePair] = true;
        _isExcludedFromFee[lpAddress] = true;
        _isExcludedFromFee[stakingAddress] = true;
        _isExcludedFromFee[address(0)];
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _liquidityHolders[lpAddress] = true;

        _startTimeForSwap = block.timestamp;
        
        emit Transfer(address(0), lpAddress, _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    //Controll functions for the first version of this contract-->
    function totalFeesBuy() public view returns (uint256) {
        return _totalFeeBuy;
    }

    function totalFeesSell() public view returns (uint256) {
        return _totalFeeSell;
    }

    function totalBuySellFees() public view returns (uint256) {
        return _totalFee;
    }
    
    //If there are rounding errors when determining the distribution, they can be corrected here.
    //These values only influence the tokens to be swapped and not the amount of the tax.
    function setTotalFees(uint256 paramTotalFeeBuy, uint256 paramTotalFeeSell, uint256 paramTotalFee) external onlyOwner {
        _totalFeeBuy = paramTotalFeeBuy;
        _totalFeeSell = paramTotalFeeSell;
        _totalFee = paramTotalFee;
    }  

    function MarketMakerSet(address _newMarketMaker, bool _aktive) public onlyOwner {
        require(_newMarketMaker != pancakePair);
        _isMarketMaker[_newMarketMaker] = _aktive;
    }
    //Controll functions for the first version of this contract<--
    
    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }    
    
    function deliver(uint256 tAmount) public {
        bool tIsBuy = false;
        bool tIsSell = true;
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount, tIsBuy, tIsSell);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
  
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, bool tIsBuy, bool tIsSell) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount, tIsBuy, tIsSell);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount, tIsBuy, tIsSell);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public teamMemberOnly() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external teamMemberOnly() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(_tradingEnabled, 'Trading is currently disabled');
            require(to != address(0), "BEP20: transfer to the zero address");
            if(to != pancakePair){
                require(balanceOf(to).add(amount) <= _maxWallet, "Transfer exceeds max");
            }else{
                if(sellIntervalStart[from] != 0){
                    if(sellIntervalStart[from].add(120) < block.timestamp){
                        allowedTxAmount[from] = _maxTxAmount;
                        sellIntervalStart[from] = block.timestamp;
                    }
                }
                if(allowedTxAmount[from] == 0 && sellIntervalStart[from] == 0){
                    allowedTxAmount[from] = _maxTxAmount;
                    sellIntervalStart[from] = block.timestamp;
                }
                if(amount > allowedTxAmount[from]){
                    revert("MaxTx Limit: Daily Limit Reached");
                }else{
                    if(allowedTxAmount[from].sub(amount) <= 0){
                        allowedTxAmount[from] = 0;
                    }else{
                        allowedTxAmount[from] = allowedTxAmount[from].sub(amount); 
                    }
                }
            }
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinimumSwapTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;    

        // Handle liquidity and buybacks
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(pancakePair) > 0 && !_isExcludedFromFee[from]) {
            if(to == pancakePair ){ 
                if (overMinimumSwapTokenBalance && _startTimeForSwap + _intervalSecondsForSwap <= block.timestamp) {
                    _startTimeForSwap = block.timestamp;
                    swapAndLiquifycount = swapAndLiquifycount.add(1);
                    swapAndLiquify(minimumTokensBeforeSwap);
                }  
            }
        }

        bool takeFee = true;
        
        // If any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        //Security query whether the summed values are correct. Only for the first contract version
        uint256 _sharePercentFeeBuy = 0;
        uint256 _sharePercentFeeSell = 0;
        uint256 _shareAmountFeeBuy = 0;
        uint256 _shareAmountFeeSell = 0;
        if (_totalFee != contractTokenBalance) {
            _contractTokenBalanceIdenticalWithFee = false;
        } else {
            _contractTokenBalanceIdenticalWithFee = true;
        }

        //Determining the proportions of the buy and sell fee --> buy
        if (_totalFee != 0) {
            _sharePercentFeeBuy = _totalFeeBuy.mul(100).div(_totalFee);
            _sharePercentFeeSell = _totalFeeSell.mul(100).div(_totalFee);
            _shareAmountFeeBuy = _sharePercentFeeBuy.mul(contractTokenBalance).div(100);
            _shareAmountFeeSell = _sharePercentFeeSell.mul(contractTokenBalance).div(100);
        } else {
            _shareAmountFeeBuy = contractTokenBalance.div(2);
            _shareAmountFeeSell = contractTokenBalance.div(2);
        }

		//Add Liquidity-->
        // split the contract balance into halves
        uint256 wholeBuy = _shareAmountFeeBuy.div(div1Buy);
        uint256 halfBuy = wholeBuy.div(2);
        uint256 otherHalfBuy = wholeBuy.sub(halfBuy);
        uint256 remainsBuy = _shareAmountFeeBuy.sub(wholeBuy);

        _totalFeeBuy = _totalFeeBuy.sub(wholeBuy).sub(remainsBuy);
        _totalFee = _totalFee.sub(wholeBuy).sub(remainsBuy);

		//Determining the proportions of the buy and sell fee --> Sell
        // split the contract balance into halves
        uint256 wholeSell = _shareAmountFeeSell.div(div1Sell);
        uint256 halfSell = wholeSell.div(2);
        uint256 otherHalfSell = wholeSell.sub(halfSell);
        uint256 remainsSell = _shareAmountFeeSell.sub(wholeSell);

        _totalFeeSell = _totalFeeSell.sub(wholeSell).sub(remainsSell);
        _totalFee = _totalFee.sub(wholeSell).sub(remainsSell);
        
        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
		uint256 totalHalves = halfBuy.add(halfSell);
        swapTokensForEth(totalHalves);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity
		uint256 totalOtherHalves = otherHalfBuy + otherHalfSell;
        addLiquidity(totalOtherHalves, newBalance);
		//Add Liquidity<--

		//Get Other Taxes-->
        // swap tokens for BNB --> Buy
		initialBalance = address(this).balance;
        swapTokensForEth(remainsBuy);
		
        //Determine values of buys
        uint256 transferredBalanceBuy = address(this).balance.sub(initialBalance);
        uint256 marketingBalanceBuy = transferredBalanceBuy.mul(div2Buy).div(100);
        uint256 buybackBalanceBuy = transferredBalanceBuy.sub(marketingBalanceBuy);		
				
		
		// swap tokens for BNB --> Sell
		initialBalance = address(this).balance;
		swapTokensForEth(remainsSell);
        
		//Determine values of sells
        uint256 transferredBalanceSell = address(this).balance.sub(initialBalance);
        uint256 marketingBalanceSell = transferredBalanceSell.mul(div2Sell).div(100);
        uint256 buybackBalanceSell = transferredBalanceSell.sub(marketingBalanceSell);
		
		uint256 marketingBalance = marketingBalanceBuy + marketingBalanceSell;
		uint256 buybackBalance = buybackBalanceBuy + buybackBalanceSell;
        
        // Send Token to Wallet address
        transferToAddressETH(buybackAddress, buybackBalance);
        transferToAddressETH(marketingAddress, marketingBalance);
        emit SwapAndLiquify(totalHalves, newBalance, totalOtherHalves);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the pancake pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), tokenAmount);

        // Make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of BNB
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRouter), tokenAmount);

        // Add the liquidity
        pancakeRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            lpAddress,
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(sniperProtection) {
          // if sender is a sniper address, reject the sell.
          if(isSniper(sender)) {
            revert('Sniper rejected.');
          }
    
          // check if this is the liquidity adding tx to startup.
          if(!_hasLiqBeenAdded) {
            _checkLiquidityAdd(sender, recipient);
          } else {
            if(
              launchedAt > 0
                && sender == pancakePair
                && !_liquidityHolders[sender]
                && !_liquidityHolders[recipient]
            ) {
              if(block.number - launchedAt < 3) {
                _isSniper[recipient] = true;
                snipersCaught++;
              }
            }
          }
        }
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        bool isBuy = _isMarketMaker[sender];
        bool isSell = _isMarketMaker[recipient];
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount, isBuy, isSell);
        if (isBuy) {
            _totalFeeBuy = _totalFeeBuy.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else if (isSell) {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        }
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        bool isBuy = _isMarketMaker[sender];
        bool isSell = _isMarketMaker[recipient];
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount, isBuy, isSell);
        if (isBuy) {
            _totalFeeBuy = _totalFeeBuy.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else if (isSell) {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        }
	    _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        bool isBuy = _isMarketMaker[sender];
        bool isSell = _isMarketMaker[recipient];
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount, isBuy, isSell);
        if (isBuy) {            
            _totalFeeBuy = _totalFeeBuy.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else if (isSell) {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        }
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        bool isBuy = _isMarketMaker[sender];
        bool isSell = _isMarketMaker[recipient];
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount, isBuy, isSell);
        if (isBuy) {
            _totalFeeBuy = _totalFeeBuy.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else if (isSell) {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        } else {
            _totalFeeSell = _totalFeeSell.add(tLiquidity);
            _totalFee = _totalFee.add(tLiquidity);
        }
    	_tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, bool tIsBuy, bool tIsSell) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount, tIsBuy, tIsSell);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount, bool tIsBuy, bool tIsSell) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount, tIsBuy, tIsSell);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        }
    
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(100);
    }
    
    function calculateLiquidityFee(uint256 _amount, bool _isBuy, bool _isSell) private view returns (uint256) {
        if (_isBuy) {
            return _amount.mul(_liquidityFeeBuy).div(100);
        } else if (_isSell) {
            if(launchedAt.add(3) >= block.number){
                return _amount.mul(_liquidityFeeSell.mul(7)).div(100);
            } else {
                return _amount.mul(_liquidityFeeSell).div(100);
            }
        } else {
            return _amount.mul(_liquidityFeeSell).div(100);
        }
    }
    
    function manualSwapandLiquify(uint256 _balance) external teamMemberOnly {
        swapAndLiquify(_balance);
    }
    
    function setLaunchLiqPair (address _pair) public onlyOwner {
        pancakePair = _pair;
    }
    
    function isSniper(address account) public view returns(bool) {
        return _isSniper[account];
    }
    
    function removeAllFee() private {
        if(_reflectionFee == 0 && _liquidityFeeBuy == 0 && _liquidityFeeSell == 0) return;
        
        _previousReflectionFee = _reflectionFee;
        _previousLiquidityFeeBuy = _liquidityFeeBuy;
        _previousLiquidityFeeSell = _liquidityFeeSell;
        
        _reflectionFee = 0;
        _liquidityFeeBuy = 0;
        _liquidityFeeSell = 0;
    }
    
    function restoreAllFee() private {
        _reflectionFee = _previousReflectionFee;
        _liquidityFeeBuy = _previousLiquidityFeeBuy;
        _liquidityFeeSell = _previousLiquidityFeeSell;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public teamMemberOnly {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public teamMemberOnly {
        _isExcludedFromFee[account] = false;
    }

    function GetSwapMinutes() public view returns(uint256) {
        return _intervalSecondsForSwap.div(60);
    }

    function SetSwapMinutes(uint256 newMinutes) external teamMemberOnly {
        _intervalSecondsForSwap = newMinutes * 1 minutes;
    }
    
    function setReflectionFeePercent(uint256 reflectionFee) external teamMemberOnly() {
        require(reflectionFee < 50, "tax too high");
        _reflectionFee = reflectionFee;
    }
        
    function setLiquidityFeePercent(uint256 liquidityFeeBuy, uint256 liquidityFeeSell) external teamMemberOnly {
        require(liquidityFeeBuy < 50, "tax too high");
        require(liquidityFeeSell < 50, "tax too high");
        _liquidityFeeBuy = liquidityFeeBuy;
        _liquidityFeeSell = liquidityFeeSell;
    }
    
    function setDivsBuy(uint256 _div1Buy, uint256 _div2Buy) external teamMemberOnly {
        div1Buy = _div1Buy;
        div2Buy = _div2Buy;
    }
    
    function setDivsSell(uint256 _div1Sell, uint256 _div2Sell) external teamMemberOnly {
        div1Sell = _div1Sell;
        div2Sell = _div2Sell;
    }

    function addressChange(address payable _lpAddress, address payable _stakingAddress, address payable _marketingAddress, address payable _buybackAddress) external onlyOwner{
        require(_marketingAddress != address(0),"cant set dev address 0");
        require(_buybackAddress != address(0),"cant set buyback address 0");
        lpAddress = _lpAddress;
        stakingAddress = _stakingAddress;
        marketingAddress = _marketingAddress;
        buybackAddress = _buybackAddress;
    }
    
    function _checkLiquidityAdd(address from, address to) private {
        // if liquidity is added by the _liquidityholders set trading enables to true and start the anti sniper timer
        require(!_hasLiqBeenAdded, 'Liquidity already added and marked.');
    
        if(_liquidityHolders[from] && to == pancakePair) {
          _hasLiqBeenAdded = true;
          _tradingEnabled = true;
          launchedAt = block.number;
        }
    }
    
    function removeSniper(address account) external teamMemberOnly { 
        require(_isSniper[account], 'Account is not a recorded sniper.');
        _isSniper[account] = false;
    }


    function changeWhaleSettings(uint256 maxTxAmount, uint256 maxWallet) external teamMemberOnly {
        require(maxTxAmount > totalSupply().div(1000), "max tx too low");
        require(maxWallet > totalSupply().div(1000), "max wallet too low");
        _maxWallet = maxWallet;
        _maxTxAmount = maxTxAmount;
    }
    
    function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap) external teamMemberOnly {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }  
    
    function setSwapAndLiquifyEnabled(bool _enabled) public teamMemberOnly {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function buyBack() public payable {
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(0,path,stakingAddress,block.timestamp.add(10));
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function preSaleBevor() external onlyOwner {
        setSwapAndLiquifyEnabled(false);
        _reflectionFee = 0;
        _liquidityFeeBuy = 0;
        _liquidityFeeSell = 0;
        _maxTxAmount = 1000000000 * 10**6 * 10**9;
    }
    
    function preSaleAfter() external onlyOwner {
        setSwapAndLiquifyEnabled(true);
        launchedAt = block.number;
        _hasLiqBeenAdded = true;
        _tradingEnabled = true;
        _reflectionFee = 0;
        _liquidityFeeBuy = 8;
        _liquidityFeeSell = 12;
        _maxTxAmount = 25 * 10**5 * 10**9;
    }

    function multisend( address[] memory dests, uint256[] memory values) public teamMemberOnly returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }

    function changeRouterVersion(address _router) public onlyOwner returns(address _pair) {
        IPancakeRouter _pancakeRouter = IPancakeRouter(_router);
        
        _pair = IPancakeFactory(_pancakeRouter.factory()).getPair(address(this), _pancakeRouter.WETH());
        if(_pair == address(0)){
            // Pair doesn't exist
            _pair = IPancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), _pancakeRouter.WETH());
        }
        pancakePair = _pair;

        // Set the router of the contract variables
        pancakeRouter = _pancakeRouter;
    }
    
     // To recieve BNB from pancakeV2Router when swapping
    receive() external payable {}

    function transferForeignToken(address _token, address _to) public teamMemberOnly returns(bool _sent){
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        _sent = IBEP20(_token).transfer(_to, _contractBalance);
    }
    
    function Sweep() external teamMemberOnly {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}