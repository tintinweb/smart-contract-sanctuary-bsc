/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-24
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
		uint256 maxMiningTime;
		uint256 miningRate;
	}
	mapping(uint256 => PoolInfo)public poolMap;
	struct UserPool{
		bool isPledge;
		uint256 tokenAmount;
		uint256 pledgeTime;
	}
	mapping(address => mapping(uint256 => UserPool)) public userMap;
	
	
	address public PAL = 0xD4cebCeD3c3cba3B34ad0400C68D557CD4d220B2;
	
	
	event Pledge(address user, uint256 poolId, uint256 tokenAmount);
	event Withdraw(address user, uint256 poolId, uint256 fit);
	
	
	constructor()  {
		_setPoolMap(1,true,30 * 86400,15);
		_setPoolMap(2,true,90 * 86400,40);
		_setPoolMap(3,true,180 * 86400,80);
		_setPoolMap(4,true,270 * 86400,150);
		_setPoolMap(5,true,365 * 86400,300);
    }
	
	
	function pledge(uint256 _poolId, uint256 _tokenAmount)public{
		require(poolMap[_poolId].isEnabled,"Not Enabled");
		require(!userMap[msg.sender][_poolId].isPledge,"exist");
		IERC20(PAL).transferFrom(msg.sender,address(this),_tokenAmount);
		userMap[msg.sender][_poolId].isPledge = true;
		userMap[msg.sender][_poolId].tokenAmount = _tokenAmount;
		userMap[msg.sender][_poolId].pledgeTime = block.timestamp;
		emit Pledge(msg.sender,_poolId,_tokenAmount);		
		
	}
	
	function pendingFit(uint256 _poolId, address _user) public view returns(uint256){
		if(userMap[msg.sender][_poolId].isPledge == false){
			return 0;
		}
		uint256 maxTime = userMap[msg.sender][_poolId].pledgeTime.add(poolMap[_poolId].maxMiningTime);
		uint256 trueTime = block.timestamp.sub(userMap[_user][_poolId].pledgeTime);
		if(trueTime > maxTime){
			trueTime = maxTime;
		}
		uint256 rate = userMap[_user][_poolId].tokenAmount.mul(poolMap[_poolId].miningRate).div(100);
		uint256 fit = rate.mul(trueTime).div(365 * 86400) ;
		return fit;
		
	}
	
	function withdraw(uint256 _poolId)public{
		uint256 maxTime = userMap[msg.sender][_poolId].pledgeTime.add(poolMap[_poolId].maxMiningTime);
		uint256 trueTime = block.timestamp.sub(userMap[msg.sender][_poolId].pledgeTime);
		
		require(trueTime >= maxTime,"time is not up yet");
		uint256 fit = pendingFit(_poolId, msg.sender);
		IERC20(PAL).transfer(msg.sender,fit);
        IERC20(PAL).transfer(msg.sender,userMap[msg.sender][_poolId].tokenAmount);
		emit Withdraw(msg.sender,_poolId,fit);
		
		userMap[msg.sender][_poolId].isPledge = false;
		userMap[msg.sender][_poolId].tokenAmount = 0;
		userMap[msg.sender][_poolId].pledgeTime = 0;
	}
	
	function setPoolMap(uint256 _poolId, bool _isEnabled, uint256 _maxMiningTime, uint256 _miningRate)public onlyOwner{
		_setPoolMap(_poolId, _isEnabled, _maxMiningTime, _miningRate);
	}
	
	function _setPoolMap(uint256 _poolId, bool _isEnabled, uint256 _maxMiningTime, uint256 _miningRate)internal{
		poolMap[_poolId].isEnabled = _isEnabled;
		poolMap[_poolId].maxMiningTime = _maxMiningTime;
		poolMap[_poolId].miningRate = _miningRate;
	}
	
	function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
		IERC20(_token).transfer(msg.sender, _amount);
	}
	
	function PayTransfer(address payable recipient) public onlyOwner {
		recipient.transfer(address(this).balance);
	}
	
   
}