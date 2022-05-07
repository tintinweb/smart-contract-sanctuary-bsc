/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

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

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
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

    //function totalSupply() external view returns (uint256);

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


contract HoleJourney is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromSwapLimit;

    uint256 private _tTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _swapFee = 6;
    uint256 public _bonusTotal = 0;
    uint256 public _priceLimit = 0;
    uint256 public _priceLimitToken = 0;
    uint256 public _swapUsdtLimit = 0;
    uint256 public _swapTokenLimit = 99;
    bool public _swapkey = false;
    address public _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address private _destroyAddress =address(0x000000000000000000000000000000000000dEaD);
    
    address public uniswapV2Pair;

    IUniswapV2Router02 private uniswapV2Router;
  
    constructor() {
        _name = "BHI";
        _symbol = "BHI";
        _decimals = 18;

        _tTotal = 5000000 * 10 **_decimals;

        _priceLimit = 100 * 10 **IERC20(_usdtAddress).decimals();
        _priceLimitToken = 10 * 10 **_decimals;

        _swapUsdtLimit = 2000 * 10 **IERC20(_usdtAddress).decimals();

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        //exclude owner and this contract from price limit
        _isExcludedFromSwapLimit[msg.sender] = true;
        _isExcludedFromSwapLimit[address(this)] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _usdtAddress);
        uniswapV2Router = _uniswapV2Router;
       
        _owner = msg.sender;
        _rOwned[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _tTotal);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
         return _rOwned[account];
    }
    
    function transfer(address recipient, uint256 amount)public override returns (bool) {
        if(msg.sender == uniswapV2Pair){
            //if account belongs to _isExcludedFromPriceLimit then remove the swap limit
            if(!_isExcludedFromSwapLimit[recipient]){
                require(_swapkey, "SWAP: swap is off");
                //can swap max usdt of token
                uint256[] memory canAmounts = getThisTokenToUsdtAomunt(amount);
                require(canAmounts[1]<=_swapUsdtLimit, "SWAP: swapout is limit");
                //if price below _priceLimit and amount > _priceLimitToken and account not belongs to _isExcludedFromPriceLimit then can't to swap
                uint256[] memory prices = getThisTokenToUsdtAomunt(1* 10**_decimals);
                require(prices[1]>=_priceLimit || amount<=_priceLimitToken, "SWAP: price is limit");
            }
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(!_isExcludedFromFee[recipient]){
                uint256 amounts = amount.div(100).mul(_swapFee);
                _bonusTotal = _bonusTotal.add(amounts);
                _transfer(msg.sender, recipient, amount.sub(amounts));
                _transfer(msg.sender, address(this), amounts);
            }else{
                _transfer(msg.sender, recipient, amount);
            }
        }else if(recipient == uniswapV2Pair){
            //if account belongs to _isExcludedFromPriceLimit then remove the swap limit
            if(!_isExcludedFromSwapLimit[msg.sender]){
                //can swap max usdt of token
                uint256[] memory canAmounts = getThisTokenToUsdtAomunt(amount);
                require(canAmounts[1]<=_swapUsdtLimit, "SWAP: swapout is limit");
                //if account not belongs to _isExcludedFromPriceLimit then once swap token can't greater than _swapTokenLimit of balance
                uint256 canSwapToken = balanceOf(msg.sender).div(100).mul(_swapTokenLimit);
                require(amount<=canSwapToken, "SWAP: token is limit");
            }
            if(!_isExcludedFromFee[msg.sender]){
                uint256 amounts = amount.div(100).mul(_swapFee);
                _bonusTotal = _bonusTotal.add(amounts);
                _transfer(msg.sender, recipient, amount.sub(amounts));
                _transfer(msg.sender, address(this), amounts);    
            }else{
                _transfer(msg.sender, recipient, amount);
            }           
        }else{
            _transfer(msg.sender, recipient, amount);
        }
        return true;
    }


    function allowance(address owner, address spender)public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)public override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
        if(sender == uniswapV2Pair){
             //if account belongs to _isExcludedFromPriceLimit then remove the swap limit
            if(!_isExcludedFromSwapLimit[recipient]){
                require(_swapkey, "SWAP: swap is off");
                //can swap max usdt of token
                uint256[] memory canAmounts = getThisTokenToUsdtAomunt(amount);
                require(canAmounts[1]<=_swapUsdtLimit, "SWAP: swapout is limit");
                //if price below _priceLimit and amount > _priceLimitToken and account not belongs to _isExcludedFromPriceLimit then can't to swap
                uint256[] memory prices = getThisTokenToUsdtAomunt(1* 10**_decimals);
                require(prices[1]>=_priceLimit || amount<=_priceLimitToken, "SWAP: price is limit");
            }
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(!_isExcludedFromFee[recipient]){
                uint256 amounts = amount.div(100).mul(_swapFee);
                _bonusTotal = _bonusTotal.add(amounts);
                _transfer(sender, recipient, amount.sub(amounts));
                _transfer(sender, address(this), amounts);
            }else{
                _transfer(sender, recipient, amount);
            }
        }else if(recipient == uniswapV2Pair){
            //if account belongs to _isExcludedFromPriceLimit then remove the swap limit
            if(!_isExcludedFromSwapLimit[sender]){
                //can swap max usdt of token
                uint256[] memory canAmounts = getThisTokenToUsdtAomunt(amount);
                require(canAmounts[1]<=_swapUsdtLimit, "SWAP: swapout is limit");
                //if account not belongs to _isExcludedFromPriceLimit then once swap token can't greater than _swapTokenLimit of balance
                uint256 canSwapToken = balanceOf(sender).div(100).mul(_swapTokenLimit);
                require(amount<=canSwapToken, "SWAP: token is limit");
            }
             if(!_isExcludedFromFee[sender]){
                uint256 amounts = amount.div(100).mul(_swapFee);
                _bonusTotal = _bonusTotal.add(amounts);
                _transfer(sender, recipient, amount.sub(amounts));
                _transfer(sender, address(this), amounts);  
            }else{
                _transfer(sender, recipient, amount);
            }    
        }else{
            _transfer(sender, recipient, amount);
        }
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // increase allowance
    function increaseAllowance(address spender, uint256 addedValue)public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    // decrease allowance
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }


    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


     function excludeFromSwapLimit(address account) public onlyOwner {
        _isExcludedFromSwapLimit[account] = true;
    }

    function includeInSwapLimit(address account) public onlyOwner {
        _isExcludedFromSwapLimit[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimBnb(uint256 amount) public onlyOwner {
        payable(_owner).transfer(amount);
    }

    function claimUsdt(uint256 amount) public onlyOwner {
        IERC20(_usdtAddress).transfer(_owner,amount);
    }

    function claimToken(uint256 amount) public onlyOwner {
        _transfer(address(this), _owner, amount);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromSwapLimit(address account) public view returns (bool) {
        return _isExcludedFromSwapLimit[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _rOwned[from] = _rOwned[from].sub(amount);
        _rOwned[to] = _rOwned[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    //change swap percentage 
    function changeSwapFee(uint256 amount) public onlyOwner {
        _swapFee = amount;
    } 

     //change price limit 
    function changePriceLimit(uint256 amount) public onlyOwner {
        _priceLimit = amount * 10**IERC20(_usdtAddress).decimals();
    } 

     //change price limit token
    function changePriceLimitToken(uint256 amount) public onlyOwner {
        _priceLimitToken = amount * 10**_decimals;
    } 

    //change swap usdt limit
    function changeSwapUsdtLimit(uint256 amount) public onlyOwner {
        _swapUsdtLimit = amount * 10**IERC20(_usdtAddress).decimals();
    } 

    //on swap key
    function onSwapkey() public onlyOwner {
        _swapkey = true;
    }

    //off swap key
    function offSwapkey() public onlyOwner {
        _swapkey = false;
    }

    // get this token to USDT amount
    function getThisTokenToUsdtAomunt(uint256 amount) public view returns(uint256[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress; 
        amounts = uniswapV2Router.getAmountsOut(amount,path);
        return amounts;
    }

    //transfer batch
     function transferBatch(address[] memory recipient,uint256[] memory amount) public onlyOwner returns (bool) {
        for(uint256 i=0;i<recipient.length && i<amount.length;i++ ){
            _transfer(address(this), recipient[i], amount[i]);
        }
        return true;
    }
}