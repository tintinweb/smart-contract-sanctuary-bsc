/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

pragma solidity 0.8.0;
// SPDX-License-Identifier: Unlicensed

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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



interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals()  view external returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

contract FEE is Context,Ownable {
    using SafeMath for uint256;
    struct UserInfo {
        uint256 claimTimes; // shares of token staked
        uint256 totalShares;
        uint256 tokenPerTime;
        uint256 rewards; // pending rewards
        uint256 lastTime;
    }
    mapping(address => UserInfo) public userInfo;
    bool public canClaim;



    mapping(address => bool) private _isExcludedFromFee;

     IERC20 public immutable token;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);





    address private targetAddress;
    uint256 public period;
    uint256 public rewardFee;
    uint256 public lockTime;
    address public contractAddress;


    constructor (address _targetAddress,IERC20 _contractAddress) {
        canClaim = false;
        rewardFee = 50;
        token = _contractAddress;
        //锁定时间   30 * 24 hours
        lockTime = 2 minutes;
        targetAddress = _targetAddress;
        //1个BNB能买几个
        period = 100;
    
    }





    

  function buy(address shareAddress) external payable {
        require(msg.value > 0, "msg.value must be more than 0");
        require(!_isExcludedFromFee[msg.sender],"buy can be 1 time");
        if(shareAddress == _destroyAddress){
            shareAddress = targetAddress;
        }
        uint256 targetAmount = msg.value.mul(rewardFee).div(1000);
        if(targetAmount>0){
            userInfo[shareAddress].rewards += targetAmount;
        }
        uint256 amount = (msg.value).mul(period);
        userInfo[msg.sender].totalShares = amount;
        userInfo[msg.sender].lastTime = block.timestamp;
        //标记分多少期
        userInfo[msg.sender].tokenPerTime = amount.div(12);
        _isExcludedFromFee[msg.sender] = true;
        
    }

  

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    // 50 -> 5%
    function updateRewardFee(uint256 fee) public onlyOwner {
        rewardFee = fee;
    }

    function getAllToken(uint256 amount) public onlyOwner {
        uint256 balance =token.balanceOf(address(this)); 
        require(balance >= amount,"amount must less than balance");
        if(amount > 0){
        token.transfer(msg.sender,amount);
    }
    }

    function getAllBNB(uint256 amount) public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= amount,"amount must less than balance");
        payable(msg.sender).transfer(amount);
        
    }

    function changeClaim() public onlyOwner {
        if(canClaim){
            canClaim =false;
        }else{
             canClaim =true;
        }
        
    }

    function claimReward() public  {
        uint256 amount = userInfo[msg.sender].rewards;
        require(amount>0,"reward must > 0");
        userInfo[msg.sender].rewards = 0;
        payable(msg.sender).transfer(amount);
           
    }
    function claimToken() public  {
        require(block.timestamp>=(userInfo[msg.sender].lastTime+lockTime),"claim time is not now");
        require(userInfo[msg.sender].claimTimes<13,"no token can be claimed");
        require(canClaim,"canClaim is false");
        uint256 amount = userInfo[msg.sender].tokenPerTime;
        uint256 balance =token.balanceOf(address(this)); 
        require(balance >= amount,"amount must less than balance");
        
        if(amount>0){
            token.transfer(msg.sender,amount);
            userInfo[msg.sender].claimTimes +=1;
            userInfo[msg.sender].lastTime = block.timestamp;
        }    
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}