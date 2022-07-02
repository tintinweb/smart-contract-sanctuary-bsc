//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./uniswapV02.sol";
import "./DividendDistributor.sol";
import "./ISPAC3X20.sol";


contract SPAC3X20 is ISPAC3X20,Ownable{
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
        
    address  marketingFeeReceiver = 0xd4a582003f24Bd0ec788FC8d9196b006459de07e;
    address devFeeReceiver = 0x413Eb35fB55b385d3e9e3d8eE2643acB9d1e5258;    
   
    address public REWARD =// 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // BUSD peg Bep20 mainnet change to mainnet
    
     0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //testnet
  


    string constant _name = "SPAC3X";
    string constant _symbol = "SPAC3X";
    uint8 constant _decimals = 9;
    uint256 constant TOKEN = 10**9;

    uint256 public  _totalSupply;
    uint256 public _maximumSupply;
    uint256 public  _privateSaleAmount;
    uint256 public  _presaleAmount;
    uint256 public  _liquidityAmount;
    uint256 public  _teamTokenAmount;
    uint256 public  _initialMarketingAmount;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) isAuthorized;
    mapping(address=>bool) blackListed;  
    mapping(address => bool) isMaxWalletExempt;

    // buy fees
    uint256 public buyRewardFee = 8;
    uint256 public buyMarketingFee = 2;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyDevFee = 1;
    uint256 public buyTotalFees = 12;
    // sell fees
    uint256 public sellRewardFee = 8;
    uint256 public sellMarketingFee = 2;
    uint256 public sellLiquidityFee = 1;
    uint256 public sellDevFee = 1;
    uint256 public sellTotalFees = 12;

    // swap percentage
    uint256 public rewardSwap = 8;
    uint256 public marketingSwap = 2;
    uint256 public liquiditySwap = 1;
    uint256 public devSwap = 1;
    uint256 public totalSwap = 12;


  IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = false;
    uint256 maxTX = TOKEN.mul(100000000);

    DividendDistributor public dividendTracker;

    uint256 distributorGas = 700000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
  
    uint256 public swapThreshold = TOKEN.mul(100000000);

  
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

 

     function  SPAC3X(uint256 amount) internal pure returns(uint256) {
        return amount.mul(TOKEN);
      }

        constructor() 
    
     {
      // router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //mainent
          router= IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);  //testnet

        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
      
        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendTracker = new DividendDistributor(address(router), REWARD); //creating contract for dividend Distributor.
       
       
       
        isFeeExempt[marketingFeeReceiver]=true;
         isFeeExempt[devFeeReceiver]=true;



        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[marketingFeeReceiver]=true;
        isDividendExempt[devFeeReceiver]=true;      
              
        isMaxWalletExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;

         whitelistPreSale(address(router));
         whitelistPreSale(owner());

    uint256 _privateSaleAmt =SPAC3X(0);
    uint256 _liquidityAmt = SPAC3X(0);
    uint256 _teamTokenAmt = SPAC3X(0);
    uint256 _initialMarketingAmt = SPAC3X(0);
    uint256 _presaleAmt = SPAC3X(1000000000000);
   
    _mint(_msgSender(),
    _privateSaleAmt,
    _presaleAmt,
    _liquidityAmt,
    _teamTokenAmt,
    _initialMarketingAmt);  


    swapThreshold = TOKEN.mul(1000000000);
    uint256 one_percent = _totalSupply.mul(1).div(100);
    maxTX = TOKEN.mul(one_percent);
   
   
    }

    receive() external payable {
      //  _acceptFund();
    
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
     function name() public override  pure returns (string memory) {
        return _name;
    }

    function symbol() public override pure returns (string memory) {
        return _symbol;
    }

    function decimals() public override pure returns (uint8) {
        return _decimals;
    }
 
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
     
     function getOwner() external override view returns (address) {
        return owner();
    }

    function _mint(address account,
    uint256 privateSaleAmount,
    uint256 presaleAmount,
    uint256 liquidityAmount,
    uint256 teamTokenAmount,
    uint256 initialMarketingAmount
   ) virtual internal{

       
         require(account != address(0), 'BEP20: mint to the zero address');
            _privateSaleAmount = privateSaleAmount;
            _presaleAmount =presaleAmount;
             _liquidityAmount = liquidityAmount;
             _teamTokenAmount = teamTokenAmount;
             _initialMarketingAmount = initialMarketingAmount;
           
           uint256 totalSupply_ = _privateSaleAmount
           .add(_presaleAmount)
           .add(_liquidityAmount)
           .add(_teamTokenAmount)
           .add(_initialMarketingAmount);
                         
            _balances[account] = _balances[account].add(totalSupply_);
              _totalSupply = _totalSupply.add(totalSupply_);
                  
        emit Transfer(address(0),account,_totalSupply);
         
          
        }

    // tracker dashboard functions

    function setRewardingToken(address token) public onlyOwner{
        REWARD = token;
    }
    function getHolderDetails(address holder) public view returns (uint256,uint256,uint256,uint256) {
        return dividendTracker.getHolderDetails(holder);
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() public view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() public view returns (uint256) {
        return dividendTracker.totalDistributedRewards();
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)  public override returns (bool)    {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function _approve(  address owner, address spender,uint256 amount ) internal virtual {
        require(owner != address(0), "SPAC3X: approve from the zero address");
        require(spender != address(0), "SPAC3X: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient,uint256 amount) external override returns (bool) {
        if (_allowances[sender][_msgSender()] != type(uint256).max) {
         
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

      
                 

        if (!isAuthorized[sender]) {
            require(tradingOpen, "SPAC3X: Trading not open yet");
            require(!blackListed[sender], "SPAC3X:  BlackList");
            require(amount<= maxTX,"SPAC3X: Maximum Transfer Limit Exceeded");   

             if(!isMaxWalletExempt[recipient]){
            uint256 balanceAfter = balanceOf(recipient).add(amount);
            uint256 maxWallet = maxTX.mul(3);
            require(balanceAfter <= maxWallet,"SPAC3X: Maximum Wallet Exceeded");

           }

           }

          


  
          if (shouldSwapBack()) {
            swapBackInBnb();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Fund");

        uint256 amountReceived = shouldTakeFee(sender, recipient)? takeFee(sender, amount, recipient): amount;
       
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try dividendTracker.setShare(sender, _balances[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendTracker.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try dividendTracker.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            return false;
        } else {
            return true;
        }
    }

  
    function takeFee(address sender,uint256 amount, address recipient) internal returns (uint256) {
        uint256 feeAmount = 0;
      
        if (recipient == pair) {
          
          feeAmount = amount.mul(sellTotalFees).div(100);
          
        } 
        else {

            feeAmount = amount.mul(buyTotalFees).div(100);
        }
        

         _balances[address(this)] = _balances[address(this)].add(feeAmount);       

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
        
    }


    function shouldSwapBack() internal view returns (bool) {
        return
            _msgSender() != pair &&
            !inSwap &&
            swapEnabled &&
            tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(_msgSender()).transfer((amountBNB * amountPercentage).div(100));
   
    }

     function clearStuckSPAC3X(uint256 amountPercentage) external onlyOwner returns(bool){
        uint256 amountSPAC3X = balanceOf(address(this)).mul(amountPercentage).div(100);
      return   _basicTransfer(address(this),owner(), amountSPAC3X);
   
    }

   

    function updateBuyFees(uint256 reward, uint256 marketing,uint256 dev, uint256 liquidity) public onlyOwner {
        buyRewardFee = reward;
        buyMarketingFee = marketing;
        buyLiquidityFee = liquidity;  
        buyDevFee = dev;     
        buyTotalFees = reward.add(marketing).add(liquidity).add(dev);
    }

    function burnTax(address sender,uint256 _burnAmount) private {
        _balances[DEAD] = _balances[DEAD].add(_burnAmount);
       
        emit Transfer(sender,DEAD,_burnAmount);

    }

    function updateSellFees(uint256 reward, uint256 marketing,uint256 dev, uint256 liquidity) public onlyOwner {
        sellRewardFee = reward;
        sellMarketingFee = marketing;
        sellLiquidityFee = liquidity;
        sellDevFee = dev;
        sellTotalFees = reward.add(marketing).add(liquidity).add(dev);
    }

    // update swap percentages
    function updateSwapPercentages(uint256 reward,uint256 marketing,uint256 dev,uint256 liquidity) public onlyOwner {
        rewardSwap = reward;
        marketingSwap = marketing;
        liquiditySwap = liquidity;
        devSwap =dev;
        totalSwap = reward.add(marketing).add(liquidity).add(devSwap);
    }

    // switch Trading
    function openTrading(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
        isAuthorized[_preSale] = true;
        isMaxWalletExempt[_preSale] = true;
        blackListed[_preSale] = false;
    
    }

    // manual claim for the greedy humans
    function ___claimRewards(bool tryAll) public {
        dividendTracker.claimDividend();
        if (tryAll) {
            try dividendTracker.process(distributorGas) {} catch {}
        }
    }

    // manually clear the queue
    function claimProcess() public {
        try dividendTracker.process(distributorGas) {} catch {}
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];

        uint256 tokensToLiquidity = contractTokenBalance.mul(liquiditySwap).div(totalSwap );
        uint256 tokensToReward  = contractTokenBalance.mul(rewardSwap).div(totalSwap);
        uint256 tokensToDev = contractTokenBalance.mul(devSwap).div(totalSwap);
        uint256 tokensToMarketing = contractTokenBalance.sub(tokensToLiquidity).sub(tokensToReward).sub(tokensToDev);

        if (tokensToMarketing > 0 && marketingSwap > 0) {
            // swap the tokens
            swapTokensForEth(tokensToMarketing);
            // get swapped bnb amount
            uint256 swappedBnbAmount = address(this).balance;

            (bool marketingSuccess, ) = payable(marketingFeeReceiver).call{
                value: swappedBnbAmount,
                gas: 30000
            }("");
            marketingSuccess = false;
        }

        if (tokensToDev > 0 && devSwap > 0) {
            // swap the tokens
            swapTokensForEth(tokensToDev);
            // get swapped bnb amount
            uint256 swappedBnbAmount = address(this).balance;
              (bool devSuccess, ) = payable(devFeeReceiver).call{value: swappedBnbAmount,gas: 30000}("");
           

            devSuccess = false;
        
        }

          

                         
            if (tokensToReward > 0 && rewardSwap > 0) {
                 swapTokensForTokens(tokensToReward, REWARD);
                  uint256 swappedTokensAmount = ISPAC3X20(REWARD).balanceOf(address(this));
                // send token to reward
                ISPAC3X20(REWARD).transfer(address(dividendTracker),swappedTokensAmount);
                try dividendTracker.deposit(swappedTokensAmount) {} catch {}
            }

      

       
        if (tokensToLiquidity > 0 && liquiditySwap>0) {
            // add liquidity
            swapAndLiquify(tokensToLiquidity);
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit AutoLiquify(newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenToSwap;
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendTracker.setShare(holder, 0);
        } else {
            dividendTracker.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }


    function setIsMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isMaxWalletExempt[holder] = exempt;
    }

    function addAuthorizedWallets(address holder, bool exempt)
        external
        onlyOwner
    {
        isAuthorized[holder] = exempt;
    }

     function blackListAccount(address holder, bool exempt)
        external
        onlyOwner
    {
        blackListed[holder] = exempt;
    }

    function setFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setDevFeeReceiver(address _devFeeReceiver) external onlyOwner{
        devFeeReceiver = _devFeeReceiver;
    }

 
    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = TOKEN.mul(_amount);
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        dividendTracker.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorGas(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }
    
}