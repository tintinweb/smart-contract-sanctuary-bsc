/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/SafeERC721.sol";

// contract ERC721StakingContract is SafeERC721 {
//   using SafeMath for uint256;

//   // Mapping from NFT ID to staking record
//   mapping(uint256 => StakingRecord) public stakingRecords;

//   // Mapping from NFT ID to pending rewards
//   mapping(uint256 => uint256) public pendingRewards;

//   // Owner address
//   address private owner;

//   // Reward rate (per block)
//   uint256 public rewardRate;

//   // Curve parameter
//   uint256 public curveParameter;

//   // Minimum staking period (in blocks)
//   uint256 public minStakingPeriod;

//   // Event emitted when an NFT is staked
//   event Staked(uint256 indexed nftId, uint256 stakingPeriod);

//   // Event emitted when an NFT is unstaked
//   event Unstaked(uint256 indexed nftId);

//   // Event emitted when rewards are claimed
//   event Claimed(uint256 indexed nftId, uint256 amount);

//   constructor() public {
//     // Set the owner to the contract deployer
//     owner = msg.sender;

//     // Set the default reward rate to 1
//     rewardRate = 1;

//     // Set the default curve parameter to 1
//     curveParameter = 1;

//     // Set the default minimum staking period to 180 days
//     minStakingPeriod = 180 * 1 days;
//   }

//   // Stake an array of NFTs
//   function stake(uint256[] memory nftIds, uint256 stakingPeriod) public {
//     // Ensure that the caller is the owner of the NFTs
//     require(isApprovedOrOwner(msg.sender, nftIds), "NFTs not owned by caller");

//     // Ensure that the staking period is at least the minimum staking period
//     require(stakingPeriod >= minStakingPeriod, "Staking period too short");

//     // Iterate over the NFTs
//     for (uint256 i = 0; i < nftIds.length; i++) {
//       uint256 nftId = nftIds[i];

//       // Ensure that the NFT is not already staked
//       require(!stakingRecords[nftId].staked, "NFT already staked");

//       // Set the staking record
//       stakingRecords[nftId].staked = true;
//       stakingRecords[nftId].stakingPeriod = stakingPeriod;
//       stakingRecords[nftId].timestamp = block.timestamp;

//       // Emit the Staked event
//       emit Staked(nftId, stakingPeriod);
//     }
//   }






// ============= 2 ================



// pragma solidity ^0.6.12;

// import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/SafeERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

// contract NFTStaking is SafeERC721 {
//   using SafeMath for uint256;

//   // Minimal staking period, in days
//   uint256 public constant MIN_STAKING_PERIOD = 180;

//   // Staking curve parameter
//   uint256 public curveParameter;

//   // Reward rate, in percentage
//   uint256 public rewardRate;

//   // Mapping from NFT token ID to staking record
//   mapping(uint256 => StakingRecord) public stakingRecords;

//   // Staking record struct
//   struct StakingRecord {
//     uint256 stakedAt;
//     uint256 stakingPeriod;
//     bool locked;
//   }

//   // Event emitted when NFTs are staked
//   event Staked(uint256[] tokenIds);

//   // Event emitted when NFTs are unstaked
//   event Unstaked(uint256[] tokenIds);

//   // Event emitted when rewards are claimed
//   event Claimed(uint256 amount);

//   constructor(uint256 _curveParameter, uint256 _rewardRate) public {
//     curveParameter = _curveParameter;
//     rewardRate = _rewardRate;
//   }

//   // Stake NFTs
//   function stake(uint256[] memory tokenIds) public {
//     require(tokenIds.length > 0, "No NFTs to stake");
//     require(now >= MIN_STAKING_PERIOD, "Minimal staking period not reached");

//     for (uint256 i = 0; i < tokenIds.length; i++) {
//       uint256 tokenId = tokenIds[i];
//       require(isApprovedOrOwner(msg.sender, tokenId), "NFT not approved or owned by staker");
//       require(!stakingRecords[tokenId].locked, "NFT already staked");

