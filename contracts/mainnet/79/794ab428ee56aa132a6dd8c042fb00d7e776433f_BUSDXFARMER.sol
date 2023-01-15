/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;


interface IERC20 {

	function totalSupply() external view returns (uint);

	function balanceOf(address account) external view returns (uint);

	function transfer(address recipient, uint amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint amount) external returns (bool);

	function transferFrom(address sender, address recipient, uint amount) external returns (bool);

}


library Address {

	function isContract(address account) internal view returns (bool) {

		uint size;
		assembly {
			size := extcodesize(account)
		}
		return size > 0;
	}

	function sendValue(address payable recipient, uint amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{value: amount}("");
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
		uint value
	) internal returns (bytes memory) {
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint value,
		string memory errorMessage
	) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		require(isContract(target), "Address: call to non-contract");
		(bool success, bytes memory returndata) = target.call{value: value}(data);
		return verifyCallResult(success, returndata, errorMessage);
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
		return verifyCallResult(success, returndata, errorMessage);
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
		return verifyCallResult(success, returndata, errorMessage);
	}

	function verifyCallResult(
		bool success,
		bytes memory returndata,
		string memory errorMessage
	) internal pure returns (bytes memory) {
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


library SafeERC20 {

	using Address for address;

	function safeTransfer(
		IERC20 token,
		address to,
		uint value
	) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

	function safeTransferFrom(
		IERC20 token,
		address from,
		address to,
		uint value
	) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
	}

	function safeApprove(
		IERC20 token,
		address spender,
		uint value
	) internal {
		require(
			(value == 0) || (token.allowance(address(this), spender) == 0),
			"SafeERC20: approve from non-zero to non-zero allowance"
		);
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}

	function safeIncreaseAllowance(
		IERC20 token,
		address spender,
		uint value
	) internal {
		uint newAllowance = token.allowance(address(this), spender) + value;
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
	}

	function safeDecreaseAllowance(
		IERC20 token,
		address spender,
		uint value
	) internal {
		unchecked {
			uint oldAllowance = token.allowance(address(this), spender);
			require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
			uint newAllowance = oldAllowance - value;
			_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
		}
	}

	function _callOptionalReturn(IERC20 token, bytes memory data) private {
		bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
		if (returndata.length > 0) {
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
		}
	}
}


struct Tarif {
	uint8 life_days;
	uint8 percent;
}

struct Deposit {
	uint8 tarif;
	uint amount;
	uint time;
}

struct Player {
	address upline;
	uint dividends;
	uint match_bonus;
	uint last_payout;
	uint total_invested;
	uint total_withdrawn;
	uint total_match_bonus;
	Deposit[] deposits;
	uint[5] structure;
}

struct HistoryDeposit {
	address player;
	uint amount;
	uint time;
}


