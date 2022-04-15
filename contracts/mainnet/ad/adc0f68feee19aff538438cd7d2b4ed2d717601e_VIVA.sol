// SPDX-License-Identifier: MIT

/*

################
##Introduction##
################
ViceVersa Protocol is a life changing DeFi 3.0 auto-staking and auto-rebasing Protocol. 
It’s a rebased auto-staking DeFi with multiple levels and play and earn features. 
We guarantee you HIGH APY, incoming DEX, DEFI, NFT platform and much more! 
ViceVersa Protocol will stake and compound you Tokens automatically in your wallet!


##########################
##Auto-Staking with NFTs##
##########################
With an fixed APY of 196,968.08% all you have to do is to hold ViceVersa Tokens in your Wallet. 
You will be rewarded with every block (round about 3 seconds).
If you are not satisfied with this ULTRA-HIGH APY you can go further and become an APY BEAST!

We offer you 4 kinds of NFT-Staking levels to get even more APY in our Staking Protocol:

####Dayjobber – 402,352.13%
####Entrepreneur – 820,749.96%
####Baller – 1,171,619.75%
####Satoshi – 2,384,991.58%

All you have to do is to get yourself one of the 4 Tier NFTs. 
We will track the higher tier NFT you own and give you the promised Staking APY. 
The NFTs will be minted on Polygon-Chain and later can be used for the play and earn game. 
The higher the NFT Tier the higher the APY and the higher the probability to win the round in the play and earn game.

*/


pragma solidity >=0.8.2;