//       stakingRecords[tokenId] = StakingRecord(now, MIN_STAKING_PERIOD, true);
//       safeTransferFrom(msg.sender, address(this), tokenId);
//     }

//     emit Staked(tokenIds);
//   }

//   // Restake NFTs
//   function restake(uint256[] memory tokenIds) public {
//     require(tokenIds.length > 0, "No NFTs to restake");

//     for (uint256 i = 0; i < tokenIds.length; i++) {
//       uint256 tokenId = tokenIds[i];
//       require(isOwner(msg.sender, tokenId), "NFT not owned by staker");
//       require(stakingRecords[tokenId].locked, "NFT not staked");

//       stakingRecords[tokenId].stakedAt = now;
//       stakingRecords[tokenId].stakingPeriod += MIN_STAKING_PERIOD;
//     }
//   }

//   // Unstake NFTs
//   function unstake(uint256[] memory tokenIds




// ========================



/**
 *Submitted for verification at polygonscan.com on 2022-12-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

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
}





contract SBRF_StakingDAPP {

    using SafeMath for uint256;
   string public name = "SBRF STAKING DAPP";
   address public owner ;
    IERC20  public SBRF ;
  mapping(address => bool) public hasStaked;
    address[] public stakers;


  uint256 public Plan1 = 30 days;  //30 days
  uint256 public Plan2 =  60 days;  //60 days
  uint256 public Plan3 = 90 days;  //90 days

  uint256 public totalStakedOfPlan1;
  uint256 public totalStakedOfPlan2;
  uint256 public totalStakedOfPlan3;


 
uint256 public MinStakedOfPlan1 = 20e18;
uint256 public MinStakedOfPlan2 = 50e18;
uint256 public MinStakedOfPlan3 = 100e18;


  
  
 uint256 public totalStakedOfPlan1Apy = 1000; // 10%;
 uint256 public totalStakedOfPlan2Apy = 1500; // 15%;
 uint256 public totalStakedOfPlan3Apy = 2000; // 20%;


mapping(address => uint256) public stakingBalancePlan1;
mapping(address => uint256) public stakingBalancePlan2;
mapping(address => uint256) public stakingBalancePlan3;
mapping(address => uint256) public stakingStartTime1;
mapping(address => uint256) public stakingStartTime2;
mapping(address => uint256) public stakingStartTime3;



 constructor(IERC20 _Token) public  {
        SBRF  = _Token;
        owner = msg.sender;
    }


      function stakeTokens(uint256 _amount , uint256 _plan ) public {
        //must be more than 0
        require(_amount > 0, "amount cannot be 0");

        //User adding test tokens
       

        if(_plan == Plan1  ){
            require(_amount> MinStakedOfPlan1 ," please enter amount greater than Min amount");
            totalStakedOfPlan1 = totalStakedOfPlan1 + _amount;
            stakingBalancePlan1[msg.sender] = stakingBalancePlan1[msg.sender] + _amount;
            stakingStartTime1[msg.sender]= block.timestamp;
            SBRF.transferFrom(msg.sender, address(this), _amount);
        }
        if(_plan == Plan2  ){

        require(_amount> MinStakedOfPlan2," please enter amount greater than Min amount");
            totalStakedOfPlan2 = totalStakedOfPlan2 + _amount;
            stakingBalancePlan2[msg.sender] = stakingBalancePlan2[msg.sender] + _amount;
             stakingStartTime2[msg.sender]= block.timestamp;
              SBRF.transferFrom(msg.sender, address(this), _amount);

        }
        if(_plan == Plan3  ){
           require(_amount> MinStakedOfPlan3 ," please enter amount greater than Min amount");
            totalStakedOfPlan3 = totalStakedOfPlan3 + _amount;
             stakingBalancePlan3[msg.sender] = stakingBalancePlan3[msg.sender] + _amount;
              stakingStartTime3[msg.sender]= block.timestamp;
               SBRF.transferFrom(msg.sender, address(this), _amount);

        }

        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //updating staking status
        
        hasStaked[msg.sender] = true;
    }




    function unstakeTokens(uint256 _plan) public {

        if(_plan == Plan1  ){

    require(stakingStartTime1[msg.sender] + 30 days < block.timestamp , "plase try after staking  Time period hours");
     uint256 _amount = stakingBalancePlan1[msg.sender];
        SBRF.transfer(msg.sender, _amount);

        totalStakedOfPlan1 = totalStakedOfPlan1 - _amount;
        stakingBalancePlan1[msg.sender] = stakingBalancePlan1[msg.sender] - _amount;
        stakingStartTime1[msg.sender]= 0;

        }
        if(_plan == Plan2  ){

            require(stakingStartTime2[msg.sender] + 60 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan2[msg.sender];
            SBRF.transfer(msg.sender, _amount);
             totalStakedOfPlan2 = totalStakedOfPlan2 - _amount;
            stakingBalancePlan2[msg.sender] =  stakingBalancePlan2[msg.sender] - _amount;
            stakingStartTime2[msg.sender]= 0;
        }
        if(_plan == Plan3  ){

            require(stakingStartTime3[msg.sender] + 90 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan3[msg.sender];
            SBRF.transfer(msg.sender, _amount);
             totalStakedOfPlan3 = totalStakedOfPlan3 - _amount;
            stakingBalancePlan3[msg.sender] =  stakingBalancePlan3[msg.sender] - _amount;
            stakingStartTime3[msg.sender]= 0;

        }

    }





   function Reward(uint256 plan ) public {

  if(plan == Plan1  ){

    require(stakingStartTime1[msg.sender] + 30 days < block.timestamp , "plase try after staking  Time period hours");
     uint256 _amount = stakingBalancePlan1[msg.sender];
        uint interest = _amount.mul(totalStakedOfPlan1Apy).div(10000);
        SBRF.transfer(msg.sender, interest);

   

        }
        if(plan == Plan2  ){

            require(stakingStartTime2[msg.sender] + 60 days < block.timestamp , "plase try after staking  Time period hours");
            uint256 _amount = stakingBalancePlan2[msg.sender];
            uint interest = _amount.mul(totalStakedOfPlan2Apy).div(10000);
             SBRF.transfer(msg.sender, interest);
        }
        if(plan == Plan3  ){

            require(stakingStartTime3[msg.sender] + 90 days < block.timestamp , "plase try after staking  Time period hours");
              uint256 _amount = stakingBalancePlan3[msg.sender];
              uint interest = _amount.mul(totalStakedOfPlan3Apy).div(10000);
               SBRF.transfer(msg.sender, interest);

        }
      

    }


    function setPlans( uint256 _plan1 , uint256 _plan2 , uint256 _plan3) public  onlyOwner {
        require(msg.sender == owner ,"only owner can run this function");
        Plan1 = _plan1;
        Plan2 = _plan2 ;
        Plan3 =  _plan3;

 
    }


        function setMinValForPlans( uint256 _val1 , uint256 _val2 , uint256 _val3) public  onlyOwner {
        require(msg.sender == owner ,"only owner can run this function");
        MinStakedOfPlan1 = _val1;
        MinStakedOfPlan2 = _val2 ;
        MinStakedOfPlan3 =  _val3;

 
    }

      function setPlansApy( uint256 _APY1 , uint256 _APY2 , uint256 _APY3) public onlyOwner {
           require(msg.sender == owner ,"only owner can run this function");
        totalStakedOfPlan1Apy = _APY1;
        totalStakedOfPlan2Apy = _APY2;
        totalStakedOfPlan3Apy =  _APY3;

 
    }

    function transferOwnership(address newOwner) public onlyOwner {
       
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }
    
    
}