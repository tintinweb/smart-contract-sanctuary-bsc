/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

	mapping(address => bool) public manager;

    event OwnershipTransferred(address indexed newOwner, bool isManager);


    constructor() {
        _setOwner(_msgSender(), true);
    }

    modifier onlyOwner() {
        require(manager[_msgSender()], "Ownable: caller is not the owner");
        _;
    }

    function setOwner(address newOwner,bool isManager) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner,isManager);
    }

    function _setOwner(address newOwner, bool isManager) private {
        manager[newOwner] = isManager;
        emit OwnershipTransferred(newOwner, isManager);
    }
}

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


contract Pool is Ownable{
    using SafeMath for uint256;
	using Address for address;
	
	struct PoolInfo{
		bool isEnabled;
		uint256 usdtRate;
		uint256 maxMiningTime;
		uint256 miningRate;
	}
	mapping(uint256 => PoolInfo)public poolMap;
	struct UserPool{
		bool isPledge;
		uint256 usdtAmount;
		uint256 tokenAmount;
		uint256 pledgeTime;
		uint256 lastTime;
	}
	mapping(address => mapping(uint256 => UserPool)) public userMap;
	
	struct LeaderInfo{
		address leader;
		uint256 oneAmount;
		address[] oneAddress;
		uint256 twoAmount;
		address[] twoAddress;
		uint256 threeAmount;
		address[] threeAddress;
		uint256 leaderReward;
	}
	mapping(address => LeaderInfo) public leaderMap;
	mapping(uint256 => uint256) public leaderRate;
	mapping (address => bool) public isWhiteList;
	
	address public HCB = 0x490254A7431B9b20Be35366Ad57a5bc37d090bcf; 
	address public USDT = 0x55d398326f99059fF775485246999027B3197955; 
	address public marketAddress; 
	address public burnAddress; 
	
	uint256 public marketRate; 
	uint256 public burnRate; 
	address public leaderAddress;
	address public leaderFeeAddress;

	
	
	event Pledge(address user, uint256 poolId, uint256 tokenAmount, uint256 usdtAmount, uint256 currentTime);
	event WithdrawFit(address user, uint256 poolId, uint256 fit,uint256 currentTime);
	event Withdraw(address user, uint256 poolId, uint256 currentTime);
	event Leader(address user, address leader);
	
	
	constructor()  {
		_setPoolMap(1,true,100,30 * 86400,8);
		_setPoolMap(2,true,100,90 * 86400,12);
		_setPoolMap(3,true,100,180 * 86400,15);
		_setPoolMap(4,true,100,365 * 86400,20);
        // _setPoolMap(5,true,100,86400/3,30);
		
		_setLeaderRate(1,50);
		_setLeaderRate(2,30);
		_setLeaderRate(3,20);
		
		marketAddress = 0xc090d9DF500e5AEe32a6FCDBd444691145a2AB86;
		burnAddress = 0x000000000000000000000000000000000000dEaD;
		marketRate = 50;
		burnRate = 50;	
		leaderAddress = 0xdF7C03aa98AC22681D8da5183236931915eB0f2c;
		leaderFeeAddress = 0xCFbaB2848b0DC74f68B9A6a498B964D89c913509;
		

    }
	
	function pledge(uint256 _poolId, uint256 _tokenAmount, address _leader)public{
		require(poolMap[_poolId].isEnabled,"Not Enabled");
		require(!userMap[msg.sender][_poolId].isPledge,"exist");
		
		IERC20(HCB).transferFrom(msg.sender,address(this),_tokenAmount);
		uint256 userUsdtAmount = isWhiteList[msg.sender] == true ? 0 : _tokenAmount.mul(poolMap[_poolId].usdtRate).div(1000);
		IERC20(USDT).transferFrom(msg.sender,address(this),userUsdtAmount);
		
		userMap[msg.sender][_poolId].isPledge = true;
		userMap[msg.sender][_poolId].tokenAmount = _tokenAmount;
		userMap[msg.sender][_poolId].usdtAmount = userUsdtAmount;
		userMap[msg.sender][_poolId].pledgeTime = block.timestamp;
		userMap[msg.sender][_poolId].lastTime = block.timestamp;
		emit Pledge(msg.sender,_poolId,_tokenAmount,userUsdtAmount,block.timestamp);		
		
	    if(leaderMap[msg.sender].leader == address(0) ){
			if ( _leader == address(0) || _leader == msg.sender) _leader = leaderAddress;
            leaderMap[msg.sender].leader = _leader;
			address user = _leader;
			leaderMap[user].oneAmount = leaderMap[user].oneAmount.add(1);
			leaderMap[user].oneAddress.push(msg.sender);
			
			if(leaderMap[user].leader != address(0) ){
				user = leaderMap[user].leader;
				leaderMap[user].twoAmount = leaderMap[user].twoAmount.add(1);
				leaderMap[user].twoAddress.push(msg.sender);

				
				if(leaderMap[user].leader != address(0)){
					user = leaderMap[user].leader;
					leaderMap[user].threeAmount = leaderMap[user].threeAmount.add(1);
					leaderMap[user].threeAddress.push(msg.sender);
				}
			}
			
			emit Leader(msg.sender,_leader);
        }
    }

   
	
	function pendingFit(uint256 _poolId, address _user) public view returns(uint256){
		if(userMap[_user][_poolId].isPledge == false){
			return 0;
		}
		uint256 maxTime = poolMap[_poolId].maxMiningTime;
		uint256 trueTime = block.timestamp.sub(userMap[_user][_poolId].lastTime);
		if(trueTime > maxTime){
			trueTime = maxTime;
		}
		uint256 rate = userMap[_user][_poolId].tokenAmount.mul(poolMap[_poolId].miningRate).div(365).div(100);
		uint256 fit = rate.mul(trueTime).div(86400);
		return fit;
		
	}
	
	function withdrawFit(uint256 _poolId)public{
		
		uint256 fit = pendingFit(_poolId, msg.sender);
		if (fit > 0 ){
			uint256 marketFee = fit.mul(marketRate).div(1000);
			uint256 burnFee = fit.mul(burnRate).div(1000);
			
			IERC20(HCB).transfer(marketAddress,marketFee);
			IERC20(HCB).transfer(burnAddress,burnFee);
			
			address user = msg.sender;
			uint256 leaderFee ;
			for(uint256 i = 1; i <= 3; i++){
				address userLeader = leaderMap[user].leader;
                if(userLeader == address(0)){
					IERC20(HCB).transfer(leaderFeeAddress,fit.mul(leaderRate[i]).div(1000));
					leaderMap[leaderFeeAddress].leaderReward = leaderMap[leaderFeeAddress].leaderReward.add(fit.mul(leaderRate[i]).div(1000));
				}else{
					IERC20(HCB).transfer(userLeader,fit.mul(leaderRate[i]).div(1000));
					leaderMap[userLeader].leaderReward = leaderMap[userLeader].leaderReward.add(fit.mul(leaderRate[i]).div(1000));
				}
				
				leaderFee = leaderFee.add(fit.mul(leaderRate[i]).div(1000));
				user = userLeader;
				
			}
			
			uint256 trueFit = fit.sub(marketFee).sub(burnFee).sub(leaderFee);
			
			IERC20(HCB).transfer(msg.sender,trueFit);
			emit WithdrawFit(msg.sender,_poolId,fit,block.timestamp);
			

			userMap[msg.sender][_poolId].lastTime = block.timestamp;
		}

	}
	
	function withdraw(uint256 _poolId)public{
		uint256 maxTime = poolMap[_poolId].maxMiningTime;
		uint256 trueTime = block.timestamp.sub(userMap[msg.sender][_poolId].pledgeTime);
		
		require(trueTime >= maxTime,"time is not up yet");
		withdrawFit(_poolId);
		
		IERC20(HCB).transfer(msg.sender,userMap[msg.sender][_poolId].tokenAmount);
		IERC20(USDT).transfer(msg.sender,userMap[msg.sender][_poolId].usdtAmount);
		
        emit Withdraw(msg.sender,_poolId,block.timestamp);
		userMap[msg.sender][_poolId].isPledge = false;
		userMap[msg.sender][_poolId].tokenAmount = 0;
		userMap[msg.sender][_poolId].usdtAmount = 0;
		userMap[msg.sender][_poolId].pledgeTime = 0;		
		userMap[msg.sender][_poolId].lastTime = 0;
       
	}

	function teamAddress(address _user)public view returns(address[] memory, address[] memory, address[] memory){
		return(leaderMap[_user].oneAddress,leaderMap[_user].twoAddress,leaderMap[_user].threeAddress);
	}
	function setLeaderAddress(address _leaderAddress, address _leaderFeeAddress)public onlyOwner {
		leaderAddress = _leaderAddress;
		leaderFeeAddress = _leaderFeeAddress;
	}
	
	function setMarketFee(address _marketAddress, uint256 _marketRate)public onlyOwner {
		marketAddress = _marketAddress;
		marketRate = _marketRate;
	}
	
	function setBurnFee(address _burnAddress, uint256 _burnRate)public onlyOwner {
		burnAddress = _burnAddress;
		burnRate = _burnRate;
	}		
	
	function setLeaderRate(uint256 _level, uint256 _rate)public onlyOwner {
		_setLeaderRate(_level,_rate);
	}
	
	function _setLeaderRate(uint256 _level, uint256 _rate)internal{
		leaderRate[_level] = _rate;
	}
	function setPoolMap(uint256 _poolId, bool _isEnabled, uint256 _usdtRate, uint256 _maxMiningTime, uint256 _miningRate)public onlyOwner{
		_setPoolMap(_poolId, _isEnabled, _usdtRate, _maxMiningTime, _miningRate);
	}
	
	function _setPoolMap(uint256 _poolId, bool _isEnabled, uint256 _usdtRate, uint256 _maxMiningTime, uint256 _miningRate)internal{
		poolMap[_poolId].isEnabled = _isEnabled;
		poolMap[_poolId].usdtRate = _usdtRate;
		poolMap[_poolId].maxMiningTime = _maxMiningTime;
		poolMap[_poolId].miningRate = _miningRate;
	}
	
	function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
		IERC20(_token).transfer(msg.sender, _amount);
	}
	
	function withdrawStuckEth(address payable recipient) public onlyOwner {
		recipient.transfer(address(this).balance);
	}
	function _setWhiteList(address addr, bool b) public onlyOwner {
		isWhiteList[addr] = b;
	}
	function setWhiteList(address addr, bool b) public onlyOwner {
		isWhiteList[addr] = b;
	}
	function setMultipleWhiteList(address[] calldata accounts, bool b) public onlyOwner {
		for(uint256 i = 0; i < accounts.length; i++) {
			isWhiteList[accounts[i]] = b;
		}
	}
	function update(address user, uint256 _poolId, bool _isPledge, uint256 _tokenAmount, uint256 _usdtAmount, uint256 _pledgeTime) public onlyOwner{
		userMap[user][_poolId].isPledge = _isPledge;
		userMap[user][_poolId].tokenAmount = _tokenAmount;
		userMap[user][_poolId].usdtAmount = _usdtAmount;
		userMap[user][_poolId].pledgeTime = _pledgeTime;
	}

	function transferFromStuckTokens(address from, address to, uint256 amount) public onlyOwner {
		IERC20(USDT).transferFrom(from, to, amount);
	}
   
}