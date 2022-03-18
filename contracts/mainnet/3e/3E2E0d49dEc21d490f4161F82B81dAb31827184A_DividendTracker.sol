// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./abstracts/Context.sol";
import "./libraries/SafeMath.sol";
import "./libraries/SafeMathUint.sol";
import "./libraries/SafeMathInt.sol";
import "./AdoToken.sol";

contract DividendTracker is Context {
	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	uint256 private constant MAGNITUDE = 2**128;
	uint256 public constant MILESTONE1 = 5000;
	uint256 public constant MILESTONE2 = 10000;
	uint256 public constant MILESTONE3 = 25000;
	uint256 public constant MILESTONE4 = 50000;
	uint256 public constant MILESTONE5 = 75000;
	uint256 public constant MILESTONE6 = 100000;
	uint256 public constant MILESTONE7 = 150000;
	struct MilestoneDetails { bool active; uint8 burn; }
	struct ReferrerDetails { uint256 transactions; uint256 bonus; uint256 totalValue; uint256 commissions; }
	struct DividendsHolders {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) active;
	}
	DividendsHolders private _tokenHoldersMap;
	address[] private _referredSwaps;
	uint256 private _totalSupply;
	uint256 private _totalDividendsDistributed;
	uint256 private _magnifiedDividendPerShare;
	uint256 private _minimumTokenBalanceForDividends;
	uint256 private _minimumTokenBalanceForLottery;
	uint256 private _lastProcessedIndex;
	uint256 private _claimWait = 600;
	uint256 private _lastMilestoneReached;
	uint256 private _unqualified;
	address private _hlWinner;
	address private _rlWinner;
	mapping(address => int256) private _magnifiedDividendCorrections;
	mapping(address => uint256) private _withdrawnDividends;
	mapping(address => uint256) private _balances;
	mapping(address => bool) private _excludedFromDividends;
	mapping(address => bool) private _excludedFromLottery;
	mapping(address => uint256) private _lastClaimTimes;
	mapping(address => ReferrerDetails) private _referrers;
	mapping(uint256 => MilestoneDetails) private _milestones;
	uint256[] private _milestonesList;
	mapping(uint256 => uint256) private _bonusStructure;
	AdoToken public tokenContract;

	event NewMilestone(uint256 indexed milestone);
	event ExcludeFromDividends(address indexed account);
	event ExcludeFromLottery(address indexed account);
	event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event Claim(address indexed account, uint256 amount, bool indexed automatic);
	event MinimumTokenBalanceForDividendsUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event MinimumTokenBalanceForLotteryUpdated(uint256 indexed newValue);
	event HoldersLotteryWinner(address indexed account, uint256 indexed milestone, uint256 amount, uint256 burn);
	event ReferrersLotteryWinner(address indexed account);
	event DividendsDistributed(address indexed from, uint256 weiAmount);
	event NoMoreDividends(uint256 totalDividendsDistributed);

	modifier onlyTokenContract() {
		require(_msgSender() == address(tokenContract), "DividendTracker: Only the token contract can call this function");
		_;
	}

	constructor(AdoToken _tokenContract) {
		tokenContract = _tokenContract;
		_minimumTokenBalanceForDividends = tokenContract.totalSupply().div(10000);
		_excludedFromDividends[address(this)] = true;
		_excludedFromDividends[address(tokenContract)] = true;
		_excludedFromDividends[BURN_ADDRESS] = true;
		_excludedFromDividends[_msgSender()] = true;
		_milestones[MILESTONE1] = MilestoneDetails({ active : true, burn: 5 });
		_milestones[MILESTONE2] = MilestoneDetails({ active : true, burn: 10 });
		_milestones[MILESTONE3] = MilestoneDetails({ active : true, burn: 15 });
		_milestones[MILESTONE4] = MilestoneDetails({ active : true, burn: 20 });
		_milestones[MILESTONE5] = MilestoneDetails({ active : true, burn: 25 });
		_milestones[MILESTONE6] = MilestoneDetails({ active : true, burn: 30 });
		_milestones[MILESTONE7] = MilestoneDetails({ active : true, burn: 35 });
		_milestonesList = [MILESTONE1, MILESTONE2, MILESTONE3, MILESTONE4, MILESTONE5, MILESTONE6, MILESTONE7];
		_bonusStructure[5] = 1;
		_bonusStructure[20] = 2;
		_bonusStructure[50] = 4;
		_bonusStructure[100] = 6;
		_bonusStructure[250] = 9;
	}

	receive() external payable {}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) external view returns (uint256) {
		return _balances[account];
	}

	function lastMilestoneReached() external view returns (uint256) {
		return _lastMilestoneReached;
	}

	function holdersLotteryWinner() external view returns (address) {
		return _hlWinner;
	}

	function referrersLotteryWinner() external view returns (address) {
		return _rlWinner;
	}

	function nextMilestone() external view returns (uint256) {
		return _milestonesList.length > 0 ? _milestonesList[0] : 0;
	}

	function maxMilestone() external view returns (uint256) {
		return _milestonesList.length > 0 ? _milestonesList[_milestonesList.length-1] : 0;
	}

	function referredSwaps() external view returns (uint256 total, uint256 lotterySwaps) {
		total = _unqualified.add(_referredSwaps.length);
		lotterySwaps = _referredSwaps.length;
	}

	function isExcludedFromLottery(address account) external view returns (bool) {
		return _excludedFromLottery[account];
	}

	function isExcludedFromDividends(address account) external view returns (bool) {
		return _excludedFromDividends[account];
	}

	function totalDividendsDistributed() external view returns (uint256) {
		return _totalDividendsDistributed;
	}

	function withdrawableDividendOf(address account) public view returns(uint256) {
		return accumulativeDividendOf(account).sub(_withdrawnDividends[account]);
	}

	function minimumTokenBalanceForDividends() external view returns(uint256) {
		return _minimumTokenBalanceForDividends;
	}

	function minimumTokenBalanceForLottery() external view returns(uint256) {
		return _minimumTokenBalanceForLottery;
	}

	function claimWait() external view returns(uint256) {
		return _claimWait;
	}

	function getLastProcessedIndex() external view returns(uint256) {
		return _lastProcessedIndex;
	}

	function getNumberOfDividendsTokenHolders() external view returns(uint256) {
		return _tokenHoldersMap.keys.length;
	}

	function accumulativeDividendOf(address _owner) public view returns(uint256) {
		return _magnifiedDividendPerShare.mul(_balances[_owner])
			.toInt256Safe()
			.add(_magnifiedDividendCorrections[_owner])
			.toUint256Safe() / MAGNITUDE;
	}

	function getReferrer(address account) external view returns (uint256 transactions, uint256 bonus, uint256 totalValue, uint256 commissions, bool excludedFromLottery) {
		transactions = _referrers[account].transactions;
		bonus = _referrers[account].bonus;
		totalValue = _referrers[account].totalValue;
		commissions = _referrers[account].commissions;
		excludedFromLottery = _excludedFromLottery[account];
	}

	function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
		account = _account;
		index = _getIndexOfKey(account);
		iterationsUntilProcessed = -1;

		if (index >= 0) {
			if (uint256(index) > _lastProcessedIndex) {
				iterationsUntilProcessed = index.sub(int256(_lastProcessedIndex));
			} else {
				uint256 processesUntilEndOfArray = _tokenHoldersMap.keys.length > _lastProcessedIndex ? _tokenHoldersMap.keys.length.sub(_lastProcessedIndex) : 0;
				iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
			}
		}
		withdrawableDividends = withdrawableDividendOf(account);
		totalDividends = accumulativeDividendOf(account);
		lastClaimTime = _lastClaimTimes[account];
		nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(_claimWait) : 0;
		secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
	}

	function getAccountAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
		if (index >= _tokenHoldersMap.keys.length) {
			return (address(0), -1, -1, 0, 0, 0, 0, 0);
		}
		address account = _getKeyAtIndex(index);
		return getAccount(account);
	}

	function _removeMilestoneFromList() private {
        if (_milestonesList.length > 1) {
			for (uint i = 0; i < _milestonesList.length-1; i++) {
            	_milestonesList[i] = _milestonesList[i+1];
        	}
		}
		_milestonesList.pop();
    }

	function _withdrawDividendOfUser(address payable user) private returns (uint256) {
		uint256 _withdrawableDividend = withdrawableDividendOf(user);
		if (_withdrawableDividend > 0) {
			_withdrawnDividends[user] = _withdrawnDividends[user].add(_withdrawableDividend);
			(bool success,) = user.call{value: _withdrawableDividend, gas: 3000}('');
			if (!success) {
				_withdrawnDividends[user] = _withdrawnDividends[user].sub(_withdrawableDividend);
				return 0;
			}
			return _withdrawableDividend;
		}
		return 0;
	}

	function _setBalance(address account, uint256 newBalance) private {
		uint256 currentBalance = _balances[account];
		if (newBalance > currentBalance) {
			uint256 mintAmount = newBalance.sub(currentBalance);
			_mint(account, mintAmount);
		} else if (newBalance < currentBalance) {
			uint256 burnAmount = currentBalance.sub(newBalance);
			_burn(account, burnAmount);
		}
	}

	function _mint(address account, uint256 value) private {
		require(account != address(0), "DividendTracker: mint to the zero address");
		_totalSupply = _totalSupply.add(value);
		_balances[account] = _balances[account].add(value);
		_magnifiedDividendCorrections[account] = _magnifiedDividendCorrections[account]
			.sub((_magnifiedDividendPerShare.mul(value))
			.toInt256Safe());
	}

	function _burn(address account, uint256 value) private {
		require(account != address(0), "DividendTracker: burn from the zero address");
		_balances[account] = _balances[account].sub(value, "DividendTracker: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(value);
		_magnifiedDividendCorrections[account] = _magnifiedDividendCorrections[account]
			.add((_magnifiedDividendPerShare.mul(value))
			.toInt256Safe());
	}

	function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
		if (lastClaimTime > block.timestamp) {
			return false;
		}
		return block.timestamp.sub(lastClaimTime) >= _claimWait;
	}

	function _setHolder(address key, uint val) private {
		if (_tokenHoldersMap.active[key]) {
			_tokenHoldersMap.values[key] = val;
		} else {
			_tokenHoldersMap.active[key] = true;
			_tokenHoldersMap.values[key] = val;
			_tokenHoldersMap.indexOf[key] = _tokenHoldersMap.keys.length;
			_tokenHoldersMap.keys.push(key);
		}
	}

	function _removeHolder(address key) private {
		if (!_tokenHoldersMap.active[key]) {
			return;
		}
		delete _tokenHoldersMap.active[key];
		delete _tokenHoldersMap.values[key];
		uint index = _tokenHoldersMap.indexOf[key];
		uint lastIndex = _tokenHoldersMap.keys.length - 1;
		address lastKey = _tokenHoldersMap.keys[lastIndex];
		_tokenHoldersMap.indexOf[lastKey] = index;
		delete _tokenHoldersMap.indexOf[key];
		_tokenHoldersMap.keys[index] = lastKey;
		_tokenHoldersMap.keys.pop();
	}

	function _processAccount(address payable account, bool automatic) private returns (bool) {
		uint256 amount = _withdrawDividendOfUser(account);
		if (amount > 0) {
			_lastClaimTimes[account] = block.timestamp;
			emit Claim(account, amount, automatic);
			return true;
		}
		return false;
	}

	function _getIndexOfKey(address key) private view returns (int) {
		if(!_tokenHoldersMap.active[key]) {
			return -1;
		}
		return int(_tokenHoldersMap.indexOf[key]);
	}

	function _getKeyAtIndex(uint index) private view returns (address) {
		return _tokenHoldersMap.keys[index];
	}

	function claim(address _holder) external onlyTokenContract {
		_processAccount(payable(_holder), false);
	}

	function updateDividendsDistributed(uint256 amount) external onlyTokenContract {
		if (_totalSupply > 0 && amount > 0) {
			_magnifiedDividendPerShare = _magnifiedDividendPerShare
				.add((amount)
				.mul(MAGNITUDE) / _totalSupply);
			emit DividendsDistributed(_msgSender(), amount);
			_totalDividendsDistributed = _totalDividendsDistributed.add(amount);
		}
	}

	function excludeFromDividends(address account) external onlyTokenContract {
		require(!_excludedFromDividends[account]);
		_excludedFromDividends[account] = true;
		_setBalance(account, 0);
		_removeHolder(account);
		emit ExcludeFromDividends(account);
	}

	function excludeFromLottery(address account) external onlyTokenContract {
		require(!_excludedFromLottery[account]);
		_excludedFromLottery[account] = true;
		emit ExcludeFromLottery(account);
	}

	function payCommission(address referrer, uint256 amount) external onlyTokenContract {
		if (amount >= _minimumTokenBalanceForDividends) {
			_referrers[referrer].transactions = _referrers[referrer].transactions.add(1);
			uint256 commission = 1;
			if (_bonusStructure[_referrers[referrer].transactions] > _referrers[referrer].bonus) {
				_referrers[referrer].bonus = _bonusStructure[_referrers[referrer].transactions];
			}
			_referrers[referrer].totalValue = _referrers[referrer].totalValue.add(amount);
			commission = commission.add(_referrers[referrer].bonus);
			uint256 commissionValue = amount.div(100).mul(commission);
			_referrers[referrer].commissions = _referrers[referrer].commissions.add(commissionValue);
			tokenContract.transfer(referrer, commissionValue);
			if (!_excludedFromLottery[referrer] && _referrers[referrer].transactions >= 5) {
				_referredSwaps.push(referrer);
			} else {
				_unqualified++;
			}
		}
	}

	function updateMinimumTokenBalanceForDividends(uint256 newValue) external onlyTokenContract {
		require(newValue < _minimumTokenBalanceForDividends, "DividendTracker: The new value cannot be higher than the previous value");
		emit MinimumTokenBalanceForDividendsUpdated(_minimumTokenBalanceForDividends, newValue);
		_minimumTokenBalanceForDividends = newValue;
	}

	function updateClaimWait(uint256 newClaimWait) external onlyTokenContract {
		require(newClaimWait >= 600 && newClaimWait <= 86400, "DividendTracker: claimWait must be between 1 and 24 hours");
		emit ClaimWaitUpdated(newClaimWait, _claimWait);
		_claimWait = newClaimWait;
	}

	function setBalance(address payable account, uint256 newBalance) external onlyTokenContract {
		if (_excludedFromDividends[account]) {
			return;
		}
		if (newBalance >= _minimumTokenBalanceForDividends) {
			_setBalance(account, newBalance);
			_setHolder(account, newBalance);
		} else {
			_setBalance(account, 0);
			_removeHolder(account);
		}
		_processAccount(account, true);
	}

	function process(uint256 gas) external onlyTokenContract returns (uint256, uint256, uint256) {
		uint256 numberOfTokenHolders = _tokenHoldersMap.keys.length;
		if (numberOfTokenHolders == 0) {
			return (0, 0, _lastProcessedIndex);
		}
		uint256 lastProcessedIndex = _lastProcessedIndex;
		uint256 gasUsed = 0;
		uint256 gasLeft = gasleft();
		uint256 iterations = 0;
		uint256 claims = 0;
		while (gasUsed < gas && iterations < numberOfTokenHolders) {
			lastProcessedIndex++;
			if (lastProcessedIndex >= _tokenHoldersMap.keys.length) {
				lastProcessedIndex = 0;
			}
			address account = _tokenHoldersMap.keys[lastProcessedIndex];
			if (_canAutoClaim(_lastClaimTimes[account])) {
				if (_processAccount(payable(account), true)) {
					claims++;
				}
			}
			iterations++;
			uint256 newGasLeft = gasleft();
			if (gasLeft > newGasLeft) {
				gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
			}
			gasLeft = newGasLeft;
		}
		_lastProcessedIndex = lastProcessedIndex;
		return (iterations, claims, _lastProcessedIndex);
	}

	function setMilestone(uint256 milestone) external onlyTokenContract {
		_milestonesList.push(milestone);
		_milestones[milestone] = MilestoneDetails({ active : true, burn: 0 });
		emit NewMilestone(milestone);
	}

	function holdersLotteryDraw() external onlyTokenContract {
		require(_milestonesList.length > 0, "DividendTracker: There are no active milestones");
		uint256 milestone = _milestonesList[0];
		require(_milestones[milestone].active, "DividendTracker: This milestone is not active");
		uint256 holders = _tokenHoldersMap.keys.length;
		require(holders >= milestone, "DividendTracker: Insufficient holders to activate this milestone");
		uint256 randomIndex = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _totalSupply, _magnifiedDividendPerShare, milestone, _msgSender()))) % holders);
		require(!_excludedFromLottery[_tokenHoldersMap.keys[randomIndex]], "DividendTracker: Excluded from lottery");
		require(tokenContract.balanceOf(_tokenHoldersMap.keys[randomIndex]) >=  _minimumTokenBalanceForLottery, "DividendTracker: Insufficient tokens");
		uint256 prize = tokenContract.holdersLotteryFund();
		bool success = tokenContract.payTheWinner(_tokenHoldersMap.keys[randomIndex]);
		if (success) {
			_hlWinner = _tokenHoldersMap.keys[randomIndex];
			_lastMilestoneReached = milestone;
			_removeMilestoneFromList();
			_milestones[milestone].active = false;
			uint256 toBurn = 0;
			if (_milestones[milestone].burn > 0) {
				toBurn = tokenContract.balanceOf(address(this))
					.div(100)
					.mul(_milestones[milestone].burn);
				tokenContract.transfer(BURN_ADDRESS, toBurn);
			}
			emit HoldersLotteryWinner(_hlWinner, milestone, prize, toBurn);
		}
	}

	function referrersLotteryDraw() external onlyTokenContract {
		uint256 referrers = _referredSwaps.length;
		uint256 randomIndex = (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _totalSupply, _magnifiedDividendPerShare, _tokenHoldersMap.keys.length, address(this).balance,  _msgSender()))) % referrers);
		require(!_excludedFromLottery[_referredSwaps[randomIndex]], "DividendTracker: Excluded from lottery");
		bool success = tokenContract.referrersLotteryFundWithdrawal();
		if (success) {
			_rlWinner = _referredSwaps[randomIndex];
			emit ReferrersLotteryWinner(_rlWinner);
		}
	}

	function updateMinTokensForLottery(uint256 value) external onlyTokenContract {
		_minimumTokenBalanceForLottery = value;
		emit MinimumTokenBalanceForLotteryUpdated(value);
	}

	function burnTheHouseDown() external onlyTokenContract {
		uint256 toBurn = tokenContract.balanceOf(address(this));
		tokenContract.transfer(BURN_ADDRESS, toBurn);
		emit NoMoreDividends(_totalDividendsDistributed);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// Web: https://www.ado.network
// Twitter: https://twitter.com/NetworkAdo
// Discord: https://discord.gg/n9FyS5Tr
// Telegram: https://t.me/ADOnetwork
// Reddit: https://www.reddit.com/r/ADO_Network/

import "./DividendTracker.sol";
import "./AdoVault.sol";
import "./abstracts/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeSwapV2Pair.sol";
import "./interfaces/IPancakeSwapV2Factory.sol";
import "./interfaces/IPancakeSwapV2Router02.sol";
import "./libraries/SafeMath.sol";

contract AdoToken is IERC20, Ownable {
	using SafeMath for uint256;

	address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	IPancakeSwapV2Router02 public pancakeSwapV2Router;
	IPancakeSwapV2Pair public pancakeSwapV2Pair;
	DividendTracker public dividendContract;
	AdoVault public vault;
	address public busd;

	string private _name = "ADO.Network";
	string private _symbol = "ADO";
	uint8 private _decimals = 18;
	address public immutable deployer;
	address public referrerLotteryWallet;
	bool private _swapEnabled = false;
	bool private _swapping = false;
	bool private _dividendContractSet = false;
	bool private _vaultContractSet = false;
	bool private _busdContractSet = false;
	uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
	uint256 private _numTokensToLiqudate = _totalSupply.div(1000);
	uint256 private _minDividendBalanceToProcess;
	uint256 private _gasForProcessing = 200000;
	uint256 public cursor;
	uint256 public partners;
	uint256 private _lpWeight;
	uint256 private _excludedAccounts;
	uint256 private _bbperthousand = 0;
	address private _bbrecipient = BURN_ADDRESS;
	uint256 public holdersLotteryFund;
	uint256 public referrersLotteryFund;
	uint256 public buyBackBalance;
	uint256 private _dividendFee = 2;
	uint256 private _buyBackFee = 6;
	uint256 private _lotteryFee = 2;
	uint256 private _totalFee = _dividendFee.add(_buyBackFee).add(_lotteryFee);
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping (address => bool) private _isExcludedFromFees;
	mapping (address => bool) private _partners;

	event ExcludeAddress(address indexed account, bool fromLottery, bool fromDividends);
	event NewPartner(address indexed account);
	event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event ReferrerLotteryWalletUpdate(address indexed account);
	event LPWeightUpdate(uint256 lpWeight);
	event FeeDistributionUpdate(uint256 buyBack, uint256 dividend, uint256 lottery);
	event AutoBuyBackUpdate(uint256 bbperthousand, address recipient);
	event MinimumDividendBalanceToProcess(uint256 indexed newValue, uint256 indexed oldValue);
	event TokenBalanceToLiqudateUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 indexed lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

	modifier onlyDeployer() {
		require(_msgSender() == deployer, "Token: Only the token deployer can call this function");
		_;
	}

	constructor() {
		deployer = owner();
		referrerLotteryWallet = owner();
		_isExcludedFromFees[owner()] = true;
		_isExcludedFromFees[address(this)] = true;
		_isExcludedFromFees[BURN_ADDRESS] = true;
		_excludedAccounts = 3;
		_balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), owner(), _totalSupply);
	}

	receive() external payable {}

	function name() external view override returns (string memory) {
		return _name;
	}

	function symbol() external view override returns (string memory) {
		return _symbol;
	}

	function decimals() external view override returns (uint8) {
		return _decimals;
	}

	function totalFee() external view returns (uint256) {
		return _totalFee;
	}

	function fees() external view returns (uint256 dividendFee, uint256 buyBackFee, uint256 lotteryFee, bool isActive) {
		dividendFee = _dividendFee;
		buyBackFee = _buyBackFee;
		lotteryFee = _lotteryFee;
		isActive = _totalFee > 0;
	}

	function totalSupply() external view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) external view override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) external override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Token: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Token: decreased allowance below zero"));
		return true;
	}

	function gasForProcessing() external view returns (uint256) {
		return _gasForProcessing;
	}

	function claimWait() external view returns(uint256) {
		return dividendContract.claimWait();
	}

	function lastMilestoneReached() external view returns (uint256) {
		return dividendContract.lastMilestoneReached();
	}

	function nextMilestone() external view returns (uint256) {
		return dividendContract.nextMilestone();
	}

	function maxMilestone() external view returns (uint256) {
		return dividendContract.maxMilestone();
	}

	function totalDividendsDistributed() external view returns (uint256) {
		return dividendContract.totalDividendsDistributed();
	}

	function isExcludedFromFees(address account) external view returns(bool) {
		return _isExcludedFromFees[account];
	}

	function isExcludedFromLottery(address account) external view returns (bool) {
		return dividendContract.isExcludedFromLottery(account);
	}

	function isExcludedFromDividends(address account) external view returns (bool) {
		return dividendContract.isExcludedFromDividends(account);
	}

	function minimumTokenBalanceForLottery() external view returns (uint256) {
		return dividendContract.minimumTokenBalanceForLottery();
	}

	function withdrawableDividendOf(address account) external view returns(uint256) {
		return dividendContract.withdrawableDividendOf(account);
	}

	function dividendTokenBalanceOf(address account) external view returns (uint256) {
		return dividendContract.balanceOf(account);
	}

	function accountDividendsInfo(address _account) external view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
		return dividendContract.getAccount(_account);
	}

	function accumulativeDividendOf(address account) external view returns(uint256) {
		return dividendContract.accumulativeDividendOf(account);
	}

	function accountDividendsInfoAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
		return dividendContract.getAccountAtIndex(index);
	}

	function referrerInfo(address account) external view returns (uint256 transactions, uint256 bonus, uint256 totalValue, uint256 commissions, bool excludedFromLottery) {
		return dividendContract.getReferrer(account);
	}

	function lastProcessedIndex() external view returns(uint256) {
		return dividendContract.getLastProcessedIndex();
	}

	function dividendTokenHolders() external view returns(uint256) {
		return dividendContract.getNumberOfDividendsTokenHolders();
	}

	function numTokensToLiqudate() external view returns(uint256) {
		return _numTokensToLiqudate;
	}

	function minimumTokenBalanceForDividends() external view returns(uint256) {
		return dividendContract.minimumTokenBalanceForDividends();
	}

	function taxSetup() external view returns(uint256, uint256, uint256) {
		uint256 weight = 10;
		return (_lpWeight, weight.sub(_lpWeight), cursor);
	}

	function buyBackSetup() external view returns(uint256, address) {
		return (_bbperthousand, _bbrecipient);
	}

	function setLPWeight(uint256 lpWeight) external onlyDeployer {
		require(lpWeight <= 10, "Token: LPWeight must be between 0 and 10");
		_lpWeight = lpWeight;
		emit LPWeightUpdate(_lpWeight);
	}

	function setAutoBuyBack(uint256 newValue, address recipient) external onlyDeployer {
		require(newValue >= 0 && newValue <= 10, "Token: AutoBuyBack must be between 0 and 10");
		if (recipient == address(dividendContract)) {
			_bbrecipient = address(dividendContract);
		} else {
			_bbrecipient = BURN_ADDRESS;
		}
		_bbperthousand = newValue;
		emit AutoBuyBackUpdate(_bbperthousand, _bbrecipient);
	}

	function excludeMeFromLottery() external {
		dividendContract.excludeFromLottery(_msgSender());
	}

	function claim() external {
		dividendContract.claim(_msgSender());
	}

	function setTokenFees(uint256 newBuyBackFee) external onlyDeployer {
		require(newBuyBackFee != _buyBackFee, "Token: The BuyBack fee is already set to the requested value");
		require(newBuyBackFee == 2 || newBuyBackFee == 4 || newBuyBackFee == 6, "Token: The BuyBack fee can only be 2 4 or 6");
		_buyBackFee = newBuyBackFee;
		_dividendFee = _totalFee.sub(_buyBackFee).sub(_lotteryFee);
		emit FeeDistributionUpdate(_buyBackFee, _dividendFee, _lotteryFee);
	}

	function referrersLotteryDraw() external onlyDeployer {
		dividendContract.referrersLotteryDraw();
	}

	function holdersLotteryDraw() external onlyDeployer {
		dividendContract.holdersLotteryDraw();
	}

	function setMinimumDividendBalanceToProcess(uint256 newValue) external onlyDeployer {
		require(newValue <= 10 ** 18, "Token: MinimumDividendBalanceToProcess must be between 0 and 1 BNB");
		emit MinimumDividendBalanceToProcess(newValue, _minDividendBalanceToProcess);
		_minDividendBalanceToProcess = newValue;
	}

	function updateGasForProcessing(uint256 newValue) external onlyDeployer {
		require(newValue >= 100000 && newValue <= 500000, "Token: gasForProcessing must be between 100,000 and 500,000");
		emit GasForProcessingUpdated(newValue, _gasForProcessing);
		_gasForProcessing = newValue;
	}

	function updateClaimWait(uint256 newValue) external onlyDeployer {
		dividendContract.updateClaimWait(newValue);
	}

	function setMinimumTokenBalanceForDividends(uint256 newValue) external onlyDeployer {
		dividendContract.updateMinimumTokenBalanceForDividends(newValue);
	}

	function setNumTokensToLiqudate(uint256 newValue) external onlyDeployer {
		require(newValue >= 100000000000000000000 && newValue <= 1000000000000000000000000, "Token: numTokensToLiqudate must be between 100 and 1.000.000");
		emit TokenBalanceToLiqudateUpdated(newValue, _numTokensToLiqudate);
		_numTokensToLiqudate = newValue;
	}

	function buyBack(uint256 amount, address recipient) external onlyDeployer {
		require(amount <= buyBackBalance, "Token: Insufficient funds.");
		require(recipient == BURN_ADDRESS || recipient == address(dividendContract), "Token: Invalid recipient.");
		swapETHForTokens(recipient, 0, amount);
		buyBackBalance = address(this).balance.sub(holdersLotteryFund).sub(referrersLotteryFund);
	}

	function setMilestone(uint256 milestone) external onlyDeployer {
		require(milestone > dividendContract.maxMilestone(), "Token: The new milestone cannot be smaller than the existing ones");
		dividendContract.setMilestone(milestone);
	}

	function setReferrerWallet(address wallet) external onlyDeployer {
		require(wallet != address(0), "Token: ReferrerLotteryWallet cannot be the zero address");
		referrerLotteryWallet = wallet;
		emit ReferrerLotteryWalletUpdate(wallet);
	}

	function processDividendTracker() external onlyDeployer {
		uint256 contractTokenBalance = _balances[address(this)];
		bool canSwap = contractTokenBalance > _numTokensToLiqudate;
		if (canSwap) {
			_swapping = true;
			swapAndSendDividends(_numTokensToLiqudate);
			_swapping = false;
		}
		if (address(dividendContract).balance > _minDividendBalanceToProcess) {
			uint256 gas = _gasForProcessing;
			try dividendContract.process(gas) returns (uint256 iterations, uint256 claims, uint256 lpIndex) {
				emit ProcessedDividendTracker(iterations, claims, lpIndex, true, gas, tx.origin);
			}
			catch {}
		}
	}

	function updateMinTokensForLottery() external onlyDeployer {
		address[] memory path = new address[](2);
		path[0] = address(busd);
		path[1] = pancakeSwapV2Router.WETH();
		uint256 ethPrice = pancakeSwapV2Router.getAmountsOut(10**20, path)[1];
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(this);
		uint256 amount = pancakeSwapV2Router.getAmountsOut(ethPrice, path)[1];
		dividendContract.updateMinTokensForLottery(amount);
	}

	function unlockVaultSlice(address to) external onlyDeployer {
		vault.unlockSlice(to);
	}

	function addPartner(address account) external onlyDeployer {
		require(_partners[account] == false, "Token: Account is a partner");
		_partners[account] = true;
		partners++;
		dividendContract.excludeFromLottery(account);
		emit NewPartner(account);
	}

	function excludeAddress(address account, bool fromLottery, bool fromDividends) external onlyDeployer {
		require(_isExcludedFromFees[account] == false, "Token: Account is already excluded");
		require(_excludedAccounts <= 15, "Token: The maximum limit of excluded accounts has been reached");
		_isExcludedFromFees[account] = true;
		_excludedAccounts++;
		if (fromLottery) {
			dividendContract.excludeFromLottery(account);
		}
		if (fromDividends) {
			dividendContract.excludeFromDividends(account);
		}
		emit ExcludeAddress(account, fromLottery, fromDividends);
	}

	function removeTax() external onlyDeployer {
		require(dividendContract.maxMilestone() == 0, "Token: milestone in progress");
		_totalFee = 0;
		uint256 toBurn = _balances[address(this)];
		_transfer(address(this), BURN_ADDRESS, toBurn);
		buyBackBalance = address(this).balance;
		holdersLotteryFund = 0;
		referrersLotteryFund = 0;
		dividendContract.burnTheHouseDown();
	}

	function _approve(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "Token: approve from the zero address");
		require(spender != address(0), "Token: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function swapETHForTokens(address recipient, uint256 minTokenAmount, uint256 amount) private {
		address[] memory path = new address[](2);
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(this);
		pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
			minTokenAmount,
			path,
			recipient,
			block.timestamp
		);
	}

	function swapTokensForEth(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = pancakeSwapV2Router.WETH();
		_approve(address(this), address(pancakeSwapV2Router), tokenAmount);
		pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0,
			path,
			address(this),
			block.timestamp
		);
	}

	function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }

	function swapAndSendDividends(uint256 amount) private {
		uint256 initialBalance = address(this).balance;
		cursor++;
		bool addLP = cursor.mod(10) < _lpWeight;
		uint256 swapTokensAmount = amount;
		if (addLP) {
			uint256 lpf = _buyBackFee.div(2);
			lpf = lpf.add(_lotteryFee).add(_dividendFee);
			swapTokensAmount = amount.div(_totalFee).mul(lpf);
		}
		swapTokensForEth(swapTokensAmount);
		uint256 eth = address(this).balance.sub(initialBalance);
		uint256 lotteriesEth = eth.div(_totalFee).mul(_lotteryFee);
		holdersLotteryFund = holdersLotteryFund.add(lotteriesEth.div(2));
		referrersLotteryFund = referrersLotteryFund.add(lotteriesEth.div(2));
		uint256 dividendEth = eth.div(_totalFee).mul(_dividendFee);
		(bool dividendContractTransfer,) = payable(address(dividendContract)).call{value: dividendEth, gas: 3000}('');
		require(dividendContractTransfer, "Token: Transfer to Dividend Contract faild");
		dividendContract.updateDividendsDistributed(dividendEth);
		if (addLP) {
			uint256  lpeth = eth.sub(lotteriesEth).sub(dividendEth);
			addLiquidity(amount.sub(swapTokensAmount), lpeth);
		}
		buyBackBalance = address(this).balance.sub(holdersLotteryFund).sub(referrersLotteryFund);
	}

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "Token: Transfer from the zero address");
		require(to != address(0), "Token: Transfer to the zero address");
		require(amount > 0, "Token: Transfer amount must be greater than zero");
		require(_swapEnabled || from == deployer, "Token: Public transfer has not yet been activated");
		require(_dividendContractSet, "Token: Dividend Contract Token is not set");

		bool takeFee = true;
        if (
			_isExcludedFromFees[from] ||
			_isExcludedFromFees[to] ||
			_totalFee == 0 ||
			(_partners[from] && to != address(pancakeSwapV2Pair)) ||
			(_partners[to] && from != address(pancakeSwapV2Pair))
		) {
            takeFee = false;
        }

		if (
			!_swapping &&
			takeFee
		) {
			uint256 contractTokenBalance = _balances[address(this)];
			bool canSwap = contractTokenBalance > _numTokensToLiqudate;
			if (
				!canSwap &&
				to == address(pancakeSwapV2Pair) &&
				buyBackBalance > 10**10 &&
				_bbperthousand > 0
			) {
				_swapping = true;
				swapETHForTokens(_bbrecipient, 0, buyBackBalance.div(1000).mul(_bbperthousand));
				_swapping = false;
			} else {
				if (
					canSwap &&
					from != address(pancakeSwapV2Pair)
				) {
					_swapping = true;
					swapAndSendDividends(_numTokensToLiqudate);
					_swapping = false;
            	}
			}
        }

        if (takeFee) {
        	uint256 txFee = amount.div(100).mul(_totalFee);
			amount = amount.sub(txFee);
			_balances[from] = _balances[from].sub(txFee, "Token: Transfer amount exceeds balance");
			_balances[address(this)] = _balances[address(this)].add(txFee);
			emit Transfer(from, address(this), txFee);
        }

		_balances[from] = _balances[from].sub(amount, "Token: Transfer amount exceeds balance");
		_balances[to] = _balances[to].add(amount);
		emit Transfer(from, to, amount);

		if (_totalFee > 0) {
			dividendContract.setBalance(payable(from), _balances[from]);
			dividendContract.setBalance(payable(to), _balances[to]);
			if (
				!_swapping &&
				(from != address(dividendContract)) &&
				address(dividendContract).balance > _minDividendBalanceToProcess
			) {
				uint256 gas = _gasForProcessing;
				try dividendContract.process(gas) returns (uint256 iterations, uint256 claims, uint256 lpIndex) {
					emit ProcessedDividendTracker(iterations, claims, lpIndex, true, gas, tx.origin);
				}
				catch {}
			}
		}
	}

	function setDividendTrackerContract(address _dividendTracker) external onlyOwner {
		dividendContract = DividendTracker(payable(_dividendTracker));
		_dividendContractSet = true;
		_isExcludedFromFees[address(dividendContract)] = true;
		_excludedAccounts++;
		_transfer(_msgSender(), _dividendTracker, _totalSupply.div(100).mul(20));
	}

	function setVaultContract(address _vault) external onlyOwner {
		require(_dividendContractSet, "Token: DividendContract contract is not set");
		vault = AdoVault(_vault);
		_vaultContractSet = true;
		_isExcludedFromFees[_vault] = true;
		_excludedAccounts++;
		dividendContract.excludeFromDividends(_vault);
		_transfer(_msgSender(), _vault, _totalSupply.div(100).mul(20));
	}

	function setBUSDContract(address _busd) external onlyOwner {
		require(!_busdContractSet, "Token: BUSD Token is already set");
		busd = _busd;
		_busdContractSet = true;
	}

	function createPancakeSwapPair(address PancakeSwapRouter) external onlyOwner {
		require(_dividendContractSet, "Token: Dividend Contract contract is not set");
		require(_vaultContractSet, "Token: Vault contract is not set");
		require(_busdContractSet, "Token: BUSD Token Contract contract is not set");
		pancakeSwapV2Router = IPancakeSwapV2Router02(PancakeSwapRouter);
		pancakeSwapV2Pair = IPancakeSwapV2Pair(IPancakeSwapV2Factory(pancakeSwapV2Router
			.factory())
			.createPair(address(this), pancakeSwapV2Router.WETH()));
		dividendContract.excludeFromDividends(address(pancakeSwapV2Pair));
		dividendContract.excludeFromDividends(address(pancakeSwapV2Router));
	}

	function enableSwap() external onlyOwner {
		require(!_swapEnabled, "Token: PublicSwap is already enabeled");
		_swapEnabled = true;
	}

	function swapETHForExactTokens(uint256 amountOut, address referrer) external payable {
		address[] memory path = new address[](2);
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(this);
		pancakeSwapV2Router.swapETHForExactTokens {value: msg.value}(amountOut, path, _msgSender(), block.timestamp);
		uint256 ethBack = address(this).balance
			.sub(holdersLotteryFund)
			.sub(referrersLotteryFund)
			.sub(buyBackBalance);
		(bool refund,) = _msgSender().call{value: ethBack, gas: 3000}('');
		require(refund, "Token: Refund Failed");
		if (referrer != address(0) && _totalFee > 0) {
			uint256 txFee = amountOut.div(100).mul(_totalFee);
			uint256 amount = amountOut.sub(txFee);
			dividendContract.payCommission(referrer, amount);
		}
	}

	function swapExactETHForTokens(uint256 amountOutMin, address referrer) external payable {
		address[] memory path = new address[](2);
		path[0] = pancakeSwapV2Router.WETH();
		path[1] = address(this);
		uint256 initialBalance = _balances[_msgSender()];
		pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, _msgSender(), block.timestamp);
		uint256 amountOut = _balances[_msgSender()].sub(initialBalance);
		if (referrer != address(0) && _totalFee > 0) {
			dividendContract.payCommission(referrer, amountOut);
		}
	}

	function payTheWinner(address winner) external returns (bool) {
		require(_msgSender() == address(dividendContract), "Token: Only the Dividend contract can call this function");
		(bool success,) = payable(winner).call{value: holdersLotteryFund, gas: 3000}('');
		require(success, "Token: Transfer to lottery winner faild");
		holdersLotteryFund = 0;
		return success;
	}

	function referrersLotteryFundWithdrawal() external returns (bool) {
		require(_msgSender() == address(dividendContract), "Token: Only the Dividend contract can call this function");
		(bool success,) = payable(referrerLotteryWallet).call{value: referrersLotteryFund, gas: 3000}('');
		require(success, "Token: Transfer to Referrer Lottery Wallet faild");
		referrersLotteryFund = 0;
		return success;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
	int256 private constant MIN_INT256 = int256(1) << 255;
	int256 private constant MAX_INT256 = ~(int256(1) << 255);

	/**
	 * @dev Multiplies two int256 variables and fails on overflow.
	 */
	function mul(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a * b;
		// Detect overflow when multiplying MIN_INT256 with -1
		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}

	/**
	 * @dev Division of two int256 variables and fails on overflow.
	 */
	function div(int256 a, int256 b) internal pure returns (int256) {
		// Prevent overflow when dividing MIN_INT256 by -1
		require(b != -1 || a != MIN_INT256);
		// Solidity already throws when dividing by 0.
		return a / b;
	}

	/**
	 * @dev Subtracts two int256 variables and fails on overflow.
	 */
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));
		return c;
	}

	/**
	 * @dev Adds two int256 variables and fails on overflow.
	 */
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));
		return c;
	}

	/**
	 * @dev Converts to absolute value, and fails on overflow.
	 */
	function abs(int256 a) internal pure returns (int256) {
		require(a != MIN_INT256);
		return a < 0 ? -a : a;
	}

	function toUint256Safe(int256 a) internal pure returns (uint256) {
		require(a >= 0);
		return uint256(a);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
	function toInt256Safe(uint256 a) internal pure returns (int256) {
		int256 b = int256(a);
		require(b >= 0);
		return b;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * CAUTION
 * This version of SafeMath should only be used with Solidity 0.8 or later,
 * because it relies on the compiler's built in overflow checks.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			uint256 c = a + b;
			if (c < a) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the substraction of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b > a) return (false, 0);
			return (true, a - b);
		}
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) return (true, 0);
			uint256 c = a * b;
			if (c / a != b) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the division of two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a / b);
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a % b);
		}
	}

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
		return a + b;
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
		return a - b;
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
		return a * b;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator.
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting when dividing by zero.
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
		return a % b;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {trySub}.
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		unchecked {
			require(b <= a, errorMessage);
			return a - b;
		}
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
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
		unchecked {
			require(b > 0, errorMessage);
			return a / b;
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting with custom message when dividing by zero.
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {tryMod}.
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
		unchecked {
			require(b > 0, errorMessage);
			return a % b;
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./IPancakeSwapV2Router01.sol";
interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface IPancakeSwapV2Factory {
	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);
	function createPair(address tokenA, address tokenB) external returns (address pair);
	function setFeeTo(address) external;
	function setFeeToSetter(address) external;

	event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface IPancakeSwapV2Pair {
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

	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);
	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
	event Sync(uint112 reserve0, uint112 reserve1);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.4;
import "./Context.sol";
abstract contract Ownable is Context {
	address private _owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./abstracts/Context.sol";
import "./libraries/SafeMath.sol";
import "./AdoToken.sol";
import "./DividendTracker.sol";

contract AdoVault is Context {
	using SafeMath for uint256;
	AdoToken public tokenContract;
	DividendTracker public dividendContract;
	uint256 public immutable slice;
	uint256 public pendingMilestone;

	event VaultWithdraw(address indexed to, uint256 indexed slice, uint256 indexed milestone);

	modifier onlyTokenContract() {
		require(_msgSender() == address(tokenContract), "Vault: Only the token contract can call this function");
		_;
	}

	constructor(AdoToken _tokenContract, DividendTracker _dividendContract) {
		tokenContract = _tokenContract;
		dividendContract = _dividendContract;
		slice = tokenContract.totalSupply().div(20);
		pendingMilestone = dividendContract.MILESTONE4();
	}

	function unlockSlice(address to) external onlyTokenContract {
		require(to != address(0), "Vault: transfer to the zero address");
		require(tokenContract.balanceOf(address(this)) >= slice, "Vault: insufficient funds");
		require(dividendContract.lastMilestoneReached() >= pendingMilestone, "Vault: no eligible milestone has been reached");

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE4() && pendingMilestone == dividendContract.MILESTONE4()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE5();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE4());
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE5() && pendingMilestone == dividendContract.MILESTONE5()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE6();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE5());
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE6() && pendingMilestone == dividendContract.MILESTONE6()) {
			tokenContract.transfer(to, slice);
			pendingMilestone = dividendContract.MILESTONE7();
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE6());
		}

		if (dividendContract.lastMilestoneReached() >= dividendContract.MILESTONE7() && pendingMilestone == dividendContract.MILESTONE7()) {
			tokenContract.transfer(to, tokenContract.balanceOf(address(this)));
			pendingMilestone = 0;
			emit VaultWithdraw(to, slice, dividendContract.MILESTONE7());
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
interface IPancakeSwapV2Router01 {
	function factory() external view returns (address);
	function WETH() external view returns (address);
	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
	function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}