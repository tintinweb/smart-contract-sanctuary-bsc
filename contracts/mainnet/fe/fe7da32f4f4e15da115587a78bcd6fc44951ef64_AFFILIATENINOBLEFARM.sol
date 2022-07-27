/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity ^ 0.6.2;

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

 library Address {
 	function isContract(address account) internal view returns(bool) {
 		bytes32 codehash;
 		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
 		assembly {
 			codehash:= extcodehash(account)
 		}
 		return (codehash != accountHash && codehash != 0x0);
 	}

 	function sendValue(address payable recipient, uint256 amount) internal {
 		require(address(this).balance >= amount, "Address: insufficient balance");
 		(bool success, ) = recipient.call {
 			value: amount
 		}("");
 		require(success, "Address: unable to send value, recipient may have reverted");
 	}

 	function functionCall(address target, bytes memory data) internal returns(bytes memory) {
 		return functionCall(target, data, "Address: low-level call failed");
 	}

 	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
 		return _functionCallWithValue(target, data, 0, errorMessage);
 	}

 	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
 		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 	}

 	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
 		require(address(this).balance >= value, "Address: insufficient balance for call");
 		return _functionCallWithValue(target, data, value, errorMessage);
 	}

 	function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns(bytes memory) {
 		require(isContract(target), "Address: call to non-contract");
 		(bool success, bytes memory returndata) = target.call {
 			value: weiValue
 		}(data);
 		if (success) {
 			return returndata;
 		} else {
 			if (returndata.length > 0) {

 				assembly {
 					let returndata_size:= mload(returndata)
 					revert(add(32, returndata), returndata_size)
 				}
 			} else {
 				revert(errorMessage);
 			}
 		}
 	}
 }



 abstract contract Context {
 	function _msgSender() internal view virtual returns(address payable) {
 		return msg.sender;
 	}

 	function _msgData() internal view virtual returns(bytes memory) {
 		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
 		return msg.data;
 	}
 }


 contract Ownable is Context {
 	address private _owner;
 	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 	constructor() internal {
 		address msgSender = _msgSender();
 		_owner = msgSender;
 		emit OwnershipTransferred(address(0), msgSender);
 	}

 	function owner() public view returns(address) {
 		return _owner;
 	}
 	modifier onlyOwner() {
 		require(_owner == _msgSender(), "Ownable: caller is not the owner");
 		_;
 	}

 	function renounceOwnership() public virtual onlyOwner {
 		emit OwnershipTransferred(_owner, address(0));
 		_owner = address(0);
 	}

 	function transferOwnership(address newOwner) public virtual onlyOwner {
 		require(newOwner != address(0), "Ownable: new owner is the zero address");
 		emit OwnershipTransferred(_owner, newOwner);
 		_owner = newOwner;
 	}
 }



 contract AFFILIATENINOBLEFARM is Ownable {
 	using SafeMath
 	for uint256;


 	struct UserInfo {
 		uint256 amount;
 		uint256 rewardDebt;
 		uint256 release_block;
 	}

 	struct PoolInfo {
 		address tokenStaking;
 		uint256 accPerShare;
 		uint256 totalLP;
 		uint256 rewardPerBlock;
 		uint256 lastRewardBlock;
 		uint256 lock_deposit_block;
 		uint256 divider;
         
 	}

	address REWARD = 0xC866987195f2EEA49A170e328ac26E7B5565352f;

 	constructor() public {
		 createFarm(0x703aDE9FF10c39606EcDbbf17d3e5602001782f1,10000000);
 	}

 	PoolInfo[] public poolInfo;
 	mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => address) private upline;


 	//createFarm   Farms 
 	function createFarm(address token_staking,  uint256 _divider ) public onlyOwner {
        if(_divider<10000000)return;
 		poolInfo.push(PoolInfo({
 			tokenStaking: token_staking,
 			accPerShare: 0,
 			totalLP: 0,
 			lastRewardBlock: 0,
 			lock_deposit_block: 100,
 			rewardPerBlock: 0,
 			divider: _divider
            
 		}));
 	}

 	function pendingReward(uint256 _pid, address _user) public view returns(uint256) {

 		PoolInfo storage pool = poolInfo[_pid];
 		UserInfo storage user = userInfo[_pid][_user];
 		uint256 accPerShare = pool.accPerShare;
 		uint256 lpSupply = pool.totalLP;
 		uint256 rPerBlock = pool.rewardPerBlock;
 		uint256 lastRewardBloc = pool.lastRewardBlock;
 		uint256 curentBlock = block.number;

 		if (curentBlock > pool.lastRewardBlock && lpSupply != 0) {
 			uint256 multiplier = curentBlock.sub(lastRewardBloc);
 			uint256 tokenReward = multiplier.mul(rPerBlock);
 			accPerShare = accPerShare.add(tokenReward.mul(1e50).div(lpSupply));
 		}
 		uint256 debt = user.rewardDebt;
 		uint256 rew = user.amount.mul(accPerShare).div(1e50);
 		uint256 pend = 0;
 		if (rew > debt) pend = rew.sub(debt);
 		return pend;

 	}


 	function timelock(uint256 _pid, address _user) public view returns(uint256) {
 		UserInfo storage user = userInfo[_pid][_user];
 		uint256 remaining = 0;
 		if (user.release_block > block.number) remaining = user.release_block - block.number;
 		return remaining;

 	}

	function updatedivider(uint256 _pid,uint256 _divider) public onlyOwner {
         if(_divider<10000000)return;
 		PoolInfo storage pool = poolInfo[_pid];
 		 pool.divider = _divider;
    }

 	function updatePool(uint256 _pid) public {
 		PoolInfo storage pool = poolInfo[_pid];
 		uint256 rPerBlock = pool.rewardPerBlock;
 		if (block.number <= pool.lastRewardBlock) {
 			return;
 		}
 		uint256 lpSupply = pool.totalLP;
 		uint256 rewardAvailable = IERC20(REWARD).balanceOf(address(this));
 		pool.rewardPerBlock = rewardAvailable.div(pool.divider);
 		uint256 lastRewardBloc = pool.lastRewardBlock;
 		uint256 curentBlock = block.number;
 		uint256 multiplier = curentBlock.sub(lastRewardBloc);
 		uint256 tokenReward = multiplier.mul(rPerBlock);
 		pool.accPerShare = pool.accPerShare.add(tokenReward.mul(1e50).div(lpSupply));
 		pool.lastRewardBlock = block.number;
 	}



 	//deposit LP
 	function deposit(uint256 _pid, uint256 _amount,address _upline) public {
 		PoolInfo storage pool = poolInfo[_pid];
 		UserInfo storage user = userInfo[_pid][address(msg.sender)];

 		if (pool.totalLP == 0) {
 			pool.lastRewardBlock = block.number;
 		}

 		uint256 unsend = 0;
 		if (user.amount > 0) {
            if(upline[address(msg.sender)]==address(0))upline[address(msg.sender)] = _upline;
 			uint256 pending = pendingReward(_pid, address(msg.sender));
 			unsend = pending;
 			uint256 remaining = timelock(_pid, address(msg.sender));
 			if (pending > 0 && remaining == 0) {
 				unsend = 0;
 				IERC20(REWARD).transfer(address(msg.sender), pending);
                if(pending>10)
                IERC20(REWARD).transfer(upline[address(msg.sender)], pending.div(10));
 				user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e50);
 			}
 		}

 		if (_amount > 0) {
 			IERC20(pool.tokenStaking).transferFrom(address(msg.sender), address(this), _amount);
 			user.amount = user.amount.add(_amount);
 			pool.totalLP = pool.totalLP.add(_amount);
 			user.release_block = block.number.add(pool.lock_deposit_block);
 		}

 		updatePool(_pid);
 		uint256 rew = user.amount.mul(pool.accPerShare).div(1e50);
 		user.rewardDebt = rew;
 		if (unsend > 0) user.rewardDebt = user.rewardDebt.sub(unsend);

 	}

 	function withdraw(uint256 _pid,uint256 _amount) public {
 		PoolInfo storage pool = poolInfo[_pid];
 		UserInfo storage user = userInfo[_pid][address(msg.sender)];
 		require(user.amount >= _amount, "withdraw: not good");
 		require(_amount > 0, "withdraw: Must > 0");
        
 		if (user.release_block <= block.number) {
 			uint256 pending = pendingReward(_pid, address(msg.sender));
 			uint256 rewardAvailable = IERC20(REWARD).balanceOf(address(this));
 			uint256 safepending = 0;
 			if (pending <= rewardAvailable) safepending = pending;
 			if (safepending > 0) {
 				IERC20(REWARD).transfer(address(msg.sender), pending);
                if(pending>10)
                IERC20(REWARD).transfer(upline[address(msg.sender)], pending.div(10));
 			}
			user.amount = user.amount.sub(_amount);
 			
 			IERC20(pool.tokenStaking).transfer(address(msg.sender), _amount);
 			pool.totalLP = pool.totalLP.sub(_amount);
             
 		 updatePool(_pid);
 		 uint256 rew  = user.amount.mul(pool.accPerShare).div(1e50);
 	     user.rewardDebt = rew;
 		 

		 }

 	}

 	function balanceLP(uint256 _pid, address _user) external view returns(uint256) {
 		UserInfo storage user = userInfo[_pid][_user];
 		return user.amount;
 	}

     //clear BNB inside contract from unknow sender
     function clearBNB() external onlyOwner{
        uint256 ib = address(this).balance;
         payable(msg.sender).transfer(ib);
    }
    

 }