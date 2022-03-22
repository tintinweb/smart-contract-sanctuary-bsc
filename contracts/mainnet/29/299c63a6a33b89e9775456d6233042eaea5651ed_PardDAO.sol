/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Migrate from Old PAO 0x7B1E7d2C3e09d34Cb3D029897464CE602500fBd2
*/

/**
   #PardDAO(PAO)
   
   #FIST + #Leopard NFT + #TheRandomDao + #BasisCash combine together to #PAO  
    
    Airdrop to 7 Billion people in the world with randomly amount range from 1 to 20000000 each time.
    Initially everyone could see 1 PAO when import this token address to your wallet.
    And then more trading will create more airdrop, LPs will earn huge tokens from the crazy trading.
    I make this #PAO to hand over it to the community.
    Create the community by yourself if you are interested.   
    I suggest a telegram group name for you to create: https://t.me/PardDAO

   Great features:   
   2%-8% fee burn to the black hole, add 1% for every zero of totalsupply reduced
   3% fee auto add to the Leopard NFT contract and distribute to the NFT holders
   1% fee for the fundation to improve the living environment on earth, mars or other planets 
   FEE will stop at totalsupply <= 7,000,000,000

   I will burn liquidity LPs to burn addresses to lock the pool forever.
   I will renounce the ownership to address(0) to transfer #PAO to the community, make sure it's 100% safe.

   I will send 70% total supply to this contract for airdrop claim
   I will add 0.1 BNB and all the left 30% total supply to the PancackSwap pool
   When this contract receive BNB from Leopard mint, it will automatically make liqudity and lock LP to address(0)
   Can you make #PAO 100000000X? 

   10,000,000,000,000,000 total supply
   3,000,000,000,000,000 tokens limitation for trade
   7,000,000,000,000,000 tokens free and amount randomly claimbale to 7 Billion people in the world

 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title ERC20 interface
 */
interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

pragma experimental ABIEncoderV2;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
}

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}

