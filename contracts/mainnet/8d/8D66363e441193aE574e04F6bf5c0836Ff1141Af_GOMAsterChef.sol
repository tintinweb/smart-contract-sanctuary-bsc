/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/** 

      /$$$$$$   /$$$$$$  /$$      /$$  /$$$$$$              /$$                          /$$$$$$  /$$                  /$$$$$$ 
     /$$__  $$ /$$__  $$| $$$    /$$$ /$$__  $$            | $$                         /$$__  $$| $$                 /$$__  $$
    | $$  \__/| $$  \ $$| $$$$  /$$$$| $$  \ $$  /$$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$ | $$  \__/| $$$$$$$   /$$$$$$ | $$  \__/
    | $$ /$$$$| $$  | $$| $$ $$/$$ $$| $$$$$$$$ /$$_____/|_  $$_/   /$$__  $$ /$$__  $$| $$      | $$__  $$ /$$__  $$| $$$$    
    | $$|_  $$| $$  | $$| $$  $$$| $$| $$__  $$|  $$$$$$   | $$    | $$$$$$$$| $$  \__/| $$      | $$  \ $$| $$$$$$$$| $$_/    
    | $$  \ $$| $$  | $$| $$\  $ | $$| $$  | $$ \____  $$  | $$ /$$| $$_____/| $$      | $$    $$| $$  | $$| $$_____/| $$      
    |  $$$$$$/|  $$$$$$/| $$ \/  | $$| $$  | $$ /$$$$$$$/  |  $$$$/|  $$$$$$$| $$      |  $$$$$$/| $$  | $$|  $$$$$$$| $$      
     \______/  \______/ |__/     |__/|__/  |__/|_______/    \___/   \_______/|__/       \______/ |__/  |__/ \_______/|__/     
     
     
                                             ___________________ __________.___.___ 
                                            \__    ___/\_____  \\______   \   |   |
                                              |    |    /   |   \|       _/   |   |
                                              |    |   /    |    \    |   \   |   |
                                              |____|   \_______  /____|_  /___|___|
                                                               \/       \/    
                                                               
                                                               
                                                  *****************************
                                                        
                                                        
                                                    GOMAsterChef for TORII v3
                                                     
     
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		return msg.data;
	}
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor() {
		_setOwner(_msgSender());
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view virtual returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
		_setOwner(address(0));
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_setOwner(newOwner);
	}

	function _setOwner(address newOwner) private {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

abstract contract Operable is Ownable {
	mapping(address => bool) public operators;
	address[] public operatorsList;

	constructor() {
		setOperator(_msgSender(), true);
	}

	function setOperator(address operator, bool state) public onlyOwner {
		operators[operator] = state;
		if (state) {
			operatorsList.push(operator);
		}
		emit OperatorSet(operator, state);
	}

	function operatorsCount() public view returns (uint256) {
		return operatorsList.length;
	}

	modifier onlyOperator() {
		require(operators[_msgSender()] || _msgSender() == owner(), "Sender is not the operator or owner");
		_;
	}
	event OperatorSet(address operator, bool state);
}

interface IBEP20 {
	function totalSupply() external view returns (uint256);

	function decimals() external view returns (uint8);

	function symbol() external view returns (string memory);

	function name() external view returns (string memory);

	function getOwner() external view returns (address);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address _owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
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
		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

	function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint256 value,
		string memory errorMessage
	) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		require(isContract(target), "Address: call to non-contract");
		(bool success, bytes memory returndata) = target.call{ value: value }(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
		return functionStaticCall(target, data, "Address: low-level static call failed");
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

	function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
		return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

library SafeBEP20 {
	using Address for address;

	function safeTransfer(
		IBEP20 token,
		address to,
		uint256 value
	) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

	function safeTransferFrom(
		IBEP20 token,
		address from,
		address to,
		uint256 value
	) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
	}

	/**
	 * @dev Deprecated. This function has issues similar to the ones found in
	 * {IBEP20-approve}, and its usage is discouraged.
	 *
	 * Whenever possible, use {safeIncreaseAllowance} and
	 * {safeDecreaseAllowance} instead.
	 */
	function safeApprove(
		IBEP20 token,
		address spender,
		uint256 value
	) internal {
		// safeApprove should only be called when setting an initial allowance,
		// or when resetting it to zero. To increase and decrease it, use
		// 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
		require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeBEP20: approve from non-zero to non-zero allowance");
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}

	function safeIncreaseAllowance(
		IBEP20 token,
		address spender,
		uint256 value
	) internal {
		uint256 newAllowance = token.allowance(address(this), spender) + value;
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
	}

	function safeDecreaseAllowance(
		IBEP20 token,
		address spender,
		uint256 value
	) internal {
		unchecked {
			uint256 oldAllowance = token.allowance(address(this), spender);
			require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
	function _callOptionalReturn(IBEP20 token, bytes memory data) private {
		// We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
		// we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
		// the target address contains contract code and also asserts for success in the low-level call.

		bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
		if (returndata.length > 0) {
			// Return data is optional
			require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
		}
	}
}

contract GOMAsterChef is Operable {
	using SafeBEP20 for IBEP20;

	struct UserInfo {
		uint256 amount;
		uint256 rewardDebt;
	}

	uint256 public lastRewardTimestamp;
	uint256 public accRewardTokensPerShare;
	uint256 public claimedRewardTokens;

	IBEP20 public rewardToken;
	IBEP20 public immutable stakedToken;
	uint256 public stakedTokenDeposied;
	
	uint256 public tokensPerSecond;
	uint256 public minDepositAmount;

	uint256 private immutable taxPercent;

	mapping(address => UserInfo) public userInfo;
	address[] public users;

	uint256 public startTimestamp;
	uint256 public pausedTimestamp;
	bool public productionMode = false;

	event Deposit(address indexed user, uint256 amount);
	event Withdraw(address indexed user, uint256 amount);
	event Claim(address indexed user, uint256 amount);
	event EmergencyWithdraw(address indexed user, uint256 amount);
	event Supply(address indexed user, uint256 amount);

	modifier onlyStarted() {
		require(startTimestamp <= blockTimestamp(), "GOMAsterChef: not started");
		_;
	}

	constructor() {
		stakedToken = IBEP20(0x9EC55d57208cb28a7714A2eA3468bD9d5bB15125); // GOMA
		rewardToken = IBEP20(0xD9979e2479AEa29751D31AE512a61297B98Fbbf4); // TORII
				
		tokensPerSecond = 2500000000000000;

		taxPercent = 800; // 8%
		minDepositAmount = 1000000000 * 10**9; // 1000000000000000000
	}

	function getData()
		public
		view
		returns (
			uint256 _stakedTokenDeposied, 
			uint256 _tokensPerSecond,
			uint256 _minDepositAmount,
			uint256 _startTimestamp,
			uint256 _pausedTimestamp
		)
	{
    _stakedTokenDeposied = stakedTokenDeposied;
    _tokensPerSecond = tokensPerSecond;
    _minDepositAmount = minDepositAmount;
    _startTimestamp = startTimestamp;
    _pausedTimestamp = pausedTimestamp;    
	}

	function getUserData(address account)
		public
		view
		returns (
			uint256 _pendingRewards, 
			uint256 _depositedAmount,
			uint256 _balanceStakeTokens,
			uint256 _allowanceStakeTokens,
			uint256 _balanceRewardTokens
		)
	{
    _pendingRewards = pendingRewardsOfUser(account);
    _depositedAmount = userInfo[account].amount;
    _balanceStakeTokens = stakedToken.balanceOf(account);
    _allowanceStakeTokens = stakedToken.allowance(account, address(this));
    _balanceRewardTokens = rewardToken.balanceOf(account);
	}

	function setRewardTokensPerSecond(uint256 _tokensPerSecond) external onlyOwner onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef setTokensPerSecond: you can't set while paused!");		
		_updatePool();
		tokensPerSecond = _tokensPerSecond;
	}

	function setMinDepositAmount(uint256 _minDepositAmount) external onlyOwner {
		require(_minDepositAmount != 0, "GOMAsterChef setMinDepositAmount: 0!");
		minDepositAmount = _minDepositAmount;
	}

	function pauseOn() external onlyOwner onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef pause: already paused!");
		pausedTimestamp = blockTimestamp();
	}

	function pauseOff() external onlyOwner onlyStarted {
		require(pausedTimestamp != 0, "GOMAsterChef resume: not paused!");
		_updatePool();
		pausedTimestamp = 0;
	}

	function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
		_from = _from > startTimestamp ? _from : startTimestamp;
		if (_to < startTimestamp) {
			return 0;
		}

		if (pausedTimestamp != 0) {
			return _to - (_from + blockTimestamp() - pausedTimestamp);
		} else {
			return _to - _from;
		}
	}

	function getMultiplierNow() public view returns (uint256) {
		return getMultiplier(lastRewardTimestamp, blockTimestamp());
	}

	function pendingRewardsOfSender() public view returns (uint256) {
		return pendingRewardsOfUser(msg.sender);
	}

	function pendingRewardsOfUser(address _user) public view returns (uint256 amount) {
		UserInfo storage user = userInfo[_user];
		uint256 _accRewardTokensPerShare = accRewardTokensPerShare;

		if (stakedTokenDeposied != 0 && user.amount != 0 && blockTimestamp() > lastRewardTimestamp) {
			_accRewardTokensPerShare = accRewardTokensPerShare + (((getMultiplierNow() * tokensPerSecond) * 1e12) / stakedTokenDeposied);
		}

		uint256 pending = (user.amount * _accRewardTokensPerShare) / 1e12;
		if (pending > user.rewardDebt) {
			amount = pending - user.rewardDebt;
		} else {
			amount = 0;
		}		
	}

	function getPending(UserInfo storage user) internal view returns (uint256) {
		uint256 pending = ((user.amount * accRewardTokensPerShare) / 1e12);
		if (pending > user.rewardDebt) {
			return pending - user.rewardDebt;
		} else {
			return 0;
		}
	}
	
	function updatePool() public onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef updatePool: you can't update while paused!");
		_updatePool();
	}

	function _updatePool() internal {
		if (blockTimestamp() <= lastRewardTimestamp) {
			return;
		}

		if (stakedTokenDeposied == 0) {
			lastRewardTimestamp = blockTimestamp();
			return;
		}

		accRewardTokensPerShare = accRewardTokensPerShare + (((getMultiplierNow() * tokensPerSecond) * 1e12) / stakedTokenDeposied);
		lastRewardTimestamp = blockTimestamp();
	}

	function deposit(uint256 _amount) public onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef deposit: you can't deposit while paused!");
		require(_amount >= minDepositAmount, "GOMAsterChef deposit: you can't deposit less than minDepositAmount of wei!");

		UserInfo storage user = userInfo[msg.sender];

		_updatePool();

		if (stakedTokenDeposied != 0) {
			uint256 pending = getPending(user);
			if (pending != 0) {
				claimedRewardTokens += pending;
				safeRewardTransfer(msg.sender, pending);
			}
		}
		
		stakedTokenDeposied += _amount;

		if (user.amount == 0 && user.rewardDebt == 0) {
			users.push(msg.sender);
		}

		user.amount += _amount;
		user.rewardDebt = (user.amount * accRewardTokensPerShare) / 1e12;

		stakedToken.safeTransferFrom(msg.sender, address(this), _amount);
		emit Deposit(msg.sender, _amount);
	}

	function start() external onlyOperator {
		require(startTimestamp == 0, "GOMAsterChef start: already started");
		startTimestamp = blockTimestamp();
		lastRewardTimestamp = blockTimestamp();
	}

  function usersCount() public view returns (uint256) {
		return users.length;
	}

  struct UserExport {
		uint256 amount;
		uint256 rewards;
	}

  function getUsersExport(uint256 _startIndex, uint256 _endIndex) public view returns (UserExport[] memory userExport) {
    userExport = new UserExport[](_endIndex - _startIndex);
		
    for (uint256 i = _startIndex; i < _endIndex; i++) {
      address user = users[i];
      userExport[i] = UserExport(userInfo[user].amount, pendingRewardsOfUser(user));
		}    
	}

	function migrateUsers(address[] memory _users, uint256[] memory _amounts) external onlyOperator {
		uint8 cnt = uint8(_users.length);
		require(cnt != 0, "GOMAsterChef migrateUsers: number or recipients must be more then 0 and not much than 255");
		require(_users.length == _amounts.length, "GOMAsterChef migrateUsers: number or recipients must be equal to number of amounts");
		for (uint256 i = 0; i < cnt; i++) {
			userInfo[_users[i]].amount = userInfo[_users[i]].amount + _amounts[i];
			stakedTokenDeposied = stakedTokenDeposied + _amounts[i];
		}
	}

	// Withdraw staked tokens
	function withdraw(uint256 _amount) public onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef withdraw: you can't withdraw while paused!");
		require(_amount != 0, "GOMAsterChef withdraw: you can't withdraw 0!");

		UserInfo storage user = userInfo[msg.sender];
		require(user.amount >= _amount, "GOMAsterChef withdraw: not enough funds");

		_updatePool();

		uint256 pending = getPending(user);
		if (pending != 0) {
			claimedRewardTokens += pending;
			safeRewardTransfer(msg.sender, pending);
		}

		uint256 finalAmount = _amount;

		if ((user.amount - _amount) < minDepositAmount) {
			finalAmount = user.amount;
			user.amount = 0;
			user.rewardDebt = 0;
		} else {
			user.amount -= _amount;
			user.rewardDebt = (user.amount * accRewardTokensPerShare) / 1e12;
		}

		stakedTokenDeposied -= finalAmount;

		stakedToken.safeTransfer(msg.sender, finalAmount);
		emit Withdraw(msg.sender, finalAmount);
	}

	// Withdraw reward tokens
	function claim() public onlyStarted {
		require(pausedTimestamp == 0, "GOMAsterChef claim: you can't claim while paused!");

		UserInfo storage user = userInfo[msg.sender];
		require(user.amount != 0, "GOMAsterChef claim: user deposited 0");

		_updatePool();

		uint256 pending = getPending(user);
		require(pending != 0, "GOMAsterChef claim: nothing to claim");

		user.rewardDebt = (user.amount * accRewardTokensPerShare) / 1e12;

		claimedRewardTokens += pending;
		safeRewardTransfer(msg.sender, pending);
		emit Claim(msg.sender, pending);
	}

	// Withdraw without caring about rewards. EMERGENCY ONLY.
	function withdrawEmergency() public onlyStarted {
		UserInfo storage user = userInfo[msg.sender];

		uint256 userAmount = user.amount;
		require(userAmount != 0, "GOMAsterChef emergencyWithdraw: nothing to withdraw");

		user.amount = 0;
		user.rewardDebt = 0;

		stakedToken.safeTransfer(msg.sender, userAmount);

		stakedTokenDeposied -= userAmount;

		emit EmergencyWithdraw(msg.sender, userAmount);
	}

	// Safe rewardToken transfer function.
	function safeRewardTransfer(address _to, uint256 _amount) internal {
		uint256 tokenBal = balanceOfRewardToken();
		if (_amount > tokenBal) {
			rewardToken.transfer(_to, tokenBal);
		} else {
			rewardToken.transfer(_to, _amount);
		}
	}

	function supplyRewardTokens(uint256 _amount) public {
		rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
		emit Supply(msg.sender, _amount);
	}

	function supplyStakedTokens(uint256 _amount) public {
		stakedToken.safeTransferFrom(msg.sender, address(this), _amount);
		emit Supply(msg.sender, _amount);
	}

	function startProductionMode() external onlyOwner onlyStarted {
		require(productionMode == false, "startProductionMode: already stared");
		productionMode = true;
		_updatePool();
		pausedTimestamp = 0;
	}

	function setRewardToken(address newRewardToken) external onlyOperator {
		require(pausedTimestamp != 0, "GOMAsterChef setRewardToken: you can't change reward token when not paused");
		rewardToken = IBEP20(newRewardToken);
	}

	function withdrawStakedTokens(uint256 _amount) external onlyOperator {
		require(productionMode == false, "GOMAsterChef withdrawAllStakedTokens: not allowed in production mode");
		require(balanceOfStakedToken() != 0, "GOMAsterChef withdrawAllStakedTokens: nothing to withdraw");
		require(balanceOfStakedToken() >= _amount, "GOMAsterChef withdrawAllStakedTokens: no enough funds");
		stakedToken.safeTransfer(msg.sender, _amount);
	}

	function withdrawStakedRewards(uint256 _amount) external onlyOperator {
		require(balanceOfStakedToken() > stakedTokenDeposied, "GOMAsterChef withdrawStakedRewards: nothing to withdraw");
		uint256 amount = balanceOfStakedToken() - stakedTokenDeposied;
		require(_amount <= amount, "GOMAsterChef withdrawStakedRewards: no enough funds");
		stakedToken.safeTransfer(msg.sender, _amount);
	}

	function recoverTokens(address token, uint256 amount) external onlyOperator {
		require(token != address(stakedToken), "GOMAsterChef recoverTokens: can't recover staked token");
		require(token != address(rewardToken), "GOMAsterChef recoverTokens: can't recover reward token");
		IBEP20(token).safeTransfer(msg.sender, amount);
	}

	function withdrawRewardTokens(uint256 _amount) external onlyOperator {
		require(balanceOfRewardToken() >= _amount, "GOMAsterChef withdrawRewardTokens: nothing to withdraw");
		safeRewardTransfer(msg.sender, _amount);
	}

	function balanceOfRewardToken() public view returns (uint256) {
		return rewardToken.balanceOf(address(this));
	}

	function balanceOfStakedToken() public view returns (uint256) {
		return stakedToken.balanceOf(address(this));
	}

	function blockTimestamp() public view returns (uint256) {
		return block.timestamp;
	}
}