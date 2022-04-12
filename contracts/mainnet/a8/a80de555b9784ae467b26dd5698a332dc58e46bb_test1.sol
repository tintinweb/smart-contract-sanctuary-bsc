/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
}

/*
 * interfaces from here
 */


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IPancakeSwapPair {
    function skim(address to) external;
}

/*
 * interfaces to here
 */
 
contract test1 {
    using SafeMath for uint256;
    
    uint public _uptest;
    
    address public _owner; // constant
    
    address public _token; // constant
    address public _myRouterSystem; // constant
    address public _stakeSystem; // constant
    address public _rewardSystem; // constant
    address public _projectFund; // constant
    address public _rewardToken; // constant

    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    
    address public _uniswapV2Router; // constant
    address public _uniswapV2Pair; // constant

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;

    uint public _liquidityFee; // fixed
    uint public _improvedRewardFee; // fixed
    uint public _projectFundFee; // fixed
    uint public _dipRewardFee; // fixed
    uint public _manualBuyFee; // fixed    
    uint public _autoBurnFee; // fixed
    uint public _redistributionFee; // fixed

    uint public _priceRecoveryFee; // fixed
    uint private PRICE_RECOVERY_ENTERED;

    uint public _isLaunched;

    uint public _minReservesAmount;
    uint public _curReservesAmount;
    
    uint public _rewardTotalBNB;
    mapping (address => uint) public _adjustBuyBNB;
    mapping (address => uint) public _adjustSellBNB;

    mapping (address => uint256) public _buySellTimer;
    uint public _buySellTimeDuration; // fixed
    
    uint public _lastLpSupply;
    
    mapping (address => bool) public _blacklisted;
    
    uint public DAY; // constant
    uint public _accuMulFactor; // fixed

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;

    uint public _curcuitBreakerFlag;
    uint public _curcuitBreakerTime;
    
    address public _freeAirdropSystem; // constant
    address public _airdropSystem; // constant
    mapping (address => uint) public _airdropTokenLocked;
    uint public _airdropTokenUnlockTime;
   
    uint public _firstPenguinWasBuy; // fixed
    mapping (address => uint) public _lifeSupports;
    mapping (address => uint) public _monitors;

    address public _liquifier;
    address public _stabilizer;
    address public _treasury;
    address public _blackHole;

    uint256 public _liquifierFee;
    uint256 public _stabilizerFee;
    uint256 public _treasuryFee;
    uint256 public _blackHoleFee;
    uint256 public _moreSellFee;

    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    uint256 public _lastLiqTime;

    bool public _rebaseStarted;

    bool private inSwap;
    bool private _pause;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockNumber, uint256 totalSupply);



    fallback() external payable {}
    receive() external payable {}
    
    
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier limited() {
        require(_owner == msg.sender, "limited usage");
        _;
    }

    function initialize() public {
        _owner = address(0x33A39eB4834eF3dAFA8187e3DAED4c2377150a2c);

        _name = "test1";
        _symbol = "t1";
        _decimals = 18;
    }

    function runInit() external limited {

        {
          _uniswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
          _uniswapV2Pair = IUniswapV2Factory(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
          .createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
        }

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 100 * 10**3 * 10**_decimals; // 100,000 $test1
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**4; // 1,000,000,000 $test1 (x10000)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        _owner = address(0x33A39eB4834eF3dAFA8187e3DAED4c2377150a2c);

        _liquifier = address(0x164731b3576A5c582fC590Af4BdC8dd1B87944D7);
        _stabilizer = address(0xA5f1656Dd1FeF1dB46e215154A61CC2D50966fFa);
        _treasury = address(0xA03fE981DEC99B6eB010dE4ab53A3bd09a354372);
        _blackHole = address(0x000000000000000000000000000000000000dEaD);
        
        // deno = 10000
        _liquifierFee = 400;
        _stabilizerFee = 500;
        _treasuryFee = 300;
        _blackHoleFee = 200;
        _moreSellFee = 200;

        _allowances[address(this)][_uniswapV2Router] = MAX;

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        _tOwned[_owner] = _rTotal;
        emit Transfer(address(0x0), _owner, _rTotal.div(_frag));

        _initRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _lifeSupports[_owner] = 2;
        _lifeSupports[_stabilizer] = 2;
        _lifeSupports[_treasury] = 2;
        _lifeSupports[address(this)] = 2;

    }
    
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }

    function startRebase() external limited {
        _rebaseStarted = true;
    }

    function manualRebase() external {
        _rebase();
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account].div(_frag);
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount); 
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        _specialTransfer(from, to, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function antiBotSystem(address target) internal {
        if (target == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) { // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) { // Pair can do in sequence
            return;
        }
            
        require(_buySellTimer[target] + 60 <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; ///////////////////// NFT values
    }

    function _getImpact(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = x_.mul(10000); // to make it based on 10000 multi
        uint deno = r1_.add(x_);
        uint impact = nume / deno;
        
        return impact;
    }
    
    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = uint(10000).sub(priceChange);
        
        return priceChange;
    }

    function _getLiquidityImpact(uint r1, uint amount) internal pure returns (uint) {
        if (r1 == 0) {
          return 0;
        }

        if (amount == 0) { 
          return 1;
        }

        uint impact = _getImpact(r1, amount);
        
        return impact;
    }

    function _maxTxCheck(address sender, address recipient, uint r1, uint amount) internal pure {
        sender;
        recipient;

        uint impact = _getLiquidityImpact(r1, amount);
        if (impact <= 1) {
          return;
        }

        require(impact <= 1000, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    }

    function sanityCheck(address sender, address recipient, uint256 amount) internal returns (uint) {
        sender;
        recipient;

        if (_blacklisted[sender]) {
            uint punishAmount = amount.mul(9999).div(10000);
            _tokenTransfer(sender, address(this), punishAmount);
            amount = amount.sub(punishAmount); // bot will get only 0.01% 
        }

        return amount;
    }

    function _specialTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            (amount == 0) ||

            inSwap ||
            
            (_lifeSupports[sender] == 2) || // sell case
            (_lifeSupports[recipient] == 2) // buy case
            ) {
            _tokenTransfer(sender, recipient, amount);

            return;
        }

        address pair = _uniswapV2Pair;
        uint r1 = balanceOf(pair); // liquidity pool

        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) { // not buy, remove liq, etc
          _rebase();
        }

        uint autoBurnEthAmount;
        if (sender != pair) { // not buy, remove liq, etc    
            {
                autoBurnEthAmount = _swapBack(r1);
                _buyBack(autoBurnEthAmount);
            }
        }

        if (recipient == pair) { // sell, add liq, etc
          antiBotSystem(sender);
          if (sender != msg.sender) {
            antiBotSystem(msg.sender);
          }
          if (sender != recipient) {
            if (msg.sender != recipient) {
              antiBotSystem(recipient);
            }
          }
        }

        if (sender != pair) { // not buy, remove liq, etc    
          _addBigLiquidity(r1);
          amount = sanityCheck(sender, recipient, amount);
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {

            fAmount = _takeFee(sender, recipient, r1, fAmount);
        }
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);
        emit Transfer(sender, recipient, fAmount.div(_frag));

        return;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
        uint fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);

        emit Transfer(sender, recipient, amount); // fAmount.div(_frag)

        return;
    }





    function _rebase() internal {
        if (inSwap) {
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }

        if (!_rebaseStarted) {
            return;
        }

   
        if (_MAX_TOTAL_SUPPLY <= _tTotal) {
            return;
        }

        // Rebase Adjusting System
        // save gas: will be done by yearly upgrade

        uint deno = 10**6 * 10**18;
        uint rebaseRate = 88 * 10**18;
        uint minuteRebaseRate = 1760 * 10**18; 
        uint hourRebaseRate = 105654 * 10**18; 
        uint dayRebaseRate = 2566745 * 10**18;
        // 1.00000088**20 = 1.00001760
        // 1.00001760**60 = 1.00105654
        // 1.00105654**24 = 1.02566745

        // FASTEST AUTO-COMPOUND: 0.000088% per block (3 seconds)
        // HIGHEST APY: 1041035% APY
        uint blockCount = block.number.sub(_lastRebaseBlock);
        uint tmp = _tTotal;
        for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
            tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
            tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
            tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
            tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
        }

        _tTotal = tmp;
        _frag = _rTotal.div(tmp);
        _lastRebaseBlock = block.number;

        IPancakeSwapPair(_uniswapV2Pair).skim(address(this)); // do only in sell case?

        emit Rebased(block.number, _tTotal);
    }

    function _swapBack(uint r1) internal returns (uint) {
        if (inSwap) { // this could happen later so just in case
            return 0;
        }

        if (r1 == 0) {
            return 0;
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { // nothing to swap
          return 0;
        }

        uint swapAmount = fAmount.div(_frag);
        if (r1.mul(100).div(10000) < swapAmount) {
           swapAmount = r1.mul(100).div(10000);
        }
        
        uint ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee.add(_moreSellFee); // handle sell case
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.div(2).add(stabilizerFee).add(treasuryFee).add(blackHoleFee);

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee));
        
        uint autoBurnEthAmount = ethAmount.mul(blackHoleFee).div(totalFee);

        return autoBurnEthAmount;
    }

    function _buyBack(uint autoBurnEthAmount) internal {
        if (autoBurnEthAmount == 0) {
          return;
        }

        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _blackHole); // user?
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _blackHole);
    }

    function _addBigLiquidity(uint r1) internal { // should have _lastLiqTime but it will update at start
        r1;
        if (block.number < _lastLiqTime.add(20 * 60 * 24)) { // 20 * 60 * 24 CHANGE THIS!
            return;
        }

        if (inSwap) { // this could happen later so just in case
            return;
        }

        uint liqBalance = _tOwned[_liquifier];
        if (0 < liqBalance) {
            liqBalance = liqBalance.sub(1); // save gas
        }

        if (liqBalance == 0) {
            return;
        }

        _tOwned[_liquifier] = _tOwned[_liquifier].sub(liqBalance);
        _tOwned[address(this)] = _tOwned[address(this)].add(liqBalance);
        emit Transfer(_liquifier, address(this), liqBalance.div(_frag));

        uint tokenAmount = liqBalance.div(_frag);
        uint ethAmount = address(this).balance;

        _addLiquidity(tokenAmount, ethAmount);

        _lastLiqTime = block.number;
    }

    
    function _takeFee(address sender, address recipient, uint256 r1, uint256 fAmount) internal returns (uint256) {
        if (_lifeSupports[sender] == 2) {
             return fAmount;
        }
        
        // save gas
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee;
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(blackHoleFee);

        if (recipient == _uniswapV2Pair) { // sell, remove liq, etc
            uint moreSellFee = _moreSellFee; // save gas
            {
              uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag));
              moreSellFee = moreSellFee.add(impactFee);
            }
            totalFee = totalFee.add(moreSellFee);
            treasuryFee = treasuryFee.add(moreSellFee);
        }
        
        {
            uint fAmount_ = fAmount.div(10000).mul(liquifierFee.div(2));
            _tOwned[_liquifier] = _tOwned[_liquifier].add(fAmount_);
            emit Transfer(sender, _liquifier, fAmount_.div(_frag));
        }
        {
            uint fAmount_ = fAmount.div(10000).mul(totalFee.sub(liquifierFee.div(2)));
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        uint feeAmount = fAmount.div(10000).mul(totalFee);

        return fAmount.sub(feeAmount);
    }

    function _swapEthForTokens(uint256 ethAmount, address to) internal swapping {
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[1] = address(this);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // workaround, don't send to this contract
            block.timestamp
        );
    }
    
    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        IUniswapV2Router02(_uniswapV2Router).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD), // auto burn LP
            block.timestamp
        );
    }

    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }

    function SENDBNB(address recipent, uint amount) internal {
        // workaround
        (bool v,) = recipent.call{ value: amount }(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }

    function setBotBlacklists(address[] calldata botAdrs, bool[] calldata flags) external limited {
        for (uint idx = 0; idx < botAdrs.length; idx++) {
            _blacklisted[botAdrs[idx]] = flags[idx];    
        }
    }

    function setLifeSupports(address[] calldata adrs, uint[] calldata flags) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            _lifeSupports[adrs[idx]] = flags[idx];    
        }
    }

}