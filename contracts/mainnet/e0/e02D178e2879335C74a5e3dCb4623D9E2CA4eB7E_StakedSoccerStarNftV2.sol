//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {SafeMath} from "../lib/SafeMath.sol";
import {SafeCast} from "../lib/SafeCast.sol";
import {ISoccerStarNft} from "../interfaces/ISoccerStarNft.sol";
import {IStakedSoccerStarNftV2} from "../interfaces/IStakedSoccerStarNftV2.sol";
import {DistributionTypes} from "../lib/DistributionTypes.sol";
import {DistributionManager} from "../misc/DistributionManager.sol";
import {SafeMath} from "../lib/SafeMath.sol";
import {SafeERC20} from "../lib/SafeERC20.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IBalanceHook} from "../interfaces/IBalanceHook.sol";
import {IBIBNode} from "../interfaces/IBIBNode.sol";

/**
 * @title StakedToken
 * @notice Contract to stake Aave token, tokenize the position and get rewards, inheriting from a distribution manager contract
 * @author BIB
 **/
contract StakedSoccerStarNftV2 is
  IStakedSoccerStarNftV2,
  PausableUpgradeable,
  DistributionManager
{
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeCast for uint;

  ISoccerStarNft public STAKED_TOKEN;
  IERC20 public REWARD_TOKEN;
  IBalanceHook public balanceHook;
  IBIBNode public NODE;

  event StakedTokenChanged(address sender, address oldValue, address newValue);
  event RewardTokenChanged(address sender, address oldValue, address newValue);
  event RewardVaultChanged(address sender, address oldValue, address newValue);
  event BalanceHookChanged(address sender, address oldValue, address newValue);
  event CoolDownDurationChanged(address sender, uint oldValue, uint newValue);
  event TransferOwnershipNFT(address sender, uint tokenId, address owner, address to);

  /// @notice Address to pull from the rewards, needs to have approved this contract
  address public REWARDS_VAULT;

  uint public coolDownDuration;
  uint public totalStaked;
  uint public totalPower;

  // address->token table
  mapping(address=>uint[]) public userStakedTokenTb;
  // token->staken info table
  mapping(uint=>TokenStakedInfo) public tokenStakedInfoTb;
  // user->power
  mapping(address=>uint) public userTotalPower;
  // 
  mapping(address=>bool) public allowProtocolToCallTb;

  function initialize(
    IBIBNode _node,
    ISoccerStarNft stakedToken,
    IERC20 rewardToken,
    address rewardsVault,
    uint128 distributionDuration
  ) public reinitializer(1)  {
    STAKED_TOKEN = stakedToken;
    REWARD_TOKEN = rewardToken;
    REWARDS_VAULT = rewardsVault;
    NODE = _node;

    __Pausable_init();
    __Ownable_init();

    coolDownDuration = 7 days;

    setDistributionDuration(distributionDuration);
  }

  function setAllowProtocolToCall(address _protAddr, bool value) 
  public onlyOwner{
      allowProtocolToCallTb[_protAddr] = value;
  }

  modifier onlyAllowProtocolToCall() {
      require(allowProtocolToCallTb[msg.sender], "ONLY_PROTOCOL_CALL");
      _;
  }

  function setStakedToken(address _newValue) public onlyOwner{
    require(address(0) != _newValue, "INVALID_ADDRESS");
    emit StakedTokenChanged(msg.sender, address(STAKED_TOKEN), _newValue);
    STAKED_TOKEN = ISoccerStarNft(_newValue);
  }

  function setRewardToken(address _newValue) public onlyOwner{
    require(address(0) != _newValue, "INVALID_ADDRESS");
    emit RewardTokenChanged(msg.sender, address(REWARD_TOKEN), _newValue);
    REWARD_TOKEN = IERC20(_newValue);
  }
  
  function setRewardVault(address _newValue) public onlyOwner{
    require(address(0) != _newValue, "INVALID_ADDRESS");
    emit RewardVaultChanged(msg.sender, address(REWARDS_VAULT), _newValue);
    REWARDS_VAULT = _newValue;
  }

  function setBalanceHook(address _newValue) public onlyOwner{
    require(address(0) != _newValue, "INVALID_ADDRESS");
    emit BalanceHookChanged(msg.sender, address(balanceHook), _newValue);
    balanceHook = IBalanceHook(_newValue);
  }

  function setCoolDownDuration(uint _coolDownDuration) public onlyOwner{
    emit CoolDownDurationChanged(msg.sender, coolDownDuration, _coolDownDuration);
    coolDownDuration = _coolDownDuration;
  }

  // check is the specified token is staked
  function isStaked(uint tokenId) public view override returns(bool){
      TokenStakedInfo storage tokenStakedInfo = tokenStakedInfoTb[tokenId];
      return isOwner(tokenId, address(this)) 
      && tokenStakedInfo.cooldown <= 0;
  }

  // Check if the specified token is unfreezing
  function isUnfreezing(uint tokenId) public view override returns(bool){
    uint cooldown = tokenStakedInfoTb[tokenId].cooldown;
    return cooldown > 0 && cooldown.add(coolDownDuration) >= block.timestamp;
  }

  // Check if the specified token is withdrawable
  function isWithdrawAble(uint tokenId) public view override returns(bool){
    uint cooldown = tokenStakedInfoTb[tokenId].cooldown;
    return cooldown > 0 && cooldown.add(coolDownDuration)  < block.timestamp;
  }

  function isOwner(uint tokenId, address owner)
    internal  view returns(bool){
      return (owner == IERC721(address(STAKED_TOKEN)).ownerOf(tokenId));
  }

  function getTokenPower(uint tokenId) public view returns(uint power){
      ISoccerStarNft.SoccerStar memory cardInfo = ISoccerStarNft(address(STAKED_TOKEN)).getCardProperty(tokenId);
      require(cardInfo.starLevel > 0, "CARD_UNREAL");
      // The power equation: power = gradient * 10 ^ (starLevel -1)
      return caculatePower(cardInfo.gradient, cardInfo.starLevel);
  }
 
  function caculatePower(uint gradient, uint starLevel) 
  public pure returns(uint power){
    require(gradient > 0 && gradient <= 4, "INVALID_GRADIENT");
    require(starLevel > 0 && starLevel <= 4, "INVALID_STARLEVEL");

    return gradient.exp(starLevel.sub(1));
  }

  function _stake(uint tokenId) internal {
    require(isOwner(tokenId, msg.sender), "NOT_TOKEN_OWNER");

    // delegate token to this contract
    IERC721(address(STAKED_TOKEN)).transferFrom(msg.sender, address(this), tokenId);

    // udpate global and token index
    _updateTokenAssetInternal(tokenId, address(this), 0, totalPower);

    uint power = getTokenPower(tokenId);
    totalPower += power;
    totalStaked++;
    userTotalPower[msg.sender] += power;

    tokenStakedInfoTb[tokenId] = TokenStakedInfo({
      owner: msg.sender,
      tokenId: tokenId,
      unclaimed: 0,
      cooldown: 0
    });

    userStakedTokenTb[msg.sender].push(tokenId);

    emit Stake(msg.sender, tokenId);

    // record extra dividend
    if(address(0) != address(balanceHook)){
      balanceHook.hookBalanceChange(msg.sender, tokenId, power);
    }
  }

  function stake(uint[] memory tokenIds)
  public override whenNotPaused{
    for(uint i = 0; i < tokenIds.length; i++){
      _stake(tokenIds[i]);
    }
  }

  function stake(uint tokenId) public override whenNotPaused{
   _stake((tokenId));
  }

  function getTokenOwner(uint tokenId) public view returns(address){
    return tokenStakedInfoTb[tokenId].owner;
  }

  /**
   * @dev Redeems staked tokens, and stop earning rewards
   * @param tokenId token to redeem to
   **/
  function redeem(uint tokenId) external override whenNotPaused{
    require(isStaked(tokenId), "TOKEN_NOT_SATKED");
    require(getTokenOwner(tokenId) == msg.sender, "NOT_TOKEN_OWNER");

    // can't allow reddem if the nft is stake as a node
    require(!NODE.isStakedAsNode(tokenId), "TOKEN_STAKED_AS_NODE");
    uint power = getTokenPower(tokenId);
    uint unclaimedRewards = _updateCurrentUnclaimedRewards(tokenId, power);

    // settle rewards
    IERC20(REWARD_TOKEN).transferFrom(
      REWARDS_VAULT,
      tokenStakedInfoTb[tokenId].owner, 
      unclaimedRewards);
    emit ClaimReward(tokenStakedInfoTb[tokenId].owner, tokenId, unclaimedRewards);

    // deducate the power
    totalPower -= power;
    totalStaked--;
    userTotalPower[msg.sender] -= power;

    tokenStakedInfoTb[tokenId].cooldown = block.timestamp;
    
    emit Redeem(msg.sender, tokenId);

    // record extra dividend
    if(address(0) != address(balanceHook)){
      balanceHook.hookBalanceChange(msg.sender, tokenId, 0);
    }
  }

  // user withdraw the spcified token
  function withdraw(uint tokenId) public override whenNotPaused{
    require(getTokenOwner(tokenId) == msg.sender, "NOT_TOKEN_OWNER");
    require(isWithdrawAble(tokenId), "NOT_WITHDRAWABLE");
    
    // refund token
    IERC721(address(STAKED_TOKEN)).safeTransferFrom(
      address(this), tokenStakedInfoTb[tokenId].owner, tokenId);

    delete tokenStakedInfoTb[tokenId];

    // remove from user list
    uint[] storage tokenIds = userStakedTokenTb[msg.sender];
    for(uint i = 0; i < tokenIds.length; i++){
        if(tokenIds[i] == tokenId){
            tokenIds[i] = tokenIds[tokenIds.length - 1];
            tokenIds.pop();
            break;
        }
    }

    emit Withdraw(msg.sender, tokenId);
  }

  function transferOwnershipNFT(uint tokenId, address to) 
  public onlyAllowProtocolToCall {
    require(isStaked(tokenId), "TOKEN_NOT_STAKED");
    address owner = tokenStakedInfoTb[tokenId].owner;
    require(owner != to, "SAME_OWNER");

    // transfer ownership
    tokenStakedInfoTb[tokenId].owner = to;

    // update old user token table
    uint[] storage tokenIds = userStakedTokenTb[owner];
    for(uint i = 0; i < tokenIds.length; i++){
      if(tokenIds[i] == tokenId){
          tokenIds[i] = tokenIds[tokenIds.length - 1];
          tokenIds.pop();
          break;
      }
    }
    // update new user token table
    userStakedTokenTb[to].push(tokenId);

    // update user power table
    ISoccerStarNft.SoccerStar memory cardInfo = 
    ISoccerStarNft(address(STAKED_TOKEN)).getCardProperty(tokenId);
    uint power = caculatePower(cardInfo.gradient, cardInfo.starLevel);
    userTotalPower[owner] -= power;
    userTotalPower[to] += power;

    // settle user unclaimed rewards
    uint unclaimed = _updateCurrentUnclaimedRewards(tokenId, power);
    REWARD_TOKEN.safeTransferFrom(REWARDS_VAULT, owner, unclaimed);
    emit ClaimReward(owner, tokenId, unclaimed);

    // update dvidend share
    if(address(0) != address(balanceHook)){
      balanceHook.hookBalanceChange(owner, tokenId, 0);
      balanceHook.hookBalanceChange(to, tokenId, power);
    }
      
    emit TransferOwnershipNFT(msg.sender, tokenId, owner, to);
  }

  function updateStarlevel(uint tokenId, uint starLevel) 
    public onlyAllowProtocolToCall {
      require(isStaked(tokenId), "TOKEN_NOT_STAKED");

      address owner = tokenStakedInfoTb[tokenId].owner;

      // claimed unclaimed reward
      uint unclaimedRewards = getUnClaimedRewardsByToken(tokenId);
      REWARD_TOKEN.safeTransferFrom(REWARDS_VAULT, owner, unclaimedRewards);
      emit ClaimReward(owner, tokenId, unclaimedRewards);

      // update nft property
      ISoccerStarNft(address(STAKED_TOKEN)).updateStarlevel(tokenId, starLevel);

      // update power
      ISoccerStarNft.SoccerStar memory cardInfo = 
        ISoccerStarNft(address(STAKED_TOKEN)).getCardProperty(tokenId);
      uint power = caculatePower(cardInfo.gradient, starLevel);
      uint oldPower = userTotalPower[owner];
      userTotalPower[owner] = power;
      if(power > oldPower){
        totalPower += power - oldPower;
      } else {
        totalPower -= power - oldPower;
      }
      // udpate global and token index
      _updateTokenAssetInternal(tokenId, address(this), 0, totalPower);

      // record extra dividend
      if(address(0) != address(balanceHook)){
        balanceHook.hookBalanceChange(msg.sender, tokenId, power);
      }
    }
    
  /**
   * @dev Claims reward to the specific token
   **/
  function claimRewards() external override whenNotPaused{
    uint totalUnclaimedRewards = 0;
    uint[] storage tokenIds = userStakedTokenTb[msg.sender];
    for(uint i = 0; i < tokenIds.length; i++){
      // skip redeeming
      if(isStaked(tokenIds[i])){
        uint unclaimedRewards = _updateCurrentUnclaimedRewards(tokenIds[i], getTokenPower(tokenIds[i]));
        emit ClaimReward(msg.sender, tokenIds[i], unclaimedRewards);
        totalUnclaimedRewards += unclaimedRewards;
      }
    }
    REWARD_TOKEN.safeTransferFrom(REWARDS_VAULT, msg.sender, totalUnclaimedRewards);
  }

    /**
   * @dev Claims reward to the specific token
   **/
  function claimRewardsOnbehalfOf(address to) external override whenNotPaused{
    uint totalUnclaimedRewards = 0;
    uint[] storage tokenIds = userStakedTokenTb[to];
    for(uint i = 0; i < tokenIds.length; i++){
      if(isStaked(tokenIds[i])){
        uint unclaimedRewards =  _updateCurrentUnclaimedRewards(tokenIds[i], getTokenPower(tokenIds[i]));
        emit ClaimReward(to, tokenIds[i], unclaimedRewards);
        totalUnclaimedRewards += unclaimedRewards;
      }
    }
    REWARD_TOKEN.safeTransferFrom(REWARDS_VAULT, to, totalUnclaimedRewards);
  }

  /**
   * @dev Updates the user state related with his accrued rewards
   * @param tokenId token id
   * @param power token power
   * @return The unclaimed rewards that were added to the total accrued
   **/
  function _updateCurrentUnclaimedRewards(
    uint256 tokenId,
    uint256 power
  ) internal returns (uint256) {
    return _updateTokenAssetInternal(tokenId, address(this), power, totalPower);
  }

  // Get unclaimed rewards by the specified tokens
  function getUnClaimedRewardsByToken(uint tokenId) public view override returns(uint){
    // skip over redeeming
    if(!isStaked(tokenId)){
      return 0;
    }

    DistributionTypes.UserStakeInput[] memory tokenStakeInputs =
      new DistributionTypes.UserStakeInput[](1);

    tokenStakeInputs[0] = DistributionTypes.UserStakeInput({
      underlyingAsset: address(this),
      tokenPower: getTokenPower(tokenId),
      totalPower: totalPower
    });

    return _getUnclaimedRewards(tokenId, tokenStakeInputs);
  }

  // Get unclaimed rewards by a set of the specified tokens
  function getUnClaimedRewardsByTokens(uint[] memory tokenIds) 
  public view override returns(uint[] memory amount){
    uint[] memory unclaimedRewards = new uint[](tokenIds.length);
    DistributionTypes.UserStakeInput[] memory tokenStakeInputs =
      new DistributionTypes.UserStakeInput[](1);
    for(uint i = 0; i < tokenIds.length; i++){
      if(isStaked(tokenIds[i])){
        tokenStakeInputs[0] = DistributionTypes.UserStakeInput({
              underlyingAsset: address(this),
              tokenPower: getTokenPower(tokenIds[i]),
              totalPower: totalPower
        });
        unclaimedRewards[i] = _getUnclaimedRewards(tokenIds[i], tokenStakeInputs);
      }
    }

    return unclaimedRewards;
  }

  /**
   * @dev Return the total rewards pending to claim by an staker
   * @param staker The staker address
   * @return The rewards
   */
  function getUnClaimedRewards(address staker) external view override returns (uint256) {
    uint unclaimedRewards = 0;
    uint[] storage userStakedTokens= userStakedTokenTb[staker];
    for(uint i = 0; i < userStakedTokens.length; i++){
      if(isStaked(userStakedTokens[i])){
        unclaimedRewards += getUnClaimedRewardsByToken(userStakedTokens[i]);
      }
    }
    return unclaimedRewards;
  }

  // Get user stake info by page
  function getUserStakedInfoByPage(address user, uint pageSt, uint pageSz) 
  public view override returns(TokenStakedInfo[] memory userStaked){
      TokenStakedInfo[] memory ret;

      uint[] storage userStakedTokens = userStakedTokenTb[user];

      if(pageSt < userStakedTokens.length){
        uint end = pageSt + pageSz;
        end = end > userStakedTokens.length ? userStakedTokens.length : end;
        ret =  new TokenStakedInfo[](end - pageSt);
        for(uint i = 0;pageSt < end; i++){
            ret[i] = tokenStakedInfoTb[userStakedTokens[pageSt]];
            pageSt++;
        } 
    }

    return ret;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


/**
 * @dev From https://github.com/OpenZeppelin/openzeppelin-contracts
 * Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    using SafeMath for uint;

    uint constant internal PRECISION = 1e18;

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
    require(c >= a, 'SafeMath: addition overflow');

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
    return sub(a, b, 'SafeMath: subtraction overflow');
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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
    return div(a, b, 'SafeMath: division by zero');
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
  function precisionDiv(uint256 a, uint256 b)internal pure returns (uint256) {
     a = a.mul(PRECISION);
     a = div(a, b);
     return div(a, PRECISION);
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    return mod(a, b, 'SafeMath: modulo by zero');
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function exp(uint256 a, uint256 n) internal pure returns(uint256){
    require(n >= 0, "SafeMath: n less than 0");
    uint256 result = 1;
    for(uint256 i = 0; i < n; i++){
        result = result.mul(10);
    }
    return a.mul(result);
  }
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library SafeCast {
    uint internal constant MAX_UINT = uint(int(-1));
    function toInt(uint value) internal pure returns(int){
        require(value < MAX_UINT, "CONVERT_OVERFLOW");
        return int(value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface ISoccerStarNft {

     struct SoccerStar {
        string name;
        string country;
        string position;
        // range [1,4]
        uint256 starLevel;
        // range [1,4]
        uint256 gradient;
    }

    // roud->timeInfo
    struct TimeInfo {
        uint startTime;
        uint endTime;
        uint revealTime;
    }

    enum BlindBoxesType {
        presale,
        normal,
        supers,
        legend
    }

    enum PayMethod{
        PAY_BIB,
        PAY_BUSD
    }

    event Mint(
        address newAddress, 
        uint rount,
        BlindBoxesType blindBoxes, 
        uint256 tokenIdSt, 
        uint256 quantity, 
        PayMethod payMethod, 
        uint sales);
        
    function updateStarlevel(uint tokenId, uint starLevel) external;

    // whitelist functions
    function addUserQuotaPreRoundBatch(address[] memory users,uint[] memory quotas) external;
    function setUserQuotaPreRound(address user, uint quota) external;
    function getUserRemainningQuotaPreRound(address user) external view returns(uint);
    function getUserQuotaPreRound(address user) external view returns(uint);

    function getCardProperty(uint256 tokenId) external view returns(SoccerStar memory);

    // BUSD quota
    function setBUSDQuotaPerPubRound(uint round, uint quota) external;
    function getBUSDQuotaPerPubRound(uint round) external view returns(uint);
    function getBUSDUsedQuotaPerPubRound(uint round) external view returns(uint);

    // only allow protocol related contract to mint
    function protocolMint() external returns(uint tokenId);

    // only allow protocol related contract to mint to burn
    function protocolBurn(uint tokenId) external;

    // only allow protocol related contract to bind star property
    function protocolBind(uint tokenId, SoccerStar memory soccerStar) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IStakedSoccerStarNftV2 {
    struct TokenStakedInfo {
        address owner;
        uint tokenId;
        uint unclaimed;
        uint cooldown;
    }

    // Trigred to stake a nft card
    event Stake(address sender, uint tokenId);

    // Triggered when redeem the staken
    event Redeem(address sender, uint  tokenId);

    // Triggered after unfrozen peroid
    event Withdraw(address sender, uint  tokenId);

    // Triggered when reward is taken
    event ClaimReward(address sender, uint tokenId, uint amount);

    function getTokenOwner(uint tokenId) external view returns(address);

    // protocol to udpate the star level
    function updateStarlevel(uint tokenId, uint starLevel) external;

    // user staken the spcified token
    function stake(uint tokenId) external;

    // user staken multiple tokens
    function stake(uint[] memory tokenIds) external;

    // user redeem the spcified token
    function redeem(uint tokenId) external;

    // user withdraw the spcified token
    function withdraw(uint tokenId) external;

    // Get unclaimed rewards by the specified tokens
    function getUnClaimedRewardsByToken(uint tokenId) 
    external view returns(uint);

    // Get unclaimed rewards by a set of the specified tokens
    function getUnClaimedRewardsByTokens(uint[] memory tokenIds) 
    external view returns(uint[] memory amount);
    
    // Get unclaimed rewards 
    function getUnClaimedRewards(address user) 
    external view returns(uint amount);

    // Claim rewards
    function claimRewards() external;

    function claimRewardsOnbehalfOf(address to) external;

    // Get user stake info by page
    function getUserStakedInfoByPage(address user,uint pageSt, uint pageSz) 
    external view returns(TokenStakedInfo[] memory userStaked);

    // Check if the specified token is staked
    function isStaked(uint tokenId) external view returns(bool);

    // Check if the specified token is unfreezing
    function isUnfreezing(uint tokenId) external view returns(bool);

    function transferOwnershipNFT(uint tokenId, address to) external;

    // Check if the specified token is withdrawable
    function isWithdrawAble(uint tokenId) external view returns(bool);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

library DistributionTypes {
  struct AssetConfigInput {
    uint128 emissionPerSecond;
    uint256 totalPower;
    address underlyingAsset;
  }

  struct UserStakeInput {
    address underlyingAsset;
    uint256 tokenPower;
    uint256 totalPower;
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {SafeMath} from "../lib/SafeMath.sol";
import {DistributionTypes} from "../lib/DistributionTypes.sol";

/**
 * @title DistributionManager
 * @notice Accounting contract to manage multiple staking distributions
 **/
contract DistributionManager is OwnableUpgradeable {
  using SafeMath for uint256;

  struct AssetData {
    uint128 emissionPerSecond;
    uint128 lastUpdateTimestamp;
    uint256 index;
    mapping(uint256 => uint256) tokenDebt;
  }

  uint256 public  DISTRIBUTION_END;

  uint8 public constant PRECISION = 18;

  mapping(address => AssetData) public assets;

  event AssetConfigUpdated(address indexed asset, uint256 emission);
  event AssetIndexUpdated(address indexed asset, uint256 index);
  event UserIndexUpdated(uint indexed tokenId, address indexed asset, uint256 index);

  function setDistributionDuration(uint256 distributionDuration) public onlyOwner{
    DISTRIBUTION_END = block.timestamp.add(distributionDuration);
  }

  /**
   * @dev Configures the distribution of rewards for a list of assets
   * @param assetsConfigInput The list of configurations to apply
   **/
  function configureAssets(DistributionTypes.AssetConfigInput[] calldata assetsConfigInput)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < assetsConfigInput.length; i++) {
      AssetData storage assetConfig = assets[assetsConfigInput[i].underlyingAsset];

      _updateAssetStateInternal(
        assetsConfigInput[i].underlyingAsset,
        assetConfig,
        assetsConfigInput[i].totalPower
      );

      assetConfig.emissionPerSecond = assetsConfigInput[i].emissionPerSecond;

      emit AssetConfigUpdated(
        assetsConfigInput[i].underlyingAsset,
        assetsConfigInput[i].emissionPerSecond
      );
    }
  }

  /**
   * @dev Updates the state of one distribution, mainly rewards index and timestamp
   * @param underlyingAsset The address used as key in the distribution, for example sAAVE or the aTokens addresses on Aave
   * @param assetConfig Storage pointer to the distribution's config
   * @param totalStaked Current total of staked assets for this distribution
   * @return The new distribution index
   **/
  function _updateAssetStateInternal(
    address underlyingAsset,
    AssetData storage assetConfig,
    uint256 totalStaked
  ) internal returns (uint256) {
    uint256 oldIndex = assetConfig.index;
    uint128 lastUpdateTimestamp = assetConfig.lastUpdateTimestamp;

    if (block.timestamp == lastUpdateTimestamp) {
      return oldIndex;
    }

    uint256 newIndex =
      _getAssetIndex(oldIndex, assetConfig.emissionPerSecond, lastUpdateTimestamp, totalStaked);

    if (newIndex != oldIndex) {
      assetConfig.index = newIndex;
      emit AssetIndexUpdated(underlyingAsset, newIndex);
    }

    assetConfig.lastUpdateTimestamp = uint128(block.timestamp);

    return newIndex;
  }

  /**
   * @dev Updates the state of an token in a distribution
   * @param tokenId The token's address
   * @param asset The address of the reference asset of the distribution
   * @param tokenPower Amount of tokens staked by the token in the distribution at the moment
   * @param totalPower Total tokens staked in the distribution
   * @return The accrued rewards for the token until the moment
   **/
  function _updateTokenAssetInternal(
    uint256 tokenId,
    address asset,
    uint256 tokenPower,
    uint256 totalPower
  ) internal returns (uint256) {
    AssetData storage assetData = assets[asset];
    uint256 tokenIndex = assetData.tokenDebt[tokenId];
    uint256 accruedRewards = 0;

    uint256 newIndex = _updateAssetStateInternal(asset, assetData, totalPower);

    if (tokenIndex != newIndex) {
      if (tokenPower != 0) {
        accruedRewards = _getRewards(tokenPower, newIndex, tokenIndex);
      }

      assetData.tokenDebt[tokenId] = newIndex;
      emit UserIndexUpdated(tokenId, asset, newIndex);
    }

    return accruedRewards;
  }

  /**
   * @dev Used by "frontend" stake contracts to update the data of an token when claiming rewards from there
   * @param tokenId The address of the token
   * @param stakes List of structs of the token data related with his stake
   * @return The accrued rewards for the token until the moment
   **/
  function _claimRewards(uint256 tokenId, DistributionTypes.UserStakeInput[] memory stakes)
    internal
    returns (uint256)
  {
    uint256 accruedRewards = 0;

    for (uint256 i = 0; i < stakes.length; i++) {
      accruedRewards = accruedRewards.add(
        _updateTokenAssetInternal(
          tokenId,
          stakes[i].underlyingAsset,
          stakes[i].tokenPower,
          stakes[i].totalPower
        )
      );
    }

    return accruedRewards;
  }

  /**
   * @dev Return the accrued rewards for an token over a list of distribution
   * @param tokenId The address of the token
   * @param stakes List of structs of the token data related with his stake
   * @return The accrued rewards for the token until the moment
   **/
  function _getUnclaimedRewards(uint256 tokenId, DistributionTypes.UserStakeInput[] memory stakes)
    internal
    view
    returns (uint256)
  {
    uint256 accruedRewards = 0;

    for (uint256 i = 0; i < stakes.length; i++) {
      AssetData storage assetConfig = assets[stakes[i].underlyingAsset];
      uint256 assetIndex =
        _getAssetIndex(
          assetConfig.index,
          assetConfig.emissionPerSecond,
          assetConfig.lastUpdateTimestamp,
          stakes[i].totalPower
        );

      accruedRewards = accruedRewards.add(
        _getRewards(stakes[i].tokenPower, assetIndex, assetConfig.tokenDebt[tokenId])
      );
    }
    return accruedRewards;
  }

  /**
   * @dev Internal function for the calculation of token's rewards on a distribution
   * @param principalTotalPower Amount staked by the token on a distribution
   * @param reserveIndex Current index of the distribution
   * @param tokenIndex Index stored for the token, representation his staking moment
   * @return The rewards
   **/
  function _getRewards(
    uint256 principalTotalPower,
    uint256 reserveIndex,
    uint256 tokenIndex
  ) internal pure returns (uint256) {
    return principalTotalPower.mul(reserveIndex.sub(tokenIndex)).div(10**uint256(PRECISION));
  }

  /**
   * @dev Calculates the next value of an specific distribution index, with validations
   * @param currentIndex Current index of the distribution
   * @param emissionPerSecond Representing the total rewards distributed per second per asset unit, on the distribution
   * @param lastUpdateTimestamp Last moment this distribution was updated
   * @param totalPower of tokens considered for the distribution
   * @return The new index.
   **/
  function _getAssetIndex(
    uint256 currentIndex,
    uint256 emissionPerSecond,
    uint128 lastUpdateTimestamp,
    uint256 totalPower
  ) internal view returns (uint256) {
    if (
      emissionPerSecond == 0 ||
      totalPower == 0 ||
      lastUpdateTimestamp == block.timestamp ||
      lastUpdateTimestamp >= DISTRIBUTION_END
    ) {
      return currentIndex;
    }

    uint256 currentTimestamp =
      block.timestamp > DISTRIBUTION_END ? DISTRIBUTION_END : block.timestamp;
    uint256 timeDelta = currentTimestamp.sub(lastUpdateTimestamp);
    return
      emissionPerSecond.mul(timeDelta).mul(10**uint256(PRECISION)).div(totalPower).add(
        currentIndex
      );
  }

  /**
   * @dev Returns the data of an token on a distribution
   * @param tokenId Id of the token
   * @param asset The address of the reference asset of the distribution
   * @return The new index
   **/
  function getTokenAssetData(uint256 tokenId, address asset) public view returns (uint256) {
    return assets[asset].tokenDebt[tokenId];
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {IERC20} from '../interfaces/IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';

/**
 * @title SafeERC20
 * @dev From https://github.com/OpenZeppelin/openzeppelin-contracts
 * Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.8.0;

interface IBalanceHook {
    function hookBalanceChange(address user, uint tokenId, uint newBalance) external;
}

pragma solidity ^0.8.9;

interface IBIBNode {

    struct Node {
        address ownerAddress;
        uint256 cardNftId;
        uint256 createTime;
        uint256 upNode;
    }
    
    function isStakedAsNode(uint tokenId) external view returns(bool);

    function getFreezeAmount(address _account) external view returns(uint256);

    function nodeMap(uint256 ticketId) external view returns(Node memory);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
pragma solidity >=0.8.0;

/**
 * @dev Collection of functions related to the address type
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
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
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}