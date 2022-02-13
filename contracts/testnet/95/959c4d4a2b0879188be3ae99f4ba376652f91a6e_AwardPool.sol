/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function mint(address account, uint amount) external;
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// MasterChef is the master of Good. He can make Good and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Good is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.


contract AwardPool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    // Info of each userInfo.
    struct UserInfo {
		uint256 remainMaxReward;
		//uint256 trueReward;
		
        uint256 amount; 
        uint256 rewardDebt;         
		
        address leader;
        uint256 inviteNum;
		uint256 performance;
    }
    mapping(address => UserInfo) public userInfo;
    // Info of each poolInfo.
    struct PoolInfo {
		uint256 pledgeTotal;
        uint256 lastRewardBlock; 
        uint256 accPerShare; 
		
		uint256 price; 
		uint256 multiple;
		uint256 shareRate;

    }
	struct GuildInfo{
		uint256 minInviteNum;
		uint256 minPerformance;
		uint256 awardRate;
	}
	mapping (uint256 => GuildInfo)public guildMap;
    uint256 public maxGuildLevel;
	

	IERC20 public MGF = IERC20(0xab41A7cd610f8173aE8F281A5740822f96855137);
	IERC20 public MGFA = IERC20(0x265a8c035158f2a397c2EAF4c996f5c7FD64deF4);
	
	uint256 public maxPledge = 10000 * 10 ** 18;
    uint256 public minPledge = 1000 * 10 ** 18;
	
	address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	uint256 public burnRate = 60;
	
    address public foundationWallet = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public foundationRate = 20;
	
	address public technologyAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public technologyRate = 10;
	
	address public mediaAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public mediaRate = 5;
	
	address public activityAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public activityRate = 5;
	
    uint256 public awardPerBlock = 10417 * 10 **14;
    PoolInfo public poolInfo;
    uint256 public startBlock;
    uint256 public endBlock;
    address public owner;

    bool public paused = false;
    bool public additionSwitch = false;
 
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user,  uint256 amount);
    event SetPause( bool paused);


    constructor() public {
        owner = msg.sender;
        poolInfo.price = 10 ** 18;
        poolInfo.multiple = 3;
        poolInfo.shareRate = 30;
        startBlock =  block.number;
        endBlock = block.number.add(9999999999);
        _setGuildMap(1,50, 5 * 10 ** 18,10);
        _setGuildMap(2,200, 10 * 10 ** 18,20);
        maxGuildLevel = 2;
    }
	

    function setMaxAndMin(uint256 _max, uint256 _min) external onlyOwner{
        maxPledge = _max;
        minPledge = _min;
    }
    
    function setStartAndEnd(uint256 _startBlock, uint256 _endBlock) external onlyOwner{
        startBlock = _startBlock;
        endBlock = _endBlock;
    }
    
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256){
        return _to.sub(_from);
    }


    function pendingAward(address _user) external view returns(uint256){
        
        uint256 curBlock = endBlock < block.number ? endBlock : block.number;
        uint256 accPerShare = poolInfo.accPerShare;
        
        if (curBlock > poolInfo.lastRewardBlock && poolInfo.pledgeTotal != 0) {
            uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, curBlock);
            uint256 Reward = multiplier.mul(awardPerBlock);
            accPerShare = accPerShare.add(
                Reward.mul(1e12).div(poolInfo.pledgeTotal)
                );
        }
        
        // if(userInfo[_user].trueReward.add(
        //     userInfo[_user].amount.mul(accPerShare).div(1e12).sub(userInfo[_user].rewardDebt)
        //     ) >= userInfo[_user].remainMaxReward){
        //     return userInfo[_user].remainMaxReward.sub(userInfo[_user].trueReward);
        // }
        uint256 pending = userInfo[_user].amount.mul(accPerShare).div(1e12).sub(userInfo[_user].rewardDebt);
        if(  pending.mul(poolInfo.price).div(10 ** 18) > userInfo[_user].remainMaxReward){
            return userInfo[_user].remainMaxReward;
        }
        return userInfo[_user].amount.mul(accPerShare).div(1e12).sub(userInfo[_user].rewardDebt);
    }

    function updatePool() public {
        if (block.number <= poolInfo.lastRewardBlock) {
            return;
        }
      
        if (poolInfo.pledgeTotal == 0) {
            poolInfo.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
        uint256 awardReward = multiplier.mul(awardPerBlock);

        poolInfo.accPerShare = poolInfo.accPerShare.add(awardReward.mul(1e12).div(poolInfo.pledgeTotal));
        poolInfo.lastRewardBlock = block.number;
    }

    function pledge(uint256 _amount, address _leader) public notPause {

        require(_amount >= minPledge,"Too few");
        require(_amount <= maxPledge,"Too many");
        require(userInfo[msg.sender].amount == 0,"Not over yet");
        
        updatePool();
        MGF.transferFrom(msg.sender,burnAddress,getAmount(_amount,burnRate));
        MGF.transferFrom(msg.sender,foundationWallet,getAmount(_amount,foundationRate));
        MGF.transferFrom(msg.sender,technologyAddress,getAmount(_amount,technologyRate));
        MGF.transferFrom(msg.sender,mediaAddress,getAmount(_amount,mediaRate));
		MGF.transferFrom(msg.sender,activityAddress,getAmount(_amount,activityRate));
        
        handling(_amount,msg.sender,_leader);

        
		userInfo[msg.sender].remainMaxReward = _amount.mul(poolInfo.price).div(10 ** 18).mul(poolInfo.multiple);
		userInfo[msg.sender].amount = _amount;
        poolInfo.pledgeTotal = poolInfo.pledgeTotal.add(_amount);        
        userInfo[msg.sender].rewardDebt = userInfo[msg.sender].amount.mul(poolInfo.accPerShare).div(1e12);            
        chagePerBlock();
        emit Deposit(msg.sender, _amount);
		
	
    }
    function chagePerBlock()internal{
	
		if(poolInfo.pledgeTotal >= 10000000 * 10 ** 18){
			awardPerBlock = 13889 * 10 **14;
		}
		
		if(poolInfo.pledgeTotal >= 15000000 * 10 ** 18){
			awardPerBlock = 173612 * 10 **13;
		}
		
	}
    function handling(uint256 _amount, address _from, address _leader)internal{
        if(userInfo[_from].leader == address(0) && _leader != address(0) &&_leader != _from){
            userInfo[_from].leader = _leader;
            userInfo[_leader].inviteNum = userInfo[_leader].inviteNum.add(1);           
        }
		
        if(userInfo[_from].leader !=address(0)){
			address currentLeader = userInfo[_from].leader;
			userInfo[currentLeader].performance = userInfo[currentLeader].performance.add(_amount);
			// share 30%
            uint256 shareAmount =_amount.mul(poolInfo.shareRate).div(100);
			userInfo[currentLeader].amount = userInfo[currentLeader].amount.add(shareAmount);
            if(additionSwitch){
                uint256 shareMaxReward = shareAmount.mul(poolInfo.price).div(10 ** 18).mul(poolInfo.multiple);
                userInfo[currentLeader].remainMaxReward = userInfo[currentLeader].remainMaxReward.add(shareMaxReward);
			}
			for(uint256 i = maxGuildLevel; i > 0; i--){
			
				if(userInfo[currentLeader].performance > guildMap[i].minPerformance  && userInfo[currentLeader].inviteNum > guildMap[i].minInviteNum){
					uint256 guildAmount = _amount.mul(guildMap[i].awardRate).div(100);
                    userInfo[currentLeader].amount = userInfo[currentLeader].amount.add(guildAmount);
                    if(additionSwitch){
                        uint256 currentMaxReward = guildAmount.mul(poolInfo.price).div(10 ** 18).mul(poolInfo.multiple);
                        userInfo[currentLeader].remainMaxReward = userInfo[currentLeader].remainMaxReward.add(currentMaxReward);
                    }
					break;
				}
			}
		}
			
            
        
    }
    
    function getAmount(uint256 _amount, uint256 _rate) internal pure returns(uint256){
        return _amount.mul(_rate).div(100);
    }


    function withdraw() public  notPause {
        updatePool();
        uint256 pending = userInfo[msg.sender].amount.mul(poolInfo.accPerShare).div(1e12).sub(userInfo[msg.sender].rewardDebt);
        
        if(pending.mul(poolInfo.price).div(10 ** 18) > userInfo[msg.sender].remainMaxReward){
            pending = userInfo[msg.sender].remainMaxReward;
            poolInfo.pledgeTotal = poolInfo.pledgeTotal.sub(userInfo[msg.sender].amount);
            userInfo[msg.sender].amount = 0;
            userInfo[msg.sender].remainMaxReward = 0;            
           
        }else{
            userInfo[msg.sender].remainMaxReward = userInfo[msg.sender].remainMaxReward.sub(pending);
        }
        
        userInfo[msg.sender].rewardDebt = userInfo[msg.sender].amount.mul(poolInfo.accPerShare).div(1e12);
        safeTransferAward(msg.sender, pending);
        

    }


   
    function safeTransferAward(address _to, uint256 _amount) internal {
        uint256 awardBal = MGFA.balanceOf(address(this));
        if (_amount > awardBal) {
            MGFA.transfer(_to, awardBal);
        } else {
            MGFA.transfer(_to, _amount);
        }
    }

    function setAwardPerBlock(uint256 _awardPerBlock) public onlyOwner  {
       awardPerBlock = _awardPerBlock;
    }
    
	
	function setWallet(address _burnAddress,
						uint256 _burnRate,
						address _foundationWallet,
						uint256 _foundationRate,
						address _technologyAddress,
						uint256 _technologyRate,
						address _mediaAddress,
						uint256 _mediaRate,
						address _activityAddress,
						uint256 _activityRate)public onlyOwner {
		
		burnAddress = _burnAddress;
		burnRate =  _burnRate;
		foundationWallet = _foundationWallet;
		foundationRate = _foundationRate;
		technologyAddress = _technologyAddress;
		technologyRate = _technologyRate;
		mediaAddress = _mediaAddress;
		mediaRate = _mediaRate;
		activityAddress = _activityAddress;
		activityRate = _activityRate;
	}
    
    function setPrice(uint256 _price)public onlyOwner {
        poolInfo.price = _price;
    }

    function setMultiple(uint256 _multiple)public onlyOwner {
        poolInfo.multiple = _multiple;
    }
    function setShareRate(uint256 _shareRate)public onlyOwner{
        poolInfo.shareRate = _shareRate;
    }
    function setGuildMap( uint256 _mapId,uint256 _minInviteNum,
		uint256 _minPerformance,
		uint256 _awardRate)public onlyOwner{
            _setGuildMap(_mapId,_minInviteNum,_minPerformance,_awardRate);

    }

    function _setGuildMap( uint256 _mapId,uint256 _minInviteNum,
		uint256 _minPerformance,
		uint256 _awardRate)internal{
            guildMap[_mapId].minInviteNum = _minInviteNum;
            guildMap[_mapId].minPerformance = _minPerformance;
            guildMap[_mapId].awardRate = _awardRate;

    }
    function setMaxGuildLevel(uint256 _maxGuildLevel) public onlyOwner{
        maxGuildLevel = _maxGuildLevel;
    }

    function setAdditionSwitch(bool _status)public onlyOwner{
        additionSwitch = _status;
    }
    function setPause() public onlyOwner {
        paused = !paused;
        emit SetPause(paused);

    }
    modifier notPause() {
        require(paused == false, "Mining has been suspended");
        _;
    }
    function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
		IERC20(_token).transfer(msg.sender, _amount);
	}
	
	function PayTransfer(address payable recipient) public onlyOwner {
		recipient.transfer(address(this).balance);
	}

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
}