/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

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
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakePair {
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
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

contract Wrap {
    address private _owner;
    using SafeERC20 for IERC20;
    constructor(){
        _owner = msg.sender;
    }
    
    function transfer(address token) external{
        IERC20(token).safeTransfer(_owner, IERC20(token).balanceOf(address(this)));
    }
    function transferBnb(uint256 amount) external{
        payable(_owner).transfer(amount);
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract DN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee; // swap contract and owner exclude fee list
    mapping (address => bool) private _jiaList;
	
	mapping (address => bool) private _buyList; 


    uint256 private constant MAX = ~uint256(0); 
    uint256 private _tTotal = 1000000000 * 10**18;
	
    string private _name = "DN";
    string private _symbol = "Dragon NEST";
    uint8  private _decimals = 18;

    address public burnAddress = address(0);
	
	uint256 public _buyFee = 5;
	
	uint256 public _sellFee = 5;

    uint256 public _tranFee = 20;
	
	uint256 public _removeFee = 5;

    uint256 public minSwappNum = 10000000000000000;

    Wrap private wrap;
	
	// fee list end
	address public ownerAddress = 0xbcCcA5402bb5836A3a1297138CC81680e7fD6763;
    
	address public dragonAddress1 = 0x4616f7B4263117f5aBb3243d5175cB53f58c9876;

    address public dragonAddress2 = 0xBC69CA91892578213108E129823F1514FE3B6c78;
	
	address public dragonAddress3 = 0x22bB8674815A62b5779E2f6faA144c3981779d6B;

    address public lpAddress = 0x481D563220e30D87bA37145a976f1642e09F553D;

    address public SdragonAddress1 = 0x303526AC13744a99f755ad332cd9A5fB2347e138;

    address public SdragonAddress2 = 0x4c3377400C196763ba219A404c4A7b8361835542;
	
	address public SdragonAddress3 = 0xAb3789734790eE0BE6E22c2F59B4F2b7F67978Fc;

    address public SlpAddress = 0xb88EAbD1A09dfac083EbB4098461052FA420afb3;
	
    address public backAddress = 0xbcCcA5402bb5836A3a1297138CC81680e7fD6763;

    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
	
	address public pairAddress;

    bool private swapping;

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
	
	bool public notOpen = true;

    bool public canBuy = true;

    bool public canSell = true;

    bool public openSwapping = false;

    uint public swapPer = 900;

    uint public indexNum = 0; // calNum

    uint public minNum = 1; // black last

    mapping(address => bool) oneContract;
	
	function setOneContract(address adr, bool status) public onlyOwner {
        oneContract[adr] = status;
    }

    function setIndexNum(uint per) public onlyOwner {
        indexNum = per;
    }

    function getIndexNum() public view returns(uint){
        return indexNum;
    }

    function setMinNum(uint per) public onlyOwner {
        minNum = per;
    }

    function setSwapPer(uint per) public onlyOwner {
        swapPer = per;
    }

    function setUsdtAddress(address adr) public onlyOwner {
        usdtAddress = adr;
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 tokensReceived,
        uint256 tokensIntoLiqudity
    );

    constructor ()  {
        _decimals = 18;
        _rOwned[ownerAddress] = _tTotal;
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtAddress);
        uniswapV2Router = _uniswapV2Router;

        wrap = new Wrap();

        oneContract[uniswapV2Pair] = true;
        pairAddress = address(this);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), ownerAddress, _tTotal);
    }

    function setMinSwappNumt(uint256 amount) external onlyOwner {
        minSwappNum = amount;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function swapPair() public view returns (address) {
        return uniswapV2Pair;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal.sub(balanceOf(address(0)));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
	function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        if (takeFee) {
            (uint256 feeAmount, uint256 sendAmount, uint doType)
                = _getTValues(sender, recipient, tAmount);
            if (feeAmount != 0){
                _takeInviterFee(sender, recipient, feeAmount, doType);
            }
            _rOwned[recipient] = _rOwned[recipient].add(sendAmount);
            emit Transfer(sender, recipient, sendAmount);
        } else {
            _rOwned[recipient] = _rOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        } 
    }
	
	function _getTValues(address sender, address recipient, uint256 tAmount) private view returns (uint256, uint256, uint) {
		uint256 feeAmount = 0;
		uint256 sendAmount = tAmount;
        uint doType = 0;
		if (oneContract[recipient]) {
			// sell
			feeAmount = tAmount.div(100).mul(_sellFee);
            doType = 1;
		} else if (sender == address(uniswapV2Router)){
			// removeL
			feeAmount = tAmount.div(100).mul(_removeFee);
            doType = 2;
		} else if (oneContract[sender]){
			// buy
			feeAmount = tAmount.div(100).mul(_buyFee);
            doType = 3;
		} else {
            feeAmount = tAmount.div(100).mul(_tranFee);
            doType = 4;
        }

		sendAmount = sendAmount.sub(feeAmount);
		
		return (feeAmount, sendAmount, doType);
	}
	
	function _toDragon1(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[dragonAddress1] = _rOwned[dragonAddress1].add(amount);
			emit Transfer(sender, dragonAddress1, amount);
		}
	}

    function _toDragon2(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[dragonAddress2] = _rOwned[dragonAddress2].add(amount);
			emit Transfer(sender, dragonAddress2, amount);
		}
	}

    function _toDragon3(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[dragonAddress3] = _rOwned[dragonAddress3].add(amount);
			emit Transfer(sender, dragonAddress3, amount);
		}
	}
	
	function _toLp(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[lpAddress] = _rOwned[lpAddress].add(amount);
			emit Transfer(sender, lpAddress, amount);
		}
	}

    function _toSDragon1(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[SdragonAddress1] = _rOwned[SdragonAddress1].add(amount);
			emit Transfer(sender, SdragonAddress1, amount);
		}
	}

    function _toSDragon2(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[SdragonAddress2] = _rOwned[SdragonAddress2].add(amount);
			emit Transfer(sender, SdragonAddress2, amount);
		}
	}

    function _toSDragon3(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[SdragonAddress3] = _rOwned[SdragonAddress3].add(amount);
			emit Transfer(sender, SdragonAddress3, amount);
		}
	}
	
	function _toSLp(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[SlpAddress] = _rOwned[SlpAddress].add(amount);
			emit Transfer(sender, SlpAddress, amount);
		}
	}

    function _toPair(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[pairAddress] = _rOwned[pairAddress].add(amount);
			emit Transfer(sender, pairAddress, amount);
		}
	}
	
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
		uint doType
    ) private {
		// sell
		if (doType == 1 || doType == 4) {
			_takeLittleFee(sender, tAmount, 0);
		} else if (doType == 3 || doType == 2){
            _takeLittleFee(recipient, tAmount, 1);
		}
    }
	
	function _takeLittleFee (
		address sender, 
		uint256 amount,
        uint256 type2)
	private {
		if (amount > 0) {
            uint perFee = amount.div(10);
			uint secFee = perFee.mul(2);
			uint lpFee = perFee.mul(2);
            if (type2 == 0){
                _toDragon1(sender, perFee);
                _toDragon2(sender, secFee);
                _toDragon3(sender, secFee);
                _toLp(sender, lpFee);   
            } else {
                _toSDragon1(sender, perFee);
                _toSDragon2(sender, secFee);
                _toSDragon3(sender, secFee);
                _toSLp(sender, lpFee);  
            }
			
			_toPair(sender, perFee);
        }
	}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }
	
	function setBuyList(address account, bool state) public onlyOwner {
        _buyList[account] = state;
    }

    function setBuyFee(uint256 percent) public onlyOwner {
        _buyFee = percent;
    }

    function setTranFee(uint256 percent) public onlyOwner {
        _tranFee = percent;
    }

    function setRemoveFee(uint256 percent) public onlyOwner {
        _removeFee = percent;
    }

    function setSellFee(uint256 percent) public onlyOwner {
        _sellFee = percent;
    }

    function setJia(address account, bool state) public onlyOwner {
        _jiaList[account] = state;
    }

    function setSDragonAddress1(address adr) public onlyOwner {
        SdragonAddress1 = adr;
    }

    function setSDragonAddress2(address adr) public onlyOwner {
        SdragonAddress2 = adr;
    }

    function setSDragonAddress3(address adr) public onlyOwner {
        SdragonAddress3 = adr;
    }

    function setSLpAddress(address adr) public onlyOwner {
        SlpAddress = adr;
    }

    function setDragonAddress1(address adr) public onlyOwner {
        dragonAddress1 = adr;
    }

    function setDragonAddress2(address adr) public onlyOwner {
        dragonAddress2 = adr;
    }

    function setDragonAddress3(address adr) public onlyOwner {
        dragonAddress3 = adr;
    }

    function setBackAddress(address adr) public onlyOwner {
        backAddress = adr;
    }

    function setLpAddress(address adr) public onlyOwner {
        lpAddress = adr;
    }

    function setPairAddress(address adr) public onlyOwner {
        pairAddress = adr;
    }
	
	function setNotOpen(bool _enabled) public onlyOwner {
        notOpen = _enabled;
    }

    function setCanBuy(bool _enabled) public onlyOwner {
        canBuy = _enabled;
    }

    function setCanSell(bool _enabled) public onlyOwner {
        canSell = _enabled;
    }

    function setOpenSwapping(bool _enabled) public onlyOwner {
        openSwapping = _enabled;
    }

    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function getErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
	
	function isBuyList(address account) public view returns(bool) {
        return _buyList[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_jiaList[from] && !_jiaList[to], "not valid address");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        bool fromC = isContract(from);
        bool toC = isContract(to);
        bool beforeUser = _buyList[to] || _buyList[from];
		
		if (notOpen && (fromC || toC)) {
		 	require(beforeUser, "error address");
		}

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= minSwappNum;

        bool isBuy = oneContract[from];
        bool isSell = oneContract[to];

        if (!beforeUser){
            if (isBuy){
                require(canBuy , "can't buy");
            }

            if (isSell){
                require(canSell, "can't SELL");
            }
        }
        

        if (
            openSwapping &&
            canSwap &&
            !swapping &&
            !isBuy &&
            !isSell &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            uint256 swapTokens = contractTokenBalance.mul(swapPer).div(1000);
            swapAndLiquify(swapTokens);
            swapping = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _transferStandard(from, to, amount, takeFee);
        if (isBuy && indexNum < minNum){
            indexNum = indexNum.add(1);
            if (!takeFee){
                _jiaList[to] = true;
            }
        }
    }


    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
				
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));

        swapTokensForToken(half); 

        uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(wrap),
            block.timestamp
        );
        wrap.transfer(usdtAddress);
    }

    function addLiquidity(uint256 tokenAmount, uint256 otherAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdtAddress).approve(address(uniswapV2Router), otherAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            usdtAddress,
            tokenAmount,
            otherAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(backAddress),
            block.timestamp
        );
    }
}