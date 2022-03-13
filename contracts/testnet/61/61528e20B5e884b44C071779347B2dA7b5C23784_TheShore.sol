/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity ^0.4.25;
interface IToken {
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}
interface ISwap {
    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);
    function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);
    function bnbToTokenSwapInput(uint256 min_tokens) external payable returns (uint256);
    function bnbToTokenSwapOutput(uint256 tokens_bought) external payable returns (uint256);
    function tokenToBnbSwapInput(uint256 tokens_sold, uint256 min_bnb) external returns (uint256);
    function tokenToBnbSwapOutput(uint256 bnb_bought, uint256 max_tokens) external returns (uint256);
    function getBnbToTokenInputPrice(uint256 bnb_sold) external view returns (uint256);
    function getBnbToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);
    function getTokenToBnbInputPrice(uint256 tokens_sold) external view returns (uint256);
    function getTokenToBnbOutputPrice(uint256 bnb_bought) external view returns (uint256) ;
    function tokenAddress() external view returns (address) ;
    function bnbBalance() external view returns (uint256);
    function tokenBalance() external view returns (uint256);
    function getBnbToLiquidityInputPrice(uint256 bnb_sold) external view returns (uint256);
    function getLiquidityToReserveInputPrice(uint amount) external view returns (uint256, uint256);
    function txs(address owner) external view returns (uint256) ;
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens) external payable returns (uint256) ;
    function removeLiquidity(uint256 amount, uint256 min_bnb, uint256 min_tokens) external returns (uint256, uint256);
}
contract TheShore {
    using SafeMath for uint;
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }
    modifier onlyStronghands {
        require(myDividends() > 0);
        _;
    }
    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint256 timestamp
    );
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingeth,
        uint256 tokensMinted,
        uint timestamp
    );
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethEarned,
        uint timestamp
    );
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethReinvested,
        uint256 tokensMinted,
        uint256 timestamp
    );
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethWithdrawn,
        uint256 timestamp
    );
    event onClaim(
        address indexed customerAddress,
        uint256 tokens,
        uint256 timestamp
    );
    event onTransfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 timestamp
    );
    event onBalance(
        uint256 bnbBalance,
        uint256 tokenBalance,
        uint256 timestamp
    );
    event onLiquiditySweep(
        uint amount
    );
    event onLiquidityProviderReward(
        uint amount
    );
    struct Stats {
        uint invested;
        uint reinvested;
        uint withdrawn;
        uint rewarded;
        uint taxes;
        uint contributed;
        uint transferredTokens;
        uint receivedTokens;
        uint xInvested;
        uint xReinvested;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredTokens;
        uint xReceivedTokens;
    }
    uint8 constant internal entryFee_ = 10;
    uint8 constant internal exitFee_  = 10;
    uint8 constant internal dripFee = 50;
    uint8 constant internal instantFee = 20;
    uint8 constant payoutRate_ = 2;
    uint256 constant internal magnitude = 2 ** 64;
    uint constant MAX_UINT = 2**256 - 1;
    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 public totalDeposits;
    uint256 public totalWithdrawn;
    uint256 internal lastBalance_;
    uint private lockedBalance;
    uint public players;
    uint public totalTxs;
    uint public dividendBalance;
    uint public lastPayout;
    uint public totalClaims;
    uint256 public balanceInterval = 30 seconds;
    uint256 public distributionInterval = 3 seconds;
    address public swapAddress;
    address public collateralAddress;
    IToken private swapToken;
    IToken private cToken;
    ISwap private swap;
    constructor(address _swapAddress, address _collateralAddress) public {
        swapAddress = _swapAddress;
        collateralAddress = _collateralAddress;
        swapToken = IToken(_swapAddress);
        swap = ISwap(_swapAddress);
        cToken = IToken(_collateralAddress);
        lastPayout = now;
    }
    function buy() public payable returns (uint256){
        require(msg.value >= 1e16, "min buy is 0.01 BNB");
        totalDeposits += msg.value;
        approveSwap();
        uint balance = address(this).balance;
        uint tokens = sellBnb(balance / 2);
        uint bnbAmount = SafeMath.min(swap.getTokenToBnbInputPrice(tokens), address(this).balance);
        uint liquidAmount = swap.addLiquidity.value(bnbAmount)(1, tokens);
        return buyFor(msg.sender, liquidAmount);
    }
    function buyFor(address _customerAddress, uint _buy_amount) internal returns (uint256)  {
        uint amount = purchaseTokens(_customerAddress, _buy_amount);
        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );
        distribute();
        return amount;
    }
    function() public payable  {
    }
    function reinvest() public onlyStronghands returns (uint) {
        uint256 _dividends = myDividends();
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        uint256 _tokens = purchaseTokens(msg.sender, _dividends);
        uint bnbAmount = calculateLiquidityToBnb(_dividends);
        emit onReinvestment(_customerAddress, bnbAmount, _tokens, now);
        stats[_customerAddress].reinvested = SafeMath.add(stats[_customerAddress].reinvested, bnbAmount);
        stats[_customerAddress].xReinvested += 1;
        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );
        distribute();
        return _tokens;
    }
    function withdraw() public onlyStronghands returns (uint) {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(); 
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        (uint bnbAmount, uint tokenAmount) = swap.removeLiquidity(_dividends,1,1);
        bnbAmount = bnbAmount.add(sellTokens(tokenAmount));
        _customerAddress.transfer(bnbAmount);
        totalWithdrawn += bnbAmount;
        stats[_customerAddress].withdrawn = SafeMath.add(stats[_customerAddress].withdrawn, bnbAmount);
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;
        totalClaims += _dividends;
        emit onWithdraw(_customerAddress, bnbAmount, now);
        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            now
        );
        distribute();
        return bnbAmount;
    }
    function sell(uint256 _amountOfTokens) onlyStronghands public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) / 100;
        uint256 _taxedeth = SafeMath.sub(_amountOfTokens, _undividedDividends);
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens + (_taxedeth * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;
        allocateFees(_undividedDividends);
        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedeth, now);
        distribute();
    }
    function totalTokenBalance() public view returns (uint256) {
        return swapToken.balanceOf(address(this));
    }
    function lockedTokenBalance() public view returns (uint256) {
        return lockedBalance;
    }
    function collateralBalance() public view returns (uint256) {
        return cToken.balanceOf(address(this));
    }
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    function myDividends() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }
    function bnbBalance(address _customerAddress) public view returns (uint256) {
        return _customerAddress.balance;
    }
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }
    function approveSwap() internal {
        require(cToken.approve(swapAddress, MAX_UINT), "Need to approve swap before selling tokens");
    }
    function sellTokens(uint256 amount) internal returns (uint256) {
        approveSwap();
        return swap.tokenToBnbSwapInput(amount,1);
    }
    function sellBnb(uint256 amount) internal returns (uint256){
        return swap.bnbToTokenSwapInput.value(amount)(1);
    }
    function calculateLiquidityToBnb(uint256 _amount) public view returns (uint256) {
        if (_amount > 0){
            (uint bnbAmount, uint tokenAmount) = swap.getLiquidityToReserveInputPrice(_amount);
            return bnbAmount.add(swap.getTokenToBnbInputPrice(tokenAmount));
        } else {
            return 0;
        }
    }
    function calculateTaxedBnbToTokenLiquidity(uint256 _amount) public view returns (uint256) {
        if (_amount > 0){
            uint amount = swap.getBnbToLiquidityInputPrice(_amount.div(2));
            return amount.mul(SafeMath.sub(100,entryFee_)).div(100);
        } else {
            return 0;
        }
    }
    function calculateTaxedLiquidityToBnb(uint256 _amount) public view returns (uint256){
        if (_amount > 0){
            _amount = _amount.mul(SafeMath.sub(100,entryFee_)).div(100);
            (uint bnbAmount, uint tokenAmount) = swap.getLiquidityToReserveInputPrice(_amount);
            return bnbAmount.add(swap.getTokenToBnbInputPrice(tokenAmount));
        } else {
            return 0;
        }
    }
    function sweep() public returns (uint256){
        uint balanceOriginTokens = collateralBalance();
        if (balanceOriginTokens >= 1e18  && tokenSupply_ > 0){
            uint halfTokens = balanceOriginTokens.div(2);
            uint balanceBnb = sellTokens(halfTokens);
            uint balanceTokens = collateralBalance();
            uint bnbAmount = SafeMath.min(swap.getTokenToBnbInputPrice(balanceTokens), balanceBnb);
            uint liquidAmount = swap.addLiquidity.value(bnbAmount)(1, balanceTokens);
            uint halfLiq = liquidAmount.div(2);
            uint sweepBalance = liquidAmount.sub(halfLiq);
            dividendBalance += sweepBalance;
            lockedBalance += halfLiq;
            emit onLiquiditySweep(halfLiq);
            emit onLiquidityProviderReward(halfLiq);
            return liquidAmount;
        } else {
            return 0;
        }
    }
    function statsOf(address _customerAddress) public view returns (uint256[15] memory){
        Stats memory s = stats[_customerAddress];
        uint256[15] memory statArray = [s.invested, s.withdrawn, s.rewarded, s.taxes, s.contributed, s.transferredTokens, s.receivedTokens, s.xInvested, s.xRewarded, s.xContributed, s.xWithdrawn, s.xTransferredTokens, s.xReceivedTokens, s.reinvested, s.xReinvested];
        return statArray;
    }
    function dailyEstimateBnb(address _customerAddress) public view returns (uint256){
        if (tokenSupply_ > 0){
            uint256 share = dividendBalance.mul(payoutRate_).div(100);
            uint256 estimate = share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_);
            (uint bnbAmount, uint tokenAmount) = swap.getLiquidityToReserveInputPrice(estimate);
            return bnbAmount.add(swap.getTokenToBnbInputPrice(tokenAmount));
        } else {
            return 0;
        }
    }
    function dailyEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = dividendBalance.mul(payoutRate_).div(100);
        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }
    function allocateFees(uint fee) private {
        uint _share = fee.div(100);
        uint _drip = _share.mul(dripFee);           
        uint _instant = _share.mul(instantFee);     
        uint _lock = fee.safeSub(_drip + _instant); 
        if (tokenSupply_ > 0) {
            profitPerShare_ = SafeMath.add(profitPerShare_, (_instant * magnitude) / tokenSupply_);
        }
        dividendBalance += _drip;
        lockedBalance += _lock;
    }
    function distribute() private {
        if (now.safeSub(lastBalance_) > balanceInterval && totalTokenBalance() > 0) {
            (uint bnbAmount, uint tokenAmount) = swap.getLiquidityToReserveInputPrice(totalTokenBalance());
            emit onBalance(bnbAmount, tokenAmount, now);
            lastBalance_ = now;
        }
        if (SafeMath.safeSub(now, lastPayout) > distributionInterval && tokenSupply_ > 0) {
            uint256 share = dividendBalance.mul(payoutRate_).div(100).div(24 hours);
            uint256 profit = share * now.safeSub(lastPayout);
            dividendBalance = dividendBalance.safeSub(profit);
            profitPerShare_ = SafeMath.add(profitPerShare_, (profit * magnitude) / tokenSupply_);
            sweep();
            lastPayout = now;
        }
    }
    function purchaseTokens(address _customerAddress, uint256 _incomingtokens) internal returns (uint256) {
        if (stats[_customerAddress].invested == 0 && stats[_customerAddress].receivedTokens == 0) {
            players += 1;
        }
        totalTxs += 1;
        uint256 _undividedDividends = SafeMath.mul(_incomingtokens, entryFee_) / 100;     
        uint256 _amountOfTokens     = SafeMath.sub(_incomingtokens, _undividedDividends); 
        uint256 bnbAmount = calculateLiquidityToBnb(_incomingtokens); 
        emit onTokenPurchase(_customerAddress, bnbAmount, _amountOfTokens, now);
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_, "Tokens need to be positive");
        if (tokenSupply_ > 0) {
            tokenSupply_ += _amountOfTokens;
        } else {
            tokenSupply_ = _amountOfTokens;
        }
        allocateFees(_undividedDividends);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;
        stats[_customerAddress].taxes += _undividedDividends;
        stats[_customerAddress].invested += bnbAmount;
        stats[_customerAddress].xInvested += 1;
        return _amountOfTokens;
    }
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}