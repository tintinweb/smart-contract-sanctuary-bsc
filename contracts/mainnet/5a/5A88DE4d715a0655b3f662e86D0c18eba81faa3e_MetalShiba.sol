/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/**
   All newly created LP is sent to the contract address and not into any wallet controlled by anyone. 
   These LPs are only withdrawable from the contract after a specified TimeLock (set at 180 days) has passed. 

    Telegram:         t.me/MetalShibaInu
    Website:          metalshiba.com
    Contract Creator: t.me/Frankfourier


    ███╗░░░███╗███████╗████████╗░██████╗░██╗░░░░░░░███████╗░██╗░░██╗██╗███████╗░░██████╗
    ████╗░████║██╔════╝╚══██╔══╝██╔═══██╗██║░░░░░░███╔════╝░██║░░██║██║██╔═══██╗██╔══ ██╗
    ██╔████╔██║█████╗░░░░░██║░░░████████║██║░░░░░░░███████╗░███████║██║████████╝████████║
    ██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔═══██║██║░░░░░░░░░░░░███╗██╔══██║██║██╔═══██╗██╔══ ██║
    ██║░╚═╝░██║███████╗░░░██║░░░██║░░░██║███████╗░████████╔╝██║░░██║██║████████║██║░░░██║
    ╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░░╚═╝╚══════╝░╚═══════╝░╚═╝░░╚═╝╚═╝╚═══════╝╚═╝░░░╚═╝
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

/**
 * BEP20 standard interface.
 */
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

abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

