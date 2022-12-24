/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

/**
 *Submitted for verification at polygonscan.com on 2021-07-27
*/
// SPDX-License-Identifier: MIT 

pragma solidity 0.8.4;

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
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

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract BEATSPresaleRef{
    using SafeMath for uint256;
    address public owner;
    address public mktAddress;
    IERC20 public token;
    uint256 public _price = 3000000000000000 wei;
    uint256 public presaleTimeEnds;
    uint256 public totalTokenSold;
    uint256 public normalSaleSold = 0;
    uint256 private referrerComissionVal = 10;

    constructor(address _token , uint256 endTime){
        owner = msg.sender;
        mktAddress = msg.sender;
        token = IERC20(_token);
        presaleTimeEnds = endTime;
    }
  

    struct User {
        uint256 invest;
        address referrals;
        uint256 referrer;
        uint256 amountBNBReferrer;
    }

    mapping (address => User) public users;
    uint public totalInvested;

    modifier IsOwner{
        require(msg.sender == owner);
        _;
    }
  
    function changePrice(uint256 price) public {
        require(msg.sender == owner,"You are not authorized");
        _price = price;
    }

    function referrerCommission(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(_amount, referrerComissionVal), 100);
    }

    function safeTransferTokens(uint256 noOfTokens)internal{
        require(getTokenBalance()>= noOfTokens,"Contract has no balance");

        token.transfer(msg.sender,noOfTokens);
        totalTokenSold = totalTokenSold.add(noOfTokens);
    }

    function buyToken(address ref) public payable {
        User storage user = users[msg.sender];
        if (ref == msg.sender) {
            user.referrals = mktAddress;
        } else if (user.referrals == address(0)) {
            user.referrals = ref;
            users[ref].referrer = users[ref].referrer.add(1);
        }
        payCommision(users[ref]);
        uint256 noOfTokens = calculateTokens(msg.value);
        safeTransferTokens(noOfTokens);
    }

    function payCommision(User storage user) private {
        uint256 amountReferrer = referrerCommission(msg.value);
        if (user.referrals != msg.sender && user.referrals != address(0)) {
            users[user.referrals].amountBNBReferrer = SafeMath.add(
                users[user.referrals].amountBNBReferrer,
                amountReferrer
            );
            payable(user.referrals).transfer(amountReferrer);
        }
    }

    function calculateTokens (uint256 amount ) public view returns(uint256){
            return amount.mul(10**18).div(_price);
    }

    // this fucntion is used to check how many fokitos are remaining in the contract
    function getTokenBalance() public view returns(uint256){
        return  token.balanceOf(address(this));
    }
    
    // this fucntion is used to check how many ethers are there in the contract

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    
    // use this fuction for withdrawing all the unsold tokens

    function withdrawTokens( ) public{
        require(msg.sender == owner,"You are not the owner");
        token.transfer(owner,getTokenBalance());
        
    }

    // use this fuction for withdrawing all the ethers
    function withdrawBalance( ) public{
        require(msg.sender == owner,"You are not the owner");
        payable(msg.sender).transfer(getContractBalance());
    }

    function sendReferral(address ref) private{
        payable(ref).transfer(msg.value /10);
    }
    // you can extend or shrink the presale time 

    function changePresaleEndTime(uint256 time) public{
        require(msg.sender == owner,"You are not the owner");
        presaleTimeEnds = time;
        
    }

    function userData(address user_)
        external
        view
        returns (
            address referrals_,
            uint256 referrer,
            uint256 referrerBNB
        )
    {
        User memory user = users[user_];
        referrals_ = user.referrals;
        referrer = user.referrer;
        referrerBNB = user.amountBNBReferrer;
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