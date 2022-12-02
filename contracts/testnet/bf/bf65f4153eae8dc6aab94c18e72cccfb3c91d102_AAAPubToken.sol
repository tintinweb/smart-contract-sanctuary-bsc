/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


interface IERC20 {


    /**
 * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);



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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Invite(address indexed owner, address indexed pAddress);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
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
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

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


contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}


abstract contract AbsHiToken is IERC20, Ownable, Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;


    address public immutable uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;



    address public  USDTAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address private uniswapRouterAddress;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) private _marketList;

    uint256 public destroyFeeRate=100;
    uint256 public dividendFeeRate=100;

    uint256 public dividendTotal=100000000*10**_decimals;


    address[] _dividendList;

    uint256 public dividendMinUsdt=100*10**_decimals;


    uint256 public minSwapAmount=0;

    event DvidendUsdt(address indexed recipient ,uint256  usdt,uint256 balance,uint256 totalUsdt,uint256 currentUsdt);


    TokenDistributor public _tokenDistributor;
    mapping(address => bool) public _swapPairList;


    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_){
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10 ** decimals_;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);


        if(block.chainid == 56){
            uniswapRouterAddress =address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            USDTAddress =address(0x55d398326f99059fF775485246999027B3197955);
        }else{
            uniswapRouterAddress =address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            USDTAddress =address(0xC744A874521e7C4Da624fF928A3a8C71B9A17081);
        }
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), USDTAddress);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        _swapPairList[address(uniswapV2Pair)] = true;

        _approve(address(this), address(_uniswapV2Router), 2 ** 256 - 1);

        IERC20(USDTAddress).approve(address(_uniswapV2Router), 2 ** 256 - 1);


        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x000000000000000000000000000000000000dEaD)] = true;
        _isExcludedFromFee[address(_uniswapV2Router)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        _approve(_msgSender(), address(_tokenDistributor), 2 ** 256 - 1);
        _approve(address(_tokenDistributor), _msgSender(), 2 ** 256 - 1);


    }




    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external override view returns (address) {
        return owner();
    }
    /**
     * @dev Returns the token decimals.
   */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
    * @dev Returns the token symbol.
   */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }
    /**
    * @dev Returns the token name.
  */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
 * @dev See {BEP20-totalSupply}.
   */

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }


    /**
 * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    /**
     * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
* @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }



    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }
    /**
 * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }


    function setDestoryFee(uint256 fee) onlyOwner public{
        destroyFeeRate=fee;
    }

    function setDividendFee(uint256 fee) onlyOwner public{
        dividendFeeRate=fee;
    }
    function setDividendTotal(uint256 total) onlyOwner public{
        dividendTotal=total;
    }

        function setMinSwapAmount(uint256 amount) onlyOwner public{
        minSwapAmount=amount;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        require(!_marketList[sender], "ERC20: market is not enabled");
        require(!_marketList[recipient], "ERC20: market is not enabled");

        uint256 fee=0;


        if(_swapPairList[sender] || _swapPairList[recipient]){
            fee=destroyFeeRate.add(dividendFeeRate);
        }

        if(_isExcludedFromFee[sender]||_isExcludedFromFee[recipient]){
            fee=0;
        }
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount.mul(10000-fee).div(10000));
        emit Transfer(sender, recipient, amount.mul(10000-fee).div(10000));
        _balanceChange(recipient);
        _balanceChange(sender);

        if(fee>0 && (_swapPairList[sender] || _swapPairList[recipient])){
            _fee(sender, amount, fee);
        }


        uint256 contractTokenBalance = _balances[address(this)];
        if(sender!=address(this)&& sender!=address(uniswapV2Pair)&& sender!=owner()&& recipient !=owner()){
            swapTokensForTokens(contractTokenBalance);
        }
        _startDividendUsdt();

    }



    function _startDividendUsdt() private{

        IERC20 usdt=   IERC20(USDTAddress);


        uint256 usdtBalance=   usdt.balanceOf(address(this));

        if(usdtBalance<dividendMinUsdt){
            return;
        }

        uint256 totalAmount;

        for(uint i=0;i<_dividendList.length;i++){
            address addr=_dividendList[i];
            if(addr!=address(0)){
              uint256 balance=      _balances[addr];
              if(balance>dividendTotal)
                totalAmount =totalAmount.add(balance);
            }
        }


        for(uint i=0;i<_dividendList.length;i++){
            address addr=_dividendList[i];
            if(addr!=address(0)){
              uint256 balance=      _balances[addr];
              if(balance>dividendTotal){
                    uint256 usdtAmount=  usdtBalance.mul(balance).div(totalAmount) ;
                    uint256 usdtA=  usdt.balanceOf(address(this));
                    if( usdt.balanceOf(address(this))>=usdtAmount){
                        usdt.transfer(addr,usdtAmount); 
                        emit DvidendUsdt(addr,usdtAmount,balance,usdtBalance,usdtA) ;     
                    }else{
                        emit DvidendUsdt(addr,usdtAmount,balance,usdtBalance,usdtA) ;         
                    }
                }
            }
        }
    }

    function _fee(address sender, uint256 amount, uint256 rate) private {
        if (rate == 0) return;
            address dividend=address(this);

        if(destroyFeeRate>0){
            address destory=address(0x000000000000000000000000000000000000dEaD);
            _balances[destory] = _balances[destory].add(amount.mul(destroyFeeRate).div(10000));
            emit Transfer(sender, destory, amount.mul(destroyFeeRate).div(10000));
        }

        if(dividendFeeRate>0){
            uint256 feeBalance=amount.mul(dividendFeeRate).div(10000);
            _balances[dividend] = _balances[dividend].add(feeBalance);
            emit Transfer(sender, dividend, feeBalance);
        }


    }


    function swapTokensForTokens(uint256 admount) private{
        _approve(address(this), address(uniswapV2Router), admount);
        if(admount>minSwapAmount){
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = USDTAddress;
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(admount, 0, path, address(_tokenDistributor), block.timestamp);
        }

        IERC20 usdt=IERC20(USDTAddress);
        if(usdt.balanceOf(address(_tokenDistributor))>1000){
            usdt.transferFrom(address(_tokenDistributor),address(this),usdt.balanceOf(address(_tokenDistributor)));
        }
    }



    function dividendStatus(address addr) public view returns(uint256,address,uint){
       uint index= _getDividendListIndex(addr);
        return(_balances[addr],_dividendList[index],index);
    }



    struct DividendAddress {
        address wallet;
        uint256 amount;
    }


    function viewDividendList() public view returns(DividendAddress[] memory){
        uint total=_dividendList.length;
        DividendAddress[] memory list = new DividendAddress[](total);
        for(uint i=0;i<_dividendList.length;i++){
            address a=   _dividendList[i];
            DividendAddress memory item  =DividendAddress(a,_balances[a]);
            list[i]=item;

        }
        return(list);
    }



   function _balanceChange(address addr) private {

        if(_swapPairList[addr] ||addr==address(this) || addr==owner()){
            return;
        }



        if(_balances[addr]>=dividendTotal){
            bool next=true;
            for(uint i=0;i<_dividendList.length;i++){
                if(_dividendList[i]==addr){
                    next=false;
                }  
            }
            if(next){
                _dividendList.push(addr);
            }
        }else{
             _dividendListRemove(addr);
        }
    }


    function _dividendListRemove(address addr)private {

         for(uint i=0;i<_dividendList.length;i++){
            if(_dividendList[i]==addr){
                delete _dividendList[i];
            }
         }   
    }


    function _getDividendListIndex(address addr)private view returns(uint) {
         for(uint i=0;i<_dividendList.length;i++){
            if(_dividendList[i]==addr){
                return i;
            }
         } 
         return 0;  
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender,
            _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

}

/**
 * 合约开发 
 * telegram : wyll365
 * 区块链开发 , 合约开发, Web3开发
 * 
 */
contract AAAPubToken is AbsHiToken{
    constructor() AbsHiToken("Relay Race","RYR",18,1000000000000){
    }
}