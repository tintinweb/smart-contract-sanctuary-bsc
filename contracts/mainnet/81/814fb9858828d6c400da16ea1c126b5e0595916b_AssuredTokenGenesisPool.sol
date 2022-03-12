/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.7;

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
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
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
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

struct Tarif {
  uint256 life_days;
  uint256 percent;
}

struct Deposit {
  uint256 tarif;
  uint256 amount;
  uint40 time;
}

struct Player {
  uint256 dividends;
  uint256 ref_bonus;  
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_ref_bonus;
  uint256 total_redeemed;
  uint256[5] structure; 
  uint40 last_payout;
  Deposit[] deposits;
  address upline;
}

contract AssuredTokenGenesisPool {
	  using SafeMath for uint256;
	  using SafeMath for uint40;
    using SafeERC20 for IERC20;
	
    address public owner;
	  address public marketing;
    address public charity;
	
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    uint256 public redeemed_funds;
    uint256 public redeem_percentage;
    uint256 constant MAX_WITHDRAW = 1 ether;
    uint8 constant BONUS_LINES_COUNT = 5;
    uint8 public isScheduled;
    uint16 constant PERCENT = 1000; 
    uint16[BONUS_LINES_COUNT] private ref_bonuses = [200, 100, 50, 30, 10]; 
	  uint256 private constant HOUR = 1 hours;
    uint256 private numHours = 1; 
 	
    mapping(uint256 => Tarif) public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event RefPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event DividendsTranferred(address indexed _from, address indexed _to, uint256 amount);

	  IERC20 public AST;
    
    constructor() {

        owner = msg.sender;
        marketing = owner;
        charity = owner;

		  AST = IERC20(0xF63A242CA36E832e052BB47d73d117Fa93401635);
	
		  uint256 tarifPercent = 126;
        for (uint8 tarifDuration = 7; tarifDuration <= 37; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }
		
    }
	
	function deposit(uint8 _tarif, address _upline) external payable {
	    require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 300, "Max 300 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;
        _refPayout(msg.sender, msg.value);

    	  uint256 shares = msg.value / 20;        
        payable(owner).transfer(shares); 
        payable(marketing).transfer(shares); 
        payable(charity).transfer(shares); 
		
        withdrawn += (shares+shares+shares);
		
        if( AST.balanceOf(address(this)) - msg.value >= 0)
        {
            Tarif storage tarif = tarifs[_tarif];
            uint256 roi = (msg.value * tarif.percent) / 100; 
            AST.safeTransfer(msg.sender, roi);		                
		    }
        
        emit NewDeposit(msg.sender, msg.value, _tarif);

    }
	
    function withdraw() external {
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.last_payout + (HOUR * numHours)), "Not due yet for next encashment!");
        }

        _payout(msg.sender);

        require(player.dividends > 0 || player.ref_bonus > 0, "No New Dividends Earned Yet!");

        
        uint256 amount = player.dividends + player.ref_bonus;
	    
        uint256 redeem_amount = 0;//(amount * redeem_percentage) / 100;
        uint256 total_amount = amount+redeem_amount;
        
		    if(AST.balanceOf(msg.sender) - total_amount >= 0){}
		    else{
			    total_amount = amount;
		    }
        require( AST.balanceOf(msg.sender) - total_amount >= 0,"Not Enough Redemption Tokens!");
        
        payable(msg.sender).transfer(total_amount);

        emit Withdraw(msg.sender, amount);
        withdrawn += amount;
        redeemed_funds += redeem_amount;
        
        AST.safeTransferFrom(msg.sender, address(this), total_amount);
            
        player.dividends = 0;
        player.ref_bonus = 0;
        player.total_withdrawn += amount;
        player.total_redeemed += redeem_amount;
      
    }
	
	function sendWithdrawables(address _dest) external {
        Player storage myAcct = players[msg.sender];
        Player storage dest = players[_dest];
        
        _payout(msg.sender);
        _payout(_dest);

        require(myAcct.dividends > 0 || myAcct.ref_bonus > 0, "No New Dividends Earned Yet!");

        uint256 amount = myAcct.dividends + myAcct.ref_bonus;

        dest.dividends = dest.dividends + amount;

        myAcct.dividends = 0;
        myAcct.ref_bonus = 0;
        myAcct.total_withdrawn += amount;

        emit DividendsTranferred(msg.sender, _dest, amount);
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

	function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT;
            
            payable(up).transfer(bonus); 
			      withdrawn += bonus;
			      emit Withdraw(up, bonus);
			
            players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
            emit RefPayout(up, _addr, bonus);
        
            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }   

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }
    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_ref_bonus, uint256 total_redeemed, uint256[BONUS_LINES_COUNT] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_ref_bonus,
            player.total_redeemed,
            structure
        );
    }
	
	function transferOwnership(address newOwner) public returns (bool success) {
        require(msg.sender==owner,'Non-Owner Wallet!');
        owner = newOwner;
        return true;
    }

    function setRedeemPercentage(uint256 newVal) public returns (bool success) {
        require(msg.sender==owner,'Non-Owner Wallet!');
        redeem_percentage = newVal;
        return true;
    }

    function setMarketing(address newMarketing) public returns (bool success) {
        require(msg.sender==owner,'Non-Owner Wallet!');
        marketing = newMarketing;
        return true;
    }

    function setCharity(address newCharity) public returns (bool success) {
        require(msg.sender==owner,'Non-Owner Wallet!');
        charity = newCharity;
        return true;
    }
	
	function setScheduled(uint8 newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        isScheduled = newval;
        return true;
    }
    
    function setHours(uint newval) public returns (bool success) {
        require(msg.sender==owner,'Unauthorized Wallet!');
        numHours = newval;
        return true;
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _ref_bonus, uint256 _redeemed) {
        return (invested, withdrawn, ref_bonus, redeemed_funds);
    }
    
}