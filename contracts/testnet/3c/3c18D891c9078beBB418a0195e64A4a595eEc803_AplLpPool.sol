/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// File: AplLpPool.sol


// File: AplLpStaking.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

contract AplLpPool is Ownable {
    using SafeMath for uint256;

    uint256 minScore = 50;
    uint256 maxScore = 200;
    uint256 claimPerBlock = 10**18;
    uint256 public settleCount = 0;
    uint256 ONE_MONTH_IN_SECONDS = 2592000;
    // uint256 ONE_MONTH_IN_SECONDS = 180;
    uint256 public lastSettleBlockNumber = 0;

    IERC20 public lpToken;
    IERC20 public cpToken1;
    IERC20 public cpToken2;
    IERC20 public aplToken;

    uint256 public settleData1;
    uint256 public settleData2;
    uint256 public settleData;

    struct stakeEntity {
        uint256 initStakingTime;
        uint256 lastSettleTime;
        uint256 initBlockNumber;
        uint256 lastSettleBlockNumber;
        uint256 amount;
        bool isLiving;
    }

    struct claimEntity {
        uint256 claimTime;
        uint256 claimBlock;
        uint256 claimAmount;
    }

    mapping(address => uint256) public lastMolecular;
    mapping(address => uint256) public lastDenominator;

    mapping(address => uint256) public balanceOfLpToken;
    mapping(address => uint256) public balanceOfComputePower;
    mapping(address => uint256) public balanceOfCurrentIncresedComputePower;
    mapping(address => uint256) public balanceOfHistoryIncresedComputePower;
    mapping(address => uint256) public balanceOfScore;
    mapping(address => bool) public hasStaked;

    mapping(address => stakeEntity[]) public stakingList;
    mapping(address => uint256) public totalBlockOfCurrentRound;
    mapping(address => uint256) public clearCount;
    mapping(address => uint256) public balanceOfHistoryIncresedBlock;

    mapping(address => uint256) public totalUnStakingTimesOfCurrentRound;
    mapping(address => uint256) public totalUnStakingTimesOfHistory;

    mapping(address => uint256) public cpScoreBalance;
    mapping(address => uint256) public blockScoreBalance;
    mapping(address => uint256) public unstakingScoreBalance;
    mapping(address => uint256) public balanceOfCpForCurrentRound;

    mapping(address => claimEntity[]) public claimList;
    mapping(address => uint256) public unclaimBalance;
    mapping(address => uint256) public withdrawedApl;

    address[] private addressList;

    address settleAddress;
    address parameterAddress;
    address subOwnerAddress;

    modifier onlySettle {
        require (msg.sender == settleAddress, "Unauthorized address");
        _;
    }

    modifier onlyParameter {
        require (msg.sender == parameterAddress, "Unauthorized address");
        _;
    }

    modifier onlySubOwner {
        require (msg.sender == subOwnerAddress, "Unauthorized address");
        _;
    }

    constructor() {
        lastSettleBlockNumber = block.number;
    }

    function setLpTokenAddress(address _address) public onlyOwner {
        require(_address!=address(0), "Invalid address");
        lpToken = IERC20(address(_address));
    }

    function setCp1TokenAddress(address _address) public onlyOwner {
        require(_address!=address(0), "Invalid address");
        cpToken1 = IERC20(address(_address));
    }

    function setCp2TokenAddress(address _address) public onlyOwner {
        require(_address!=address(0), "Invalid address");
        cpToken2 = IERC20(address(_address));
    }

    function setAplTokenAddress(address _address) public onlyOwner {
        require(_address!=address(0), "Invalid address");
        aplToken = IERC20(address(_address));
    }

    function setMinScore(uint256 _minScore) public onlyParameter {
        require(_minScore >=20, "MinScore can't be smaller than 10");
        require(_minScore <= maxScore, "MinScore can't be larger than maxScore");
        minScore = _minScore;
    }

    function setMaxScore(uint256 _maxScore) public onlyParameter {
        require(_maxScore <= 500, "MaxScore can't be larger than 500");
        require(minScore <= _maxScore, "MaxScore can't be smaller than minScore");
        maxScore = _maxScore;
    }

    function setClaimPerBlock(uint256 _num) public onlyParameter {
        require(_num <= 10*10**18 , "ClaimPerBlock can't be larger than 10");
        require(_num >= 1*10**18 , "ClaimPerBlock can't be smaller than 1");
        claimPerBlock = _num;
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Invalid staking amount");
        lpToken.transferFrom(msg.sender, address(this), _amount);
        cpToken1.transfer(msg.sender, _amount);
        cpToken2.transfer(msg.sender, _amount);

        if(!hasStaked[msg.sender]){
            balanceOfComputePower[msg.sender] = _amount;
            balanceOfScore[msg.sender] = 100;
            hasStaked[msg.sender] = true;
            addressList.push(msg.sender);
            balanceOfLpToken[msg.sender] = _amount;
            balanceOfCurrentIncresedComputePower[msg.sender] = _amount;
        }else{
            balanceOfComputePower[msg.sender] = balanceOfComputePower[msg.sender].add(_amount);
            balanceOfLpToken[msg.sender] = balanceOfLpToken[msg.sender].add(_amount);
            balanceOfCurrentIncresedComputePower[msg.sender] = balanceOfCurrentIncresedComputePower[msg.sender].add(_amount);
        }
        stakeEntity memory entity = stakeEntity(block.timestamp, block.timestamp, block.number, block.number, _amount, true);
        stakingList[msg.sender].push(entity);
    }

    function withdraw(uint256 _amount, uint256 index) public {
        require(_amount > 0, "Invalid unstaking amount");
        require(_amount <= stakingList[msg.sender][index].amount, "Not enough lp token");
        uint256 cpTokenBalance = cpToken1.balanceOf(msg.sender);
        uint256 cp2TokenBalance = cpToken2.balanceOf(msg.sender);
        uint256 realAmount = _amount;
        uint256 cpb = 0;
        if(cpTokenBalance>=cp2TokenBalance){
            cpb = cp2TokenBalance;
        }else{
            cpb = cpTokenBalance;
        }
        if(_amount>cpb){
            realAmount = cpb;
        }
        lpToken.transfer(msg.sender, realAmount);
        cpToken1.transferFrom(msg.sender, address(this), realAmount);
        cpToken2.transferFrom(msg.sender, address(this), realAmount);
        balanceOfLpToken[msg.sender] = balanceOfLpToken[msg.sender].sub(realAmount);
        if(stakingList[msg.sender][index].amount==realAmount){
            uint256 bNumber = block.number.sub(stakingList[msg.sender][index].lastSettleBlockNumber);
            totalBlockOfCurrentRound[msg.sender] = totalBlockOfCurrentRound[msg.sender].add(bNumber);
            stakingList[msg.sender][index].isLiving = false;
            clearCount[msg.sender] = clearCount[msg.sender].add(1);
        }else{
            stakingList[msg.sender][index].amount = stakingList[msg.sender][index].amount.sub(realAmount);
        }
        balanceOfComputePower[msg.sender] = balanceOfComputePower[msg.sender].sub(realAmount);
        totalUnStakingTimesOfCurrentRound[msg.sender] = totalUnStakingTimesOfCurrentRound[msg.sender].add(1);
    }

    function settle() public onlySettle{
        uint256 currentBlock = block.number;
        uint256 releaseAplAmount = currentBlock.sub(lastSettleBlockNumber).mul(claimPerBlock);
        settleData1 = currentBlock;
        settleData2 = lastSettleBlockNumber;
        settleData = currentBlock.sub(settleData2);

        uint256 totalCp = totalHistoryIncreasedCp();
        uint256 totalBlock = totalHistoryIncreasedBlock();
        uint256 totalTimes = totalWithdrawTimes();

        uint256 nowTime = block.timestamp;
        uint256 total = 0;  

        if(settleCount==0){
            if(totalTimes >= 10){
                for(uint256 k=0; k < addressList.length; k++){
                    uint256 timeRatioNumber = totalUnStakingTimesOfCurrentRound[addressList[k]].div(totalTimes).mul(100);
                    unstakingScoreBalance[addressList[k]] = unstakingLevelMapping(timeRatioNumber);
                    totalUnStakingTimesOfHistory[addressList[k]] = totalUnStakingTimesOfHistory[addressList[k]].add(totalUnStakingTimesOfCurrentRound[addressList[k]]);
                    totalUnStakingTimesOfCurrentRound[addressList[k]] = 0;
                    balanceOfCpForCurrentRound[addressList[k]] = balanceOfComputePower[addressList[k]].mul(balanceOfScore[addressList[k]].sub(unstakingScoreBalance[addressList[k]]));
                    total = total.add(balanceOfCpForCurrentRound[addressList[k]]);
                    balanceOfScore[addressList[k]] = balanceOfScore[addressList[k]].sub(unstakingScoreBalance[addressList[k]]);
                    // unstakingScoreBalance[addressList[k]] = 0;
                }
            }else{
                for(uint256 k=0; k < addressList.length; k++){
                    totalUnStakingTimesOfHistory[addressList[k]] = totalUnStakingTimesOfHistory[addressList[k]].add(totalUnStakingTimesOfCurrentRound[addressList[k]]);
                    totalUnStakingTimesOfCurrentRound[addressList[k]] = 0;
                    balanceOfCpForCurrentRound[addressList[k]] = balanceOfComputePower[addressList[k]].mul(balanceOfScore[addressList[k]]);
                    total = total.add(balanceOfCpForCurrentRound[addressList[k]]);
                    unstakingScoreBalance[addressList[k]] = 0;
                }
            }

            for(uint256 n=0; n < addressList.length; n++){
                balanceOfHistoryIncresedComputePower[addressList[n]] = balanceOfHistoryIncresedComputePower[addressList[n]].add(balanceOfCurrentIncresedComputePower[addressList[n]]);
                balanceOfCurrentIncresedComputePower[addressList[n]] = 0;

                uint256 livingCount = 0;
                for(uint256 j=0; j<stakingList[addressList[n]].length; j++){
                    uint256 timeSpan = nowTime.sub(stakingList[addressList[n]][j].initStakingTime);
                    if(timeSpan >= ONE_MONTH_IN_SECONDS){
                        if(stakingList[addressList[n]][j].isLiving){
                            totalBlockOfCurrentRound[addressList[n]] = totalBlockOfCurrentRound[addressList[n]].add(currentBlock.sub(stakingList[addressList[n]][j].lastSettleBlockNumber));
                            stakingList[addressList[n]][j].lastSettleTime = nowTime;
                            stakingList[addressList[n]][j].lastSettleBlockNumber = block.number;
                            livingCount = livingCount.add(1);
                        }
                    }else{
                        if(stakingList[addressList[n]][j].isLiving){
                            stakingList[addressList[n]][j].lastSettleTime = nowTime;
                            stakingList[addressList[n]][j].lastSettleBlockNumber = block.number;
                            livingCount = livingCount.add(1);
                        }
                    }
                }
                uint256 realBlockNum = totalBlockOfCurrentRound[addressList[n]].div(livingCount.add(clearCount[addressList[n]]));
                totalBlockOfCurrentRound[addressList[n]] = 0;
                clearCount[addressList[n]] = 0;
                balanceOfHistoryIncresedBlock[addressList[n]] = balanceOfHistoryIncresedBlock[addressList[n]].add(realBlockNum);
            }
        }else{
            uint256 cunrrentLpBalance = lpToken.balanceOf(address(this));
            for(uint256 i=0; i < addressList.length; i++){
                if(cunrrentLpBalance>=5000*10**18){
                    uint256 cpRatioNumber = balanceOfCurrentIncresedComputePower[addressList[i]].div(totalCp).mul(100);
                    cpScoreBalance[addressList[i]] = cpLevelMapping(cpRatioNumber);
                    balanceOfHistoryIncresedComputePower[addressList[i]] = balanceOfHistoryIncresedComputePower[addressList[i]].add(balanceOfCurrentIncresedComputePower[addressList[i]]);
                    balanceOfCurrentIncresedComputePower[addressList[i]] = 0;
                }else{
                    balanceOfCurrentIncresedComputePower[addressList[i]] = 0;
                    cpScoreBalance[addressList[i]] = 0;
                }

                uint256 livingCount = 0;
                for(uint256 j=0; j<stakingList[addressList[i]].length; j++){
                    uint256 timeSpan = nowTime.sub(stakingList[addressList[i]][j].initStakingTime);
                    if(timeSpan >= ONE_MONTH_IN_SECONDS){
                        if(stakingList[addressList[i]][j].isLiving){
                            totalBlockOfCurrentRound[addressList[i]] = totalBlockOfCurrentRound[addressList[i]].add(currentBlock.sub(stakingList[addressList[i]][j].lastSettleBlockNumber));
                            stakingList[addressList[i]][j].lastSettleTime = nowTime;
                            stakingList[addressList[i]][j].lastSettleBlockNumber = block.number;
                            livingCount = livingCount.add(1);
                        }
                    }else{
                        if(stakingList[addressList[i]][j].isLiving){
                            stakingList[addressList[i]][j].lastSettleTime = nowTime;
                            stakingList[addressList[i]][j].lastSettleBlockNumber = block.number;
                            livingCount = livingCount.add(1);
                        }
                    }
                }
                uint256 realBlockNum = totalBlockOfCurrentRound[addressList[i]].div(livingCount.add(clearCount[addressList[i]]));
                uint256 blockRatioNumber = realBlockNum.div(totalBlock).mul(100);
                blockScoreBalance[addressList[i]] = blockLevelMapping(blockRatioNumber);
                totalBlockOfCurrentRound[addressList[i]] = 0;
                clearCount[addressList[i]] = 0;
                balanceOfHistoryIncresedBlock[addressList[i]] = balanceOfHistoryIncresedBlock[addressList[i]].add(realBlockNum);
                
                if(totalTimes >= 10){
                    uint256 timeRatioNumber = totalUnStakingTimesOfCurrentRound[addressList[i]].div(totalTimes).mul(100);
                    unstakingScoreBalance[addressList[i]] = unstakingLevelMapping(timeRatioNumber);
                }
                totalUnStakingTimesOfHistory[addressList[i]] = totalUnStakingTimesOfHistory[addressList[i]].add(totalUnStakingTimesOfCurrentRound[addressList[i]]);
                totalUnStakingTimesOfCurrentRound[addressList[i]] = 0;

                uint256 totalScore = balanceOfScore[addressList[i]].add(cpScoreBalance[addressList[i]]).add(blockScoreBalance[addressList[i]]).sub(unstakingScoreBalance[addressList[i]]);
                balanceOfScore[addressList[i]] = totalScore;
                if(totalScore < minScore){
                    totalScore = minScore;
                }
                if(totalScore > maxScore){
                    totalScore = maxScore;
                }
                balanceOfCpForCurrentRound[addressList[i]] = balanceOfComputePower[addressList[i]].mul(totalScore);
                total = total.add(balanceOfCpForCurrentRound[addressList[i]]);
            }
        }

        for(uint256 m=0; m < addressList.length; m++){
            lastMolecular[addressList[m]] = balanceOfCpForCurrentRound[addressList[m]];
            lastDenominator[addressList[m]] = total;
            uint256 amount = releaseAplAmount.mul(balanceOfCpForCurrentRound[addressList[m]]).div(total);
            unclaimBalance[addressList[m]] = unclaimBalance[addressList[m]].add(amount);
            balanceOfCpForCurrentRound[addressList[m]] = 0;
        }
        settleCount = settleCount.add(1);
        lastSettleBlockNumber = currentBlock;
    }

    function totalHistoryIncreasedCp() public view returns(uint256) {
        uint256 total = 0;
        for(uint256 i=0; i < addressList.length; i++){
            total = total.add(balanceOfHistoryIncresedComputePower[addressList[i]]);
        }
        return total;
    }

    function totalHistoryIncreasedBlock() public view returns(uint256) {
        uint256 total = 0;
        for(uint256 i=0; i < addressList.length; i++){
            total = total.add(balanceOfHistoryIncresedBlock[addressList[i]]);
        }
        return total;
    }

    function totalWithdrawTimes() public view returns(uint256) {
        uint256 total = 0;
        for(uint256 i=0; i < addressList.length; i++){
            total = total.add(totalUnStakingTimesOfHistory[addressList[i]]);
            total = total.add(totalUnStakingTimesOfCurrentRound[addressList[i]]);
        }
        return total;
    }

    function cpLevelMapping(uint256 ratio) public pure returns(uint256) {
        if(ratio==0){
            return 0;
        }else if(ratio>0 && ratio<20){
            return 5;
        }else if(ratio>=20 && ratio<40){
            return 10;
        }else if(ratio>=40 && ratio<60){
            return 15;
        }else if(ratio>=60 && ratio<80){
            return 20;
        }else{
            return 25;
        }
    }

    function blockLevelMapping(uint256 ratio) public pure returns(uint256) {
        if(ratio==0){
            return 0;
        }else if(ratio>0 && ratio<20){
            return 1;
        }else if(ratio>=20 && ratio<40){
            return 2;
        }else if(ratio>=40 && ratio<60){
            return 3;
        }else if(ratio>=60 && ratio<80){
            return 4;
        }else{
            return 5;
        }
    } 

    function unstakingLevelMapping(uint256 ratio) private pure returns(uint256) {
        if(ratio==0){
            return 0;
        }else if(ratio>0 && ratio<20){
            return 6;
        }else if(ratio>=20 && ratio<40){
            return 8;
        }else if(ratio>=40 && ratio<60){
            return 11;
        }else if(ratio>=60 && ratio<80){
            return 15;
        }else{
            return 20;
        }
    } 

    function getDepositedRecords(address _address) public view returns(stakeEntity[] memory){
        return stakingList[_address];
    }

    function claim(uint256 _amount) public {
        uint256 leftAmount = unclaimBalance[msg.sender];
        require(leftAmount >= _amount, "Not enough APL");
        aplToken.transfer(msg.sender, _amount);
        withdrawedApl[msg.sender] = withdrawedApl[msg.sender].add(_amount);
        unclaimBalance[msg.sender] = unclaimBalance[msg.sender].sub(_amount);
        claimEntity memory entity = claimEntity(block.timestamp, block.number, _amount);
        claimList[msg.sender].push(entity);
    }

    function getClaimRecords(address _address) public view returns(claimEntity[] memory){
        return claimList[_address];
    }

    function getClaimPerBlock() public view returns(uint256) {
        return claimPerBlock;
    }

    function getUnclaim(address _address) public view returns(uint256) {
        return unclaimBalance[_address];
    }

    function getProfit(address _address) public view returns(uint256) {
        return withdrawedApl[_address];
    }

    function getTotalUnclaim() public view returns(uint256) {
        uint256 total = 0;
        for(uint8 i=0; i < addressList.length; i++){
            total = total.add(unclaimBalance[addressList[i]]);
        }
        return total;
    }

    function getTotalAddresses() public view returns(uint256) {
        return addressList.length;
    }

    function systemTotalWithdrawedAplAmount() public view returns(uint256) {
        uint256 total = 0;
        for(uint8 i=0; i < addressList.length; i++){
            total = total.add(withdrawedApl[addressList[i]]);
        }
        return total;
    }

    function getTotalLock() public view returns(uint256) {
        uint256 total = 0;
        for(uint8 i=0; i < addressList.length; i++){
            total = total.add(balanceOfLpToken[addressList[i]]);
        }
        return total;
    }

    function getMyLock() public view returns(uint256) {
        return balanceOfLpToken[msg.sender];
    }

    function setSettleAddress(address _address) public onlySubOwner {
        require(_address!=address(0), "Invalid address");
        settleAddress = _address;
    }

    function setParameterAddress(address _address) public onlySubOwner {
        require(_address!=address(0), "Invalid address");
        parameterAddress = _address;
    }

    function setSubOwnerAddress(address _address) public onlyOwner {
        require(_address!=address(0), "Invalid address");
        subOwnerAddress = _address;
    }

    function getAllBlocks() private view returns(uint256) {
        uint256 total = 0;
        for(uint256 k=0; k < addressList.length; k++){
            for(uint256 j=0; j < stakingList[addressList[k]].length; j++){
               stakeEntity memory entity = stakingList[addressList[k]][j];
               if(entity.isLiving){
                   total = total.add(block.number.sub(entity.lastSettleBlockNumber));
               }else{
                   total = total.add(totalBlockOfCurrentRound[addressList[k]]);
               }
            }
        }
        return total;
    }

    function getCUrrentBlockNumber() public view returns(uint256){
        return block.number;
    }

    function getPreDictApl() public view returns(uint256) {
        uint256 currentBlock = block.number;
        stakeEntity[] memory list = stakingList[msg.sender];
        uint256 total = 0;
        for(uint256 m=0; m < list.length; m++){
            total = total.add(currentBlock.sub(list[m].lastSettleBlockNumber));
        }
        return total.mul(lastMolecular[msg.sender]).div(lastDenominator[msg.sender]);
    }

    function getLastRatio() public view returns(uint256) {
        return lastDenominator[msg.sender].div(lastMolecular[msg.sender]);
    }

    function getCurrentScore() public view returns(uint256) {
        return balanceOfScore[msg.sender];
    }

    function getCpScore() public view returns(uint256) {
        return cpScoreBalance[msg.sender];
    }

    function getBlockScore() public view returns(uint256) {
        return blockScoreBalance[msg.sender];
    }

    function getWithdrawScore() public view returns(uint256) {
        return unstakingScoreBalance[msg.sender];
    }
}