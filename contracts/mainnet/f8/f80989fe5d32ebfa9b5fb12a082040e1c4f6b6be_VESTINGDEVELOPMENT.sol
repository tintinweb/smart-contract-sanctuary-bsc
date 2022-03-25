/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity >=0.6.5;
 
library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;
		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
		// benefit is lost if 'b' is also tested.
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

 
interface IERC20 {
	function totalSupply() external view returns(uint256);

	function balanceOf(address account) external view returns(uint256);

	function transfer(address recipient, uint256 amount) external returns(bool);

	function allowance(address owner, address spender) external view returns(uint256);

	function approve(address spender, uint256 amount) external returns(bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract   VESTINGDEVELOPMENT   {
using SafeMath
	for uint256;
address locker ;
bool used = false;
uint256 public lastblock;
address public address_to_claim;
address public token;
uint256 public vestingperbloc;
uint256 public total_locked;
uint256 public hasbeenclaim;
uint256 public remaining_inlock;

  constructor() 
  public
 {
     locker = address(msg.sender);
 }
 
 function vesting(address _token,address _receiver,uint256 _month, uint256 _amount, uint256 _decimal)  public {
    if(address(msg.sender)!=locker ) return;
    if(used) return;
    used = true;
    token =_token;
    address_to_claim = _receiver;
    uint256 dig = 1;
    if(_month<1)_month = 1;
    lastblock = block.number.add(_month.mul(864401));
    if(_decimal>0)dig = 10**_decimal;
    uint256 amount_to_send =  _amount.mul(dig);
    IERC20(_token).transferFrom(address(msg.sender),address(this),amount_to_send);
    total_locked = IERC20(_token).balanceOf(address(this));
    remaining_inlock = total_locked;
    vestingperbloc = total_locked.div(_month.mul(864401));
 }
 
 function unvesting()  public {
    if(address(msg.sender)!=address_to_claim ) return;
    uint256 this_balance = IERC20(token).balanceOf(address(this));
    uint256 divider = 1;
    uint256 amount = this_balance;
    if(lastblock>block.number) { 
        divider = lastblock.sub(block.number);
        uint256 still_locked = divider.mul(vestingperbloc);
        if(this_balance>still_locked) amount =  this_balance.sub(still_locked);
        else amount = 0;
        hasbeenclaim = hasbeenclaim.add(amount);
    }

    IERC20(token).transfer(address_to_claim,amount);
    remaining_inlock = IERC20(token).balanceOf(address(this));
 }


function availabletowithdraw()  public view returns(uint256){
    uint256 this_balance = IERC20(token).balanceOf(address(this));
    uint256 divider = 1;
    uint256 amount = this_balance;
    if(lastblock>block.number){
        divider = lastblock.sub(block.number);
        uint256 still_locked = divider.mul(vestingperbloc);
        if(this_balance>still_locked) amount =  this_balance.sub(still_locked);
        else amount = 0;
    }
    
   return amount;
 }
 
}