/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: Unlicensed

    pragma solidity ^0.8.10;

library Address {

    function JFContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(JFContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {            
            if (returndata.length > 0) {              
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function tokensamount(address account) external view returns (uint256);
    function transfertokens(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfertokensFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface IDistributor {
    function startDistribution() external;
    function setDistributionParameters(uint256 _minPeriod, uint256 _minDistribution, uint256 _gas) external;
    function setShares(address shareholder, uint256 amount) external;
    function process() external;
    function deposit() payable external;
    function claim(address shareholder) external;
    function getUnpaidRewards(address shareholder) external view returns (uint256);
    function getPaidRewards(address shareholder) external view returns (uint256);
    function getClaimTime(address shareholder) external view returns (uint256);
    function countShareholders() external view returns (uint256);
    function getTotalRewards() external view returns (uint256);
    function getTotalRewarded() external view returns (uint256);
    function migrate(address distributor) external;
}

interface IAntiSnipe {
  function setTokenOwner(address owner, address pair) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external returns (bool checked);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function whoowner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
        function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}



contract testetest is IBEP20, Ownable {
    using Address for address;
    
    address WBNB;
    //Rewards 0x2b3f34e9d4b127797ce6244ea341a83733ddd6e4
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "testetset";
    string constant _symbol = "testcoin";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1_000_000_000 * (10 ** _decimals);
    uint256 _maxBuyTxAmount = (_totalSupply * 3) / 200;
    uint256 _maxSellTxAmount = (_totalSupply * 3) / 200;
    uint256 _maxWalletSize = (_totalSupply * 3) / 100;
    uint256 minimumBalance = 1;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) liquidityCreator;
    mapping (address => bool) iswhitelisted;
    mapping (address => bool) public isBlacklisted;

    uint256 marketingFee = 800;   
    uint256 reflectionfee = 0;
    uint256 liquidityFee = 400;
    uint256 devFee = 300;

    uint256 marketingSellFee = 800;
    uint256 reflectionfeeSell = 0;
    uint256 liquiditySellFee = 400;
    uint256 devFeeSell = 300;

    uint256 totalBuyFee = marketingFee + reflectionfee + liquidityFee + devFee;
    uint256 totalSellFee = marketingSellFee + reflectionfeeSell + liquiditySellFee + devFeeSell;
    uint256 feeDenominator = 10000;

    address public liquidityFeeReceiver = DEAD;
    address payable public marketingFeeReceiver = payable(0x479a7E1E091C48E827170d5f696d30AeAB1572A8);
    address payable public PotFeeReceiver = payable(0xfA4A85E16d119a189A43427B913b1aF9E209A4aD);

    IDEXRouter public router;
    //address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) liquidityPools;

    address public pair;

    uint256 public launchedAt;
    uint256 public launchedTime;
    uint256 public deadBlocks;
    bool startBullRun = false;


    IAntiSnipe public antisnipe;
    bool public WhitelistEnabled = false;
    bool public protectionEnabled = true;
    bool public protectionDisabled = false;
    

    IDistributor public distributor;
    bool public swapEnabled = false;
    bool processEnabled = true;
    uint256 public swapThreshold = _totalSupply / 400;
    uint256 public swapMinimum = _totalSupply / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        router = IDEXRouter(routerAddress);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        liquidityPools[pair] = true;
        _allowances[whoowner()][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        isFeeExempt[whoowner()] = true;
        liquidityCreator[whoowner()] = true;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[whoowner()] = true;
        isTxLimitExempt[routerAddress] = true;
        isDividendExempt[whoowner()] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        _balances[whoowner()] = _totalSupply;

        emit Transfer(address(0), whoowner(), _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return whoowner(); }
    function maxBuyTxTokens() external view returns (uint256) { return _maxBuyTxAmount / (10 ** _decimals); }
    function maxSellTxTokens() external view returns (uint256) { return _maxSellTxAmount / (10 ** _decimals); }
    function maxWalletTokens() external view returns (uint256) { return _maxWalletSize / (10 ** _decimals); }
    function tokensamount(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function EnableWhitelist(bool _value) external onlyOwner{
        WhitelistEnabled = _value;
    }

    function WhitelistAddress(address _address, address _address2, address _address3, address _address4, address _address5, bool _value) external onlyOwner{
        iswhitelisted[_address] = _value;
        iswhitelisted[_address2] = _value;
        iswhitelisted[_address3] = _value;
        iswhitelisted[_address4] = _value;
        iswhitelisted[_address5] = _value;
    }

    // Blacklist/unblacklist an address
    function blacklistAddress(address _address,address _address2, address _address3, address _address4, address _address5, bool _value) external onlyOwner{
        isBlacklisted[_address] = _value;
        isBlacklisted[_address2] = _value;
        isBlacklisted[_address3] = _value;
        isBlacklisted[_address4] = _value;
        isBlacklisted[_address5] = _value;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function setProtectionEnabled(bool _protect) external onlyOwner {
        if (_protect)
            require(!protectionDisabled);
        protectionEnabled = _protect;
    }
    
    function setProtection(address _protection, bool _call) external onlyOwner {
        if (_protection != address(antisnipe)){
            require(!protectionDisabled);
            antisnipe = IAntiSnipe(_protection);
        }
        if (_call)
            antisnipe.setTokenOwner(msg.sender, pair);
    }
    
    function disableProtection() external onlyOwner {
        protectionDisabled = true;
    }
    
    function airdrop(address[] memory addresses, uint256[] memory amounts) external onlyOwner {
        require(addresses.length > 0 && addresses.length == amounts.length, "Length mismatch");
        address from = msg.sender;

        for (uint i = 0; i < addresses.length; i++) {
            if(!liquidityPools[addresses[i]] && !liquidityCreator[addresses[i]]) {
                _transferFrom(from, addresses[i], amounts[i] * (10 ** _decimals));
            }
        }
    }
    
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner
        returns (bool success)
    {
        return IBEP20(tokenAddress).transfertokens(msg.sender, tokens);
    }
    
    function launch(uint256 _deadBlocks) external onlyOwner {
        require(!startBullRun && _deadBlocks < 7);
        deadBlocks = _deadBlocks;
        startBullRun = true;
        launchedAt = block.number;
    }
    
    function startDistribution() external onlyOwner {
        distributor.startDistribution();
    }

    function transfertokens(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transfertokensFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient balance");
        if(!launched() && liquidityPools[recipient]){ require(liquidityCreator[sender], "Liquidity not added yet."); launch(); }
        if(!startBullRun){ require(liquidityCreator[sender] || liquidityCreator[recipient], "Trading not open yet."); }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        checkTxLimit(sender, amount);
        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');
        
        // Check if address is whitelisted
        if(WhitelistEnabled == true){
            require(!iswhitelisted[recipient] && !iswhitelisted[sender], 'Address is not whitelisted');
        }

        if (!liquidityPools[recipient] && recipient != DEAD) {
            if (!isTxLimitExempt[recipient]) {
                checkWalletLimit(recipient, amount);
            }
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender) && shouldTakeFee(recipient) ? takeFee(recipient, sender, amount) : amount;
        
        if(shouldTakeFee(sender) && shouldSwapBack(recipient)){ if (amount > 0) swapBack(amount); }
        
        _balances[recipient] = _balances[recipient] + amountReceived;

        if(!isDividendExempt[sender]){ try distributor.setShares(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShares(recipient, _balances[recipient]) {} catch {} }

        if (processEnabled)
            try distributor.process() {} catch {}

        if(!liquidityPools[sender] && shouldTakeFee(sender) && minimumBalance > 0 && _balances[sender] == 0)
            _balances[sender] = minimumBalance;
     
        if (protectionEnabled && shouldTakeFee(sender))
            antisnipe.onPreTransferCheck(sender, recipient, amount);

            
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        launchedTime = block.timestamp;
        swapEnabled = true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function checkWalletLimit(address recipient, uint256 amount) internal view {
        uint256 walletLimit = _maxWalletSize;
        require(_balances[recipient] + amount <= walletLimit, "Transfer amount exceeds the bag size.");
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(isTxLimitExempt[sender] || amount <= (liquidityPools[sender] ? _maxBuyTxAmount : _maxSellTxAmount), "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + deadBlocks >= block.number){ return feeDenominator - 1; }
        if (selling) return totalSellFee;
        return totalBuyFee;
    }

    function takeFee(address recipient, address sender, uint256 amount) internal returns (uint256) {
        bool selling = liquidityPools[recipient];
        uint256 feeAmount = (amount * getTotalFee(selling)) / feeDenominator;
        
        _balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
    
        return amount - feeAmount;
    }

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return !liquidityPools[msg.sender]
        && !inSwap
        && swapEnabled
        && liquidityPools[recipient]
        && _balances[address(this)] >= swapMinimum;
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 totalFee = totalBuyFee + totalSellFee;
        uint256 amountToSwap = amount < swapThreshold ? amount : swapThreshold;
        if (_balances[address(this)] < amountToSwap) amountToSwap = _balances[address(this)];
        
        uint256 amountToLiquify = ((amountToSwap * (liquidityFee + liquiditySellFee)) / totalFee) / 2;
        amountToSwap -= amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee - ((liquidityFee + liquiditySellFee) / 2);

        uint256 amountBNBLiquidity = (amountBNB * (liquidityFee + liquiditySellFee)) / totalBNBFee / 2;
        uint256 amountBNBReflection = (amountBNB * (reflectionfee + reflectionfeeSell)) / totalBNBFee;
        uint256 amountBNBMarketing = amountBNB - (amountBNBLiquidity + amountBNBReflection);
        uint256 amountBNBPot = amountBNB - (amountBNBLiquidity + amountBNBReflection + amountBNBMarketing);
        
        if (amountBNBPot > 0)
            PotFeeReceiver.transfer(amountBNBPot);

        if (amountBNBMarketing > 0)
            marketingFeeReceiver.transfer(amountBNBMarketing);
        
        if (amountBNBReflection > 0)
            try distributor.deposit{value: amountBNBReflection}() {} catch {}

        if(amountBNBLiquidity > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityFeeReceiver,
                block.timestamp
            );
        }

        emit FundsDistributed(amountBNBLiquidity, amountBNBMarketing, amountBNBReflection);
    }
    
    function updateDistributor(address _distributor, bool migrate) external onlyOwner {
        emit UpdatedSettings('Migrated Distributor', [Log(concatenate('Old Distributor: ',toString(abi.encodePacked(address(distributor)))), 1),Log(concatenate('New Distributor: ',toString(abi.encodePacked(_distributor))), 1), Log('', 0)]);
        if (migrate) distributor.migrate(_distributor);
        distributor = IDistributor(_distributor);
        isFeeExempt[_distributor] = true;
        isTxLimitExempt[_distributor] = true;
        isDividendExempt[_distributor] = true;
    }
    
    function addLiquidityPool(address lp, bool isPool) external onlyOwner {
        require(lp != pair, "Can't alter current liquidity pair");
        liquidityPools[lp] = isPool;
        isDividendExempt[lp] = true;
        emit UpdatedSettings(isPool ? 'Liquidity Pool Enabled' : 'Liquidity Pool Disabled', [Log(toString(abi.encodePacked(lp)), 1), Log('', 0), Log('', 0)]);
    }
    
    function switchRouter(address newRouter) external onlyOwner {
        router = IDEXRouter(newRouter);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        liquidityPools[pair] = true;
        isDividendExempt[pair] = true;
        isTxLimitExempt[newRouter] = true;
        emit UpdatedSettings('Exchange Router Updated', [Log(concatenate('New Router: ',toString(abi.encodePacked(newRouter))), 1),Log(concatenate('New Liquidity Pair: ',toString(abi.encodePacked(pair))), 1), Log('', 0)]);
    }
    
    function setLiquidityCreator(address preSaleAddress) external onlyOwner {
        liquidityCreator[preSaleAddress] = true;
        isTxLimitExempt[preSaleAddress] = true;
        isDividendExempt[preSaleAddress] = true;
        isFeeExempt[preSaleAddress] = true;
        emit UpdatedSettings('Presale Setup', [Log(concatenate('Presale Address: ',toString(abi.encodePacked(preSaleAddress))), 1),Log('', 0), Log('', 0)]);
    }
    
    function updateShares(address shareholder) external onlyOwner {
        if(!isDividendExempt[shareholder]){ distributor.setShares(shareholder, _balances[shareholder]); }
        else distributor.setShares(shareholder, 0);
    }

    function setTxLimit(uint256 buyNumerator, uint256 sellNumerator, uint256 divisor) external onlyOwner {
        require(buyNumerator > 0 && sellNumerator > 0 && divisor > 0 && divisor <= 10000);
        _maxBuyTxAmount = (_totalSupply * buyNumerator) / divisor;
        _maxSellTxAmount = (_totalSupply * sellNumerator) / divisor;
        emit UpdatedSettings('Maximum Transaction Size', [Log('Max Buy Tokens', _maxBuyTxAmount / (10 ** _decimals)), Log('Max Sell Tokens', _maxSellTxAmount / (10 ** _decimals)), Log('', 0)]);
    }
    
    function setMaxWallet(uint256 numerator, uint256 divisor) external onlyOwner() {
        require(numerator > 0 && divisor > 0 && divisor <= 10000);
        _maxWalletSize = (_totalSupply * numerator) / divisor;
        emit UpdatedSettings('Maximum Wallet Size', [Log('Tokens', _maxWalletSize / (10 ** _decimals)), Log('', 0), Log('', 0)]);
    }

    function setIsDividendExempt(address holder, bool exempt) public onlyOwner {
        require(holder != address(this) && !liquidityPools[holder] && holder != whoowner());
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShares(holder, 0);
        }else{
            distributor.setShares(holder, _balances[holder]);
        }
        emit UpdatedSettings(exempt ? 'Dividends Removed' : 'Dividends Enabled', [Log(toString(abi.encodePacked(holder)), 1), Log('', 0), Log('', 0)]);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        if (exempt) setIsDividendExempt(holder, exempt);
        emit UpdatedSettings(exempt ? 'Fees Removed' : 'Fees Enforced', [Log(toString(abi.encodePacked(holder)), 1), Log('', 0), Log('', 0)]);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
        emit UpdatedSettings(exempt ? 'Transaction Limit Removed' : 'Transaction Limit Enforced', [Log(toString(abi.encodePacked(holder)), 1), Log('', 0), Log('', 0)]);
    }

    function setFees(uint256 _reflectionfee, uint256 _reflectionfeeSell, uint256 _liquidityFee, uint256 _liquiditySellFee, uint256 _marketingFee, uint256 _marketingSellFee,uint256 _devfee, uint256 _devfeesell, uint256 _feeDenominator) external onlyOwner {
        reflectionfee = _reflectionfee;
        reflectionfeeSell = _reflectionfeeSell;
        liquidityFee = _liquidityFee;
        liquiditySellFee = _liquiditySellFee;
        marketingFee = _marketingFee;
        marketingSellFee = _marketingSellFee;
        devFee = _devfee;
        devFeeSell = _devfeesell;

        totalBuyFee = reflectionfee + liquidityFee + marketingFee + devFee;
        totalSellFee = reflectionfeeSell + _liquiditySellFee + _marketingSellFee + devFeeSell;
        feeDenominator = _feeDenominator;
        require(totalBuyFee + totalSellFee < feeDenominator / 2);

        emit UpdatedSettings('Fees', [Log('Total Buy Fee Percent', totalBuyFee * 100 / feeDenominator), Log('Total Sell Fee Percent', totalSellFee * 100 / feeDenominator), Log('Distribution Percent', (_reflectionfee + _reflectionfeeSell) * 100 / feeDenominator)]);
    }

    function setMinimumBalance(uint256 _minimum) external onlyOwner {
        require(_minimum < 100);
        minimumBalance = _minimum;
    }

    function setFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        marketingFeeReceiver = payable(_marketingFeeReceiver);

        emit UpdatedSettings('Fee Receivers', [Log(concatenate('Marketing Receiver: ',toString(abi.encodePacked(_marketingFeeReceiver))), 1), Log('', 0), Log('', 0)]);
    }

    function setSwapBackSettings(bool _enabled, bool _processEnabled, uint256 _denominator, uint256 _swapMinimum) external onlyOwner {
        require(_denominator > 0);
        swapEnabled = _enabled;
        processEnabled = _processEnabled;
        swapThreshold = _totalSupply / _denominator;
        swapMinimum = _swapMinimum * (10 ** _decimals);
        emit UpdatedSettings('Swap Settings', [Log('Enabled', _enabled ? 1 : 0),Log('Swap Maximum', swapThreshold), Log('Auto-processing', _processEnabled ? 1 : 0)]);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 gas) external onlyOwner {
        require(gas < 750000);
        require(_minPeriod <= 24 hours);
        distributor.setDistributionParameters(_minPeriod, _minDistribution, gas);

        emit UpdatedSettings('DistributionCriteria', [Log('MaxGas', gas),Log('PayPeriod', _minPeriod), Log('MinimumDistribution', _minDistribution)]);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (tokensamount(DEAD) + tokensamount(ZERO));
    }
    
    function getPoolStatistics() external view returns (uint256 totalAmount, uint256 totalClaimed, uint256 holders) {
        totalAmount = distributor.getTotalRewards();
        totalClaimed = distributor.getTotalRewarded();
        holders = distributor.countShareholders();
    }
    
    function getWalletStatistics(address wallet) external view returns (uint256 pending, uint256 claimed) {
	    pending = distributor.getUnpaidRewards(wallet);
	    claimed = distributor.getPaidRewards(wallet);
	}

	function claimDividends() external {
	    distributor.claim(msg.sender);
        if (processEnabled)
	        try distributor.process() {} catch {}
	}
	
	function toString(bytes memory data) internal pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
    
    function concatenate(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

	struct Log {
	    string name;
	    uint256 value;
	}

    event FundsDistributed(uint256 liquidityBNB, uint256 marketingBNB, uint256 reflectionBNB);
    event UpdatedSettings(string name, Log[3] values);
}