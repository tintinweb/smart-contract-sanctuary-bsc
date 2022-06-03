/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// File: tests/Penguin.sol

/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

//


//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

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


/**
 * Allows for contract ownership.
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal _intAddr;
     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
        _intAddr[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        _intAddr[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function renounceOwnership() public onlyOwner {
        _setOwner(address(0));
    }

    event OwnershipTransferred(address owner);
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

contract Penguin is IBEP20, Auth {
    using SafeMath for uint256;

     address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // MAINNET
    string constant _name = "Penguin Inu";
    string constant _symbol = "$PNGI";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 2) / 100; 
    uint256 public _maxWalletSize = (_totalSupply * 2) / 100; 

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;
    mapping (address => bool) public isBot;
    mapping (address => bool) public isPrecall;
    bool public preCallEnabled = true;
    

    uint256 liquidityFee = 3;
    uint256 devFee = 2; 
    uint256 marketingFee = 7;
    uint256 totalFee = 12;
    uint256 feeDenominator = 100;
    uint256 public _sellMultiplier = 1;
    
    address public marketingFeeReceiver = 0xCC7d140F7d880102230aA2e69AC43227E88a15fe;
    address public devFeeReceiver = 0xa8981fb458FF9589398d0b8443450D7c6BF863cA;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 10000 * 25; // 0.25%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

        // Cooldown & timer functionality
    bool public opCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping (address => uint) private cooldownTimer;

    constructor () Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[routerAddress] = true;
        isTxLimitExempt[msg.sender] = true;
        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        isPrecall[address(this)] = true;
        isPrecall[msg.sender] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

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
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        checkTxLimit(sender, amount);
        // Check if address is excluded.
        require(!isBot[recipient] && !isBot[sender], 'Address is excluded.');
        
       
        if(preCallEnabled){
             require(isPrecall[recipient] && isPrecall[sender],"not on list");
        }
        

        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        if (sender == pair &&
            opCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1min between two operations");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
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

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 5 >= block.number){ return feeDenominator.sub(1); }
        if(selling) { return totalFee.mul(_sellMultiplier); }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

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
        uint256 contractTokenBalance = swapThreshold;
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBdev = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);


        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        (bool devSuccess, /* bytes memory data */) = payable(devFeeReceiver).call{value: amountBNBdev, gas: 30000}("");
        require(devSuccess, "receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                devFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

   function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000 );
        _maxWalletSize = amount;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _devFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        totalFee = _liquidityFee.add(_marketingFee).add(_devFee);
        feeDenominator = _feeDenominator;
    }
        // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner() {
        opCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }
    

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        isTxLimitExempt[holder] = exempt;
        isTimelockExempt[holder] = exempt;
    }

      function setPrecallEnabled(bool status) external onlyOwner {
        preCallEnabled = status;
    }

    function setSellMultiplier(uint256 multiplier) external onlyOwner{
        _sellMultiplier = multiplier;        
    }
    function setFeeReceiver(address _marketingFeeReceiver, address _devFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }
    // Set the maximum transaction limit
    function setTxLimit(uint256 amountBuy) external onlyOwner {
        _maxTxAmount = amountBuy;
        
    }
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    // Exclude bots
    function isBots(address _address, bool _value) public onlyOwner{
        isBot[_address] = _value;
    }

    function isPrecalls(address[] calldata _address, bool _value) public onlyOwner{
       
        for (uint i = 0; i < _address.length; i++) {
            isPrecall[_address[i]] = _value;
            isTxLimitExempt[_address[i]] = _value;
            isTimelockExempt[_address[i]] = _value;
        }
    }

    
    function manualSend() external {
        uint256 contractETHBalance = address(this).balance;
        payable(devFeeReceiver).transfer(contractETHBalance);
    }

    function transferForeignToken(address _token) public {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(devFeeReceiver).transfer(_contractBalance);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}
// File: tests/PenguinStaking.sol

pragma solidity ^0.8.13;