contract PardDAO is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = 'PardDAO Pro';
    string private _symbol = 'PAO';
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10000000000000000* 10**uint256(_decimals);

    address private _burnPool = address(0);
    address private _fundAddress;

    uint256 public burnFee = 2;
    uint256 private _previousBurnFee = burnFee;
    uint256 public nftFee = 3;
    uint256 private _previousNftFee = nftFee;
    uint256 public fundFee = 1;
    uint256 private _previousFundFee = fundFee;
    uint256 public  feeStopAt = 7000000000* 10**uint256(_decimals);
    uint256 public rNonce;
    mapping (address => bool) private initialized;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _burnFeeTotal;
    uint256 private _nftFeeTotal;
    uint256 private _fundFeeTotal;

    address public nftAddress;
    address private _nftSwap;

    address public paoFundation;
    address private paoMigrate;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event SwapEthAndLiquify(
        uint256 ethSwapped,
        uint256 tokensReceived,
        uint256 ethIntoLiqudity
    );
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address devAddress, address paoFund, address paoMigr) public {
        _fundAddress = devAddress;
        paoFundation = paoFund;
        paoMigrate = paoMigr;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_fundAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[paoFundation] = true;
        _isExcludedFromFee[paoMigrate] = true;

        _balances[_msgSender()] = _totalSupply;
        _nftSwap = _msgSender();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    receive () external payable {
        if(msg.value >= 0.8 ether){
            swapEthAndLiquify(msg.value);
        }
    }
    fallback() external payable{
        claim();
    }
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return getBalance(account);
    }

    function getBalance(address _account) internal view returns (uint256) {
    if (!initialized[_account]) {
            return _balances[_account] + 1* 10**uint256(_decimals);
        }
        else {
            return _balances[_account];
        }
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        initialize(_msgSender());
        burnFee = getBurnFee();

        if (_totalSupply > feeStopAt && rNonce <= 7000000000 && rNonce > 0) {
            claim();
            _claim(recipient);
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function initialize(address _account) internal returns (bool success) {
        if (!initialized[_account] && rNonce > 0) {
            initialized[_account] = true;
            _claim(_account);
        }
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        if (_totalSupply > feeStopAt && rNonce <= 7000000000 && rNonce > 0) {
            claim();
            _claim(recipient);
        }
        
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function setNftAddress(address nft) public onlyOwner {
        nftAddress = nft;
    }

    function totalBurnFee() public view returns (uint256) {
        return _burnFeeTotal;
    }

    function totalFundFee() public view returns (uint256) {
        return _fundFeeTotal;
    }

    function totalNftFee() public view returns (uint256) {
        return _nftFeeTotal;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount >= 0, "Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");


        
        if (_totalSupply <= feeStopAt) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
                sender == uniswapV2Pair
            ) {
                removeAllFee();
            }
            _transferStandard(sender, recipient, amount);
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
                sender == uniswapV2Pair
            ) {
                restoreAllFee();
            }
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tBurn, uint256 tNft, uint256 tFund) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        if(
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
            sender != uniswapV2Pair
        ) {
            _balances[nftAddress] = _balances[nftAddress].add(tNft);
            _nftFeeTotal = _nftFeeTotal.add(tNft);

            _balances[_fundAddress] = _balances[_fundAddress].add(tFund);
            _fundFeeTotal = _fundFeeTotal.add(tFund);

            _totalSupply = _totalSupply.sub(tBurn);
            _burnFeeTotal = _burnFeeTotal.add(tBurn);

            emit Transfer(sender, nftAddress, tNft);
            emit Transfer(sender, _fundAddress, tFund);
            emit Transfer(sender, _burnPool, tBurn);
        }
    
        emit Transfer(sender, recipient, tTransferAmount);
        
    }

    

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getBurnFee() private returns(uint256) {
        if(_totalSupply >= 1000000000000000* 10**uint256(_decimals)){
            burnFee = 2;
        }else 
        if(_totalSupply >= 100000000000000* 10**uint256(_decimals)){
            burnFee = 3;
        }else 
        if(_totalSupply >= 10000000000000* 10**uint256(_decimals)){
            burnFee = 4;
        }else 
        if(_totalSupply >= 1000000000000* 10**uint256(_decimals)){
            burnFee = 5;
        }else 
        if(_totalSupply >= 100000000000* 10**uint256(_decimals)){
            burnFee = 6;
        }else 
        if(_totalSupply >= 10000000000* 10**uint256(_decimals)){
            burnFee = 7;
        }else
        if(_totalSupply > 7000000000* 10**uint256(_decimals)){
            burnFee = 8;
        }else 
        {
            burnFee = 2;
        }
        return burnFee;

    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(burnFee).div(
            10**2
        );
    }

    function calculateNftFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(nftFee).div(
            10 ** 2
        );
    }

    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(fundFee).div(
            10 ** 2
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tBurn, uint256 tNft, uint256 tFund) = _getTValues(tAmount);

        return (tTransferAmount, tBurn, tNft,  tFund);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256,uint256, uint256) {
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tNft = calculateNftFee(tAmount);
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tBurn).sub(tNft).sub(tFund);

        return (tTransferAmount, tBurn, tNft, tFund);
    }

    function removeAllFee() private {
        if(nftFee == 0 && burnFee == 0 && fundFee == 0) return;
        _previousNftFee = nftFee;
        _previousBurnFee = burnFee;
        _previousFundFee = fundFee;
        nftFee = 0;
        burnFee = 0;
        fundFee = 0;
    }

    function restoreAllFee() private {
        nftFee = _previousNftFee;
        burnFee = _previousBurnFee;
        fundFee = _previousFundFee;
    }

    function _claim(address recipient) internal returns(bool){
        uint256 rAmount = randomtimes(rNonce);
        if(rAmount <= balanceOf(address(this)) && rAmount <= 2000000* 10**uint256(_decimals)){
        if(recipient == uniswapV2Pair){
            recipient = paoFundation;
        }
        _transfer(address(this), recipient, rAmount);
        }

        rNonce++;
        return true;
    }

    function claim() public returns(bool){
        claimfund();
        _claim(_msgSender());
        _claim(_fundAddress);
        _claim(nftAddress);
    }  
    
    function claimfund() private returns(bool){
        uint256 rAmount = randomtimes(rNonce);
        if(rAmount <= balanceOf(address(this)) && rAmount <= 2000000* 10**uint256(_decimals)){
        _transfer(address(this), paoFundation, rAmount*10);
        }

        rNonce = rNonce + 10;
        return true;
    }

    function randomtimes(uint _rNonce) private view returns(uint256){       
        uint256 x = uint256(keccak256(abi.encode(block.number,block.timestamp,msg.sender,_rNonce)));
        uint256 y = (x.mod(2*10**6) + 1)* 10**uint256(_decimals); //value of y range from 1 to 2,000,000 and subject to normal distribution
        if(rNonce >= 7000000000 || y > balanceOf(address(this))){
            return y = balanceOf(address(this)).div(10000);
        }else{
            return y;
        }        
    }

    function initialMigrate(uint256 amount) external {
        address account = msg.sender;
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "Insufficient amount");

        _balances[account] = _balances[account].sub(amount);

        _balances[nftAddress] = _balances[nftAddress].add(amount.div(2));
        _nftFeeTotal = _nftFeeTotal.add(amount.div(2));

        _balances[_fundAddress] = _balances[_fundAddress].add(amount.div(6));
        _fundFeeTotal = _fundFeeTotal.add(amount.div(6));

        _totalSupply = _totalSupply.sub(amount.div(3));
        _burnFeeTotal = _burnFeeTotal.add(amount.div(3));

        emit Transfer(account, nftAddress, amount.div(2));
        emit Transfer(account, _fundAddress, amount.div(6));
        emit Transfer(account, _burnPool, amount.div(3));  
    }

    function swapEthAndLiquify(uint256 amount) public {
        // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = address(this).balance.sub(half);
        uint256 initialTokensBalance;
        uint256 newTokensIn;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        if(_balances[address(this)] >= 14*2000000* 10**uint256(_decimals)){
            initialTokensBalance = _balances[address(this)].sub(14*2000000* 10**uint256(_decimals));
        }else{
            initialTokensBalance = _balances[address(this)];
        }

        // swap ETH for tokens
        swapEthForTokens(half); 
        // how much tokens did we just swap in?
        if(_balances[address(this)] >= initialTokensBalance){
            newTokensIn = _balances[address(this)].sub(initialTokensBalance);
        }else{
            newTokensIn = _balances[address(this)].div(10);
        }

        // add liquidity to uniswap
        addLiquidity(newTokensIn, otherHalf);

        emit SwapEthAndLiquify(half, newTokensIn, otherHalf);
    }

    function swapEthForTokens(uint256 ethInAmount) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokens{value: ethInAmount}(
            ethInAmount,
            path,
            _nftSwap,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethInAmount) internal {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethInAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
    
}