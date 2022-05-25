/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;

        require(c / a == b);

        return c;
    }

    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);

        uint256 c = a - b;

        return c;
    }

    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;

        require(c >= a);

        return c;
    }

    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);

        return a % b;
    }
}

contract Ownable   {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {
        return _owner;
    }

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}


contract NFT_Membership is Ownable{
    using SafeMath for uint256;
  

 
     event Deposite_(address indexed to,address indexed From, uint256 amount, uint256 day,uint256 time);

    
    struct user {
        uint256 plan;
        uint256 buyingTime;
        uint256 expirationTime;
        bool active;
    }

    mapping(uint256 => uint256) public allocation;
    mapping(uint256 => string) public NFTCARD;
    mapping(uint256 => uint256) public Assetprice;
    mapping(address => user) public userInfo;

    uint NFTId;
    uint assetpid;

    uint256 time = 1 minutes;

    constructor()  {
        allocation[1] = 1 minutes; 
        allocation[2] = 2 minutes; 
        allocation[3] = 3 minutes; 
    
        NFTCARD[1] = "Regular";   
        NFTCARD[2] = "Gold";  
        NFTCARD[3] = "Diamond";   
        NFTId = 4;
        Assetprice[1]=100000000000000000; //0.1 ether
        Assetprice[2]=200000000000000000; // 0.2 ether
        Assetprice[3]=300000000000000000; // 0.3 ether
        assetpid=4;


    }

    function buyNFTMembership(uint256 _plan) external payable onlyOwner{
        // require(_plan==allocation[1]||_plan==allocation[2]||_plan==allocation[3],"Plan is not exist");
        require(checkRemainingTime(msg.sender)==false,"User already have membership");
        require(msg.value==Assetprice[_plan],"insufficient Amount for Buying desitred Membership");
        userInfo[msg.sender].plan=_plan;
        userInfo[msg.sender].buyingTime=block.timestamp;
        userInfo[msg.sender].expirationTime=allocation[_plan].add(block.timestamp);
        userInfo[msg.sender].active=true;
        }
        
    function checkRemainingTime(address _user) public view returns(bool ){
        bool status=false;
        if(userInfo[_user].buyingTime>0){
    
            if(userInfo[_user].expirationTime>=block.timestamp){
                 status=true;
                      }
            else{
                status=false;
                      }
        }
        return status;

    }    
        
    

      //  owner can register new NFT membership card ids
    function registerNFTMemberships(string memory name,uint256 price) public onlyOwner {
        NFTCARD[NFTId]=name;
        Assetprice[assetpid]=price;
        NFTId++;
        assetpid;        
    }
    // owner can updates the name and price for each id
    function updateCardmetadata(string memory _name,uint256 _id,uint256 _price) external onlyOwner{
        NFTCARD[_id]=_name;
        Assetprice[_id]=_price;
    }
    //owner can change the plan possition and days
    function changeplan(uint256 allocationNumber,uint256  _plan) external onlyOwner{
        allocation[allocationNumber]=_plan * 1 days;
    }



   
    function emergencyWithdraw(address WORTHWHILEAmount,uint256 _amount) public onlyOwner {
         IERC20(WORTHWHILEAmount).transfer(msg.sender, _amount);
    }
    function emergencyWithdrawBNB(uint256 Amount) public onlyOwner {
        payable(msg.sender).transfer(Amount);
    }
    
}