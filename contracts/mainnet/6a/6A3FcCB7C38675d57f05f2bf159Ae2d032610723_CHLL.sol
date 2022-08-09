/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface Callable {
	function tokenCallback(address _from, uint256 _tokens, bytes calldata _data) external returns (bool);
}

interface BUSD {
	function balanceOf(address) external view returns (uint256);
	function allowance(address, address) external view returns (uint256);
	function transfer(address, uint256) external returns (bool);
	function transferFrom(address, address, uint256) external returns (bool);
}

contract CHLL {
	uint256 constant private BIG_NUMBER = 2**64;
	uint256 constant private STAKE_FEE = 10;
	uint256 constant private UNSTAKE_FEE = 10;
	uint256 constant private RESTAKE_FEE = 5;
  uint256 constant private REFERRAL_COMMISSION = 30; 
	uint256 constant private STARTING_PRICE = 0.00001 ether;
	uint256 constant private INCREMENT = 1e14;

	string constant public name = "CHLL";
	string constant public symbol = "CHLL";
	uint8 constant public decimals = 18;

  

	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
		int256 scaledPayout;
    uint256 restakedAmount;
    uint256 withdrawnAmount;
    address referrer;
    uint256 referralEarnings;
    uint256 referralEarned;
    bool hasReferrer;
	}

	struct Info {
		uint256 totalSupply;
    uint256 totalRewards;
		mapping(address => User) users;
		uint256 scaledBUSDPerToken;
		BUSD busd;
	}
	
	Info private info;

	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	event Stake(address indexed staker, uint256 amountSpent, uint256 tokensReceived);
	event Unstake(address indexed unstaker, uint256 tokensSpent, uint256 amountReceived);
	event Withdraw(address indexed user, uint256 amount);
	event Restake(address indexed user, uint256 amountSpent, uint256 tokensReceived);

	constructor(address _BUSD_address) {
		info.busd = BUSD(_BUSD_address);
	}

	function stake(uint256 _amount, address _referrer) external returns (uint256) {
		require(_amount > 0);
		require(info.busd.transferFrom(msg.sender, address(this), _amount));
		return _stake(_amount, _referrer);
	}

	function unstake(uint256 _tokens) external returns (uint256) {
		require(balanceOf(msg.sender) >= _tokens);
		return _unstake(_tokens);
	}

	function withdraw() external returns (uint256) {
		uint256 _rewards = rewardsOf(msg.sender);
		require(_rewards > 0);
    info.users[msg.sender].withdrawnAmount += uint256(_rewards);
    info.users[msg.sender].referralEarned += info.users[msg.sender].referralEarnings;
    info.users[msg.sender].referralEarnings = 0;
    info.users[msg.sender].scaledPayout += int256(_rewards * BIG_NUMBER);
		info.busd.transfer(msg.sender, _rewards);
		emit Withdraw(msg.sender, _rewards);
		return _rewards;
	}

	function restake() external returns (uint256) {
		uint256 _rewards = rewardsOf(msg.sender);
		require(_rewards > 0);
    info.users[msg.sender].referralEarned += info.users[msg.sender].referralEarnings;
    info.users[msg.sender].referralEarnings = 0;
		info.users[msg.sender].scaledPayout += int256(_rewards * BIG_NUMBER);
		return _restake(_rewards);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {
		return _transfer(msg.sender, _to, _tokens);
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		return _transfer(_from, _to, _tokens);
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _tokens, _data));
		}
		return true;
	}

	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

  function totalRewardsEarned() public view returns (uint256) {
		return info.totalRewards;
	}

	function currentPrices() public view returns (uint256 truePrice, uint256 mintPrice, uint256 burnValue) {
		truePrice = STARTING_PRICE + INCREMENT * totalSupply() / 1e18;
		mintPrice = truePrice * 100 / (100 - STAKE_FEE);
		burnValue = truePrice * (100 - UNSTAKE_FEE) / 100;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance;
	}

	function rewardsOf(address _user) public view returns (uint256) {
		return uint256(info.users[_user].referralEarnings) + (uint256(int256(info.scaledBUSDPerToken * balanceOf(_user)) - info.users[_user].scaledPayout) / BIG_NUMBER);
	}

	function withdrawnRewardsOf(address _user) public view returns (uint256) {
		return uint256(info.users[_user].restakedAmount) + uint256(info.users[_user].withdrawnAmount);
	}

	function allInfoFor(address _user) public view returns (uint256 contractBalance, uint256 totalTokenSupply, uint256 truePrice, uint256 mintPrice, uint256 burnValue, uint256 userBUSD, uint256 userAllowance, uint256 userBalance, uint256 userRewards,uint256 userRewardsEarned, uint256 userLiquidValue) {
		contractBalance = info.busd.balanceOf(address(this));
		totalTokenSupply = totalSupply();
		(truePrice, mintPrice, burnValue) = currentPrices();
		userBUSD = info.busd.balanceOf(_user);
		userAllowance = info.busd.allowance(_user, address(this));
		userBalance = balanceOf(_user);
		userRewards = rewardsOf(_user);
		userLiquidValue = calculateResult(userBalance, false) + userRewards;
		userRewardsEarned = withdrawnRewardsOf(_user) + userRewards;
	}

  function allRewardsInfoFor(address _user) public view returns (uint256 userRewards,uint256 userRewardsEarned, uint256 userReferralEarnings, uint256 userReferralEarned) {
		userRewards = rewardsOf(_user);
		userReferralEarnings = uint256(info.users[_user].referralEarnings);
    userReferralEarned = uint256(info.users[_user].referralEarned) + userReferralEarnings;
		userRewardsEarned = withdrawnRewardsOf(_user) + userRewards;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function calculateResult(uint256 _amount, bool _staking) public view returns (uint256) {
		uint256 _mintPrice;
		uint256 _burnValue;
		( , _mintPrice, _burnValue) = currentPrices();
		uint256 _rate = (_staking ? _mintPrice : _burnValue);
		uint256 _increment = INCREMENT * (_staking ? 100 : (100 - UNSTAKE_FEE)) / (_staking ? (100 - STAKE_FEE) : 100);
		if (_staking) {
				return (_sqrt((_increment + 2 * _rate) * (_increment + 2 * _rate) + 8 * _amount * _increment) - _increment - 2 * _rate) * 1e18 / (2 * _increment);
		} else {
				return (_rate * _amount - (_increment * (_amount + 1e18) / 2e18) * _amount) / 1e18;
		}
	}

	function _transfer(address _from, address _to, uint256 _tokens) internal returns (bool) {
		require(info.users[_from].balance >= _tokens);
		info.users[_from].balance -= _tokens;
		info.users[_from].scaledPayout -= int256(_tokens * info.scaledBUSDPerToken);
		info.users[_to].balance += _tokens;
		info.users[_to].scaledPayout += int256(_tokens * info.scaledBUSDPerToken);
		emit Transfer(_from, _to, _tokens);
		return true;
	}

	function _stake(uint256 _amount, address _referrer) internal returns (uint256 tokens) {
		uint256 _tax = _amount * STAKE_FEE / 100;
    info.totalRewards += _tax;
		tokens = calculateResult(_amount, true);
    address _referrerAddress = info.users[msg.sender].hasReferrer ? (info.users[msg.sender].referrer) : (_referrer);
    info.users[msg.sender].referrer = _referrerAddress;
    info.users[msg.sender].hasReferrer = true;
    uint256 _taxAfterReferral = uint256(_tax - (_tax / (100 / REFERRAL_COMMISSION)));
    info.users[_referrerAddress].referralEarnings += uint256(_tax / (100 / REFERRAL_COMMISSION));
		info.totalSupply += tokens;
		info.users[msg.sender].balance += tokens;
		info.users[msg.sender].scaledPayout += int256(tokens * info.scaledBUSDPerToken);
		info.scaledBUSDPerToken += _taxAfterReferral * BIG_NUMBER / info.totalSupply;
		emit Transfer(address(0x0), msg.sender, tokens);
		emit Stake(msg.sender, _amount, tokens);
	}

	function _restake(uint256 _amount) internal returns (uint256 tokens) {
		uint256 _tax = _amount * RESTAKE_FEE / 100;
    info.users[msg.sender].restakedAmount += uint256(_amount);
    info.totalRewards += _tax;
		tokens = calculateResult(_amount, true);
    uint256 _taxAfterReferral = uint256(_tax - (_tax / (100 / REFERRAL_COMMISSION)));
    info.users[info.users[msg.sender].referrer].referralEarnings += uint256(_tax / (100 / REFERRAL_COMMISSION));
		info.totalSupply += tokens;
		info.users[msg.sender].balance += tokens;
		info.users[msg.sender].scaledPayout += int256(tokens * info.scaledBUSDPerToken);
		info.scaledBUSDPerToken += _taxAfterReferral * BIG_NUMBER / info.totalSupply;
		emit Transfer(address(0x0), msg.sender, tokens);
		emit Restake(msg.sender, _amount, tokens);
	}

	function _unstake(uint256 _tokens) internal returns (uint256 amount) {
		require(info.users[msg.sender].balance >= _tokens);
		amount = calculateResult(_tokens, false);
		uint256 _tax = amount * UNSTAKE_FEE / (100 - UNSTAKE_FEE);
    uint256 _taxAfterReferral = uint256(_tax - (_tax / (100 / REFERRAL_COMMISSION)));
    info.users[info.users[msg.sender].referrer].referralEarnings += uint256(_tax / (100 / REFERRAL_COMMISSION));
    info.totalRewards += _tax;
		info.totalSupply -= _tokens;
		info.users[msg.sender].balance -= _tokens;
		info.users[msg.sender].scaledPayout -= int256(_tokens * info.scaledBUSDPerToken);
		info.scaledBUSDPerToken += _taxAfterReferral * BIG_NUMBER / info.totalSupply;
		info.busd.transfer(msg.sender, amount);
		emit Transfer(msg.sender, address(0x0), _tokens);
		emit Unstake(msg.sender, _tokens, amount);
	}

	function _sqrt(uint256 _n) internal pure returns (uint256 result) {
		uint256 _tmp = (_n + 1) / 2;
		result = _n;
		while (_tmp < result) {
			result = _tmp;
			_tmp = (_n / _tmp + _tmp) / 2;
		}
	}
}