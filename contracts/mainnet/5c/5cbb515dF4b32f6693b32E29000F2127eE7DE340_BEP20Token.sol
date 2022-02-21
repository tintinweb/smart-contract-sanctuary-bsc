pragma solidity ^ 0.8.4;
// SPDX-License-Identifier: Unlicensed
                                                                              																			  
interface IBEP20 {
    function totalSupply() external view returns(uint256);

    function decimals() external view returns(uint8);

    function symbol() external view returns(string memory);

    function name() external view returns(string memory);

    function getOwner() external view returns(address);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address recipient, uint256 amount) external returns(bool);

    function allowance(address _owner, address spender) external view returns(uint256);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns(address);

    function feeToSetter() external view returns(address);

    function getPair(address tokenA, address tokenB) external view returns(address pair);

    function allPairs(uint) external view returns(address pair);

    function allPairsLength() external view returns(uint);

    function createPair(address tokenA, address tokenB) external returns(address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns(string memory);

    function symbol() external pure returns(string memory);

    function decimals() external pure returns(uint8);

    function totalSupply() external view returns(uint);

    function balanceOf(address owner) external view returns(uint);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint value) external returns(bool);

    function transfer(address to, uint value) external returns(bool);

    function transferFrom(address from, address to, uint value) external returns(bool);

    function DOMAIN_SEPARATOR() external view returns(bytes32);

    function PERMIT_TYPEHASH() external pure returns(bytes32);

    function nonces(address owner) external view returns(uint);

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

    function MINIMUM_LIQUIDITY() external pure returns(uint);

    function factory() external view returns(address);

    function token0() external view returns(address);

    function token1() external view returns(address);

    function getReserves() external view returns(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns(uint);

    function price1CumulativeLast() external view returns(uint);

    function kLast() external view returns(uint);

    function mint(address to) external returns(uint liquidity);

    function burn(address to) external returns(uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns(address);

    function WETH() external pure returns(address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns(uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns(uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns(uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns(uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns(uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns(uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns(uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns(uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns(uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns(uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns(uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns(uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns(uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns(uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns(uint amountETH);

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

contract Context {
    constructor() {}

    function _msgSender() internal view returns(address) {
        return msg.sender;
    }

    function _msgData() internal view returns(bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "only for owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Manageable is Ownable {
    address private _manager;

    event ManagmentTransferred(address indexed previousManager, address indexed newManager);

    constructor() {
        address msgSender = _msgSender();
        _manager = msgSender;
        emit ManagmentTransferred(address(0), msgSender);
    }

    function manager() public view returns(address) {
        return _manager;
    }

    modifier onlyManager() {
        require(_manager == _msgSender(), "only for manager");
        _;
    }

    function transferManagment(address newManager) public onlyManager {
        emit ManagmentTransferred(_manager, newManager);
        _manager = newManager;
    }
}

contract BEP20Token is IBEP20, Manageable {
	address public constant _burnAddress = 0x000000000000000000000000000000000000dEaD ;
	
    mapping(address => uint256) private _bep20Balances;
    mapping(address => mapping(address => uint256)) private _bep20Allowances;
	
	mapping (address => bool) private _isMaxRatioExcluded;
	
	/*struct Item {
		string code;
		string name;
		bytes32 data;
	}
	
    mapping(address => mapping(string => Item)) private _trackedAddressesItems;*/
	
	struct PrepareTransfer {
		uint256 amount;
		string transferData;
	}
	
	struct TrackedTransfer {
		uint256 time;
		uint256 amount;
		string transferData;
	}

	address[] private _trackedAddresses;
	mapping (address => bool) private _trackedAddressesExists;
	
	uint256 private _trackedLastTransferTimestamp;
	mapping (address => uint256) private _trackedAddressesLastTransferTimestamp;
	mapping (address => mapping (address => uint256)) private  _trackedAddressesSenderLastTransferTimestamp;	
	
	mapping (address => address[]) private _trackedAddressesSenders;
	mapping (address => mapping (address => bool)) private _trackedAddressesSendersExists;	
	
	mapping (address => mapping (address => PrepareTransfer)) private  _trackedAddressesPrepareTransfers;	
	mapping (address => mapping (address => TrackedTransfer[])) private  _trackedAddressesTransfers;
	
    uint8 private constant _decimals = 12;
    string private _symbol = "OPKEE";
    string private _name = "Opkee.tech";
    uint256 private constant _targetSupply = 1024 * 1024 * 1024 * 32 * 12 * (10 ** uint256(_decimals));
    uint256 private constant _initialSupply = _targetSupply * 4;
    uint256 private _totalSupply;
	
    uint256 private constant _burnRateLimit = 650; /* 650 = 6.5% */
    uint256 private _burnRate = 275; /* 275 = 2.75% */
	
    uint256 private constant _devRateLimit = 350; /* 350 = 3.5% */
    uint256 private _devRate = 225; /* 225 = 2.25% */

    uint256 private constant _managerWalletRateLimit = 495; /* 495 = 4.95% */

	uint256 private _maxWalletTotalSupplyRatio = 115; /* 115 = 1.15%, 0 = No Limitation */
	
	bool private _enableTransferWithData = false;
	
    IUniswapV2Router02 private _uniswapV2Router;
    IUniswapV2Pair public _uniswapV2Pair;
	
	/*"This contract is managed by the development team. The burn rate, the max wallet ratio and the communication and development fee rate may change during the life of the contract to adapt to present conditions. The management of the contract is different from the ownership of the contract. Under no circumstances can the manager manipulate transfers or the number of units outstanding. This can be verified by examining the contract code." */

    constructor() {
        _totalSupply = _initialSupply;
        _bep20Balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
		
		updateExcludeFromMaxRatio(_burnAddress, true) ;
    }
	
    function getOwner() external view returns(address) {
        return owner();
    }

    function decimals() external pure returns(uint8) {
        return _decimals;
    }

	// symbol
    function symbol() external view returns(string memory) {
        return _symbol;
    }

	event SymbolUpdated(string previousValue, string newValue);
    function setSymbol(string memory newSymbol) external onlyManager() {
		emit SymbolUpdated(_symbol, newSymbol) ;
        _symbol = newSymbol;
    }
	
	// name
    function name() external view returns(string memory) {
        return _name;
    }

	event NameUpdated(string previousValue, string newValue);
    function setName(string memory newName) external onlyManager() {
		emit NameUpdated(_name, newName) ;
        _name = newName;
    }
	
	// supply
    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function activeSupply() external view returns(uint256) {
        return _totalSupply - _bep20Balances[_burnAddress];
    }
	
    function balanceOf(address account) external view returns(uint256) {
        return _bep20Balances[account];
    }

	// _burnRate
    function burnRate() external view returns(uint256) {
        return _burnRate;
    }

    event BurnRateUpdated(uint256 previousValue, uint256 newValue);
    function setBurnRate(uint256 newRate) external onlyManager() {
        require(newRate <= _burnRateLimit, "rate > limit");
        emit BurnRateUpdated(_burnRate, newRate);
        _burnRate = newRate;
    }
	
	// _devRate
    function devRate() external view returns(uint256) {
        return _devRate;
    }

    event DevRateUpdated(uint256 previousValue, uint256 newValue);
    function setDevRate(uint256 newRate) external onlyManager() {
        require(newRate <= _devRateLimit, "rate > limit");
        emit DevRateUpdated(_devRate, newRate);
        _devRate = newRate;
    }

	// _maxWalletTotalSupplyRatio
    function maxWalletTotalSupplyRatio() external view returns(uint256) {
        return _maxWalletTotalSupplyRatio;
    }
	
    event MaxWalletTotalSupplyRatioUpdated(uint256 previousValue, uint256 newValue);	
    function setMaxWalletTotalSupplyRatio(uint256 newRate) external onlyManager() {
		require(newRate <= 1000, "newRate > 10%");
		emit MaxWalletTotalSupplyRatioUpdated(_maxWalletTotalSupplyRatio, newRate);
        _maxWalletTotalSupplyRatio = newRate;
    }
	
    /*function setInitialBotProtection(bool newValue) external onlyOwner() {
        _isInitialBotProtectionActivated = newValue;
    }*/
	
    function isMaxRatioExcluded(address account) external view returns (bool) {
        return _isMaxRatioExcluded[account];
    }
	
    function updateExcludeFromMaxRatio(address account, bool newValue) public onlyManager() {
        _isMaxRatioExcluded[account] = newValue;
    }
		
	function migrateHolderBalances(address[] calldata accounts, uint256[] calldata amounts) external {
		bulkDistribution(accounts, amounts, false) ;
	}
	
	function airdrop(address[] calldata accounts, uint256[] calldata amounts) external {
		bulkDistribution(accounts, amounts, true) ;
	}
	
	function bulkDistribution(address[] calldata accounts, uint256[] calldata amounts, bool isAirdrop) internal onlyOwner {
		require(accounts.length == amounts.length, "size mismatch");
        for(uint256 i = 0; i < accounts.length; i++) {
			address account = accounts[i] ;
			if (isAirdrop || _bep20Balances[account] < amounts[i]) {
				uint256 delta = isAirdrop ? amounts[i] : amounts[i] - _bep20Balances[account] ;
				require(_bep20Balances[msg.sender] >= delta, "insufficient balance");
				_bep20Balances[account] += delta;
				_bep20Balances[msg.sender] -= delta;
				if (isAirdrop) {
					emit Transfer(msg.sender, account, delta);						
				} else{
					emit Transfer(msg.sender, address(0), delta);
					emit Transfer(address(0), account, delta);				
				}
			}
        }
    }
	
    function prepareTransferDataByReceiver(address expectedTransferSender, uint256 amount, string memory transferData) external returns(bool) {
        return _prepareTransferData(_msgSender(), expectedTransferSender, amount, transferData) ;
    }
	
    function prepareTransferDataBySender(address expectedTransferReceiver, uint256 amount, string memory transferData) external returns(bool) {
        return _prepareTransferData(expectedTransferReceiver, _msgSender(), amount, transferData) ;
    }
	
	function _prepareTransferData(address receiver, address sender, uint256 amount, string memory transferData) internal returns(bool)  {
		require(amount > 0, "amount is 0");
		require(sender != address(0), "Sender is 0x0");	
		require(receiver != address(0), "prepare the 0x0");
		require(_trackedAddressesExists[receiver], "inactive receiver");		
		PrepareTransfer storage prepareTransfer =  _trackedAddressesPrepareTransfers[receiver][sender];
		prepareTransfer.amount = amount;
		prepareTransfer.transferData = transferData;
		_trackedAddressesPrepareTransfers[receiver][sender] = prepareTransfer;
        return true;
	}
		
    function enableTransferWithData() external view returns(bool) {
        return _enableTransferWithData;
    }		

    function setEnableTransferWithData(bool newValue) external onlyOwner() {
        _enableTransferWithData = newValue;
    }
	
    function transferWithData(address recipient, uint256 amount, string memory transferData) external returns(bool) {
		require(_enableTransferWithData, "deactivated");
		if (_prepareTransferData(recipient, _msgSender(), amount, transferData)) {
			_transfer(_msgSender(), recipient, amount);
		}
        return false;
    }
	
    function transfer(address recipient, uint256 amount) external returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
    function allowance(address owner, address spender) external view returns(uint256) {
        return _bep20Allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _bep20Allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
	
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require((amount > 0) && (amount <= _totalSupply), "amount must be > 0 and < supply");
        require(sender != address(0), "transfer from 0x0");
        require(recipient != address(0), "transfer to 0x0");		
		require(sender != recipient, "loop transfer");
		uint256 senderBalance = _bep20Balances[sender];
		require(senderBalance >= amount, "amount exceeds balance");
		
        uint256 transferAmount = amount;

		if ((sender != address(this)) && (recipient != address(this)) && (recipient != _burnAddress) && !_trackedAddressesExists[recipient]) {
			address manager = manager();	
			
			if ((manager != sender) && (manager != recipient) || (manager == address(0))) {
				uint256 currentActiveSupply = _totalSupply - _bep20Balances[_burnAddress];
				if ((_burnRate > 0) && (currentActiveSupply > _targetSupply)) {		
					uint256 burnedAmount = amount * _burnRate / 10000;
					/*if (_isInitialBotProtectionActivated && (owner() != address(0))) {
						// Temporary protection against bots during token initialization.
						// Cannot be used once the ownership is renounced.
						burnedAmount = amount * _initialBotProtectionRate / 10000;
					}*/
					if ( (burnedAmount > 0) && (burnedAmount <= transferAmount) ) {
						transferAmount = transferAmount - burnedAmount;
						_bep20Balances[_burnAddress] += burnedAmount;
						emit Transfer(sender, _burnAddress, burnedAmount);						
					}
				}
			}

			if ((_devRate > 0) && (manager != address(0)) && (sender != manager) && (recipient != manager)) {
				uint256 managerWalletAmount = _bep20Balances[manager];
				uint256 managerWalletAmountLimit = _totalSupply * _managerWalletRateLimit / 10000;
				if (managerWalletAmount < managerWalletAmountLimit) {
					uint256 devAmount = amount * _devRate / 10000;
					if ( (devAmount > 0) && (devAmount <= transferAmount) ) {
						transferAmount = transferAmount - devAmount;
						_bep20Balances[manager] += devAmount;
						emit Transfer(sender, manager, devAmount);
					}
				}
			}
			
			if (_maxWalletTotalSupplyRatio > 0) {
				if ((recipient != manager) && (recipient != owner()) && (recipient != address(this)) && !_isMaxRatioExcluded[recipient]) {
					uint256 maxWalletAmount =  (_totalSupply * _maxWalletTotalSupplyRatio) / 10000 ;
					uint256 newRecipientWalletAmount = _bep20Balances[recipient] + transferAmount ;
					require(newRecipientWalletAmount <= maxWalletAmount, "exceeds max wallet ratio");
				}
			}		
		}
		
        _bep20Balances[sender] = _bep20Balances[sender] - amount;
        _bep20Balances[recipient] = _bep20Balances[recipient] + transferAmount;

        emit Transfer(sender, recipient, transferAmount);
		
		if(_trackedAddressesExists[recipient]) {
			if (!_trackedAddressesSendersExists[recipient][sender]) {
				_trackedAddressesSenders[recipient].push(sender) ;
				_trackedAddressesSendersExists[recipient][sender] = true;
			}
		 		
			TrackedTransfer[] storage trackedTransfers =  _trackedAddressesTransfers[recipient][sender];
			trackedTransfers.push();
			uint id = trackedTransfers.length - 1;
			trackedTransfers[id].time = block.timestamp;
			trackedTransfers[id].amount = transferAmount;
			
		 	PrepareTransfer storage prepareTransfer =  _trackedAddressesPrepareTransfers[recipient][sender];
			
			if (prepareTransfer.amount == amount) {				
				trackedTransfers[id].transferData = prepareTransfer.transferData;				
				prepareTransfer.amount = 0;
				prepareTransfer.transferData = "";
				_trackedAddressesPrepareTransfers[recipient][sender] = prepareTransfer;	
			}

			_trackedLastTransferTimestamp = block.timestamp;
			_trackedAddressesLastTransferTimestamp[recipient] = block.timestamp;
			_trackedAddressesSenderLastTransferTimestamp[recipient][sender] = block.timestamp;
						
			_trackedAddressesTransfers[recipient][sender] = trackedTransfers;
		}		
    }

	event Destroyed(uint256 amount);
    function destroy(uint256 destroyedAmount) external onlyManager() {
		require(_totalSupply - destroyedAmount >= _targetSupply, "Total supply < amount");
		uint256 burnBalance = _bep20Balances[_burnAddress];
		require(burnBalance >= destroyedAmount, "amount exceeds balance");		
		emit Destroyed(destroyedAmount) ;
		_bep20Balances[_burnAddress] -= destroyedAmount;
        _totalSupply = _totalSupply - destroyedAmount;
    }
	
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "from is 0x0");
        require(spender != address(0), "to is 0x0");
        _bep20Allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function initUniswapV2(address uniswapV2Router) external onlyOwner {
        require(uniswapV2Router != address(0), "init from 0x0");	
        if (address(_uniswapV2Pair) == address(0)) {
			// Uniswap V2 router
			_uniswapV2Router = IUniswapV2Router02(uniswapV2Router);
			// Create a uniswap pair for this new token
			_uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()));
			updateExcludeFromMaxRatio(uniswapV2Router, true) ;
			updateExcludeFromMaxRatio(address(_uniswapV2Pair), true) ;
		}
    }

	function isTracked() external view returns(bool) {
		address sender = _msgSender();
		return _trackedAddressesExists[sender] ;
	}
	
	function trackMe() external {
		address sender = _msgSender();
		require(_bep20Balances[sender] > 0, "your balance is 0");
        if(_trackedAddressesExists[sender])
            return;
        _trackedAddressesExists[sender] = true;
        _trackedAddresses.push(sender);
    }

	function getSendersToMe() external view returns (address[] memory) {	
        return  getSendersFromReceiver(_msgSender()) ;
    }
	
	function _checkReceiver(address transferReceiver) internal view {
		require(transferReceiver != address(0), "0x0 not tracked");
		require(_trackedAddressesExists[transferReceiver], "address not tracked");	
	}
	
	function getSendersFromReceiver(address transferReceiver) public view returns (address[] memory) {
		_checkReceiver(transferReceiver) ;
        return  _trackedAddressesSenders[transferReceiver] ;
    }
	
	function getSendersFromReceiverWithTimestamp(address transferReceiver) public view returns (address[] memory, uint256[] memory) {
		_checkReceiver(transferReceiver) ;
		address[] memory senders = _trackedAddressesSenders[transferReceiver];
		uint256[] memory timestamps = new uint256[](senders.length);
		for(uint i = 0; i < timestamps.length; i++) {
			timestamps[i] = _trackedAddressesSenderLastTransferTimestamp[transferReceiver][senders[i]];
		}
        return  (senders, timestamps) ;
    }
	
	function getTransfers(address transferSender, address transferReceiver) public view returns (TrackedTransfer[] memory) {
		require(transferSender != address(0), "sender is 0x0");
		_checkReceiver(transferReceiver) ;
        return  _trackedAddressesTransfers[transferReceiver][transferSender] ;
    }
	
	function getTransfersSentToMe(address transferSender) external view returns (TrackedTransfer[] memory) {
        return  getTransfers(transferSender, _msgSender()) ;
    }
	
	function getTransfersSentByMe(address transferReceiver) external view returns (TrackedTransfer[] memory) {
        return  getTransfers(_msgSender(), transferReceiver) ;
    }	
	
    function getLastTrackedTransferTimestamp() external view returns(uint256) {
        return _trackedLastTransferTimestamp;
    }	
	
	function getLastTrackedTransferTimestampByReceiver(address transferReceiver) external view returns (uint256) {
		_checkReceiver(transferReceiver) ;
        return  _trackedAddressesLastTransferTimestamp[transferReceiver] ;
    }		

	function getLastTrackedTransferTimestampByReceiverBySender(address transferSender, address transferReceiver) external view returns (uint256) {
		_checkReceiver(transferReceiver) ;	
        return  _trackedAddressesSenderLastTransferTimestamp[transferReceiver][transferSender] ;
    }	
}