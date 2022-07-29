/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

pragma solidity 0.8.15;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
contract RUBBERFINANCE{
    using SafeMath for uint256;

    address owner=0xa5A0039B60a91b5220E4E5Cd1CdEC02a3C1CC3ee;
    address RUBBERDUCKIES=address(0);
    address chainLinkAggregatorInterface=address(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);

    AggregatorInterface public chainLinkPrice=AggregatorInterface(chainLinkAggregatorInterface);
    IBEP20 public rubberInstance = IBEP20(RUBBERDUCKIES);


    uint256 pooledTokens=0;

    mapping(address=>bool) activeBet;
    mapping(address=>int256) lockedPriceForUser;
    mapping(address=>uint256) minimumTimestampForAnswer;
    mapping(address=>uint256) maximumTimeStampForAnswer;
    mapping(address=>bool) isBull;
    mapping(address=>uint256) contractValue;
    mapping(address=>bool) claimed;

    uint256 maximumOffset=43200;
    uint256 minimumOffset=43200;
    uint256 dividor=432;

    function withdrawFromPool(uint256 amount) public {
        require(msg.sender==owner);
        rubberInstance.transfer(msg.sender,amount);
    }

    function modifyDivisor(uint256 divisor) public {
        require(msg.sender==owner);
        dividor=divisor;
    }

    function modifyOffsets(uint256 offset) public{
        require(msg.sender==owner);
        maximumOffset=offset;
        minimumOffset=offset;
    }

  function setRubberToken(address token) public {
        require(msg.sender==owner);
        RUBBERDUCKIES=token;
        rubberInstance = IBEP20(RUBBERDUCKIES);        
    }    

    function getTimeLeftUntilContractUnlock(address user) public view returns(uint256){
        return SafeMath.sub(minimumTimestampForAnswer[user],block.timestamp);

    }

    function getTimeLeftUntilContractExpires(address user) public view returns(uint256){
        return SafeMath.sub(maximumTimeStampForAnswer[user],block.timestamp);
    }

    function getContractType(address user) public view returns(bool){
        return isBull[user];
    }

    function getLockedPriceOfContract(address user) public view returns(int256){
        return lockedPriceForUser[user];
    }

    function getContractValue(address user) public view returns(uint256){
        return contractValue[user];
    }

    function poolTokens(uint256 amount) public {
        rubberInstance.transferFrom(msg.sender,address(this),amount);
        pooledTokens=pooledTokens.add(amount);
    }

    function getContractProfit(address user) public view returns(uint256){
        uint256 latestRound=chainLinkPrice.latestRound();
        uint256 currentChainLinkTimeStamp=chainLinkPrice.getTimestamp(latestRound);
        require(minimumTimestampForAnswer[user]<currentChainLinkTimeStamp,"Your contract has not been unlocked!");
        require(block.timestamp<maximumTimeStampForAnswer[user],"Your contract has expired!");
        int256 currentBTCPrice=chainLinkPrice.latestAnswer();

        if(currentBTCPrice>lockedPriceForUser[msg.sender] && isBull[msg.sender]==true){
            //Won
            uint256 penalty=SafeMath.div(SafeMath.sub(maximumTimeStampForAnswer[msg.sender],block.timestamp),dividor);
            if(penalty==0){
                penalty=1;
            }
            uint256 winMultiplier=SafeMath.div(maximumOffset,SafeMath.mul(penalty,dividor));
            require(winMultiplier<=100,"Multiplier greater than 100");

            uint256 winAmount=SafeMath.add(contractValue[msg.sender],(SafeMath.div(contractValue[msg.sender],100)));
            return winAmount;
        } else if(currentBTCPrice<lockedPriceForUser[msg.sender] && isBull[msg.sender]==false){
            //Won
            uint256 penalty=SafeMath.div(SafeMath.sub(maximumTimeStampForAnswer[msg.sender],block.timestamp),dividor);
            if(penalty==0){
                penalty=1;
            }
            uint256 winMultiplier=SafeMath.div(maximumOffset,SafeMath.mul(penalty,dividor));
            require(winMultiplier<=100,"Multiplier greater than 100");

            uint256 winAmount=SafeMath.add(contractValue[msg.sender],(SafeMath.div(contractValue[msg.sender],100)));
            return winAmount;         
        } else {
            return 0;
        }  

    }

    function getStatusOfContract(address user) public view returns(bool){
        if(block.timestamp>maximumTimeStampForAnswer[user]){
            return false;
        } else {
            return true;
        }
    }

    function enoughLiquidityForBet(uint256 amount) public view returns(bool){
        if(rubberInstance.balanceOf(address(this))>SafeMath.mul(amount,2)){
            return true;
        } else {
            return false;
        }
    }

    function claim() public {
        require(activeBet[msg.sender]==true,"No active contract.");
        uint256 latestRound=chainLinkPrice.latestRound();
        uint256 currentChainLinkTimeStamp=chainLinkPrice.getTimestamp(latestRound);
        require(claimed[msg.sender]==false,"Already claimed");
        require(minimumTimestampForAnswer[msg.sender]<currentChainLinkTimeStamp,"Your contract has not been unlocked!");
        require(block.timestamp>maximumTimeStampForAnswer[msg.sender],"Your contract has expired!");
        int256 currentBTCPrice=chainLinkPrice.latestAnswer();

        if(currentBTCPrice>lockedPriceForUser[msg.sender] && isBull[msg.sender]==true){
            //Won
            uint256 penalty=SafeMath.div(SafeMath.sub(maximumTimeStampForAnswer[msg.sender],block.timestamp),dividor);
            if(penalty==0){
                penalty=1;
            }
            uint256 winMultiplier=SafeMath.div(maximumOffset,SafeMath.mul(penalty,dividor));
            require(winMultiplier<=100,"Multiplier greater than 100");

            uint256 winAmount=SafeMath.add(contractValue[msg.sender],(SafeMath.div(contractValue[msg.sender],100)));
            pooledTokens=pooledTokens.sub(winAmount);
            claimed[msg.sender]=true;
            rubberInstance.transfer(msg.sender,winAmount);
            
        }

        if(currentBTCPrice<lockedPriceForUser[msg.sender] && isBull[msg.sender]==false){
            //Won
            uint256 penalty=SafeMath.div(SafeMath.sub(maximumTimeStampForAnswer[msg.sender],block.timestamp),dividor);
            if(penalty==0){
                penalty=1;
            }
            uint256 winMultiplier=SafeMath.div(maximumOffset,SafeMath.mul(penalty,dividor));
            require(winMultiplier<=100,"Multiplier greater than 100");

            uint256 winAmount=SafeMath.add(contractValue[msg.sender],(SafeMath.div(contractValue[msg.sender],100)));
            pooledTokens=pooledTokens.sub(winAmount);
            claimed[msg.sender]=true;
            rubberInstance.transfer(msg.sender,winAmount);            
        }     
        claimed[msg.sender]=true;   
        activeBet[msg.sender]=false;

    }


    function bet(uint256 amount,bool bull) public {
        require(activeBet[msg.sender]==false,"You already have a contract. Wait for it to finish.");
        require(rubberInstance.balanceOf(address(this))>SafeMath.mul(amount,2),"Contract does not have enough liquidity");
        rubberInstance.transferFrom(msg.sender,address(this),amount);
        int256 currentBTCPrice=chainLinkPrice.latestAnswer();
        uint256 latestRound=chainLinkPrice.latestRound();
        uint256 currentChainLinkTimeStamp=chainLinkPrice.getTimestamp(latestRound);
        lockedPriceForUser[msg.sender]=currentBTCPrice;
        minimumTimestampForAnswer[msg.sender]=SafeMath.add(currentChainLinkTimeStamp,minimumOffset);
        maximumTimeStampForAnswer[msg.sender]=SafeMath.add(currentChainLinkTimeStamp,maximumOffset);
        isBull[msg.sender]=bull;
        activeBet[msg.sender]=true;
        pooledTokens=pooledTokens.add(amount);
    }







}