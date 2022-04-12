/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract DefiProStaking is  Ownable {
  using SafeMath for uint256;  
  event Stake (address indexed user,uint256 indexed optionId, uint256 stakeAmount);
  event capitalWithdraw (address indexed user,uint256 capitalAmount);
  event ClaimReward (address indexed user,uint256 reward);
  event unstake (address indexed user,uint256 unstakeAmount);



  uint256 public InterestFeePercent = 300000; // 20% Decimal number of 20 * 10**3 ;
  uint public duration = 3600;// in Hours ;
  
    struct CoinList { 
        uint256 coinId;
        string coinName;
        AggregatorV3Interface priceProvider;
        IERC20 tokenAddress;
        bool isActive;
    }
    mapping(string => CoinList) public coinlist;
    
    
  struct _options {
      address user;
      uint256 token;
      string coinName;
      uint256 rewardAmount;
      uint256 rewardWithdraw;
      uint256 interestPercent;
      uint256 interestFeePercent;
      uint256 stakeTime;
      uint256 capitalWithdrawTime;
      uint256 interestWithdrawTime;
      bool isActive;
      bool isCapitalWithdraw;
  }

  mapping(address => _options[]) public options;
  constructor() {  
        
        coinlist["BUSD"] = CoinList(0,"BUSD",AggregatorV3Interface(0xcBb98864Ef56E9042e7d2efef76141f15731B82f),IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),true);
        coinlist["BNB"] = CoinList(1,"BNB",AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE),IERC20(address(0)),true);
        coinlist["CAKE"] = CoinList(2,"CAKE",AggregatorV3Interface(0xB6064eD41d4f67e353768aA239cA86f4F73665a1),IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82),true);
        coinlist["ETH"] = CoinList(3,"ETH",AggregatorV3Interface(0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e),IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8),true);
        coinlist["BTC"] = CoinList(4,"BTC",AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf),IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c),true);
  
        // coinlist["BUSD"] = CoinList(0,"BUSD",AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa),IERC20(0xA877fB848CEce74237b9be5B608857b3758f543e),true);
        // coinlist["BNB"] = CoinList(1,"BNB",AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526),IERC20(address(0)),true);
        // coinlist["CAKE"] = CoinList(2,"CAKE",AggregatorV3Interface(0x81faeDDfeBc2F8Ac524327d70Cf913001732224C),IERC20(0x2EF7CA476457192Ebf3B5D437699102E5d997B29),true);
        // coinlist["ETH"] = CoinList(3,"ETH",AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7),IERC20(0xf999Dc75e3Cb1273386f33C1e04bA44A61eF5d50),true);
        // coinlist["BTC"] = CoinList(4,"BTC",AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C),IERC20(0x34E1AF1B2ccd5186f8632d32668B0eFd9F2bE5EC),true);
    }
    
    function getOptions(address user) view public returns(_options[] memory){
        return options[user];
    }
    
    function convertCoinValue(       
        uint256 amount,
        string memory from_coinName,
        string memory to_coinName
    ) view public returns(uint256){
        uint256 newamount = amount;
        (,int from_latestPrice,,,) = coinlist[from_coinName].priceProvider.latestRoundData();
        uint256 from_currentPrice = uint256(from_latestPrice);
        (,int to_latestPrice,,,) = coinlist[to_coinName].priceProvider.latestRoundData();
        uint256 to_currentPrice = uint256(to_latestPrice);
        uint256 coinInUSD =  newamount.mul(from_currentPrice);
        uint256 to_amount = coinInUSD.div(to_currentPrice);
        return to_amount;
    }
    function stakeBNB() external payable returns(uint256 optionId){  
        uint256 InterestPercent= rewardPercentCalculate("BNB",msg.value);
        optionId = options[msg.sender].length;   
        options[msg.sender].push(_options(msg.sender,msg.value,"BNB",0,0,InterestPercent,InterestFeePercent,block.timestamp,0,0,true,false));
        emit Stake(msg.sender,optionId,msg.value);
    }
    function stake(string memory coin, uint256 token) external returns(uint256 optionId){ 
        require(coinlist[coin].isActive, "Invalid coin name"); 
        IERC20 tokenAddress = coinlist[coin].tokenAddress;
        require(tokenAddress.allowance(msg.sender,address(this)) >= token, "Insufficient token allowance for transfer");
        tokenAddress.transferFrom(msg.sender,address(this),token);

        uint256 InterestPercent= rewardPercentCalculate(coin,token);
        optionId = options[msg.sender].length;           
        options[msg.sender].push(_options(msg.sender,token,coin,0,0,InterestPercent,InterestFeePercent,block.timestamp,0,0,true,false));
        emit Stake(msg.sender,optionId,token);
    }

    function calculateReward(address user, uint256 optionId) public view returns(uint256 interestAmount) {
        if(options[user][optionId].isActive){
             uint256 TotalAmount = options[user][optionId].token;
             uint256 time  = options[user][optionId].stakeTime;
              uint256 rewardCount = uint(block.timestamp.sub(time)/duration);
            //  for(uint i=0; i < rewardCount; i++){
                 uint256 _interestAmount = TotalAmount.mul(options[user][optionId].interestPercent).div(1000000);
                //  TotalAmount = TotalAmount.add(_interestAmount);                 
                 interestAmount = rewardCount.mul(_interestAmount) ;//_interestAmount;
                 interestAmount = interestAmount.sub(options[user][optionId].rewardWithdraw);
            //  }             
        }else{
            interestAmount = options[user][optionId].rewardAmount;
        }
    } 


    function withdrawCapital(uint256 optionId) public returns(bool) {
        require(options[msg.sender][optionId].isActive, "Invalid Option ID");
        require(!options[msg.sender][optionId].isCapitalWithdraw, "Pool Error : Capital amount already withdraw");
        IERC20 tokenAddress = coinlist[options[msg.sender][optionId].coinName].tokenAddress;
        if(coinlist[options[msg.sender][optionId].coinName].coinId == 1){
            require(address(this).balance >= options[msg.sender][optionId].token, "Pool Error : Insufficient pool balance for withdraw");
            payable(msg.sender).transfer(options[msg.sender][optionId].token);
        }else{
            require(tokenAddress.balanceOf(address(this)) >= options[msg.sender][optionId].token, "Pool Error : Insufficient pool balance for withdraw");
            tokenAddress.transfer(msg.sender,options[msg.sender][optionId].token);
        }
        options[msg.sender][optionId].rewardAmount = calculateReward(msg.sender,optionId);
        options[msg.sender][optionId].isCapitalWithdraw = true;
        options[msg.sender][optionId].isActive =  false;
        options[msg.sender][optionId].capitalWithdrawTime = block.timestamp;
        return true;
    }

    function claimReward(uint256 optionId) public returns(bool) {
        require(options[msg.sender][optionId].token > 0, "Invalid Option ID");
        uint256 reward = calculateReward(msg.sender,optionId);
        require(reward > 0, "Pool Error : Reward not available");
        uint256 rewardInBUSD =  convertCoinValue(reward,options[msg.sender][optionId].coinName,"BUSD");
        uint256 withdrawReward = rewardInBUSD.sub(rewardInBUSD.mul(options[msg.sender][optionId].interestFeePercent).div(1000000));
        require(coinlist["BUSD"].tokenAddress.balanceOf(address(this)) >= withdrawReward, "Pool Error : Insufficient token for withdraw");
        coinlist["BUSD"].tokenAddress.transfer(msg.sender,withdrawReward);
        options[msg.sender][optionId].rewardAmount = 0;
        options[msg.sender][optionId].rewardWithdraw = reward.add(options[msg.sender][optionId].rewardWithdraw);
        emit ClaimReward(msg.sender,withdrawReward);
        return true;
    }

    function withdrawCapitalAll(uint256[] calldata optionIDs) external {
        uint arrayLength = optionIDs.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            withdrawCapital(optionIDs[i]);
        }
    }

    function claimRewardAll(uint256[] calldata optionIDs) external {
        uint arrayLength = optionIDs.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            claimReward(optionIDs[i]);
        }
    }

    function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }
    
    function setInterestFeePercent(uint256 _InterestFeePercent) public onlyOwner {
        InterestFeePercent = _InterestFeePercent;
    }

    function withdraw(string memory coin, uint256 amount) public onlyOwner {
        require(coinlist[coin].isActive, "Invalid coin name"); 
        if(coinlist[coin].coinId == 1){
            payable(msg.sender).transfer(amount);
        }else{
            coinlist[coin].tokenAddress.transfer(msg.sender,amount);
        }
    }


    function rewardPercentCalculate(string memory coin, uint256 amount) view public  returns(uint256 percent) {
        uint256 coinId = coinlist[coin].coinId;
        uint256 amountInUSD = convertCoinValue(amount,coin,"BUSD");

         if(amountInUSD >= 100 * 10**18 &&  amountInUSD <= 499 * 10**18){
            if(coinId == 1){
                percent = (2250/24)*10**4;// 0.1275 * 10**4
            }
            if(coinId == 2){
                percent = (1800/24)*10**4;// 0.1800 * 10**4
            }
        }else if(amountInUSD >= 500 * 10**18 &&  amountInUSD <= 999 * 10**18){
            if(coinId == 1){
                percent = (2400/24)*10**4; // 10**4
            }
            if(coinId == 2){
                percent = (1950/24)*10**4;// 0.1950 * 10**4
            }

        }else if(amountInUSD >= 1000 * 10**18 &&  amountInUSD <= 2999 * 10**18){
            if(coinId == 1){
                percent = (2550/24)*10**4; // 10**4
            }
            if(coinId == 2){
                percent = (2100/24)*10**4;// 0.2100 * 10**4
            }
            if(coinId == 3){
                percent = (1500/24)*10**4;// 0.1500 * 10**4
            }

        }else if(amountInUSD >= 3000 * 10**18 &&  amountInUSD <= 4999 * 10**18){
            if(coinId == 1){
                percent = (2700/24)*10**4; // 10**4
            }
            if(coinId == 2){
                percent = (2250/24)*10**4;// 0.2250 * 10**4
            }
            if(coinId == 3){
                percent = (1575/24)*10**4;// 0.1575 * 10**4
            }
            if(coinId == 4){
                percent = (1200/24)*10**4;// 0.1200 * 10**4
            }

        }else if(amountInUSD >= 5000 * 10**18 &&  amountInUSD <= 9999 * 10**18){
            if(coinId == 1){
                percent = (2850/24)*10**4; // 10**4
            }
            if(coinId == 2){
                percent = (2400/24)*10**4;// 0.2400 * 10**4
            }
            if(coinId == 3){
                percent = (1650/24)*10**4;// 0.1650 * 10**4
            }
            if(coinId == 4){
                percent = (1275/24)*10**4;// 0.1275 * 10**4
            }

        }else if(amountInUSD >= 10000 * 10**18 &&  amountInUSD <= 19999 * 10**18){
            if(coinId == 1){
                percent = (3000/24)*10**4; // 10**4
            }
            if(coinId == 2){
                percent = (2550/24)*10**4;// 0.2550 * 10**4
            }
            if(coinId == 3){
                percent = (1800/24)*10**4;// 0.1800 * 10**4
            }
            if(coinId == 4){
                percent = (1350/24)*10**4;// 0.1350 * 10**4
            }

        }else if(amountInUSD >= 20000 * 10**18){
            if(coinId == 1){
                percent = 1354166; // 10**4
            }
            if(coinId == 2){
                percent = (2700/24)*10**4;// 0.2700 * 10**4
            }
            if(coinId == 3){
                percent = (1950/24)*10**4;// 0.1950 * 10**4
            }
            if(coinId == 4){
                percent = (1425/24)*10**4;// 0.1425 * 10**4
            }
        }   
       
    }

    

}