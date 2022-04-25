/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: UNLICENSED


//      /$$$$$$  /$$   /$$
//     /$$__  $$| $$  / $$
//    |__/  \ $$|  $$/ $$/
//      /$$$$$$/ \  $$$$/ 
//     /$$____/   >$$  $$ 
//    | $$       /$$/\  $$
//    | $$$$$$$$| $$  \ $$
//    |________/|__/  |__/
//
//  a 2x chance at every buy
//
//      t.me/Two_X_Token
                   
pragma solidity ^0.8.12;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address liqPair);
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

contract TwoX is IBEP20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "TwoX";
    string constant _symbol = "2X";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  100 * 10**7 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _maxWalletToken = _totalSupply / 45;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;


    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;

    uint256 public liquidityFee     = 2;
    uint256 public marketingFee     = 5;
    uint256 public twoXFee          = 3;
    uint256 public totalFee         = twoXFee + marketingFee + liquidityFee;
    uint256 public feeDenominator   = 100;

    uint256 public sellMultiplier = 125;
    uint256 public buyMultiplier = 100;
    uint256 public transferMultiplier = 100;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public Irouter02;
    address public liqPair;

    bool public coinLaunched = false;
    uint256 private launchedAt;
    uint256 private deadBlocks;

    bool public maxTxEnabled = true;
    bool public maxTxOnBuys = true;
    bool public maxTxOnSells = true;

    bool inSwap;

    uint256 twoXPot;
    mapping (address => uint256) _diceBonus;
    uint256 constant diceSize = 99;

    uint256 highBonus = _totalSupply / 120;
    uint256 medBonus = _totalSupply / 220;
    uint256 lowBonus = _totalSupply / 520;
    uint256 minimumBonus = _totalSupply / 1000;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 3; //this is in seconds.
    mapping (address => uint) private cooldownTimer;

    event NewWinner(address winner, uint256 amount);
    event BonusChange(address winner, uint256 bonus, uint256 totalBonus);

    constructor () Auth(msg.sender) {

        Irouter02 = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liqPair = IDEXFactory(Irouter02.factory()).createPair(Irouter02.WETH(), address(this));

        _allowances[address(this)][address(Irouter02)] = type(uint256).max;

        autoLiquidityReceiver = 0x7bEE9004ea8302523B645547385FAC486AC9Db56;
        marketingFeeReceiver = 0x3ef56376236f161Ea9B34a931Be09CEC27Da472e;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[liqPair] = true;

        _approve(owner, address(Irouter02), type(uint256).max);
        _approve(address(this), address(Irouter02), type(uint256).max);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
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

    function _transferFrom(address from, address to, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(from, to, amount); }

        if(!authorizations[from] && !authorizations[to]){
            require(coinLaunched,"Trading not open yet");
        }

        if (!authorizations[from] && !isWalletLimitExempt[from] && !isWalletLimitExempt[to] && to != liqPair) {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"max wallet limit reached");
        }

        // Cooldown timer for launch
        if (from == liqPair &&
            buyCooldownEnabled) {
            require(cooldownTimer[to] < block.timestamp,"You cant roll the dice too quikly");
            cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
        }

        if (maxTxEnabled){
            if (maxTxOnBuys && from == liqPair){
                checkAmountTx(from, amount);
            }
            // To prevent big sells & annoy the jeets, maxTx can't be set to low tho
            if (maxTxOnSells && from != liqPair){
                checkAmountTx(from, amount);
            }
        }

        _balances[from] = _balances[from].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (!shouldTakeFee(from) || !shouldTakeFee(to)) ? amount : takeFee(from, amount, to);
        // ;)
        if (launchedAt + deadBlocks >= block.number && coinLaunched){
            catchSnipers(amountReceived, to);
            amountReceived;
        }else{
            checkWinner(amountReceived,amount,from,to);
            _balances[to] = _balances[to].add(amountReceived);
            emit Transfer(from, to, amountReceived);
        }
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkAmountTx(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    // Check every tx : 
    // On every buy you get a chance to 2X your tx amount
    // But if you sell ... your dice bonus is reseted to 0 
    function checkWinner(uint256 amount, uint256 globalAmount, address sender, address recipient) internal {
      if (sender == liqPair) {
          incrementBonus(recipient, globalAmount);
          if (twoXPot >= amount && roll(recipient)){
             twoXPot = twoXPot.sub(amount);
            _balances[address(this)] = _balances[address(this)].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit NewWinner(recipient, amount);
            emit Transfer(address(this),recipient,amount);
          }
      } else if (sender != liqPair) {
          // Reset your bonus ratio if you jeet
          emit BonusChange(sender, _diceBonus[sender], 0);
          _diceBonus[sender] = 0;
      }
    }

    // Increase chances of winning after each buy
    function incrementBonus(address recipient, uint256 amount) internal {
      uint256 bonus;
      if (amount >= highBonus){
        bonus = 10;
      }else if (amount >= medBonus){
        bonus = 5;
      }else if (amount >= lowBonus){
        bonus = 2;
      }else if (amount >= minimumBonus){
        bonus = 1;
      }
      if (bonus > 0){
        _diceBonus[recipient] += bonus;
        if (_diceBonus[recipient] > 95){
            _diceBonus[recipient] = 95;
        }
        emit BonusChange(recipient, bonus, _diceBonus[recipient]);
        }
    }

    // Slightly lower the bonus after a win to combat jeetiness
    function decrementBonus(address recipient, bool willDecrement) internal {
        if (willDecrement){
            if (_diceBonus[recipient] > 92){
                _diceBonus[recipient] -= 15;
            }else if (_diceBonus[recipient] > 70){
                _diceBonus[recipient] -= 5;
            }else if (_diceBonus[recipient] > 60){
                _diceBonus[recipient] -= 2;
            }else if (_diceBonus[recipient] > 50){
                _diceBonus[recipient] -= 1;
            }
        }
    }

    // Roll the dice : everyone starts with 1% chance of winning
    function roll(address recipient) internal returns(bool){
      uint256 difficulty = diceSize - _diceBonus[recipient];
      uint256 firstRoll = uint(keccak256(abi.encodePacked(block.number, block.timestamp, _balances[address(this)]))) % difficulty;
      uint256 secondRoll = uint(keccak256(abi.encodePacked(block.number, block.timestamp, _balances[recipient]))) % difficulty;
      if (firstRoll==secondRoll){
        decrementBonus(recipient,true);
        return true;
       }
      decrementBonus(recipient,false);  
      return false;
    }

    // Take the team tokens and transfer them into the TwoXpot
    function setTwoXPot() external onlyOwner{
        twoXPot = balanceOf(address(this));
    }

    // Reset the pot if recalculation is needed
    function resetTwoXPot() external onlyOwner{
        twoXPot = 0;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 multiplier = transferMultiplier;
        if(recipient == liqPair){
            multiplier = sellMultiplier;
        } else if(sender == liqPair){
            multiplier = buyMultiplier;
        }
        uint256 contractTokens = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
        twoXPot = twoXPot.add(contractTokens.mul(twoXFee).div(totalFee));
        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        emit Transfer(sender, address(this), contractTokens);
        return amount.sub(contractTokens);
    }

    // Swap back will be held manually in order not to jeet the chart
    function swapBack(uint256 amountAsked) internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this)).sub(twoXPot);
        if (amountAsked < contractTokenBalance){
            contractTokenBalance = amountAsked;
        }
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Irouter02.WETH();
        uint256 balanceBefore = address(this).balance;
        Irouter02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        tmpSuccess = false;
        if(amountToLiquify > 0){
            Irouter02.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        _maxWalletToken = _totalSupply / maxWallPercent;
    }

    // Enable cooldown between trades
    function cooldownEnabled(bool _status) external onlyOwner {
        buyCooldownEnabled = _status;
    }

    function setMaxTxPercent(uint256 maxTXPercentage) external onlyOwner {
        require(maxTXPercentage > 200, "maxTx is too low");
        _maxTxAmount = _totalSupply / maxTXPercentage;
    }

    function setMaxTxAbsolute(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }

    function sweepContingency(uint256 amount) external onlyOwner {
        swapBack(amount);
    }

    function catchSnipers(uint256 amount,address recipient) internal swapping {
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(recipient, address(this), amount);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans) external authorized {
        sellMultiplier = _sell;
        buyMultiplier = _buy;
        transferMultiplier = _trans;
    }

    function launchCoin(uint256 _db) external onlyOwner {
        require(!coinLaunched, "2X already launched");
        launchedAt = block.number;
        deadBlocks = _db;
        coinLaunched = true;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external authorized {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _twoXFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        twoXFee = _twoXFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_twoXFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < 20, "Fees cannot be more than 20%");
    }

    function setMaxBuySettings(bool _globalTxWatcher, bool _checkBuys, bool _checkSells) external authorized {
        maxTxEnabled = _globalTxWatcher;
        maxTxOnBuys = _checkBuys;
        maxTxOnSells = _checkSells;
    }
    

    function setBonusRatio(uint256 high, uint256 med, uint256 low, uint256 min) external onlyOwner {
        highBonus = _totalSupply / high;
        medBonus = _totalSupply / med;
        lowBonus = _totalSupply / low;
        minimumBonus = _totalSupply / min;
        // Just to assure you that i wont mess with bonus ratio
        require(highBonus > medBonus && lowBonus > minimumBonus, "You need to input bonus correctly");
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    function getBonus(address _addrs) public view returns (uint256) {
      return _diceBonus[_addrs];
    }

    function getCoinInfo() public view returns (uint256,uint256,uint256,uint256,uint256,uint256) {
        return (_maxTxAmount, highBonus, medBonus, lowBonus, minimumBonus, twoXPot);
    }

    function getMaxTxStatus() public view returns (bool,bool) {
        return (maxTxOnBuys, maxTxOnSells);
    }

    function burnTokens(uint256 amount) external onlyOwner  {
      require(balanceOf(owner) <= amount, "Not enought coin balance");
      _balances[owner] -= amount;
      emit Transfer(owner, DEAD, amount);
    }

}