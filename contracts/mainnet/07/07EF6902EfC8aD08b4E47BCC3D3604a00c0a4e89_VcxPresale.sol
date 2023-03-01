// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IToken {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 _amount) external;

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function decimals() external view returns (uint256);
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function latestAnswer() external view returns (int256);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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

interface vestingInterface {

    
    function createVesting(address _creator,uint8 _roundId,uint256 _tokenAmount) external ;
    
    function setAdmin(address _account) external ;

    function setTimeUnit(uint256 _unit) external ;

    function setRoundTokenPrice(uint8 _roundId,uint256 _price) external;

    function getClaimableAmount(address _walletAddress,uint256 _vestingId) external view returns(uint256);

    function userClaimData(address _walletAddress,uint256 _vestingId) external view returns(bool ,address ,uint8 ,uint256 ,uint256 ,uint256 ,uint256 ,uint256 ,uint256 ,uint256 );

    function getVestingIds(address _walletAddress) external view returns(uint256[] memory);

    function timeUnit() external view returns(uint256);

    function launchRound(uint8 _roundId, uint256 _vestingStartTime,bool _status) external;

    function getIslaunched(uint8 _roundId) external view returns(bool) ;

    function setRoundData( uint8 _roundId,  uint256 _totalTokensForSale,uint256 _tokenPrice,uint256 _totalvestingDays,uint256 _vestingStartTime,uint256 _vestingSlicePeriod,uint256 _tgePrecentage) external;

    function roundData(uint8 _roundId) external view returns(bool,uint256,uint256,uint256,uint256,uint256,uint256);  

    // function updateTotalTokenClaimed(uint8 _roundIds,uint _amount) external ;

    function currentRound() external view returns(uint8) ;


}

