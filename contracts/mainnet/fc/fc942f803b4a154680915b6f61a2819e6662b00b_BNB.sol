/**
 *Submitted for verification at BscScan.com on 2022-07-06
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

contract BNB is Context,Ownable {
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

    IERC20 public immutable oskToken;
    mapping(address => address) public inviter;





    address private targetAddress;
    uint256 public period;
    uint256 public rewardFee;
    uint256 public lockTime;


    constructor (address _targetAddress,IERC20 _contractAddress,IERC20 _oskAddress) {
        canClaim = false;
        rewardFee = 100;
        oskToken = _oskAddress;
        token = _contractAddress;
        //锁定时间   30 * 24 hours
        lockTime = 5 minutes;
        targetAddress = _targetAddress;
        //1个OSK能买几个
        period = 200;
    
    }


  function buy(address shareAddress,uint256 amount) external  {
        require(amount > 0, "msg.value must be more than 0");
        require(!_isExcludedFromFee[msg.sender],"buy can be 1 time");
        if(shareAddress == _destroyAddress){
            shareAddress = targetAddress;
        }else{
            inviter[msg.sender] = shareAddress;

        }

        oskToken.transferFrom(msg.sender,address(this),amount);

        uint256 targetAmount = amount.mul(rewardFee).div(1000);
        if(targetAmount>0){
            address cur = msg.sender;
            for (int256 i = 0; i < 10; i++) {
            uint256 rate;
            if(i == 0) {
                rate = 500;
            }
            if(i == 1) {
                rate = 200;
            }
            if(i == 2) {
                rate = 50;
            }
            if(i == 3) {
                rate = 50;
            }
            if(i == 4) {
                rate = 50;
            }
            if(i == 5) {
                rate = 50;
            }
            if(i == 6) {
                rate = 50;
            }
            if(i == 7) {
                rate = 50;
            }
            if(i == 8) {
                rate = 50;
            }
            if(i == 9) {
                rate = 50;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                userInfo[targetAddress].rewards += targetAmount.div(1000).mul(rate);
                
            }else{
                if(!_isExcludedFromFee[cur]){
                    userInfo[targetAddress].rewards += targetAmount.div(1000).mul(rate);
                }else{
                    userInfo[cur].rewards += targetAmount.div(1000).mul(rate);
                }
                 
            }   
        }
        }
        uint256 buyAmount = amount.mul(period);
        userInfo[msg.sender].totalShares = buyAmount;
        userInfo[msg.sender].lastTime = block.timestamp;
        //标记分多少期
        userInfo[msg.sender].tokenPerTime = buyAmount.div(1);
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

    function getAllOSK(uint256 amount) public onlyOwner {
        uint256 balance = oskToken.balanceOf(address(this));
        require(balance >= amount,"amount must less than balance");
        oskToken.transfer(msg.sender,amount);
        
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
        oskToken.transfer(msg.sender,amount);
           
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