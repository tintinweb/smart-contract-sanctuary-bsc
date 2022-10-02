/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPL-3.0

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

    event OwnershipTransferred(address owner);
}

abstract contract AllTheFees is IBEP20, Auth {
    using SafeMath for uint256;

    //BUY feeTokens
    uint256 public BuyFeeLP = 1;
    uint256 public BuyFeeMarketing = 6;
    uint256 public BuyFeeBuyback = 2;
    uint256 public BuyFeeReward = 3;
    uint256 public BuyFeeHouse = 1;
    uint256 public BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBuyback).add(BuyFeeReward).add(BuyFeeHouse);
    //Total 13%

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeBuyback, 
        uint256 newBuyFeeReward,
        uint256 newBuyFeeHouse
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeBuyback = newBuyFeeBuyback;
        BuyFeeReward = newBuyFeeReward;
        BuyFeeHouse = newBuyFeeHouse;

        
        BuyFeeTotal = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBuyback).add(BuyFeeReward).add(BuyFeeHouse);
		require(BuyFeeTotal <= 13);
    }
    
    //Sell feeTokens
    uint256 public SellFeeLP = 1;
    uint256 public SellFeeMarketing = 8;
    uint256 public SellFeeBuyback = 2;
    uint256 public SellFeeReward = 3;
    uint256 public SellFeeHouse = 1;
    uint256 public SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeBuyback).add(SellFeeReward).add(SellFeeHouse);
    //Total 14-24%

    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeBuyback, 
        uint256 newSellFeeReward,
        uint256 newSellFeeHouse
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeBuyback = newSellFeeBuyback;
        SellFeeReward = newSellFeeReward;
        SellFeeHouse = newSellFeeHouse;
        
        SellFeeTotal = SellFeeLP.add(SellFeeMarketing).add(SellFeeBuyback).add(SellFeeReward).add(SellFeeHouse);
		require(SellFeeTotal <= 16);
    }

    

    uint256 public unpayedRewardOnContract;
    uint256 public luckyTxCounter;
    uint256 public requiredTransactionCountForLuckyShareRoll;
    function changeRequiredTransactionCountForLuckyShareRoll(uint256 newValue) external authorized {requiredTransactionCountForLuckyShareRoll = newValue;}

    uint256 public minimumTokensForRewards;
    function changeMinimumTokensForRewards(uint256 newValue) external authorized {
        minimumTokensForRewards = newValue;
    }

    uint256 public sellcounter;
    uint256 public minimumTokensToBuybackType2;
    function changeMinimumTokensToBuybackType2(uint256 newValue) external authorized {
        minimumTokensToBuybackType2 = newValue;
    }
    uint256 public buybackType2;
    uint256 public randomCounter;

    constructor(){
        minimumTokensForRewards = 10000;
        minimumTokensToBuybackType2 = 1000000000 * (10 ** 18) / 100;
        requiredTransactionCountForLuckyShareRoll = 5;
    }
}

