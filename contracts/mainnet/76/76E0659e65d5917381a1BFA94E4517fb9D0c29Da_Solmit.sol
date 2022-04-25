/**
 *Submitted for verification at BscScan.com on 2022-04-25
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
    function decimals() external view returns (uint256);
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

contract Solmit is IBEP20, Auth {

    using SafeMath for uint256;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    string constant _name = "SOLMIT";
    string constant _symbol = "SOLT";
    uint8 constant _decimals = 18;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) _balances;
    uint256 constant _totalSupply = 2000000000 * (10 ** _decimals);

    address public BUSDReceiver;
    uint256 constant MONTH = 30 * 24 * 60 * 60;
    uint256 public referReward = 30;
    uint256 public LiquidityPercent = 150;
    uint256 public LockedForLiquidity = 0;
    uint256 public RoundBuyLimit = (1000000 * (10 ** _decimals));
    uint256 public roundsPeriod = MONTH;
    uint256 public lastRound = 0;
    uint256 public currentRound = 0;
    bool public presaleStarted = false;

    // presale
    //
    mapping (address => mapping (uint256 => uint256)) public usersBought;
    mapping (address => uint256) public usersTotalBought;
    mapping (uint256 => uint256) public roundsFilled;
    uint256[] public roundsPrices;
    uint256[] public roundsMax;
    uint256[][] public roundsTiming;
    uint256[][] public unlockData;

    IDEXRouter public router;
    address public WBNBpair;
    address public BUSDpair;
    uint256 public liquidityUnlockTime = 0;
    bool public initialLiquidity = true;
    bool public firstLiquidityProvide = true;
    uint256[][] public tokensLocked;

    constructor () Auth(msg.sender) {

        router = IDEXRouter(PANCAKE_ROUTER);
        WBNBpair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        BUSDpair = IDEXFactory(router.factory()).createPair(BUSD, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        BUSDReceiver = owner;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
        
        // set default rounds prices and maximum
        roundsPrices = [0 , 100 , 83 , 72 , 62 , 55 , 0 , 0];

        // set 0
        roundsMax.push(0);
        uint256 i = 1;
        while (i <= 7) {
            if(i <= 5){
                roundsMax.push(140000000 * (10 ** _decimals));
            }else{
                roundsMax.push(150000000 * (10 ** _decimals));
            }
            i++;
        }

    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint256) { return _decimals; }
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
        updateAndReturnCurrentRound();
        uint256 lockedTokens = 0;
        uint256 totalBought = getUserBought(0 , sender);
        uint256 percent = getUnlockedPercent();
        if(totalBought > 0 && sender != address(this)){
            lockedTokens = totalBought - (totalBought.mul(percent).div(100));
            require(_balances[sender] > amount + lockedTokens , "you cant send your locked token");
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function startPresale() external onlyOwner{
        uint256 currentTime = block.timestamp;
        roundsTiming.push([0 , 0]);

        // round 1
        roundsTiming.push([currentTime , currentTime + roundsPeriod]);
        // round 2
        roundsTiming.push([currentTime + roundsPeriod + 1 , currentTime + (roundsPeriod * 2)]);
        // round 3
        roundsTiming.push([ currentTime + (roundsPeriod * 2) + 1 ,  currentTime + (roundsPeriod * 3)]);
        // round 4
        roundsTiming.push([ currentTime + (roundsPeriod * 3) + 1 ,  currentTime + (roundsPeriod * 4)]);
        // round 5
        roundsTiming.push([ currentTime + (roundsPeriod * 4) + 1 ,  currentTime + (roundsPeriod * 5)]);
        // round 6
        roundsTiming.push([ 0 ,  0]);
        // round 7
        roundsTiming.push([ 0 ,  0]);

        uint256 presaleEndTime = currentTime + (roundsPeriod * 5);

        // set unlock percents time
        unlockData.push([0 , 0]);
        unlockData.push([presaleEndTime + (MONTH) , 25]);
        unlockData.push([presaleEndTime + ((MONTH) * 2) , 50]);
        unlockData.push([presaleEndTime + ((MONTH) * 3) , 75]);
        unlockData.push([presaleEndTime + ((MONTH) * 4) , 100]);

        // set round
        currentRound = 1;
        presaleStarted = true;
    }

    function buy(uint256 _amount , address _refer) public returns(bool){
        uint256 _token = _amount.mul(roundsPrices[currentRound]);
        uint256 userBought = getUserBought(currentRound , msg.sender);
        require(updateAndReturnCurrentRound() != 0 , "PRESALE NOT STARTED");
        require(_amount  > 0 , "buy amount should be biger than 0");
        require(_token  <=  balanceOf(address(this)) , "contract not enough balance");
        require(_token + userBought <= RoundBuyLimit , "You have reached maximum wallet buy amount for this round");
        require(IBEP20(BUSD).balanceOf(msg.sender) >= _amount , "not enough balance");
        require(getRoundLeftAmount(currentRound) >= _token  , "buy amount is more than rounds left amount");
        
        if(LiquidityPercent == 0){
            IBEP20(BUSD).transferFrom(msg.sender , BUSDReceiver , _amount);
        }else{
            uint256 amountToLiquidity = _amount.mul(LiquidityPercent).div(1000);
            uint256 amountToReceiver = _amount.sub(amountToLiquidity);
            LockedForLiquidity = LockedForLiquidity + amountToLiquidity;
            IBEP20(BUSD).transferFrom(msg.sender , address(this) , amountToLiquidity);
            IBEP20(BUSD).transferFrom(msg.sender , BUSDReceiver , amountToReceiver);
        }

        if(_refer != address(0) && _refer != DEAD && _refer != msg.sender && _refer != address(this)){
            uint256 referTokens = _token.mul(referReward).div(1000);
            _transferFrom(address(this), _refer, referTokens);
        }
        _transferFrom(address(this), msg.sender, _token);
        roundsFilled[currentRound] = roundsFilled[currentRound] + _token;
        usersBought[msg.sender][currentRound] = userBought + _token;
        usersTotalBought[msg.sender] = usersTotalBought[msg.sender] + _token;
        return true;
    }


    function startSpecialRounds(uint256 _round6 , uint256 _round7) external onlyOwner returns(bool){
        updateAndReturnCurrentRound();
        require(_round7 > 0 && _round6 > 0 && block.timestamp > roundsTiming[5][1] , "rounds price could not be 0");
        uint256 currentTime = block.timestamp;

        roundsTiming[6] = ([ currentTime,  currentTime + (roundsPeriod )]);
        roundsTiming[7] = ([ currentTime + (roundsPeriod) + 1 ,  currentTime + (roundsPeriod * 2)]);

        roundsPrices[6] = _round6;
        roundsPrices[7] = _round7;
        
        currentRound = 6;
        return true;
    }

    function updateAndReturnCurrentRound() public returns(uint256 round){
        if(presaleStarted == true){
            uint256 i = 1;
            uint256 currentTime = block.timestamp;
            while(i <= 7){
                if(currentTime > roundsTiming[i][0] && currentTime < roundsTiming[i][1]){
                    if(currentRound != 0){
                        lastRound = currentRound;
                    }
                    currentRound = i;
                    return currentRound;
                }
                i++;
            }
            if(currentTime > roundsTiming[5][1] && lastRound == 4){
                lastRound = 5;
            }else if(currentTime > roundsTiming[7][1] && lastRound == 6){
                lastRound = 7;
            }
            currentRound = 0;
            return currentRound;
        }else{
            return 0;
        }
        
    }

    function getRoundTimes(uint256 _round) public view returns(uint256 start , uint256 end){
        if(_round == 0 || _round > 7){
            return (0 , 0);
        }
        if(presaleStarted == false){
            return (0 , 0);
        }
        return (roundsTiming[_round][0] , roundsTiming[_round][1]);
    }

    function getRoundLeftAmount(uint256 _round) public view returns(uint256){
        if(_round == 0 || _round > 7){
            return 0;
        }
        return (roundsMax[_round] - roundsFilled[_round]);
    }

    function getRoundData(uint256 _round) public view returns(uint256 start , uint256 end , uint256 filled, uint256 left, uint256 max , uint256 price){
        if(_round == 0 || _round > 7 || presaleStarted == false){
            return (0 , 0 , 0 , 0 , 0 , 0);
        }
        return (roundsTiming[_round][0] , roundsTiming[_round][1] , roundsFilled[_round] , (roundsMax[_round] - roundsFilled[_round]) , roundsMax[_round] , roundsPrices[_round]);
    }

    function getUserBought(uint256 _round , address _address) public view returns(uint256 amount){
            if(_round == 0){
            return usersTotalBought[_address];
        }else{
            return usersBought[_address][_round];
        }
    }

    function getRoundPrice(uint256 _round) public view returns(uint256){
        if(_round == 0 || _round > 7){
            return 0;
        }
        return roundsPrices[_round];
    }

    function getUnlockedPercent() public view returns(uint256 percent){
        if(presaleStarted == false){
            return 0;
        }
        uint256 i = 1;
        uint256 currentTime = block.timestamp;
        while(i <= 4){
            if(currentTime < unlockData[i][0]){
                return unlockData[i - 1][1];
            }
            i++;
        }
        return unlockData[4][1];
    }

    function getUnlockedData(uint256 _step) public view returns(uint256 , uint256){
        if((presaleStarted == false) || _step > 5){
            return (0 , 0);
        }
        return (unlockData[_step][0] , unlockData[_step][1]);
    }

    function updatePresaleValues(uint256 _flag , uint256 _value) external onlyOwner returns(bool){
        if(_flag == 0){
            referReward = _value;
            emit PresaleReferRewardChanged(_value);
        }else if(_flag >= 1 && _flag <= 7){
            require(_value > 0 , "round price could not be 0");
            roundsPrices[_flag] = _value;
            emit PresalePriceChanged(_flag , _value);
        }else if(_flag == 8){
            RoundBuyLimit = _value * (10 ** _decimals);
            emit PresaleBuyLimitChanged(_value * (10 ** _decimals));
        }else if( _flag == 9){
            roundsPeriod = _value * 60;
            emit PresalePeriodChanged(_value * 60);
        }else if( _flag == 10){
            LiquidityPercent = _value;
            emit PresaleReferRewardChanged(_value);
        }else{
            revert();
        }
        return true;
    }

    function changeBUSDReceiver(address _address) external onlyOwner {
        require(_address != DEAD && _address != address(0));
        BUSDReceiver = _address;
    }

    function claimBNB() public onlyOwner {
        require(address(this).balance > 0 , "no BNB balance in contract");
        payable(owner).transfer(address(this).balance);
    }
    
   function claimToken(address _token , uint256 _amount) public onlyOwner {
        uint256 _tokenBalance = IBEP20(_token).balanceOf(address(this));
        _amount = _amount * (10 ** IBEP20(_token).decimals());
        require(_tokenBalance > _amount , "no token balance in contract");
        if(_token == BUSD){
            uint256 unlockedAmount = _tokenBalance.sub(LockedForLiquidity);
            require(unlockedAmount >= _amount , "there is no unlocked BUSD token to claim");
            IBEP20(_token).transfer(owner , _amount);
        }else if(_token == address(this)){
            uint256 totalLockedToken = totalLockedTokens();
            require((_tokenBalance - totalLockedToken) >= _amount  , "there is no unlocked tokens to claim");
            _balances[address(this)] =  _balances[address(this)].sub(_amount , "there is no unlocked tokens to claim");
            _balances[owner] =  _balances[owner] + _amount;
        }else{
            IBEP20(_token).transfer(owner , _amount);
        }
    }
     
    function addPresaleLiquidity() external onlyOwner {
        require(LockedForLiquidity > 0 , "there is no tokens for liquidity");
        approve(address(router) , balanceOf(address(this)));
        IBEP20(BUSD).approve(address(router) , LockedForLiquidity);
        ( uint amountA , uint amountB, ) = router.addLiquidity(
            address(BUSD),
            address(this),
            LockedForLiquidity,
            balanceOf(address(this)),
            LockedForLiquidity,
            0,
            address(this),
            block.timestamp
        );

        if(firstLiquidityProvide == true){
            liquidityUnlockTime = block.timestamp + (60 * 60 * 24 * 365);
            firstLiquidityProvide = false;
        }

        emit AutoLiquify(LockedForLiquidity, amountB);
        LockedForLiquidity = LockedForLiquidity -  amountA;
    }

    function provideLiquidity(uint256 tokenAmount , uint256 busdAmount)  external onlyOwner {
        require(tokenAmount > 0 && busdAmount > 0 , "token and busd amount should be bigger than 0");
        tokenAmount = tokenAmount * (10 ** _decimals);
        busdAmount = busdAmount * (10 ** _decimals);
        if(initialLiquidity == false){
            tokenAmount = balanceOf(address(this));
        }else{
            initialLiquidity = false;
        }
        approve(address(router) , balanceOf(address(this)));
        IBEP20(BUSD).approve(address(router) , tokenAmount);
        ( , uint256 amountB,  ) = router.addLiquidity(
            address(BUSD),
            address(this),
            busdAmount,
            tokenAmount,
            busdAmount,
            0,
            address(this),
            block.timestamp
        );
        emit AutoLiquify(busdAmount, amountB);
    }

    function updateLockTime(uint256 _second) external onlyOwner {
        liquidityUnlockTime = liquidityUnlockTime + _second;
    }

    function lockTokens(uint256 _amount , uint256 _seconds) external onlyOwner{
        _amount = _amount * (10 ** _decimals);
        tokensLocked.push([_amount , block.timestamp + _seconds]);     
    }
 
    function getLiquidity() external onlyOwner{
        require(block.timestamp > liquidityUnlockTime && liquidityUnlockTime != 0 , "liquidity has not unlocked!");
        uint256 liquidityAmount = IBEP20(BUSDpair).balanceOf(address(this));
        IBEP20(BUSDpair).approve(address(this) , liquidityAmount);
        IBEP20(BUSDpair).transfer(owner , liquidityAmount);
    }

    function totalLockedTokens() public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 totalLockedToken = 0;
        for(uint256 i=0; i < tokensLocked.length; i++){
            if(currentTime < tokensLocked[i][1]){
                totalLockedToken = totalLockedToken + tokensLocked[i][0];
            }
        }
        return totalLockedToken;
    }

    event AutoLiquify(uint256 amountBUSD, uint256 amountToken);
    event PresalePriceChanged(uint256 round, uint256 price);
    event PresalePeriodChanged(uint256 period);
    event PresaleBuyLimitChanged(uint256 amount);
    event PresaleLiquidityPercentChanged(uint256 Percent);
    event PresaleReferRewardChanged(uint256 Percent);

}