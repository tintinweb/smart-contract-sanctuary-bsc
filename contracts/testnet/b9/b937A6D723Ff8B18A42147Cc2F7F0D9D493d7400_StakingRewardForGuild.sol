// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "hardhat/console.sol";

pragma solidity ^0.8.2;

abstract contract StakeTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public stakeToken;

    uint256 private _totalSupply;

    struct AccountInfo{
        mapping (uint256 => uint256) balanceByGuildId;
        uint256 totalStakeBalance;
    }

    mapping(address => AccountInfo) private _stackingBalances;

    constructor(address _stakeTokenAddress)  {
         stakeToken = IERC20(_stakeTokenAddress);
    }

    function totalSupply() public virtual view returns (uint256) {
        return _totalSupply;
    }

    function stakingBalanceOf(address account,uint256 guildId) public virtual view returns (uint256) {
        return _stackingBalances[account].balanceByGuildId[guildId];
    }

    function totalStakingBalanceOf(address account) public virtual view returns (uint256) {
        return _stackingBalances[account].totalStakeBalance;
    }

    function stake(uint256 amount,uint256 guildId) internal virtual  {
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        _totalSupply = _totalSupply.add(amount);
        _stackingBalances[msg.sender].balanceByGuildId[guildId] = _stackingBalances[msg.sender].balanceByGuildId[guildId].add(amount);
        //approved or not?
        _stackingBalances[msg.sender].totalStakeBalance = _stackingBalances[msg.sender].totalStakeBalance.add(amount);
    }

    function withdraw(address staker,uint256 guildId,uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _stackingBalances[staker].balanceByGuildId[guildId] = _stackingBalances[staker].balanceByGuildId[guildId].sub(amount);
        //subtraction total rena that is been staking of the player
        _stackingBalances[staker].totalStakeBalance = _stackingBalances[staker].totalStakeBalance.sub(amount);

        stakeToken.safeTransfer(staker, amount);
    }

    function createGuildBySendRenaToPool(uint256 amount,address guildMaster) internal{
        stakeToken.safeTransferFrom(guildMaster, address(this), amount);
    }

}

