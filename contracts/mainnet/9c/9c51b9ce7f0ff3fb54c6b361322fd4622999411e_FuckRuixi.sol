/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
                                                                            
Telegram: https://t.me/fuckruixiwang                                                                       

/**
 * SAFEMATH LIBRARY
 */
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

}

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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    // ERC-20 Token that controls the contract
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // All set on contructor
    IDEXRouter router;
    IBEP20 immutable BUSD;
    address immutable WBNB;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;

    // How often dividents are paid
    uint256 public minPeriod = 1 hours;
    // Minimum distribution that the user must have in order to recieve the rewards.
    uint256 public minDistribution = 1 * (10 ** 18);
    // Current index that is being processed
    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address _WBNB, address _rewardToken) {
        router = IDEXRouter(_router);
        _token = msg.sender;
        WBNB = _WBNB;
        BUSD = IBEP20(_rewardToken);
    }

    // Accountability mechanism Triggered by token's _transferFrom function.
    // Both sender and reciever balances are updated with the users token balance after the swap.
    // If the shareholder has no shares add it otherwise remove it.
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        } else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    // Deposits BUSD into the contract by swapping incomming BNB.
    // Triggered by token's swapBack function.
    // Increases the totalDividents and the amount of dividents per share.
    function deposit() external payable override onlyToken {
        if(msg.value == 0) return;
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    // Ditributes rewards for all share holders, called by _transferFrom().
    // It will do a linear loop and ditribute for as many holders until the 
    // distributorGas runs out ot all the shareHolders are already processed.
    function process(uint256 gas) external override onlyToken {
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

    // Distribute rewards if the last claim time + min waiting time is less than now
    // And the accumulated earnings are more than the minDistribution amount
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    // Change distribution settings
    // Note: If minPeriod or minDistribution is too large shouldDistribute() may never return true.
    // Users can still claim their dividents using claimDividend()
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    // Calculate earnings and distributes them to the shareholder
    // Resets last claim and updates totalRealised & totalExcluded
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            BUSD.transfer(shareholder, amount);
        }
    }

    // For users to claim their rewards manually instead 
    // of waiting for the process loop to reach their address.
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    // Self-explanatory

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


