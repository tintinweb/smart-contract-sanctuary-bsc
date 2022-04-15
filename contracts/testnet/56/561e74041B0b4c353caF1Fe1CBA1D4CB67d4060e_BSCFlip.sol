/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

/**
 /$$$$$$$   /$$$$$$   /$$$$$$        /$$$$$$$$ /$$       /$$$$$$ /$$$$$$$ 
| $$__  $$ /$$__  $$ /$$__  $$      | $$_____/| $$      |_  $$_/| $$__  $$
| $$  \ $$| $$  \__/| $$  \__/      | $$      | $$        | $$  | $$  \ $$
| $$$$$$$ |  $$$$$$ | $$            | $$$$$   | $$        | $$  | $$$$$$$/
| $$__  $$ \____  $$| $$            | $$__/   | $$        | $$  | $$____/ 
| $$  \ $$ /$$  \ $$| $$    $$      | $$      | $$        | $$  | $$      
| $$$$$$$/|  $$$$$$/|  $$$$$$/      | $$      | $$$$$$$$ /$$$$$$| $$      
|_______/  \______/  \______/       |__/      |________/|______/|__/      

 */

pragma solidity ^0.8.0;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

contract DividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // IERC20 BUSDReward = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Mainnet
    // address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet
    IERC20 BUSDReward = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); // Testnet
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet

    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 8);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = IDEXRouter(_router);
        _token = msg.sender;
    }

    function setNewRouter(address newRouter) external onlyToken {
        require(newRouter != address(router));
        router = IDEXRouter(newRouter);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable onlyToken {
        uint256 balanceBefore = BUSDReward.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSDReward);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSDReward.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSDReward.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Tradable is IERC20, Ownable {
    using SafeMath for uint256;

    struct TokenDistribution {
        uint256 totalSupply;
        uint8 decimals;
        uint256 maxBalance;
        uint256 maxTx;
    }

    uint256 public _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    uint256 public _maxBalance;
    uint256 public _maxTx;
    //
    IDEXRouter public router;
    address public pair;
    //
    DividendDistributor public distributor;
    uint256 distributorGas = 500000;
    //
    mapping (address => uint256) public _balances;
    //
    mapping (address => mapping (address => uint256)) public _allowances;
    //
    mapping (address => bool) public _isDividendExempt;
    //
    mapping (address => bool) public _isExcludedFromMaxBalance;
    //
    mapping (address => bool) public _isExcludedFromMaxTx;

    constructor(string memory tokenSymbol, string memory tokenName, TokenDistribution memory tokenDistribution) {
        _totalSupply = tokenDistribution.totalSupply;
        _decimals = tokenDistribution.decimals;
        _symbol = tokenSymbol;
        _name = tokenName;
        _maxBalance = tokenDistribution.maxBalance;
        _maxTx = tokenDistribution.maxTx;

        // router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet 
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this)); // Create a uniswap pair for this new token

        distributor = new DividendDistributor(address(router));

        _isDividendExempt[pair] = true;
        _isDividendExempt[address(this)] = true;

        _isExcludedFromMaxBalance[owner()] = true;
        _isExcludedFromMaxBalance[address(this)] = true;
        _isExcludedFromMaxBalance[pair] = true;

        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
    }

    // To recieve BNB from anyone, including the router when swapping
    receive() external payable {}

    function withdrawBNB(uint256 amount) external onlyOwner {
        (bool sent, bytes memory data) = _msgSender().call{value: amount}("");
        require(sent, "Failed to send BNB");
    }

    // If you need to withdraw tokens that have been sent to the contract
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }

    // If PancakeSwap sets a new iteration on their router and we need to migrate where LP
    // goes, change it here!
    function setNewPair(address newPairAddress) external onlyOwner {
        require(newPairAddress != pair);
        pair = newPairAddress;
        _isExcludedFromMaxBalance[pair] = true;
        _isDividendExempt[pair] = true;
    }

    // If PancakeSwap sets a new iteration on their router, change it here!
    function setNewRouter(address newAddress) external onlyOwner {
        require(newAddress != address(router));
        router = IDEXRouter(newAddress);
        distributor.setNewRouter(newAddress);
    }

    function setMaxBalancePercentage(uint256 newMaxBalancePercentage) external onlyOwner() {
        uint256 newMaxBalance = _totalSupply.mul(newMaxBalancePercentage).div(100);

        require(newMaxBalance != _maxBalance, "Cannot set new max balance to the same value as current max balance");
        require(newMaxBalance >= _totalSupply.mul(2).div(100), "Cannot set max balance lower than 2 percent");

        _maxBalance = newMaxBalance;
    }

    // Set the max transaction percentage in increments of 0.1%.
    function setMaxTxPercentage(uint256 newMaxTxPercentage) external onlyOwner {
        uint256 newMaxTx = _totalSupply.mul(newMaxTxPercentage).div(1000);

        require(newMaxTx != _maxTx, "Cannot set new max transaction to the same value as current max transaction");
        require(newMaxTx >= _totalSupply.mul(5).div(1000), "Cannot set max transaction lower than 0.5 percent");

        _maxTx = newMaxTx;
    }

    function excludeFromMaxBalance(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxBalance[account] = exempt;
    }

    function excludeFromMaxTx(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxTx[account] = exempt;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this));
        _isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 900000);
        distributorGas = gas;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view returns (uint8) { return _decimals; }
    function symbol() external view returns (string memory) { return _symbol; }
    function name() external view returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) external view override returns (uint256) { return _allowances[owner][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address holder, address spender, uint256 amount) internal {
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!(_isExcludedFromMaxTx[from] || _isExcludedFromMaxTx[to])) {
            require(amount < _maxTx, "Transfer amount exceeds limit");
        }

        if(
            from != owner() &&              // Not from Owner
            to != owner() &&                // Not to Owner
            !_isExcludedFromMaxBalance[to]  // is excludedFromMaxBalance
        ) {
            require(balanceOf(to).add(amount) <= _maxBalance, "Tx would cause recipient to exceed max balance");
        }

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        // Dividend tracker
        if(!_isDividendExempt[from]) {
            try distributor.setShare(from, balanceOf(from)) {} catch {}
        }

        if(!_isDividendExempt[to]) {
            try distributor.setShare(to, balanceOf(to)) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(from, to, amount);
    }
}

