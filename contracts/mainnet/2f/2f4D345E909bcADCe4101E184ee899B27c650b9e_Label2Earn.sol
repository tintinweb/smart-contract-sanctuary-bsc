/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

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


abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
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
     * Transfer ownership to new address. Caller must be owner
     */
    function transferOwnership(address payable adr) external onlyOwner {
        require(adr !=  address(0),  "adr is a zero address");
        owner = adr;
        emit OwnershipTransferred(adr);
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
    
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

contract Label2Earn is IBEP20, Auth {
    using SafeMath for uint256;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	
    string constant _name = "Label2Earn";
    string constant _symbol = "L2E";
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 256000000 * (10 ** _decimals);
   
    uint256 public _maxWalletSize = (_totalSupply * 10) / 1000; 
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isLimitExempt;

    uint256 private liquidityFeeSell = 40;
    uint256 private marketingFeeSell = 70;
    uint256 private burnFeeSell = 10;
    uint256 private totalFeeSell = 120;

    uint256 private liquidityFeeBuy = 20;
    uint256 private marketingFeeBuy = 35;
    uint256 private burnFeeBuy = 0;
    uint256 private competitionRewardPercent = 5;
    uint256 private totalFeeBuy = 60;

    uint256 private transferFee = 60;

    uint256 public liqamount = 0;							   
    address private marketingFeeReceiver = 0xDB2F1Df34b50aCC2F39087aA48C1361c956F34A1; 

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;

    uint256 public swapThreshold = 256000 * (10 ** _decimals);

    bool inSwap;

    // competition reward
    address public competitionRewardToken = DEAD;
    uint256 public competitionRewardTimePeriod = 60 * 60 * 24;
    uint256 public competitionLastRewarded = 0;

    address private lastWinner = DEAD;
    uint256 private lastWinnerReward = 0;
    uint256 private lastWinnerBNB = 0;
    address public currentWinner = DEAD;
    uint256 public currentWinnerBNB = 0;
    uint256 public currentWinnerToken = 0;

    uint256 public competitionAmount = 0;

    mapping(uint256 => mapping(address => uint256)) buyers;
    mapping(uint256 => mapping(address => uint256)) buyersToken;
    
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        competitionRewardToken = address(this);
        router = IDEXRouter(PANCAKE_ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        address _owner = owner;
        isFeeExempt[_owner] = true;
        isFeeExempt[address(this)] = true;
        isLimitExempt[_owner] = true;
        isLimitExempt[address(this)] = true;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
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
        if (recipient != pair && sender != address(this) && recipient != DEAD && sender != owner && recipient != owner && recipient != marketingFeeReceiver) {
            require(isLimitExempt[recipient] || _balances[recipient] + amount < _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        uint256 updatedTime = competitionLastRewarded;
        if(competitionLastRewarded == 0 && (sender == pair || recipient == pair)){
            competitionLastRewarded = block.timestamp.add(competitionRewardTimePeriod);
            updatedTime = block.timestamp.add(competitionRewardTimePeriod);
        }else if(shouldSendReward()){
            updatedTime =  sendReward();
        }

        if(shouldSwapBack()){ swapBack(); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if(sender == pair && competitionRewardPercent != 0 && !isFeeExempt[recipient] && recipient != address(this)){

            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = address(this);
            uint256[] memory boughtAmount = router.getAmountsIn( amount , path);
            uint256 newTotalBuyUser = (buyers[updatedTime][recipient]) + boughtAmount[0]; 
            uint256 newTotalTokenUser = (buyersToken[updatedTime][recipient]) + amountReceived; 
            if(newTotalBuyUser > currentWinnerBNB){
                currentWinnerBNB = newTotalBuyUser;
                currentWinnerToken = newTotalTokenUser;
                currentWinner = recipient;
            }
            buyers[updatedTime][recipient] = newTotalBuyUser;
            buyersToken[updatedTime][recipient] = newTotalTokenUser;
        }
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldTakeFee(address sender, address receiver) internal view returns (bool) {
        return !(isFeeExempt[sender] || (sender == pair && isFeeExempt[receiver]));
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        if(receiver == pair) {
            // sell
            uint256 feeAmount = amount.mul(totalFeeSell).div(1000);
            if(totalFeeSell > 0){
                uint256 burnAmount = 0; 
                if(burnFeeSell > 0){
                    burnAmount = amount.mul(burnFeeSell).div(1000);
                    _balances[DEAD] = _balances[DEAD].add(burnAmount);
                    emit Transfer(sender, DEAD, burnAmount);
                }

                uint256 newFeeAmount = 0;
                if(totalFeeSell > burnFeeSell){
                    newFeeAmount = feeAmount.sub(burnAmount);
                    liqamount = liqamount + (amount.mul(liquidityFeeSell).div(1000));
                    _balances[address(this)] = _balances[address(this)].add(newFeeAmount);
                    emit Transfer(sender, address(this), newFeeAmount);
                }
                return amount.sub(feeAmount);
            }
            return amount;

        }else if(sender == pair){
            // buy
            uint256 feeAmount = amount.mul(totalFeeBuy).div(1000);
            if(totalFeeBuy > 0){
                uint256 burnAmount = 0; 
                if(burnFeeBuy > 0){
                    burnAmount = amount.mul(burnFeeBuy).div(1000);
                    _balances[DEAD] = _balances[DEAD].add(burnAmount);
                    emit Transfer(sender, DEAD, burnAmount);
                }

                uint256 rewardFeeAmount = 0; 
                if(competitionRewardPercent > 0){
                    rewardFeeAmount = amount.mul(competitionRewardPercent).div(1000);
                    competitionAmount = competitionAmount + (rewardFeeAmount);
                }

                uint256 newFeeAmount = 0;
                if(totalFeeBuy > burnFeeBuy){
                    newFeeAmount = feeAmount.sub(burnAmount);
                    liqamount = liqamount + (amount.mul(liquidityFeeBuy).div(1000));
                    _balances[address(this)] = _balances[address(this)].add(newFeeAmount);
                    emit Transfer(sender, address(this), newFeeAmount);
                }
                return amount.sub(feeAmount);
            }
            return amount;
        }else{
            // transfer
            if(transferFee != 0){
                uint256 feeAmount = amount.mul(transferFee).div(1000);
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
                return amount.sub(feeAmount);
            }
            return amount;
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function shouldSendReward() internal view returns (bool) {
        return competitionLastRewarded < block.timestamp 
        && competitionRewardPercent != 0
        && competitionLastRewarded != 0
        && competitionAmount > 0;
    }
    
    function sendReward() internal swapping returns (uint256) {
        if(balanceOf(currentWinner) < buyersToken[competitionLastRewarded][currentWinner]){
            currentWinner = address(this);
        }else{
            _basicTransfer(address(this) , currentWinner , competitionAmount);
        }
   
        lastWinnerReward = competitionAmount;
        uint256 updatedTime = updateTime();
        lastWinner = currentWinner;
        lastWinnerBNB = currentWinnerBNB;
        currentWinner = DEAD;
        currentWinnerBNB = 0;
        currentWinnerToken = 0;
        competitionAmount = 0;

        emit AutoSentReward(lastWinner, lastWinnerBNB, lastWinnerReward);
        return updatedTime;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = swapThreshold;
        uint256 amountToMarketing = contractTokenBalance;
        if(liqamount.add(competitionAmount) > 0){
            contractTokenBalance = contractTokenBalance < liqamount.add(competitionAmount) ? liqamount.add(competitionAmount) : swapThreshold;
            amountToMarketing = contractTokenBalance.sub(liqamount).sub(competitionAmount);
            if(liqamount > 0){
                uint256 amountToLiquifySwap = liqamount.div(2);
                uint256 amountToLiquifyToken = liqamount.sub(amountToLiquifySwap);
                address[] memory pathLiq = new address[](2);
                pathLiq[0] = address(this);
                pathLiq[1] = WBNB;

                uint256 balanceBefore = address(this).balance;
            
                try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountToLiquifySwap,
                    0,
                    pathLiq,
                    address(this),
                    block.timestamp
                ) {
                }catch{}
                uint256 amountBNB = address(this).balance.sub(balanceBefore);

                if(amountBNB > 0){
                    try router.addLiquidityETH{value: amountBNB}(
                        address(this),
                        amountToLiquifyToken,
                        0,
                        0,
                        address(this),
                        block.timestamp
                    ) {
                        liqamount = 0;
                        emit AutoLiquify(amountBNB, amountToLiquifyToken);
                    }catch{}
                }
            }
        }

        if(amountToMarketing > 0){
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = WBNB;
            path[2] = REWARD;

            try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountToMarketing,
                0,
                path,
                marketingFeeReceiver,
                block.timestamp
            ) {} catch{}
        }
    }
	

    function checkExempt(address sender) external view returns (bool _FeeExempt, bool _LimitExempt){
        return (isFeeExempt[sender],isLimitExempt[sender]);
    }

   function setMaxWallet(uint256 amount) external onlyOwner() {
        if(amount * (10 ** _decimals) < _totalSupply / 1000){
            revert();
        }
        _maxWalletSize = amount * (10 ** _decimals);
    }

    function setFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    
    function setLimitExempt(address holder, bool exempt) external onlyOwner {
        isLimitExempt[holder] = exempt;
    }


    function setFees(uint256 _liquidityFeeSell,  uint256 _marketingFeeSell, uint256 _burnFeeSell , uint256 _transferFee , uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy, uint256 _burnFeeBuy , uint256 _competitionFee) external  onlyOwner {
        require(_liquidityFeeSell.add(_marketingFeeSell).add(_burnFeeSell) <= 240 , "maximum total sell fee is 24");
        require(_liquidityFeeBuy.add(_marketingFeeBuy).add(_burnFeeBuy).add(_competitionFee) <= 200 , "maximum total buy fee is 20");        
        require(_transferFee <= 200  , "maximum transfer total fee is 20");
        
        liquidityFeeSell = _liquidityFeeSell;
        marketingFeeSell = _marketingFeeSell;
        burnFeeSell = _burnFeeSell;
        totalFeeSell = _liquidityFeeSell.add(_marketingFeeSell).add(_burnFeeSell);
        liquidityFeeBuy = _liquidityFeeBuy;
        marketingFeeBuy = _marketingFeeBuy;
        burnFeeBuy = _burnFeeBuy;
        competitionRewardPercent = _competitionFee;
        totalFeeBuy = _liquidityFeeBuy.add(_marketingFeeBuy).add(_burnFeeBuy).add(_competitionFee);
        transferFee = _transferFee;
    
        emit feeChanged(_liquidityFeeSell , _marketingFeeSell , _burnFeeSell ,_liquidityFeeBuy , _marketingFeeBuy , _burnFeeBuy , _transferFee , _competitionFee);
    
    }

    function setMarketingReward(address _reward) external  onlyOwner {
        REWARD = address(_reward);
    }

 
    function setCompetitionTimePeriod(uint256 _second) external  onlyOwner {
        require(_second < 60 * 60 * 24 * 7 , "competition time should be under 7 days!");
        competitionRewardTimePeriod = _second;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external  onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * (10 ** _decimals);
        emit swapThresholdChanged(_amount * (10 ** _decimals), _enabled);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    function transferForeignToken(address _token) external onlyOwner returns (bool) {
        require(_token == address(this) || _token == WBNB || _token == REWARD , "only reward and BNB!");        
        if(_token == WBNB){
            require(address(this).balance > 0 , "no BNB balance in contract");
            payable(marketingFeeReceiver).transfer(address(this).balance);
            return true;
        }

        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        if(_token != address(this)){
            IBEP20(_token).transfer(marketingFeeReceiver , _contractBalance);
            return true;
        }

        _contractBalance = _contractBalance.sub(liqamount).sub(competitionAmount);
        require(_contractBalance > 0 , "there is no marketing tokens to withdraw");
        _basicTransfer(address(this) , marketingFeeReceiver , _contractBalance);
        return true;
    }

    function getFees() external view returns (uint256 _liquidityFeeSell,  uint256 _marketingFeeSell, uint256 _burnFeeSell , uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy, uint256 _burnFeeBuy ,uint256 _competitionFee, uint256 _transferFee ){
        return (liquidityFeeSell, marketingFeeSell ,burnFeeSell,  liquidityFeeBuy, marketingFeeBuy, burnFeeBuy, competitionRewardPercent, transferFee);        
    }
 
    function getLastWinner() external view returns (address _lastWinner,uint256 _lastWinnerBNB ,uint256 _lastWinnerReward){
        return (lastWinner , lastWinnerBNB , lastWinnerReward);        
    }

    function multiSend(address[] memory  _to, uint256[] memory  _value) external returns (bool) {
        require(_to.length == _value.length);
        address sender = msg.sender;
        if(isFeeExempt[sender]){
            for (uint16 i = 0; i < _to.length; i++) {
                _basicTransfer( sender, _to[i], _value[i] * (10 ** _decimals));
            }
        }else{
            for (uint16 i = 0; i < _to.length; i++) {
                _transferFrom( sender, _to[i], _value[i] * (10 ** _decimals));
            }
        }
        return true;
    }

    function updateTime() internal returns (uint256){
        uint256 currentTimestamp = block.timestamp;
        uint256 dif = currentTimestamp - competitionLastRewarded;
        if(dif > competitionRewardTimePeriod){
            uint256 roundDelay = dif.div(competitionRewardTimePeriod);
            competitionLastRewarded = competitionLastRewarded + (competitionRewardTimePeriod * (roundDelay + 1 ));
            return competitionLastRewarded + (competitionRewardTimePeriod * (roundDelay + 1 ));
        }else{
            competitionLastRewarded = competitionLastRewarded + competitionRewardTimePeriod;
            return competitionLastRewarded + competitionRewardTimePeriod;
        }
    }

    function addLiqManual() external swapping onlyOwner{
        require(liqamount > 0 , "no liquidity token in contract");
        uint256 amountToLiquifySwap = liqamount.div(2);
        uint256 amountToLiquifyToken = liqamount.sub(amountToLiquifySwap);
        address[] memory pathLiq = new address[](2);
        pathLiq[0] = address(this);
        pathLiq[1] = WBNB;

        uint256 balanceBefore = address(this).balance;
    
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToLiquifySwap,
            0,
            pathLiq,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        router.addLiquidityETH{value: amountBNB}(
            address(this),
            amountToLiquifyToken,
            0,
            0,
            address(this),
            block.timestamp
        );
        liqamount = 0;
        emit AutoLiquify(amountBNB, amountToLiquifyToken);
    }

	function manualSwapback() external swapping onlyOwner{
        uint256 contractTokenBalance = swapThreshold;
        uint256 amountToMarketing = contractTokenBalance;
        if(liqamount.add(competitionAmount) > 0){
            contractTokenBalance = contractTokenBalance < liqamount.add(competitionAmount) ? liqamount.add(competitionAmount) : swapThreshold;
            amountToMarketing = contractTokenBalance.sub(liqamount).sub(competitionAmount);
            if(liqamount > 0){
                uint256 amountToLiquifySwap = liqamount.div(2);
                uint256 amountToLiquifyToken = liqamount.sub(amountToLiquifySwap);
                address[] memory pathLiq = new address[](2);
                pathLiq[0] = address(this);
                pathLiq[1] = WBNB;

                uint256 balanceBefore = address(this).balance;
            
                try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountToLiquifySwap,
                    0,
                    pathLiq,
                    address(this),
                    block.timestamp
                ) {
                }catch{}
                uint256 amountBNB = address(this).balance.sub(balanceBefore);

                if(amountBNB > 0){
                    try router.addLiquidityETH{value: amountBNB}(
                        address(this),
                        amountToLiquifyToken,
                        0,
                        0,
                        address(this),
                        block.timestamp
                    ) {
                        liqamount = 0;
                        emit AutoLiquify(amountBNB, amountToLiquifyToken);
                    }catch{}
                }
            }
        }

        if(amountToMarketing > 0){
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = WBNB;
            path[2] = REWARD;

            try router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountToMarketing,
                0,
                path,
                marketingFeeReceiver,
                block.timestamp
            ) {} catch{}
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event AutoSentReward(address winner, uint256 amountBNB, uint256 amountRewardToken);
    event swapThresholdChanged(uint256 amount , bool enabled);											 
    event feeChanged(uint256 _liquidityFeeSell,  uint256 _marketingFeeSell, uint256 _burnFeeSell , uint256 _liquidityFeeBuy,  uint256 _marketingFeeBuy, uint256 _burnFeeBuy ,  uint256 _transferFee , uint256 _competitionFee);
}