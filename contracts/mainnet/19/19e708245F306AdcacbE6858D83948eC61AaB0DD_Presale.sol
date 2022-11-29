// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/*

                                              !?JJJJJJJJJJJJJJJJJJJJ?7:         
                                            .?J???????????????????????J~        
                                           ^J??????????????????????????J7       
    .                                     ~J???????????????????????????7J?.     
   7G5!.                                 7J???????????????????????????????J:    
   .!PBP7.                             .?J7????????????????????????????????J~   
     .?GBP?:                          :J????????????????????????????????????J7  
       :JGBP?:                       ~J?????????????????????????????????????7J?.
         ^YGGGJ^           .::::::::7J???????????????????????J?????????????????J
          ^GGGGGY^         ?JJ????????????????????????????J?!: :Y??????????????Y
         ^5GGGGGGGY~        ^7J??7?????????????????????J?!:   ~J????????????7J?.
        !PGGGGGGGGGG5!.       .~?J??????????????????J?7^.   ^?J?????????????J7  
       ?GGGGGGGGGGGGGGP?:        :!?J?????????????J7~.    :7J??????????????J!   
     .YGGGGGGGGGGGGGGGGGPJ^        .~?J????????J?~.     .!J???????????????J^    
    ^5GGGGGGGGGGGGGGGGGGGGGY~         :!?J??J?!:       ~J??????????????7J?:     
   !PGGGGGGGGGGGGGGGGGGGGGGGG5!.        .^~~:        ^?J???????????????J7.      
  ?GGGGGGGGGGGGGGGGGGGGGGGGGGGGP?:                 :?J?7??????????????J!        
.JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPJ^              :YJ????????????????7^         
5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGJ              ..................           
5GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGY              ..................           
.JGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG5!              .JJ????????????????7^         
  ?GGGGGGGGGGGGGGGGGGGGGGGGGGGGG5!.                .!J????????????????J!        
   !PGGGGGGGGGGGGGGGGGGGGGGGGG5!.        :~^.        .7J???????????????J7       
    ^5GGGGGGGGGGGGGGGGGGGGGGP7.       :!Y5PP5?^        :7J??????????????J?:     
     .YGGGGGGGGGGGGGGGGGGGP7.      .!J5PP5555PPY7:       :7J??????????????J^    
       ?GGGGGGGGGGGGGGGGP7.     .~J5PP5555555555P5J~.      ^?J?????????????J!   
        !PGGGGGGGGGGGGP7.    .~?5PP555555555555555PP5?^      ^?J????????????J7  
         ^5GGGGGGGGGP?:   .^?5PP555555555555555555555PPY!:     ^?J???????????J?.
          .?5PPGGGP?:    ~5PP555555PP555555555555555555PP5J~.    ~?J???????????Y
             .!GG?:      .:::::::::^?P55555555555555555555PP57^   .~J??????????J
            .JGJ:                    ~5P555555555555555555555PPY!.  .!J??????J?.
           !PY^                       :YP5555555555555555555555PP5?~. .!J???J7  
           !^                          .JP555555555555555555555555PPY7: .!??~   
                                         7P55555555555555555555555555P5J!.      
                                          ~5P55555555555555555555555555PP5J~.   
                                           ^5P5555555555555555555555555P7.^7J^  
                                            .JP5555555555555555555555P5~        
                                              !Y5PPPPPPPPPPPPPPPPPP55?:  

*/

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./OwnerWithdrawable.sol";

