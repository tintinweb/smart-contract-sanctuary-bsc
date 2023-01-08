/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

pragma solidity ^0.5.17;

interface Callable {
	function tokenCallback(address _sender, uint256 _amountTokens, bytes calldata _data) external returns (bool);
}

// OFFICIAL GYPSUM SMART CONTRACT 2023

contract Gypsum {

    string constant public name = "Gypsum";
    string constant public symbol = "GYP";
	uint8 constant public decimals = 18;
	uint256 constant private MIN_STAKE_AMOUNT = 1000;
	uint256 constant private DEFAULT_SCALAR_VALUE = 2**64;
    uint256 constant private FLUSHING_RATIO = 10;
	uint256 constant private START_SUPPLY = 1e26;
	uint256 constant private MINIMUM_SUPPLY_PERC = 5;


	struct User {
		uint256 balance;
		uint256 amountStaked;
		mapping(address => uint256) allowance;
		int256 scaledPayout;
		bool burningDisabled;
	}


	struct Data {
		address adminAddress;
		uint256 totalSupply;
		uint256 totalStaked;
		mapping(address => User) users;
		uint256 scaledPayoutPerToken;
	}


	Data private data;

	event Staking(address indexed holder, uint256 amountTokens);
	event UnStaking(address indexed holder, uint256 amountTokens);
    event DisableFlushing(address indexed holder, bool status);
    event Flush(uint256 amountTokens);
	event Approval(address indexed holder, address indexed spender, uint256 amountTokens);
	event CollectRewards(address indexed holder, uint256 amountTokens);
	event Transfer(address indexed from, address indexed to, uint256 amountTokens);

	constructor() public {
		data.adminAddress = msg.sender;
		data.totalSupply = START_SUPPLY;
		data.users[msg.sender].balance = START_SUPPLY;
		emit Transfer(address(0x0), msg.sender, START_SUPPLY);
		disableBurning(msg.sender, true);
	}

	function burn(uint256 _amountTokens) external {
		require(balanceOf(msg.sender) >= _amountTokens);
		data.users[msg.sender].balance -= _amountTokens;
		uint256 _amountFlushed = _amountTokens;
		if (data.totalStaked > 0) {
			_amountFlushed /= 2;
			data.scaledPayoutPerToken += _amountFlushed * DEFAULT_SCALAR_VALUE / data.totalStaked;
			emit Transfer(msg.sender, address(this), _amountFlushed);
		}

		data.totalSupply -= _amountFlushed;
		emit Transfer(msg.sender, address(0x0), _amountFlushed);
		emit Flush(_amountFlushed);
	}

	function staking(uint256 _amountTokens) external {
		_staking(_amountTokens);
	}

	function unstaking(uint256 _amountTokens) external {
		_unstaking(_amountTokens);
	}

	function approve(address _spender, uint256 _amountTokens) external returns (bool) {
		data.users[msg.sender].allowance[_spender] = _amountTokens;
		emit Approval(msg.sender, _spender, _amountTokens);
		return true;
	}

	function transferPlusReceiveData(address _receiver, uint256 _amountTokens, bytes calldata _data) external returns (bool) {
		uint256 _transferring = _transfer(msg.sender, _receiver, _amountTokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_receiver)
		}
		if (_size > 0) {
			require(Callable(_receiver).tokenCallback(msg.sender, _transferring, _data));
		}
		return true;
	}

	function _transfer(address _sender, address _receiver, uint256 _amountTokens) internal returns (uint256) {
		require(balanceOf(_sender) >= _amountTokens);
		data.users[_sender].balance -= _amountTokens;
		uint256 _amountFlushed = _amountTokens * FLUSHING_RATIO / 100;

		if (totalSupply() - _amountFlushed < START_SUPPLY * MINIMUM_SUPPLY_PERC / 100 || isBurningDisabled(_sender)) {
			_amountFlushed = 0;
		}

		uint256 _transferring = _amountTokens - _amountFlushed;
		data.users[_receiver].balance += _transferring;

		emit Transfer(_sender, _receiver, _transferring);
		if (_amountFlushed > 0) {
			if (data.totalStaked > 0) {
				_amountFlushed /= 2;
				data.scaledPayoutPerToken += _amountFlushed * DEFAULT_SCALAR_VALUE / data.totalStaked;
				emit Transfer(_sender, address(this), _amountFlushed);
			}

			data.totalSupply -= _amountFlushed;
			emit Transfer(_sender, address(0x0), _amountFlushed);
			emit Flush(_amountFlushed);
		}

		return _transferring;
	}

	function bulkTransfer(address[] calldata _receivers, uint256[] calldata _amountTokens) external {
		require(_receivers.length == _amountTokens.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amountTokens[i]);
		}
	}

	function transferFrom(address _sender, address _receiver, uint256 _amountTokens) external returns (bool) {
		require(data.users[_sender].allowance[msg.sender] >= _amountTokens);
		data.users[_sender].allowance[msg.sender] -= _amountTokens;
		_transfer(_sender, _receiver, _amountTokens);
		return true;
	}

	function transfer(address _receiver, uint256 _amountTokens) external returns (bool) {
		_transfer(msg.sender, _receiver, _amountTokens);
		return true;
	}

	function distribute(uint256 _amountTokens) external {
		require(data.totalStaked > 0);
		require(balanceOf(msg.sender) >= _amountTokens);
		data.users[msg.sender].balance -= _amountTokens;
		data.scaledPayoutPerToken += _amountTokens * DEFAULT_SCALAR_VALUE / data.totalStaked;
		emit Transfer(msg.sender, address(this), _amountTokens);
	}

	function disableBurning(address _holder, bool _status) public {
		require(msg.sender == data.adminAddress);
		data.users[_holder].burningDisabled = _status;
		emit DisableFlushing(_holder, _status);
	}

	function totalStaked() public view returns (uint256) {
		return data.totalStaked;
	}

	function totalSupply() public view returns (uint256) {
		return data.totalSupply;
	}

	function getRewards(address _holder) public view returns (uint256) {
		return uint256(int256(data.scaledPayoutPerToken * data.users[_holder].amountStaked) - data.users[_holder].scaledPayout) / DEFAULT_SCALAR_VALUE;
	}

	function allowance(address _holder, address _spender) public view returns (uint256) {
		return data.users[_holder].allowance[_spender];
	}

	function balanceOf(address _holder) public view returns (uint256) {
		return data.users[_holder].balance - getStaker(_holder);
	}

	function getStaker(address _holder) public view returns (uint256) {
		return data.users[_holder].amountStaked;
	}

	function isBurningDisabled(address _holder) public view returns (bool) {
		return data.users[_holder].burningDisabled;
	}

	function getData(address _holder) public view returns (uint256 totalTokenSupply, uint256 totalTokensamountStaked, uint256 HolderBalance, uint256 HolderamountStaked, uint256 HolderDividends) {
		return (totalSupply(), totalStaked(), balanceOf(_holder), getStaker(_holder), getRewards(_holder));
	}

	function _staking(uint256 _amount) internal {
		require(balanceOf(msg.sender) >= _amount);
		require(getStaker(msg.sender) + _amount >= MIN_STAKE_AMOUNT);
		data.totalStaked += _amount;
		data.users[msg.sender].amountStaked += _amount;
		data.users[msg.sender].scaledPayout += int256(_amount * data.scaledPayoutPerToken);
		emit Transfer(msg.sender, address(this), _amount);
		emit Staking(msg.sender, _amount);
	}

	function collectRewards() external returns (uint256) {
		uint256 _holdersWhoCanClaimRewards = getRewards(msg.sender);
		require(_holdersWhoCanClaimRewards >= 0);
		data.users[msg.sender].scaledPayout += int256(_holdersWhoCanClaimRewards * DEFAULT_SCALAR_VALUE);
		data.users[msg.sender].balance += _holdersWhoCanClaimRewards;
		emit Transfer(address(this), msg.sender, _holdersWhoCanClaimRewards);
		emit CollectRewards(msg.sender, _holdersWhoCanClaimRewards);
		return _holdersWhoCanClaimRewards;
	}

	function _unstaking(uint256 _amount) internal {
		require(getStaker(msg.sender) >= _amount);
		uint256 _amountFlushed = _amount * FLUSHING_RATIO / 100;
		data.scaledPayoutPerToken += _amountFlushed * DEFAULT_SCALAR_VALUE / data.totalStaked;
		data.totalStaked -= _amount;
		data.users[msg.sender].balance -= _amountFlushed;
		data.users[msg.sender].amountStaked -= _amount;
		data.users[msg.sender].scaledPayout -= int256(_amount * data.scaledPayoutPerToken);
		emit Transfer(address(this), msg.sender, _amount - _amountFlushed);
		emit UnStaking(msg.sender, _amount);
	}


}