abstract contract Taxable is Ownable, Tradable {
    using SafeMath for uint256;

    struct Taxes {
        uint8 devFee;
        uint8 rewardsFee;
        uint8 marketingFee;
        uint8 teamFee;
        uint8 liqFee;
    }

    uint8 constant BUYTX = 1;
    uint8 constant SELLTX = 2;
    //
    address payable public _devAddress;
    address payable public _marketingAddress;
    address payable public _teamAddress;
    //
    uint256 public _liquifyThreshhold;
    bool inSwapAndLiquify;
    //
    uint8 public _maxFees;
    uint8 public _maxDevFee;
    //
    Taxes public _buyTaxes;
    uint8 public _totalBuyTaxes;
    Taxes public _sellTaxes;
    uint8 public _totalSellTaxes;
    //
    uint256 private _devTokensCollected;
    uint256 private _rewardsTokensCollected;
    uint256 private _marketingTokensCollected;
    uint256 private _teamTokensCollected;
    uint256 private _liqTokensCollected;
    //
    mapping (address => bool) private _isExcludedFromFees;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(string memory symbol, 
                string memory name, 
                TokenDistribution memory tokenDistribution,
                address payable devAddress,
                address payable marketingAddress,
                address payable teamAddress,
                Taxes memory buyTaxes,
                Taxes memory sellTaxes,
                uint8 maxFees, 
                uint8 maxDevFee, 
                uint256 liquifyThreshhold)
    Tradable(symbol, name, tokenDistribution) {
        _devAddress = devAddress;
        _marketingAddress = marketingAddress;
        _teamAddress = teamAddress;
        _buyTaxes = buyTaxes;
        _sellTaxes = sellTaxes;
        _totalBuyTaxes = buyTaxes.devFee + buyTaxes.rewardsFee + buyTaxes.marketingFee + buyTaxes.teamFee + buyTaxes.liqFee;
        _totalSellTaxes = sellTaxes.devFee + sellTaxes.rewardsFee + sellTaxes.marketingFee + sellTaxes.teamFee + sellTaxes.liqFee;
        _maxFees = maxFees;
        _maxDevFee = maxDevFee;
        _liquifyThreshhold = liquifyThreshhold;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingAddress] = true;
        _isExcludedFromFees[devAddress] = true;
        _isExcludedFromFees[teamAddress] = true;
    }

    function setReceiverAddresses(address payable newMarketingAddress, address payable newDevAddress, address payable newTeamAddress) external onlyOwner() {
        require(newMarketingAddress != _marketingAddress);
        require(newDevAddress != _devAddress);
        require(newTeamAddress != _teamAddress);

        _marketingAddress = newMarketingAddress;
        _devAddress = newDevAddress;
        _teamAddress = newTeamAddress;
    }

    function includeInFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = false;
    }

    function excludeFromFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = true;
    }

    function setBuyFees(uint8 newDevBuyFee, uint8 newRewardsBuyFee, uint8 newMarketingBuyFee, uint8 newTeamBuyFee, uint8 newLiqBuyFee) external onlyOwner {
        uint8 newTotalBuyFees = newDevBuyFee + newRewardsBuyFee + newMarketingBuyFee + newTeamBuyFee + newLiqBuyFee;
        require(!inSwapAndLiquify, "inSwapAndLiquify");
        require(newDevBuyFee <= _maxDevFee, "Cannot set dev fee higher than max");
        require(newTotalBuyFees <= _maxFees, "Cannot set total buy fees higher than max");

        _buyTaxes = Taxes({ devFee: newDevBuyFee, rewardsFee: newRewardsBuyFee, marketingFee: newMarketingBuyFee,
            teamFee: newTeamBuyFee, liqFee: newLiqBuyFee });
        _totalBuyTaxes = newTotalBuyFees;
    }

    function setSellFees(uint8 newDevSellFee, uint8 newRewardsSellFee, uint8 newMarketingSellFee, uint8 newTeamSellFee, uint8 newLiqSellFee) external onlyOwner {
        uint8 newTotalSellFees = newDevSellFee + newRewardsSellFee + newMarketingSellFee + newTeamSellFee + newLiqSellFee;
        require(!inSwapAndLiquify, "inSwapAndLiquify");
        require(newDevSellFee <= _maxDevFee, "Cannot set dev fee higher than max");
        require(newTotalSellFees <= _maxFees, "Cannot set total sell fees higher than max");

        _sellTaxes = Taxes({ devFee: newDevSellFee, rewardsFee: newRewardsSellFee, marketingFee: newMarketingSellFee,
            teamFee: newTeamSellFee, liqFee: newLiqSellFee });
        _totalSellTaxes = newTotalSellFees;
    }

    function setLiquifyThreshhold(uint256 newLiquifyThreshhold) external onlyOwner {
        _liquifyThreshhold = newLiquifyThreshhold;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transferWithTaxes(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferWithTaxes(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferWithTaxes(address from, address to, uint256 amount) private {
        // Sell tokens for funding
        if(
            !inSwapAndLiquify &&                                // Swap is not locked
            balanceOf(address(this)) >= _liquifyThreshhold &&   // liquifyThreshhold is reached
            from != pair                                        // Not from liq pool (can't sell during a buy)
        ) {
            swapCollectedFeesForFunding();
        }

        // Send fees to contract if necessary
        uint8 txType = 0;
        if (from == pair) txType = BUYTX;
        if (to == pair) txType = SELLTX;
        if(
            txType != 0 &&
            !(_isExcludedFromFees[from] || _isExcludedFromFees[to])
            && ((txType == BUYTX && _totalBuyTaxes > 0)
            || (txType == SELLTX && _totalSellTaxes > 0))
        ) {
            uint256 feesToContract = calculateTotalFees(amount, txType);
            
            if (feesToContract > 0) {
                amount = amount.sub(feesToContract); 
                _transfer(from, address(this), feesToContract);
            }
        }

        _transfer(from, to, amount);
    }

    function calculateTotalFees(uint256 amount, uint8 txType) private returns (uint256) {
        uint256 devTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.devFee).div(100) : amount.mul(_sellTaxes.devFee).div(100);
        uint256 rewardsTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.rewardsFee).div(100) : amount.mul(_sellTaxes.rewardsFee).div(100);
        uint256 marketingTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.marketingFee).div(100) : amount.mul(_sellTaxes.marketingFee).div(100);
        uint256 teamTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.teamFee).div(100) : amount.mul(_sellTaxes.teamFee).div(100);
        uint256 liqTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.liqFee).div(100) : amount.mul(_sellTaxes.liqFee).div(100);

        _devTokensCollected = _devTokensCollected.add(devTokens);
        _rewardsTokensCollected = _rewardsTokensCollected.add(rewardsTokens);
        _marketingTokensCollected = _marketingTokensCollected.add(marketingTokens);
        _teamTokensCollected = _teamTokensCollected.add(teamTokens);
        _liqTokensCollected = _liqTokensCollected.add(liqTokens);

        return devTokens.add(rewardsTokens).add(marketingTokens).add(teamTokens).add(liqTokens);
    }

    function swapCollectedFeesForFunding() private lockTheSwap {
        uint256 totalCollected = _devTokensCollected.add(_marketingTokensCollected).add(_liqTokensCollected)
            .add(_teamTokensCollected).add(_liqTokensCollected);
        require(totalCollected > 0, "No tokens available to swap");

        uint256 initialFunds = address(this).balance;

        uint256 halfLiq = _liqTokensCollected.div(2);
        uint256 otherHalfLiq = _liqTokensCollected.sub(halfLiq);

        uint256 totalAmountToSwap = _devTokensCollected.add(_rewardsTokensCollected).add(_marketingTokensCollected)
            .add(_teamTokensCollected).add(halfLiq);

        swapTokensForNative(totalAmountToSwap);

        uint256 newFunds = address(this).balance.sub(initialFunds);

        uint256 liqFunds = newFunds.mul(halfLiq).div(totalAmountToSwap);
        uint256 marketingFunds = newFunds.mul(_marketingTokensCollected).div(totalAmountToSwap);
        uint256 rewardsFunds = newFunds.mul(_rewardsTokensCollected).div(totalAmountToSwap);
        uint256 teamFunds = newFunds.mul(_teamTokensCollected).div(totalAmountToSwap);
        uint256 devFunds = newFunds.sub(liqFunds).sub(marketingFunds).sub(rewardsFunds).sub(teamFunds);

        addLiquidity(otherHalfLiq, liqFunds);
        (bool sent, bytes memory data) = _devAddress.call{value: devFunds}("");
        (bool sent1, bytes memory data1) = _marketingAddress.call{value: marketingFunds}("");
        (bool sent2, bytes memory data2) = _teamAddress.call{value: teamFunds}("");
        require(sent && sent1 && sent2, "Failed to send BNB");
        try distributor.deposit{value: rewardsFunds}() {} catch {}

        _devTokensCollected = 0;
        _marketingTokensCollected = 0;
        _liqTokensCollected = 0;
        _rewardsTokensCollected = 0;
        _teamTokensCollected = 0;
    }

    function swapTokensForNative(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(0),
            block.timestamp
        );
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract BSCFlip is Context, Ownable, Taxable {
	using SafeMath for uint256;
	using Address for address;

    string private _Bname = "BSC Flip";
    string private _Bsymbol = "BSCF";
    // 9 Decimals
    uint8 private _Bdecimals = 18;
    // 10M Supply
    uint256 private _BtotalSupply = 10**7 * 10**_Bdecimals;
    // 2% Max Wallet
    uint256 private _BmaxBalance = _BtotalSupply.mul(2).div(100);
    // 0.5% Max Transaction
    uint256 private _BmaxTx = _BtotalSupply.mul(5).div(1000);
    // 12% Max Fees
    uint8 private _BmaxFees = 12;
    // 2% Max Dev Fee
    uint8 private _BmaxDevFee = 3;
    // Contract sell at 30k tokens
    uint256 private _BliquifyThreshhold = 3 * 10**4 * 10**_Bdecimals;
    TokenDistribution private _BtokenDistribution = 
        TokenDistribution({ totalSupply: _BtotalSupply, decimals: _Bdecimals, maxBalance: _BmaxBalance, maxTx: _BmaxTx });

    address payable _BdevAddress = payable(address(0x2c3DE508c770a44F2902259f1800aA798f25ee06));
    address payable _BmarketingAddress = payable(address(0x7C29E5F9F7DB90E830bf42EEAc36ffBaE30A67cB));
    address payable _BteamAddress = payable(address(0x3252950D0ad561BF2E3689BA43C863456574ec6D));

    // Buy and sell fees will start at 99% to prevent bots/snipers at launch, 
    // but will not be allowed to be set this high ever again.
    constructor () 
    Taxable(_Bsymbol, _Bname, _BtokenDistribution, _BdevAddress, _BmarketingAddress, _BteamAddress,
            Taxes({ devFee: 1, rewardsFee: 2, marketingFee: 32, teamFee: 3, liqFee: 61 }), 
            Taxes({ devFee: 1, rewardsFee: 2, marketingFee: 32, teamFee: 3, liqFee: 61 }), 
            _BmaxFees, _BmaxDevFee, _BliquifyThreshhold) {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
}