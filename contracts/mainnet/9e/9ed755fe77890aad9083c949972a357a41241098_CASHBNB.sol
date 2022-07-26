/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

/*
CASHBNB - NO LOSS LOTTERY TOKEN WITH BNB REWARDS
HOLD CASHBNB EARN BNB IT'S THAT SIMPLE

https://www.cashbnb.win

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
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

/* Standard IDEXFactory */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/* Standard IDEXRouter */
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

/* Interface for the DividendDistributor */
interface DividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address shareholder) external;
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
    function calculLotteryPrizeToWin(uint256 lotteryBalance, uint256 winnerBalance) external view returns (uint256);
    function lotInterval() external view returns (uint256);
}

/* Token contract */
contract CASHBNB is IBEP20 {
    using SafeMath for uint256;

    // Addresses
    address distributorAddress;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address private _owner;

    // These are owner by default
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    // Name and symbol
    string constant _name = "CASHBNB";
    string constant _symbol = "CASHBNB";
    uint8 constant _decimals = 18;

    // Total supply
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    // Max wallet and TX
    uint256 public _maxTxAmount =  _totalSupply * 200  / 10000; // 2%

    // Mappings
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isLotteryExempt;
    mapping (address => bool) isDividendExempt;

    // Lottery
    address [] public _lotteryPlayers;
    mapping (address => uint256) public _lotteryPlayersIndexes;
    mapping (address => bool) public _isInLottery;

    uint256 public lotteryBalance;

    uint256 public lotteryPrize = 2 * 10 ** 18; // 2BNB
    uint256 public minLotteryPrize  = 0.01 * 10 ** 18; // 0.01BNB
    uint256 public minHoldLottery = 20000 * 10 ** 18;
    address public lastLotteryWinner = ZERO;
    uint256 public lastPotWin = 0;
    uint256 public lastLotteryDraw;
    uint256 public lotteryInterval = 14400;

    struct LotteryWinners {
        uint256 time;
        uint256 amount;
        address winner;
    }

    LotteryWinners[] public _lotteryWinners;

    // Fee variables
    uint256 liquidityFee = 200;
    uint256 marketingFee = 500;
    uint256 lotteryFee = 500;
    uint256 reflectionFee = 300;
    uint256 totalFee = 1500;
    uint256 feeDenominator = 10000;

    // Max amount of tokens when a sell takes place
    uint256 public swapThreshold = _totalSupply * 30 / 10000; // 0.3% of supply

    // Liquidity
    uint256 liquidityBalance;
    uint256 _lastAddLiquidityTime;

    DividendDistributor distributor;
    uint256 distributorGas = 300000;

    // Other variables
    IDEXRouter public router;
    address public pair;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    /* Token constructor */
    constructor (address _distributorAddress) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributorAddress = _distributorAddress;
        distributor = DividendDistributor(distributorAddress);

          _owner = msg.sender;
        isFeeExempt[_owner] = true;

        // Exempt from dividend
        isDividendExempt[_owner] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isLotteryExempt[_owner] = true;
        isLotteryExempt[pair] = true;
        isLotteryExempt[address(this)] = true;
        isLotteryExempt[DEAD] = true;
        isLotteryExempt[ZERO] = true;


        // Set the marketing and liq receiver to the owner as default
        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function renounceOwnership() public virtual {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    // Main transfer function
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != _owner && recipient != _owner && recipient != pair)
            require(balanceOf(recipient) + amount <= _maxTxAmount, "Transfer amount exceeds the maxWallet.");


        // Check if we should add liquidity
        if(shouldAddLiquidity()){ addLiquidity(); }

        // Check if we should do the swapback
        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isLotteryExempt[sender] && _isInLottery[sender] && (_balances[sender] < minHoldLottery)) {
          removePlayerFromLottery(sender);
        }

        if(!isLotteryExempt[recipient] && !_isInLottery[recipient] && (_balances[recipient] >= minHoldLottery)) {
          addPlayerToLottery(recipient);
        }

        if(lotteryBalance >= lotteryPrize && block.timestamp >= lastLotteryDraw.add(lotteryInterval)){
          drawLotteryWinner();
        }

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    // Do a normal transfer
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Check if sender is not feeExempt
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    // Take Fees
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        liquidityBalance = liquidityBalance.add(amount.mul(liquidityFee).div(feeDenominator));

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function addPlayerToLottery(address holder) internal{
      _lotteryPlayersIndexes[holder] = _lotteryPlayers.length;
      _lotteryPlayers.push(holder);
      _isInLottery[holder] = true;
    }

    function removePlayerFromLottery(address holder) internal{
      _lotteryPlayers[_lotteryPlayersIndexes[holder]] = _lotteryPlayers[_lotteryPlayers.length-1];
      _lotteryPlayersIndexes[_lotteryPlayers[_lotteryPlayers.length-1]] = _lotteryPlayersIndexes[holder];
      _lotteryPlayers.pop();
      _isInLottery[holder] = false;
    }

    function random() internal view returns (uint256){
        uint256 rdn = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    _balances[address(this)] +
                    address(this).balance
                )
            )
        );
        return rdn;
    }

    function drawLotteryWinner() internal {
      address winningAddress = _lotteryPlayers[random() % _lotteryPlayers.length];
      rewardWinner(winningAddress);
    }


    function rewardWinner(address winner) internal{
        uint256 potSizeWon = distributor.calculLotteryPrizeToWin(lotteryBalance,_balances[winner]);
        (bool successPayedWinner, /* bytes memory data */) = payable(winner).call{value: potSizeWon, gas: 30000}("");
        if(successPayedWinner){
          lotteryBalance = lotteryBalance.sub(potSizeWon);
          lastLotteryWinner = winner;
          lastPotWin = potSizeWon;
          lastLotteryDraw = block.timestamp;
          LotteryWinners memory lotteryWinners;
          lotteryWinners.time = block.timestamp;
          lotteryWinners.amount = potSizeWon;
          lotteryWinners.winner = winner;
          _lotteryWinners.push(lotteryWinners);

          emit LotteryWin(winner, potSizeWon);
        }
      }

    // Check if we should sell tokens
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && _balances[address(this)].sub(liquidityBalance) > 0;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            !inSwap &&
            msg.sender != pair &&
            liquidityBalance > 0 &&
            block.timestamp >= (_lastAddLiquidityTime + 360 minutes);
    }

    // Main swapback to sell tokens for WBNB
    function swapBack() internal swapping {
        uint256 amountToSwap = _balances[address(this)].sub(liquidityBalance) > swapThreshold ? swapThreshold : _balances[address(this)].sub(liquidityBalance);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        lotteryBalance = lotteryBalance.add(amountBNB.mul(lotteryFee).div(totalFee.sub(liquidityFee)));


        try distributor.deposit{value: amountBNB.mul(reflectionFee).div(totalFee.sub(liquidityFee))}() {} catch {}

        payable(marketingFeeReceiver).transfer(amountBNB.mul(marketingFee).div(totalFee.sub(liquidityFee)));
    }

    function addLiquidity() internal swapping {

        uint256 amountLiquidity = liquidityBalance > swapThreshold ? swapThreshold : liquidityBalance;
        uint256 amountToLiquify = amountLiquidity.div(2);
        uint256 amountToSwap = amountLiquidity.sub(amountToLiquify);


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNBLiquidity = address(this).balance.sub(balanceBefore);

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            liquidityBalance = liquidityBalance.sub(amountLiquidity);
            _lastAddLiquidityTime = block.timestamp;
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

    }

    function syncLotteryInterval() external  {
      require(distributor.lotInterval() <= 86400,"At least one draw/day");
      lotteryInterval = distributor.lotInterval();
    }

    function addInLotteryBalance() external {
        uint256 contractBNBBalance = address(this).balance.sub(lotteryBalance);
        lotteryBalance = lotteryBalance.add(contractBNBBalance);
    }

    function transferForeignToken(address _token) external {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(marketingFeeReceiver).transfer(_contractBalance);
    }

    // Let people claim there dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder) external view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    }
    
    function manualSwapBack() external {
        // Check if we should do the swapback
        if(shouldSwapBack()){ swapBack(); }
    }

    function totalPlayers() external view returns (uint256){
        return _lotteryPlayers.length;
    }

    function calculMinLotteryPrizeToWin(address player) external view returns (uint256){
        uint256 actualPrize = lotteryBalance;
        if(actualPrize < lotteryPrize){
            actualPrize = lotteryPrize;
        }
        return distributor.calculLotteryPrizeToWin(actualPrize,_balances[player]);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountCASHBNB);
    event LotteryWin(address indexed winner, uint256 potSizeWon);
}