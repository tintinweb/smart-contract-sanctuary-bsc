// SPDX-License-Identifier: MIT

/**
- Exclude From Fees
- Include To Fees 
- Exclude From Rewards
- Include to Rewards

 */

pragma solidity ^0.8.11;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./ERC20WithReflection.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./DateTime.sol";

contract XRISE is ERC20WithReflection, Ownable {
    using SafeMath for uint256;

    struct Operations {
        uint256 firstBuyDate;
        uint256 firstSellDate;
        uint256 lastBuyDate;
        uint256 lastSellDate;
        uint256 firstBuyBnbValue;
        bool isSet;
    }

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address public deadWallet;
    address payable public marketingWallet;
    address payable public devWallet;
    mapping (address => Operations) private _usersOperations;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public devFee = 4;
    uint256 public marketingFee = 4;
    uint256 public liqFee = 2;
    uint256 public reflectionFee = 2;
    uint256 public maxWalletPercent = 3;   

    uint256 public numOfNewHolders = 0;

    bool public tradingEnabled = false;
    bool public swapEnabled = true;
    bool private inSwap = false;
    uint256 public minAmountToSell = 1 * 10**10 * 10**9; // 0.1%

    constructor() ERC20WithReflection("XRise", "$XRSC", 10 * 10**12 * 10**9, reflectionFee, (devFee + marketingFee + liqFee)) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        deadWallet = 0x000000000000000000000000000000000000dEaD;
        marketingWallet = payable(0x34a05A16b3aF3d38bb79a2558f7d135D9Bf7436B);
        devWallet = payable(0xE7CaFFd76434BD36F5937b0AEfCB716964DF79fF);
    }

    receive() external payable {}

    function enableTrading() public onlyOwner{
        tradingEnabled = true;
    }

    function setSwapEnabled(bool swapEnabled_) public onlyOwner{
        swapEnabled = swapEnabled_;
    }

    function setRefFee(uint256 refFee_) public onlyOwner{
        reflectionFee = refFee_;
        super.setReflectionFee(refFee_);
    }

    function setDevFee(uint256 devFee_) public onlyOwner{
        devFee = devFee_;
        _updateContractFee();
    }

    function setMarketingFee(uint256 marketingFee_) public onlyOwner{
        marketingFee = marketingFee_;
        _updateContractFee();
    }

    function setLiquidityFee(uint256 liqFee_) public onlyOwner{
        liqFee = liqFee_;
        _updateContractFee();
    }

    function setMinAmountToSell(uint256 amount) public onlyOwner{
        minAmountToSell = amount;
    }

    function setMarketingAddress(address marketingWallet_) public onlyOwner{
        marketingWallet = payable(marketingWallet_);
    } 

    function setMaxWalletPercent(uint256 maxWalletPercent_) public onlyOwner{
        require(maxWalletPercent_ <= 100, "maxWalletPercent can't be > 100%");
        require(maxWalletPercent_ > 100, "maxWalletPercent can't be 0%");
        maxWalletPercent = maxWalletPercent_;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Already excluded");
        _isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] memory accounts,bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function excludeFromReward(address account) public onlyOwner {
        super.excludeAccountFromReward(account);
    }

    function includeInReward(address account) public onlyOwner {
        super.includeAccountInReward(account);
    }

    function _updateContractFee() private{
        super.setContractFee(devFee + marketingFee + liqFee);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override returns(bool skipFees) {
        if(
            to != address(this) && 
            from != address(this) &&
            to != deadWallet &&  
            to != marketingWallet && 
            to != devWallet &&
            from != owner() && 
            to != owner() &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            require(tradingEnabled == true, "Trading not enabled.");
            if(from != uniswapV2Pair){
                require(amount <= _allowedTxAmount(from), "Transfer amount exceeds the allowed maximum.");
            }
            if(to != uniswapV2Pair){
                uint256 accountTokens = balanceOf(to);
                require(accountTokens.add(amount) <= _maxWallet(),"Wallet holdings exceeds the allowed maximum.");
            }   
            _updateUserData(from, to, amount);
            if(to == uniswapV2Pair)
                _takeFees();
            return false;
        } else {
            return true;
        }  
    }

    function _maxWallet() private view returns(uint256) {
        return _tTotal.mul(maxWalletPercent).div(100);
    }

    function _allowedTxAmount(address from) private view returns(uint256) {
        Operations storage userOperations = _usersOperations[from];
        if(
            userOperations.firstSellDate == 0 && 
            userOperations.firstBuyBnbValue != 0 && 
            ((block.timestamp - userOperations.firstBuyDate) < (1 days))
        ){
            return _calculateApproxNumOfTokensFromBnbValue(userOperations.firstBuyBnbValue.mul(115).div(100));
        } else if((userOperations.lastSellDate != 0 && ((block.timestamp - userOperations.lastSellDate) > (90 days))) || 
            (userOperations.lastSellDate == 0 && ((block.timestamp - userOperations.firstBuyDate) > 90 days))){
            return balanceOf(from);
        } else if((block.timestamp - userOperations.lastSellDate) > (1 days)){
            return balanceOf(from).mul(10).div(100);
        }
        return 0;
    }

    function _calculateApproxNumOfTokensFromBnbValue(uint256 bnbValue) private view returns(uint256) {
        (uint256 reserveToken, uint256 reserveBnb) = _getReserves();
        return reserveToken.mul(bnbValue).div(reserveBnb);
    }

    function _calculateApproxBnvValueFromNumOfTokens(uint256 tokensValue) private view returns(uint256) {
        (uint256 reserveToken, uint256 reserveBnb) = _getReserves();
        return reserveBnb.mul(tokensValue).div(reserveToken);
    }

    function _getReserves() private view returns (uint256 _reserveToken, uint256 _reserveBnb) {
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint256 reserveToken;
        uint256 reserveBnb;
        (reserveToken, reserveBnb) = address(this) == IUniswapV2Pair(uniswapV2Pair).token0() ? (reserve0, reserve1) : (reserve1, reserve0);
        return(reserveToken, reserveBnb);
    }

    function _updateUserData(address from, address to, uint256 amount) private{
        Operations storage toOperation = _usersOperations[to];
        Operations storage fromOperation = _usersOperations[from];
        if(_usersOperations[to].isSet == false){
            toOperation.firstBuyDate = block.timestamp;
            toOperation.lastBuyDate = block.timestamp;
            if(from == uniswapV2Pair){
                toOperation.firstBuyBnbValue = _calculateApproxBnvValueFromNumOfTokens(amount);
            }
            if(to == uniswapV2Pair){
                fromOperation.lastSellDate = block.timestamp;
                if(fromOperation.firstSellDate == 0){
                    fromOperation.firstSellDate = block.timestamp;
                }
            }
            toOperation.isSet = true;
            numOfNewHolders++;
        } else {
            toOperation.lastBuyDate = block.timestamp;
            if(to == uniswapV2Pair){
                fromOperation.lastSellDate = block.timestamp;
                if(fromOperation.firstSellDate == 0){
                    fromOperation.firstSellDate = block.timestamp;
                }
            }    
        }
    }

    function _takeFees() private{
        uint256 currentBalance = balanceOf(address(this));
        if(swapEnabled && (currentBalance > minAmountToSell) && !inSwap){
            inSwap = true;
            uint256 amountToSwap = minAmountToSell;
            uint256 liquidityTokens = amountToSwap.mul(liqFee).div(liqFee + marketingFee + devFee);
            _swapAndLiquify(liquidityTokens);
            uint256 devAndMarketingTokens = amountToSwap.sub(liquidityTokens);
            _swapAndSendTokens(devAndMarketingTokens);
            inSwap = false;
        }
    }

    function _swapAndSendTokens(uint256 amount) private {
        uint256 initialBalance = address(this).balance;
        _swapTokens(amount);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 devAmount = newBalance.mul(devFee).div(devFee + marketingFee);
        devWallet.transfer(devAmount);
        uint256 marketingAmount = newBalance.mul(marketingFee).div(devFee + marketingFee);
        marketingWallet.transfer(marketingAmount);
    }

    function _swapTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapAndLiquify(uint256 amount) private {
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);
        uint256 initialBalance = address(this).balance;
        _swapTokens(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        _addLiquidity(otherHalf, newBalance);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }
}