contract FOMOToken is AllTheFees {
    using SafeMath for uint256;

    string constant _name = "Token of FOMO";
    string constant _symbol = "FOMO";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public _maxWallet = _totalSupply / 100; //Max wallet 10m
    function changeMaxWallet(uint256 newValue) external authorized{
        _maxWallet = newValue * (10 ** _decimals);
    }
    uint256 public _maxTransaction  = _totalSupply / 100; //Max tx 10m
    function changeMaxTransaction(uint256 newValue) external authorized{
        _maxTransaction = newValue * (10 ** _decimals);
    }
    uint256 public _minimumTokensToSwap = _totalSupply / 500; //2m tokens to swap
    function changeMinimumTokensToSwap(uint256 newValue) external authorized{
        _minimumTokensToSwap = newValue * (10 ** _decimals);
    }

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //Wallets for fees
    address marketingwallet = 0x2A1387e1F05F36A365D3f8986dE3ec879E049547; //Wallet of marketing fee
    address housewallet = 0xD8f98C478c6E891687C72816bf5907fEC19b2ea6; //Wallet of development fee
    address autoLiquidityReciever = 0xAc6bD92774d16462423e88318001903C79DfF4d7; //Should be the first wallet, that put in LP (owner)
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    //Basic contract variables (router, pair, routeraddress, rewardToken)
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 public router = IUniswapV2Router02(routerAddress);
    address public pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
    mapping (address => bool) public isMarketPair;
    
    address WBNBaddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address BUSDaddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardTokenBUSD = IBEP20(BUSDaddress);
    

    //Exemptions
    mapping(address => bool) public exemptFromMaxWallet;
    function changeExemptFromMaxWallet(address holder, bool newValue) external authorized{
        exemptFromMaxWallet[holder] = newValue;
    }
    mapping(address => bool) public exemptFromMaxTransaction;
    function changeExemptFromMaxTransaction(address holder, bool newValue) external authorized{
        exemptFromMaxTransaction[holder] = newValue;
    }
    mapping(address => bool) public exemptFromFee;
    function changeExemptFromFee(address holder, bool newValue) external authorized{
        exemptFromFee[holder] = newValue;
    }

    //Holders
    address[] public holders;
    function holdersLength() external view returns (uint256) {return holders.length;}
    mapping (address => uint256) public holderIndex;
    mapping (address => uint256) public holderLuckyNumber;
    mapping (address => uint256) public holderPreviousBalance;

    constructor() Auth(msg.sender){
        _balances[msg.sender] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
        _allowances[address(this)][address(router)] = type(uint256).max;

        exemptFromMaxWallet[msg.sender] = true;

        exemptFromMaxTransaction[msg.sender] = true;

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
		return _transferFrom(msg.sender, recipient, amount);
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
            //Swap tokens on contract

            if(balanceOf(address(this)) >= _minimumTokensToSwap && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled){swapAndLiquify();}
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (exemptFromFee[sender] || exemptFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);

            if(!isMarketPair[sender])
                checkHolders(sender, _balances[sender]);

            if(!isMarketPair[recipient])
                checkHolders(recipient, _balances[recipient]);

            luckyTxCounter = luckyTxCounter.add(1);
            if(luckyTxCounter >= requiredTransactionCountForLuckyShareRoll && unpayedRewardOnContract > 0){
                rollWinners();
                luckyTxCounter = 0;
            }
                


            return true;
        }
    }

    address[] public winners;
    function rollWinners() internal returns (bool){

        if(winners.length > 0){
            while(winners.length > 0){
                winners.pop();
            }
        }
        
        uint256 luckynumber = random(1,10);

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
                RewardTokenBUSD.transfer(winners[k], _balances[winners[k]].mul(unpayedRewardOnContract).div(allHoldings));
            }
            unpayedRewardOnContract = 0;
        }

        return true;
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
                buyback(buybackType2.div(2));
                buybackType2 = buybackType2.div(2);
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

    function random(uint256 min, uint256 max) internal returns (uint256) {
        /* uint256 randomHash = uint256(block.timestamp);
        uint256 randomNumber = randomHash.mod(max).add(min);
        return randomNumber; */

        randomCounter = randomCounter.add(block.timestamp.mod(10));
        uint256 HashOfRandom = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, holders.length, randomCounter)));
        uint256 randomNumber = HashOfRandom.mod(max).add(min);
        return randomNumber;
    } 

    struct SwapTokens{
        uint256 startingBalance;
        uint256 lpAmount;
        uint256 marketingAmount;
        uint256 bbAmount;
        uint256 winnersRewardAmount;
        uint256 houseAmount;
        uint256 tokensToSwapToEth;
    }

    struct SwapBNB{
        uint256 startingBalance;
        uint256 newlyGainedBNB;
        uint256 lpBNB;
        uint256 marketingBNB;
        uint256 bbBNB;
        uint256 houseBNB;
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
        swapTokens.houseAmount = swapTokens.startingBalance.mul(BuyFeeHouse.add(SellFeeHouse)).div(BuyFeeTotal.add(SellFeeTotal));

        swapTokens.tokensToSwapToEth = swapTokens.startingBalance.sub(swapTokens.lpAmount);

        swapBNB.startingBalance = address(this).balance;

        swapTokensForEth(swapTokens.tokensToSwapToEth);

        swapBNB.newlyGainedBNB = address(this).balance.sub(swapBNB.startingBalance);
        swapBNB.lpBNB = swapTokens.lpAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        addLiquidity(swapTokens.lpAmount, swapBNB.lpBNB);

        swapBNB.marketingBNB = swapTokens.marketingAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        buybackType2 = buybackType2.add(swapTokens.bbAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth));

        swapBNB.houseBNB = swapTokens.houseAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);

        (bool tmpSuccess,) = payable(marketingwallet).call{value: swapBNB.marketingBNB, gas: 50000}("");
		(bool tmpSuccess2,) = payable(housewallet).call{value: swapBNB.houseBNB, gas: 50000}("");

        tmpSuccess = false;
		tmpSuccess2 = false;

	    swapBUSD.busdBalanceBeforeSwap = RewardTokenBUSD.balanceOf(address(this));
 
        swapBUSD.bnbToSwap = swapTokens.winnersRewardAmount.mul(swapBNB.newlyGainedBNB).div(swapTokens.tokensToSwapToEth);
        swapEthForBUSD(swapBUSD.bnbToSwap);

        unpayedRewardOnContract = unpayedRewardOnContract.add(RewardTokenBUSD.balanceOf(address(this)).sub(swapBUSD.busdBalanceBeforeSwap)); 
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNBaddress;

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
        path[0] = WBNBaddress;
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
        path[0] = WBNBaddress;
        path[1] = BUSDaddress;

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
            holderLuckyNumber[holderToAdd] = random(1,10);
    }

    function removeHolder(address holderToRemove) internal {
        holders[holderIndex[holderToRemove]] = holders[holders.length-1];
        holderIndex[holders[holders.length-1]] = holderIndex[holderToRemove];
        holders.pop();

        if(holderLuckyNumber[holderToRemove] != 0)
            holderLuckyNumber[holderToRemove] = 0;
    }
}