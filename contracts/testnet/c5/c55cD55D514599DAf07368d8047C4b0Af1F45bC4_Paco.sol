/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: Mit
pragma solidity 0.8.10;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



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
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router {
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


contract Paco is Context, IERC20, Ownable {
    using SafeMath for uint256;

    
    string private _name = "Paco Coin";
    string private _symbol = "PACO";
    

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) isHrExempt;
    mapping(address => bool) private _liquidityHolders;
    mapping(address => bool) private _isSniper;
    mapping(address => uint256) public dailySpent;
    mapping(address => uint256) public allowedTxAmount;
    mapping(address => uint256) public sellIntervalStart;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);

    uint8 private _decimals = 18;
    
    uint256 private _tTotal = 100_000_000 * 10**_decimals; //100 Million
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _maxSupply = _tTotal; //were minting all our tokens

    uint256 swapNum = 3;
    uint256 swapDenom = 219000;

    uint256 public swapAndLiquifycount = 0;
    uint256 public snipersCaught = 0;

    // where tokens go to die
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    // pause indicator for contract launch
    bool public _paused = true;

    // ######## Tax structures  ############################
    struct 
    taxRatesStruct {
        uint8 rfi;
        uint8 marketing;
        uint8 charity;
        uint8 development;
        uint8 owners;
        uint8 lp;
        uint8 toSwap;
    }

    // setup buy rates
    taxRatesStruct public buyRates =    taxRatesStruct({
                                            rfi: 1, // HR
                                            marketing: 1, //marketing
                                            charity: 2, // charity
                                            development: 3, // development
                                            owners: 2, // owners
                                            lp: 2, // LP
                                            toSwap: 9 // marketing + charity + development + owners + lp
                                        });

    // setup sell rates
    taxRatesStruct public sellRates =
                                        taxRatesStruct({
                                            rfi: 2, // HR
                                            marketing: 2, //marketing
                                            charity: 4, // charity
                                            development: 6, // development
                                            owners: 4, // owners
                                            lp: 4, // LP
                                            toSwap: 18 // marketing + charity + development + owners + lp
                                        });

    
    taxRatesStruct private appliedRates = buyRates; 

    uint8 private _previousTaxFee = appliedRates.rfi;
    uint8 private _previousLiquidityFee = appliedRates.toSwap;
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap = 1 * 30 seconds;
    uint256 public thresholdDiv = 100; 
    uint256 public _maxWallet = 100_000_000 * 10**_decimals / thresholdDiv; 
    uint256 public _maxTxAmount = 100_000_000 * 10**_decimals / thresholdDiv; 
    uint256 private minimumTokensBeforeSwap = 10_000 * 10**_decimals; 
    uint256 public launchedAt = 0;
    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private sniperProtection = true;
    bool public _hasLiqBeenAdded = false;
    bool public _tradingEnabled = false;
    address public currentLiqPair;
    address payable public marketingAddress;
    address payable public developerAddress;
    address payable public charityAddress;
    address payable public ownersAddress;  

    uint256 private _reserveThreshold = 60000000 * 10**_decimals;

    //Whale limits
    uint256 public whaleDiv = 10000; 
    uint256 private constant DAY = 86400;
    uint256 private whaleSellTimeLimit = DAY;
    uint256 public maxWhaleTxAmount = _maxTxAmount; 

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event TokenBuy(uint256 amount);
    event TokenSell(uint256 amount);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    event AddLiquidityAndBurnLPairs(uint256 tokensToAddLiquidityWith, uint256 ETHToAddLiquidityWith);
    event SwapTokensForEth(uint256 toSwap);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        //all test addrs
        marketingAddress = payable(0x9b27C25AB7a69bF7358477A7E3F9d6DD4749aAc8);// tesat marketing
        developerAddress = payable(0xcA1D22Ab23d43D411f905395B9F4946965D6EDC4);
        ownersAddress = payable(0xBd34475Ad72cc20f1b77894f22563c768F734995);
        charityAddress = payable(0xAB93A01c66c3522Ad6453A06e3D7114D1cd17a44);

  
        _rOwned[owner()] = _rTotal;

        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[charityAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[ownersAddress] = true;
        _isExcludedFromFee[address(0)];
        _isExcludedFromFee[developerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _liquidityHolders[owner()] = true;

        _startTimeForSwap = block.timestamp;

        _tOwned[owner()] = tokenFromReflection(_rOwned[owner()]);
        _isExcluded[owner()] = true;
        _excluded.push(owner());

        uint256  circulatingSupply = _tTotal.sub(balanceOf(address(owner())));
        maxWhaleTxAmount = circulatingSupply.div(whaleDiv);

        emit Transfer(address(0), owner(), _tTotal);
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
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
    

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(to != address(0), "ERC20: transfer to the zero address");

            if(!_tradingEnabled){
                revert("Trading is currently disabled"); 
            }

            if (from == uniswapV2Pair) {
                emit TokenBuy(amount);
                appliedRates = buyRates; // set buy rates
            } else {
                emit TokenSell(amount);
                appliedRates = sellRates;
            }

            
            if (to != uniswapV2Pair) {
                require(balanceOf(to).add(amount) <= _maxWallet,"Transfer exceeds max");
            } else {

                if (sellIntervalStart[from] != 0) {
                    if (sellIntervalStart[from].add(whaleSellTimeLimit) < block.timestamp) {
                        allowedTxAmount[from] = maxWhaleTxAmount;
                        sellIntervalStart[from] = block.timestamp;
                    }
                }

                if ( allowedTxAmount[from] == 0 && sellIntervalStart[from] == 0 ) {
                    allowedTxAmount[from] = maxWhaleTxAmount;
                    sellIntervalStart[from] = block.timestamp;
                }

                if (amount > allowedTxAmount[from]) {
                    revert("MaxTx Limit: Daily Limit Reached");
                } else {
                    if (allowedTxAmount[from].sub(amount) <= 0) {
                        allowedTxAmount[from] = 0;
                    } else {
                        allowedTxAmount[from] = allowedTxAmount[from].sub(
                            amount
                        );
                    }
                }


            }

            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && _paused) {
            revert("Trading is currently disabled");
            }


        }


        uint256 contractTokenBalance = balanceOf(address(this));

        uint256  circulatingSupply = _tTotal.sub(balanceOf(address(owner())));
        maxWhaleTxAmount = circulatingSupply.div(whaleDiv);

        bool overMinimumSwapTokenBalance = (contractTokenBalance >= minimumTokensBeforeSwap);

        if (
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            balanceOf(uniswapV2Pair) > 0 &&
            !_isExcludedFromFee[from]
        ) {
            if (to == uniswapV2Pair) {
                if (  overMinimumSwapTokenBalance && (_startTimeForSwap + _intervalSecondsForSwap) >= block.timestamp ) {
                    _startTimeForSwap = block.timestamp;
                    swapAndLiquifycount = swapAndLiquifycount.add(1);
                    swapAndLiquify(minimumTokensBeforeSwap);
                }
            }
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {


        uint256 tokensToAddLiquidityWith = contractTokenBalance.mul(appliedRates.lp).div(appliedRates.toSwap);

        uint256 toSwap = contractTokenBalance.sub(tokensToAddLiquidityWith);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(toSwap);

        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 ETHToAddLiquidityWith = deltaBalance.mul(appliedRates.lp).div(appliedRates.toSwap);
        addLiquidityAndBurnLPairs(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        uint256 remainingBalance = address(this).balance;
        uint256 developerFee = remainingBalance.mul(appliedRates.development).div(appliedRates.toSwap);
        uint256 ownersFee = remainingBalance.mul(appliedRates.owners).div(appliedRates.toSwap);
        uint256 marketingFee = remainingBalance.mul(appliedRates.marketing).div(appliedRates.toSwap);
        uint256 charityFee = remainingBalance.mul(appliedRates.charity).div(appliedRates.toSwap);
        transferToAddressETH(developerAddress,developerFee);
        transferToAddressETH(ownersAddress,ownersFee);
        transferToAddressETH(marketingAddress,marketingFee);
        transferToAddressETH(charityAddress,charityFee);
        emit SwapAndLiquify(toSwap,ETHToAddLiquidityWith,tokensToAddLiquidityWith);

    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this), 
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidityAndBurnLPairs(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            DEAD, 
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {

        if (sniperProtection) {


            if (isSniper(sender)) {
                revert("Sniper no snipey.");
            }


            if (!_hasLiqBeenAdded) {
                _checkLiquidityAdd(sender, recipient);
            } else {
                if (
                    launchedAt > 0 &&
                    sender == uniswapV2Pair &&
                    !_liquidityHolders[sender] &&
                    !_liquidityHolders[recipient]
                ) {
                    if (block.number - launchedAt < 3) {
                        _isSniper[recipient] = true;
                        snipersCaught++;
                    }
                }
            }
        }
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(appliedRates.rfi).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        if (launchedAt.add(3) >= block.number) {
            uint256 liquidityFee = appliedRates.toSwap;
            return _amount.mul(liquidityFee).div(10**3);
        } else {
            return _amount.mul(appliedRates.toSwap).div(10**3);
        }
    }

    function manualSwapandLiquify(uint256 _balance) external onlyOwner {
        swapAndLiquify(_balance);
    }

    function setLaunchLiqPair(address _pair) public onlyOwner {
        uniswapV2Pair = _pair;
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    function removeAllFee() private {
        if (appliedRates.rfi == 0 && appliedRates.toSwap == 0) return;

        _previousTaxFee = appliedRates.rfi;
        _previousLiquidityFee = appliedRates.toSwap;

        appliedRates.rfi = 0;
        appliedRates.toSwap = 0;
    }

    function restoreAllFee() private {
        appliedRates.rfi = _previousTaxFee;
        appliedRates.toSwap = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function GetSwapMinutes() public view returns (uint256) {
        return _intervalSecondsForSwap.div(60);
    }

    function SetSwapMinutes(uint256 newMinutes) external onlyOwner {
        _intervalSecondsForSwap = newMinutes * 1 minutes;
    }




    function addressChange(
       
        address payable _charityAddress,
        address payable _developerAddress,
        address payable _marketingAddress,
        address payable _ownersAddress
    ) external onlyOwner {
        require(_developerAddress != address(0), "cant set DEVLOPER address 0");
        require(_marketingAddress != address(0), "cant set MARKETING address 0" );
        require(_ownersAddress != address(0), "cant set OWNERS address 0" );
        require(_charityAddress != address(0), "cant set CVARITY address 0" );

        charityAddress = _charityAddress;
        developerAddress = _developerAddress;
        marketingAddress = _marketingAddress;
        ownersAddress = _ownersAddress;
    }

    function _checkLiquidityAdd(address from, address to) private {

        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");

        if (_liquidityHolders[from] && to == uniswapV2Pair) {
            _hasLiqBeenAdded = true;
            _tradingEnabled = true;
            launchedAt = block.number;
        }
    }

    function removeSniper(address account) external onlyOwner {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function changeWalletLimits(uint256 maxTxAmount, uint256 maxWallet)
        external
        onlyOwner
    {
        require(maxTxAmount > totalSupply().div(1000), "max tx too low");
        require(maxWallet > totalSupply().div(1000), "max wallet too low");
        _maxWallet = maxWallet;
        _maxTxAmount = maxTxAmount;
    }

    function changeWhaleLimits(uint256 _whaleDiv)
        external
        onlyOwner
    {
        require(whaleDiv > 0, "div too low");
        
        whaleDiv = _whaleDiv;
        uint256  circulatingSupply = _tTotal.sub(balanceOf(address(owner())));
        maxWhaleTxAmount = circulatingSupply.div(whaleDiv);
    }


    function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap)
        external
        onlyOwner
    {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyOwner {
        launchedAt = block.number;
        _hasLiqBeenAdded = true;
        _tradingEnabled = true;
        _paused = false;
    }

    function afterPreSale() external onlyOwner {
        setSwapAndLiquifyEnabled(true);
         appliedRates = buyRates; // set buy rates
        _maxTxAmount = 100_000_000 * 10**_decimals / thresholdDiv; 
    }



  
    receive() external payable {}

    function airdropToWallets(
        address[] memory airdropWallets,
        uint256[] memory amounts
    ) external onlyOwner returns (bool) {
        require(
            airdropWallets.length == amounts.length,
            "arrays must be the same length"
        );
        require(airdropWallets.length < 200, "200 wallets tx max");

    
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            uint256 amount = amounts[i];
           
            require(amount < _maxTxAmount, "Airdrop amount > tx max");
        }
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
      
            transfer(wallet, amount);
        }
        return true;
    }

    function transferUnknownToken(address _token, address _to)
        public
        onlyOwner
        returns (bool _sent)
    {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setPaused(bool paused) external onlyOwner {
        require(msg.sender == owner(), "You are not the owner");
        _paused = paused;
    }

    function setWhaleTimeLimit(uint256 _timeLimit) external onlyOwner {
        require(_timeLimit > DAY, "Time Limit < DAY");
        whaleSellTimeLimit = _timeLimit;
    }



    function setSwapAutoValues(uint256 _swapNum, uint256 _swapDenom) external onlyOwner {
        require(_swapNum > 0, "Num < 0");
        require(_swapDenom > 0, "Num < 0");

        swapNum = _swapNum;
        swapDenom = _swapDenom;
    }

    function autoSwap() external onlyOwner {
        require(balanceOf(owner()) < _reserveThreshold, "Balance not met");
        require(balanceOf(uniswapV2Pair) > 0, "No LP");
        require(msg.sender == owner(), "You are not the owner");

        uint256 poolBalance = balanceOf(owner());
        uint256 swapTokens = poolBalance.mul(swapNum).div(swapDenom);

        swapTokensForEth(swapTokens);

    }

}