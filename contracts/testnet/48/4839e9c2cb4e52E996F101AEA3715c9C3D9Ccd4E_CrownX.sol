/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/**
 *Submitted for verification at Etherscan.io on 2020-05-28
*/

pragma solidity 0.5.10;


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
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/[email protected]`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/[email protected]`.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract CrownX {
    
    using SafeMath for *;
   
    address payable public  ownerWallet;
    address payable public  admin; //5%
   
    
   struct UserStruct {

        bool isExist;
        uint id;
     
    }

    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    uint public currUserID = 0;

   	event Registration(uint256  member_name, string  sponcer_id,address indexed sender,uint256 package);
    event Withdraw(address indexed  member_name,uint256 withAmt);
    event AdminPayment(string  member_name, string  current_level,address indexed sender);

    constructor(address payable _owner, address payable _admin) public {
        ownerWallet = msg.sender;
        admin = _admin;
    
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID
        });
        users[_owner] = userStruct;
        userList[currUserID] = _owner;

    }

    
    function NewRegistration(string memory sponcer_id,uint256 ownerAmt,uint256 adminAmt) public payable {
       
        require(!users[msg.sender].isExist, 'User exist');
        require (msg.value>=75*1e15,"invalid amt");

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        ownerWallet.transfer(ownerAmt);
        admin.transfer(adminAmt);
		emit Registration(currUserID, sponcer_id,msg.sender,msg.value);

    }
    
    function BuyNextMatrix(string memory member_name, string memory current_level,uint256 ownerAmt,uint256 adminAmt) public payable
	{
		 ownerWallet.transfer(ownerAmt);
        admin.transfer(adminAmt);
		emit AdminPayment(member_name, current_level,msg.sender);
	}


      function multisendBNB(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
            
        }
	
    }

     function multisendBNBOwner(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        require(msg.sender == ownerWallet, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
             _contributors[i].transfer(_balances[i]);
             emit Withdraw(_contributors[i],_balances[i]);
        }
	
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    
     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) external {
        
        require(msg.sender == ownerWallet,"You are not authorized");
        _transferOwnership(newOwner);
    }

     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "New owner cannot be the zero address");
       // emit OwnershipTransferred(ownerWallet, newOwner);
        ownerWallet = newOwner;
    }
    function withdrawLostTRXFromBalance() public payable{
        require(msg.sender == ownerWallet, "onlyOwner");
        msg.sender.transfer(address(this).balance);
    }
}