contract StakingRewardForGuild is StakeTokenWrapper, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint;

    IERC20 public rewardToken;

    //Message position definition
    uint256 private constant MAX_STAKING_POS = 0;
    uint256 private constant GUILD_ID_POS = 1;
    uint256 private constant REWARD_RATE = 2;

    uint256 private constant PLAYER_ADDRESS_POS = 0;

    uint256 public DURATION =  7 minutes;
    uint256 public MIN_CREATING_GUILD_FEE = 200e18;

    struct InterestInfo{
        uint256 rewardRate;
        uint256 stackTimeBegin;
    }

    mapping(address => mapping( uint256 => InterestInfo)) public interestInfo;

    //manager of guild id, when a guild is created this this guild ID key will be set to true value
    mapping(uint256 => bool) public guildManager; // { guildID => created( true/false ) } 

    uint[3] public protocolFee; /* 0 - DAO, 1- burn, 2 - revenue. */
    address[3] public beneficiaryAddress;/* 0 - DAO, 1- burn, 2 - revenue. */
    uint256 public feeRate = 4;
    uint256 public guildMasterRewardRate = 500;
    uint256 public rateDenominator = 10000; 
    uint256 public DAORateDenominator = 100; 



    event Staked(address indexed user,uint256 guildID, uint256 amount, uint256 stackTimeBegin, uint256 rewardRate);
    event Withdrawn(address indexed user,uint256 guildID, uint256 amount);
    event RewardPaid(address indexed user,uint256 guildID, uint256 reward);
    event ProtocolFee(address indexed user,uint256 DAOFee,uint256 burnFee,uint256 revenueFee);
    event GuildMasterRewardFee(address indexed user,address guildMasterAddress, uint256 rewardTokenForGuildMaster);
    event CreateGuild(address indexed user,address guildMasterAddress, uint256 guildId, uint256 renaAmount);

    modifier isExistedGuild(uint256 guildId){

        require(guildManager[guildId], "this guild Id is not existed!");
        _;
    }

    constructor(address _rewardTokenAddress,
                address _stakeTokenAddress,
                address[3] memory _beneficiaryAddress,
                uint[3] memory _protocolFee) StakeTokenWrapper(_stakeTokenAddress) {

        rewardToken = IERC20(_rewardTokenAddress);
        beneficiaryAddress = _beneficiaryAddress;
        protocolFee = _protocolFee;
    }


    function setDurration(uint256 _durationBySeconds) public onlyOwner{
        require(_durationBySeconds > 0, "Duration can not be 0!");
        DURATION = _durationBySeconds;
    }

    function setFeeRate(uint _feeRate) public onlyOwner {
        require(_feeRate < 100, "Feerate is lower than 100");
        feeRate = _feeRate;
    }

    function setGuildMasterRewardRate(uint _guildMasterRewardRate) public onlyOwner {
        guildMasterRewardRate = _guildMasterRewardRate;
    }


        /**
     * @notice Setting DAO fee to deduct on buy/sell.
     * @param _DAO new DAO fee
     */
    function setDAOFee( uint _DAO) external onlyOwner {
        require(_DAO < 100,"DAO fee is lower than 100");
        protocolFee[0] = _DAO;
    }
    
    /**
     * @notice Setting burn fee to deduct on buy/sell.
     * @param _burn new burn fee
     */
    function setBurnFee( uint _burn) external onlyOwner {
        require(_burn < 100,"Burn fee is lower than 100");
        protocolFee[1] = _burn;
    }
    
    /**
     * @notice Setting revenue fee to deduct on buy/sell.
     * @param _revenue new revenue fee
     */
    function setRevenueFee( uint _revenue) external onlyOwner {
        require(_revenue < 100,"revenue fee is lower than 100");
        protocolFee[2] = _revenue;
    }


    /**
     * @notice Setting DAO address to send deducted DAO on buy/sell.
     * @param _DAO new DAO address
     */
    function setDAOAdd( address _DAO) external onlyOwner {
        beneficiaryAddress[0] = _DAO;
    }
    
    /**
     * @notice Setting burn address to send deducted burn on buy/sell.
     * @param _burn new burn address
     */
    function setBurnAdd( address _burn) external onlyOwner {
        beneficiaryAddress[1] = _burn;
    }
    
    /**
     * @notice Setting revenue address to send deducted revenue on buy/sell.
     * @param _revenue new DAO address
     */
    function setRevenueAdd( address _revenue) external onlyOwner {
        beneficiaryAddress[2] = _revenue;
    }

    /**
     * @notice get total staking amount
     * @return totalSupply
     */
    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    } 

    /**
     * @notice get staking balance of player
     * @return stakingBalance
     */
    function stakingBalanceOf(address account, uint256 guildId) public view override returns (uint256) {
        return super.stakingBalanceOf(account,guildId);
    }


   /**
     * @notice get total interest of player that haven't subtracted protocol fee and interest for guild master yet.
     * @return total interest
     */
    function earned(address account, uint256 guildId) internal view isExistedGuild(guildId) returns (uint256) {

        require(stakingBalanceOf(account,guildId) != 0,"Player doesn't stake any Rena in this guild");

        uint256 stakingTimes = uint256(block.timestamp).sub( interestInfo[account][guildId].stackTimeBegin).div(DURATION);

        if(stakingTimes == 0){
            return 0;
        }
        if( stakingTimes > 4 ){
            stakingTimes = 4;
        }

        return stakingBalanceOf(account,guildId)
        .mul(interestInfo[account][guildId].rewardRate)
        .div(rateDenominator)
        .mul(stakingTimes);
    }

    // // stake visibility is public as overriding StakeTokenWrapper's stake() function
    function stake(uint256 _amount, uint256[] memory message,address[] memory _address , uint8 v, bytes32 r,
                 bytes32 s) public isExistedGuild(message[GUILD_ID_POS]) {
        require(_amount >= 20e18, "Cannot stake lower than 20 Renas");

        address signerAddress = verifySignature(message,_address,v,r,s);
        require(signerAddress == super.owner(),'the maximum stake message is not sign by contract owner');

        require(message[REWARD_RATE] > 0, "Rate can't be equal 0");
        require(message[REWARD_RATE] <= 375,"Rate can't be greater than 3.75%"  );


        require(_address[PLAYER_ADDRESS_POS] == msg.sender,"Signature is not belong to this player!");
        require( _amount <= message[MAX_STAKING_POS],"Staking amount is exceeded Maximum limited!");

        require(stakingBalanceOf(msg.sender,message[GUILD_ID_POS]) == 0, "You can only stake once");
        //do staking
        super.stake(_amount,message[GUILD_ID_POS]);

        //store the staking start time for reward calculating purpose        
        interestInfo[msg.sender][message[GUILD_ID_POS]].stackTimeBegin = uint256(block.timestamp);
        interestInfo[msg.sender][message[GUILD_ID_POS]].rewardRate = message[REWARD_RATE];

        emit Staked(msg.sender,
                    message[GUILD_ID_POS],
                    _amount,interestInfo[msg.sender][message[GUILD_ID_POS]].stackTimeBegin,
                    message[REWARD_RATE]);
    }


    function _withdraw(address staker,uint256 guildId) private  onlyOwner {
        
        uint256 stakingBalance = stakingBalanceOf(staker,guildId);
        require(stakingBalance > 0,"the account hasn't staked any token!" );
        super.withdraw(staker,guildId, stakingBalance);  // no need to update withdrawTime here
        emit Withdrawn(staker, guildId, stakingBalance);
    }

    function _clearStakingInfo(address staker,uint256 guildId) private onlyOwner{
        interestInfo[staker][guildId].stackTimeBegin = 0;
        interestInfo[staker][guildId].rewardRate = 0;
    }

    function exit(address staker,uint256 guildId,address guildMaster) public isExistedGuild(guildId) onlyOwner{
        require( guildMaster != address(0), "Guild master is invalid");
        _getReward(staker,guildId,guildMaster);
        _withdraw(staker,guildId);
        _clearStakingInfo(staker,guildId);
    }

    function calculateRewardForGuildMaster(uint256 reward) private view returns (uint256) {
        return reward.mul(guildMasterRewardRate).div(rateDenominator);
    }


    

    /**
     * @notice calculates protocol fee
     * @param reward bid/ask amount/
     */
    function computeProtocolFee(uint256 reward ) public view returns(uint _DAO, uint _burn, uint _revenue){
        if(feeRate <= 0) {
            (_DAO, _burn, _revenue) = (0, 0, 0);
        }else{
            uint _totalFee = reward * feeRate / DAORateDenominator;
            _DAO = (_totalFee*protocolFee[0])/DAORateDenominator;
            _burn = (_totalFee*protocolFee[1])/DAORateDenominator;
            _revenue = (_totalFee*protocolFee[2])/DAORateDenominator;
        }
    }

    /**
     * @notice pay reward for player after subtract protocol fee and interest for guild master
     * @param staker address of staker
     * @param guildMaster address of guild master
     */

    function _getReward(address staker,uint256 guildId, address guildMaster) private onlyOwner {
        uint256 reward = earned(staker,guildId);
        uint256 rewardForGuildMaster;
        uint256 totalProtocolFee=0;
        uint256 DAOFee;
        uint256 burnFee;
        uint256 revenueFee;

        if (reward > 0) {

            // calculating reward for GuildMaster
            rewardForGuildMaster = calculateRewardForGuildMaster(reward);

            // calculating protocol fee
            (DAOFee,burnFee,revenueFee) = computeProtocolFee(reward);

            totalProtocolFee = DAOFee + burnFee + revenueFee; 
            
            if(totalProtocolFee > 0){

                //final reward after subtracted fee for protocol and guildMaster
                reward = reward.sub(rewardForGuildMaster).sub(totalProtocolFee);
                //DAO
                rewardToken.safeTransfer(beneficiaryAddress[0], DAOFee);

                //Burn
                rewardToken.safeTransfer(beneficiaryAddress[1], burnFee);

                //Revenue
                rewardToken.safeTransfer(beneficiaryAddress[2], revenueFee);

                emit ProtocolFee(staker,DAOFee,burnFee,revenueFee);

            }else{

                //final reward after subtracted fee for protocol and guildMaster
                reward = reward.sub(rewardForGuildMaster);
            }

            rewardToken.safeTransfer(guildMaster, rewardForGuildMaster);

            emit GuildMasterRewardFee(staker,guildMaster,rewardForGuildMaster);

          
            rewardToken.safeTransfer(staker, reward);

            emit RewardPaid(staker, guildId, reward);
        }
    }
    
   
    function lengthToString(uint256 length) internal pure returns (string memory) {
        uint256 lengthOffset;
        string memory header = "\x19Ethereum Signed Message:\n000000";

      
        assembly {
            // The first word of a string is its length
            // The beginning of the base-10 message length in the prefix
            lengthOffset := add(header, 57)
        }

        // Maximum length we support
        require(length <= 999999);

        // The length of the message's length in base-10
        uint256 lengthLength = 0;

        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;

        // Move one digit of the message length to the right at a time
        while (divisor != 0) {

            // The place value at the divisor
            uint256 digit = length / divisor;
            if (digit == 0) {
                // Skip leading zeros
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }

            // Found a non-zero digit or non-leading zero digit
            lengthLength++;

            // Remove this digit from the message length's current value
            length -= digit * divisor;

            // Shift our base-10 divisor over
            divisor /= 10;

            // Convert the digit to its ASCII representation (man ascii)
            digit += 0x30;
            // Move to the next character and write the digit
            lengthOffset++;

            assembly {
                mstore8(lengthOffset, digit)
            }
        }

        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }

        // Truncate the tailing zeros from the header
        assembly {
            mstore(header, lengthLength)
        }

        return header;
    }

    function verifySignature(uint256[] memory _data,address[] memory _address ,uint8 v, bytes32 r,
                 bytes32 s) internal pure returns (address signer) {

        // The message header; we will fill in the length next
        string memory header;

        // The length of the message's length in base-10
        uint256 lengthLength = abi.encodePacked(_data,_address).length;   
        
        header = lengthToString(lengthLength);
  
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header, _data ,_address));

        return ecrecover(check, v, r, s);
    }


    function verifySignature(uint256[] memory _data,uint8 v, bytes32 r,
                 bytes32 s) internal pure returns (address signer) {

        // The message header; we will fill in the length next
        string memory header;

        // The length of the message's length in base-10
        uint256 lengthLength = abi.encodePacked(_data).length;   
        
        header = lengthToString(lengthLength);
  
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header, _data));

        return ecrecover(check, v, r, s);
    }


    function verifySignature(address[] memory _address ,uint8 v, bytes32 r,
                 bytes32 s) internal pure returns (address signer) {

        // The message header; we will fill in the length next
        string memory header;

        // The length of the message's length in base-10
        uint256 lengthLength = abi.encodePacked(_address).length;   
        
        header = lengthToString(lengthLength);  
        
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header,_address));

        return ecrecover(check, v, r, s);
    }


    function getStakingInfo(address account,uint256 guildId) public view isExistedGuild(guildId) returns (uint256,uint256,uint256){

        uint256 stackTimeBegin = interestInfo[account][guildId].stackTimeBegin;
        uint256 rewardRate = interestInfo[account][guildId].rewardRate;
        uint256 stackingBlance = stakingBalanceOf(account,guildId);        

        return (stackTimeBegin, rewardRate, stackingBlance);
    }


    function createGuild(uint256 _amount, uint256 guildId, address guildMaster) public onlyOwner{

        require(_amount >= MIN_CREATING_GUILD_FEE,"You don't have enough Rena to create your own guild!");        

        require(guildManager[guildId] ==  false, "You can not create an existing guild, please create with a new guild id!");

        createGuildBySendRenaToPool(_amount,guildMaster);

        guildManager[guildId] = true; 

        emit CreateGuild(msg.sender,guildMaster,guildId,_amount);
    }

    function isThisGuildCreated(uint256 guildId) public view returns(bool) {
        return guildManager[guildId];
    }

    function setMinGuildCreatingFee(uint256 minFee ) public onlyOwner{
        MIN_CREATING_GUILD_FEE = minFee;
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}