/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner =0xAb31e7394F30a5aE1de09E2B12388fc789AEE0Fd;
        emit OwnershipTransferred(address(0), _owner);
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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract LUPUS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "LUPUS";
    string private _symbol = "LUPUS";
    uint256 private _decimals = 18;

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _balanceLimit;
    mapping(address => uint256) internal _tokenBalance;
    
    mapping (address => bool) public _blackList;
    mapping (address => bool) public _maxAmount;
    mapping (address => bool) public _maxWallet;
    mapping(address => mapping(address => uint256)) internal _allowances;
    

    uint256 private constant MAX = ~uint256(0);
    uint256 internal _tokenTotal = 1_000_000_000_000_000 * (10**_decimals);
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));

    mapping(address => bool) isTaxless;
    mapping(address => bool) internal _isExcluded;
    address[] internal _excluded;
    
    
    uint256 public _feeDecimal = 2; // do not change this value...
    //buy taxes
    uint256 public _taxFee = 100; // means 1% which distribute to all holders reflection fee
    uint256 public _marketingFee= 100;// means 1% marketing Wallet
    uint256 public _liquidityFee = 500;// means 5% liquidityFee to liquidity
    uint256 public _developmentFee = 300;// means 3% for development wallet
    uint256 public _manualBurnBackFee = 100; // means 1% for burnbAck wallet
    
    //sell taxes
    uint256 public _SellmarketingFee=500;// meanse 2%  for marketing wallet
    uint256 public _SelldevelopmentFee = 200;// means 2% for development wallet
    uint256 public _SellmanualBurnBackFee = 400; // means 4% for burnbAck wallet

    //transfer taxes 
    uint256 public _TransfermarketingFee=500;// meanse 2%  for marketing wallet
    uint256 public _TransferdevelopmentFee = 200;// means 2% for development wallet
    uint256 public _TransfermanualBurnBackFee = 300; // means 3% for burnbAck wallet

    
    
    address private marketingAddress=0x06b63c3cdfB1A8ddD984F1401901f72b00bE4A62;
    address private developmentAddress=0xbB5BFAE5e68F6cd6e6FF0B67A2454421f5dc01A9;
    address private manualBuybackAddress=0xc8D3491a5c547F6E4A74C97a5815e2D89F540411;
    address private liquidityFeeAddress=0x26f1C9EA2b01D0a73aE98B63B8773D8b12214681;
    address DEADADDRESS = address(0);

    
    uint256 public _taxFeeTotal;
    uint256 public _burnFeeTotal;
    uint256 public _liquidityFeeTotal;

    bool public isFeeActive = true; // should be true
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private tradingEnable = true;
    
    //Max tx Amount
    uint256 public maxTxAmount = _tokenTotal; // 
    //max Wallet Holdings 1.5 limit
    uint256 public _maxWalletToken =15_000_000_000_000 * (10**_decimals);

    uint256 public minTokensBeforeSwap = 1_000_000 * (10**_decimals);
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived, uint256 tokensIntoLiqudity);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   pcs test network                 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // for BSC Pncake v2
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
      
        isTaxless[owner()] = true;
        isTaxless[address(this)] = true;
        
        
        //Exempt maxTxAmount from Onwer and Contract
        _maxAmount[owner()] = true;
        _maxAmount[address(this)] = true;
        _maxAmount[marketingAddress] =true;
        _maxAmount[developmentAddress] = true;
        _maxAmount[address(uniswapV2Pair)] = true;
        
        //Exempt maxWalletAmount from Owner ,Contract,marketingAddress
        _maxWallet[owner()] = true;
        _maxWallet[DEADADDRESS] = true;
        _maxWallet[marketingAddress] = true;
        _maxWallet[developmentAddress] = true;
        
        _maxWallet[address(uniswapV2Pair)] = true;

        // exlcude pair address and burn address from tax rewards
        _isExcluded[address(uniswapV2Pair)] = true;
        _excluded.push(address(uniswapV2Pair));
        _isExcluded[DEADADDRESS]=true;
        _excluded.push(DEADADDRESS);

        _reflectionBalance[owner()] = _reflectionTotal;
        emit Transfer(address(0),owner(), _tokenTotal);
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

    function totalSupply() public override view returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        virtual
        returns (bool)
    {
       _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        override
        view
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
    ) public override virtual returns (bool) {
        _transfer(sender,recipient,amount);
               
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub( amount,"ERC20: transfer amount exceeds allowance"));
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

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount.sub(tokenAmount.mul(_taxFee).div(10** _feeDecimal + 2)).mul(
                    _getReflectionRate()
                );
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(
            account != address(uniswapV2Router),
            "ERC20: We can not exclude Uniswap router."
        );
        require(!_isExcluded[account], "ERC20: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "ERC20: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
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
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= maxTxAmount || _maxAmount[sender], "Transfer Limit Exceeds");
        require(!_blackList[sender],"Address is blackListed");
        require(tradingEnable,"trading is disable");
    
            
        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();
        
        uint256 constractBal=balanceOf(manualBuybackAddress)
        .add(balanceOf(marketingAddress))
        .add(balanceOf(developmentAddress));
        bool overMinTokenBalance = constractBal >= minTokensBeforeSwap;
        
        if(!inSwapAndLiquify && overMinTokenBalance && sender != uniswapV2Pair && swapAndLiquifyEnabled) {
            
            //marketing
            uint256 marketingBal = balanceOf(marketingAddress);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].sub(marketingBal.mul(rate));
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(marketingBal.mul(rate));

            // //development
            
            uint256 developmentBal = balanceOf(developmentAddress);
             _reflectionBalance[developmentAddress] = _reflectionBalance[developmentAddress].sub(developmentBal.mul(rate));
             _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(developmentBal.mul(rate));

            // //burnBack
            uint256 burnBack = balanceOf(manualBuybackAddress);
            _reflectionBalance[manualBuybackAddress] = _reflectionBalance[manualBuybackAddress].sub(burnBack.mul(rate));
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(burnBack.mul(rate));

            swapAndLiquify(constractBal);
        }
         

        if(sender == uniswapV2Pair) {
            
        if(!_maxWallet[recipient] && recipient != address(this)  && recipient != address(0) && recipient != marketingAddress){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        

            
        if(!isTaxless[sender] && !isTaxless[recipient] && !inSwapAndLiquify){
            transferAmount = collectBuyFee(sender,amount,rate);
        }
        
        //transfer reflection
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        //if any account belongs to the excludedAccount transfer token
        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
        
        return;
       }
       
       if(recipient == uniswapV2Pair){
         if(!isTaxless[sender] && !isTaxless[recipient] && !inSwapAndLiquify){
            transferAmount = collectSellFee(sender,amount,rate);
         }
        
        //transfer reflection
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        //if any account belongs to the excludedAccount transfer token
        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
        
        return;
       }

        //transfer reflection

        if(!isTaxless[sender] && !isTaxless[recipient] && !inSwapAndLiquify){
            transferAmount = collectTransferFee(sender,amount,rate);
        }
       
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        //if any account belongs to the excludedAccount transfer token
        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
        
    }
    
    function collectBuyFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev tax fee
        if(_taxFee != 0){
            uint256 taxFee = amount.mul(_taxFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(taxFee);
            _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));
            _taxFeeTotal = _taxFeeTotal.add(taxFee);
        }
      
        //@dev burn fee
        if(_marketingFee != 0){
            uint256 marketingFee = amount.mul(_marketingFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(marketingFee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(marketingFee.mul(rate));
            if(_isExcluded[marketingAddress]){
                _tokenBalance[marketingAddress] = _tokenBalance[marketingAddress].add(marketingFee);
            }
          
            emit Transfer(account,marketingAddress,marketingFee);
        }

        if(_developmentFee != 0){
            uint256 developmentFee = amount.mul(_developmentFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(developmentFee);
            _reflectionBalance[developmentAddress] = _reflectionBalance[developmentAddress].add(developmentFee.mul(rate));
            if(_isExcluded[developmentAddress]){
                _tokenBalance[developmentAddress] = _tokenBalance[developmentAddress].add(developmentFee);
            }
            emit Transfer(account,developmentAddress,developmentFee);
        }
        
        if(_liquidityFee != 0){
            uint256 liquidityFee = amount.mul(_liquidityFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[liquidityFeeAddress] = _reflectionBalance[liquidityFeeAddress].add(liquidityFee.mul(rate));
            if(_isExcluded[liquidityFeeAddress]){
                _tokenBalance[liquidityFeeAddress] = _tokenBalance[liquidityFeeAddress].add(liquidityFee);
            }
          
            emit Transfer(account,liquidityFeeAddress,liquidityFee);
        }

        if(_manualBurnBackFee != 0){
            uint256 buyBurnFee = amount.mul(_manualBurnBackFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(buyBurnFee);
            _reflectionBalance[manualBuybackAddress] = _reflectionBalance[manualBuybackAddress].add(buyBurnFee.mul(rate));
            if(_isExcluded[manualBuybackAddress]){
                _tokenBalance[manualBuybackAddress] = _tokenBalance[manualBuybackAddress].add(buyBurnFee);
            }
            emit Transfer(account,manualBuybackAddress,buyBurnFee);
        }
        
        return transferAmount;
    }
    
    
    function collectSellFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
      
        //@dev burn fee
        if(_SellmarketingFee != 0){
            uint256 marketingFee = amount.mul(_SellmarketingFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(marketingFee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(marketingFee.mul(rate));
            if(_isExcluded[marketingAddress]){
                _tokenBalance[marketingAddress] = _tokenBalance[marketingAddress].add(marketingFee);
            }
          
            emit Transfer(account,marketingAddress,marketingFee);
        }

          //@dev burn fee
        if(_SelldevelopmentFee != 0){
            uint256 developmentFee = amount.mul(_SelldevelopmentFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(developmentFee);
            _reflectionBalance[developmentAddress] = _reflectionBalance[developmentAddress].add(developmentFee.mul(rate));
            if(_isExcluded[developmentAddress]){
                _tokenBalance[developmentAddress] = _tokenBalance[developmentAddress].add(developmentFee);
            }
          
            emit Transfer(account,developmentAddress,developmentFee);
        }

        if(_SellmanualBurnBackFee != 0){
            uint256 buyBurnFee = amount.mul(_SellmanualBurnBackFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(buyBurnFee);
            _reflectionBalance[manualBuybackAddress] = _reflectionBalance[manualBuybackAddress].add(buyBurnFee.mul(rate));
            if(_isExcluded[manualBuybackAddress]){
                _tokenBalance[manualBuybackAddress] = _tokenBalance[manualBuybackAddress].add(buyBurnFee);
            }
            emit Transfer(account,manualBuybackAddress,buyBurnFee);
        }
        
    
        return transferAmount;
    }


    function collectTransferFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
      
        //@dev burn fee
        if(_TransfermarketingFee != 0){
            uint256 marketingFee = amount.mul(_TransfermarketingFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(marketingFee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(marketingFee.mul(rate));
            if(_isExcluded[marketingAddress]){
                _tokenBalance[marketingAddress] = _tokenBalance[marketingAddress].add(marketingFee);
            }
          
            emit Transfer(account,marketingAddress,marketingFee);
        }

          //@dev burn fee
        if(_TransferdevelopmentFee != 0){
            uint256 developmentFee = amount.mul(_TransferdevelopmentFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(developmentFee);
            _reflectionBalance[developmentAddress] = _reflectionBalance[developmentAddress].add(developmentFee.mul(rate));
            if(_isExcluded[developmentAddress]){
                _tokenBalance[developmentAddress] = _tokenBalance[developmentAddress].add(developmentFee);
            }
          
            emit Transfer(account,developmentAddress,developmentFee);
        }

        if(_TransfermanualBurnBackFee != 0){
            uint256 buyBurnFee = amount.mul(_TransfermanualBurnBackFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(buyBurnFee);
            _reflectionBalance[manualBuybackAddress] = _reflectionBalance[manualBuybackAddress].add(buyBurnFee.mul(rate));
            if(_isExcluded[manualBuybackAddress]){
                _tokenBalance[manualBuybackAddress] = _tokenBalance[manualBuybackAddress].add(buyBurnFee);
            }
            emit Transfer(account,manualBuybackAddress,buyBurnFee);
        }
        
    
        return transferAmount;
    }

    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }
    
    
    
      function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         if(contractTokenBalance > maxTxAmount){
             contractTokenBalance = maxTxAmount;
         }
        // split the contract balance into halves

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(contractTokenBalance); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // add bnb to wallets 

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 marketingFee = newBalance.mul(_SellmarketingFee).div(10**(_feeDecimal + 2));
        uint256 newAmountWithOutMarketing = newBalance.sub(marketingFee);
        payable(marketingAddress).transfer(marketingFee);

        uint256 developmentFee = newAmountWithOutMarketing.mul(_SelldevelopmentFee).div(10**(_feeDecimal + 2));
        uint256 amountWithOutDevelopment = newAmountWithOutMarketing.sub(developmentFee);
        payable(developmentAddress).transfer(developmentFee);

        uint256 burnBackFee = amountWithOutDevelopment.mul(_SellmanualBurnBackFee).div(10**(_feeDecimal + 2));
        payable(manualBuybackAddress).transfer(burnBackFee);

    }
    
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function setPair(address pair) external onlyOwner {
        uniswapV2Pair = pair;
    }

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }
    
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
    function setFeeActive(bool value) external onlyOwner {
        isFeeActive = value;
    }
    
    function setBuyFee(
    uint256 marketingFee,
    uint256 developmentFee,
    uint256 liquidityFee,
    uint256 taxFee,
    uint256 burnBackFee
    ) external onlyOwner {
        _developmentFee=developmentFee;
        _manualBurnBackFee=burnBackFee;
        _marketingFee=marketingFee;
        _liquidityFee=liquidityFee;
        _taxFee=taxFee;
    }
    
    function setSellFee(
    uint256 marketingFee,
    uint256 developmentFee,
    uint256 burnBackFee) external onlyOwner {
        _SellmarketingFee=marketingFee;
        _SelldevelopmentFee=developmentFee;
        _SellmanualBurnBackFee=burnBackFee;
    }

    function setTransferFee(
    uint256 marketingFee,
    uint256 developmentFee,
    uint256 burnBackFee) external onlyOwner {
        _TransfermarketingFee=marketingFee;
        _TransferdevelopmentFee=developmentFee;
        _TransfermanualBurnBackFee=burnBackFee;
    }
    
    function setWalletAddress(
    address _marketingAddress,
    address _developmentAddress,
    address _manualBurnBackAddress
    ) external onlyOwner{
        marketingAddress=_marketingAddress;
        developmentAddress = _developmentAddress;
        manualBuybackAddress = _manualBurnBackAddress;
    }
    
     function setBlackList (address add,bool value) external onlyOwner {
        _blackList[add]=value;
    }
    
    function setTrading(bool value) external onlyOwner {
        tradingEnable= value;
    }
    
    function exemptMaxTxAmountAddress(address _address,bool value) external onlyOwner {
        _maxAmount[_address] = value;
    }
    
    function exemptMaxWalletAmountAddress(address _address,bool value) external onlyOwner {
        _maxWallet[_address] =value;
    }
    
    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        _maxWalletToken = amount * (10**_decimals);
    }
 
    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount * (10**_decimals);
    }
    
    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner {
        minTokensBeforeSwap = amount * (10**_decimals);
    }

    receive() external payable {}
}