contract FuckRuixi is IBEP20, Ownable {
    using SafeMath for uint256;

	string constant _name = 'Fuck Ruixi Wang';   // Name
	string constant _symbol = 'FuckRW';    // Symbol
	uint8 constant _decimals = 18;         // Decimals

    uint256 private constant _totalSupply = 100_000_000 * (10 ** _decimals); 
    uint256 public  constant _maxWalletLimit = 1_000_000 * (10 ** _decimals); 

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isMaxWalletExempt;


    // Buy Fees
    uint256 constant reflectionFeeBuy = 300;
    uint256 constant liquidityFeeBuy  = 300;
    uint256 constant marketingFeeBuy  = 300;
    uint256 constant totalFeeBuy      = 900;

    // Sell Fees
    uint256 constant reflectionFeeSell = 300;
    uint256 constant liquidityFeeSell  = 300;
    uint256 constant marketingFeeSell  = 300;
    uint256 constant totalFeeSell      = 900;

    // Contract Use
    uint256 constant private feeDenominator = 10000;

    // External wallets
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    // Router and LP pair
    address public pair;
    IDEXRouter public router;

    // ERC20s
	// BUSD mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
	// BUSD testnet 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public WBNB;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    // BUSD distributor
    DividendDistributor distributor;
    address public distributorAddress;
    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 2000; 

    // Handle Swap state
    bool inSwap;

    modifier swapping() { 
        inSwap = true; 
        _; 
        inSwap = false; 
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
    event SetDistributionCriteria(uint256 indexed _minPeriod, uint256 indexed _minDistribution);
    event SetSwapBackSettings(bool indexed swapEnabled, uint256 indexed swapThreshold);
    event SetDistributorSettings(uint256 indexed gas);

    // Pancake Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    // Pancake Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor ( address _dexRouter ){

        // set up router and create pair WBNB -> Token
        router = IDEXRouter(_dexRouter);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        // Allow the router to use all the tokens
        _allowances[address(this)][address(router)] = _totalSupply;

        // Deploy the BUSD distributor
        distributor = new DividendDistributor(_dexRouter, WBNB, BUSD);
        distributorAddress = address(distributor);

        // Set up external wallets
        autoLiquidityReceiver = 0x0000000000000000000000000000000000000000;
        marketingFeeReceiver = 0xfE62Ad96Bd34627E5d9CF0F044880d096Ea8d393;

        isFeeExempt[msg.sender] = true;
        isMaxWalletExempt[pair] = true;
        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[_dexRouter] = true;
        

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;


        // Required allowances
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);

        // Mint the tokens
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        // Prevent circular liquidity errors
        if(inSwap)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }

        // Optimized to deposit to rewards, liquify, and pay fees.
        // See shouldSwapBack() for trigger conditions.
        if(shouldSwapBack())
        { 
            swapBack(); 
        }

        // Substract the amount of tokens from the sender.
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        // Calculate amount after tax if applicable
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;

        // Simulate tx and revert if balance goes over wallet limit.
        checkWalletLimit(recipient, amount);

        // Add the calulated amount to the recipient
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Update shares values for both sender, and recipient if applicable
        if(!isDividendExempt[sender]){ 
            try distributor.setShare(sender, _balances[sender]) {} catch {} 
        }

        if(!isDividendExempt[recipient]){ 
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        // Distribute rewards to shareholders until gas runs out.
        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    // Transfer with no fees only called if the contract is in swap or there is a token transfer between wallets.
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Burn amount from msg.sender
    function burn(uint256 amount) internal returns (bool) {
        _balances[msg.sender] = _balances[msg.sender].sub(amount, "Insufficient Balance");
        _balances[DEAD] = _balances[DEAD].add(amount);
        emit Transfer(msg.sender, DEAD, amount);
        return true;
    }

    // Simulate recipient after the swap, revert tx if balace goes over max wallet limit
    function checkWalletLimit(address recipient, uint256 amount) internal view {
        require(_balances[recipient] + amount <= _maxWalletLimit || isMaxWalletExempt[recipient], "Max wallet Limit Exceeded");
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !(isFeeExempt[sender] || isFeeExempt[recipient]);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount;
    
        if(sender == pair){
            uint256 buyFees = reflectionFeeBuy.add(liquidityFeeBuy).add(marketingFeeBuy);
            feeAmount = amount.mul(buyFees).div(feeDenominator);
        } else if (recipient== pair){
            uint256 sellFees = reflectionFeeSell.add(liquidityFeeSell).add(marketingFeeSell);
            feeAmount = amount.mul(sellFees).div(feeDenominator);
        } else {
            // No fee for transfer between wallets
            // Transfer between wallets occurs when not the sender nor the receiver are the LP contract.
            return amount;
        }

        // Add fees to contract balance and return tranfer amount
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

    // Deposits BNB to the distributor contract, Auto liquidity addition & Sends BNB to wallet
    // Optimized to make only one TOKEN -> WBNB swap.
    function swapBack() internal swapping {

        // Calculate amount needed for liquidity and amount to swap
        uint256 amountToLiquify = swapThreshold.mul(liquidityFeeSell).div(totalFeeSell).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

		// swap tokens for BNB
		// generate the uniswap pair path of token -> BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        // capture the vault contract current BUSD balance.
		// this is so that we can capture exactly the amount of BUSD that we swapped.
        uint256 balanceBefore = address(this).balance;

        // make the swap and send the BNB to this contract
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        // how much BNB the contract gained.
        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        // Calculate the BNB needed for Rewards, Liquidity, Marketing
        uint256 totalBNBFee = totalFeeSell.sub(liquidityFeeSell.div(2));
        uint256 amountBNBMarketing = amountBNB.mul(marketingFeeSell).div(totalBNBFee);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFeeSell).div(totalBNBFee);
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFeeSell).div(totalBNBFee).div(2);

        // Deposit BNB into distributor which is converted into BUSD
        try distributor.deposit{value: amountBNBReflection}() {} catch {}


        // Send Marketing Value to marketingFeeReceiver.
        if(amountBNBMarketing > 0){
            payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        }

        // Add the liquidity
        if(amountBNBLiquidity > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        emit AutoLiquify(amountBNBLiquidity, amountToLiquify);

    }

    // Self Explanatory
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * 10 ** 18;
        emit SetSwapBackSettings(swapEnabled, swapThreshold);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit SetDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
        emit SetDistributorSettings(distributorGas);
    }

    function setWalletExempt(address user, bool status) external onlyOwner {
        isMaxWalletExempt[user] = status;
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
}