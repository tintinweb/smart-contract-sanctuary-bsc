//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ICanMint.sol";
import "./uniswapV02.sol";
import "./DividendDistributor.sol";
import "./IBEP20.sol";

contract RFP_V2 is IBEP20, Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
        
    address  marketingFeeReceiver = 0x563A643a15253fc637B56facaA6B9149266Ee7d8;
    address devFeeReceiver = 0xee4FbdF874E7aD3F28d24Ef4b3b24358A47D88Df;    
    address public REWARD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD peg Bep20 testnet

    string constant _name = "Reward For Passion V2";
    string constant _symbol = "$RFP";
    uint8 constant _decimals = 18;

    uint256 _totalSupply;
    uint256 _maximumSupply;
    uint256 _halving =1;

    mapping(address => uint256) _balances;
    mapping(address=>uint256) _stakebalances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    // allowed users to do transactions before trading enable
    mapping(address => bool) isAuthorized;
    mapping(address => bool) isMaxTxExempt;
    mapping(address => bool) isMaxWalletExempt;

    // buy fees
    uint256 public buyRewardFee = 3;
    uint256 public buyMarketingFee = 3;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyDevFee = 3;
    uint256 public buyTotalFees = 10;
    // sell fees
    uint256 public sellRewardFee = 5;
    uint256 public sellMarketingFee = 4;
    uint256 public sellLiquidityFee = 1;
    uint256 public sellDevFee = 4;
    uint256 public sellTotalFees = 14;

    // swap percentage
    uint256 public rewardSwap = 3;
    uint256 public marketingSwap = 2;
    uint256 public liquiditySwap = 2;
    uint256 public devSwap = 2;
    uint256 public burnShare =1;
    uint256 public totalSwap = 10;

    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public dividendTracker;

    uint256 distributorGas = 500000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(1000); // 0.01% of supply
    uint256 public maxWalletTokens = _totalSupply.mul(5).div(100); // 0.5% of supply
    uint256 public maxTxAmount = _totalSupply.mul(10).div(100); // 0.1% of supply


          address public NewContract;
           mapping  (address=>bool) public externalContractToUsePin;
           mapping (address=>uint) public numberOfVotedDelegates;
            bool[] private vote;
           address public lastContractPermitted;
           mapping (address=>mapping(address=>Delegate)) private Voter;
           uint256 voteStartTime;
           uint256 voteEndTime;
            uint256 private incentive;
           bool firstExternalContract;
           uint256 numberOfPermittedContracts;
           address[] public PermmitedContracts;
           
         
           uint public numberOfDelegates;
            struct  Delegate {
             bool canVote;   
             bool  voted;
             bool voteType;
             uint256 serial_number;
               } 




    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
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
       
        isMaxTxExempt[pair] = true;
        isMaxTxExempt[address(this)] = true;
       
        isMaxWalletExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;

         whitelistPreSale(address(router));
         whitelistPreSale(owner());

       _mint(owner(), 300000000 ether, 4125764 ether);

    swapThreshold = _totalSupply.div(10000); // 0.01% of supply
    maxWalletTokens = _totalSupply.div(100); // 1% of supply
    maxTxAmount = _totalSupply.mul(75).div(10000); // 0.75% of supply

  


    }

    receive() external payable {}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function maximumSupply() public view override returns(uint256){
        return _maximumSupply;
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
     function halving() public override view returns (uint256) {
        return _halving;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
     
     function stakeBalanceOf(address account) public view override returns (uint256) {
        return _stakebalances[account];
    }

     function getOwner() external override view returns (address) {
        return owner();
    }

    function _mint(address account, uint256 totalMintAmount_, uint256 totalSupplyPercent) virtual internal{
         require(account != address(0), 'BEP20: mint to the zero address');
          
          _maximumSupply = _maximumSupply.add(totalMintAmount_);
           
            _balances[account] = _balances[account].add(totalSupplyPercent);
              _totalSupply = _totalSupply.add(totalSupplyPercent);
       
        emit Transfer(address(0),account,_totalSupply);
         
          
        }

    // tracker dashboard functions
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
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(  address owner, address spender,uint256 amount ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient,uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
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
            require(tradingOpen, "Trading not open yet");
        }
        if (!isMaxTxExempt[sender]) {
            require(amount <= maxTxAmount, "Max Transaction Amount exceed");
        }
        if (!isMaxWalletExempt[recipient]) {
            uint256 balanceAfterTransfer = amount.add(_balances[recipient]);
            require(balanceAfterTransfer <= maxWalletTokens, "Max Wallet Amount exceed");
        }
        if (shouldSwapBack()) {
            swapBackInBnb();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient)? takeFee(sender, amount, recipient): amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try dividendTracker.setShare(sender, _balances[sender].add(_stakebalances[sender])) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendTracker.setShare(recipient, _balances[recipient].add(_stakebalances[recipient])) {} catch {}
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
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address to)
        internal
        view
        returns (bool)
    {
        if (isFeeExempt[sender] || isFeeExempt[to]) {
            return false;
        } else {
            return true;
        }
    }

    function takeFee(address sender,uint256 amount, address to) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 burnAmount =0;
        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);
        } 
        else {

            feeAmount = amount.mul(buyTotalFees).div(100);
        }
        burnAmount =feeAmount.mul(burnShare*10).div(100);
        feeAmount = feeAmount.sub(burnAmount);

         burnTax(sender,burnAmount);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);       

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount).sub(burnAmount);
        
    }


    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
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
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
        isAuthorized[_preSale] = true;
        isMaxTxExempt[_preSale] = true;
        isMaxWalletExempt[_preSale] = true;
    
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

        // calculate tokens amount to swap
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
                  uint256 swappedTokensAmount = IBEP20(REWARD).balanceOf(address(this));
                // send token to reward
                IBEP20(REWARD).transfer(address(dividendTracker),swappedTokensAmount);
                try dividendTracker.deposit(swappedTokensAmount) {} catch {}
            }

      

       
        if (tokensToLiquidity > 0) {
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

    function setIsMaxTxExempt(address holder, bool exempt) external onlyOwner {
        isMaxTxExempt[holder] = exempt;
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
    function setFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setDevFeeReceiver(address _devFeeReceiver) external onlyOwner{
        devFeeReceiver = _devFeeReceiver;
    }

    function setburnPercent(uint256 _burnPercent) external onlyOwner {
        burnShare = _burnPercent;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount * (10**_decimals);
    }

    function setMaxWalletToken(uint256 amount) external onlyOwner {
        maxWalletTokens = amount * (10**_decimals);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
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


       function transferWithoutFees(address from, address to, uint256 amount,uint8 _switch) public override returns(bool){
        
          require(NewContract == address(0),"MINT CONSENSUS : PLEASE CONSULT COMMUNITY");
          require (externalContractToUsePin[_msgSender()],"Contract Not Permmitted");

            if(_switch == 0){  _stakebalances[from] = _stakebalances[from].add(amount);}
           if(_switch == 1){  _stakebalances[to] = _stakebalances[to].sub(amount);}

           return _basicTransfer(from,to, amount);
            
             }

          


   
       // address private voteContract;  // More than 20 accounts is needed.
     function startConsensus(address _contractToVote,address[20] memory voters) public onlyOwner{
        require(ICanMint(_contractToVote).isCanMint(),"Address Not Allowed");
        for(uint x =0; x<voters.length;x++){
         require(voters[x] !=address(0),"RFP: Address Zero not allowed");
         Voter[voters[x]][_contractToVote] = Delegate({canVote:true,voted:false,voteType:false,serial_number:0});
      
    }

           numberOfDelegates = voters.length;
            NewContract = _contractToVote;
                 
            incentive = 1 ether;
        
          voteStartTime = block.timestamp + 30 minutes; //testing purpose we use minutes; change to hours
          voteEndTime = voteStartTime + 1 hours;
          delete vote;
     }

    

     function iSVoted(address _votedUser, address con) public view returns(bool voted,bool voteType, uint serial_number) {
       
         Delegate memory delegate = Voter[_votedUser][con];
         voted = delegate.voted;
         voteType = delegate.voteType;
         serial_number = delegate.serial_number;
         
         return (voted,voteType,serial_number);
     }

      

        function disableExternalContractToUsePin(address _externalC) public onlyOwner{
            require(_externalC != address(0),"Address Zero not allowed");
            require(externalContractToUsePin[_externalC],"External Contract not set");
            
            externalContractToUsePin[_externalC]=false;
        }

        function voteExternalContractToUsePin(bool _vote) public{
            require( block.timestamp > voteStartTime, " Voting not Started");
           
            require( block.timestamp < voteEndTime, " Voting Ended");
                        
            require(Voter[_msgSender()][NewContract].canVote, "You are not Allowed to vote or You have Voted already");
                  vote.push(_vote);

                Voter[_msgSender()][NewContract] = Delegate({canVote:false,voted:true,voteType:_vote,serial_number:vote.length});
                numberOfVotedDelegates[NewContract] = vote.length;
                  _mintReward(_msgSender(),incentive,0);
               
        }

        /**
        New contract must be address(0), A situation where new Contract is not address zero needs community attenton
         */
        function checkForNewContract() public view returns(address){
            return NewContract;

        }

       function countVoteForExternalContract() public onlyOwner {
        require (block.timestamp > voteEndTime,"Voting is in process");       
           
           uint yes = 0; 
          

           for(uint x =0; x<vote.length;++x){
            if(vote[x] == true){yes +=1;}
           }

        
               if(yes > vote.length.mul(2).div(3) && vote.length>numberOfDelegates.div(2)){
                externalContractToUsePin[NewContract]=true;
                lastContractPermitted = NewContract;
                numberOfPermittedContracts +=1;
                PermmitedContracts.push(NewContract);
                
               }
               
                firstExternalContract = true;
               NewContract = address(0);
                 delete vote;
               // use emit event 
                 
       } 

             
       function ownerVetoFirstExternalContractToUsePin(address staking)  public onlyOwner {
             require(staking != address(0),"Address Zero not allowed");
             require(firstExternalContract != true, "firstExternalContract already set");
             require(ICanMint(staking).isCanMint(),"Address Not Allowed");

                 
                  externalContractToUsePin[staking]=true;
                  lastContractPermitted = staking;
                  NewContract =address(0);
                  firstExternalContract = true;
                  numberOfPermittedContracts=1;
                  PermmitedContracts.push(staking);
       }  





     function _mintReward(address to, uint256 amount,uint256 fee) internal returns(uint256){


            amount = amount.sub(fee);
           amount = amount.div(_halving);
           fee= fee.div(2);

             burnTax(address(this),fee.div(_halving));
             _balances[address(this)] = _balances[address(this)].add(fee.div(_halving));
             _balances[to] = _balances[to].add(amount.div(_halving));
             _totalSupply = _totalSupply.add(amount);

               
                emit Transfer(address(this),to,amount);
             _halving = (_totalSupply/_maximumSupply.mul(2).div(100));    
            return fee;    
     }

       function mineReward(address to,uint256 amount, bool isFee) override public{ 
        require (externalContractToUsePin[_msgSender()]," Contract not Permitted to use Function");
             
        amount = totalSupply().add(amount) >maximumSupply()? maximumSupply().sub(totalSupply()):amount;    
        require(totalSupply().add(amount) <= maximumSupply(), "RFP: `totalSupply` Exceeded");

            uint256 fee = isFee? amount.mul(5).div(100):0;
           _mintReward(to,amount,fee);  

    }

     
}