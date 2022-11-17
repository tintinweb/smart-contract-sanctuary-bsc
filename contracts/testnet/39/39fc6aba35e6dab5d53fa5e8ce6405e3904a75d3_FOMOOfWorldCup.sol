/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: GPL-3.0

/*
    The Token you don't want to miss out!

    - LP is locked 👌
    - Big names supporting 🔥
    - FIFA themed rewards with a twist (Lucky number) 💰💰💰
    - Automated Buyback and Burn mechanism 🤑🤑🤑

    You can join our private channel at: 
*/

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

library SafeMath {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Auth {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

abstract contract Fees is IBEP20, Auth {
    using SafeMath for uint256;

    //BUY feeTokens
    uint256 public BuyFeeLP = 1;
    uint256 public BuyFeeMarketing = 4;
    uint256 public BuyFeeBuyback = 1;
    uint256 public BuyFeeReward = 4;
    uint256 public BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBuyback).add(BuyFeeReward);
    //Total 13%

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeBuyback, 
        uint256 newBuyFeeReward
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeBuyback = newBuyFeeBuyback;
        BuyFeeReward = newBuyFeeReward;

        BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBuyback).add(BuyFeeReward);
		require(BuyFeeTotal <= 13);
    }
    
    //Sell feeTokens
    uint256 public SellFeeLP = 1;
    uint256 public SellFeeMarketing = 6;
    uint256 public SellFeeBuyback = 2;
    uint256 public SellFeeReward = 6;
    uint256 public SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeBuyback).add(SellFeeReward);
    //Total 15

    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeBuyback, 
        uint256 newSellFeeReward
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeBuyback = newSellFeeBuyback;
        SellFeeReward = newSellFeeReward;
        
        SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeBuyback).add(SellFeeReward);
		require(SellFeeTotal <= 30);
    }

    uint256 public unpayedRewardOnContract;
    uint256 public luckyTxCounter;
    uint256 public requiredTransactionCountForLuckyShareRoll;
    function changeRequiredTransactionCountForLuckyShareRoll(uint256 newValue) external authorized {requiredTransactionCountForLuckyShareRoll = newValue;}

    uint256 public minimumTokensForRewards;
    function changeMinimumTokensForRewards(uint256 newValue) external authorized {
        minimumTokensForRewards = newValue * (10 ** 18);
    }

    uint256 buybackType2;
    uint256 randomCounter;

    constructor(){
        minimumTokensForRewards = 10000 * (10 ** 18);
        requiredTransactionCountForLuckyShareRoll = 20;
    }
}

