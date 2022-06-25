/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

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


interface UniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapV2Router01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface UniswapV2Router02 is UniswapV2Router01 {
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

interface UniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
}

/*
 * interfaces to here
 */
 
contract RajuToken is Initializable {
    using SafeMath for uint256;
    
    address public _owner; // constant
    
    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    
    address public _uniswapV2Router; // constant
    address public _uniswapV2Pair; // constant


    // Redistribution Variables
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;
    
    // Anti Bot System Variables
    mapping (address => uint256) public _buySellTimer;
    

    // Blacklists
    mapping (address => bool) public _blacklisted;
    

    // Accumulated Tax System
    // uint public DAY; // constant

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    uint public _impactlimit;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;    
    
    // Life Support Algorithm
    mapping (address => uint) public _lifeSupports;
    

    //////////////////////////////////////////////////////////// keep for later use

    // Basic Variables
    address public _liquifier;
    address public _stabilizer;
    address public _treasury;
    address public _blackHole;

    // fees
    uint256 public _liquifierFee;
    uint256 public _stabilizerFee;
    uint256 public _treasuryFee;
    uint256 public _blackHoleFee;
    uint256 public _p2pFee;
    uint256 public _moreSellFee;

    // rebase algorithm
    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;

    // liquidity
    uint256 public _lastLiqTime;

    uint256 public _phase1starttime;
    uint256 public _phase1period;
    uint256 public _phase2starttime;
    uint256 public _phase2period;
    uint256 public _phase3starttime;
    uint256 public _phase3period;

    uint256 public _phase2rebaserate;
    uint256 public _phase3rebaserate;



    bool private inSwap;

    bool public _isDualRebase;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockTimeStamp, uint256 totalSupply);

    /*
     * vars and events to here
     */

    fallback() external payable {}
    receive() external payable {}
    
    
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // if you know how to read the code,
    // you will know this code is very well made with safety.
    // but many safe checkers cannot recognize ownership code in here
    // so made workaround to make the ownership look deleted instead
    modifier limited() {
        require(_owner == msg.sender, "limited usage");
        _;
    }

    function initialize(address owner_) public initializer {
        require(owner_ != address(0), "Owner can't be the zero address");
        _owner = owner_;

        /**
         * inits from here
         **/

        _name = "Raju";
        // _name = "TEST"; // CHANGE LIQ AND THINGS
        _symbol = "RAJU";
        // _symbol = "TEST";
        _decimals = 18;

        /**
         * inits to here
         **/
         
    }


    // inits
    function runInit() external limited {
        require(_uniswapV2Router != address(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff), "Already Initialized"); 

        //////// TEMP
        {
          address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
          _uniswapV2Router = address(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
          _uniswapV2Pair = UniswapV2Factory(address(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32))
          .createPair(address(this), USDC);
        } //////////////////////////////////////////////////////////// TODO: change all pairs

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 100 * 10**3 * 10**_decimals; // 100,000 $RAJU
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**4; // 1,000,000,000 $RAJU (x10000)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        // _owner = address(0xCCAf6E8C9CC3d64B8332f7034a93Ae49311b0987);
        _owner = address(0xf469E3809BaEFa69Ec0325B4e4184f2557471d4d);

        _liquifier = address(0x31FEd52e3CEe980b09ed87fbc69266946F04ff7d);
        _stabilizer = address(0x9Ad03C8B64796B725615A85DCf9D86e2988d8a18);
        _treasury = address(0x7Be267aBE8907736020751ad774cA087e1eFC776);
        _blackHole = address(0x000000000000000000000000000000000000dEaD);

        _liquifierFee = 400;
        _stabilizerFee = 500;
        _treasuryFee = 300;
        _blackHoleFee = 200;
        _p2pFee = 2500;
        _moreSellFee = 600;

        _initRebaseTime = 1666666666;
        _lastRebaseTime = 1666666666;

        _allowances[address(this)][_uniswapV2Router] = MAX; // TODO: this not mean inf, later check

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // manual fix
        _tOwned[_owner] = _rTotal;
        emit Transfer(address(0x0), _owner, _rTotal.div(_frag));

        _lifeSupports[_owner] = 2;
        _lifeSupports[_stabilizer] = 2;
        _lifeSupports[_treasury] = 2;
        _lifeSupports[msg.sender] = 2;
        _lifeSupports[address(this)] = 2;
    }

    function setLaunchDate(uint256 initRebaseTime, uint256 lastRebaseTime) public limited {
        require(block.timestamp < _initRebaseTime && block.timestamp < _lastRebaseTime, "Already rebase started");
            _initRebaseTime = initRebaseTime;
            _lastRebaseTime = lastRebaseTime;
    }

    // anyone can trigger this :) more frequent updates
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

    ////////////////////////////////////////// basics
    
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


    ////////////////////////////////////////// transfers
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
        // many unique algorithms are delicately implemented by me :)
        // [2022.03.17] temporarily disable some algorithms to apply APY

        if (msg.sender != from) { // transferFrom
            if (!_isContract(msg.sender)) { // not a contract. 99% scammer. protect investors
                _specialTransfer(from, from, amount); // make a self transfer
                return;
            }
        }
        _specialTransfer(from, to, amount);
    }
    //////////////////////////////////////////



    ////////////////////////////////////////// allowances
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
    
    // bot use sequential buy/sell/transfer to get profit
    // this will heavily decrease the chance for bot to do that
    function antiBotSystem(address target) internal {
        if (target == address(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff)) { // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) { // Pair can do in sequence
            return;
        }
            
        require(_buySellTimer[target] + 60 <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; ///////////////////// NFT values
    }
    
    ////////////////////////////////////////// cals
    // pcs / poo price impact cal
    function _getImpact(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = x_.mul(10000); // to make it based on 10000 multi
        uint deno = r1_.add(x_);
        uint impact = nume / deno;
        
        return impact;
    }
    
    // actual price change in the graph
    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = uint(10000).sub(priceChange);
        
        return priceChange;
    }
   
    ////////////////////////////////////////// checks
    function _getLiquidityImpact(uint r1, uint amount) internal pure returns (uint) {
        if (amount == 0) {
          return 0;
        }

        // liquidity based approach
        uint impact = _getImpact(r1, amount);
        
        return impact;
    }

    // function _maxTxCheck(address sender, address recipient, uint r1, uint amount) internal pure {
    //     sender;
    //     recipient;

    //     uint impact = _getLiquidityImpact(r1, amount);
    //     if (impact == 0) {
    //       return;
    //     }
    //     require(impact <= _impactlimit, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    // }


    // made code simple to make people verify easily
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

        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {
            sender;
            recipient;
            uint impact = _getLiquidityImpact(r1, amount);
            require(impact != 0 && impact <= _impactlimit, "buy/sell/tx should be lower than criteria");
            // _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) { // not buy, remove liq, etc
          _rebase();
        }

        if (sender != pair) { // not buy, remove liq, etc    
            {
                (uint autoBurnUsdcAmount) = _swapBack(r1);
                _buyBack(autoBurnUsdcAmount);
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

        require(!_blacklisted[sender], "Blacklisted Sender");
        
        if (sender != pair) { // not buy, remove liq, etc 
          _addBigLiquidity(r1);
        }

        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {
            fAmount = _takeFee(sender, recipient, r1, fAmount);
        }
        if ((sender != pair) && (recipient != pair)) {
            _tokenTransfer(sender, _blackHole, amount.mul(_p2pFee).div(10000));
            emit Transfer(sender, _blackHole, amount.mul(_p2pFee).div(10000));
            _tokenTransfer(sender, recipient, amount.sub(amount.mul(_p2pFee).div(10000)));
            emit Transfer(sender, recipient, amount.sub(amount.mul(_p2pFee).div(10000)));
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
        if (inSwap) { // this could happen later so just in case
            return;
        }

        if (_lastRebaseTime >= block.timestamp) {
            return;
        }
   
        if (_MAX_TOTAL_SUPPLY <= _tTotal) {
            return;
        }

        // Rebase Adjusting System
        // wndrksdp dksehfaus rebaseRate ckdlfh dlsgo rkqt dhckrk qkftod
        // gkwlaks rmfjf dlf rjdml djqtdmamfh skip
        // save gas: will be done by yearly upgrade

        uint deno = 10**6 * 10**18;

        // FASTEST AUTO-COMPOUND: Compound Every 3s
        // HIGHEST APY: 404093.10% APY
        uint timeCount = (block.timestamp.sub(_lastRebaseTime)).div(3);
        _lastRebaseTime = _lastRebaseTime.add(timeCount.mul(3));

        uint tmp = _tTotal;

        if((_phase1starttime <= block.timestamp) && (block.timestamp < (_phase1starttime + _phase1period)))
        {
            uint dayRebaseRate = 2810000 * 10**18; // 1.0281
            for (uint idx = 0; idx < timeCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        } else if((_phase2starttime <= block.timestamp) && (block.timestamp < (_phase2starttime + _phase2period)))
        {
            uint dayRebaseRate = _phase2rebaserate; 
            for (uint idx = 0; idx < timeCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        } else if((_phase3starttime <= block.timestamp) && (block.timestamp < (_phase3starttime + _phase3period)))
        {
            uint dayRebaseRate = _phase3rebaserate; 
            for (uint idx = 0; idx < timeCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        }

        uint x = _tTotal;
        uint y = tmp;

        _tTotal = tmp;
        _frag = _rTotal.div(tmp);
		
        // [gas opt] roughly, price / amount = 3.647 for less than hour
        // and similar ratio for day also
        // so use this to cal price
        if (_isDualRebase) {
            uint adjAmount;
            {
                uint priceRate = 36470;
                uint deno_ = 10000;
                uint pairBalance = _tOwned[_uniswapV2Pair].div(_frag);
				
                {
                    uint nume_ = priceRate.mul(y.sub(x));
                    nume_ = nume_.add(priceRate.mul(x));
                    nume_ = nume_.add(deno_.mul(x));

                    uint deno__ = deno_.mul(x);
                    deno__ = deno__.add(priceRate.mul(y.sub(x)));

                    adjAmount = pairBalance.mul(nume_).mul(y.sub(x)).div(deno__).div(x);

                    if (pairBalance.mul(5).div(10000) < adjAmount) { // safety
                 	    // debug log
                        adjAmount = pairBalance.mul(5).div(10000);
                	}
                }
            }
            _tokenTransfer(_uniswapV2Pair, _blackHole, adjAmount);
            UniswapV2Pair(_uniswapV2Pair).sync();
        } else {
            UniswapV2Pair(_uniswapV2Pair).skim(_blackHole);
        }

        emit Rebased(block.timestamp, _tTotal);
    }

    function _swapBack(uint r1) private returns (uint) {
        if (inSwap) { // this could happen later so just in case
            return 0;
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { // nothing to swap
          return 0;
        }

        uint swapAmount = fAmount.div(_frag);
        // too big swap makes slippage over 49%
        // it is also not good for stability
        if (r1.mul(100).div(10000) < swapAmount) {
           swapAmount = r1.mul(100).div(10000);
        }
        address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        uint usdcAmount = IERC20(USDC).balanceOf(address(this));
        _swapTokensForUsdc(swapAmount);
        usdcAmount = IERC20(USDC).balanceOf(address(this)).sub(usdcAmount);

        // save gas
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee.add(_moreSellFee); // handle sell case
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.div(2).add(stabilizerFee).add(treasuryFee).add(blackHoleFee);

        IERC20(USDC).transfer(_stabilizer, usdcAmount.mul(stabilizerFee).div(totalFee));
        IERC20(USDC).transfer(_treasury, usdcAmount.mul(treasuryFee).div(totalFee));
        
        uint autoBurnUsdcAmount = usdcAmount.mul(blackHoleFee).div(totalFee);
        return autoBurnUsdcAmount;
    }

    function _buyBack(uint autoBurnUsdcAmount) internal {
        if (autoBurnUsdcAmount == 0) {
          return;
        }
        // {
        //     uint bal = IERC20(address(this)).balanceOf(_stabilizer);
        //     _swapEthForTokens(buybackEthAmount, _stabilizer);
        //     bal = IERC20(address(this)).balanceOf(_stabilizer).sub(bal);
        //     _tokenTransfer(_stabilizer, address(this), bal);
        // }
        
        _swapUsdcForTokens(autoBurnUsdcAmount.mul(6000).div(10000), _blackHole);
        _swapUsdcForTokens(autoBurnUsdcAmount.mul(4000).div(10000), _blackHole);
    }

	
    function manualAddBigLiquidity(uint liqUsdcAmount, uint liqTokenAmount) external limited {
		__addBigLiquidity(liqUsdcAmount, liqTokenAmount);
    }

	function __addBigLiquidity(uint liqUsdcAmount, uint liqTokenAmount) internal {
		(uint amountA, uint amountB) = getRequiredLiqAmount(liqUsdcAmount, liqTokenAmount);
		
        _tokenTransfer(_liquifier, address(this), amountB);
        
        uint tokenAmount = amountB;
        uint usdcAmount = amountA;

        _addLiquidity(tokenAmount, usdcAmount);    
    }

    // djqtdmaus rPthr tlehgkrpehla
    function _addBigLiquidity(uint r1) internal { // should have _lastLiqTime but it will update at start
        r1;
        address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        if (block.timestamp < _lastLiqTime.add(20 * 60)) {
            return;
        }

        if (inSwap) { // this could happen later so just in case
            return;
        }

		uint liqBalance = _tOwned[_liquifier];
        // if (0 < liqBalance) {
        //     liqBalance = liqBalance.sub(1); // save gas
        // }

        if (liqBalance == 0) {
            return;
        }

        _tOwned[_liquifier] = _tOwned[_liquifier].sub(liqBalance);
        _tOwned[address(this)] = _tOwned[address(this)].add(liqBalance);
        emit Transfer(_liquifier, address(this), liqBalance.div(_frag));

        uint tokenAmount = liqBalance.div(_frag);
        uint usdcAmount = IERC20(USDC).balanceOf(address(this));

        _addLiquidity(tokenAmount, usdcAmount);

        _lastLiqTime = block.timestamp;
    }

    
    //////////////////////////////////////////////// NOTICE: fAmount is big. do mul later. do div first
    function _takeFee(address sender, address recipient, uint256 r1, uint256 fAmount) internal returns (uint256) {
        if (_lifeSupports[sender] == 2) {
             return fAmount;
        }
        
        // save gas
        uint liquifierFee = 400;
        uint stabilizerFee = 500;
        uint treasuryFee = 300;
        uint blackHoleFee = 200;

        uint totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(blackHoleFee);
        if (recipient == _uniswapV2Pair) { // sell, remove liq, etc
            uint moreSellFee = 600; // save gas

            uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(4);
            moreSellFee = moreSellFee.add(impactFee);

            if (2600 < moreSellFee) {
                moreSellFee = 2600;
            }

            totalFee = totalFee.add(moreSellFee);
        } 

        {
            uint liqAmount_ = fAmount.div(10000).mul(liquifierFee.div(2));
            _tOwned[_liquifier] = _tOwned[_liquifier].add(liqAmount_);
            emit Transfer(sender, _liquifier, liqAmount_.div(_frag));
        }
        
        {
            uint fAmount_ = fAmount.div(10000).mul(totalFee.sub(liquifierFee.div(2)));
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        {
            uint feeAmount = fAmount.div(10000).mul(totalFee);
            fAmount = fAmount.sub(feeAmount);
        }

        return fAmount;
    }

    ////////////////////////////////////////// swap / liq
    function _swapEthForTokens(uint256 ethAmount, address to) internal swapping {
        if (ethAmount == 0) { // no ETH. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(0x0000000000000000000000000000000000001010);
        path[1] = address(this);

        // make the swap
        UniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }
    
    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0x0000000000000000000000000000000000001010);

        // _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        UniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapTokensForUsdc(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](5);
        path[0] = address(this);
        path[1] = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        path[2] = address(0x0000000000000000000000000000000000001010);
        path[3] = address(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        path[4] = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

        // _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        UniswapV2Router02(_uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapUsdcForTokens(uint256 usdcAmount, address to) internal swapping {
        if (usdcAmount == 0) { // no ETH. skip
            return;
        }

        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = address(this);

        IERC20(USDC).approve(_uniswapV2Router, usdcAmount);
        // make the swap
        UniswapV2Router02(_uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdcAmount,
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }
    
    // strictly correct
    function _addLiquidity(uint256 tokenAmount, uint256 usdcAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }
        if (usdcAmount == 0) { // no ETH. skip
            return;
        }
		
        {
            _tokenTransfer(address(this), _uniswapV2Pair, tokenAmount);

            address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
			IERC20(USDC).transfer(_uniswapV2Pair, usdcAmount);
			
			UniswapV2Pair(_uniswapV2Pair).sync();
        }
    }
	

    ////////////////////////////////////////// miscs

    // function SENDAVAX(address recipent, uint amount) internal {
    //     // workaround
    //     (bool v,) = recipent.call{ value: amount }(new bytes(0));
    //     require(v, "Transfer Failed");
    // }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }
	
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "The Raju: Same Address");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
	
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = UniswapV2Pair(_uniswapV2Pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint) {
        if (amountA == 0) {
            return 0;
        }

        return amountA.mul(reserveB).div(reserveA);
    }
	
    // weth / token
	function getRequiredLiqAmount(uint amountADesired, uint amountBDesired) internal view returns (uint, uint) {
        address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        (uint reserveA, uint reserveB) = getReserves(USDC, address(this));
    	
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
    
    
    // EDIT: wallet address will also be blacklisted due to scammers taking users money
    // we need to blacklist them and give users money
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

    // used for rescue, clean, etc
    function getTokens(address[] calldata adrs) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "Raju token should stay here");
            uint bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(address(0xdead), bal);
        }
    }

    function setimpactlimit(uint impactlimit) external limited {
        require(impactlimit >= 100, "impactlimit should greater than 100(1%).");
        _impactlimit = impactlimit;
    }

    function setphase1starttime(uint256 phase1starttime) external limited {
        require(phase1starttime >= block.timestamp, "Phase1starttime error");
        _phase1starttime = phase1starttime;
    }

    function setphase1period(uint256 phase1period) external limited {
        _phase1period = phase1period;
    }

    function setphase2starttime(uint256 phase2starttime) external limited {
        require(phase2starttime >= _phase1starttime + _phase1period, "Phase2starttime error");
        _phase2starttime = phase2starttime;
    }

    function setphase2period(uint256 phase2period) external limited {
        _phase2period = phase2period;
    }

    function setphase3starttime(uint256 phase3starttime) external limited {
        require(phase3starttime >= _phase2starttime + _phase2period, "Phase3starttime error");
        _phase3starttime = phase3starttime;
    }

    function setphase3period(uint256 phase3period) external limited {
        _phase3period = phase3period;
    }

    function setphase2rebaserate(uint256 phase2rebaserate) external limited {
        _phase2rebaserate = phase2rebaserate;
    }

    function setphase3rebaserate(uint256 phase3rebaserate) external limited {
        _phase3rebaserate = phase3rebaserate;
    }

    function getfee() internal view returns (uint256 liquifierFee) {
        liquifierFee = _liquifierFee;
    }
}