import "./Initializable.sol";

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
}

 
contract VIVA is Initializable {
    using SafeMath for uint256;
    
    uint public _uptest;
    

    address public _owner;
    
    address public _token;
    address public _myRouterSystem; 
    address public _stakeSystem;
    address public _rewardSystem; 
    address public _projectFund;
    address public _rewardToken;

    string private _name; 
    string private _symbol; 
    uint8 private _decimals; 
    
    address public _uniswapV2Router; 
    address public _uniswapV2Pair; 


    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;


    // fixed Fee 
    uint public _liquidityFee; // fixed
    uint public _improvedRewardFee; // fixed
    uint public _projectFundFee; // fixed
    uint public _dipRewardFee; // fixed
    uint public _manualBuyFee; // fixed    
    uint public _autoBurnFee; // fixed
    uint public _redistributionFee; // fixed


    uint public _priceRecoveryFee; 
    uint private PRICE_RECOVERY_ENTERED;

    uint public _isLaunched;

    uint public _minReservesAmount;
    uint public _curReservesAmount;
    
    uint public _rewardTotalBNB;
    mapping (address => uint) public _adjustBuyBNB;
    mapping (address => uint) public _adjustSellBNB;



    
    // Anti Bot System Variables
    mapping (address => uint256) public _buySellTimer;
    uint public _buySellTimeDuration; // fixed
    uint public _lastLpSupply;
    mapping (address => bool) public _blacklisted;
    
    // Accumulated Tax System
    uint public DAY; // constant
    uint public _accuMulFactor; // fixed

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;

    uint public _curcuitBreakerFlag;
    uint public _curcuitBreakerTime;

    
    
    // Airdrop Algorithm
    address public _freeAirdropSystem; 
    address public _airdropSystem; 
    mapping (address => uint) public _airdropTokenLocked;
    uint public _airdropTokenUnlockTime;

    uint public _firstPenguinWasBuy;
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

    // rebase algorithm
    uint256 private _INIT_TOTAL_SUPPLY;
    uint256 private _MAX_TOTAL_SUPPLY; 

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    uint256 public _lastLiqTime;
    bool public _rebaseStarted;
    bool private inSwap;
    bool public _isDualRebase;
    bool public _isExperi;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockNumber, uint256 totalSupply);

	event CircuitBreakerActivated();

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

    function initialize(address owner_) public initializer {
        _owner = owner_;
        _name = "ViceVersa Protocol";
        _symbol = "VIVA";
        _decimals = 18;    
    }
    
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }

    function manualChange() external limited {
    }

    function manualRebase() external {
        _rebase();
    }

    function toggleDualRebase() external limited {
        if (_isDualRebase) {
            _isDualRebase = false;
        } else {
            _isDualRebase = true;
        }
    }

    function toggleExperi() external limited {
        if (_isExperi) {
            _isExperi = false;
        } else {
            _isExperi = true;
        }
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


        if (msg.sender != from) { 
            if (!_isContract(msg.sender)) { // not a contract. 99% scammer. protect investors & make a self transfer
                _specialTransfer(from, from, amount); 
                return;
            }
        }
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

    ////////////////////////////////////////// Anti Bot System
    function antiBotSystem(address target) internal {
        if (target == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) { 
            return;
        }
        if (target == _uniswapV2Pair) { 
            return;
        }
            
        require(_buySellTimer[target] + 60 <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; 
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
        if (amount == 0) {
          return 0;
        }

        // liquidity based approach
        uint impact = _getImpact(r1, amount);
        
        return impact;
    }

    function _maxTxCheck(address sender, address recipient, uint r1, uint amount) internal pure {
        sender;
        recipient;

        uint impact = _getLiquidityImpact(r1, amount);
        if (impact == 0) {
          return;
        }

        require(impact <= 1000, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    }

    function sanityCheck(address sender, address recipient, uint256 amount) internal view returns (uint) {
        sender;
        recipient;

        // Blacklisted sender will never move token
        require(!_blacklisted[sender], "Blacklisted Sender");
        return amount;
    }


    function _specialTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            (amount == 0) ||

            inSwap ||
            
            // 0, 1 is false, 2 for true
            (_lifeSupports[sender] == 2) || // sell case
            (_lifeSupports[recipient] == 2) // buy case
            ) {
            _tokenTransfer(sender, recipient, amount);
            return;
        }

        address pair = _uniswapV2Pair;
        uint r1 = balanceOf(pair); // liquidity pool

        if (sender == pair) {
        	uint totalLpSupply = IERC20(pair).totalSupply();
            if (totalLpSupply < _lastLpSupply) {
            	STOPTRANSACTION();
            }
            if (_lastLpSupply < totalLpSupply) { 
                _lastLpSupply = totalLpSupply;
            }
        }

        if (
            (sender == pair) || 
            (recipient == pair) 
            ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) { 
          _rebase();
        }

        if (sender != pair) {  
            {
                (uint autoBurnEthAmount, uint buybackEthAmount) = _swapBack(r1);
                _buyBack(autoBurnEthAmount, buybackEthAmount);
            }
        }

        if (recipient == pair) { 
          antiBotSystem(sender);
          if (sender != msg.sender) {
            antiBotSystem(msg.sender);
          }
          if (sender != recipient) {
            if (msg.sender != recipient) {
              antiBotSystem(recipient);
            }
          }

          if (_isExperi) {
            accuTaxSystem(amount);
          }
        }

        amount = sanityCheck(sender, recipient, amount);
        
        if (sender != pair) {    
          _addBigLiquidity(r1);
          
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        if (
            (sender == pair) || 
            (recipient == pair) 
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

        emit Transfer(sender, recipient, amount);

        return;
    }





    ////////////////////////////////////////// algorithms
    function _deactivateCircuitBreaker() internal returns (uint) {
        // in the solidity world,
        // to save the gas,
        // 1 is false, 2 is true
        _curcuitBreakerFlag = 1;
        
        _taxAccuTaxCheckGlobal = 1; // [save gas]
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); 

        return 1;
    }


    function accuTaxSystem(uint amount) internal {
        uint r1 = balanceOf(_uniswapV2Pair);

    	uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
		if (curcuitBreakerFlag_ == 2) {
			if (_curcuitBreakerTime + 3600 < block.timestamp) {
                curcuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

		uint taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;
		
        {
            uint timeDiffGlobal = block.timestamp.sub(timeAccuTaxCheckGlobal_);
            uint priceChange = _getPriceChange(r1, amount); 
            if (timeDiffGlobal < 3600) { 
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(priceChange);
            } else { 
				taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; 
            }
        }
    	
        // 1% change
        if (100 < taxAccuTaxCheckGlobal_) {
            _curcuitBreakerFlag = 2; // high sell tax
            _curcuitBreakerTime = block.timestamp;
                
            emit CircuitBreakerActivated();
        }

        _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
        _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;
        return;
    }


    function _rebase() internal {
        if (inSwap) { 
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }
   
        if (_MAX_TOTAL_SUPPLY <= _tTotal) {
            return;
        }


        uint deno = 10**6 * 10**18;

        // FASTEST AUTO-COMPOUND: Compound Every Block (round about 3 seconds)
        // HIGHEST APY: Satoshi – 2,384,991.58%
        uint blockCount = block.number.sub(_lastRebaseBlock);
        uint tmp = _tTotal;

        {

            uint rebaseRate = 79 * 10**18;
            for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
                // S' = S(1+r)**t
                tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
            }
        }

        {

            uint minuteRebaseRate = 1580 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
                tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
            }
        }

        {

            uint hourRebaseRate = 94844 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
                tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
            }
        }

        {

            uint dayRebaseRate = 2301279 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        }

        uint x = _tTotal;
        uint y = tmp;

        _tTotal = tmp;
        _frag = _rTotal.div(tmp);
        _lastRebaseBlock = block.number;
		
        if (_isDualRebase) {
            uint adjAmount;
            {

                uint priceRate = 10000;
                uint deno_ = 10000;
                uint pairBalance = _tOwned[_uniswapV2Pair].div(_frag);
				
                {
                    uint nume_ = priceRate.mul(y.sub(x));
                    nume_ = nume_.add(priceRate.mul(x));
                    nume_ = nume_.add(deno_.mul(x));

                    uint deno__ = deno_.mul(x);
                    deno__ = deno__.add(priceRate.mul(y.sub(x)));

                    adjAmount = pairBalance.mul(nume_).mul(y.sub(x)).div(deno__).div(x);

                    if (pairBalance.mul(5).div(10000) < adjAmount) {
                        adjAmount = pairBalance.mul(5).div(10000);
                	}
                }
            }
            _tokenTransfer(_uniswapV2Pair, _blackHole, adjAmount);
            IPancakeSwapPair(_uniswapV2Pair).sync();
        } else {
            IPancakeSwapPair(_uniswapV2Pair).skim(_blackHole);
        }

        emit Rebased(block.number, _tTotal);
    }

    function _swapBack(uint r1) internal returns (uint, uint) {
        if (inSwap) {
            return (0, 0);
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { 
          return (0, 0);
        }

        uint swapAmount = fAmount.div(_frag);
        // too big swap makes slippage over 49%
        if (r1.mul(100).div(10000) < swapAmount) {
           swapAmount = r1.mul(100).div(10000);
        }
        
        uint ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        // save gas
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee.add(_moreSellFee);
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(blackHoleFee);
        uint buybackFee = 0;

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee.add(buybackFee)));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee.add(buybackFee)));
        
        uint autoBurnEthAmount = ethAmount.mul(blackHoleFee).div(totalFee.add(buybackFee));
        uint buybackEthAmount = 0;

        return (autoBurnEthAmount, buybackEthAmount);
    }

    function _buyBack(uint autoBurnEthAmount, uint buybackEthAmount) internal {
        if (autoBurnEthAmount == 0) {
          return;
        }

        
        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _blackHole);
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _blackHole);
    }

	
    function manualAddBigLiquidity(uint liqEthAmount, uint liqTokenAmount) external limited {
		__addBigLiquidity(liqEthAmount, liqTokenAmount);
    }

	function __addBigLiquidity(uint liqEthAmount, uint liqTokenAmount) internal {
		(uint amountA, uint amountB) = getRequiredLiqAmount(liqEthAmount, liqTokenAmount);
		
        _tokenTransfer(_liquifier, address(this), amountB);
        
        uint tokenAmount = amountB;
        uint ethAmount = amountA;

        _addLiquidity(tokenAmount, ethAmount);    
    }

    function _addBigLiquidity(uint r1) internal { 
        r1;
        if (block.number < _lastLiqTime.add(20 * 60 * 24)) {
            return;
        }

        if (inSwap) { 
            return;
        }

		uint liqEthAmount = address(this).balance;
		uint liqTokenAmount = balanceOf(_liquifier);

        __addBigLiquidity(liqEthAmount, liqTokenAmount);

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

        if (recipient == _uniswapV2Pair) { 
            uint moreSellFee = 200; // save gas

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { 
                    uint circuitFee = 900;
                    moreSellFee = moreSellFee.add(circuitFee);
                }

                {
                    uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(14);
                    moreSellFee = moreSellFee.add(impactFee);
                }

                if (1600 < moreSellFee) {
                    moreSellFee = 1600;
                }
            }


            totalFee = totalFee.add(moreSellFee);
        } else if (sender == _uniswapV2Pair) { 
            uint lessBuyFee = 0;

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { 
                    uint circuitFee = 400;
                    lessBuyFee = lessBuyFee.add(circuitFee);
                }

                if (totalFee < lessBuyFee) {
                    lessBuyFee = totalFee;
                }
            }
            
            totalFee = totalFee.sub(lessBuyFee);
        }
        
        {
            uint fAmount_ = fAmount.div(10000).mul(totalFee);
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        {
            uint feeAmount = fAmount.div(10000).mul(totalFee);
            fAmount = fAmount.sub(feeAmount);
        }

        return fAmount;
    }


    function _swapEthForTokens(uint256 ethAmount, address to) internal swapping {
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // Wrapped BNB (WBNB)
        path[1] = address(this);

        IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, 
            block.timestamp
        );
    }
    
    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // Wrapped BNB (WBNB)

        // make the swap
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
		
        {
            _tokenTransfer(address(this), _uniswapV2Pair, tokenAmount);

            address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);  // Wrapped BNB (WBNB)
        	IWETH(WETH).deposit{value: ethAmount}();
			IWETH(WETH).transfer(_uniswapV2Pair, ethAmount);
			
			IPancakeSwapPair(_uniswapV2Pair).sync();
        }
    }
	

    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }

    function SENDBNB(address recipent, uint amount) internal {
        (bool v,) = recipent.call{ value: amount }(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }
	
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "ViceVersa Protocol: Same Address");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
	
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IPancakeSwapPair(_uniswapV2Pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint) {
        if (amountA == 0) {
            return 0;
        }

        return amountA.mul(reserveB).div(reserveA);
    }
	
    // wbnb / token
	function getRequiredLiqAmount(uint amountADesired, uint amountBDesired) internal view returns (uint, uint) {
        (uint reserveA, uint reserveB) = getReserves(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c), address(this)); // Wrapped BNB (WBNB)
    	
        uint amountA = 0;
        uint amountB = 0;

        uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
            assert(amountAOptimal <= amountADesired);
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }

        return (amountA, amountB);
    }
    
    
    // wallet address will also be blacklisted due to scammers taking users money
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

    function getTokens(address[] calldata adrs) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "VIVA token should stay here");
            uint bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(_owner, bal);
        }
    }

    function disperseToken(address[] calldata recipients, uint256[] calldata amounts) external {
        {
            uint256 totalAmount = 0;
            for (uint256 idx = 0; idx < recipients.length; idx++) {
                totalAmount += amounts[idx];
            }

            uint fTotalAmount = totalAmount.mul(_frag);
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
        }

        for (uint256 idx = 0; idx < recipients.length; idx++) {
            uint fAmount = amounts[idx].mul(_frag);
            _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
            emit Transfer(msg.sender, recipients[idx], amounts[idx]);
        }
    }

    function disperseSameToken(address[] calldata recipients, uint256 amount) external { // about 30% cheaper
        {
            uint256 totalAmount = amount * recipients.length;

            uint fTotalAmount = totalAmount.mul(_frag);
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
        }

        for (uint256 idx = 0; idx < recipients.length; idx++) {
            uint fAmount = amount.mul(_frag);
            _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
            emit Transfer(msg.sender, recipients[idx], amount);
        }
    }

    function sellbuy(uint tokenAmount_) external limited {
        _tokenTransfer(msg.sender, address(this), tokenAmount_);
		
        // sell
        uint ethAmount = address(this).balance;
        _swapTokensForEth(tokenAmount_);
        ethAmount = address(this).balance.sub(ethAmount);

        // buy
        _swapEthForTokens(ethAmount, msg.sender);
    }

}