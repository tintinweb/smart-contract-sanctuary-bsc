/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.23 <0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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

contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
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

contract MoneyRain is Ownable {    
  
    using SafeMath for *;
    IBEP20 public tokenibep;    
    address payable public owner;    
    uint256 public donation = 30*10**18;
    uint256 public direct_donation = 1*10**18;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;            
    }

    //mapping(address => User) public users;
    mapping (address => User) internal users;
    mapping(uint => address) internal idToAddress;

    event NewDeposit(address indexed user, address indexed owner,uint256 amount,uint256 timeStamp);
    event DirDonation(address indexed owner,address indexed user,uint256 amount,uint256 timeStamp);       
    event ReDeposit(address indexed user, address indexed owner,uint256 amount,uint256 timeStamp);
   
    constructor (address payable ownerAddress, address _token) public { 
        owner = ownerAddress;
        tokenibep = IBEP20(_token);  
               
        users[ownerAddress].id = 1;
        users[ownerAddress].referrer = address(0);
        users[ownerAddress].partnersCount = uint(0);

        idToAddress[1] = ownerAddress; 

    }
    
    
    function mRactivation(address referrerAddress,uint256 lastUserId) public payable {
          
        require(isUserExists(referrerAddress), "referrer not exists");
             
        users[msg.sender].id = lastUserId;
        users[msg.sender].referrer = referrerAddress;
        users[msg.sender].partnersCount = 0;       
        
        
        idToAddress[lastUserId] = msg.sender;   

       // sendETHDividends(msg.sender,);
        //users[referrerAddress].partnersCount = users[referrerAddress].partnersCount.add(1);

        tokenibep.transferFrom(msg.sender,owner,donation);   
        emit NewDeposit(msg.sender,owner,donation,block.timestamp);

        //tokenibep.transferFrom(owner,referrerAddress,direct_donation);
        //emit DirDonation(referrerAddress,owner,direct_donation,block.timestamp);

    }

     

    
    function withdrawal() public payable {   
     
     //address payable receiver = address(uint160(msg.sender));
     //tokenDai.transferFrom(_wallet,receiver,msg.value);

    }	

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    

    function setTokenAddress(address _token) public onlyOwner returns(bool)
    {
        tokenibep = IBEP20(_token);
        return true;
    }  

}