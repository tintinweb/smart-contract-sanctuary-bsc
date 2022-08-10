/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// Future cryptocurrency banking space
// Partnership with COBE
// Name: COBE
// Symbol: BE
// Contract: 0xAd83a59563CCfd913D5129c1c9B6278b63025Dd8

// File: https://github.com/LiqLand/misc/blob/main/SafeMath.sol


pragma solidity ^0.8.16;
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

// File: https://github.com/LiqLand/misc/blob/main/IUniswapV2Pair.sol


pragma solidity ^0.8.15;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Dev(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function dev(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

// File: https://github.com/LiqLand/misc/blob/main/IUniswapV2Factory.sol


pragma solidity ^0.8.15;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: https://github.com/LiqLand/misc/blob/main/IUniswapV2Router01.sol


pragma solidity ^0.8.15;
interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: https://github.com/LiqLand/misc/blob/main/IERC20.sol


pragma solidity ^0.8.15;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: wMIR.sol


pragma solidity ^0.8.15;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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


contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract wMIR is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => User) private cooldown;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    mapping (address => bool) private _excludedFromReward;
    address[] private _excluded;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 9000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tTotalDistributedToken;
    string private _name = "Bank MIRReflect";  // Bank modified interest rate return
    string private _symbol = "wMIR";   // wrapped modified interest rate return
    uint8 private _decimals = 18;
    uint256 public _bReward = 50;  // Current buy fee for reward is 5% to holder via buy
    uint256 public _bDevfee = 10;  // Current buy fee for development is 1%
    uint256 public _bRfuel = 60;   //  Current buy fee for liquidity is 6% share with development 
    uint256 public _sReward = 60;    // Current sell fee for reward is 6% to holder via sell
    uint256 public _sDevfee = 10;    // Current sell fee for development is 1%
    uint256 public _sRfuel = 100;   // Current sell fee for liquidity is 10% share with development 
    uint256 private currentRefectionFee;
    uint256 private currentDevFee;
    uint256 private currentLiquidityFee;
    uint256 private currentLiquidNDevFee = currentDevFee.add(currentLiquidityFee);
    uint256 public xDirect_Inject = 3000000;
    address public _xBoost = payable(0x1E123ba26D5d6f9a29512F119941661F8A58945e);
    address public _xLiqEngine = payable(0xae1cE2B3ea3d5D3F191f374f29BaAEfFc75CBBcD);
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private _cooldownEnabled = true;
    struct User {
        uint256 buy;
        uint256 sell;
        bool exists;
    }
    uint256 private numTokensSellToAddToLiquidity = xDirect_Inject * 10**18;     
    IERC20 public BE = IERC20(0xAd83a59563CCfd913D5129c1c9B6278b63025Dd8);
    struct FeeDrop {
        uint256 beRequired;
        uint256 discountPercent;
    }
    mapping (uint256 => FeeDrop) public feeDrop;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event CooldownEnabledUpdated(bool _cooldown);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }   
    modifier onlyXboost() {
        require(_xBoost == _msgSender(), "Caller is not the _xBoost");
        _;
    }
    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);  
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
       .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        
        _excludedFromFee[owner()] = true;
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[_xBoost] = true;
        _excludedFromFee[_xLiqEngine] = true;
        
        feeDrop[1].beRequired = 50000 ether; // Exactly amount 
        feeDrop[1].discountPercent = 10; // Current 1% discount 
        feeDrop[2].beRequired = 500000 ether; // Exactly amount 
        feeDrop[2].discountPercent = 20; // Current 2% discount 
        feeDrop[3].beRequired = 5000000 ether; // Exactly amount 
        feeDrop[3].discountPercent = 50; // Current 5% discount 

        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_excludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "wMIR: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "wMIR: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _excludedFromReward[account];
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyXboost() {
        require(!_excludedFromReward[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _excludedFromReward[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyXboost() {
        require(_excludedFromReward[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _excludedFromReward[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function set_xDirect_Inject(uint256 Inject_Number) external onlyXboost() {
       xDirect_Inject = Inject_Number;
       numTokensSellToAddToLiquidity = xDirect_Inject * 10**18;
   }
    
    function set_xBoost(address new_xBoost) external onlyXboost {
        require(new_xBoost != address(0), "new_xBoost can not be a zero address");
        _xBoost = (new_xBoost);
    }
    
    function setBuyFeePercent(uint256 reflect, uint256 dev, uint256 liquid) public onlyXboost {
        require(reflect.add(dev).add(liquid) <= 200, "Fee limitation is 20% anti rugged");
        _bReward = reflect;
        _bDevfee = dev;
        _bRfuel = liquid;
    }
  
    function setSellFeePercent(uint256 reflect, uint256 dev, uint256 liquid) public onlyXboost {
        require(reflect.add(dev).add(liquid) <= 250, "Fee limitation is 25% anti rugged");
        _sReward = reflect;
        _sDevfee = dev;
        _sRfuel = liquid;
    }

    function excludeFromFee(address account) public onlyXboost {
        _excludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyXboost {
        _excludedFromFee[account] = false;
    }

    function setLiquify(bool _enabled) public onlyXboost {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);     
    }
 
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tTotalDistributedToken = _tTotalDistributedToken.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidNDevFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidNDevFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidNDevFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tLiquidNDevFee = calculateLiquidNDevFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidNDevFee);
        return (tTransferAmount, tFee, tLiquidNDevFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidNDevFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidNDevFee = tLiquidNDevFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidNDevFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidNDevFee(uint256 tLiquidNDevFee,address sender) private {
        if(currentLiquidNDevFee == 0){
            return;
        }
        uint256 tDev = tLiquidNDevFee.mul(currentDevFee).div(currentLiquidNDevFee);
        uint256 tLiquid = tLiquidNDevFee.sub(tDev);

        _sendFee(sender, _xBoost, tDev);
        _sendFee(sender, address(this), tLiquid);
    }

    function _sendFee(address from, address to, uint256 amount) private{
        uint256 currentRate =  _getRate();
        uint256 rAmount = amount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        if(_excludedFromReward[to])
            _tOwned[to] = _tOwned[to].add(amount);

        emit Transfer(from, to, amount);
    }
    
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(currentRefectionFee).div(
            10**3
        );
    }

    function calculateLiquidNDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(currentLiquidNDevFee).div(
            10**3
        );
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _excludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "wMIR: approve from the zero address");
        require(spender != address(0), "wMIR: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "wMIR: transfer from the zero address");
        require(to != address(0), "wMIR: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
         if(from != owner() && to != owner()) {
            if(_cooldownEnabled) {
                if(!cooldown[msg.sender].exists) {
                    cooldown[msg.sender] = User(0,0,true);
                }
            }
            if(from == uniswapV2Pair && to != address(uniswapV2Router) && !_excludedFromFee[to]) {
                if(_cooldownEnabled) {
                        require(cooldown[to].buy < block.timestamp, "Wait 30 seconds before each buy");
                        cooldown[to].buy = block.timestamp + (30 seconds);
                    }
                }
                if(_cooldownEnabled) {
                    cooldown[to].sell = block.timestamp + (15 seconds);
                }
            }   
           bool overMinTokenBalance = balanceOf(address(this)) >= numTokensSellToAddToLiquidity;
        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled &&
            overMinTokenBalance
        ) {
           if(_cooldownEnabled) {
                    require(cooldown[from].sell < block.timestamp, "Your sell cooldown has not expired.");
                }
            swapAndLiquify(balanceOf(address(this)));
        }
        bool takeFee = true;
        if(_excludedFromFee[from] || _excludedFromFee[to]){
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokenAmount = contractTokenBalance.mul(2).div(3);
        uint256 slices = contractTokenBalance.div(3);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenAmount); 
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 pizza = newBalance.div(2);
        addLiquidity(slices, pizza);
        uint256 pizzaslices = address(this).balance.sub(initialBalance);
        payable(_xBoost).transfer(pizzaslices);
        emit SwapAndLiquify(tokenAmount, newBalance, slices);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
       address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            // Sandwich, 
            path,
            address(this),
            block.timestamp
        );     
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            _xLiqEngine,
            block.timestamp
        );
    }
   
    function setBEHolder(uint256 tier, uint256 requiredAmount, uint256 discountPercent) public onlyXboost {
        require(tier > 0 && tier <= 3, "3 tiers BE holder fee discount");
        require(discountPercent <= 100, "Check discount percent");
        feeDrop[tier].beRequired = requiredAmount;
        feeDrop[tier].discountPercent = discountPercent;        
    }
    
    function getFeeDrop(address account) public view returns (uint256){
      if(BE.balanceOf(account) >= feeDrop[3].beRequired){
            return feeDrop[3].discountPercent;
        }else if(BE.balanceOf(account) >= feeDrop[2].beRequired){
            return feeDrop[2].discountPercent;
        }else if(BE.balanceOf(account) >= feeDrop[1].beRequired){
            return feeDrop[1].discountPercent;
        }else {
            return 0;
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 feeDropPercent = 0;
        if(!takeFee){
            currentRefectionFee = 0;
            currentDevFee = 0;
            currentLiquidityFee = 0;
        }else if( sender == uniswapV2Pair) {  
            feeDropPercent = getFeeDrop(recipient);
            currentRefectionFee = _bReward.mul(100 - feeDropPercent).div(100);
            currentDevFee = _bDevfee.mul(100 - feeDropPercent).div(100);
            currentLiquidityFee = _bRfuel.mul(100 - feeDropPercent).div(100);
        }else if (recipient == uniswapV2Pair){  
            feeDropPercent = getFeeDrop(sender);
            currentRefectionFee = _sReward.mul(100 - feeDropPercent).div(100);
            currentDevFee = _sDevfee.mul(100 - feeDropPercent).div(100);
            currentLiquidityFee = _sRfuel.mul(100 - feeDropPercent).div(100);
        }else { 
            currentRefectionFee = 0;
            currentDevFee = 0;
            currentLiquidityFee = 0;
        }
        currentLiquidNDevFee = currentDevFee + currentLiquidityFee;

        if (_excludedFromReward[sender] && !_excludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_excludedFromReward[sender] && _excludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_excludedFromReward[sender] && !_excludedFromReward[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_excludedFromReward[sender] && _excludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidNDevFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidNDevFee(tLiquidNDevFee, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidNDevFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidNDevFee(tLiquidNDevFee, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidNDevFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidNDevFee(tLiquidNDevFee, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidNDevFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidNDevFee(tLiquidNDevFee, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}