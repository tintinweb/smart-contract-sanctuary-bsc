/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PvPTicket {
    using SafeERC20 for IERC20;
	address private _owner;
	
	struct ticketConfig {
		IERC20 token;
		uint256 price;
		address team;
		uint256 teamfee;
		uint256 start_pvp_season;
		uint256 period_pvp_ticket;//86400 * 2; 172800
		uint256 period_pvp_season;//86400 * 5; 432000
	}
	
    mapping(uint256 => ticketConfig) private TicketConfigs;
    mapping(uint256 => mapping(address => uint256)) private AccountsTickets;

    constructor() {
        _owner = msg.sender;
        emit OwnerSet(address(0), _owner);
    }

    function getConfig(uint256 pvp) public view virtual returns (ticketConfig memory) {
		return TicketConfigs[pvp];
    }
	
    function setConfig(uint256 pvp, IERC20 token, uint256 price, address team, uint256 teamfee, uint256 start_pvp_season, uint256 period_pvp_ticket, uint256 period_pvp_season) public isOwner returns (bool success) {
		require(price > 0, "PvPTicket: missing price");
		require(team != address(0), "PvPTicket: missing team address");
		require(teamfee > 0, "PvPTicket: missing teamfee");
		require(start_pvp_season > 0, "PvPTicket: missing start pvp season");
		require(block.timestamp < start_pvp_season, "PvPTicket: current time is after start pvp season");
		require(period_pvp_season > 0, "PvPTicket: missing period pvp season");
		require(period_pvp_ticket > 0, "PvPTicket: missing period pvp ticket");
        TicketConfigs[pvp] = ticketConfig(
            token,
            price,
            team,
            teamfee,
            start_pvp_season,
            period_pvp_ticket,
            period_pvp_season
        );
        return true;
    }
	
    function getTicket(uint256 pvp, address account) public view virtual returns (uint256) {
        return AccountsTickets[pvp][account];
    }
	
    event NewSeason(uint256 indexed pvp, uint256 indexed start_pvp_season);
    function setSeason(uint256 pvp, uint256 start_pvp_season) public isOwner returns (bool success) {
        ticketConfig memory config = TicketConfigs[pvp];
        require(config.price > 0, "PvPTicket: This PvP type not configured");
        TicketConfigs[pvp].start_pvp_season = start_pvp_season;
		emit NewSeason(pvp, start_pvp_season);
        return true;
    }
	
    event TicketSale(uint256 pvp, address receiver, uint256 ticket_id);
	function ticketSale(uint256 pvp) public returns (bool success) {
        ticketConfig memory config = TicketConfigs[pvp];
        require(config.price > 0, "PvPTicket: This type not configured");
        if(msg.sender == _owner){
            //return true;
        }
        require(block.timestamp >= config.start_pvp_season, "PvPTicket: PvP season coming soon");
        require(block.timestamp < (config.start_pvp_season + config.period_pvp_ticket + config.period_pvp_season), "PvPTicket: PvP season is ended. New season coming soon");
        require(block.timestamp <= (config.start_pvp_season + config.period_pvp_ticket), "PvPTicket: TicketSale for this PvP season is ended");
        require(config.price > 0, "PvPTicket: Sell tickets coming soon");
        uint256 allowance = config.token.allowance(msg.sender, address(this));
        require(allowance >= config.price, "PvPTicket: Check the token allowance");
		uint256 Ticket = AccountsTickets[pvp][msg.sender];
		if(Ticket > 0 && Ticket > config.start_pvp_season && Ticket < (config.start_pvp_season + config.period_pvp_season)){
			require(false, "PvPTicket: Already buy ticket");
		}
		uint256 prizepool = config.price;
		if(config.teamfee > 0){
			uint256 teamfee = (prizepool / 100) * config.teamfee;
			prizepool -= teamfee;
            if(config.price == (teamfee + prizepool)){
                require(config.token.transferFrom(msg.sender, config.team, teamfee) == true, "PvPTicket: Couldn't transfer tokens to PvP Team");
            }else{
                require(false, "PvPTicket: Fail calculate team bonus");
            }
		}
        require(config.token.transferFrom(msg.sender, address(this), prizepool) == true, "PvPTicket: Couldn't transfer tokens to PvP Pool");
		AccountsTickets[pvp][msg.sender] = block.timestamp;
		emit TicketSale(pvp, msg.sender, block.timestamp);
        return true;
    }
	
	function ticketGift(uint256 pvp, address receiver) public isOwner returns (bool success) {
        ticketConfig memory config = TicketConfigs[pvp];
        require(config.price > 0, "PvPTicket: This type not configured");
        require(block.timestamp >= config.start_pvp_season, "PvPTicket: PvP season coming soon");
        require(block.timestamp < (config.start_pvp_season + config.period_pvp_ticket + config.period_pvp_season), "PvPTicket: PvP season is ended. New season coming soon");
        require(block.timestamp <= (config.start_pvp_season + config.period_pvp_ticket), "PvPTicket: TicketSale for this PvP season is ended");
		uint256 Ticket = AccountsTickets[pvp][receiver];
		if(Ticket > 0 && Ticket > config.start_pvp_season && Ticket < (config.start_pvp_season + config.period_pvp_season)){
			require(false, "PvPTicket: Already buy ticket");
		}
		AccountsTickets[pvp][receiver] = block.timestamp;
		emit TicketSale(pvp, receiver, block.timestamp);
        return true;
    }
	
	/*
	//IF BUY FOR ETHER
	function ticketSale() payable public {
        uint256 amount = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit TicketSale(msg.sender, amount);
    }
	*/
	
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    function getOwner() external view returns (address) {
        return _owner;
    }
	
    function setOwner(address newOwner) public isOwner {
		require(newOwner != address(0), "PvPTicket: missing new Owner address");
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    modifier isOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }
}

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.7;

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

pragma solidity ^0.8.7;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.8.7;

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "PvPTicket: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "PvPTicket: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "PvPTicket: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "PvPTicket: ERC20 operation did not succeed");
        }
    }
}