contract Presale is OwnerWithdrawable, ReentrancyGuard{
    using SafeERC20 for IERC20Metadata;

    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public totalTokensforSale;
    uint256 public rate;
    uint256 public vestingBeginTime;
    uint256 public totalTokensSold;
    uint256 public totalTokensAlloc;
    uint256 public saleTokenDec;

    address public immutable saleToken;

    //vestingPercent: Vesting percent for the allocated tokens in a round
    //lockingPeriod: locking period for the allocated tokens in a round
    struct VestingDetails{
        uint256 vestingPercent;
        uint256 lockingPeriod;
    }

    uint256 public currentRound = 1000;

    mapping (uint256 => VestingDetails) public roundDetails;

    //totalAmount: total tokens allocated in all the rounds
    //array storing the rounds participated by a user
    //Rounds::  0: PS1, 1: PS2, 2:INNOVATION, 3: TEAM, 4:MARKETING, 5: SEED
    //tokensPerRound: mapping to store the tokens allocated to the user in the specific round
    //monthlyVestingClaimed: stores the latest month when a user withdrew tokens in the specific round
    //tokensClaimed: stores the number of tokens claimed by the user in the specific round
    struct BuyerTokenDetails {
        uint256 totalAmount;
        uint256 []roundsParticipated;
        mapping(uint256 => uint256)tokensPerRound;
        mapping(uint256 => uint256)monthlyVestingClaimed;
        mapping(uint256 => uint256)tokensClaimed;
    }

    mapping(address => BuyerTokenDetails) public buyersAmount;

    constructor(address _saleTokenAddress, uint256[] memory _roundID, uint256[] memory _vestingPercent, uint256[] memory _lockingPeriod) ReentrancyGuard(){
        require(_saleTokenAddress != address(0), "Presale: Invalid Address");
        saleToken = _saleTokenAddress;
        saleTokenDec = IERC20Metadata(saleToken).decimals();
        setRoundDetails(_roundID, _vestingPercent, _lockingPeriod);
    }

    modifier saleStarted(){
    if(preSaleStartTime != 0){
        require(block.timestamp < preSaleStartTime || block.timestamp > preSaleEndTime, "PreSale: Sale has already started!");
    }
        _;
    }

    /// @dev modifier to check if the sale is active or not
    modifier saleDuration(){
        require(block.timestamp > preSaleStartTime, "Presale: Sale hasn't started");
        require(block.timestamp < preSaleEndTime, "PreSale: Sale has already ended");
        _;
    }

    /// @dev modifier to check if the Sale Duration and Locking periods are valid or not
    modifier saleValid(
    uint256 _preSaleStartTime, uint256 _preSaleEndTime
    ){
        require(block.timestamp < _preSaleStartTime, "PreSale: Invalid PreSale Date!");
        require(_preSaleStartTime < _preSaleEndTime, "PreSale: Invalid PreSale Dates!");
        _;
    }

    /// @notice Set round details like vesting percent per month, and locking period for different rounds. 
    /// @dev    Rounds::  0: PS1, 1: PS2, 2:INNOVATION, 3: TEAM, 4:MARKETING, 5: SEED
    /// @dev    Function is called in the constructor
    /// @param _roundID Array of Round ID's
    /// @param _vestingPercent Array of vesting percentage per month for the specific round
    /// @param _lockingPeriod Array of locking period's for each round
    function setRoundDetails(uint256[] memory _roundID, uint256[] memory _vestingPercent, uint256[] memory _lockingPeriod) internal {
        require(_roundID.length == _vestingPercent.length, "Redux: Length mismatch");
        require(_lockingPeriod.length == _vestingPercent.length, "Redux: Length mismatch");
        uint256 length = _roundID.length;
        // VestingDetails storage vestingInfo = 
        for(uint256 i = 0; i < length; i++){
            roundDetails[_roundID[i]] = VestingDetails(_vestingPercent[i], _lockingPeriod[i]);
        }
    }

    /// @notice Set sale token params when initializing a new round. Will not work if sale is already active.
    /// @dev    Can be called only twice for the two presale round requirements. Owner needs to approve presale contract to handle said number of tokens
    /// @param _totalTokensforSale The total tokens for sale in wei
    /// @param _rate The rate of each token in USD 
    /// @param _roundID The id for the specific presale round 
    function setSaleTokenParams(uint256 _totalTokensforSale, uint256 _rate, uint256 _roundID) external onlyOwner saleStarted {
        require(_rate != 0, "PreSale: Invalid Native Currency rate!");
        require(_roundID < 2, "Redux Presale: Round ID should be 0 or 1");
        currentRound = _roundID;
        rate = _rate;
        totalTokensforSale = _totalTokensforSale;
        totalTokensSold = 0;
        IERC20Metadata(saleToken).safeTransferFrom(msg.sender, address(this), totalTokensforSale);
    }

    /// @notice Set sale period for the ICO
    /// @dev    Cannot be called if sale is already active
    /// @param _preSaleStartTime Start time for the sale in unix format
    /// @param _preSaleEndTime End time for the sale in unix format
    function setSalePeriodParams(uint256 _preSaleStartTime, uint256 _preSaleEndTime) 
    external onlyOwner saleStarted saleValid(_preSaleStartTime, _preSaleEndTime){
        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;
    }

    /// @notice Call when vesting needs to start. Can be called only once
    /// @dev    Cannot be called if sale has not ended
    function setVestingPeriod() external onlyOwner{
        require(vestingBeginTime == 0, "Redux: Cannot set multiple times");
        require(preSaleEndTime !=0, "Redux: Sale not started");
        require(block.timestamp > preSaleEndTime, "Redux: Sale in progress");
        vestingBeginTime = block.timestamp;

    }

    /// @notice Calculate Redux token amount for said BNB amount
    /// @return Calculated Redux tokens in wei
    function getTokenAmount(uint256 amount) external view returns (uint256) {
        return amount*(10**saleTokenDec)/rate;
    }

    /// @notice Investor calls this to buy Redux tokens for BNB
    /// @param _isInnovation boolean to denote if this purchase falls under the innovation round
    function buyToken(bool _isInnovation) external payable saleDuration{
        uint256 saleTokenAmt;

        saleTokenAmt = (msg.value)*(10**saleTokenDec)/rate;
        require((totalTokensSold + saleTokenAmt) < totalTokensforSale, "PreSale: Total Token Sale Reached!");

        // Update Stats
        totalTokensSold += saleTokenAmt;
        BuyerTokenDetails storage buyerDetails = buyersAmount[msg.sender];        
        buyerDetails.totalAmount += saleTokenAmt;
        if(_isInnovation) {
          if(buyerDetails.tokensPerRound[2] == 0){
              buyerDetails.roundsParticipated.push(2);
              buyerDetails.monthlyVestingClaimed[2] = roundDetails[2].lockingPeriod-1;
          }
          buyerDetails.tokensPerRound[2] += saleTokenAmt;
        }
        else {
          if(buyerDetails.tokensPerRound[currentRound] == 0){
              buyerDetails.roundsParticipated.push(currentRound);
              buyerDetails.monthlyVestingClaimed[currentRound] = roundDetails[currentRound].lockingPeriod-1;

          }
          buyerDetails.tokensPerRound[currentRound] += saleTokenAmt;
        }
    }

    /// @notice Returns the amount of Redux tokens bought by an investor
    /// @param  _user The wallet address of the investor
    /// @return Redux tokens in wei
    function getTokensBought(address _user) external view returns(uint256) {
        return buyersAmount[_user].totalAmount;
    }

    /// @notice Returns the rounds that an investor has been a part of
    /// @param  _user The wallet address of the investor
    /// @return Array of round ID's
    function getRoundsParticipated(address _user) external view returns(uint256[] memory) {
        return buyersAmount[_user].roundsParticipated;
    }

    /// @notice Returns the amount of Redux tokens that an investor purchased in the specific round (denoted by roundID)
    /// @param  _user The wallet address of the investor
    /// @param  _roundID The specific Round ID
    /// @return Redux tokens in wei
    function getTokensPerRound(address _user, uint256 _roundID)external view returns(uint256){
        return buyersAmount[_user].tokensPerRound[_roundID];
    }

    /// @notice Returns the amount of Redux tokens that an investor has claimed from a specific round (denoted by roundID)
    /// @param  _user The wallet address of the investor
    /// @param  _roundID The specific Round ID
    /// @return Redux tokens in wei
    function getClaimedTokensPerRound(address _user, uint256 _roundID) external view returns(uint256) {
        return buyersAmount[_user].tokensClaimed[_roundID];
    }

    /// @notice Returns the number of month's vesting that has been claimed by a given investor for a given round (denoted by roundID)
    /// @param  _user The wallet address of the investor
    /// @param  _roundID The specific Round ID 
    /// @return Returns an integer (uint)
    function getMonthlyVestingClaimed(address _user, uint256 _roundID) external view returns(uint256) {
        return buyersAmount[_user].monthlyVestingClaimed[_roundID];
    }

    /// @notice Returns the total amount of Redux tokens that an investor has claimed so far from vesting. 
    /// @param  _user The wallet address of the investor
    /// @return Redux tokens in wei
    function getTotalClaimedTokens(address _user) external view returns(uint256) {
        uint256 tokensClaimed;

        for(uint256 i = 0; i<6; i++){
            tokensClaimed += buyersAmount[_user].tokensClaimed[i];
        }
        return tokensClaimed;
    }

    /// @notice Investor can call this to withdraw their share of tokens that are eligible fro withdrawal 
    /// @dev Modifier to take care of Reentrancy attacks is included
    function withdrawToken() external nonReentrant{
        uint256 tokensforWithdraw = getAllocation(msg.sender);
        address user = msg.sender;
        require(tokensforWithdraw > 0, "Redux Token Vesting: No $REDUX Tokens available for claim!");
        
        uint256 timeElapsed = (block.timestamp)-vestingBeginTime;
        uint256 boost;
        uint256 availableAllocation;
        uint256 availableTokens;

        uint256 round;
        uint256 tokenPerRound;
        BuyerTokenDetails storage buyerDetails = buyersAmount[user];        
        uint256 length = buyerDetails.roundsParticipated.length;
        for(uint256 i = 0; i < length; i++){
            round = buyerDetails.roundsParticipated[i];
            tokenPerRound = buyerDetails.tokensPerRound[round];

            if(timeElapsed/(30*24*60*60) >= roundDetails[round].lockingPeriod){

                boost = (timeElapsed/(30*24*60*60))-(buyerDetails.monthlyVestingClaimed[round]);
                availableAllocation = tokenPerRound*boost*(roundDetails[round].vestingPercent)/100;
                availableTokens = tokenPerRound-(buyerDetails.tokensClaimed[round]);
    
                buyerDetails.tokensClaimed[round] += availableAllocation > availableTokens ? availableTokens : availableAllocation;
                buyerDetails.monthlyVestingClaimed[round] = timeElapsed/(30*24*60*60);

            }
        }

        IERC20Metadata(saleToken).safeTransfer(msg.sender, tokensforWithdraw);

    }

    /// @notice Get investor's allocation that is available for withdrawal
    /// @param  user The wallet address of the investor
    /// @return Redux tokens in wei
    function getAllocation(address user) public view returns(uint256){

        require(vestingBeginTime != 0, "Redux: Vesting hasn't started for me");    

        uint256 timeElapsed = (block.timestamp)-vestingBeginTime;
        uint256 boost;
        uint256 availableAllocation;
        uint256 availableTokens;
        uint256 tokensAlloted;

        uint256 round;
        uint256 tokenPerRound;
        BuyerTokenDetails storage buyerDetails = buyersAmount[user];        
        
        for(uint256 i = 0; i < buyerDetails.roundsParticipated.length; i++){
            round = buyerDetails.roundsParticipated[i];
            tokenPerRound = buyerDetails.tokensPerRound[round];
            //check if lockingPeriod is inactive
            if(timeElapsed/(30*24*60*60) >= roundDetails[round].lockingPeriod){
                
                //boost: months available since last withdraw
                boost = (timeElapsed/(30*24*60*60))-(buyerDetails.monthlyVestingClaimed[round]);
                availableAllocation = tokenPerRound*boost*(roundDetails[round].vestingPercent)/100;
                availableTokens = tokenPerRound-(buyerDetails.tokensClaimed[round]);
                tokensAlloted += availableAllocation > availableTokens ? availableTokens : availableAllocation;

            }
        }
        return tokensAlloted;
    }

    /// @notice Owner can use this to externally set vesting for different investor's / wallets
    /// @param  _user Array of wallet addresses
    /// @param  _amount Array of amounts that need to be vested
    /// @param  _roundID Round ID in which the vesting falls
    function setExternalAllocation(address[] calldata _user, uint256[] calldata _amount, uint256 _roundID)external onlyOwner{

        uint256 totalTokens;
        require(_user.length == _amount.length, "Redux Token Vesting: user & amount arrays length mismatch");
        require(_roundID >2, "Redux: Id should be greater than 1");
        uint256 length = _user.length;
        for(uint256 i = 0; i < length; i+=1){
        BuyerTokenDetails storage buyerDetails = buyersAmount[_user[i]];        
            buyerDetails.totalAmount += _amount[i];
            if(buyerDetails.tokensPerRound[_roundID] == 0){
                buyerDetails.roundsParticipated.push(_roundID);
                buyerDetails.monthlyVestingClaimed[_roundID] = roundDetails[_roundID].lockingPeriod-1;
            }
            buyerDetails.tokensPerRound[_roundID] += _amount[i];
            totalTokens += _amount[i];
        }
        totalTokensAlloc += totalTokens;
        IERC20Metadata(saleToken).safeTransferFrom(msg.sender, address(this), totalTokens);
    }

    /// @notice Owner can use this to withdraw the leftover, unsold tokens from the ICO
    function withdrawUnsoldTokens() external saleStarted onlyOwner {
        uint256 tokens = IERC20Metadata(saleToken).balanceOf(address(this))-(totalTokensSold+totalTokensAlloc);
        IERC20Metadata(saleToken).safeTransfer(msg.sender, tokens);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnerWithdrawable is Ownable {

    receive() external payable {}

    fallback() external payable {}

    /// @notice Owner can call this function to withdraw BNB
    /// @param _amt Amount that needs to be withdrawn
    function withdrawCurrency(uint256 _amt) external onlyOwner {
        payable(msg.sender).transfer(_amt);
    }
    /// @notice Get the BNB balance of the presale contract
    /// @return Amount of BNB in wei
    function getCurrencyBalance() external view returns(uint256){
        return (address(this).balance);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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