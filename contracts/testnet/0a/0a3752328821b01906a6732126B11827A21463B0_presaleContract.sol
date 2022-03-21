// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./IERC20.sol";
import "./launchpad.sol";
import "./ownable.sol";


library SafeMath0 {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract presaleContract is Ownable {
    using SafeMath0 for uint256;

    address _owner;
    address tokenOwner;
    string public name;
    string public tokenSymbol;
    uint256 public totalSupply;
    IERC20 public rewardToken;
    IERC20 public buyToken;
    uint256 public swapRate = 1 * 1e18;
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public TGETime;
    uint256 public TGEUnlockPercent = 10 * 1e18;
    uint256 public lockTime = 0;
    uint256 public rewardDuration = 3 * 1e18;
    uint256 public rewardUnlockTime = 1 * 1e18;
    bool public useTiers = true;
    address public launchpadAddress;
    uint256 public maxHardCap = 100 * 10 ** 5 * 1e18;

    uint256 public minimumDepositeAmount = 100 * 1e18;  
    
    uint256 public maximumDepositeAmount = 100000  * 1e18; 

    uint256 tier1Max = 1000000 * 1e18;
    uint256 tier1Min = 50000 * 1e18;    
    uint256 tier2Max = 2000000 * 1e18;
    uint256 tier2Min = 150000 * 1e18;    
    uint256 tier3Max = 3000000 * 1e18;
    uint256 tier3Min = 250000 * 1e18;

    uint256 public totalInvested = 0;
    uint256 public totalRewardTokens = 0;
    uint256 public totalRewardTokensDeposited = 0;
    uint256 public allocation = 0;

    mapping(address => uint256) public userInvestment;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) lastClaimedTime;
    mapping(address => uint256) totalClaimableAmount;
    mapping(address => uint256) public totalClaimed;
    mapping(address => bool) TGEClaimed;

    constructor(
        string memory _name,
        string memory _tokenSymbol,
        uint256 _totalSupply,
        IERC20 _buyToken,
        IERC20 _rewardToken,
        address _tokenOwner,
        uint256 _allocation
    ){
        name = _name;
        tokenSymbol = _tokenSymbol;
        totalSupply = _totalSupply;
        buyToken = _buyToken;
        rewardToken = _rewardToken;
        _owner = msg.sender;
        tokenOwner = _tokenOwner;
        allocation = _allocation;
    }

    function getMinMaxDepositeAmount(address _user) public view returns(uint256, uint256) {
        uint256 _maximumDepositeAmount = maximumDepositeAmount;
        uint256 _minimumDepositeAmount = minimumDepositeAmount;
        if(useTiers){
            uint256 userTier = launchpad(launchpadAddress).getTier(_user);
            if(userTier == 1){
                _maximumDepositeAmount = tier1Max;
                _minimumDepositeAmount = tier1Min;
            }
            if(userTier == 2){
                _maximumDepositeAmount = tier2Max;
                _minimumDepositeAmount = tier2Min;
            }
            if(userTier == 3){
                _maximumDepositeAmount = tier3Max;
                _minimumDepositeAmount = tier3Min;
            }
            if(whitelisted[_user] && _maximumDepositeAmount < tier2Max){
                _maximumDepositeAmount = tier2Max;
                _minimumDepositeAmount = tier2Min;
            }
        }
        return (_maximumDepositeAmount,_minimumDepositeAmount);
    }

    function getAllocation() external view returns(uint256){
        return (allocation * swapRate) / 1000000000000000000;
    }

    function depositeRewardToken(uint256 _amount) public {
        require(msg.sender == tokenOwner, "You need to be the owner of the token");
        totalRewardTokensDeposited += _amount;
        require(rewardToken.transferFrom(tokenOwner,address(this), _amount), "Transfer Failed");
    }

    function withdrawRewardTokens(uint256 _amount) public{
        require(msg.sender == tokenOwner, "You need to be the owner of the token");
        require(block.timestamp > saleEnd, "Sale is not ended yet");
        uint256 withdrawableAmount = totalRewardTokensDeposited - totalRewardTokens;
        require(withdrawableAmount >= _amount, "Not enough tokens to withdraw");
        totalRewardTokensDeposited -= _amount;
        require(rewardToken.transfer(tokenOwner,_amount), "Transfer Failed");
    }

    function buy(uint256 _amount) public {
        require(block.timestamp >= saleStart, "Presale is not started yet!");
        require(block.timestamp <= saleEnd, "Presale is ended!");
        require(_amount >= minimumDepositeAmount, "You can't deposite less than minimum amount");
        address _user = msg.sender;
        (uint256 _maxAmount,uint256 _minAmount) = getMinMaxDepositeAmount(_user);
        uint256 _currentInvestment = userInvestment[_user];
        require(_currentInvestment + _amount <= _maxAmount, "You can't deposite more than maximum amount");
        require(_currentInvestment + _amount >= _minAmount, "You can't deposite less than minimum amount");
        uint256 _rewardTokensgenerated = (_amount * 1000000000000000000) / swapRate;
        require(_rewardTokensgenerated + totalRewardTokens <= allocation, "Max allocation limit is touched");
        require(_amount + totalInvested <= maxHardCap, "Maximum total investment limit is touched");
        totalInvested += _amount;
        totalRewardTokens += _rewardTokensgenerated;
        totalClaimableAmount[_user] += _rewardTokensgenerated;
        userInvestment[_user] += _amount;
        require(buyToken.transferFrom(address(_user), address(this), _amount), "Transfer Failed");
    }

    function claim() public payable {
        address _user = msg.sender;
        uint256 currentTime = block.timestamp;
        require(currentTime >= TGETime, "Can't claim before TGE");
        uint256 _amount = 0;
        uint256 _totalRewardTokens = totalClaimableAmount[_user];
        require(totalClaimed[_user] < _totalRewardTokens, "Nothing to claim");
        if(currentTime > rewardDuration){
            _amount = _totalRewardTokens - totalClaimed[_user];
        }else{
            uint256 _lockTime = TGETime + lockTime;
            if(!TGEClaimed[_user]){
                _amount += (_totalRewardTokens * TGEUnlockPercent) / 100000000000000000000;
                TGEClaimed[_user] = true;
            }
            if(lastClaimedTime[_user] < _lockTime){
                lastClaimedTime[_user] = _lockTime;
            }
            if(currentTime > _lockTime){
                uint256 timeElapsed = currentTime - lastClaimedTime[_user];
                uint256 totalRewardDurationInDays = rewardDuration - _lockTime;
                uint256 _rewardUnlockPercent = (rewardUnlockTime * (100 * 1e18 - TGEUnlockPercent)) / (totalRewardDurationInDays);
                uint256 _claimablePercent = (timeElapsed / rewardUnlockTime) * _rewardUnlockPercent;   
                _amount += (_totalRewardTokens * _claimablePercent) / 100000000000000000000;
                lastClaimedTime[_user] = lastClaimedTime[_user] + (timeElapsed - (timeElapsed % rewardUnlockTime));   
            }
            if(_amount + totalClaimed[_user] > _totalRewardTokens){
                _amount = _totalRewardTokens - totalClaimed[_user];
            }
        }
        totalClaimed[_user] += _amount;
        totalRewardTokens -= _amount;
        rewardToken.transfer(_user, _amount);
    }
    
    function getClaimableAmount(address _user) external view returns(uint256) {
        uint256 currentTime = block.timestamp;
        require(currentTime >= TGETime, "Can't claim before TGE");
        uint256 _amount = 0;
        uint256 _totalRewardTokens = totalClaimableAmount[_user];
        if(totalClaimed[_user] >= _totalRewardTokens){
            return _amount;
        }
        if(currentTime > rewardDuration){
            _amount = _totalRewardTokens - totalClaimed[_user];
        }else{
            uint256 _lockTime = TGETime + lockTime;
            uint256 lastClaimed = lastClaimedTime[_user];
            if(!TGEClaimed[_user]){
                _amount += (_totalRewardTokens * TGEUnlockPercent) / 100000000000000000000;
            }
            if(lastClaimed < _lockTime){
                lastClaimed = _lockTime;
            }
            if(currentTime > _lockTime){
                uint256 timeElapsed = currentTime - lastClaimed;
                uint256 totalRewardDurationInDays = rewardDuration - _lockTime;
                uint256 _rewardUnlockPercent = (rewardUnlockTime * (100 * 1e18 - TGEUnlockPercent)) / (totalRewardDurationInDays);
                uint256 _claimablePercent = (timeElapsed / rewardUnlockTime) * _rewardUnlockPercent;   
                _amount += (_totalRewardTokens * _claimablePercent) / 100000000000000000000;
            }
            if(_amount + totalClaimed[_user] > _totalRewardTokens){
                _amount = _totalRewardTokens - totalClaimed[_user];
            }
        }
        return _amount;
    }

    function withdrawAmount(uint256 _amount) external onlyOwner{
        require(totalInvested >= _amount, "Insuffcient tokens in the contract");
        require(buyToken.transfer(owner, _amount), "Transfer Failed");
        totalInvested -= _amount;
    }

    function setSwapRate(uint256 _amount) external onlyOwner {
        require(_amount != 0, "Swap Rate can't be zero");
        swapRate = _amount;
    }

    function setSaleStart(uint256 _saleStart) external onlyOwner {
        saleStart = _saleStart;
    }

    function setSaleEnd(uint256 _saleEnd) external onlyOwner {
        saleEnd = _saleEnd;
    }

    function setTGETime(uint256 _TGETime) external onlyOwner {
        require(_TGETime > saleEnd && saleEnd!=0, "TGE can't be before end time");
        TGETime = _TGETime;
    }

    function setTGEUnlockPercent(uint256 _TGEUnlockPercent) external onlyOwner {
        TGEUnlockPercent = _TGEUnlockPercent;
    }

    function setLockTime(uint256 _lockTime) external onlyOwner {
        lockTime = _lockTime;
    }

    function setRewardDuration(uint256 _rewardDuration) external onlyOwner {
        require(TGETime != 0, "TGE Time is not set");
        require(_rewardDuration > TGETime, "Can't be before TGE Time");
        rewardDuration = _rewardDuration;
    }

    function setRewardUnlockTime(uint256 _rewardUnlockTime) external onlyOwner {
        rewardUnlockTime = _rewardUnlockTime;
    }

    function updateUseTiers(bool _useTiers) external onlyOwner {
        useTiers = _useTiers;
    }

    function updateLaunchpadAddress(address _launchpadAddress) external onlyOwner {
        launchpadAddress = _launchpadAddress;
    }

    function updateMaxHardCap(uint256 _maxHardCap) external onlyOwner {
        maxHardCap = _maxHardCap;
    }

    function updateMinimumDepositeAmount(uint256 _minimumDepositeAmount) external onlyOwner {
        minimumDepositeAmount = _minimumDepositeAmount;
    } 

    function updateMaximumDepositeAmount(uint256 _maximumDepositeAmount) external onlyOwner {
        maximumDepositeAmount = _maximumDepositeAmount;
    }

    function updateTier1Max(uint256 _tier1Max) external onlyOwner {
        tier1Max = _tier1Max;
    }

    function updateTier2Max(uint256 _tier2Max) external onlyOwner {
        tier2Max = _tier2Max;
    }

    function updateTier3Max(uint256 _tier3Max) external onlyOwner {
        tier3Max = _tier3Max;
    }

    function updateTier1Min(uint256 _tier1Min) external onlyOwner {
        tier1Min = _tier1Min;
    }

    function updateTier2Min(uint256 _tier2Min) external onlyOwner {
        tier2Min = _tier2Min;
    }

    function updateTier3Min(uint256 _tier3Min) external onlyOwner {
        tier3Min = _tier3Min;
    }

    function whitelistUser(address _user) external onlyOwner {
        whitelisted[_user] = true;
    }


}