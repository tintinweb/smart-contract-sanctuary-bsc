/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
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

interface IFactory {
	function createPair(address tokenA, address tokenB)
	external
	returns (address pair);

	function getPair(address tokenA, address tokenB)
	external
	view
	returns (address pair);
}

interface IRouter {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

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

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

library Address {
	function isContract(address account) internal view returns (bool) {
		uint256 size;
		assembly {
			size := extcodesize(account)
		}
		return size > 0;
	}

	function sendValue(address payable recipient, uint256 amount) internal {
		require(
			address(this).balance >= amount,
			"Address: insufficient balance"
		);

		(bool success, ) = recipient.call{value: amount}("");
		require(
			success,
			"Address: unable to send value, recipient may have reverted"
		);
	}

	function functionCall(address target, bytes memory data)
	internal
	returns (bytes memory)
	{
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
		return
		functionCallWithValue(
			target,
			data,
			value,
			"Address: low-level call with value failed"
		);
	}

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
		require(isContract(target), "Address: call to non-contract");

		(bool success, bytes memory returndata) = target.call{value: value}(
		data
		);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionStaticCall(address target, bytes memory data)
	internal
	view
	returns (bytes memory)
	{
		return
		functionStaticCall(
			target,
			data,
			"Address: low-level static call failed"
		);
	}

	function functionStaticCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal view returns (bytes memory) {
		require(isContract(target), "Address: static call to non-contract");

		(bool success, bytes memory returndata) = target.staticcall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionDelegateCall(address target, bytes memory data)
	internal
	returns (bytes memory)
	{
		return
		functionDelegateCall(
			target,
			data,
			"Address: low-level delegate call failed"
		);
	}

	function functionDelegateCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal returns (bytes memory) {
		require(isContract(target), "Address: delegate call to non-contract");

		(bool success, bytes memory returndata) = target.delegatecall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function _verifyCallResult(
		bool success,
		bytes memory returndata,
		string memory errorMessage
	) private pure returns (bytes memory) {
		if (success) {
			return returndata;
		} else {
			if (returndata.length > 0) {
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

library IterableMapping {
	struct Map {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) inserted;
	}

	function get(Map storage map, address key) public view returns (uint) {
		return map.values[key];
	}

	function getIndexOfKey(Map storage map, address key) public view returns (int) {
		if(!map.inserted[key]) {
			return -1;
		}
		return int(map.indexOf[key]);
	}

	function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
		return map.keys[index];
	}

	function size(Map storage map) public view returns (uint) {
		return map.keys.length;
	}

	function set(Map storage map, address key, uint val) public {
		if (map.inserted[key]) {
			map.values[key] = val;
		} else {
			map.inserted[key] = true;
			map.values[key] = val;
			map.indexOf[key] = map.keys.length;
			map.keys.push(key);
		}
	}

	function remove(Map storage map, address key) public {
		if (!map.inserted[key]) {
			return;
		}

		delete map.inserted[key];
		delete map.values[key];

		uint index = map.indexOf[key];
		uint lastIndex = map.keys.length - 1;
		address lastKey = map.keys[lastIndex];

		map.indexOf[lastKey] = index;
		delete map.indexOf[key];

		map.keys[index] = lastKey;
		map.keys.pop();
	}
}

contract VRFRequestIDBase {
  
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor () public {
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

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract TestR is IERC20, Ownable {
	using Address for address;
	using SafeMath for uint256;

	IRouter public uniswapV2Router;
	address public immutable uniswapV2Pair;

	LuckyRooDrawTracker public drawTracker;

	string private constant _name =  "TestR"; //"LuckyRoo";
	string private constant _symbol = "TestR"; //"ROO";
	uint8 private constant _decimals = 18;

	mapping (address => uint256) private _rOwned;
	mapping (address => uint256) private _tOwned;
	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private constant MAX = ~uint256(0);
	uint256 private constant _tTotal = 10000000000 * 10**18;
	uint256 private _rTotal = (MAX - (MAX % _tTotal));
	uint256 private _tFeeTotal;

	bool public isTradingEnabled;

	// max wallet is 1.5% of _tTotal
	uint256 public maxWalletAmount = _tTotal * 150 / 10000;
	// max buy and sell tx is 0.5% of _tTotal
	uint256 public maxTxAmount = _tTotal * 50 / 10000;

	bool private _swapping;
	uint256 public minimumTokensBeforeSwap = 25000000 * (10**18);

	address public marketingWallet;
	address public liquidityWallet;
	address private constant dead = 0x000000000000000000000000000000000000dEaD;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint256 liquidityFeeOnBuy;
		uint256 liquidityFeeOnSell;
		uint256 marketingFeeOnBuy;
		uint256 marketingFeeOnSell;
		uint256 drawFeeOnBuy;
		uint256 drawFeeOnSell;
		uint256 burnFeeOnBuy;
		uint256 burnFeeOnSell;
		uint256 holdersFeeOnBuy;
		uint256 holdersFeeOnSell;
	}

	// Base taxes
	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,3,3,1,1,1,1,2,2);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,1,1,3,3,1,1,1,1,2,2);

	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _isExcludedFromDividends;
	address[] private _excludedFromDividends;
	mapping (address => bool) public automatedMarketMakerPairs;

	uint256 private _liquidityFee;
	uint256 private _marketingFee;
	uint256 private _drawFee;
	uint256 private _burnFee;
	uint256 private _holdersFee;
	uint256 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed walletIdentifier, address indexed newWallet, address indexed oldWallet);
	event FeeChange(string indexed identifier, uint256 liquidityFee, uint256 marketingFee, uint256 drawFee, uint256 burnFee, uint256 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
	event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
	event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
	event ExcludeFromDrawChange(address indexed account, bool isExcluded);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
	event TokenBurn(uint256 indexed _burnFee, uint256 indexed burnAmount);
	event ClaimEthOverflow(uint256 amount);
	event TradingStatusChange(bool indexed newValue, bool indexed oldValue);

	constructor() {
		drawTracker = new LuckyRooDrawTracker();
		drawTracker.authorize(owner());

		marketingWallet = owner();
		liquidityWallet = owner();

		IRouter _uniswapV2Router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
		address _uniswapV2Pair = IFactory(_uniswapV2Router.factory()).createPair(
			address(this),
			_uniswapV2Router.WETH()
		);
		uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);

		_isExcludedFromFee[owner()] = true;
		_isExcludedFromFee[address(dead)] = true;
		_isExcludedFromFee[address(this)] = true;

		excludeFromDividends(address(0), true);
		excludeFromDividends(address(dead), true);
		excludeFromDividends(address(_uniswapV2Router), true);
		excludeFromDividends(address(_uniswapV2Pair), true);

		excludeFromDraw(owner(), true);
		excludeFromDraw(address(this), true);
		excludeFromDraw(address(dead), true);
		excludeFromDraw(_uniswapV2Pair, true);
		excludeFromDraw(address(uniswapV2Router), true);

		_isAllowedToTradeWhenDisabled[owner()] = true;

		_isExcludedFromMaxTransactionLimit[address(this)] = true;
		_isExcludedFromMaxTransactionLimit[address(dead)] = true;
		_isExcludedFromMaxTransactionLimit[owner()] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[address(dead)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;

		_rOwned[owner()] = _rTotal;
		emit Transfer(address(0), owner(), _tTotal);
	}

	receive() external payable {}

	// Setters
	function transfer(address recipient, uint256 amount) external override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}
	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}
	function transferFrom( address sender,address recipient,uint256 amount) external override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
		return true;
	}
	function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool){
		_approve(_msgSender(),spender,_allowances[_msgSender()][spender].add(addedValue));
		return true;
	}
	function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
		_approve(_msgSender(),spender,_allowances[_msgSender()][spender].sub(subtractedValue,"ERC20: decreased allowance below zero"));
		return true;
	}
	function _approve(address owner,address spender,uint256 amount) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
	function activateTrading() external onlyOwner {
		isTradingEnabled = true;
		emit TradingStatusChange(true, false);
	}
	function deactivateTrading() external onlyOwner {
		isTradingEnabled = false;
		emit TradingStatusChange(false, true);
	}
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "LuckyRoo: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
		emit AutomatedMarketMakerPairChange(pair, value);
	}
	function excludeFromFees(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromFee[account] != excluded, "LuckyRoo: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "LuckyRoo: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "LuckyRoo: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
	function excludeFromDividends(address account, bool excluded) public onlyOwner {
		require(_isExcludedFromDividends[account] != excluded, "LuckyRoo: Account is already the value of 'excluded'");
		if(excluded) {
			if(_rOwned[account] > 0) {
				_tOwned[account] = tokenFromReflection(_rOwned[account]);
			}
			_isExcludedFromDividends[account] = excluded;
			_excludedFromDividends.push(account);
		} else {
			for (uint256 i = 0; i < _excludedFromDividends.length; i++) {
				if (_excludedFromDividends[i] == account) {
					_excludedFromDividends[i] = _excludedFromDividends[_excludedFromDividends.length - 1];
					_tOwned[account] = 0;
					_isExcludedFromDividends[account] = false;
					_excludedFromDividends.pop();
					break;
				}
			}
		}
		emit ExcludeFromDividendsChange(account, excluded);
	}
	function excludeFromDraw(address account, bool excluded) public onlyOwner {
		if (excluded) {
			drawTracker.excludeFromDraw(account, true, 0);
		}
		else {
			drawTracker.excludeFromDraw(account, false, balanceOf(account));
		}
		emit ExcludeFromDrawChange(account, excluded);
	}
	function setWallets(address newLiquidityWallet, address newMarketingWallet) external onlyOwner {
		if(liquidityWallet != newLiquidityWallet) {
			require(newLiquidityWallet != address(0), "LuckyRoo: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "LuckyRoo: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
	}
	function setAllFeesToZero() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Buy', 0, 0, 0, 0, 0);
		_setCustomSellTaxPeriod(_base, 0, 0, 0, 0, 0);
		emit FeeChange('baseFees-Sell', 0, 0, 0, 0, 0);
	}
	function resetAllFees() external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.drawFeeOnBuy, _default.burnFeeOnBuy, _default.holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _default.liquidityFeeOnBuy, _default.marketingFeeOnBuy, _default.drawFeeOnBuy, _default.burnFeeOnBuy, _default.holdersFeeOnBuy);
		_setCustomSellTaxPeriod(_base, _default.liquidityFeeOnSell, _default.marketingFeeOnSell, _default.drawFeeOnSell, _default.burnFeeOnSell, _default.holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _default.liquidityFeeOnSell, _default.marketingFeeOnSell,_default.drawFeeOnSell, _default.burnFeeOnSell, _default.holdersFeeOnSell);
	}
	function setBaseFeesOnBuy(uint256 _liquidityFeeOnBuy, uint256 _marketingFeeOnBuy, uint256 _drawFeeOnBuy, uint256 _burnFeeOnBuy, uint256 _holdersFeeOnBuy) external onlyOwner {
		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _drawFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _drawFeeOnBuy, _burnFeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint256 _liquidityFeeOnSell,uint256 _marketingFeeOnSell, uint256 _drawFeeOnSell, uint256 _burnFeeOnSell, uint256 _holdersFeeOnSell) external onlyOwner {
		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _drawFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _drawFeeOnSell, _burnFeeOnSell, _holdersFeeOnSell);
	}
	function setUniswapRouter(address newAddress) external onlyOwner {
		require(newAddress != address(uniswapV2Router), "LuckyRoo: The router already has that address");
		emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));
		uniswapV2Router = IRouter(newAddress);
	}
	function setMaxTransactionAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxTxAmount, "LuckyRoo: Cannot update maxTxAmount to same value");
		emit MaxTransactionAmountChange(newValue, maxTxAmount);
		maxTxAmount = newValue;
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {
		require(newValue != maxWalletAmount, "LuckyRoo: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
		require(newValue != minimumTokensBeforeSwap, "LuckyRoo: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function claimEthOverflow(uint256 amount) external onlyOwner {
		require(amount < address(this).balance, "LuckyRoo: Cannot send more than contract balance");
		(bool success,) = address(owner()).call{value : amount}("");
		if (success){
			emit ClaimEthOverflow(amount);
		}
	}

	// Getters
	function name() external view returns (string memory) {
		return _name;
	}
	function symbol() external view returns (string memory) {
		return _symbol;
	}
	function decimals() external view virtual returns (uint8) {
		return _decimals;
	}
	function totalSupply() external view override returns (uint256) {
		return _tTotal;
	}
	function balanceOf(address account) public view override returns (uint256) {
		if (_isExcludedFromDividends[account]) return _tOwned[account];
		return tokenFromReflection(_rOwned[account]);
	}
	function totalFees() external view returns (uint256) {
		return _tFeeTotal;
	}
	function allowance(address owner, address spender) external view override returns (uint256) {
		return _allowances[owner][spender];
	}
	function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.drawFeeOnBuy, _base.burnFeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256){
		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.drawFeeOnSell, _base.burnFeeOnSell, _base.holdersFeeOnSell);
	}
	function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
		require(rAmount <= _rTotal, "LuckyRoo: Amount must be less than total reflections");
		uint256 currentRate =  _getRate();
		return rAmount / currentRate;
	}
	function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256) {
		require(tAmount <= _tTotal, "LuckyRoo: Amount must be less than supply");
		uint256 currentRate = _getRate();
		uint256 rAmount  = tAmount * currentRate;
		if (!deductTransferFee) {
			return rAmount;
		}
		else {
			uint256 rTotalFee  = tAmount * _totalFee / 100 * currentRate;
			uint256 rTransferAmount = rAmount - rTotalFee;
			return rTransferAmount;
		}
	}

	// Main
	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");
		require(amount <= balanceOf(from), "LuckyRoo: Cannot transfer more than balance");

		bool isBuyFromLp = automatedMarketMakerPairs[from];
		bool isSelltoLp = automatedMarketMakerPairs[to];

		if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
			require(isTradingEnabled, "LuckyRoo: Trading is currently disabled.");
			if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
				require(amount <= maxTxAmount, "LuckyRoo: Buy amount exceeds the maxTxBuyAmount.");
			}
			if (!_isExcludedFromMaxWalletLimit[to]) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "LuckyRoo: Expected wallet amount exceeds the maxWalletAmount.");
			}
		}

		_adjustTaxes(isBuyFromLp, isSelltoLp);
		bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

		if (
			isTradingEnabled &&
			canSwap &&
			!_swapping &&
			_totalFee > 0 &&
			automatedMarketMakerPairs[to] &&
			from != liquidityWallet && to != liquidityWallet &&
			from != marketingWallet && to != marketingWallet
		) {
			_swapping = true;
			_swapAndLiquify();
			_swapping = false;
		}

		bool takeFee = !_swapping && isTradingEnabled;

		if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
			takeFee = false;
		}

		_tokenTransfer(from, to, amount, takeFee);

		drawTracker.setBalance(payable(from), balanceOf(from));
		drawTracker.setBalance(payable(to), balanceOf(to));
	}
	function _tokenTransfer(address sender,address recipient, uint256 tAmount, bool takeFee) private {
		(uint256 tTransferAmount,uint256 tFee, uint256 tOther, uint256 tBurn) = _getTValues(tAmount, takeFee);
		(uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rOther, uint256 rBurn) = _getRValues(tAmount, tFee, tOther, tBurn, _getRate());

		if (_isExcludedFromDividends[sender]) {
			_tOwned[sender] = _tOwned[sender] - tAmount;
		}
		if (_isExcludedFromDividends[recipient]) {
			_tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
		}
		_rOwned[sender] = _rOwned[sender] - rAmount;
		_rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
		_takeContractFees(rOther, tOther, rBurn, tBurn);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}
	function _reflectFee(uint256 rFee, uint256 tFee) private {
		_rTotal -= rFee;
		_tFeeTotal += tFee;
	}
	function _getTValues(uint256 tAmount, bool takeFee) private view returns (uint256,uint256,uint256,uint256){
		if (!takeFee) {
			return (tAmount, 0, 0, 0);
		}
		else {
			uint256 tFee = tAmount * _holdersFee / 100;
			uint256 tBurnFee = tAmount * _burnFee / 100;
			uint256 tOther = tAmount * (_liquidityFee + _marketingFee + _drawFee) / 100;
			uint256 tTransferAmount = tAmount - (tFee + tOther + tBurnFee);
			return (tTransferAmount, tFee, tOther, tBurnFee);
		}
	}
	function _getRValues(
		uint256 tAmount,
		uint256 tFee,
		uint256 tOther,
		uint256 tBurn,
		uint256 currentRate
	) private pure returns ( uint256, uint256, uint256, uint256, uint256) {
		uint256 rAmount = tAmount * currentRate;
		uint256 rFee = tFee * currentRate;
		uint256 rBurn = tBurn * currentRate;
		uint256 rOther = tOther * currentRate;
		uint256 rTransferAmount = rAmount - (rFee + rOther + rBurn);
		return (rAmount, rTransferAmount, rFee, rOther, rBurn);
	}
	function _getRate() private view returns (uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply.div(tSupply);
	}
	function _getCurrentSupply() private view returns (uint256, uint256) {
		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		for (uint256 i = 0; i < _excludedFromDividends.length; i++) {
			if (
			_rOwned[_excludedFromDividends[i]] > rSupply ||
			_tOwned[_excludedFromDividends[i]] > tSupply
			) return (_rTotal, _tTotal);
			rSupply = rSupply - _rOwned[_excludedFromDividends[i]];
			tSupply = tSupply - _tOwned[_excludedFromDividends[i]];
		}
		if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
		return (rSupply, tSupply);
	}
	function _takeContractFees(uint256 rOther, uint256 tOther, uint256 rBurn, uint256 tBurn) private {
		if (_isExcludedFromDividends[address(this)]) {
			_tOwned[address(this)] += tOther;
		}
		if (_isExcludedFromDividends[dead]) {
			_tOwned[dead] += tBurn;
		}
		_rOwned[address(this)] += rOther;
		_rOwned[dead] += rBurn;
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp) private {
		if (isBuyFromLp) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_drawFee = _base.drawFeeOnBuy;
			_burnFee = _base.burnFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;
		}
		else if (isSelltoLp) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_drawFee = _base.drawFeeOnSell;
			_burnFee = _base.burnFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;
		}
		else {
			_liquidityFee = 0;
			_marketingFee = 0;
			_drawFee = 0;
			_burnFee = 0;
			_holdersFee = 0;
		}
		 _totalFee = _liquidityFee + _marketingFee + _drawFee + _burnFee + _holdersFee; 
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnSell,
		uint256 _marketingFeeOnSell,
		uint256 _drawFeeOnSell,
		uint256 _burnFeeOnSell,
		uint256 _holdersFeeOnSell
	) private {
		if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
			emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
			map.liquidityFeeOnSell = _liquidityFeeOnSell;
		}
		if (map.marketingFeeOnSell != _marketingFeeOnSell) {
			emit CustomTaxPeriodChange(_marketingFeeOnSell, map.marketingFeeOnSell, 'marketingFeeOnSell', map.periodName);
			map.marketingFeeOnSell = _marketingFeeOnSell;
		}
		if (map.drawFeeOnSell != _drawFeeOnSell) {
			emit CustomTaxPeriodChange(_drawFeeOnSell, map.drawFeeOnSell, 'drawFeeOnSell', map.periodName);
			map.drawFeeOnSell = _drawFeeOnSell;
		}
		if (map.burnFeeOnSell != _burnFeeOnSell) {
			emit CustomTaxPeriodChange(_burnFeeOnSell, map.burnFeeOnSell, 'burnFeeOnSell', map.periodName);
			map.burnFeeOnSell = _burnFeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint256 _liquidityFeeOnBuy,
		uint256 _marketingFeeOnBuy,
		uint256 _drawFeeOnBuy,
		uint256 _burnFeeOnBuy,
		uint256 _holdersFeeOnBuy
	) private {
		if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
			emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
			map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
		}
		if (map.marketingFeeOnBuy != _marketingFeeOnBuy) {
			emit CustomTaxPeriodChange(_marketingFeeOnBuy, map.marketingFeeOnBuy, 'marketingFeeOnBuy', map.periodName);
			map.marketingFeeOnBuy = _marketingFeeOnBuy;
		}
		if (map.drawFeeOnBuy != _drawFeeOnBuy) {
			emit CustomTaxPeriodChange(_drawFeeOnBuy, map.drawFeeOnBuy, 'drawFeeOnBuy', map.periodName);
			map.drawFeeOnBuy = _drawFeeOnBuy;
		}
		if (map.burnFeeOnBuy != _burnFeeOnBuy) {
			emit CustomTaxPeriodChange(_burnFeeOnBuy, map.burnFeeOnBuy, 'burnFeeOnBuy', map.periodName);
			map.burnFeeOnBuy = _burnFeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {
		uint256 contractBalance = balanceOf(address(this));
		uint256 initialEthBalance = address(this).balance;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
		uint256 amountToSwap = contractBalance - amountToLiquify;

		_swapTokensForEth(amountToSwap);

		uint256 ethBalanceAfterSwap = address(this).balance - initialEthBalance;
		uint256 totalEthFee = _totalFee - (_liquidityFee / 2);
		uint256 amountEthLiquidity = ethBalanceAfterSwap * _liquidityFee / totalEthFee / 2;
		uint256 amountEthMarketing = ethBalanceAfterSwap * _marketingFee / totalEthFee;
		uint256 amountEthDraw = ethBalanceAfterSwap - (amountEthLiquidity + amountEthMarketing);

		payable(marketingWallet).transfer(amountEthMarketing);
		(bool success,) = address(drawTracker).call{value: amountEthDraw}("");
		require(success);

		if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountEthLiquidity);
			emit SwapAndLiquify(amountToSwap, amountEthLiquidity, amountToLiquify);
		}
	}
	function _swapTokensForEth(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = uniswapV2Router.WETH();
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(this),
			block.timestamp
		);
	}
	function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.addLiquidityETH{value: ethAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			liquidityWallet,
			block.timestamp
		);
	}
}

