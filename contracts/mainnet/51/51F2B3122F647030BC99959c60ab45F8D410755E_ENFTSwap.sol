/**
 *Submitted for verification at BscScan.com on 2022-11-29
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


contract ENFTSwap {
	using SafeMath for uint256;
    uint256 public fees = 5;
	
	address payable private ownerAddress;
    BEP20Interface public usdtAddress = BEP20Interface(0x55d398326f99059fF775485246999027B3197955);
    BEP20Interface public tokenAddress=BEP20Interface(0x3D692F0F5170d749De3D942Aa36F6a7e0eA20dc1);
    uint256 public priceInUsdt;
    bool public isPaused;
    mapping(address=>bool) public isBlocked;
   
	event priceChange(address indexed user,uint256 price,uint256 date);
    event buyENFT(address indexed user,uint256 priceInUsdt,uint256 tokens);
    event sellENFT(address indexed user,uint256 priceInUsdt,uint256 tokens);
    
    modifier onlyOwner {
      require(msg.sender == ownerAddress,"Invalid user");
      _;
   }

	constructor(address payable marketingAddr) {
		ownerAddress = marketingAddr;
		priceInUsdt = 1000*1e18;
	}
	
	
	/*******Swapping ********/
    function setPrice(uint256 amount) public onlyOwner
    {
        require(amount>0,"Invalid amount or plan");
        priceInUsdt=amount;
    }

    function blockUser(address _user) external onlyOwner{
        isBlocked[_user] = true;
    }

    function unblockUser(address _user) external onlyOwner{
        isBlocked[_user] = false;
    }
    
    function setFees(uint256 _fees) public onlyOwner
    {
        require(_fees>0,"Invalid amount or plan");
        fees=_fees;
    }

    function pasueContract() public onlyOwner
    {
        isPaused = true;
    }
    
    function unPasueContract() public onlyOwner
    {
        isPaused = false;
    }
	
    function exchange(uint256 amount) public payable
    {
        require(!isBlocked[msg.sender],"User is blocked");
        require(!isPaused,"Contract is paused");
        require(amount>0,"Invalid Amount");
        address payable userAddress = payable(msg.sender);
        convertToUsdt(amount,userAddress);
       
    }
    
    function convertToUsdt(uint256 tokenAmount,address payable userAddress) private
    {
        uint256 fee = tokenAmount.mul(fees).div(100);
        uint256 usdtAmount=(tokenAmount.sub(fee)).mul(priceInUsdt).div(1e18);
        require(BEP20Interface(tokenAddress).transferFrom(userAddress,address(this),tokenAmount),"Token transfer failed");
        
        require(BEP20Interface(address(usdtAddress)).transfer(address(userAddress),usdtAmount),"Token transfer failed");
        
        emit sellENFT(userAddress,usdtAmount,tokenAmount);
    }

    function withdrawUSDT(address userAddress,uint256 amount) external onlyOwner
    {
        BEP20Interface(usdtAddress).transfer(userAddress, amount);
    }
	
	function withdrawtoken(address userAddress,uint256 amount) external onlyOwner
    {
        BEP20Interface(tokenAddress).transfer(userAddress, amount);
    }

}