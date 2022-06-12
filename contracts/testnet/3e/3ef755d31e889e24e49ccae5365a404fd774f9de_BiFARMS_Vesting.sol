// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract BiFARMS_Vesting is Ownable, ReentrancyGuard {
	using SafeERC20 for IERC20;

	struct Policy {
		uint256 next;
		uint256[] amounts;
	}

	IERC20 public token;
	uint256 public constant PERIOD = 5 minutes;
	uint256 public constant MAX_DAYS = 2 days;
	uint256 public startAt;

	mapping(address => Policy) private policies;
	mapping(address => uint256) public claimed;
	address[] private listOfBeneficiaries;
	bool public locked;

	event Released (
		address indexed beneficiary,
		uint256 day,
		uint256 amount
	);

	modifier zeroAddr(address _addr) {
        require(_addr != address(0), "Set zero address");
        _;
    }

	modifier isLocked() {
		require(!locked, "Locked already");
		_;
	}

	constructor(uint256 _startAt) Ownable() {
		require(_startAt >= block.timestamp, "Invalid vesting schedule");
		startAt = _startAt;
	}

	/**
       	@notice Enable the lock state of setting
       	@dev Caller must be Owner
			Note:
			- Set value of `locked` to `true`
			- When `locked = true`, setVesting() will be locked
				and additional vesting policies are unable to be added
			- No method to unlock this state
    */
	function lock() external onlyOwner isLocked {
		locked = true;
	}

	function setToken(address _token) external onlyOwner zeroAddr(_token) {
		require(address(token) == address(0), "Token contract existed");
		require(_token != address(0), "Set zero address");
		token = IERC20(_token);
	}

	function setVesting(
		address _beneficiary,
		uint256[] calldata _list
	)	external onlyOwner isLocked zeroAddr(_beneficiary) {
		require(
			policies[_beneficiary].amounts.length == 0, 
			"Beneficiary existed"
		);
		require(_list.length != 0, "Empty list");

		policies[_beneficiary] = Policy ({
			next: 0,
			amounts: _list
		});
		listOfBeneficiaries.push(_beneficiary);
	}

	function getBeneficiaries() external view returns (address[] memory _list) {
		_list = listOfBeneficiaries;
	}

	function getPolicy(address _beneficiary) external view returns (Policy memory _policy) {
		_policy = policies[_beneficiary];
	}

	function getAvailAmt(address _beneficiary) external view returns (uint256 _amount) {
		
		if (policies[_beneficiary].amounts.length == 0)
			return 0;

		(_amount, ) = _availableAmt(_beneficiary);
	}

	function claim() external nonReentrant {
		address _beneficiary = _msgSender();
		require(
			policies[_beneficiary].amounts.length != 0, 
			"Beneficiary not existed"
		);

		(uint256 _amount, uint256 _now) = _availableAmt(_beneficiary);
		require(_amount != 0, "Zero vesting amount. Please check your policy again");

		policies[_beneficiary].next = _now + 1;
		claimed[_beneficiary] += _amount;
	
		_releaseTokenTo(_beneficiary, _now, _amount);
	}

	function _availableAmt(address _beneficiary) private view returns (uint256 _amount, uint256 _now) {
		uint256[] memory _values =  policies[_beneficiary].amounts;
		uint256 _next = policies[_beneficiary].next;
		_now = block.timestamp;
		if (_now < startAt)
			return (0, _now);

		_now = (_now - startAt) / PERIOD;
		if (_now > MAX_DAYS)
			_now = MAX_DAYS;

		for(_next; _next <= _now; _next++) 
			_amount = _amount + _values[_next];
	}

	/**
       	@notice Owner uses this method to transfer remaining tokens
       	@dev Caller must be Owner
	   		Note: 
			- This method should be used ONLY in the case that
			tokens are distributed wrongly by mistaken settings
			- It should be called 7 days after TGE has already completed
    */
	function collect() external onlyOwner {
		uint256 _until = MAX_DAYS + 10 minutes;
		require(
			block.timestamp > startAt + _until * 24 hours, "Should call 7 days after TGE"
		);
		uint256 _balance = token.balanceOf(address(this));
		require(_balance != 0, "Allocations completely vested");

		_releaseTokenTo(_msgSender(), _until, _balance);
	}

	function _releaseTokenTo(address _beneficiary, uint256 _currentVesting, uint256 _amount) private {
		token.safeTransfer(_beneficiary, _amount);
		
		emit Released(_beneficiary, _currentVesting, _amount);
	}
}