abstract contract TimeLock is Ownable {
    uint256 private _lockTime;
    bool public locked;

    /**
     * @dev Throws if called when Timelock is not expired.
     */
    modifier TimeLockExpired() {
        if(locked)
        require(block.timestamp > _lockTime , "Function is locked");
        _;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the function for owner for the amount of time provided
    function lock(uint256 time) internal virtual {
        _lockTime = block.timestamp + time;
        locked = true;
    }
    
    //Unlocks the function for owner when _lockTime is exceeds
    function unlock() external virtual onlyOwner {
        require(block.timestamp > _lockTime , "Function is locked");
        locked = false;
    }
}

interface PCSFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PCSv2Router {
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

interface PCSv2Pair {
    function sync() external;
}

contract MetalShiba is IBEP20, Ownable, TimeLock {

    address constant private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private ZERO = 0x0000000000000000000000000000000000000000;
    address public marketingFeeReceiver1 = 0x88a0a39f4ed5322fa5Ede28d24602e241DEb26F4;
    address public marketingFeeReceiver2 = 0xE4d073908fe4350d9004a01EEe66b32F74D5e4E4;
    address public teamFeeReceiver       = 0x2bB4E1D59770D48E32785d04043CE5646Cd85f50;
    address public pair;

    string constant private _name = "Metal Shiba";
    string constant private _symbol = "METAL";
    string constant public ContractCreator = "@FrankFourier";

    uint8 constant  private _decimals = 18;

    uint256 private _totalSupply =  21 * 10**9 * 10**_decimals;
    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _maxWalletToken = _totalSupply / 100;

    mapping (address => uint256)                      private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool)                         private isFeeExempt;
    mapping (address => bool)                         private isTxLimitExempt;
    mapping (address => bool)                         private isWalletLimitExempt;
    // store addresses that are automatic market maker pairs
    mapping (address => bool)                         public  automatedMarketMakerPairs;
    //Anti Dump
    mapping (address => uint256)                      private _lastSell;
    mapping (address => bool)                         public  isSniper;
    
    uint256 private liquidityFee = 2;
    uint256 private marketingFee = 4;
    uint256 private teamFee = 1;
    uint256 private referralFee = 1;
    uint256 public totalFee = liquidityFee + marketingFee + teamFee + referralFee;
    uint256 constant public feeDenominator   = 100;
    uint256 public sellMultiplier = 125;
    uint256 public buyMultiplier = 100;
    uint256 public transferMultiplier = 100;
    uint256 public deadBlocks_highslippage = 2;
    uint256 public deadBlocks_antisniper = 4;
    uint256 public launchedAt = 0;
    uint256 public gasPriceLimit = 20 gwei;
    uint256 public targetLiquidity = 100;
    uint256 public targetLiquidityDenominator = 100;

    PCSv2Router public router;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    // LP Burn
    uint256 public percentForLPBurn = 25; // 25 = .25%
    uint256 public lpBurnFrequency = 7200 seconds;
    uint256 public lastLpBurnTime;
    uint256 public manualBurnFrequency = 240 minutes;
    uint256 public lastManualLpBurnTime;
    uint256 public swapThreshold = _totalSupply / 1000;
    uint256 public swapTransactionThreshold = _totalSupply * 5 / 10000;
    uint256 public coolDownTime = 60 seconds;
    uint256 public currentIndex;

    bool    public launched;
    bool    public gasLimitActive = false;
    bool    public swapEnabled = true;
    bool    public swapandliquifyEnabled = true;
    bool    private inSwap;
    bool    public lpBurnEnabled = true;
    bool    public coolDownEnabled = false;
    bool    private is_farmable;
    bool    public Resale_open;
    bool    public AntibotEnabled;

    //Referral system
    mapping (address => address) private referral;
    mapping (address => address) public referred_by;
    mapping (address => bool)    private is_referred;
    mapping (address => bool)    public PointStaked;
    mapping (address => bool)    public isBuyFeeExempt;
    mapping (address => bool)    public farm_active;
    mapping (address => bool)    public is_farmer;
    mapping (address => uint256) public points_balance;
    mapping (address => uint256) public deposit_time;
    mapping (address => uint256) private OGdeposit_time;
    mapping (address => uint256) public pendingRewards;
    //Resale
    mapping (address => uint256) public pendingAmount;
    mapping (address => uint256) public BuyTime;

    address[] public farmers;

    uint256 public redeemPeriod = 1 days;
    uint256 public discount = 10;
    uint256 private soldtokens;
    uint256 public _pendingRewards;
    uint256 private _totalDistributed;  
    uint256 public total_points_balance;
    uint256 private ReferRewards;
    uint256 private constant _precision = 1e36;
    uint256 public ReferTreshold = _totalSupply / 1000;
    uint256 public updatesGas = 500000;
    uint256 public lastsync;

    constructor () Ownable(msg.sender) {
        router = PCSv2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        _setAutomatedMarketMakerPair(address(pair), true);

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[ZERO] = true;

        is_farmable = false;

        marketingFeeReceiver1 = msg.sender;
        marketingFeeReceiver2 = msg.sender;
        teamFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    //to recieve BNB
    receive() external payable {}

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 100);
        require(amount <= _totalSupply);
        _maxWalletToken = amount;
    }

    function setMaxTx(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000);
        require(amount <= _totalSupply);
        _maxTxAmount = amount;
    }

    function setAutomatedMarketMakerPair(address _pair, bool value) public onlyOwner {
        require(_pair != pair, "The pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(_pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address _pair, bool value) internal {
        automatedMarketMakerPairs[_pair] = value;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isSniper[sender],"Snipers can't trade");
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner && recipient != owner && sender != address(this) && !isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(launched,"Trading not open yet");
            if(gasLimitActive)
                require(tx.gasprice <= gasPriceLimit,"Gas price exceeds limit");   
            if(launchedAt + deadBlocks_antisniper > block.number)
                require(!automatedMarketMakerPairs[recipient], "Sells not allowed for dead blocks");
            if(coolDownEnabled && automatedMarketMakerPairs[recipient]){
                require(block.timestamp - _lastSell[sender] >= coolDownTime, "Cooldown enabled");
                _lastSell[sender] = block.timestamp;
            }
        }

        if (sender != owner && recipient != owner && recipient != address(this) && sender != address(this) && recipient != address(DEAD) && recipient != address(ZERO) && !isFeeExempt[sender]){
            require(amount <= _maxTxAmount || isTxLimitExempt[sender],"TX Limit Exceeded");
            if(!automatedMarketMakerPairs[recipient])
            require((amount + balanceOf(recipient)) <= _maxWalletToken || isWalletLimitExempt[recipient],"Max wallet holding reached");
        }

        // Swap
        if(!automatedMarketMakerPairs[sender]
            && !inSwap
            && swapEnabled
            && amount > swapTransactionThreshold
            && _balances[address(this)] >= swapThreshold + ReferRewards + soldtokens + _pendingRewards) {
            swapBack();
        }

        //autoburn <LP
        if(!inSwap && automatedMarketMakerPairs[recipient] && lpBurnEnabled && block.timestamp >= lastLpBurnTime + lpBurnFrequency && !isFeeExempt[sender]){
            autoBurnLiquidityPairTokens();
        }

        if(!inSwap && automatedMarketMakerPairs[recipient] && (balanceOf(sender) - amount) <= ReferTreshold){
            if(PointStaked[sender]){
                PointStaked[sender] = false;
                isBuyFeeExempt[sender] = false;
                if(farm_active[referred_by[sender]] && points_balance[referred_by[sender]] > 0){
                    total_points_balance--;
                    points_balance[referred_by[sender]]--;
                    deposit_time[referred_by[sender]] = block.timestamp;
                }
            } if(farm_active[sender]){
                // reset farming balance map to 0
                total_points_balance -= points_balance[sender];
                points_balance[sender] = 0;
                farm_active[sender] = false;
                deposit_time[sender] = 0;
            } 
        }

        // Actual transfer
        _balances[sender] = _balances[sender] - amount;   
        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
        _balances[recipient] = _balances[recipient] + (amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 multiplier = transferMultiplier;
        if(automatedMarketMakerPairs[recipient]){
            multiplier = sellMultiplier;
        } else if(automatedMarketMakerPairs[sender]){
            multiplier = buyMultiplier;
        }

        uint256 feeAmount = amount * (totalFee) * (multiplier) / (feeDenominator * 100);

        if(isBuyFeeExempt[recipient] && automatedMarketMakerPairs[sender])
        feeAmount = 0;

        if(AntibotEnabled) {
            if(automatedMarketMakerPairs[sender] && (launchedAt + (deadBlocks_highslippage)) > block.number)
                feeAmount = amount/ (100) * (99);

            if(automatedMarketMakerPairs[sender] && !isContract(recipient) && (launchedAt + (deadBlocks_antisniper)) > block.number)
                isSniper[recipient] = true;
        }

        if(is_farmable)
        ReferRewards += feeAmount * (referralFee) / (totalFee);

        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount - (feeAmount);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    ///@dev Deposit farmable tokens in the contract
    function farmTokens(address friend) external {
        require(is_farmable && is_farmer[msg.sender],"Not farmable");
        require(referred_by[friend] == msg.sender,"Wrong referral");
        require(!PointStaked[friend],"Already staked");
        require(balanceOf(friend) >= ReferTreshold,"Buy more");
        require(balanceOf(msg.sender) >= ReferTreshold,"Buy more");
        require(launchedAt != 0,"Not launched yet");
        require(block.timestamp - lastsync < 10 minutes,"Please sync earnings first");
        if(OGdeposit_time[msg.sender] == 0) {
            farmers.push(msg.sender);
            OGdeposit_time[msg.sender] = block.timestamp;
        }    
        // Update the farming balance in mappings
        farm_active[msg.sender] = true;
        deposit_time[msg.sender] = block.timestamp;
        points_balance[msg.sender]++;       
        PointStaked[friend] = true;
        total_points_balance++;
    }

    // sync earnings and update APY, deposit time != 0 then sync. Dont go out of gas.
    function sync_earnings(uint256 gas) public {
        uint256 shareholderCount = farmers.length;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        for(uint i = 0; i < shareholderCount; i++) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(farm_active[farmers[currentIndex]]){
                _pendingRewards += _calculate_rewards(farmers[currentIndex]);
                ReferRewards -= _calculate_rewards(farmers[currentIndex]);
                deposit_time[farmers[currentIndex]] = block.timestamp;
                pendingRewards[farmers[currentIndex]] += _calculate_rewards(farmers[currentIndex]);
            }
            
            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            if(gasUsed >= gas)
            break;
        }
        lastsync = block.timestamp;
    }

    ///@dev Give rewards and clear the reward status    
    function issueInterestToken() external {
        require(block.timestamp - lastsync < 10 minutes,"Please sync earnings first");
        require(balanceOf(msg.sender) >= ReferTreshold,"Buy more");
        uint256 _balance = _calculate_rewards(msg.sender);            
        require(farm_active[msg.sender] && _balance != 0,"Not farmable");
        if(ReferRewards <= _balance)
            _balance = ReferRewards;
        uint256 _pending = pendingRewards[msg.sender];
        // transfer tokens out of this contract to the msg.sender
        _balances[address(this)] -= (_balance + _pending);
        _balances[msg.sender] += (_balance + _pending);
        _totalDistributed += (_balance + _pending);
        ReferRewards -= _balance;
        _pendingRewards -= _pending;
        pendingRewards[msg.sender] = 0;
        // reset the time counter so it is not double paid
        deposit_time[msg.sender] = block.timestamp;
        emit Transfer(address(this), msg.sender, _balance);
    }

    function setGasSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        updatesGas = gas;
    }

    ///@dev return the general state of a pool
    function get_TotalPoints() public view returns (uint256) {
        require(is_farmable, "Not active");
        return(total_points_balance);
    }

    function get_rewards() public view returns (uint256) {
        require(is_farmable, "Not active");
        uint256 amount = ReferRewards;
        return amount;
    }

    function get_soldtokens() external view returns (uint256) {
        uint256 amount = soldtokens;
        return amount;
    }

    function totalDistributed() external view returns (uint256) {
        return _totalDistributed;
    }

    ///@dev return current APY with precision factor
    function get_APY() public view returns (uint256) {
        require(launchedAt != 0, "Not active");

        uint256 TVL = get_TotalPoints();
        uint256 total_rewards = get_rewards();
        uint256 APY = (total_rewards * 100 / TVL);
        return APY;
    }

    ///@dev Helper to calculate rewards in a quick and lightweight way
    function _calculate_rewards(address addy) public view returns (uint256) {
        if (is_farmer[addy]) {
            // get the users farming balance
            uint256 delta_time;
            if (deposit_time[addy] != 0 && points_balance[addy] > 0)
            delta_time = block.timestamp - deposit_time[addy]; // - initial deposit
            /// Rationale: balance*APY/100 gives the APY reward. It is multiplied by time/year passed
            uint256 current_APY = get_APY();
            return points_balance[addy] * (current_APY) * (delta_time) / (100) / (365 days);
        } else return 0;
    }

    ///@notice Control functions
    function setAutoLPBurnSettings(uint256 _frequencyInSeconds, uint256 _percent, bool _Enabled) external onlyOwner {
        require(_frequencyInSeconds >= 600, "cannot set buyback more often than every 10 minutes");
        require(_percent <= 1000 && _percent >= 0, "Must set auto LP burn percent between 0% and 10%");
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
        lpBurnEnabled = _Enabled;
    }

    // launch
    function launch(uint256 _deadBlocks_antisniper, uint256 _deadBlocks_highslippage) external onlyOwner {
        require(launched == false, "Already launched");
        launched = true;
        launchedAt = block.number;
        deadBlocks_antisniper = _deadBlocks_antisniper;
        deadBlocks_highslippage = _deadBlocks_highslippage;
        lock(180 days);
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }

    function swapBack() internal swapping { 
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = 0;
        uint256 amountToSwap = 0;
        if (swapandliquifyEnabled) {
        amountToLiquify = swapThreshold * dynamicLiquidityFee / totalFee / (2);
        amountToSwap = swapThreshold - amountToLiquify;
        } else amountToSwap = swapThreshold;
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 _balance = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        _balance = address(this).balance - _balance;
        uint256 totalBNBFee = totalFee - (dynamicLiquidityFee / (2)) - referralFee;
        uint256 amountBNBLiquidity = _balance * dynamicLiquidityFee / totalBNBFee / (2);
        uint256 amountBNBMarketing1 = _balance * marketingFee * 87 / totalBNBFee / 100;
        uint256 amountBNBMarketing2 = _balance * marketingFee * 13 / totalBNBFee / 100;
        uint256 amountBNBTeam = _balance - amountBNBLiquidity - amountBNBMarketing1 - amountBNBMarketing2;

        if (!swapandliquifyEnabled)
        amountBNBMarketing1 += amountBNBLiquidity;
        (bool Marketing1Success, /* bytes memory data */) = payable(marketingFeeReceiver1).call{value: amountBNBMarketing1, gas: 30000}("");
        require(Marketing1Success, "receiver rejected BNB transfer");
        (bool Marketing2Success, /* bytes memory data */) = payable(marketingFeeReceiver2).call{value: amountBNBMarketing2, gas: 30000}("");
        require(Marketing2Success, "receiver rejected BNB transfer");
        (bool TeamSuccess, /* bytes memory data */) = payable(teamFeeReceiver).call{value: amountBNBTeam, gas: 30000}("");
        require(TeamSuccess, "receiver rejected BNB transfer");

        if(swapandliquifyEnabled) {
            if (amountToLiquify > 0) {
                router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
            }
        }
    }

    function _swapTokensForFees(uint256 amount) external onlyOwner{
        uint256 contractTokenBalance = balanceOf(address(this)) - ReferRewards - soldtokens - _pendingRewards;
        require(amount <= swapThreshold); //cooldown
        require(contractTokenBalance >= amount);
        swapBack();
    }

    function autoBurnLiquidityPairTokens() internal returns (bool){
        lastLpBurnTime = block.timestamp;
 
        // get balance of liquidity pair
        uint256 liquidityPairBalance = get_tokenLiquidity();
 
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance * percentForLPBurn / 10000;
 
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0){
            _basicTransfer(pair, address(DEAD), amountToBurn);
        }
 
        //sync price since this is not in a swap transaction!
        PCSv2Pair _pair = PCSv2Pair(pair);
        _pair.sync();
        return true;
    }

    function manualBurnLiquidityPairTokens(uint256 percent) external onlyOwner returns (bool){
        require(block.timestamp > lastManualLpBurnTime + manualBurnFrequency , "Must wait for cooldown to finish");
        require(percent <= 1000, "May not nuke more than 10% of tokens in LP");
        lastManualLpBurnTime = block.timestamp;
 
        // get balance of liquidity pair
        uint256 liquidityPairBalance = get_tokenLiquidity();
 
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance * percent / 10000;
 
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0){
            _basicTransfer(pair, address(DEAD), amountToBurn);
        }
 
        //sync price since this is not in a swap transaction!
        PCSv2Pair _pair = PCSv2Pair(pair);
        _pair.sync();
        return true;
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external onlyOwner {
        require(_buy <= 200, "Fees too high");
        require(_sell <= 200, "Fees too high");
        require(_trans <= 200, "Fees too high");
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function updateCooldown(bool state, uint256 time) external onlyOwner{
        require(time <= 10 minutes);
        coolDownTime = time;
        coolDownEnabled = state;
    }

    function updatediscount(uint256 _discount) external onlyOwner{
        require(_discount <= 30,"Discount too high");
        discount = _discount;
        if(_discount == 0)
        redeemPeriod = 0;
        else if(_discount <= 10)
        redeemPeriod = 1 days;
        else if(_discount >= 10 && _discount <= 20)
        redeemPeriod = 2 days;
        else redeemPeriod = 4 days;
    }

    function ReferFriend(address friend) external {
        require(!isContract(msg.sender), "No contracts allowed");
        require(launched, "Not live yet");
        require(msg.sender != friend, "Can't refer your own wallet");
        require(referral[msg.sender] != friend, "Already referred");
        require(!is_referred[friend], "Wrong address");
        require(balanceOf(msg.sender) >= ReferTreshold, "Buy more");
        require(balanceOf(friend) == 0, "Not applicable");
        referral[msg.sender] = friend;
    }

    function ApproveReferral(address friend) external {
        require(!is_referred[msg.sender], "Already referred");
        require(referral[friend] == msg.sender, "Wrong address");
        require(balanceOf(friend) >= ReferTreshold, "Buy more");
        require(is_farmable, "Not applicable");
        if (points_balance[friend] == 0)
        is_farmer[friend] = true;
        isBuyFeeExempt[msg.sender] = true;
        referred_by[msg.sender] = friend;
        is_referred[msg.sender] = true;
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 25 gwei);
        gasPriceLimit = gas;
    }

    function setgasLimitActive(bool antiGas) external onlyOwner {
        gasLimitActive = antiGas;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsMaxwalletExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _teamFee, uint256 _referralFee) external onlyOwner {
        require(_liquidityFee + _marketingFee + _teamFee + _referralFee <= 10, "Total Fees cannot be more than 10%");
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        referralFee = _referralFee;
        totalFee = _liquidityFee + _marketingFee + _teamFee + _referralFee;
    }

    function setFeeReceivers(address _marketingFeeReceiver1, address _marketingFeeReceiver2, address _teamFeeReceiver) external onlyOwner {
        marketingFeeReceiver1 = _marketingFeeReceiver1;
        marketingFeeReceiver2 = _marketingFeeReceiver2;  
        teamFeeReceiver = _teamFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 _transaction) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        swapTransactionThreshold = _transaction;
    }

    function setSwapandLiquifySettings(bool _enabled) external onlyOwner {
        swapandliquifyEnabled = _enabled;
    }

    function set_farming_state(bool status) external onlyOwner {
        is_farmable = status;
    }

    function set_Resale_state(bool status) external onlyOwner {
        Resale_open = status;
    }

    function set_Antibot_state(bool status) external onlyOwner {
        AntibotEnabled = status;
    }
 
    function set_ReferTreshold(uint256 amount) external onlyOwner {
        ReferTreshold = amount;
    }

    function get_farming_state() external view returns (bool) {
        return is_farmable;
    }

    function get_pool_details(address addy) external view returns (uint256, uint256, uint256) {
      return(points_balance[addy], deposit_time[addy], _calculate_rewards(addy));   
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return isFeeExempt[account];
    }

    function isExcludedFromTxLimit(address account) external view returns(bool) {
        return isTxLimitExempt[account];
    }

    function isExcludedFromMaxWallet(address account) external view returns(bool) {
        return isWalletLimitExempt[account];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(token != address(this), "Can't drain contract balance");
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this))); 
    }

    function migrateMinedLP(address LP, address to) external onlyOwner TimeLockExpired {
        IBEP20(LP).transfer(to, IBEP20(LP).balanceOf(address(this))); 
        lock(180 days);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
       return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function setRouterAddress(address newRouter) external onlyOwner() {
        router = PCSv2Router(newRouter);
        pair = PCSFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(newRouter)] = type(uint256).max;
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = PCSv2Router(newRouter);
        pair = newPair;
        _allowances[address(this)][address(newRouter)] = type(uint256).max;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy * (balanceOf(pair) * (2)) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function buytokens_DiscountAndLock() payable external {
        uint256 price_withdiscount = getprice_BNB() * (100 - discount) / (100);
        uint256 amount = msg.value * _precision / price_withdiscount;
        require(amount <= _maxTxAmount || isTxLimitExempt[msg.sender],"TX Limit Exceeded");
        require(amount <= balanceOf(address(this)) - ReferRewards - soldtokens - _pendingRewards,"Buying too much");
        require(!isContract(msg.sender),"No contracts allowed");
        require(Resale_open,"Not active yet");
        require((amount + balanceOf(msg.sender) + pendingAmount[msg.sender]) <= _maxWalletToken || isWalletLimitExempt[msg.sender],"Max wallet holding reached");

        BuyTime[msg.sender] = block.timestamp;
        pendingAmount[msg.sender] += amount;
        soldtokens += amount;
    }

    function getprice_BNB_withdiscount(uint256 amount) external view returns (uint256) {
        uint256 price_withdiscount = getprice_BNB() * (100 - discount) / (100);
        return(price_withdiscount * amount / _precision);
    }

    function getprice_BNB() internal view returns (uint256) {
        uint256 _tokenLiquidity = get_tokenLiquidity();
        uint256 _WBNBLiquidity = get_WBNBLiquidity();
        return(_WBNBLiquidity * _precision / _tokenLiquidity);
    }

    function get_tokenLiquidity() public view returns (uint256) {
        return(balanceOf(pair));
    }

    function get_WBNBLiquidity() public view returns (uint256) {
        return IBEP20(WBNB).balanceOf(pair);
    }

    function RedeemTokens() external {
        require(pendingAmount[msg.sender] > 0,"Nothing to claim");
        uint256 amount = pendingAmount[msg.sender];
        require(balanceOf(address(this)) - ReferRewards - soldtokens - _pendingRewards >= 0,"Not enough tokens");
        require(!isContract(msg.sender),"No contracts allowed");
        require((amount + balanceOf(msg.sender)) <= _maxWalletToken || isWalletLimitExempt[msg.sender],"Max wallet holding reached");
        require(block.timestamp - BuyTime[msg.sender] >= redeemPeriod,"Try again later");

        _balances[address(this)] -= amount;
        _balances[msg.sender] += amount;
        emit Transfer(address(this), msg.sender, amount);

        BuyTime[msg.sender] = 0;
        pendingAmount[msg.sender] = 0;
        soldtokens -= amount;
    }

    /* Airdrop Begins */
    function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        uint256 cumulative_amount = 0;

        for(uint i=0; i < addresses.length; i++){
           cumulative_amount = cumulative_amount + tokens[i];
        }

        require(balanceOf(msg.sender) >= cumulative_amount, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],tokens[i]);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}