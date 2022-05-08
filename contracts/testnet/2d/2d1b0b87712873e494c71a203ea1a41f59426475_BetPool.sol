/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity ^0.5.0;

library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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
        // Solidity only automatically asserts when dividing by 0
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
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */


    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
       //------ require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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


contract BetPool  {
    
    using SafeERC20 for IERC20;
    uint256 public total_deposits=1000000000000;
    uint256 public total_usd=1000000;
    using SafeMath for uint;
    IERC20 m=IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 u=IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address owner;
    
	struct User { 
        uint256 deposits;
        uint256 reward;
        address leader; 
        uint256 ls;
    } 
    
    constructor() public{
        owner=msg.sender;
    }
    
    modifier admin{
        require(owner==msg.sender,"no permission");
        _;
    }


    event Staked(address indexed user, uint256 amount);
    event betBtc(address indexed  user, uint256 fx,uint256 amount);
    event inPool(address indexed user,uint256 amount);
    event outPool(address indexed user,uint256 amount);
    event getwin(address indexed user,uint256 amount);

    mapping(address => User) users;
    function betbtc(uint256 fx,uint256 amount, address tj) public 
    {
        require(amount > 99999, "Cannot BET 1"); 
        require(fx > 0, "Cannot BET 0"); 
        require(amount <1000000001, "Cannot BET 1000"); 
        if( users[msg.sender].leader!=address(0))
        {
            u.safeTransferFrom(msg.sender,address(this),amount);
            total_usd=total_usd.add(amount);
            address leadera=users[msg.sender].leader;
            users[msg.sender].ls=users[msg.sender].ls.add(amount);
            if(leadera!=address(0))
            {
                users[leadera].reward+=amount/100;
                address leaderb=users[leadera].leader;
                 if(leaderb!=address(0))
                {
                users[leaderb].reward+=amount/100;
                address leaderc=users[leaderb].leader;
                 if(leaderc!=address(0))
                   {
                    users[leaderc].reward+=amount/100; 
                  }

                }

            }
            
            emit betBtc(msg.sender,fx, amount);
        }
        else
        {

            u.safeTransferFrom(msg.sender,address(this),amount);
            users[msg.sender].leader=tj;
            total_usd=total_usd.add(amount);
            users[msg.sender].ls=users[msg.sender].ls.add(amount);
            emit betBtc(msg.sender,fx, amount);
        }
    }
    function inpool(uint256 amount) public 
    {
        require(amount > 0, "Cannot BET 0");  
        
            u.safeTransferFrom(msg.sender,address(this),amount);
            uint256 tempunit=amount*total_deposits/total_usd;
            users[msg.sender].deposits+=tempunit;
            total_usd=total_usd.add(amount);
            total_deposits+=tempunit;
            emit inPool(msg.sender, amount);
    }
    function outpool(uint256 amount) public 
    {
        require(amount > 0, "Cannot BET 0");  
            uint256 tempunit=total_usd*1000000000000/total_deposits;
            uint256 tempdeposits=amount*1000000000000/tempunit;
            if(users[msg.sender].deposits>=(tempdeposits))
            {
                users[msg.sender].deposits=users[msg.sender].deposits.sub(tempdeposits);
                total_usd=total_usd.sub(amount);
                total_deposits=total_deposits.sub(tempdeposits);
                u.safeTransfer(msg.sender,amount);
                emit outPool(msg.sender, amount);
            }
    }
    function getrewardbyaddress(address _u) public view  returns(uint256) {
        uint256 amount=users[_u].reward;
        return amount;
    }
    function getrtotalusd() public view  returns(uint256) {
        
        return total_usd;
    }
    function getreward()  external  returns(uint256) {
        require(users[msg.sender].reward>0,"rd error!");
        require(users[msg.sender].ls>0,"ls error!");
            if(users[msg.sender].ls>=(users[msg.sender].reward*10))
            {
                
               uint256 temreword=users[msg.sender].reward;
               users[msg.sender].reward=0;
               users[msg.sender].ls=users[msg.sender].ls.sub(temreword*10);
               u.safeTransfer(msg.sender,temreword);
            }
            else
            {
               uint256 temreword=users[msg.sender].ls.div(10);
               require(users[msg.sender].reward>temreword,"ls error!");
               
               users[msg.sender].reward=users[msg.sender].reward.sub(temreword);
               users[msg.sender].ls=0;
               u.safeTransfer(msg.sender,temreword);
                 
            }

        //require(block.timestamp-users[msg.sender].profit_time>=8640000,"Already get!");
         
    }
    function getrewardfroozen(address _u)  public view  returns(uint256 _rewardf,uint256 _reward) {
        if(users[_u].reward>0)
        {
            if(users[_u].ls>=(users[_u].reward*10))
            {
               _reward=users[_u].reward;
               _rewardf=0;
            }
            else
            {
                _reward=users[_u].ls/10;
                _rewardf=users[_u].reward-_reward;
            }
        }
        else
        {
            _reward=0;
            _rewardf=0;  
        }
 
        
        
    }
    function getdes(address _u)  public view  returns(uint256 ublancesa) {
 
        uint256 ublances=u.balanceOf(_u); 
         
        return ublances;
    }
    function getrewardusd(address _u)  public view  returns(uint256 ublancesa) {
 
        uint256 tempunit=total_usd*1000000000000/total_deposits;
       
        return  users[_u].deposits*tempunit/1000000000000;
    }
     function getrewardsalowb(address _u)  public view  returns(uint256 alowbs) {
 
        uint256 alowb=u.allowance(_u,address(this)); 
        return alowb; 
    }

     function setU(IERC20 tokenaddress) public admin returns(bool success) { 
          u=tokenaddress;
          return true;
    }
         function winreward(address _useraddress,uint256 _amount) public admin returns(bool success) { 
          total_usd-=_amount;
          u.safeTransfer(_useraddress,_amount);
          return true;
    }
     function setleader(address _address) public  returns(address) {
          require(_address!=address(0),"this address error");
          if(users[msg.sender].leader!=address(0))
           {users[msg.sender].leader = _address;}
                  
          return _address;
      }
   
    function userinfo(address _address) view external returns(uint256 _deposits,uint256 _reward 
    ,uint256 _ls,uint256 _all_deposits,address _leader)
    {
        _deposits=users[_address].deposits;
        _reward=users[_address].reward;
        _ls=users[_address].ls;
        _all_deposits=total_deposits;
        _leader=users[_address].leader;
    }
}