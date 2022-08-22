/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/**
███████ ███    ██  ██████  ██     ██ ███████  █████  ██      ██          ██████  ██████   ██████  ████████  ██████   ██████  ██████  ██      
██      ████   ██ ██    ██ ██     ██ ██      ██   ██ ██      ██          ██   ██ ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
███████ ██ ██  ██ ██    ██ ██  █  ██ █████   ███████ ██      ██          ██████  ██████  ██    ██    ██    ██    ██ ██      ██    ██ ██      
     ██ ██  ██ ██ ██    ██ ██ ███ ██ ██      ██   ██ ██      ██          ██      ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
███████ ██   ████  ██████   ███ ███  ██      ██   ██ ███████ ███████     ██      ██   ██  ██████     ██     ██████   ██████  ██████  ███████ 
                                                                                                                                             
                                                                                                                                             
*/

pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address payable private _owner;
    address payable private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), _owner);
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
        _owner = payable(address(0));
    }

    function transferOwnership(address payable newOwner)
        public
        virtual
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = payable(address(0));
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(
            block.timestamp > _lockTime,
            "Contract is locked until defined days"
        );
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
        _previousOwner = payable(address(0));
    }
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library Utils {
    using SafeMath for uint256;

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        internal
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 360
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }
}

// Main Token
contract SNW is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) public _isSniper;

    address[] private _excluded;
    address[] private _confirmedSnipers;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000 * 1e6 * 1e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Snowfall Protocol";
    string private _symbol = "SNW";
    uint8 private _decimals = 18;

    IPancakeRouter02 public pancakeRouter;
    address public immutable pancakePair;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public marketAddress;

    uint256 public _maxTxAmount = _tTotal.mul(5).div(1000); // should be 0.5% percent per transaction
    uint256 minTokenNumberToSell = _tTotal.div(100000); // 0.001% max tx amount will trigger swap and add liquidity

    bool public swapAndLiquifyEnabled = false; // should be true to turn on to liquidate the pool
    bool public reflectionFeesdiabled = false; // should be false to charge fee
    bool inSwapAndLiquify = false;

    uint256 public _taxFee = 10; // 1% will be distributed among holder as token divideneds
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 50; // 5% will be added to the liquidity pool
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 10; // 1% will go to the Dead address to deflate token
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _marketFee = 10; // 1% will go to the market address for marketing
    uint256 private _previousMarketFee = _marketFee;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );
    event SniperBotAddded(address indexed account);

    event SniperBotRemoved(address indexed account);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address _market) {
        _rOwned[owner()] = _rTotal;
        marketAddress = _market;

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a pancake pair for this new token
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            _pancakeRouter.WETH()
        );

        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[address(burnAddress)] = true;

        //exclude from reward
        _isExcluded[burnAddress] = true;
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
                "BEP20: transfer amount exceeds allowance"
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
                "BEP20: decreased allowance below zero"
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

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        uint256 rAmount = tAmount.mul(_getRate());
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
            uint256 rAmount = tAmount.mul(_getRate());
            return rAmount;
        } else {
            uint256 rAmount = tAmount.mul(_getRate());
            uint256 rTransferAmount = rAmount.sub(
                totalFeePerTx(tAmount).mul(_getRate())
            );
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
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _rOwned[account] = _tOwned[account].mul(_getRate());
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    // for 1% input 100
    function setMaxTxPercent(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxAmount).div(10000);
    }

    function setMinTokenNumberToSell(uint256 _amount) public onlyOwner {
        minTokenNumberToSell = _amount;
    }

    function setExcludeFromMaxTx(address _address, bool value)
        public
        onlyOwner
    {
        _isExcludedFromMaxTx[_address] = value;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner {
        _burnFee = burnFee;
    }

    function setMarketFeePercent(uint256 marketFee) external onlyOwner {
        _marketFee = marketFee;
    }

    function addSniperInList(address account) external onlyOwner {
        require(
            account != address(pancakeRouter),
            "We can not blacklist pancakeRouter"
        );
        require(!_isSniper[account], "Account is already blacklisted");
        _isSniper[account] = true;
        _confirmedSnipers.push(account);

        emit SniperBotAddded(account);
    }

    function removeSniperFromList(address account) external onlyOwner {
        require(_isSniper[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
            if (_confirmedSnipers[i] == account) {
                _confirmedSnipers[i] = _confirmedSnipers[
                    _confirmedSnipers.length - 1
                ];
                _isSniper[account] = false;
                _confirmedSnipers.pop();
                break;
            }
        }

        emit SniperBotRemoved(account);
    }

    function setSwapAndLiquifyEnabled(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    function setReflectionFees(bool _state) external onlyOwner {
        reflectionFeesdiabled = _state;
    }

    function setPancakeRouter(IPancakeRouter02 _pancakeRouter)
        external
        onlyOwner
    {
        pancakeRouter = _pancakeRouter;
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = tAmount
            .mul(_taxFee.add(_liquidityFee).add(_burnFee).add(_marketFee))
            .div(1e3);
        return percentage;
    }

    function _reflectFee(uint256 tAmount) private {
        uint256 tFee = tAmount.mul(_taxFee).div(1e3);
        uint256 rFee = tFee.mul(_getRate());
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
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

    function _takeBothPoolFee(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 tPoolFee = tAmount.mul(_liquidityFee).div(1e3);
        uint256 rPoolFee = tPoolFee.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rPoolFee);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tPoolFee);
        emit Transfer(sender, address(this), tPoolFee);
    }

    function _takeBurnFee(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 burnFee = tAmount.mul(_burnFee).div(1e3);
        uint256 rBurnFee = burnFee.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurnFee);
        if (_isExcluded[burnAddress])
            _tOwned[burnAddress] = _tOwned[burnAddress].add(burnFee);
        emit Transfer(sender, burnAddress, burnFee);
    }

    function _takeMarketFee(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 marketFee = tAmount.mul(_marketFee).div(1e3);
        uint256 rmarketFee = marketFee.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rmarketFee);
        if (_isExcluded[marketAddress])
            _tOwned[marketAddress] = _tOwned[marketAddress].add(marketFee);
        emit Transfer(sender, marketAddress, marketFee);
    }

    function removeAllFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousMarketFee = _marketFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _marketFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _marketFee = _previousMarketFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(amount > 0, "SNW: Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "SNW: Insufficient user balance");
        require(!_isSniper[to], "SNW: Can not send to bot");
        require(!_isSniper[from], "SNW: Bots can not send");

        if (
            _isExcludedFromMaxTx[from] == false &&
            _isExcludedFromMaxTx[to] == false // by default false
        ) {
            require(amount <= _maxTxAmount, "SNW: amount exceeded max limit");
        }
        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            reflectionFeesdiabled
        ) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
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
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBothPoolFee(sender, tAmount, currentRate);
        _takeBurnFee(sender, tAmount, currentRate);
        _takeMarketFee(sender, tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBothPoolFee(sender, tAmount, currentRate);
        _takeBurnFee(sender, tAmount, currentRate);
        _takeMarketFee(sender, tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBothPoolFee(sender, tAmount, currentRate);
        _takeBurnFee(sender, tAmount, currentRate);
        _takeMarketFee(sender, tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBothPoolFee(sender, tAmount, currentRate);
        _takeBurnFee(sender, tAmount, currentRate);
        _takeMarketFee(sender, tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            !inSwapAndLiquify &&
            shouldSell &&
            from != pancakePair &&
            swapAndLiquifyEnabled &&
            !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            // only sell for minTokenNumberToSell, decouple from _maxTxAmount
            // split the contract balance into 4 pieces

            contractTokenBalance = minTokenNumberToSell;
            // approve contract
            _approve(
                address(this),
                address(pancakeRouter),
                contractTokenBalance
            );

            // add liquidity
            // split the contract balance into 2 pieces

            uint256 otherPiece = contractTokenBalance.div(2);
            uint256 tokenAmountToBeSwapped = contractTokenBalance.sub(
                otherPiece
            );

            uint256 initialBalance = address(this).balance;

            // now is to lock into staking pool
            Utils.swapTokensForEth(
                address(pancakeRouter),
                tokenAmountToBeSwapped
            );

            // how much BNB did we just swap into?

            // capture the contract's current BNB balance.
            // this is so that we can capture exactly the amount of BNB that the
            // swap creates, and not make the liquidity event include any BNB that
            // has been manually sent to the contract

            uint256 bnbToBeAddedToLiquidity = address(this).balance.sub(
                initialBalance
            );

            // add liquidity to pancake
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                otherPiece,
                bnbToBeAddedToLiquidity
            );

            emit SwapAndLiquify(
                tokenAmountToBeSwapped,
                bnbToBeAddedToLiquidity,
                otherPiece
            );
        }
    }
}