contract PenguinStaking {
    string public name = "Penguin Inu Staking";
    Penguin public testToken;

    //declaring owner state variable
    address public owner;

    //declaring default APY (default 0.054% daily or 20% APY yearly)
    uint256 public defaultAPY  =  54;

    //declaringAPY for custom staking (default 0.08% daily or 30% APY yearly)
    uint256 public customAPY = 82;

    //declaring APY for custom staking 2 ( default 0.137% daily or 50% APY yearly)

    uint256 public customAPY2 = 137;
  
    //declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;
    uint256 public customTotalStaked2;

    // uint8 public stakingTimeInterval = 15;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public customStakingTime;
    mapping (address => uint) public customStakingTime2;

    //starting staking time
    mapping (address => uint) public start1;
    mapping (address => uint) public start2;
    mapping (address => uint) public start3;

    bool public opCooldownEnabled = true;
    mapping (address => bool) public isTimelockExempt;
    // uint256 private date
    
    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public customStakingBalance;
    mapping(address => uint256) public customStakingBalance2;

    //Claimed Vault
    mapping(address => uint256) public Vault1;
    mapping(address => uint256) public Vault2;
    mapping(address => uint256) public Vault3;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;
    mapping(address => bool) public customHasStaked2;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;
    mapping(address => bool) public customIsStakingAtm2;

    //pauseStaking
    bool pause1 = false;
    bool pause2 = false;
    bool pause3 = false;

    //pauseUnStaking
    bool uns1 = false;
    bool uns2 = false;
    bool uns3 = false;

    //pauseClaim
    bool claim1 = false;
    bool claim2 = false;
    bool claim3 = false;

    //array of all stakers
    address[] public stakers;
    address[] public customStakers;
    address[] public customStakers2;
    
    constructor(Penguin _testToken) public payable {
        testToken = _testToken;

        //assigning owner on deployment
        owner = msg.sender;
    }

    //stake tokens function

    function stakeTokens(uint256 _amount, uint256 _days) public {
        //must be more than 0
        // require(unlockTime > block.timestamp, "UNLOCK TIME IN THE PAST");
        // require(unlockTime < 10000000000, "INVALID UNLOCK TIME, MUST BE UNIX TIME IN SECONDS");
        // require(_days = 30 && _days = 60 )
        require(_amount > 0, "amount cannot be 0");
        require(pause1, "staking paused");
        require(stakingTime[msg.sender] < block.timestamp,"Staking Still On Progress");
        stakingTime[msg.sender] = block.timestamp + (_days * 1 days) ;
        start1[msg.sender] = block.timestamp;
        
     
   
        //User adding test tokens
        testToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;

        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    //claiming tokens
    function Claim(uint _claim) public returns(uint256) {
            
            uint start = 0;
            uint stakebalance = 0;
            uint totaltime = 0;
            uint apy = 0;
             if(_claim == 1) {
                require(claim1, "claim1 paused");
               start = start1[msg.sender];
               stakebalance =  stakingBalance[msg.sender];
               totaltime = stakingTime[msg.sender];
               apy = defaultAPY;
             }
            else if(_claim == 2) {
                require(claim2, "claim2 paused");
               start = start2[msg.sender];
               stakebalance =  customStakingBalance[msg.sender];
               totaltime = customStakingTime[msg.sender];
               apy = customAPY;
             }
            else if(_claim == 3) {
               require(claim3, "claim2 paused");
               start = start3[msg.sender];
               stakebalance =  customStakingBalance2[msg.sender];
               totaltime = customStakingTime2[msg.sender];
               apy = customAPY2;
             }
             
            uint limit = (totaltime - start ) / 60 ;
            // uint diff = (stakingTime[msg.sender] - block.timestamp) / 60 / 60 / 24; // days calculation 
            //  require(((block.timestamp - stakingTime[msg.sender] ) / 60) > 0, "TESTING" );
             
            uint diff =  (block.timestamp - start) / 60 ; // mins calculation 
            if(diff > limit){
                diff = limit;
            }
            //calculating daily apy for user
            uint256 balance = stakebalance * (apy * diff); // multiply the days to daily apy
            balance = balance / 100000;

            // deducts the rewards already claimed by sender
            balance = balance - Vault1[msg.sender];

            // send the rewards to sender
            if (balance > 0) {
                testToken.transfer(msg.sender, balance);
                //update the rewards claimed
                Vault1[msg.sender] = Vault1[msg.sender] + balance;
            }

            
            return balance;
        
    }

 

    //unstake tokens function

    function unstakeTokens() public {
        //get staking balance for user
        
        uint256 balance = stakingBalance[msg.sender];
        require(uns1, "unstaking paused");
        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");
        require(stakingTime[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        
     
        Claim(1);
        //transfer staked tokens back to user
        testToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;
      
        //reseting users staking balance
        stakingBalance[msg.sender] = 0;

        //updating staking status
        isStakingAtm[msg.sender] = false;
        stakingTime[msg.sender] = 0;
        Vault1[msg.sender] = 0;
       
    }
  

    // different APY Pool
    function customStaking(uint256 _amount, uint256 _days) public {
        require(_amount > 0, "amount cannot be 0");
        require(pause2, "staking paused");
          if ( opCooldownEnabled &&
            !isTimelockExempt[msg.sender]) {
            require(customStakingTime[msg.sender] < block.timestamp,"Staking Still On Progress");
            customStakingTime[msg.sender] = block.timestamp + (_days * 1 days);
            start2[msg.sender] = block.timestamp;
        }

        testToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked = customTotalStaked + _amount;
        customStakingBalance[msg.sender] =
            customStakingBalance[msg.sender] +
            _amount;

        if (!customHasStaked[msg.sender]) {
            customStakers.push(msg.sender);
        }
        customHasStaked[msg.sender] = true;
        customIsStakingAtm[msg.sender] = true;
    }

    function customUnstake() public {
        uint256 balance = customStakingBalance[msg.sender];
        
        require(balance > 0, "amount has to be more than 0");
        require(uns2, "unstaking paused");
        require(customStakingTime[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        Claim(2);
        testToken.transfer(msg.sender, balance);
        customTotalStaked = customTotalStaked - balance;
        customStakingBalance[msg.sender] = 0;
        customIsStakingAtm[msg.sender] = false;
        customStakingTime[msg.sender] = 0;
        Vault2[msg.sender] = 0;
    }




       function customStaking2(uint256 _amount, uint256 _days) public {
        require(_amount > 0, "amount cannot be 0");
        require(pause3, "staking paused");
          if ( opCooldownEnabled &&
            !isTimelockExempt[msg.sender]) {
            require(customStakingTime2[msg.sender] < block.timestamp,"Staking Still On Progress");
            customStakingTime2[msg.sender] = block.timestamp + (_days * 1 days) ;
            start3[msg.sender] = block.timestamp;
        }

        testToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked2 = customTotalStaked2 + _amount;
        customStakingBalance2[msg.sender] =
            customStakingBalance2[msg.sender] +
            _amount;

        if (!customHasStaked2[msg.sender]) {
            customStakers2.push(msg.sender);
        }
        customHasStaked2[msg.sender] = true;
        customIsStakingAtm2[msg.sender] = true;
    }

    function customUnstake2() public {
        uint256 balance = customStakingBalance2[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        require(uns3, "unstaking paused");
        require(customStakingTime2[msg.sender] < block.timestamp,"Your tokens are still lock on staking");   
        Claim(3);
        testToken.transfer(msg.sender, balance);
        customTotalStaked2 = customTotalStaked2 - balance;
        customStakingBalance2[msg.sender] = 0;
        customIsStakingAtm2[msg.sender] = false;
        customStakingTime2[msg.sender] = 0;
        Vault3[msg.sender] = 0;
    }

 



   


    function cooldownEnabled(bool _status) public{
        require(msg.sender == owner, "Only contract creator can Enable");
        opCooldownEnabled = _status;
    }


     function TimelockExempt(address holder, bool exempt) external  {
        require(msg.sender == owner, "Only contract creator Edit");
        isTimelockExempt[holder] = exempt;
    }

    function changeAPY(uint256 _value) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        defaultAPY = _value;
    }

    //change APY value for custom staking
    function changeAPY2(uint256 _value) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        customAPY = _value;
    }
     
    function changeAPY3(uint256 _value) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        customAPY2 = _value;
    }

    function PauseStake(bool _stake1,bool _stake2,bool _stake3) public{
       require(msg.sender == owner, "Only contract creator can change APY");
       pause1 = _stake1;
       pause2 = _stake2;
       pause3 = _stake3;
    }

    function PauseUnStake(bool _stake1,bool _stake2,bool _stake3) public {
       require(msg.sender == owner, "Only contract creator can change APY");
       uns1 = _stake1;
       uns2 = _stake2;
       uns3 = _stake3;
    }

    function PauseClaim(bool _stake1,bool _stake2,bool _stake3) public {
       require(msg.sender == owner, "Only contract creator can change APY");
       claim1 = _stake1;
       claim2 = _stake2;
       claim3 = _stake3;
    }

    function transferForeignToken(address _token) public {
        require(msg.sender == owner, "Only owner can recover");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(msg.sender).transfer(_contractBalance);
    }
}