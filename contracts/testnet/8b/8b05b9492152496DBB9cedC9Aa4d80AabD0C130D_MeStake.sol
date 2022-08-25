/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/ME/MeStake.sol

pragma solidity ^0.8.15;
//SPDX-License-Identifier: UNLICENSED




interface IERC20Ext is IERC20{
  function decimals() external view returns(uint8);
  function pair() external view returns(address);
  function usdt() external view returns(address);
}

interface MyNftEX is IERC721Enumerable{
  function getRecommender(address account) external view returns(address);
  function getRecommendedCount(address account) external view returns(uint);
}

interface ConsensusPoo {
    function _out_pool (IERC20 _ERC20, address _address, uint256 _amount) external;
}

interface IUniswapV2Pair {
  function balanceOf(address owner) external view returns (uint);
  function transfer(address to, uint value) external returns (bool);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);
  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;
  function initialize(address, address) external;
}

contract MeStake is Ownable {
  struct ConsensusPool {
    uint8     star;
    uint256   amount;
    uint256   claimed;
    uint256   birthday;
  }

  IERC20Ext public meToken;
  MyNftEX public myNftEX;
  ConsensusPoo public consensusPool;
  mapping(uint8 => uint256) public poolPrices;
  mapping(address => uint) public recommended;
  mapping(address => ConsensusPool[]) public cpools;
  uint256 public rewardDuration;
  uint[7] public referralRewards = [5, 5, 5, 5, 5, 5, 5];
  address public _meToken;
  address public _myNftEX;
  address public _consensus_pool;//共识池(合约)
  address public _security_fund;//保障基金
  address public _dao_reward;//DAO奖励 

  event ClaimReward(uint256);
  event PurchaseStar(uint, uint256);

  constructor(address _meToken_address, address _myNftEX_address, address _consensus_pool_address) {
    _meToken = _meToken_address;
    _myNftEX = _myNftEX_address;
    _consensus_pool = _consensus_pool_address;
    meToken = IERC20Ext(_meToken);
    myNftEX = MyNftEX(_myNftEX);
    consensusPool = ConsensusPoo(_consensus_pool);
    poolPrices[1] = 100 ether;
    poolPrices[2] = 200 ether;
    poolPrices[3] = 300 ether;
    poolPrices[4] = 400 ether;
    poolPrices[5] = 500 ether;
    poolPrices[6] = 600 ether;
    poolPrices[7] = 700 ether;
    _security_fund = address(0x2fE24DDE0bbdDc05596C68E370d627B24678538e);
    _dao_reward = address(0xf92DD02Dfd9577Cedcd62E9291261B862E74f0bc);
    rewardDuration = 60;//静默释放间隔
  }

  function setMeToken(address tokenAddr) public onlyOwner {
    meToken = IERC20Ext(tokenAddr);
  }

  function setMeMyNftEX(address nftAddr) public onlyOwner {
    myNftEX = MyNftEX(nftAddr);
  }

  function getMeAmountForUsdt(uint256 usdtAmount) public view returns(uint256) {
    IUniswapV2Pair pair = IUniswapV2Pair(meToken.pair());
    (uint256 amountMeInPair, uint256 amountUsdtInPair) = getLiquidityPairAmount(pair);
    return (amountMeInPair * usdtAmount) / amountUsdtInPair;
  }

  function getLiquidityPairAmount(IUniswapV2Pair pair) public view returns(uint256 amountTk, uint256 amountUsdt)  {
    (uint256 token0, uint256 token1, ) = pair.getReserves();
    if (pair.token0() == address(meToken)) {
      amountTk = token0;
      amountUsdt = token1;
    }
    else {
      amountTk = token1;
      amountUsdt = token0;
    }
  }

  function availStarToPurchase(address account) public view returns(uint8) {
    (, uint256 residual) = getBalance(account);
    uint8 star = 0;
    if (residual == 0)
      star = 1;
    else if (residual > 0 && residual <= 200 ether)
      star = 2;
    else if (residual > 200 ether && residual <= 600 ether)
      star = 3;
    else if (residual > 600 ether && residual <= 1200 ether)
      star = 4;
    else if (residual > 1200 ether && residual <= 2000 ether)
      star = 5;
    else if (residual > 2000 ether && residual <= 3000 ether)
      star = 6;
    else 
      star = 7;
    return star;
  }

  //当前星级
  function currentStar(address account) public view returns(uint8) {
    (, uint256 residual) = getBalance(account);
    if (residual == 0)
      return 0;
    if (residual <= 200 ether)
      return 1;
    if (residual <= 600 ether)
      return 2;
    if (residual <= 1200 ether)
      return 3;
    if (residual <= 2000 ether)
      return 4;
    if (residual <= 3000 ether)
      return 5;
    if (residual <= 4000 ether)
      return 6;
    return 7;
  }

  function purchaseStar() public {
    address referrer = myNftEX.getRecommender(msg.sender);
    require(referrer != address(0), "[MeStake] Cannot purchase because you have no referrer!");
    uint8 star = availStarToPurchase(msg.sender);
    ConsensusPool memory cp;
    cp.star = star;
    cp.amount = poolPrices[star] * 2;
    cp.birthday = block.timestamp;
    cpools[msg.sender].push(cp);

    uint256 meAmount = getMeAmountForUsdt(poolPrices[star]);
    require(meToken.balanceOf(msg.sender) >= meAmount, "[MeStake] Insufficient ME balance to purchase consensus pool!");
    meToken.transferFrom(msg.sender, address(this), meAmount);

    // referral
    address upline = msg.sender;
    uint256 remainAmount = (meAmount*35)/100;
    for(uint8 i = 0; i < referralRewards.length; i ++) {
      upline = myNftEX.getRecommender(upline);
      if (upline == address(0))
        break;
      if (upline == msg.sender)
        continue;
      if (currentStar(upline) >= star)
      {
        uint256 rAmount = (meAmount*referralRewards[i])/100;
        meToken.transfer(upline, rAmount);
        remainAmount -= rAmount;
      }
    }
    if(remainAmount > 0){
      meToken.transfer(_consensus_pool, remainAmount); //剩余
    }
    emit PurchaseStar(star, meAmount);
  }

  function getRewardRate(address account) public view returns(uint) {
    uint recmCount = recommended[account];
    if (recmCount < 4)
      return 30; // 0.3%
    if (recmCount < 7)
      return 40; // 0.4%
    if (recmCount < 9)
      return 50; // 0.5%
    return 60; // 0.6%
  }
  
  function getBalance(address account) public view returns(uint256 tReward, uint256 tResidual) {
    ConsensusPool[] storage cpArray = cpools[account];
    for(uint8 i = 0; i < cpArray.length; i ++) {
      ConsensusPool memory c = cpArray[i];
      uint rRate = getRewardRate(account);
      uint256 dayPassed = (block.timestamp - c.birthday) / rewardDuration;
      uint256 reward = (dayPassed * c.amount * rRate) / 10000;
      if ((reward + c.claimed) > c.amount)
        reward = c.amount - c.claimed;

      tReward += reward;//奖励
      tResidual += (c.amount - reward - c.claimed);//剩余
    }
  }

  function getReward(address account) public view returns(uint256) {
    (uint256 reward, ) = getBalance(account);
    return reward;
  }

  function claimReward() public {
    address account = msg.sender;
    uint256 tReward = 0;
    ConsensusPool[] storage cpArray = cpools[account];
    uint8 i;
    for(i = 0; i < cpArray.length; i ++) {
      ConsensusPool storage c = cpArray[i];
      uint rRate = getRewardRate(account);
      uint256 dayPassed = (block.timestamp - c.birthday) / rewardDuration;
      uint256 reward = (dayPassed * c.amount * rRate) / 10000;
      if ((reward + c.claimed) > c.amount)
        reward = c.amount - c.claimed;
      c.claimed += reward;
      c.birthday += dayPassed * rewardDuration;
      tReward += reward;
    }

    require(tReward > 0, "[MeStake] No reward to claim!");
    uint256 meAmount = getMeAmountForUsdt(tReward);
    require(meToken.balanceOf(_consensus_pool) >= meAmount, "[MeStake] Insufficient ME token balance in the contract!");
    // meToken.transfer(msg.sender, meAmount);
    consensusPool._out_pool(IERC20(_meToken),msg.sender,meAmount);

    // remove all claimed pools
    while(true) {
      cpArray = cpools[account];
      uint arrLength = cpArray.length;
      for(i = 0; i < arrLength; i ++) {
        ConsensusPool memory c = cpArray[i];
        if (c.claimed < c.amount)
          continue;
        
        uint last = arrLength - 1;
        if (i == last)
          cpArray.pop();
        else {
          c = cpArray[last];
          cpArray[i] = c;
          cpArray.pop();
          break;
        }
      }
      if (i == arrLength)
        break;
    }

    emit ClaimReward(tReward);
  }

  function withdrawByOwner() public onlyOwner {
    uint256 amount = meToken.balanceOf(address(this));
    require(amount > 0, "[MeStake] No ME token to withdraw!");
    meToken.transfer(owner(), amount);
  }
}