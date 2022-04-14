/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


abstract contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

   
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

contract singleStake is Ownable {

    using Address for address;

    using SafeMath for uint256;

    address private tokenContract;

    uint256 private minStakeAmt;

    uint256 private minStakeTime;

    uint256 private stakeYield;

    uint256 private rewardYield;

    
    mapping (address => uint256) public stakeAmts;

    mapping (address => uint256) public stakeTimes;


    constructor (address _tokenAddress, 
                    uint256 _minStakeAmt, 
                    uint256 _minStakeTime,
                    uint256 _stakeYield, 
                    uint256 _rewardYield
                    ) {
        tokenContract = _tokenAddress;
        minStakeAmt = _minStakeAmt;
        minStakeTime = _minStakeTime;
        stakeYield = _stakeYield;
        rewardYield = _rewardYield;
    }



    function stake(address stakeUserAddress, uint256 amount) public returns (bool) {
        bytes memory data = abi.encodeWithSelector(IERC20.transferFrom.selector, stakeUserAddress, owner() , amount);
        tokenContract.functionCall(data,"TransferHelper: TRANSFER_FAILED");
        uint256 stakeAmt = stakeAmts[stakeUserAddress];
        stakeAmts[stakeUserAddress] = stakeAmt.add(amount);
        stakeTimes[stakeUserAddress] = getBlockTimestamp();
        return true;
    }


    function unStake(address stakeUserAddress, uint256 amount) public returns (bool) {
        uint256 stakeAmt = stakeAmts[stakeUserAddress];
        stakeAmts[stakeUserAddress] = stakeAmt.sub(amount);
        bytes memory data = abi.encodeWithSelector(IERC20.transferFrom.selector, owner() , stakeUserAddress , amount);
        tokenContract.functionCall(data,"TransferHelper: TRANSFER_FAILED");
        return true;
    }

    function claim(address stakeUserAddress) public returns (uint256) {
        uint256 stakeAmt = stakeAmts[stakeUserAddress];
        require(stakeAmt >= minStakeAmt,"Less than min stake amount, no income");
        uint256 stakeTime = stakeTimes[stakeUserAddress];
        uint256 myNow = getBlockTimestamp();
        uint256 betweenTime = myNow.sub(stakeTime);
        require(betweenTime >= 600,"Less than min stake time, no income");
        uint256 rate = stakeYield.add(rewardYield).div(100);
        uint256 realRate = betweenTime.div(31536000).mul(rate);
        uint256 rewardAmt = realRate.mul(stakeAmt);
        bytes memory data = abi.encodeWithSelector(IERC20.transferFrom.selector, owner() , stakeUserAddress , rewardAmt);
        tokenContract.functionCall(data,"TransferHelper: TRANSFER_FAILED");
        stakeTimes[stakeUserAddress] = myNow;
        return rewardAmt;
    }


    function getIncome(address stakeUserAddress,uint myNow) public view returns (uint256) {
        uint256 stakeAmt = stakeAmts[stakeUserAddress];
        require(stakeAmt >= minStakeAmt,"Less than min stake amount, no income");
        uint256 stakeTime = stakeTimes[stakeUserAddress];
        uint256 betweenTime = myNow.sub(stakeTime);
        require(betweenTime >= 600,"Less than min stake time, no income");
        uint256 rate = stakeYield.add(rewardYield).div(100);
        uint256 realRate = betweenTime.div(31536000).mul(rate);
        uint256 rewardAmt = realRate.mul(stakeAmt);
        return rewardAmt;
    }



    function setTokenContract(address myTokenContract) public onlyOwner  {
        tokenContract = myTokenContract;
    }

    function getTokenContract() public view onlyOwner returns (address)  {
       return tokenContract;
    }


    function setMinStakeAmt(uint256 myMinStakeAmt) public onlyOwner  {
        minStakeAmt = myMinStakeAmt;
    }

    function getMinStakeAmt() public view onlyOwner returns (uint256)  {
       return minStakeAmt;
    }


    function setMinStakeTime(uint256 myMinStakeTime) public onlyOwner  {
        minStakeTime = myMinStakeTime;
    }

    function getMinStakeTime() public view onlyOwner returns (uint256)  {
       return minStakeTime;
    }

    
     function setStakeYield(uint256 myStakeYield) public onlyOwner  {
        stakeYield = myStakeYield;
    }

    function getStakeYield() public view onlyOwner returns (uint256)  {
       return stakeYield;
    }


     function setRewardYield(uint256 myRewardYield) public onlyOwner  {
        rewardYield = myRewardYield;
    }

    function getRewardYield() public view onlyOwner returns (uint256)  {
       return rewardYield;
    }

    function getBlockTimestamp() internal virtual returns(uint) {
        // 获取当前块的Unix时间戳
        return block.timestamp;
    }

}