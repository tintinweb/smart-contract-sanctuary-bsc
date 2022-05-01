//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./KRAIDDistributor.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapRouter02.sol";

contract KittyRaid is IERC20, Context, Ownable {
    
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Address for address;

    // token data
    string constant _name = "KittyRaid";
    string constant _symbol = "KRAID";
    uint8 constant _decimals = 9;
    // 10 Billion Max Supply
    uint256 _totalSupply = 1 * 10**10 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(200); // 0.5% or 50 million
    // balances
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    // exemptions
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    // fees
    uint256 public liquidityFee = 250;
    uint256 public reflectionFee = 850;
    uint256 public marketingFee = 150;
    // total fees
    uint256 totalFeeSells = 1250;
    uint256 totalFeeBuys = 1250;
    uint256 feeDenominator = 10000;
    // Marketing Funds Receiver
    address public marketingFeeReceiver = 0x37A76Cee1Cc1C1C8332F448C6bddEEB14E55aDb3;
    //Liquidity fee receiver
    address public autoLiquidityReceiver = 0x37A76Cee1Cc1C1C8332F448C6bddEEB14E55aDb3;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public ZERO = 0x0000000000000000000000000000000000000000;
    // minimum bnb needed for distribution
    uint256 public minimumToDistribute = 2 * 10**17;
    // targetliquidity, initially set at 25%
    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;
    // Pancakeswap V2 Router
    IUniswapV2Router02 router;
    address public pair;
    bool public allowTransferToMarketing = true;
    // gas for distributor
    KRAIDDistributor public distributor;
    uint256 distributorGas = 500000;
    // in charge of swapping
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.div(300); // 0.033% = 3.33 million
    // true if our threshold decreases with circulating supply
    bool public canChangeSwapThreshold = false;
    uint256 public swapThresholdPercentOfCirculatingSupply = 300;
    bool inSwap;
    bool isDistributing;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    modifier distributing() { isDistributing = true; _; isDistributing = false; }
    // Uniswap Router V2
    address private _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    constructor (
    ) {
        // Pancakeswap V2 Router
        router = IUniswapV2Router02(_dexRouter);
        // Liquidity Pool Address for BNB -> KittyRaid
        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        // our dividend Distributor
        distributor = new KRAIDDistributor(_dexRouter);
        // exempt deployer and contract from fees
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        // exempt important addresses from TX limit
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[address(distributor)] = true;
        isTxLimitExempt[address(this)] = true;
        // exempt this important addresses  from receiving Rewards
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        // approve router of total supply
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function internalApprove() private {
        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;
    }
    
    /** Approve Total Supply */
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    
    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // make standard checks
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // check if we have reached the transaction limit
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        // whether transfer succeeded
        bool success;
        // amount of tokens received by recipient
        uint256 amountReceived;
        // if we're in swap perform a basic transfer
        if(inSwap || isDistributing){ 
            (amountReceived, success) = handleTransferBody(sender, recipient, amount); 
            emit Transfer(sender, recipient, amountReceived);
            return success;
        }
        
        // limit gas consumption by splitting up operations
        if(shouldSwapBack()) { 
            swapBack();
            (amountReceived, success) = handleTransferBody(sender, recipient, amount);
        } else if (shouldReflectAndDistribute()) {
            reflectAndDistribute();
            (amountReceived, success) = handleTransferBody(sender, recipient, amount);
        } else {
            (amountReceived, success) = handleTransferBody(sender, recipient, amount);
            try distributor.process(distributorGas) {} catch {}
        }
        
        emit Transfer(sender, recipient, amountReceived);
        return success;
    }
    
    /** Takes Associated Fees and sets holders' new Share for the KittyRaid Distributor */
    function handleTransferBody(address sender, address recipient, uint256 amount) internal returns (uint256, bool) {
        // subtract balance from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        // amount receiver should receive
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(recipient, amount) : amount;
        // add amount to recipient
        _balances[recipient] = _balances[recipient].add(amountReceived);
        // set shares for distributors
        if(!isDividendExempt[sender]){ 
            distributor.setShare(sender, _balances[sender]);
        }
        if(!isDividendExempt[recipient]){ 
            distributor.setShare(recipient, _balances[recipient]);
        }
        // return the amount received by receiver
        return (amountReceived, true);
    }

    /** False if sender is Fee Exempt, True if not */
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
    
    /** Takes Proper Fee (12.5% buys / transfers, 12.5% on sells) and stores in contract */
    function takeFee(address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        return amount.sub(feeAmount);
    }
    
    /** True if we should swap from KittyRaid => BNB */
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    
    /**
     *  Swaps KittyRaid for BNB if threshold is reached and the swap is enabled
     *  Adds partial to LP if contract is not overliquified
     *  Swaps The Rest For BNB
     */
    function swapBack() private swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFeeSells).div(2);
        // How many tokens are swapped to BNB
        uint256 swapAmount = swapThreshold.sub(amountToLiquify);

        // Path from token -> BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        // Swap tokens for BNB
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFeeSells.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
            
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        
        // Tell The Blockchain
        emit SwappedBack(swapAmount, amountToLiquify);
    }
    
    function shouldReflectAndDistribute() private view returns(bool) {
        return msg.sender != pair
        && !isDistributing
        && swapEnabled
        && address(this).balance >= minimumToDistribute;
    }
    
    function reflectAndDistribute() private distributing {
        
        bool success; bool successful;
        uint256 amountBNBMarketing; uint256 amountBNBReflection;
        // allocate bnb
        if (allowTransferToMarketing) {
            amountBNBMarketing = address(this).balance.mul(marketingFee).div(totalFeeSells);
            amountBNBReflection = address(this).balance.sub(amountBNBMarketing);
            // fund distributors
            (success,) = payable(address(distributor)).call{value: amountBNBReflection, gas: 26000}("");
            distributor.deposit();
            // transfer to marketing
            if (allowTransferToMarketing) {
                (successful,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 26000}("");
            }
        } else {
            amountBNBReflection = address(this).balance;
            // fund distributors
            (success,) = payable(address(distributor)).call{value: amountBNBReflection, gas: 26000}("");
            distributor.deposit();
        }
        emit FundDistributors(amountBNBReflection, amountBNBMarketing);
    }
   
    /** Claim Your KittyCat Rewards Early */
    function claimKITDividend() external returns (bool) {
        distributor.claimKITDividend(msg.sender);
        return true;
    }
    
    /** Claim Your Shiba Rewards Manually */
    function claimSHIBDividend() external returns (bool) {
        distributor.claimShibaDividend(msg.sender);
        return true;
    }

    /** Manually Depsoits To The KIT or SHIB Contract */
    function manuallyDeposit() external returns (bool){
        distributor.deposit();
        return true;
    }
    
    /** Is Holder Exempt From Fees */
    function getIsFeeExempt(address holder) public view returns (bool) {
        return isFeeExempt[holder];
    }
    
    /** Is Holder Exempt From Dividends */
    function getIsDividendExempt(address holder) public view returns (bool) {
        return isDividendExempt[holder];
    }
    
    /** Is Holder Exempt From Transaction Limit */
    function getIsTxLimitExempt(address holder) public view returns (bool) {
        return isTxLimitExempt[holder];
    }
        
    /** Get Fees for Buying or Selling */
    function getTotalFee(bool selling) public view returns (uint256) {
        if(selling){ return totalFeeSells; }
        return totalFeeBuys;
    }

        function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

        function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    /** Returns whether contract is over liquified */
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    /** Sets Various Fees */
    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _buyFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFeeSells = _liquidityFee.add(_reflectionFee).add(_marketingFee);
        totalFeeBuys = _buyFee;
        require(_buyFee <= 1500);
        require(totalFeeSells < feeDenominator/4);
    }
    
    /** Set Exemption For Holder */
    function setIsFeeAndTXLimitExempt(address holder, bool feeExempt, bool txLimitExempt) external onlyOwner {
        require(holder != address(0));
        isFeeExempt[holder] = feeExempt;
        isTxLimitExempt[holder] = txLimitExempt;
    }
    
    /** Set Holder To Be Exempt From Dividends */
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }
    
    /** Set Settings related to Swaps */
    function setSwapBackSettings(uint256 _swapThreshold, bool _canChangeSwapThreshold, uint256 _percentOfCirculatingSupply, uint256 _minimumBNBToDistribute) external onlyOwner {
        swapThreshold = _swapThreshold;
        canChangeSwapThreshold = _canChangeSwapThreshold;
        swapThresholdPercentOfCirculatingSupply = _percentOfCirculatingSupply;
        minimumToDistribute = _minimumBNBToDistribute;
    }

    /** Set Settings related to target liquidity */
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    /** Set Criteria For KittyRaid Distributor */
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _bnbToTokenThreshold) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _bnbToTokenThreshold);
    }

    /** Should We Transfer To Marketing and set LP receiver */
    function setAllowTransferToMarketing(bool _canSendToMarketing, address _marketingFeeReceiver, address _autoLiquidityReceiver) external onlyOwner {
        allowTransferToMarketing = _canSendToMarketing;
        marketingFeeReceiver = _marketingFeeReceiver;
        autoLiquidityReceiver = _autoLiquidityReceiver;
    }
    
    /** Updates The Pancakeswap Router */
    function setDexRouter(address nRouter) external onlyOwner{
        require(nRouter != _dexRouter);
        _dexRouter = nRouter;
        router = IUniswapV2Router02(nRouter);
        address _uniswapV2Pair = IUniswapV2Factory(router.factory())
            .createPair(address(this), router.WETH());
        pair = _uniswapV2Pair;
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor.updatePancakeRouterAddress(nRouter);
    }

    /** Set Address For KittyRaid Distributor */
    function setDistributor(address payable newDistributor) external onlyOwner {
        require(newDistributor != address(distributor), 'Distributor already has this address');
        distributor = KRAIDDistributor(newDistributor);
        emit SwappedDistributor(newDistributor);
    }

    /** Swaps KittyCat and Shiba Token Addresses in case of migration */
    function setTokenAddresses(address nKittyCat, address nShiba) external onlyOwner {
        distributor.setKittyCatAddress(nKittyCat);
        distributor.setShibaAddress(nShiba);
        emit SwappedTokenAddresses(nKittyCat, nShiba);
    }
    
    /** Deletes the entire bag from sender */
    function deleteBag(uint256 nTokens) external returns(bool){
        // make sure you are burning enough tokens
        require(nTokens > 0);
        // if the balance is greater than zero
        require(_balances[msg.sender] >= nTokens, 'user does not own enough tokens');
        // remove tokens from sender
        _balances[msg.sender] = _balances[msg.sender].sub(nTokens, 'cannot have negative tokens');
        // remove tokens from total supply
        _totalSupply = _totalSupply.sub(nTokens, 'total supply cannot be negative');
        // approve Router for the new total supply
        internalApprove();
        // set share in distributor
        distributor.setShare(msg.sender, _balances[msg.sender]);
        // tell blockchain
        emit Transfer(msg.sender, address(0), nTokens);
        return true;
    }

    // Events
    event SwappedDistributor(address newDistributor);
    event SwappedBack(uint256 tokensSwapped, uint256 amountBurned);
    event SwappedTokenAddresses(address newKittyCat, address newShiba);
    event FundDistributors(uint256 reflectionAmount, uint256 marketingAmount);
}