contract FOMOOfWorldCup is Fees {
    using SafeMath for uint256;

    string constant _name = "FOMO Of World Cup";
    string constant _symbol = "FOWC";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public _maxWallet = _totalSupply / 100; //Max wallet 10m (later it will be extended to 20m)
    function changeMaxWallet(uint256 newValue) external authorized{
        _maxWallet = newValue * (10 ** _decimals);
    }
    uint256 public _minimumTokensToSwap = _totalSupply / 500; //2m tokens to swap
    function changeMinimumTokensToSwap(uint256 newValue) external authorized{
        _minimumTokensToSwap = newValue * (10 ** _decimals);
    }

    bool inSwapAndLiquify;
    bool swapAndLiquifyEnabled = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //Wallets for fees
    address marketingwallet = 0xb1Fc7a84bEe64E9Ef2325Aa6e80A924876C487e0; //Wallet of marketing fee
    address housewallet = 0x4eE9298c164e2D13B45Ed928adb8853f6b735D5A; //Wallet of development fee
    address autoLiquidityReciever = 0x4eE9298c164e2D13B45Ed928adb8853f6b735D5A; //Should be the first wallet, that put in LP (owner)
    address DEAD = 0x000000000000000000000000000000000000dEaD;
	
	function changeRecieverWallets(address marketing, address house, address liquidity) external authorized {
        marketingwallet = marketing;
        housewallet = house;
        autoLiquidityReciever = liquidity;
    }

    //Basic contract variables (router, pair, routeraddress, rewardToken)
    //address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
    address pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
    mapping (address => bool) isMarketPair;
    
    //address RewardAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address RewardAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardInstance = IBEP20(RewardAddress);

    function changeRewardToken(address newReward) external authorized{
        RewardAddress = newReward;
        RewardInstance = IBEP20(RewardAddress);
    }

    //Exemptions
    mapping(address => bool) public exemptFromMaxWallet;
    function changeExemptFromMaxWallet(address holder, bool newValue) external authorized{
        exemptFromMaxWallet[holder] = newValue;
    }
    mapping(address => bool) public exemptFromFee;
    function changeExemptFromFee(address holder, bool newValue) external authorized{
        exemptFromFee[holder] = newValue;
    }

    //Holders
    address[] holders;
    function holdersLength() external view returns (uint256) {return holders.length;}
    mapping (address => uint256) holderIndex;
    mapping (address => uint256) public holderLuckyNumber;
    mapping (address => uint256) holderPreviousBalance;

    //Open trade
    bool tradingOpen;
    uint256 public tradeOpenedAt;

    function openTrade() public authorized {
        tradingOpen = true;
        tradeOpenedAt = block.timestamp;
    }

    constructor() Auth(msg.sender){
        _balances[msg.sender] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
        _allowances[address(this)][address(router)] = type(uint256).max;

        exemptFromMaxWallet[msg.sender] = true;
        exemptFromMaxWallet[address(this)] = true;
        exemptFromMaxWallet[DEAD] = true;

        exemptFromFee[msg.sender] = true;
        exemptFromFee[address(this)] = true;
        exemptFromFee[DEAD] = true;
        
        exemptFromMaxWallet[address(pair)] = true;
        isMarketPair[address(pair)] = true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function totalSupply() external view returns (uint256){return _totalSupply;}
    function decimals() external pure returns (uint8){return _decimals;}
    function symbol() external pure returns (string memory){return _symbol;}
    function name() external pure returns (string memory){return _name;}
    function getOwner() external view returns (address){return owner;}
    function balanceOf(address account) public view returns (uint256){return _balances[account];}
    function allowance(address _holder, address spender) external view returns (uint256){return _allowances[_holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool){

        if(isMarketPair[recipient] || isMarketPair[msg.sender]){
            _transferFrom(msg.sender, recipient, amount);
        }else{
			require(_balances[recipient].add(amount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");
            _basicTransfer(msg.sender, recipient, amount);
            checkHolders(msg.sender, _balances[msg.sender]);
            checkHolders(recipient, _balances[recipient]);
        }

		return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!authorizations[sender] && !authorizations[recipient]){
                require(tradingOpen, "Trading not open yet");
            }

            //Swap tokens on contract
            if(balanceOf(address(this)) >= _minimumTokensToSwap && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled){swapAndLiquify();}
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (exemptFromFee[sender] || exemptFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);

            if(!exemptFromMaxWallet[recipient])
                require(_balances[recipient].add(finalAmount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");

            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);

            
            if(!isMarketPair[sender])
                checkHolders(sender, _balances[sender]);

            if(!isMarketPair[recipient])
                checkHolders(recipient, _balances[recipient]);

            luckyTxCounter = luckyTxCounter.add(1);
            if(luckyTxCounter >= requiredTransactionCountForLuckyShareRoll && unpayedRewardOnContract > 0){
                rollWinners(recipient);
                luckyTxCounter = 0;
            }
                
            return true;
        }
    }

    address[] public winners;
    uint256 public luckynumber;

    function winnersLength() public view returns (uint256){return winners.length;}

    function rollWinners(address holder) internal returns (bool){

        if(winners.length > 0){
            while(winners.length > 0){
                winners.pop();
            }
        }
        
        luckynumber = random(holder, 1,10);

        for(uint256 i = 0; i < holders.length; i++){
            if(holderLuckyNumber[holders[i]] == luckynumber){
                winners.push(holders[i]);
            }
        }

        if(winners.length > 0){
            uint256 allHoldings;
            for(uint256 j = 0; j < winners.length; j++){
                allHoldings = allHoldings.add(_balances[winners[j]]);
            }

            for(uint256 k = 0; k < winners.length; k++){
                RewardInstance.transfer(winners[k], _balances[winners[k]].mul(unpayedRewardOnContract).div(allHoldings));
            }
            unpayedRewardOnContract = 0;
        }

        return true;
    }

    uint256 public buybackPercentage = 30;
    function changeBuybackPercentage(uint256 newPercentage) public authorized {
        buybackPercentage = newPercentage;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        
        //If its a buy
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(BuyFeeTotal).div(100);
        }
        //If its a sell
        else if(isMarketPair[receiver]) {
            feeAmount = amount.mul(SellFeeTotal).div(100);
            if(buybackType2 > 0){
                uint256 buybackAmount = buybackType2.mul(buybackPercentage).div(100);
                buyback(buybackAmount);
                buybackType2 = buybackType2.sub(buybackAmount);
            }
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkHolders(address holder, uint256 amount) internal {
        if(holder != DEAD && holder != marketingwallet && holder != housewallet && holder != address(this)){
            if(amount >= minimumTokensForRewards && holderPreviousBalance[holder] < minimumTokensForRewards){
                addHolder(holder);
            }else if(amount < minimumTokensForRewards && holderPreviousBalance[holder] >= minimumTokensForRewards){
                removeHolder(holder);
            }
            holderPreviousBalance[holder] = amount;
        }
    }

    function random(address holder, uint256 min, uint256 max) internal returns (uint256) {
        randomCounter = randomCounter.add(block.timestamp.mod(10));
        uint256 HashOfRandom = uint256(keccak256(abi.encodePacked(holder, balanceOf(holder), block.difficulty, block.timestamp, holders.length, randomCounter)));
        uint256 randomNumber = HashOfRandom.mod(max).add(min);
        return randomNumber;
    }

    function manualSendStuckBalance() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingwallet).transfer(contractETHBalance);
    }

    function manualSendStuckReward(address rewardAddress) external authorized {
        IBEP20 rewardToUnstuck = IBEP20(rewardAddress);
        uint256 balanceOfRewardOnCA = rewardToUnstuck.balanceOf(address(this));
        rewardToUnstuck.transfer(marketingwallet, balanceOfRewardOnCA);
    }

    struct SwapTokens{
        uint256 startingBalance;
        uint256 lpAmount;
        uint256 marketingAmount;
        uint256 bbAmount;
        uint256 winnersRewardAmount;
        uint256 tokensToSwapToEth;
    }

    struct SwapBNB{
        uint256 startingBalance;
        uint256 newlyGainedBNB;
        uint256 lpBNB;
        uint256 marketingBNB;
        uint256 bbBNB;
        uint256 winnerBNB;
    }

    struct SwapBUSD{
        uint256 busdBalanceBeforeSwap;
        uint256 bnbToSwap;
        uint256 newlyGainedBUSD;
        uint256 winnerBUSD;
    }

    function swapAndLiquify() internal lockTheSwap{
        SwapTokens memory swapTokens;
        SwapBNB memory swapBNB;
        SwapBUSD memory swapBUSD;

        swapTokens.startingBalance = balanceOf(address(this));
        swapTokens.lpAmount = (swapTokens.startingBalance.mul(BuyFeeLP.add(SellFeeLP)).div(BuyFeeTotal.add(SellFeeTotal))).div(2);

        swapTokens.marketingAmount = swapTokens.startingBalance.mul(BuyFeeMarketing.add(SellFeeMarketing)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.bbAmount = swapTokens.startingBalance.mul(BuyFeeBuyback.add(SellFeeBuyback)).div(BuyFeeTotal.add(SellFeeTotal));
        swapTokens.winnersRewardAmount = swapTokens.startingBalance.mul(BuyFeeReward.add(SellFeeReward)).div(BuyFeeTotal.add(SellFeeTotal));

        swapTokens.tokensToSwapToEth = swapTokens.startingBalance.sub(swapTokens.lpAmount);

        swapBNB.startingBalance = address(this).balance;

        swapTokensForEth(swapTokens.tokensToSwapToEth);

        swapBNB.newlyGainedBNB = address(this).balance.sub(swapBNB.startingBalance);
        swapBNB.lpBNB = swapTokens.lpAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        addLiquidity(swapTokens.lpAmount, swapBNB.lpBNB);

        swapBNB.marketingBNB = swapTokens.marketingAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        buybackType2 = buybackType2.add(swapTokens.bbAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth));

        (bool tmpSuccess,) = payable(marketingwallet).call{value: swapBNB.marketingBNB, gas: 50000}("");

        tmpSuccess = false;

	    swapBUSD.busdBalanceBeforeSwap = RewardInstance.balanceOf(address(this));
 
        swapBUSD.bnbToSwap = swapTokens.winnersRewardAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapEthForBUSD(swapBUSD.bnbToSwap);

        unpayedRewardOnContract = unpayedRewardOnContract.add(RewardInstance.balanceOf(address(this)).sub(swapBUSD.busdBalanceBeforeSwap)); 
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    function buyback(uint256 EthAmount) internal lockTheSwap{
        // generate the uniswap pair path of weth -> busd
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
            0,
            path,
            DEAD,
            block.timestamp
        );

        emit BuybackSuccessfull(EthAmount, path);
    }
    event BuybackSuccessfull(
        uint256 amountIn,
        address[] path
    );

    function swapEthForBUSD(uint256 EthAmount) internal {
        // generate the uniswap pair path of weth -> busd
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = RewardAddress;

        //router.WETH().approve(address(router), EthAmount);

        // make the swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapETHForBusd(EthAmount, path);
    }
    event SwapETHForBusd(
        uint256 amountIn,
        address[] path
    );

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {

        if(tokenAmount > 0){
            router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                autoLiquidityReciever,
                block.timestamp
            );
        emit LiquidityAdded(ethAmount, tokenAmount);
        }
    }
    event LiquidityAdded(
        uint256 ethAmount,
        uint256 tokenAmount
    );

    function addHolder(address holderToAdd) internal {
        holderIndex[holderToAdd] = holders.length;
        holders.push(holderToAdd);

        if(holderLuckyNumber[holderToAdd] == 0)
            holderLuckyNumber[holderToAdd] = random(holderToAdd, 1,10);
    }

    function removeHolder(address holderToRemove) internal {
        holders[holderIndex[holderToRemove]] = holders[holders.length-1];
        holderIndex[holders[holders.length-1]] = holderIndex[holderToRemove];
        holders.pop();

        if(holderLuckyNumber[holderToRemove] != 0)
            holderLuckyNumber[holderToRemove] = 0;
    }
}