contract VcxPresale is Ownable {
    using SafeMath for uint256;
    event WalletCreated(address walletAddress,address userAddress,uint256 amount);
    bool public isPresaleOpen = true;
    address public admin;

    AggregatorV3Interface internal priceFeed;

    address public tokenAddress;
    address public BUSDAddress;
    uint256 public tokenDecimals;
    uint256 public BUSDdecimals;

    //2 means if you want 100 tokens per eth then set the rate as 100 + number of rateDecimals i.e => 10000
    uint256 public rateDecimals = 2;

    mapping(uint8 => uint256 ) public tokenSold ;
    // bool private allowance = false;
    uint256 public totalEthAmount = 0;
    uint256 public totalBUSDAmount = 0;
 

    uint256 public hardcap = 10000*1e18;  // Total Eth Value
    address private dev;
    uint256 private MaxValue;

    vestingInterface vestingAddress;



    mapping(uint8 => uint256) public minBUSDLimit ;
    mapping(uint8 => uint256) public maxBUSDLimit ;

    mapping(address => uint256) public usersInvestments;
    mapping(address => uint256) public usersInvestmentsBUSD ;
    mapping(address => uint256) public userPurchased;

    address public recipient;
    address public developmentWallet;
    uint256 public developmentShare;

    modifier onlyOwnerAndAdmin()   {
        require(
            owner() == _msgSender() || _msgSender() == admin,
            "Ownable: caller is not the owner or admin"
        );
        _;
    }

    constructor(
        address _token,
        address _recipient,
        address _BUSDAddress,
        address _developmentWallet
    ) {
        tokenAddress = _token;
        tokenDecimals = IToken(_token).decimals();
        recipient = _recipient;
        BUSDAddress = _BUSDAddress;
        BUSDdecimals = IToken(BUSDAddress).decimals();
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        admin = _msgSender();
        developmentWallet = _developmentWallet;
        developmentShare = 1000;
        
    }

    function setAdmin(address account) external  onlyOwnerAndAdmin{
        require(account != address(0),"Invalid Address, Address should not be zero");
        admin = account;
    }
    
    function setvestingAddress(address _vestingAddress) external onlyOwnerAndAdmin {
        vestingAddress = vestingInterface(_vestingAddress);
    }

    function setRecipient(address _recipient) external onlyOwnerAndAdmin {
        require(_recipient != address(0),"Invalid Address, Address should not be zero");

        recipient = _recipient;
    }

    function setDevelopmentTeamWallet(address wallet) external onlyOwnerAndAdmin {
        require(wallet != address(0),"Invalid Address, Address should not be zero");
        developmentWallet = wallet;
    }    

    function setHardcap(uint256 _hardcap) external onlyOwnerAndAdmin {
        hardcap = _hardcap;
    }

    function setDevelopmentShare(uint256 _rate) public onlyOwnerAndAdmin {
        developmentShare = _rate;
    }

    function startPresale() external onlyOwnerAndAdmin {
        require(!isPresaleOpen, "Presale is open");

        isPresaleOpen = true;
    }

    function closePresale() external onlyOwnerAndAdmin {
        require(isPresaleOpen, "Presale is not open yet.");

        isPresaleOpen = false;
    }

    function setTokenAddress(address token) external onlyOwnerAndAdmin {
        require(token != address(0), "Token address zero not allowed.");
        tokenAddress = token;
        tokenDecimals = IToken(token).decimals();
    }

    function setBUSDToken(address token) external onlyOwnerAndAdmin {
        require(token != address(0), "Token address zero not allowed.");
        
        BUSDAddress = token;
        BUSDdecimals = IToken(BUSDAddress).decimals();
    }

    function setTokenDecimals(uint256 decimals) external onlyOwnerAndAdmin {
        tokenDecimals = decimals;
    }

    function setMinBUSDLimit(uint8 _roundId,uint256 amount) external onlyOwnerAndAdmin {
        minBUSDLimit[_roundId] = amount;
    }

    function setMaxBUSDLimit(uint8 _roundId,uint256 amount) external onlyOwnerAndAdmin {
        maxBUSDLimit[_roundId] = amount;
    }

    function setRateDecimals(uint256 decimals) external onlyOwnerAndAdmin {
        rateDecimals = decimals;
    }

    function setAdminForVesting(address _address) public onlyOwnerAndAdmin{
        vestingInterface(vestingAddress).setAdmin(_address);
    }
          
    function setTimeUnit(uint _unit) public onlyOwnerAndAdmin{
        vestingInterface(vestingAddress).setTimeUnit(_unit);
    }

    receive() external payable {}

    function getMaxAmount(uint8 _roundId) public view returns(uint256) {
        return(maxBUSDLimit[_roundId])/uint(getEthPriceInUsd()) ;
    }

    function getMinAmount(uint8 _roundId) public view returns(uint256) {
        return(minBUSDLimit[_roundId])/uint(getEthPriceInUsd()) ;
    }

    function buyToken(uint8 _roundId) public payable  {
        require(isPresaleOpen, "Presale is not open.");
        require(!vestingInterface(vestingAddress).getIslaunched(_roundId),"Already Listed!");

        require(
            usersInvestments[msg.sender].add(msg.value) <= getMaxAmount(_roundId) &&
                usersInvestments[msg.sender].add(msg.value) >= getMinAmount(_roundId) ,
            "user input should be  with in the range"
        );

        uint256 tokenAmount = getTokensPerEth(msg.value,_roundId);
        
        vestingCreate(tokenAmount,_msgSender(),_roundId);

        tokenSold[_roundId] += tokenAmount;

        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
        userPurchased[msg.sender] = userPurchased[msg.sender].add(tokenAmount);
        uint256 msgValue = msg.value;
        totalEthAmount = totalEthAmount + msgValue;
        
        uint _developmentShareAmount = (msgValue * developmentShare)/(10**(2+rateDecimals));
        uint _recipientShare = msgValue - _developmentShareAmount    ;
        payable(recipient).transfer(_recipientShare);
        payable(developmentWallet).transfer(_developmentShareAmount);

        // if (totalEthAmount > hardcap) {
        //     isPresaleOpen = false;
        // }
    }

    function buyTokenBUSD(uint8 _roundId,uint _amount) public {
        require(isPresaleOpen, "Presale is not open.");
        require(!vestingInterface(vestingAddress).getIslaunched(_roundId),"Already Listed!");

        require(
            usersInvestmentsBUSD[msg.sender].add(_amount) <= maxBUSDLimit[_roundId] &&
                usersInvestmentsBUSD[msg.sender].add(_amount) >= minBUSDLimit[_roundId],
            "user input should be  with in the range"
        );

        uint256 tokenAmount = getTokenPerBUSD(_amount,_roundId);
        
        vestingCreate(tokenAmount,_msgSender(),_roundId);

        tokenSold[_roundId] += tokenAmount;

        totalBUSDAmount +=  _amount ;

        usersInvestmentsBUSD[msg.sender] =usersInvestmentsBUSD[msg.sender].add(tokenAmount);
        userPurchased[msg.sender] = userPurchased[msg.sender].add(tokenAmount);

        uint _developmentShareAmount = (_amount * developmentShare)/(10**(2+rateDecimals));
        uint _recipientShare = _amount - _developmentShareAmount;

        IToken(BUSDAddress).transferFrom(_msgSender(),developmentWallet,_developmentShareAmount);
        IToken(BUSDAddress).transferFrom(_msgSender(),recipient,_recipientShare);

        // if (totalEthAmount > hardcap) {
        //     isPresaleOpen = false;
        // }
    }

    function vestingCreate(
        uint256 tokenAmount,
        address _userAddress,
        uint8 _roundId
    ) private {

        (,,,,,,uint256 _tgePrecentage) = getRoundData(_roundId);

        if(_tgePrecentage > 0) {
            uint _tgeAmount = (tokenAmount * _tgePrecentage)/(10**(2+rateDecimals));
            tokenAmount =  tokenAmount - _tgeAmount;


        require(IToken(tokenAddress).transfer(_userAddress, _tgeAmount),
            "Insufficient balance of presale contract!"
        );

        }

            vestingInterface(vestingAddress).createVesting(_userAddress,_roundId,tokenAmount);
            require(IToken(tokenAddress).transfer(address(vestingAddress), tokenAmount),
                "Insufficient balance of presale contract!"
            );
    }

    function createRoundData( 
        uint8 _roundId,
        uint256 _totalTokensForSale,
        uint256 _tokenPrice,
        uint256 _totalvestingDays,
        uint256 _vestingStartTime,
        uint256 _vestingSlicePeriod,
        uint256 _tgePrecentage,
        uint256 _minBUSDLimit,
        uint256 _maxBUSDLimit
        ) public onlyOwnerAndAdmin{
            vestingInterface(vestingAddress).setRoundData(_roundId,_totalTokensForSale,_tokenPrice,_totalvestingDays,_vestingStartTime,_vestingSlicePeriod,_tgePrecentage);
            
            minBUSDLimit[_roundId] = _minBUSDLimit ;
            maxBUSDLimit[_roundId] = _maxBUSDLimit ;
        }

    function burnUnsoldTokens() external onlyOwnerAndAdmin {
        require(
            !isPresaleOpen,
            "You cannot burn tokens untitl the presale is closed."
        );

        IToken(tokenAddress).burn(
            IToken(tokenAddress).balanceOf(address(this))
        );
    }

    function getUnsoldTokens(address to) external onlyOwnerAndAdmin {
        require(
            !isPresaleOpen,
            "You cannot get tokens until the presale is closed."
        );

        IToken(tokenAddress).transfer(to,IToken(tokenAddress).balanceOf(address(this)));
    
    }

    function getvestingAddress() external view returns (address){
        return address(vestingAddress);
    }

    function getEthPriceInUsd() public view returns(int256) {
        return (priceFeed.latestAnswer()/1e8);
    }

    // this function has to be internal
    function getTicketRate(uint8 _roundId) public view returns(uint256) {
        (,,uint256 tokenprice,,,,) = getRoundData(_roundId);
        return tokenprice;
    }

    function getTokensPerEth(uint256 amount,uint8 _roundId) public view returns (uint256) {

        uint _denominator =(getTicketRate(_roundId)*(10**((uint256(18).sub(tokenDecimals))))) ;

        return (((amount.mul(uint(getEthPriceInUsd()))).mul(10**(2+rateDecimals)))/ _denominator) ;
  
    }

    function getTokenPerBUSD(uint256 _BUSDamount,uint8 _roundId) public view returns(uint256) {
        
        return  (((_BUSDamount.mul(10**(2+rateDecimals)))/getTicketRate(_roundId))*10**tokenDecimals).div(10**BUSDdecimals);
    }

    function getVestingId(address _walletAddress) public view returns(uint256[] memory) {
        return vestingInterface(vestingAddress).getVestingIds(_walletAddress);        
    }
 
    function getTimeUnit() public view returns(uint _timeUnit){
        return vestingInterface(vestingAddress).timeUnit();
    }

    function launchRound(uint8 _roundId, uint256 _vestingStartTime,bool _status) public onlyOwnerAndAdmin {
         vestingInterface(vestingAddress).launchRound(_roundId,_vestingStartTime,_status);
    }

    function getClaimAmount(address _walletAddress,uint256 _vestingId) public view returns(uint _claimAmount) {
        return vestingInterface(vestingAddress).getClaimableAmount(_walletAddress,_vestingId);
    }

    function getUserVestingData(address _address,uint256 _vestingId) public view returns(     
        bool ,
        address ,
        uint8 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 
        
        ){
        
        return vestingInterface(vestingAddress).userClaimData(_address,_vestingId);
        
    }

    function getTotalTokensForSale(uint8 _roundId) public view returns(uint256 _totalTokensForSale ){
        (,_totalTokensForSale,,,,,) = getRoundData(_roundId);
    }

    function getRoundData(uint8 _roundId) public view returns(bool,uint256,uint256,uint256,uint256,uint256,uint256) {
        return( vestingInterface(vestingAddress).roundData(_roundId)) ;
    }

    function getCurrentRound() public view returns(uint8) {
        return vestingInterface(vestingAddress).currentRound();
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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