contract BUSDXFARMER {

	receive() external payable {}

	using SafeERC20 for IERC20;

	IERC20 public						BUSD;

	uint16 constant						PERCENT_DIVIDER =		1000;
	uint8 constant						BONUS_LINES_COUNT =		5;
 	uint8[BONUS_LINES_COUNT] public		ref_bonuses =			[70, 30, 20, 10, 5];

 	bool public							launched;
	address public						owner;
	uint public							invested;
	uint public							withdrawn;
	uint public							match_bonus;

	mapping(uint8 => Tarif) public		tarifs;
	mapping(address => Player) public	players;
	HistoryDeposit[] public				deposits;

	event event_deposit(address indexed user, uint8 tarif, address indexed upline, uint amount, uint8 depositsLength, address indexed uplineFinal);
	event event_withdraw(address indexed user, uint totalAmount, uint plansDividends, uint referralBonus);
	event event_setUpline(address indexed user, address indexed upline);
	event event_refBonus(address indexed user, address indexed from, uint amount);


	constructor(address _busd) {

		owner = msg.sender;

		BUSD = IERC20(_busd);

		uint8 tarifPercent = 130;
		for (uint8 tarifDuration = 10; tarifDuration <= 30; tarifDuration++) {
			tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
			tarifPercent += 5;
		}
		
	}


	function deposit(uint8 _tarif, address _upline, uint _amount) external {

		Player storage player = players[msg.sender];

		require( launched || (msg.sender == owner), "Project is not launched");

		require( tarifs[_tarif].life_days > 0, "Tarif not found");

		require( _amount >= 30 ether, "Minimal deposit amount required");

		require( player.deposits.length < 100, "Max 100 deposits per address");

		if(!launched) {
			launched = true;
		}

		BUSD.safeTransferFrom(msg.sender, address(this), _amount);

		BUSD.safeTransfer(owner, _amount / 10);

		_setUpline(msg.sender, _upline);

		_refPayout(msg.sender, _amount);


		player.deposits.push(
			Deposit({
				tarif: _tarif,
				amount: _amount,
				time: block.timestamp
			})
		);

		deposits.push(
			HistoryDeposit({
				player: msg.sender,
				amount: _amount,
				time: block.timestamp
			})
		);

		player.total_invested += _amount;
		invested += _amount;

		emit event_deposit(msg.sender, _tarif, _upline, _amount, uint8(player.deposits.length), player.upline);

	}


	function withdraw() external {

		Player storage player = players[msg.sender];

		_doPayout(msg.sender);

		uint amount = player.dividends + player.match_bonus;

		require(amount > 0, "Zero amount");

		emit event_withdraw(msg.sender, amount, player.dividends, player.match_bonus);

		player.dividends = 0;
		player.match_bonus = 0;
		player.total_withdrawn += amount;
		withdrawn += amount;

		BUSD.safeTransfer(msg.sender, amount);

	}


	function getUserAvailable(address _addr) public view returns(uint _amount) {
		(_amount,,) = _payoutOf(_addr);
		_amount += players[_addr].match_bonus;
	}


	struct userInfoData {
		bool isUser;
		uint earnings;
		uint active;
		uint daily;
		uint match_bonus;
		uint total_invested;
		uint total_withdrawn;
		uint total_match_bonus;
		uint[BONUS_LINES_COUNT] structure;
		uint structure_sum;
	}

	function userInfo(address _addr) view external returns(	uint _time, userInfoData memory _userData ) {

		Player storage player = players[_addr];

		uint[BONUS_LINES_COUNT] memory temp;
		_userData = userInfoData({
			isUser:				_isUser(_addr),
			earnings: 0,
			active: 0,
			daily: 0,
			match_bonus: 		player.match_bonus,
			total_invested:		player.total_invested,
			total_withdrawn:	player.total_withdrawn,
			total_match_bonus:	player.total_match_bonus,
			structure:			temp,
			structure_sum:		0
		});

		(_userData.earnings, _userData.active, _userData.daily) = _payoutOf(_addr);

		for(uint8 i = 0; i < ref_bonuses.length; i++) {
			_userData.structure[i] = player.structure[i];
			_userData.structure_sum += player.structure[i];
		}

		return ( block.timestamp, _userData );
	}


	function userDeposits(address _addr) view external returns(uint _time, Deposit[100] memory _deposits, uint _count) {

		Player storage player = players[_addr];

		for(uint8 i = 0; i < player.deposits.length; i++) {
			_deposits[i] = player.deposits[i];
		}

		return( block.timestamp, _deposits, player.deposits.length );

	}


	struct contractInfoData {
		uint time;
		uint balance;
		uint invested;
		uint withdrawn;
		uint match_bonus;
	}
	function contractInfo(address _addr) view external returns(contractInfoData memory _contractData, uint _depositsCount, HistoryDeposit[20] memory _deposits, uint _userBalance, uint _userApproved) {

		_contractData.time = block.timestamp;
		_contractData.balance = BUSD.balanceOf(address(this));
		_contractData.invested = invested;
		_contractData.withdrawn = withdrawn;
		_contractData.match_bonus = match_bonus;

		uint cnt = deposits.length >= 20 ? 20 : deposits.length;
		uint start = deposits.length - cnt;
		for(uint i=start; i<deposits.length; i++) {
			_deposits[i-start] = deposits[i];
		}

		return ( _contractData , deposits.length, _deposits, BUSD.balanceOf(_addr), BUSD.allowance(_addr,address(this)) );
	}


	function _isUser(address _addr) private view returns(bool) {
		return (players[_addr].deposits.length > 0);
	}

	function _payoutOf(address _addr) view private returns(uint _amount, uint8 _active, uint _daily) {

		Player storage player = players[_addr];

		for(uint i = 0; i < player.deposits.length; i++) {

			Deposit storage dep = player.deposits[i];
			Tarif storage tarif = tarifs[dep.tarif];

			uint time_end = dep.time + tarif.life_days * 86400;
			uint from = player.last_payout > dep.time ? player.last_payout : dep.time;
			uint to = block.timestamp > time_end ? time_end : block.timestamp;

			if(from < to) {
				_amount += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
			}
			if(block.timestamp < time_end) {
				_daily += (dep.amount * tarif.percent / tarif.life_days ) / 100;
				_active++;
			}
		}

		return (_amount, _active, _daily);
	}

	function _setUpline(address _addr, address _upline) private {

		if( players[_addr].upline != address(0) ) return;
		if( !_isUser(_upline) ) return;
		if( _addr == _upline ) return;

		players[_addr].upline = _upline;
		emit event_setUpline(_addr, _upline);

		for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
			players[_upline].structure[i]++;
			_upline = players[_upline].upline;
			if(_upline == address(0)) break;
		}

	}

	function _refPayout(address _addr, uint _amount) private {

		address up = players[_addr].upline;

		for(uint8 i = 0; i < ref_bonuses.length; i++) {

			if(up == address(0)) break;

			uint bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;

			players[up].match_bonus += bonus;
			players[up].total_match_bonus += bonus;

			match_bonus += bonus;

			emit event_refBonus(up, _addr, bonus);

			up = players[up].upline;
		}
	}

	function _doPayout(address _addr) private {

		uint payout;
		(payout,,) = _payoutOf(_addr);

		if(payout > 0) {
			players[_addr].last_payout = block.timestamp;
			players[_addr].dividends += payout;
		}
	}



}