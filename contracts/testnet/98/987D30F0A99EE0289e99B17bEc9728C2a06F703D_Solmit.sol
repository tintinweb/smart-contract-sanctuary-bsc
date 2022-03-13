/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity ^0.8.5;
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
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public PANCAKE_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    string constant _name = "Solmit";
    string constant _symbol = "SOM";
    uint8 constant _decimals = 18;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) _balances;
    uint256 constant _totalSupply = 2000000000 * (10 ** _decimals);

    uint16 public referReward = 30;
    uint256 public RoundBuyLimit = (1000000 * (10 ** _decimals));
    uint256 public roundsPeriod = 30 * 24 * 60 * 60;
    uint8 public lastRound = 0;
    uint8 public currentRound = 0;

    // presale
    // 
    mapping (address => mapping (uint8 => uint256)) usersBought;
    mapping (uint256 => uint256) roundsFilled;
    uint256[] roundsPrices;
    uint256[] roundsMax;
    uint256[][] roundsTiming;
    uint256[][]  unlockData;
    
    IDEXRouter public router;
    address public pair;


    constructor () Auth(msg.sender) {
        router = IDEXRouter(PANCAKE_ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;        
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);        

        // set default rounds prices and maximum
        roundsPrices = [0 , 100 * (10 ** _decimals) , 67  * (10 ** _decimals) , 50  * (10 ** _decimals) , 40  * (10 ** _decimals) , 33  * (10 ** _decimals) , 0 , 0];

        // set 0
        roundsMax.push(0);
        uint8 i = 1;
        while (i <= 7) {
            if(i <= 5){
                roundsMax.push(14000000 * (10 ** _decimals));
            }else{
                roundsMax.push(150000000 * (10 ** _decimals));
            }
            i++;
        }

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
        updateAndReturnCurrentRound();
        uint256 lockedTokens = 0;
        uint256 totalBought = getUserBought(0 , msg.sender);
        uint256 percent = getUnlockedPercent();
        if(totalBought > 0){
            lockedTokens = totalBought - (totalBought.mul(percent).div(100));
        }
        _balances[sender] = _balances[sender].sub(amount + lockedTokens, "Insufficient Balance");
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

        // set unlock percents time
        unlockData.push([0 , 0]);
        unlockData.push([currentTime + (roundsPeriod * 5) + roundsPeriod , 25]);
        unlockData.push([currentTime + (roundsPeriod * 5) + roundsPeriod , 50]);
        unlockData.push([currentTime + (roundsPeriod * 5) + roundsPeriod , 75]);
        unlockData.push([currentTime + (roundsPeriod * 5) + roundsPeriod , 100]);
    }

    function buy(uint256 _amount , address _refer) public returns(bool){
        uint256 _token = _amount.mul(roundsPrices[uint256(currentRound)]);
        uint256 userBought = getUserBought(currentRound , msg.sender);
        require(updateAndReturnCurrentRound() != 0 , "PRESALE NOT STARTED");
        require(_amount  > 0 , "buy amount should be biger than 0");
        require(_token + userBought <= RoundBuyLimit , "You have reached maximum wallet buy amount for this round");
        require(IBEP20(BUSD).balanceOf(msg.sender) >= _amount , "not enough balance");
        require(getRoundLeftAmount(currentRound) >= _amount  , "buy amount is more than rounds left amount");
        bool status = IBEP20(BUSD).transferFrom(msg.sender , address(this) , _amount);
        require(status == true);

        if(_refer != address(0) && _refer != DEAD){
            uint256 referTokens = _token.mul(referReward).div(1000);
            _transferFrom(address(this), _refer, referTokens);
            emit Transfer(address(this), _refer, referTokens);
        }
        _transferFrom(address(this), msg.sender, _token);
        roundsFilled[currentRound] = roundsFilled[currentRound] + _token; 
        usersBought[msg.sender][currentRound] = userBought + _token;
        emit Transfer(address(this), msg.sender, _token);
        return true;
    }


    function startSpecialRounds(uint256 _round6 , uint256 _round7) external onlyOwner returns(bool){
        uint256 currentTime = block.timestamp;
        require(_round7 > 0 && _round6 > 0 , "rounds price could not be 0");

        roundsTiming[6] = ([ currentTime,  currentTime + (roundsPeriod )]);
        roundsTiming[7] = ([ currentTime + (roundsPeriod) + 1 ,  currentTime + (roundsPeriod * 2)]);

        roundsPrices[6] = _round6 * (10 ** _decimals);
        roundsPrices[7] = _round7 * (10 ** _decimals);
        return true;
    }

    function updateAndReturnCurrentRound() public returns(uint8 round){
        uint8 i = 1;
        uint256 currentTime = block.timestamp;
        while(i <= 7){
            if(currentTime > roundsTiming[i][0] && currentTime < roundsTiming[i][1]){
                if(currentRound != 0){
                    lastRound = currentRound;
                }
                currentRound = i;
                return currentRound;
            }
        }
        
        if(currentTime > roundsTiming[5][1] && lastRound == 4){
            lastRound = 5;
        }else if(currentTime > roundsTiming[7][1] && lastRound == 6){
            lastRound = 7;
        }

        currentRound = 0;
        return currentRound;
    }

    function getRoundTimes(uint8 _round) public view returns(uint256 start , uint256 end){
        require(_round != 0 && _round <= 7 , "wrong round");
        require(currentRound != 0 || lastRound != 0 , "presale not started");
        return (roundsTiming[_round][0] , roundsTiming[_round][1]);
    }

    function getRoundLeftAmount(uint8 _round) public view returns(uint256){
        require(_round != 0 && _round <= 7 , "wrong round");
        return (roundsMax[_round] - roundsFilled[uint256(_round)]);
    }

    function getRoundMaxAmount(uint8 _round) public view returns(uint256){
        require(_round != 0 && _round <= 7 , "wrong round");
        return roundsMax[_round];
    }

    function getRoundFilledAmount(uint256 _round) public view returns(uint256){
        require(_round != 0 && _round <= 7 , "wrong round");
        return roundsFilled[_round];
    }

    function getUserBought(uint8 _round , address _address) public view returns(uint256 amount){
        if(_round == 0){
            uint8 i = 1;
            uint256 totalBought = 0;
            while(i <= 7){
                totalBought = totalBought + usersBought[_address][i];
            }
            return totalBought;
        }else{
            return usersBought[_address][_round];
        }
    }

    function getRoundPrice(uint8 _round) public view returns(uint256){
        require(_round != 0 && _round <= 7 , "wrong round");
        return roundsPrices[_round];
    }

    function getUnlockedPercent() public view returns(uint256 percent){
        if(currentRound == 0 && lastRound == 0){
            return 0;
        }
        uint8 i = 1;
        uint256 currentTime = block.timestamp;
        uint256 unlockedPercent = 0;
        while(i <= 7){
            if(currentTime > unlockData[i][0]){
                unlockedPercent = unlockData[i][1];
            }
        }
        return unlockedPercent;
    }

    function getUnlockedData(uint8 _step) public view returns(uint256 , uint256){
        require(_step <= 5 , "wrong step");
        return (unlockData[_step][0] , unlockData[_step][1]);
    }

    function updatePresaleValues(uint8 _flag , uint256 _value) external onlyOwner returns(bool){
        if(_flag == 0){
            referReward = uint16(_value) * 10;
        }else if(_flag >= 1 && _flag <= 7){
            require(_value > 0 , "round price could not be 0");
            roundsPrices[_flag] = _value * (10 ** _decimals);
        }else if(_flag == 8){
            RoundBuyLimit = _value * (10 ** _decimals);
        }else if( _flag == 9){
            roundsPeriod = _value * 60 * 60;
        }else{
            revert();
        }
        return true;
    }
}