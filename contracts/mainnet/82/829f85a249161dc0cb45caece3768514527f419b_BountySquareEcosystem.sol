/*
    BSC Token developed by Kraitor <TG: kraitordev>
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "IBEP20.sol";
import "SafeMath.sol";
import "MultiSignAuth.sol";
import "IDEXFactory.sol";
import "IDEXRouter.sol";

contract BountySquareEcosystem is IBEP20, MultiSignAuth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string constant _name = "Bounty Square Ecosystem";
    string constant _symbol = "bset";
    uint8 constant _decimals = 18;

    uint256 public _totalSupply = 100_000_000 * (10 ** _decimals);
    uint256 public _maxWalletSize = (_totalSupply * 35) / 1000;  //3.5% max wallet

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isWalletLimitExempt;

    //Open/close trade
    bool public isTradeOpened = false;

    //Total fee
    uint256 public buySellFee = 250;
    uint256 public feeDenominator = 10000;

    //Fees, all of them over buySellFee (250)
    uint256 public liquidityFee = 175;
    uint256 public marketingFee = 25;
    uint256 public rewardsFee = 25;
    uint256 public devFee = 25;

    //Fees receivers, can be set only one time
    address public liquidityFeeReceiver;
    address public marketingFeeReceiver;
    address public rewardsFeeReceiver;
    address public devFeeReceiver;

    //Wallet to manage project supply, unique wallet that allows burns
    address public supplyWallet;

    //Liq. pair and router
    IDEXRouter private router;
    address public pair;

    //Swapback settings
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 3; // 0.3%
    uint256 public pcThresholdMaxSell = 100; //Applied over swapThreshold

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address _WBNB, address _PANCAKE_ROUTER) MultiSignAuth(msg.sender) {
        if(_PANCAKE_ROUTER != address(0)){ PANCAKE_ROUTER = _PANCAKE_ROUTER; }
        if(_WBNB != address(0)){ WBNB = _WBNB; }

        router = IDEXRouter(PANCAKE_ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = getOwners()[0];
        isWalletLimitExempt[pair] = true;
        isWalletLimitExempt[address(this)] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function getCirculatingSupply() public view returns (uint256) { return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)); }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return getOwners()[0]; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }    

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        _allowances[msg.sender][spender] = type(uint256).max;
        emit Approval(msg.sender, spender, type(uint256).max);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        if (recipient != pair && recipient != DEAD) {
            require(isWalletLimitExempt[recipient] || isOwner[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        
        if(shouldSwapBack()){ swapBack(); }

        require(isTradeOpened || isOwner[sender], "Trade still not opened");

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = (shouldTakeFee(sender) && shouldTakeFee(recipient)) ? takeFee(sender, amount) : amount;        
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) { return !isOwner[sender] && !isFeeExempt[sender]; }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {        
        uint256 feeAmount = amount.mul(buySellFee).div(feeDenominator);        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);        
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance > swapThreshold.mul(pcThresholdMaxSell).div(100)){
            contractTokenBalance = swapThreshold.mul(pcThresholdMaxSell).div(100);
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ){}catch{}

        sendFees();
    }

    function sendFees() internal {
        uint256 amountBNB = address(this).balance;
        if(amountBNB > 0){
            uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(buySellFee);
            uint256 amountBNBDev = amountBNB.mul(devFee).div(buySellFee);
            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(buySellFee);
            uint256 amountBNBRewards = amountBNB.mul(rewardsFee).div(buySellFee);

            if(marketingFeeReceiver != address(0)){
                payable(marketingFeeReceiver).transfer(amountBNBMarketing);
            }
            if(devFeeReceiver != address(0)){
                payable(devFeeReceiver).transfer(amountBNBDev);
            }
            if(rewardsFeeReceiver != address(0)){
                payable(rewardsFeeReceiver).transfer(amountBNBRewards);
            }
            if(liquidityFeeReceiver != address(0)){
                payable(liquidityFeeReceiver).transfer(amountBNBLiquidity);
            }
        }
    }

    /* 
     * Functions that only can be triggered by owners, after the necessary confirmations
     */
    function openTrade(bool _open) external multiSignReq { 
        if(multiSign()){ 
            isTradeOpened = _open; 
        }
    }

    function burn(uint256 amount) external override multiSignReq {
        require(_balances[supplyWallet] >= amount, 'Not enough tokens to burn');

        if(multiSign()){ 
            _transferFrom(supplyWallet, DEAD, amount);
        }
    }

    /* 
     * Functions that only can be triggered by owners
     */
    function setIsFeeExempt(address holder, bool exempt) external onlyOwners { 
        isFeeExempt[holder] = exempt; 
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwners {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFeesReceivers(address _marketingFeeReceiver, address _devFeeReceiver, address _rewardsFeeReceiver, address _liqFeeReceiver) external onlyOwners {
        require(_marketingFeeReceiver != address(0) && _devFeeReceiver != address(0) && _rewardsFeeReceiver != address(0) && _liqFeeReceiver != address(0), "Zero address not allowed");
        require(marketingFeeReceiver == address(0) && devFeeReceiver == address(0) && rewardsFeeReceiver == address(0) && liquidityFeeReceiver == address(0), "Fees receivers only can be set one time");                    

        marketingFeeReceiver = _marketingFeeReceiver;        
        devFeeReceiver = _devFeeReceiver;
        rewardsFeeReceiver = _rewardsFeeReceiver;
        liquidityFeeReceiver = _liqFeeReceiver;

        isFeeExempt[marketingFeeReceiver] = true;               
        isFeeExempt[devFeeReceiver] = true;        
        isFeeExempt[rewardsFeeReceiver] = true;        
        isFeeExempt[liquidityFeeReceiver] = true;

        isWalletLimitExempt[marketingFeeReceiver] = true; 
        isWalletLimitExempt[devFeeReceiver] = true;   
        isWalletLimitExempt[rewardsFeeReceiver] = true;   
        isWalletLimitExempt[liquidityFeeReceiver] = true;   
    }

    function setSupplyWallet(address _supplyWallet) external onlyOwners { 
        require(_supplyWallet != address(0), "Zero address not allowed");
        require(supplyWallet == address(0), "Supply wallet only can be set one time");

        supplyWallet = _supplyWallet; 

        isFeeExempt[supplyWallet] = true;        
        isWalletLimitExempt[supplyWallet] = true;
    }

    function setSwapBackSettings(bool _enabled, uint256 _threshold, uint256 _pcThresholdMaxSell) external onlyOwners {
        require(pcThresholdMaxSell >= 100, "The _pcThresholdMaxSell has to be 100 or higher");

        swapEnabled = _enabled;
        swapThreshold = _threshold;
        pcThresholdMaxSell = _pcThresholdMaxSell;
    }

    function forceSwapBack() external onlyOwners { 
        swapBack(); 
    }

    function forceSendFees() external onlyOwners { 
        sendFees(); 
    }

    function transferForeignToken(address _token) public onlyOwners {
        require(_token != address(this), "Can't let you take native tokens");

        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        IBEP20(_token).transfer(msg.sender, _contractBalance);
    }
}