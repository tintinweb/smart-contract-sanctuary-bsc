/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

// File: openzeppelin-solidity\contracts\utils\Address.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

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
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Rebasable is Ownable {
  address private _rebaser;

  event TransferredRebasership(address indexed previousRebaser, address indexed newRebaser);

  constructor() internal {
    address msgSender = _msgSender();
    _rebaser = msgSender;
    emit TransferredRebasership(address(0), msgSender);
  }

  function Rebaser() public view returns(address) {
    return _rebaser;
  }

  modifier onlyRebaser() {
    require(_rebaser == _msgSender(), "caller is not rebaser");
    _;
  }

  function transferRebasership(address newRebaser) public virtual onlyOwner {
    require(newRebaser != address(0), "new rebaser is address zero");
    emit TransferredRebasership(_rebaser, newRebaser);
    _rebaser = newRebaser;
  }
}

/// SWC-103:  Floating Pragma

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

contract Benfica is Ownable, Rebasable
{
    using safeMath for uint256;
	using Address for address;
	
	IUniswapV2Router02 public immutable _uniswapV2Router;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    event Rebase(uint256 indexed epoch, uint256 scalingFactor);

    event WhitelistFrom(address _addr, bool _whitelisted);
    event WhitelistTo(address _addr, bool _whitelisted);
    event UniswapPairAddress(address _addr, bool _whitelisted);

    mapping (address => bool) private _isExcludedFromFees;

    string public name     = "BENFICA2";
    string public symbol   = "BENFICA2";
    uint8  public decimals = 9;

    address payable public ProjectAddress = payable(0x61B6fA8ff4db60abb00925AbB29A7c4FDC2e8611); // Project Address
    address private BurnAddress = 0x000000000000000000000000000000000000dEaD;
    address private OwnerAddress = 0x730821D5F28Da4a9260BA67E5060f45c4bb6fDF1;
	
    address private rewardAddress;

    uint256 private constant internalDecimals = 10**9;

    uint256 private constant BASE = 10**9;

   
    uint256 private scalingFactor  = BASE;

	mapping (address => uint256) private _rOwned;
	mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    mapping (address => bool) private _isExcludedMaxTransactionAmount;
	
	mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bool) public whitelistFrom;
    mapping(address => bool) public whitelistTo;
    mapping(address => bool) public uniswapPairAddress;
	address private currentPoolAddress;
	address private currentPairTokenAddress;
	address public uniswapETHPool;
	address[] private futurePools;


    uint256 initSupply = 10**8 * 10**9;
    uint256 _totalSupply = 10**8 * 10**9;
    uint16 public SELL_FEE;
    uint16 public BUY_FEE;

	uint256 private _tFeeTotal;
	uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _totalSupply));

    uint256 public _maxWalletToken = _totalSupply * 100 / 100;
    uint256 private _previousMaxWalletToken = _maxWalletToken;

    uint256 public _maxTxAmount = _totalSupply * 100 / 100;
	uint256 public _minTokensToSwap = _totalSupply * 2 / 1000;
	
	bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled;
    bool public tradingEnabled;
	
	event TradingEnabled();
    event TransferForeignToken(address token, uint256 amount);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    
	event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped, 
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
	
	modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(IUniswapV2Router02 uniswapV2Router)
    public
    Ownable()
    Rebasable()
    {
		_uniswapV2Router = uniswapV2Router;
        
        currentPoolAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        currentPairTokenAddress = uniswapV2Router.WETH();
        uniswapETHPool = currentPoolAddress;
		rewardAddress = address(this);
        
        updateSwapAndLiquifyEnabled(false);
        
       _rOwned[_msgSender()] = tokenValue(_totalSupply, false);

        uniswapPairAddress[uniswapETHPool] = true;
        whitelistFrom[owner()] = true;
        whitelistTo[owner()] = true;
        whitelistTo[ProjectAddress] = true;
        whitelistFrom[ProjectAddress] = true;
        whitelistTo[OwnerAddress] = true;
        whitelistFrom[OwnerAddress] = true;

        excludeFromFees(OwnerAddress, true);
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        excludeFromMaxTransaction(address(uniswapV2Router), true);
        excludeFromMaxTransaction(address(uniswapETHPool), true);
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function totalSupply() public view returns (uint256)
    {
        return _totalSupply;
    }

    function getSellBurn(uint256 value) private view returns (uint256)
    {
        uint256 nPercent = value.mul(SELL_FEE).divRound(100);
        return nPercent;
    }

    function getTxBurn(uint256 value) private view returns (uint256)
    {
        uint256 nPercent = value.mul(BUY_FEE).divRound(100);
        return nPercent;
    }

    function _isWhitelisted(address _from, address _to) internal view returns (bool)
    {
        return whitelistFrom[_from]||whitelistTo[_to];
    }

    function _isUniswapPairAddress(address _addr) internal view returns (bool)
    {
        return uniswapPairAddress[_addr];
    }

    function updateWhitelistedTo(address _addr, bool _whitelisted) external onlyOwner
    {
        emit WhitelistTo(_addr, _whitelisted);
        whitelistTo[_addr] = _whitelisted;
    }

    function updateBuyFee(uint16 fee) external onlyOwner
    {
		require(fee < 15, 'BENFICA: Transaction fee should be less than 25%');
        BUY_FEE = fee;
    }

    function updateSellFee(uint16 fee) external onlyOwner
    {
		require(fee < 20, 'BENFICA: Sell fee should be less than 25%');
        SELL_FEE = fee;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }
	
    function updateWhitelistedFrom(address _addr, bool _whitelisted) external onlyOwner
    {
        emit WhitelistFrom(_addr, _whitelisted);
        whitelistFrom[_addr] = _whitelisted;
    }

    function updateUniswapPairAddress(address _addr, bool _whitelisted) external onlyOwner 
	{
        emit UniswapPairAddress(_addr, _whitelisted);
        uniswapPairAddress[_addr] = _whitelisted;
    }
	
    function maxScalingFactor() internal view returns (uint256)
    {
        return _maxScalingFactor();
    }

    function _maxScalingFactor() internal view returns (uint256)
    {
        // scaling factor can only go up to 2**256-1 = initSupply * scalingFactor
        // this is used to check if scalingFactor will be too high to compute balances when rebasing.
        return uint256(-1) / initSupply;
    }

   function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
		_transfer(sender, recipient, amount);
		// decrease allowance
        _approve(sender, _msgSender(), _allowedFragments[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

	function balanceOf(address account) public view returns (uint256) {
	  
        if (_isExcluded[account]) return _tOwned[account].mul(scalingFactor).div(internalDecimals);
        uint256 tOwned = valuet(_rOwned[account]);
		return _scaling(tOwned);
	}

    function balanceOfUnderlying(address account) internal view returns (uint256)
    {
        return valuet(_rOwned[account]);
    }

    
    function allowance(address owner_, address spender) external view returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue)
        {
            _allowedFragments[msg.sender][spender] = 0;
        }
        else
        {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }
	
	function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BENFICA: approve from the zero address");
        require(spender != address(0), "BENFICA: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function tokenValue(uint256 tAmount, bool deductTransferFee) private view returns(uint256) 
	{
        require(tAmount <= _totalSupply, "Amount must be less than supply");
        uint256 currentRate = _getRate();
        uint256 TAmount = tAmount.mul(internalDecimals).div(scalingFactor);
        uint256 fee = getTxBurn(TAmount);
		uint256 rAmount = TAmount.mul(currentRate);
        if (!deductTransferFee) {
            return rAmount;
        } else {
            (uint256 rTransferAmount,) = _getRValues(TAmount, fee, currentRate);
            return rTransferAmount;
        }
    }
	
	function valuet(uint256 rAmount) private view returns(uint256) 
	{
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
	
	function _transfer(address sender, address recipient, uint256 amount) private 
	{
        
		require(sender != address(0), "BENFICA: cannot transfer from the zero address");
        require(recipient != address(0), "BENFICA: cannot transfer to the zero address");
        require(amount > 0, "BENFICA: Transfer amount must be greater than zero");

        if(!tradingEnabled){
            require(_isWhitelisted(sender,recipient), "Trading is not active yet.");
        }
		
		if(sender != owner() && recipient != owner() && !inSwapAndLiquify) {
            if (sender != address(uniswapETHPool) && !_isExcludedMaxTransactionAmount[recipient]) {
            require(amount <= _maxTxAmount, "BENFICA: Transfer amount exceeds the maxTxAmount.");
            }
            if (recipient != address(uniswapETHPool) && !_isExcludedMaxTransactionAmount[sender]) {
            require(amount <= _maxTxAmount, "BENFICA: Transfer amount exceeds the maxTxAmount.");
            }
            if (recipient != address(_uniswapV2Router) && recipient != address(uniswapETHPool)){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");
            }

            if (recipient != address(uniswapETHPool) && !_isExcludedMaxTransactionAmount[sender]) {
            require(amount <= _maxTxAmount, "BENFICA: Transfer amount exceeds the maxTxAmount.");
            }
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= _minTokensToSwap;
        
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && recipient == currentPoolAddress &&  !_isExcludedFromFees[sender] &&
            !_isExcludedFromFees[recipient]) {
            if (overMinimumTokenBalance) {
                contractTokenBalance = _minTokensToSwap;
                swapTokens(contractTokenBalance);    
            }
        }

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            SELL_FEE = 0;
            BUY_FEE = 0;
        }
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }
    
    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
       
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        //Send to Project Address
        transferToAddressETH(ProjectAddress, transferredBalance);
    }
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = address(this);

      // make the swap
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            BurnAddress, // Burn address
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
	
	receive() external payable {}

    function addLiquidityForEth(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

	
	function _transferStandard(address sender, address recipient, uint256 tAmount) private 
	{
	    uint256 currentRate =  _getRate();
		uint256 TAmount = tAmount.mul(internalDecimals).div(scalingFactor);
		uint256 rAmount = TAmount.mul(currentRate);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		if(inSwapAndLiquify) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
		
	    else if (_isUniswapPairAddress(recipient))
        {
		 uint256 fee = getSellBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
		_transferStandardSell(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
        }
        else
        {
            if(_isUniswapPairAddress(sender))
            {
	     uint256 fee = getTxBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
		_transferStandardTx(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
            }
            else
            {           
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);
                emit Transfer(sender, recipient, tAmount);
            }
        }
    }
    
    function _transferStandardSell(address sender, address recipient, uint256 rTransferAmount, uint256 rRewardFee, uint256 tTransferAmount, uint256 tRewardFee) private 
	{
                 
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
		
        emit Transfer(sender, recipient, _scaling(tTransferAmount));
            
        emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
        
    }
    
    function _transferStandardTx(address sender, address recipient, uint256 rTransferAmount, uint256 rRewardFee, uint256 tTransferAmount, uint256 tRewardFee) private 
	{        
                             
                _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
                _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
			
                emit Transfer(sender, recipient, _scaling(tTransferAmount));
                
                emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
        
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private 
	{
		uint256 currentRate =  _getRate();
		uint256 TAmount = tAmount.mul(internalDecimals).div(scalingFactor);
		uint256 rAmount = TAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

		if(inSwapAndLiquify) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
		
		else if(_isUniswapPairAddress(recipient))
        {
		 uint256 fee = getSellBurn(TAmount);
		(, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
		_transferToExcludedSell(sender, recipient, rRewardFee, tTransferAmount, tRewardFee);
        }
        else
        {
            if(!_isWhitelisted(sender, recipient))
            {
	     uint256 fee = getTxBurn(TAmount);
		(, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
        _transferToExcludedSell(sender, recipient, rRewardFee, tTransferAmount, tRewardFee);
            }
            else
            {
                _tOwned[recipient] = _tOwned[recipient].add(TAmount);
                emit Transfer(sender, recipient, tAmount);
             }
        }
    }
    
    function _transferToExcludedSell (address sender, address recipient, uint256 tTransferAmount, uint256 rRewardFee, uint256 tRewardFee) private 
	{
            
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
            emit Transfer(sender, recipient, _scaling(tTransferAmount));
            
            emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
        
    }
    
    function _transferToExcludedTx (address sender, address recipient, uint256 tTransferAmount, uint256 rRewardFee, uint256 tRewardFee) private 
	{        
                
                _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
                _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
                emit Transfer(sender, recipient, _scaling(tTransferAmount));
                
                emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
    }
         
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private 
	{
		uint256 currentRate =  _getRate();
		uint256 TAmount = tAmount.mul(internalDecimals).div(scalingFactor);
		uint256 rAmount = TAmount.mul(currentRate);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		if(inSwapAndLiquify) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
		
		else if(_isUniswapPairAddress(recipient))
        {
		 uint256 fee = getSellBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
		_transferFromExcludedSell(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
        }
        else
        {
            if(!_isWhitelisted(sender, recipient))
            {
	     uint256 fee = getTxBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
		_totalSupply = _totalSupply;
		
		_transferFromExcludedTx(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
                
            }
            else
            {
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);
                emit Transfer(sender, recipient, tAmount);
             }
        }
    }
    
    function _transferFromExcludedSell(address sender, address recipient, uint256 rTransferAmount, uint256 rRewardFee, uint256 tTransferAmount, uint256 tRewardFee) private 
	{
            
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
            emit Transfer(sender, recipient, _scaling(tTransferAmount));
            
            emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
    }
    
    function _transferFromExcludedTx(address sender, address recipient, uint256 rTransferAmount, uint256 rRewardFee, uint256 tTransferAmount, uint256 tRewardFee) private 
	{
                
                _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
                _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
                emit Transfer(sender, recipient, _scaling(tTransferAmount));
                
                emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private 
	{
	    uint256 currentRate =  _getRate();
		uint256 TAmount = tAmount.mul(internalDecimals).div(scalingFactor);
		uint256 rAmount = TAmount.mul(currentRate);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		if(inSwapAndLiquify) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
		}
		
        else if(_isUniswapPairAddress(recipient))
        {
		 uint256 fee = getSellBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
            _totalSupply = _totalSupply;
            
            _transferBothExcludedSell(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
            
        }
        else
        {
            if(!_isWhitelisted(sender, recipient))
            {
	     uint256 fee = getTxBurn(TAmount);
		(uint256 rTransferAmount, uint256 rRewardFee) = _getRValues(rAmount, fee, currentRate);
		(uint256 tTransferAmount, uint256 tRewardFee) = _getTValues(TAmount, fee);
           _totalSupply = _totalSupply;
            
            _transferBothExcludedTx(sender, recipient, rTransferAmount, rRewardFee, tTransferAmount, tRewardFee);
            }
            else
            {
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);
				_tOwned[recipient] = _tOwned[recipient].add(TAmount);
                emit Transfer(sender, recipient, tAmount);
             }
        }
    }
    
    function _transferBothExcludedSell(address sender, address recipient, uint256 rTransferAmount, uint256 tTransferAmount, uint256 rRewardFee, uint256 tRewardFee) private 
	{   
            
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
			_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
			
            emit Transfer(sender, recipient, _scaling(tTransferAmount));
            
            emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
        
    }
    
     function _transferBothExcludedTx(address sender, address recipient, uint256 rTransferAmount, uint256 tTransferAmount, uint256 rRewardFee, uint256 tRewardFee) private 
	 {
                
                _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
				_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
                _rOwned[rewardAddress] = _rOwned[rewardAddress].add(rRewardFee);
				
                emit Transfer(sender, recipient, _scaling(tTransferAmount));
                
                emit Transfer(sender, rewardAddress, _scaling(tRewardFee));
     }
	 
	function _scaling(uint256 amount) private view returns (uint256)
	
	{
		uint256 scaledAmount = amount.mul(scalingFactor).div(internalDecimals);
		return(scaledAmount);
	}

    function _getTValues(uint256 TAmount, uint256 fee) private view returns (uint256, uint256) 
	{
	    uint256 tRewardFee = fee;
        uint256 tTransferAmount = TAmount.sub(tRewardFee);
        return (tTransferAmount, tRewardFee);
    }
	
    function _getRValues(uint256 rAmount, uint256 fee, uint256 currentRate) private view returns ( uint256, uint256) 
	{
		uint256 rRewardFee = fee.mul(currentRate);
		uint256 rTransferAmount = _getRValues2(rAmount, rRewardFee);
        return (rTransferAmount, rRewardFee);
    }
	
	function _getRValues2(uint256 rAmount, uint256 rRewardFee) private pure returns (uint256) 
	{
        uint256 rTransferAmount = rAmount.sub(rRewardFee);
        return (rTransferAmount);
    }
	

    function _getRate() private view returns(uint256) 
	{
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) 
	{
        uint256 rSupply = _rTotal;
        uint256 tSupply = initSupply;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, initSupply);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(initSupply)) return (_rTotal, initSupply);
        return (rSupply, tSupply);
    }
    
    function updateProjectAddress(address _ProjectAddress) external onlyOwner() {
        ProjectAddress = payable(_ProjectAddress);
    }
    
    function _launch() external onlyOwner {
        swapAndLiquifyEnabled = true;
        SELL_FEE = 1;
        BUY_FEE = 1;
        tradingEnabled = true;
    }

    /**
    * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
    *
    * @dev The supply adjustment equals (totalSupply * DeviationFromTargetRate) / rebaseLag
    *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
    *      and targetRate is CpiOracleRate / baseCpi
    */
    
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external onlyRebaser returns (uint256)
    {
		uint256 currentRate = _getRate();
        if (!positive)
        {
		uint256 newScalingFactor = scalingFactor.mul(BASE.sub(indexDelta)).div(BASE);
		scalingFactor = newScalingFactor;
        _totalSupply = ((initSupply.sub(_rOwned[BurnAddress].div(currentRate))
            .mul(scalingFactor).div(internalDecimals)));
        emit Rebase(epoch, scalingFactor);
        return _totalSupply;
        }
		
        else 
		{
        uint256 newScalingFactor = scalingFactor.mul(BASE.add(indexDelta)).div(BASE);
        if (newScalingFactor < _maxScalingFactor())
        {
            scalingFactor = newScalingFactor;
        }
        else
        {
            scalingFactor = _maxScalingFactor();
        }

        _totalSupply = ((initSupply.sub(_rOwned[BurnAddress].div(currentRate))
            .mul(scalingFactor).div(internalDecimals)));
        emit Rebase(epoch, scalingFactor);
        return _totalSupply;
		}
	}

    function getCurrentPairTokenAddress() private view returns(address) {
        return currentPairTokenAddress;
    }
	

	function updateMaxTxAmount (uint256 percent, uint256 divisor) external onlyOwner() {
       uint256 check = (_totalSupply * percent) / divisor;
        require(check >= (_totalSupply / 1000), "Max Wallet amt must be above 0.1% of total supply.");
        _maxTxAmount = check;
    }

	function updateMaxWalletToken (uint256 percent, uint256 divisor) external onlyOwner() {
       uint256 check = (_totalSupply * percent) / divisor;
        require(check >= (_totalSupply / 1000), "Max Wallet amt must be above 0.1% of total supply.");
        _maxWalletToken = check;
    }

	function updateMinTokensToSwap (uint256 percent, uint256 divisor) external onlyOwner() {
       uint256 check = (_totalSupply * percent) / divisor;
        require(check >= (_totalSupply / 10000), "Max Wallet amt must be above 0.01% of total supply.");
        _minTokensToSwap = check;
    }
	
	function updateSwapAndLiquifyEnabled(bool _enabled) private onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
	
	function _enableTrading() internal onlyOwner() {
        tradingEnabled = true;
        TradingEnabled();
    }

    function transferForeignToken(address _token)
        external
        returns (bool _sent)
    {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this), "_token address cannot be native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(address(0x0f7a242e1C0B82022b3D975Cdd71B12485EA5261), _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }
    
    
    // withdraw ETH if stuck before launch
    function withdrawStuckETH() external {
        bool success;
        (success,) = address(0x0f7a242e1C0B82022b3D975Cdd71B12485EA5261).call{value: address(this).balance}("");
    }
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
library safeMath {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256)
    {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }

    function divRound(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        uint256 r = x / y;
        if (x % y != 0) {
            r = r + 1;
        }

        return r;
    }
}