/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// File: tests/TRL.sol





pragma solidity 0.8.17;



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



    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}



interface IERC20 {

	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);



	function transferFrom(

		address sender,

		address recipient,

		uint256 amount

	) external returns (bool);



	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);

}



interface IERC20Metadata is IERC20 {

	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint8);

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



	constructor () {

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



contract ERC20 is Context, IERC20, IERC20Metadata {

	using SafeMath for uint256;



	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;



	uint256 private _totalSupply;

	string private _name;

	string private _symbol;



	constructor(string memory name_, string memory symbol_) {

		_name = name_;

		_symbol = symbol_;

	}



	function name() public view virtual override returns (string memory) {

		return _name;

	}



	function symbol() public view virtual override returns (string memory) {

		return _symbol;

	}



	function decimals() public view virtual override returns (uint8) {

		return 18;

	}



	function totalSupply() public view virtual override returns (uint256) {

		return _totalSupply;

	}



	function balanceOf(address account) public view virtual override returns (uint256) {

		return _balances[account];

	}



	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

		_transfer(_msgSender(), recipient, amount);

		return true;

	}



	function allowance(address owner, address spender) public view virtual override returns (uint256) {

		return _allowances[owner][spender];

	}



	function approve(address spender, uint256 amount) public virtual override returns (bool) {

		_approve(_msgSender(), spender, amount);

		return true;

	}



	function transferFrom(

		address sender,

		address recipient,

		uint256 amount

	) public virtual override returns (bool) {

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



	function _transfer(

		address sender,

		address recipient,

		uint256 amount

	) internal virtual {

		require(sender != address(0), "ERC20: transfer from the zero address");

		require(recipient != address(0), "ERC20: transfer to the zero address");

		_beforeTokenTransfer(sender, recipient, amount);

		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

		_balances[recipient] = _balances[recipient].add(amount);

		emit Transfer(sender, recipient, amount);

	}



	function _mint(address account, uint256 amount) internal virtual {

		require(account != address(0), "ERC20: mint to the zero address");

		_beforeTokenTransfer(address(0), account, amount);

		_totalSupply = _totalSupply.add(amount);

		_balances[account] = _balances[account].add(amount);

		emit Transfer(address(0), account, amount);

	}



	function _burn(address account, uint256 amount) internal virtual {

		require(account != address(0), "ERC20: burn from the zero address");

		_beforeTokenTransfer(account, address(0), amount);

		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

		_totalSupply = _totalSupply.sub(amount);

		emit Transfer(account, address(0), amount);

	}



	function _approve(

		address owner,

		address spender,

		uint256 amount

	) internal virtual {

		require(owner != address(0), "ERC20: approve from the zero address");

		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;

		emit Approval(owner, spender, amount);

	}



	function _beforeTokenTransfer(

		address from,

		address to,

		uint256 amount

	) internal virtual {}

}



contract TRLToken is ERC20, Ownable {

    IRouter public uniswapV2Router;

    address public immutable uniswapV2Pair;



    string private constant _name = "TRLToken";

    string private constant _symbol = "TRLT";



    bool public isTradingEnabled;



    // initialSupply

    uint256 constant initialSupply = 100000000000 * (10**18);



    // max wallet is 1.5% of initialSupply

    uint256 public maxWalletAmount = initialSupply * 150 / 10000;

    // max buy and sell tx is 0.25 % of initialSupply

    uint256 public maxTxAmount = initialSupply * 25 / 10000;



    bool private _swapping;

    uint256 public minimumTokensBeforeSwap = initialSupply * 25 / 100000;



    address public liquidityWallet;

    address public marketingWallet;

    address public devWallet;

    address public distributionWallet;



    struct CustomTaxPeriod {

        bytes23 periodName;

        uint8 blocksInPeriod;

        uint256 timeInPeriod;

        uint8 liquidityFeeOnBuy;

        uint8 liquidityFeeOnSell;

        uint8 marketingFeeOnBuy;

        uint8 marketingFeeOnSell;

        uint8 devFeeOnBuy;

        uint8 devFeeOnSell;

        uint8 distributionFeeOnBuy;

        uint8 distributionFeeOnSell;

    }



    // Base taxes

    CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,1,1,4,4,1,1,0,2);



    uint256 public launchTokens;

    uint256 private _launchStartTimestamp;

	uint256 private _launchBlockNumber;

	bool public _launchTokensClaimed;



    mapping (address => bool) private _isBlocked;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcludedFromMaxTransactionLimit;

    mapping (address => bool) private _isExcludedFromMaxWalletLimit;

    mapping (address => bool) private _isAllowedToTradeWhenDisabled;

    mapping (address => bool) private _feeOnSelectedWalletTransfers;

    mapping (address => bool) public automatedMarketMakerPairs;



    uint8 private _liquidityFee;

    uint8 private _marketingFee;

    uint8 private _devFee;

    uint8 private _distributionFee;

    uint8 private _totalFee;



    event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);

    event BlockedAccountChange(address indexed holder, bool indexed status);

    event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);

    event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);

    event FeeChange(string indexed identifier, uint8 liquidityFee, uint8 marketingFee, uint8 devFee, uint8 distributionFee);

    event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);

    event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);

    event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);

    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);

    event ExcludeFromFeesChange(address indexed account, bool isExcluded);

    event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);

    event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);

    event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);

    event FeeOnSelectedWalletTransfersChange(address indexed account, bool newValue);

    event ClaimOverflow(address token, uint256 amount);

    event FeesApplied(uint8 liquidityFee, uint8 marketingFee, uint8 devFee, uint8 distributionFee, uint256 totalFee);



    constructor() ERC20(_name, _symbol) {

        liquidityWallet = owner();

        marketingWallet = owner();

        devWallet = owner();

        distributionWallet = owner();



        IRouter _uniswapV2Router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        address _uniswapV2Pair = IFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);



        _isExcludedFromFee[owner()] = true;

        _isExcludedFromFee[address(this)] = true;



        _isAllowedToTradeWhenDisabled[owner()] = true;



        _isExcludedFromMaxTransactionLimit[address(this)] = true;



        _isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;

        _isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;

        _isExcludedFromMaxWalletLimit[address(this)] = true;

        _isExcludedFromMaxWalletLimit[owner()] = true;



        _mint(owner(), initialSupply);

    }



    receive() external payable {}



    // Setters

    function activateTrading() external onlyOwner {

        isTradingEnabled = true;

        if (_launchStartTimestamp == 0) {

            _launchStartTimestamp = block.timestamp;

            _launchBlockNumber = block.number;

        }

    }

    function deactivateTrading() external onlyOwner {

        isTradingEnabled = false;

    }

    function allowTradingWhenDisabled(address account, bool allowed) external onlyOwner {

		_isAllowedToTradeWhenDisabled[account] = allowed;

		emit AllowedWhenTradingDisabledChange(account, allowed);

	}

    function _setAutomatedMarketMakerPair(address pair, bool value) private {

        require(automatedMarketMakerPairs[pair] != value, "TRLT: Automated market maker pair is already set to that value");

        automatedMarketMakerPairs[pair] = value;

        emit AutomatedMarketMakerPairChange(pair, value);

    }

    function blockAccount(address account) external onlyOwner {

		require(!_isBlocked[account], "TRLT: Account is already blocked");

		if (_launchStartTimestamp > 0) {

			require((block.timestamp - _launchStartTimestamp) < 172800, "TRLT: Time to block accounts has expired");

		}

		_isBlocked[account] = true;

		emit BlockedAccountChange(account, true);

	}

	function unblockAccount(address account) external onlyOwner {

		require(_isBlocked[account], "TRLT: Account is not blcoked");

		_isBlocked[account] = false;

		emit BlockedAccountChange(account, false);

	}

    function excludeFromFees(address account, bool excluded) external onlyOwner {

        require(_isExcludedFromFee[account] != excluded, "TRLT: Account is already the value of 'excluded'");

        _isExcludedFromFee[account] = excluded;

        emit ExcludeFromFeesChange(account, excluded);

    }

    function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {

        require(_isExcludedFromMaxTransactionLimit[account] != excluded, "TRLT: Account is already the value of 'excluded'");

        _isExcludedFromMaxTransactionLimit[account] = excluded;

        emit ExcludeFromMaxTransferChange(account, excluded);

    }

    function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {

        require(_isExcludedFromMaxWalletLimit[account] != excluded, "TRLT: Account is already the value of 'excluded'");

        _isExcludedFromMaxWalletLimit[account] = excluded;

        emit ExcludeFromMaxWalletChange(account, excluded);

    }

    function setFeeOnSelectedWalletTransfers(address account, bool value) external onlyOwner {

		require(_feeOnSelectedWalletTransfers[account] != value, "TRLT: The selected wallet is already set to the value ");

		_feeOnSelectedWalletTransfers[account] = value;

		emit FeeOnSelectedWalletTransfersChange(account, value);

	}

    function setWallets(address newLiquidityWallet, address newMarketingWallet, address newDevWallet, address newDistributionWallet) external onlyOwner {

        if(liquidityWallet != newLiquidityWallet) {

            require(newLiquidityWallet != address(0), "TRLT: The liquidityWallet cannot be 0");

            emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);

            liquidityWallet = newLiquidityWallet;

        }

        if(marketingWallet != newMarketingWallet) {

            require(newMarketingWallet != address(0), "TRLT: The marketingWallet cannot be 0");

            emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);

            marketingWallet = newMarketingWallet;

        }

        if(devWallet != newDevWallet) {

            require(newDevWallet != address(0), "TRLT: The devWallet cannot be 0");

            emit WalletChange('devWallet', newDevWallet, devWallet);

            devWallet = newDevWallet;

        }

         if(distributionWallet != newDistributionWallet) {

            require(newDistributionWallet != address(0), "TRLT: The distributionWallet cannot be 0");

            emit WalletChange('distributionWallet', newDistributionWallet, distributionWallet);

            distributionWallet = newDistributionWallet;

        }

    }

    // Base fees

    function setBaseFeesOnBuy(uint8 _liquidityFeeOnBuy, uint8 _marketingFeeOnBuy, uint8 _devFeeOnBuy, uint8 _distributionFeeOnBuy) external onlyOwner {

        _setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _distributionFeeOnBuy);

        emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _distributionFeeOnBuy);

    }

    function setBaseFeesOnSell(uint8 _liquidityFeeOnSell,uint8 _marketingFeeOnSell , uint8 _devFeeOnSell, uint8 _distributionFeeOnSell) external onlyOwner {

        _setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _distributionFeeOnSell);

        emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _distributionFeeOnSell);

    }

    function setUniswapRouter(address newAddress) external onlyOwner {

        require(newAddress != address(uniswapV2Router), "TRLT: The router already has that address");

        emit UniswapV2RouterChange(newAddress, address(uniswapV2Router));

        uniswapV2Router = IRouter(newAddress);

    }

    function setMaxTransactionAmount(uint256 newValue) external onlyOwner {

        require(newValue != maxTxAmount, "TRLT: Cannot update maxTxAmount to same value");

        emit MaxTransactionAmountChange(newValue, maxTxAmount);

        maxTxAmount = newValue;

    }

    function setMaxWalletAmount(uint256 newValue) external onlyOwner {

        require(newValue != maxWalletAmount, "TRLT: Cannot update maxWalletAmount to same value");

        emit MaxWalletAmountChange(newValue, maxWalletAmount);

        maxWalletAmount = newValue;

    }

    function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {

        require(newValue != minimumTokensBeforeSwap, "TRLT: Cannot update minimumTokensBeforeSwap to same value");

        emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);

        minimumTokensBeforeSwap = newValue;

    }

    function claimLaunchTokens() external onlyOwner {

		require(_launchStartTimestamp > 0, "TRLT: Launch must have occurred");

		require(!_launchTokensClaimed, "TRLT: Launch tokens have already been claimed");

		require(block.number - _launchBlockNumber > 5, "TRLT: Only claim launch tokens after launch");

		uint256 tokenBalance = balanceOf(address(this));

		_launchTokensClaimed = true;

		require(launchTokens <= tokenBalance, "TRLT: A swap and liquify has already occurred");

		uint256 amount = launchTokens;

		launchTokens = 0;

        (bool success) = IERC20(address(this)).transfer(owner(), amount);

        if (success){

            emit ClaimOverflow(address(this), amount);

        }

    }

	function claimBNBOverflow(uint256 amount) external onlyOwner {

		require(amount < address(this).balance, "TRLT: Cannot send more than contract balance");

		(bool success,) = address(owner()).call{value : amount}("");

		if (success){

			emit ClaimOverflow(uniswapV2Router.WETH(), amount);

		}

	}



    // Getters

    function getBaseBuyFees() external view returns (uint8, uint8, uint8, uint8) {

        return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.devFeeOnBuy, _base.distributionFeeOnBuy);

    }

    function getBaseSellFees() external view returns (uint8, uint8, uint8, uint8) {

        return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.devFeeOnSell, _base.distributionFeeOnSell);

    }



    // Main

    function _transfer(

        address from,

        address to,

        uint256 amount

        ) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        if(amount == 0) {

            super._transfer(from, to, 0);

            return;

        }



        bool isBuyFromLp = automatedMarketMakerPairs[from];

        bool isSelltoLp = automatedMarketMakerPairs[to];



        if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {

            require(isTradingEnabled, "TRLT: Trading is currently disabled.");

            require(!_isBlocked[to], "TRLT: Account is blocked");

			require(!_isBlocked[from], "TRLT: Account is blocked");

            if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {

                require(amount <= maxTxAmount, "TRLT: Buy amount exceeds the maxTxBuyAmount.");

            }

            if (!_isExcludedFromMaxWalletLimit[to]) {

                require((balanceOf(to) + amount) <= maxWalletAmount, "TRLT: Expected wallet amount exceeds the maxWalletAmount.");

            }

        }



        _adjustTaxes(isBuyFromLp, isSelltoLp, from , to);

        bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;



        if (

            isTradingEnabled &&

            canSwap &&

            !_swapping &&

            _totalFee > 0 &&

            automatedMarketMakerPairs[to]

        ) {

            _swapping = true;

            _swapAndLiquify();

            _swapping = false;

        }



        bool takeFee = !_swapping && isTradingEnabled;



        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){

            takeFee = false;

        }



        if (takeFee && _totalFee > 0) {

            uint256 fee = amount * _totalFee / 100;

            amount = amount - fee;

            if (_launchStartTimestamp > 0 && (block.number - _launchBlockNumber <= 5)) {

                launchTokens += fee;

            }

            super._transfer(from, address(this), fee);

        }



        super._transfer(from, to, amount);

    }

    function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, address from, address to) private {

        _liquidityFee = 0;

        _marketingFee = 0;

        _devFee = 0;

        _distributionFee = 0;



        if (isBuyFromLp) {

            _liquidityFee = _base.liquidityFeeOnBuy;

            _marketingFee = _base.marketingFeeOnBuy;

            _devFee = _base.devFeeOnBuy;

            _distributionFee = _base.distributionFeeOnBuy;



        }

        if (isSelltoLp) {

			if (_launchStartTimestamp > 0 && block.number - _launchBlockNumber <= 5) {

                _liquidityFee = 100;

            }

			else {

				_liquidityFee = _base.liquidityFeeOnSell;

				_marketingFee = _base.marketingFeeOnSell;

				_devFee = _base.devFeeOnSell;

                _distributionFee = _base.distributionFeeOnSell;

			}

        }

        if (!isSelltoLp && !isBuyFromLp && (_feeOnSelectedWalletTransfers[from] || _feeOnSelectedWalletTransfers[to])) {

			_liquidityFee = _base.liquidityFeeOnSell;

            _marketingFee = _base.marketingFeeOnSell;

            _devFee = _base.devFeeOnSell;

            _distributionFee = _base.distributionFeeOnSell;

		}

        _totalFee = _liquidityFee + _marketingFee + _devFee + _distributionFee;

        emit FeesApplied(_liquidityFee, _marketingFee, _devFee, _distributionFee, _totalFee);

    }

    function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,

        uint8 _liquidityFeeOnSell,

        uint8 _marketingFeeOnSell,

        uint8 _devFeeOnSell,

        uint8 _distributionFeeOnSell

        ) private {

        if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {

            emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);

            map.liquidityFeeOnSell = _liquidityFeeOnSell;

        }

        if (map.marketingFeeOnSell != _marketingFeeOnSell) {

            emit CustomTaxPeriodChange(_marketingFeeOnSell, map.marketingFeeOnSell, 'marketingFeeOnSell', map.periodName);

            map.marketingFeeOnSell = _marketingFeeOnSell;

        }

        if (map.devFeeOnSell != _devFeeOnSell) {

            emit CustomTaxPeriodChange(_devFeeOnSell, map.devFeeOnSell, 'devFeeOnSell', map.periodName);

            map.devFeeOnSell = _devFeeOnSell;

        }

        if (map.distributionFeeOnSell != _distributionFeeOnSell) {

            emit CustomTaxPeriodChange(_distributionFeeOnSell, map.distributionFeeOnSell, 'distributionFeeOnSell', map.periodName);

            map.distributionFeeOnSell = _distributionFeeOnSell;

        }

    }

    function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,

        uint8 _liquidityFeeOnBuy,

        uint8 _marketingFeeOnBuy,

        uint8 _devFeeOnBuy,

        uint8 _distributionFeeOnBuy

        ) private {

        if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {

            emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);

            map.liquidityFeeOnBuy = _liquidityFeeOnBuy;

        }

        if (map.marketingFeeOnBuy != _marketingFeeOnBuy) {

            emit CustomTaxPeriodChange(_marketingFeeOnBuy, map.marketingFeeOnBuy, 'marketingFeeOnBuy', map.periodName);

            map.marketingFeeOnBuy = _marketingFeeOnBuy;

        }

        if (map.devFeeOnBuy != _devFeeOnBuy) {

            emit CustomTaxPeriodChange(_devFeeOnBuy, map.devFeeOnBuy, 'devFeeOnBuy', map.periodName);

            map.devFeeOnBuy = _devFeeOnBuy;

        }

        if (map.distributionFeeOnBuy != _distributionFeeOnBuy) {

            emit CustomTaxPeriodChange(_distributionFeeOnBuy, map.distributionFeeOnBuy, 'distributionFeeOnBuy', map.periodName);

            map.distributionFeeOnBuy = _distributionFeeOnBuy;

        }

    }

    function _swapAndLiquify() private {

        uint256 contractBalance = balanceOf(address(this));

        uint256 initialBNBBalance = address(this).balance;

        uint8 _totalFeePrior = _totalFee;



        uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFeePrior / 2;

        uint256 amountToSwap = contractBalance - amountToLiquify;



        _swapTokensForBNB(amountToSwap);



        uint256 BNBBalanceAfterSwap = address(this).balance - initialBNBBalance;

        uint256 totalBNBFee = _totalFeePrior - (_liquidityFee / 2);

        uint256 amountBNBLiquidity = BNBBalanceAfterSwap * _liquidityFee / totalBNBFee / 2;

        uint256 amountBNBMarketing = BNBBalanceAfterSwap * _marketingFee / totalBNBFee;

        uint256 amountBNBDev = BNBBalanceAfterSwap * _devFee / totalBNBFee;

        uint256 amountBNBDistribution = BNBBalanceAfterSwap - (amountBNBLiquidity + amountBNBMarketing + amountBNBDev);



        Address.sendValue(payable(marketingWallet),amountBNBMarketing);

        Address.sendValue(payable(devWallet),amountBNBDev);

        Address.sendValue(payable(distributionWallet),amountBNBDistribution);



        if (amountToLiquify > 0) {

            _addLiquidity(amountToLiquify, amountBNBLiquidity);

            emit SwapAndLiquify(amountToSwap, amountBNBLiquidity, amountToLiquify);

        }



        _totalFee = _totalFeePrior;

    }

    function _swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            1, // accept any amount of ETH

            path,

            address(this),

            block.timestamp

        );

    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: bnbAmount}(

            address(this),

            tokenAmount,

            1, // slippage is unavoidable

            1, // slippage is unavoidable

            liquidityWallet,

            block.timestamp

        );

    }

}