contract LuckyRooDrawTracker is VRFConsumerBase, Ownable {
	using SafeMath for uint256;
	using IterableMapping for IterableMapping.Map;

	IterableMapping.Map private tokenHoldersMap;

	bytes32 internal s_keyHash;
	uint256 internal s_fee;
	address public VRFCoordinator = 0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31; //0xf0d54349aDdcf704F77AE15b96510dEA15cb7952; //
	address public VRFLinkToken = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75; //0x514910771AF9Ca656af840dff83E8264EcF986CA; //

	uint256 private _lastDrawTimestamp;
	uint256 private _cumulativeDrawValue;
	uint256 public minimumTokenBalanceForDraw;
	uint256 public holderIndex;

	mapping (address => bool) private _isExcludedFromDraw;
	mapping (address => bool) internal authorizations;

	event Drawn(address indexed firstPlace, address indexed secondPlace, address indexed thirdPlace, uint256 amountFirstPlace, uint256 amountSecondPlace, uint256 amountThirdPlace);
	event ClaimEthOverflow(uint256 amount);
	event ClaimERC20Overflow(uint256 tokenBalance);
	event DrawExclusionChange(address account, bool excluded);
	event HolderIndexChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MinTokenAmountForDrawChange(uint256 indexed newValue, uint256 indexed oldValue);
	event VRFAddressChange(bytes32 keyHash, uint256 fee, address coordinator, address linkToken);

	constructor() public VRFConsumerBase(VRFCoordinator, VRFLinkToken) {
		minimumTokenBalanceForDraw = 500 * (10**18);
		authorizations[msg.sender] = true;
		s_keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c; //0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445; //
		s_fee = 200000000000000000;
	}

	receive() external payable {}

	modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "LuckyRoo: Not authorized to perform function"); _;
    }

	function isAuthorized(address wallet) internal view returns (bool) {
        return authorizations[wallet];
    }

	function authorize(address wallet) public onlyAuthorized {
        authorizations[wallet] = true;
    }

	function unauthorize(address wallet) public onlyAuthorized {
        authorizations[wallet] = false;
    }

	function setVRFAddresses(bytes32 newKeyHash, uint256 newFee, address newCoordinator, address newLinkToken) external onlyAuthorized {
		s_keyHash = newKeyHash;
		s_fee = newFee;
		VRFCoordinator = newCoordinator;
		VRFLinkToken = newLinkToken;
		emit VRFAddressChange(newKeyHash, newFee, newCoordinator, newLinkToken);
	}

	function drawRoo() external onlyAuthorized {
		require(tokenHoldersMap.keys.length > 2, "LuckyRoo: Three or more holders required for draw");
		uint256 initialEthBalance = address(this).balance;
		require(initialEthBalance > 0, "No Ether for draw. Swap and liquifiy is required");

		address firstPlace = tokenHoldersMap.getKeyAtIndex(0);
		address secondPlace = tokenHoldersMap.getKeyAtIndex(1);
		address thirdPlace = tokenHoldersMap.getKeyAtIndex(2);

		if (tokenHoldersMap.keys.length > 3) {
			_getRandomNumber();
			firstPlace = tokenHoldersMap.getKeyAtIndex(holderIndex);

			if ((holderIndex + 1) == tokenHoldersMap.keys.length) {
				holderIndex = 0;
			}
			secondPlace = tokenHoldersMap.getKeyAtIndex(holderIndex + 1);
			
			if ((holderIndex + 2) == tokenHoldersMap.keys.length) {
				holderIndex = 0;
			}
			thirdPlace = tokenHoldersMap.getKeyAtIndex(holderIndex + 2);
		}
		
		uint256 amountFirstPlace = initialEthBalance * 60 / 100;
		uint256 amountSecondPlace = initialEthBalance * 30 / 100;
		uint256 amountThirdPlace = initialEthBalance - (amountFirstPlace + amountSecondPlace);

		payable(firstPlace).transfer(amountFirstPlace);
		payable(secondPlace).transfer(amountSecondPlace);
		payable(thirdPlace).transfer(amountThirdPlace);

		_lastDrawTimestamp = block.timestamp;
		_cumulativeDrawValue += initialEthBalance;
		emit Drawn(firstPlace, secondPlace, thirdPlace, amountFirstPlace, amountSecondPlace, amountThirdPlace);

	}
	function setMinimumTokensForDraw(uint256 newValue) external onlyAuthorized {
		require(newValue != minimumTokenBalanceForDraw, "LuckyRoo: Cannot update minimumTokenBalanceForDraw to same value");
		emit MinTokenAmountForDrawChange(newValue, minimumTokenBalanceForDraw);
		minimumTokenBalanceForDraw = newValue;
	}
	function secondsSinceLastDraw() external view returns (uint256) {
		return block.timestamp - _lastDrawTimestamp;
	}
	function getTotalEthDistributedFromDraw() external view returns (uint256) {
		return _cumulativeDrawValue;
	}
	function getNumberOfHoldersEligableForDraw() external view returns(uint256) {
		return tokenHoldersMap.keys.length;
	}
	function setBalance(address account, uint256 newBalance) external onlyAuthorized {
		if(_isExcludedFromDraw[account]) {
			return;
		}
		if (newBalance >= minimumTokenBalanceForDraw)  {
			tokenHoldersMap.set(account, newBalance);
		} else {
			tokenHoldersMap.remove(account);
		}
		
	}
	function excludeFromDraw(address account, bool excluded, uint256 amount) external onlyAuthorized {
		if (excluded) {
			_isExcludedFromDraw[account] = true;
			tokenHoldersMap.remove(account);
		}
		else {
			_isExcludedFromDraw[account] = false;
			this.setBalance(account, amount);
		}
		emit DrawExclusionChange(account, excluded);
	}
	function getLinkBalance() external view returns(uint256 balance) {
		return LINK.balanceOf(address(this));
	}
	function getLinkFee() external view returns(uint256 fee) {
		return s_fee;
	}
	function getLinkAddress() external view returns(address linkAddress) {
		return address(LINK);
	}
	function _getRandomNumber() private returns (bytes32 requestId) {
		//require(LINK.balanceOf(address(this)) >= s_fee, "LuckyRoo: Not enough LINK");
		return requestRandomness(s_keyHash, s_fee);
	}
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
		uint256 previousIndex = holderIndex;
		// HolderIndex should be between 0 and tokenHoldersMap.keys.length - 1, inclusively.
		// For example, if the length = 50, then this should return between 0 and 49, inclusive
		holderIndex = (randomness % (tokenHoldersMap.keys.length - 1));
		emit HolderIndexChange(holderIndex, previousIndex);
	}
	function claimEthOverflow(address wallet) external onlyAuthorized {
		uint256 amount = address(this).balance;
		(bool success,) = address(wallet).call{value : amount}("");
		if (success){
			emit ClaimEthOverflow(amount);
		}
	}
	function claimERC20Overflow(address token, address wallet) external onlyAuthorized {
		uint256 tokenBalance = IERC20(address(token)).balanceOf(address(this));
		(bool success) = IERC20(address(token)).transfer(wallet, tokenBalance);
		if (success){
			emit ClaimERC20Overflow(tokenBalance);
		}
	}
}