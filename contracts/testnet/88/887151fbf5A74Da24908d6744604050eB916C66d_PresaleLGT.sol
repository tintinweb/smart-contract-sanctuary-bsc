/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 interface BEP20Interface {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function balanceOf(address account) external view returns (uint256);
}



contract PresaleLGT {
	using SafeMath for uint256;

	address payable ownerAddress;
    uint256 public REFERRAL_EARNINGS = 5*1e18;
    BEP20Interface public tokenAddress=BEP20Interface(0x0c348857F85006FBa3461d0e0Bcbc181BC08E6F8);
    uint256 public priceInUsdt;

    bool public isRunningSwap=true;
    mapping(address=>address) public referral;

    event buy(address indexed user,address indexed referral,uint256 priceInUsdt,uint256 tokens);
    

	constructor(address payable marketingAddr) {
		ownerAddress = marketingAddr;
		referral[ownerAddress] = ownerAddress;
		priceInUsdt = 10**18;
	}
	
	
	/*******Swapping ********/
	  function setPrice(uint256 amount) public
    {
        require(msg.sender==ownerAddress,"Invalid user");
        require(amount>0,"Invalid amount or plan");
        priceInUsdt=amount;
    }
    
	
	//type 0 for buy 
    //type 1 for toBUSD 
    //type 2 for toUSDT 
    
    
    function exchange(address refAddress) public payable
    {
        uint256 amount = msg.value;
        require(amount>0,"Invalid Amount");
        address payable userAddress = payable(msg.sender);
        if(referral[msg.sender]==address(0) && refAddress!=msg.sender)
        {
            referral[msg.sender] = refAddress;
        }
        uint256 tokenAmount=amount.mul(1e18).div(priceInUsdt);
        require(BEP20Interface(address(tokenAddress)).transfer(address(userAddress),tokenAmount),"Token transfer failed");
        if(referral[msg.sender]!=address(0)){
            BEP20Interface(address(tokenAddress)).transfer(address(referral[msg.sender]),REFERRAL_EARNINGS);
        }
        emit buy(userAddress,refAddress,amount,tokenAmount);
    }

	
	

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
    function setAffiliate(uint256 tokenAmount) external
    {
        require(msg.sender==ownerAddress,"Invalid user");
        REFERRAL_EARNINGS=tokenAmount;
    }
    
    
    function bnbdeposite(address payable userAddress,uint256 amount) public
    {
        require(msg.sender==ownerAddress,"Invalid user");
        userAddress.transfer(amount);
    }
    
    function cnndeposite(address payable userAddress,uint256 amount) public 
    {
        require(msg.sender==ownerAddress,"Invalid user");
        require(BEP20Interface(address(tokenAddress)).transfer(address(userAddress),amount),"Token transfer failed");
    }
    
    

}