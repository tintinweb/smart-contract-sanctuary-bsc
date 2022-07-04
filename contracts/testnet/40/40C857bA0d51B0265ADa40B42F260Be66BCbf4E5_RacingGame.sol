// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath 
{

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

contract RacingGame
{
    using SafeMath for uint256;
    struct userinfo
    {
       uint256 totalpoint;
       uint256 totalclaim;
       string email;
    }

    mapping(address => userinfo) userdetails;
    mapping(string => address) useraddress;
    uint256 tokenValue;
    address token;
    address owner;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    constructor(address _address,address _owner)
    {
       token = _address;
       owner = _owner;
       tokenValue = 1;
    }

    function fundAccount(uint256 amount,string memory email) external 
    {
       require(IERC20(token).allowance(msg.sender,address(this)) >= amount,"allowance is not enough");
       IERC20(token).transferFrom(msg.sender,address(this),amount);
       userdetails[msg.sender].totalpoint =userdetails[msg.sender].totalpoint + amount;
       userdetails[msg.sender].email=email; 
       useraddress[email] = msg.sender;
    }

    function claminToken(uint256 amount) external
    {
       require((userdetails[msg.sender].totalpoint.div(tokenValue))>=amount,"you don't have balance"); 
       userdetails[msg.sender].totalclaim+=amount;
       userdetails[msg.sender].totalpoint = userdetails[msg.sender].totalpoint.sub(amount);
       IERC20(token).transfer(msg.sender,amount);
    } 
    
    function gameResult(address[] memory _participents,uint256 _fees) 
      external
      onlyOwner
    {
        for(uint256 i=0;i<_participents.length;i++)
        {
          userdetails[(_participents[i])].totalpoint = userdetails[(_participents[i])].totalpoint.add(_fees);
        }
    }
    
    function feesCutting(address[] memory _participents,uint256 _fees)
       external
       onlyOwner
    {
        for(uint256 i=0;i<_participents.length;i++)
        {
          require(userdetails[msg.sender].totalpoint>=_fees,"you don't have balance");   
          userdetails[(_participents[i])].totalpoint = userdetails[(_participents[i])].totalpoint.sub(_fees);
        }
    }
    
    function settokenvalue(uint256 value) external onlyOwner
    {
        tokenValue = value;
    }

    function updateOwner(address _address) external onlyOwner
    {
        owner = _address;
    }

    function getuserinformation(address _address) external view returns(userinfo memory)
    {
        return userdetails[_address];
    }

    function getuserbalance(address _address) external view returns(uint256)
    {
        return userdetails[_address].totalpoint;
    }

    function getaddressfromemail(string memory _email) external view returns(address)
    {
        return useraddress[_email];
    }
}