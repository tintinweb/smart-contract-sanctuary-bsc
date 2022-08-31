/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

pragma solidity ^0.8.6;
interface I {
	function balanceOf(address a) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function transferFrom(address sender,address recipient, uint amount) external returns (bool);
	function getRewards(address a,uint rewToClaim) external;
}
// this contract' beauty was butchered
contract StakingContract {
	address public _letToken;
	address public _treasury;
	uint public totalLetLocked;

	struct TokenLock {
		uint128 amount;
		uint32 lastClaim;
		uint32 lockUpTo;
		uint32 reserved;
	}

	mapping(address => TokenLock) private _ls;
	
    bool public ini;
    
	function init() public {
	    //require(ini==false);ini=true;
		_letToken = 0x74404135DE39FABB87493c389D0Ca55665520d9A;
		_treasury = 0xee59B379eC7DC18612B39f35eD8A46C78463E744;
	}

	function lock25days(uint amount) public {// game theory disallows the deployer to exploit this lock, every time locker can exit before a malicious trust minimized upgrade is live
		_getLockRewards(msg.sender);
		_ls[msg.sender].lockUpTo=uint32(block.number+720000);
		require(amount>0 && I(_letToken).balanceOf(msg.sender)>=amount);
		_ls[msg.sender].amount+=uint128(amount);
		I(_letToken).transferFrom(msg.sender,address(this),amount);
		totalLetLocked+=amount;
	}

	function getLockRewards() public returns(uint){
		return _getLockRewards(msg.sender);
	}

	function _getLockRewards(address a) internal returns(uint){
		uint toClaim=0;
		if(_ls[a].amount>0){
			toClaim = lockRewardsAvailable(a);
			I(_treasury).getRewards(a, toClaim);
			_ls[msg.sender].lockUpTo=uint32(block.number+720000);
		}
		_ls[msg.sender].lastClaim=uint32(block.number);
		return toClaim;
	}

	function lockRewardsAvailable(address a) public view returns(uint) {
		if(_ls[a].amount>0){
			uint rate = 47e13;
			/// a cap to rewards
			uint cap = totalLetLocked*100/100000e18;
			if(cap>100){cap=100;}
			rate = rate*cap/100;
			///
			uint amount = (block.number - _ls[a].lastClaim)*_ls[a].amount*rate/totalLetLocked;
			return amount;
		} else {
			return 0;
		}
	}

	function unlock(uint amount) public {
		require(_ls[msg.sender].amount>=amount && totalLetLocked>=amount && block.number>_ls[msg.sender].lockUpTo);
		_getLockRewards(msg.sender);
		_ls[msg.sender].amount-=uint128(amount);
		I(_letToken).transfer(msg.sender,amount*19/20);
		uint leftOver = amount - amount*19/20;
		I(_letToken).transfer(_treasury,leftOver);//5% burn to treasury as spam protection
		totalLetLocked-=amount;
	}

// VIEW FUNCTIONS ==================================================
	function getVoter(address a) external view returns (uint amount,uint lockUpTo,uint lastClaim) {
		return (_ls[a].amount,_ls[a].lockUpTo,_ls[a].lastClaim);
	}
}