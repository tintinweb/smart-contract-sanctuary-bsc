// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ISportBe.sol";

contract SportBe is Ownable,ISportBe{
    using SafeMath for uint256;
    
    //gameId to game
    mapping(uint256=>Game) private _games;

    address private _apiConsumerAddress;

    address private _usdtAddress;

    uint256 private _feeRate; // 1000

    address private _feeAddress;

    uint256 private _minAmount;

    uint256 private _referrerRate; // 1000

    event AddGame(AddGameParam addGameParam,uint256 addGameAt);

    event Bet(address user,BetParam betParam, uint256 betAt);

    event Claim(address user,ClaimParam claimParam, uint256 amount, uint256 claimAt);

    function setAddress(address apiConsumerAddress,address usdtAddress,uint256 feeRate, address feeAddress, uint256 minAmount,uint256 referrerRate) public onlyOwner
    {
        if(apiConsumerAddress != address(0)){
            _apiConsumerAddress = apiConsumerAddress;
        }
        if(usdtAddress != address(0)){
            _usdtAddress = usdtAddress;
        }
        if(feeRate != 0){
            _feeRate = feeRate;
        }
        if(feeAddress != address(0)){
            _feeAddress = feeAddress;
        }
        if(minAmount != 0){
            _minAmount = minAmount;
        }

        _referrerRate = referrerRate;
    }

    function batchAddGame(AddGameParam[] memory addGameParams)  public onlyOwner
    {
        for (uint256 index = 0; index < addGameParams.length; index++) {
            addGame(addGameParams[index]);
        }
    }

    function addGame(AddGameParam memory addGameParam) public onlyOwner
    {
        _games[addGameParam.gameId].gameId = addGameParam.gameId;
        _games[addGameParam.gameId].roundNum = addGameParam.roundNum;
        _games[addGameParam.gameId].gameName = addGameParam.gameName;
        _games[addGameParam.gameId].betEndTime = addGameParam.betEndTime;
        _games[addGameParam.gameId].startTime = addGameParam.startTime;
        _games[addGameParam.gameId].endTime =  addGameParam.endTime;
        _games[addGameParam.gameId].maxHomeScore = addGameParam.maxHomeScore;
        _games[addGameParam.gameId].maxAwayScore = addGameParam.maxAwayScore;
        _games[addGameParam.gameId].maxTotalScore = addGameParam.maxHomeScore + addGameParam.maxAwayScore;

        emit AddGame(addGameParam,block.timestamp);
    }

    //test
    function batchBet(BetParam[] memory betParams) public
    {
        for (uint256 index = 0; index < betParams.length; index++) {
            bet(betParams[index]);
        }
    }
    function bet(BetParam memory betParam) public 
    {
        require(betParam.amount>= _minAmount,"amount less than minAmount");
        Game storage game = _games[betParam.gameId];
        require(block.timestamp <= game.betEndTime,"over game betEndTime");
        // transfer token
        IERC20(_usdtAddress).transferFrom(_msgSender(), address(this), betParam.amount);

        Pool storage pool = game.winOrLosePools[betParam.winOrLose];

        if(betParam.betType == 0){
            require(betParam.winOrLose == 0 || betParam.winOrLose == 1 || betParam.winOrLose == 2);
            game.winOrLosePoolsTotalAmount += betParam.amount;
        }

        if(betParam.betType == 1){
            if(betParam.homeScore > game.maxHomeScore || betParam.awayScore > game.maxAwayScore){
                betParam.homeScore = 99;
                betParam.awayScore = 99;
            }
            pool = game.scorePools[betParam.homeScore][betParam.awayScore];
            game.scorePoolsTotalAmount += betParam.amount;
        }

        if(betParam.betType == 2){
            require(betParam.totalScore >= 0);
            if(betParam.totalScore > game.maxTotalScore){
                betParam.totalScore = 99;
            }
            pool = game.totalScorePools[betParam.totalScore];
            game.totalScorePoolsTotalAmount += betParam.amount;
        }

        pool.userAmount[_msgSender()] += betParam.amount;
        pool.poolAmount += betParam.amount;
        if(betParam.referrerAddress != address(0)){
            pool.referrerAmount[_msgSender()][betParam.referrerAddress] += betParam.amount;
            pool.referrerAddress[_msgSender()].push(betParam.referrerAddress);
        }

        emit Bet(_msgSender(),betParam,block.timestamp);
    }


    function batchClaim(ClaimParam[] memory claimParams) public
    {
        for (uint256 index = 0; index < claimParams.length; index++) {
            claim(claimParams[index]);
        }
    }
    function claim(ClaimParam memory claimParam) public 
    {
        Game storage game = _games[claimParam.gameId];
        require(block.timestamp >= game.claimStartTime && game.claimStartTime !=0,"over game startTime");

        UserBetReturn memory userBetReturn = getUserBet(claimParam,_msgSender());
        if(userBetReturn.userClaimd){
            return;
        }
        Pool storage pool = game.winOrLosePools[claimParam.winOrLose];
        if(claimParam.claimType == 0){
            pool = game.winOrLosePools[claimParam.winOrLose];
        }else if(claimParam.claimType == 1){
            if(claimParam.homeScore > game.maxHomeScore || claimParam.awayScore > game.maxAwayScore){
                claimParam.homeScore = 99;
                claimParam.awayScore = 99;
            }
            pool = game.scorePools[claimParam.homeScore][claimParam.awayScore];
        }else if(claimParam.claimType == 2){
            if(claimParam.totalScore > game.maxTotalScore){
                claimParam.totalScore = 99;
            }
            pool = game.totalScorePools[claimParam.totalScore];
        }
        pool.userClaimed[_msgSender()] = true;

        if(userBetReturn.userWinAmount == 0 ){
            return;
        }

        //trasfer token
        uint256 fee = userBetReturn.userWinAmount.mul(_feeRate).div(1000);

        IERC20(_usdtAddress).transfer(_feeAddress , fee);

        uint256 referrerTotal = 0;
        if(userBetReturn.referrerAddress.length != 0){
            for (uint256 index = 0; index < userBetReturn.referrerAddress.length; index++) {
                uint256 referrerFee = userBetReturn.userWinAmount.mul(_referrerRate).div(1000).mul(userBetReturn.referrerAmount[index]).div(userBetReturn.userBetAmount);
                IERC20(_usdtAddress).transfer(userBetReturn.referrerAddress[index] , referrerFee);
                referrerTotal += referrerFee;
            }
        }else{
            referrerTotal = userBetReturn.userWinAmount.mul(_referrerRate).div(1000);
            IERC20(_usdtAddress).transfer(_feeAddress , referrerTotal);
        }
        
        IERC20(_usdtAddress).transfer(_msgSender() , userBetReturn.userWinAmount.sub(fee).sub(referrerTotal));

        emit Claim(_msgSender(),claimParam,userBetReturn.userWinAmount,block.timestamp);

    }

    function setGameWinScore(uint256 gameId,uint256 winHomeScore, uint256 winAwayScore) public override
    {
        require(_msgSender() == _apiConsumerAddress,"not you");
        Game storage game = _games[gameId];
        require(block.timestamp >= game.endTime,"game isn't over");
        game.claimStartTime = block.timestamp;
        if(winHomeScore < winAwayScore){
            game.winOrLose = 0;
        }else if(winHomeScore > winAwayScore){
            game.winOrLose = 1;
        }else{
            game.winOrLose = 2;
        }

        game.winWinOrLosePoolAmount = game.winOrLosePools[game.winOrLose].poolAmount;
        //winWinOrLosePoolAmount == 0 ,transfer to manager Address
        if(game.winWinOrLosePoolAmount == 0){
            IERC20(_usdtAddress).transfer(_feeAddress,game.winOrLosePoolsTotalAmount);
        }

        uint256 totalScore = winHomeScore.add(winAwayScore);
        if(totalScore > game.maxTotalScore){
            game.totalScore = 99;
        }else{
            game.totalScore = totalScore;
        }
        game.winTotalScorePoolAmount = game.totalScorePools[game.totalScore].poolAmount;
        if(game.winTotalScorePoolAmount == 0){
            IERC20(_usdtAddress).transfer(_feeAddress,game.totalScorePoolsTotalAmount);
        }

        if(winHomeScore > game.maxHomeScore || winAwayScore > game.maxAwayScore){
            winHomeScore = 99;
            winAwayScore = 99;
        }
        game.winHomeScore = winHomeScore;
        game.winAwayScore = winAwayScore;
        game.winScorePoolAmount = game.scorePools[winHomeScore][winAwayScore].poolAmount;
        if(game.winScorePoolAmount == 0){
            IERC20(_usdtAddress).transfer(_feeAddress,game.scorePoolsTotalAmount);
        }
    }

    function getUserBetAmount(uint256 gameId,uint256 betType,uint256 homeScore, uint256 awayScore,uint256 winOrLose,uint256 totalScore,address user) public view returns(uint256 poolsTotalAmount,uint256 poolAmount,uint256 userAmount,bool userClaimd)
    {
        Game storage game = _games[gameId];
        
        Pool storage pool = game.winOrLosePools[winOrLose];
        if(betType == 0){
            poolsTotalAmount = game.winOrLosePoolsTotalAmount;
            pool = game.winOrLosePools[winOrLose]; 
        }else if(betType == 1){
            poolsTotalAmount = game.scorePoolsTotalAmount;
            pool = game.scorePools[homeScore][awayScore];
            if(homeScore > game.maxHomeScore || awayScore > game.maxAwayScore){
                pool = game.scorePools[99][99];
            }    
        }else if(betType == 2){
            poolsTotalAmount = game.totalScorePoolsTotalAmount;
            pool = game.totalScorePools[totalScore];
            if(totalScore > game.maxTotalScore){
                pool = game.totalScorePools[99];
            }
        }

        poolAmount = pool.poolAmount;
        userAmount = pool.userAmount[user];
        userClaimd = pool.userClaimed[user];
    }

    function getUserBet(ClaimParam memory claimParam,address user) internal view returns(UserBetReturn memory userBetReturn){
        Game storage game = _games[claimParam.gameId];
        if(block.timestamp >= game.claimStartTime){

            Pool storage pool = game.winOrLosePools[claimParam.winOrLose];
            bool flag = false;
            if(claimParam.claimType == 0){
                userBetReturn.poolsTotalAmount = game.winOrLosePoolsTotalAmount;
                pool = game.winOrLosePools[claimParam.winOrLose]; 

                if(game.winOrLose == claimParam.winOrLose){
                    flag = true;
                }
            }else if(claimParam.claimType == 1){
                userBetReturn.poolsTotalAmount = game.scorePoolsTotalAmount;
                pool = game.scorePools[claimParam.homeScore][claimParam.awayScore];
                if(claimParam.homeScore > game.maxHomeScore || claimParam.awayScore > game.maxAwayScore){
                    claimParam.homeScore = 99;
                    claimParam.awayScore = 99;

                    pool = game.scorePools[99][99];
                }
                if(game.winHomeScore == claimParam.homeScore && game.winAwayScore == claimParam.awayScore){
                    flag = true;
                }
            }else if(claimParam.claimType == 2){
                userBetReturn.poolsTotalAmount = game.totalScorePoolsTotalAmount;
                pool = game.totalScorePools[claimParam.totalScore];

                if(claimParam.totalScore > game.maxTotalScore){
                    claimParam.totalScore = 99;

                    pool = game.totalScorePools[99];
                }
                if(game.totalScore == claimParam.totalScore ){
                    flag = true;
                }
            }

            if(flag){

                if(pool.referrerAddress[user].length !=0){
                    userBetReturn.referrerAddress = new address[](pool.referrerAddress[user].length);
                    userBetReturn.referrerAmount = new uint256[](pool.referrerAddress[user].length);

                    for (uint256 index = 0; index < pool.referrerAddress[user].length; index++) {
                        userBetReturn.referrerAddress[index] = pool.referrerAddress[user][index];
                        userBetReturn.referrerAmount[index] = pool.referrerAmount[user][userBetReturn.referrerAddress[index]];
                    }
                }

                userBetReturn.userClaimd = pool.userClaimed[user];
                userBetReturn.userBetAmount = pool.userAmount[user];
                userBetReturn.userWinAmount = pool.userAmount[user].mul(userBetReturn.poolsTotalAmount).div(pool.poolAmount);
            }
        }
    }

    function getGames(uint256 gameId)public view returns(
        string memory gameName,
        uint256 betEndTime,
        uint256 startTime,
        uint256 endTime,
        uint256 claimStartTime
    ){
        gameName = _games[gameId].gameName;
        betEndTime = _games[gameId].betEndTime;
        startTime = _games[gameId].startTime;
        endTime = _games[gameId].endTime;
        claimStartTime = _games[gameId].claimStartTime;
       
    }

    function getGameResult(uint256 gameId)public view returns(
        string memory gameName,
        uint256 winHomeScore,
        uint256 winAwayScore,
        uint256 winScorePoolAmount,
        uint256 scorePoolsTotalAmount,
        uint256 winOrLose,
        uint256 winWinOrLosePoolAmount,
        uint256 winOrLosePoolsTotalAmount,
        uint256 totalScore,
        uint256 winTotalScorePoolAmount,
        uint256 totalScorePoolsTotalAmount)
    {
        gameName = _games[gameId].gameName;
        
        winHomeScore = _games[gameId].winHomeScore;
        winAwayScore = _games[gameId].winAwayScore;
        winScorePoolAmount = _games[gameId].winScorePoolAmount;
        scorePoolsTotalAmount = _games[gameId].scorePoolsTotalAmount;

        winOrLose = _games[gameId].winOrLose;
        winWinOrLosePoolAmount = _games[gameId].winWinOrLosePoolAmount;
        winOrLosePoolsTotalAmount = _games[gameId].winOrLosePoolsTotalAmount;

        totalScore = _games[gameId].totalScore;
        winTotalScorePoolAmount = _games[gameId].winTotalScorePoolAmount;
        totalScorePoolsTotalAmount = _games[gameId].totalScorePoolsTotalAmount;
    }

    //scorePoolAmounts order: 0=0:0,1=0:1,2=0:2,3=0:3,4=0:4,5=0:5,6=1:0,7=1:1,...35=5:5,36=99:99   
    function getPoolBetAmount(uint256 gameId)public view returns(uint256[] memory scorePoolAmounts,uint256[] memory winOrLosePoolAmounts,uint256[] memory totalScorePoolAmounts)
    {
        Game storage game = _games[gameId];
        uint256 maxHomeScore = game.maxHomeScore;
        uint256 maxAwayScore = game.maxAwayScore;
        uint256 totalResultNum = (maxHomeScore+1)*(maxAwayScore+1)+1;
        uint256 startIndex = 0;
        scorePoolAmounts = new uint256[](totalResultNum);
        for (uint256 homeScore = 0; homeScore <= maxHomeScore; homeScore++) {
            for (uint256 awayScore = 0; awayScore <= maxAwayScore; awayScore++) {
                Pool storage scorePool = game.scorePools[homeScore][awayScore];
                scorePoolAmounts[startIndex]=scorePool.poolAmount;
                startIndex ++;
            } 
        } 
        scorePoolAmounts[totalResultNum-1] = game.scorePools[99][99].poolAmount;

        winOrLosePoolAmounts = new uint256[](3);
        for (uint256 winOrLose = 0; winOrLose < 3; winOrLose++) {
            Pool storage winOrLosePool = game.winOrLosePools[winOrLose];
            winOrLosePoolAmounts[winOrLose]=winOrLosePool.poolAmount;
        } 

        //add >10
        totalScorePoolAmounts = new uint256[](game.maxTotalScore + 2);
        for (uint256 totalScore = 0; totalScore <= game.maxTotalScore; totalScore++) {
            Pool storage totalScorePool = game.totalScorePools[totalScore];
            totalScorePoolAmounts[totalScore]=totalScorePool.poolAmount;
        } 
        totalScorePoolAmounts[game.maxTotalScore + 1] = game.totalScorePools[99].poolAmount;
    }

    // function getNow() public view returns(uint256 times){
    //     times = block.timestamp;
    // }

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
pragma solidity ^0.8.7;

interface ISportBe{

     struct Game{
        uint256 gameId;
        uint256 roundNum;
        string gameName;
        uint256 betEndTime;
        uint256 startTime;
        uint256 endTime;
        uint256 claimStartTime;

        //----game1----
        uint256 scorePoolsTotalAmount;
        //home score => away score
        mapping(uint256=>mapping(uint256=>Pool)) scorePools;

        uint256 winHomeScore;
        uint256 winAwayScore;

        uint256 winScorePoolAmount;

        //over max score = 99:99
        uint256 maxHomeScore;
        uint256 maxAwayScore;

        //----game2----
        //Home 0:Defeat 1:Victory 2:Tie
        uint256 winOrLose;

        uint256 winWinOrLosePoolAmount;

        uint256 winOrLosePoolsTotalAmount;

        mapping(uint256=>Pool) winOrLosePools;

        //----game3----
        uint256 totalScore;

        uint256 maxTotalScore;

        uint256 winTotalScorePoolAmount;

        uint256 totalScorePoolsTotalAmount;

        mapping(uint256=>Pool) totalScorePools;

    }

    struct Pool{
        uint256 poolAmount;
        mapping(address=>uint256) userAmount;
        mapping (address=>bool) userClaimed;
        mapping(address=>mapping(address=>uint256)) referrerAmount;
        mapping(address=>address[]) referrerAddress;
    }

    struct AddGameParam{
        uint256 gameId;
        uint256 roundNum;
        string  gameName;
        uint256 betEndTime;
        uint256 startTime;
        uint256 endTime;
        uint256 maxHomeScore;
        uint256 maxAwayScore;
    }

    struct BetParam{
        uint256 gameId;
        uint256 betType;//0:victoryOrDefeat 1:score 2:totalScore
        uint256 homeScore; 
        uint256 awayScore;
        uint256 winOrLose;
        uint256 totalScore;
        address referrerAddress;
        uint256 amount;
    }

    struct ClaimParam{
        uint256 gameId;
        uint256 claimType;//0:victoryOrDefeat 1:score 2:totalScore
        uint256 homeScore; 
        uint256 awayScore;
        uint256 winOrLose;
        uint256 totalScore;
    }

    struct UserBetReturn{
        uint256 poolsTotalAmount;
        uint256 poolAmount;
        uint256 userBetAmount;
        uint256 userWinAmount;
        address[] referrerAddress;
        uint256[] referrerAmount;
        bool userClaimd;
    }

    function setGameWinScore(uint256 gameId,uint256 winHomeScore, uint256 winAwayScore) external; 
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