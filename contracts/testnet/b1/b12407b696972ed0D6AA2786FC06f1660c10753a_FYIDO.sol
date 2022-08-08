pragma solidity ^0.8.15;
//SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
// import "@uniswap/v2-core/contracts/interfaces/IuniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

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

interface IERC20Ext is IERC20{
  function decimals() external view returns(uint8);
  function pair() external view returns(address);
  function router() external view returns(address);
  function setTradeEnable(bool) external;
}

interface IYHNFT {
  function mint(address) external;
  function balanceOf(address owner) external view returns (uint256);
}

contract FYIDO is Ownable {
  struct Partner {
    bool  bought;
    uint  inviteCount;
    bool  lv2Opened;
    bool  paid300;
  }
  struct Investor {
    uint    level;
    uint    inviteCount;
    bool    rewardReceived;
    uint256 claimAmount;
  }

  struct TeamPerformance {
    address who;
    uint256 performance;
  }

  IERC20Ext public yhToken;
  IERC20Ext public paymentToken;
  uint256 public yhClaimAmount100;
  uint256 public yhClaimAmount300;
  IUniswapV2Pair public pair;
  IUniswapV2Router01 public router;
  uint256 public idoPrice; // in usdt
  uint256 public idoPriceLv2; // in usdt
  uint256 ticketPrice; // in usdt
  mapping(address=>Investor) public investors;
  uint256 public inverstorCount;
  mapping(address=>address) public referrals;
  bool public idoFinished;
  uint public percentLiquidity;
  uint public percentTeam;
  address public teamWallet;
  uint8 public targetInviteNumber;
  uint public totalInvestors;
  uint256 public totalTokensToProvide;
  IYHNFT public yhNft;

  event Claim(address, uint256);
  event ParticipateIDO100(address, address, uint256);
  event ParticipateIDO300(address, uint256);
  event ParticipatePartner(address, uint256);
  event EndIDO(uint256 lp, uint256 dev);
  event ClaimPartnerReward(address);

  modifier onlyInIdo() {
    require(!idoFinished, "[YHIDO] IDO already finished!");
    _;
  }

  function init(address yhToken_, address paymentToken_) public onlyOwner {
    setIDOTokens(yhToken_, paymentToken_);
    setLiquidityPercent(80);
    setTeamWallet(0x85048aae2FCc6877cA379e2dfDD61ea208Fa076C);
    setTargetInviteNumber(10);
  }

  constructor (address yht, address pt) {
    init(yht, pt);
  }

  function setIDOTokens(address yh, address pt) public onlyOwner {
    // set parameters related with YH token
    yhToken = IERC20Ext(yh);
    pair = IUniswapV2Pair(yhToken.pair());
    router = IUniswapV2Router01(yhToken.router());
    // set parameters related with USDT token
    paymentToken = IERC20Ext(pt);
    uint8 ptDecimal = paymentToken.decimals();
    idoPrice = 100*(10**ptDecimal); // 100 usdt
    idoPriceLv2 = 300*(10**ptDecimal); // 300 usdt
    ticketPrice = 300*(10**ptDecimal); // 300 usdt
    // caim amount after finished ido
    yhClaimAmount100 = getAmountYhForUsdt(idoPrice);
    yhClaimAmount300 = getAmountYhForUsdt(idoPriceLv2);
  }
  
  function setLiquidityPercent(uint percent) public onlyOwner {
    require(percent < 100, "[YHIDO] Percent valud should be less than 100!");
    percentLiquidity = percent;
    percentTeam = 100 - percent;
  }

  function setTeamWallet(address addr) public onlyOwner {
    teamWallet = addr;
  }

  function setTargetInviteNumber(uint8 n) public onlyOwner {
    targetInviteNumber = n;
  }

  function setYhNft(address addr) public onlyOwner {
    yhNft = IYHNFT(addr);
  }

  function getReferralDepth(address addr) private view returns(uint) {
    address upline = msg.sender;
    uint depth = 0;
    while(upline != address(0)) {
      depth ++;
      upline = referrals[upline];
    }
    return depth;
  }

  function getTeamPerformance(address account) private view returns(TeamPerformance[] memory) {
    uint teamDepth = getReferralDepth(account);
    TeamPerformance[] memory teamPerfArray = new TeamPerformance[](teamDepth);
    address upline = account;
    uint256 perf = 0;
    uint i = 0;
    while(upline != address(0)) {
      TeamPerformance memory tp;
      tp.who = upline;
      tp.performance = perf;
      teamPerfArray[i] = tp;
      perf += 100;
      upline = referrals[upline];
      i ++;
    }
    return teamPerfArray;
  }

  function participateIDO100(address recommender) public onlyInIdo {
    require(investors[msg.sender].level == 0, "[YHIDO] You can only participate once!");
    require(msg.sender != recommender, "[YHIDO] Recommender should not be same with your address!");
    require(recommender == address(0) || investors[recommender].level != 0, "[YHIDO] Wrong recommender!");
    // deposit 100 usdt
    uint256 beforeBalance = paymentToken.balanceOf(address(this));
    paymentToken.transferFrom(msg.sender, address(this), idoPrice);
    uint256 payAmount = paymentToken.balanceOf(address(this)) - beforeBalance;
    uint256 amountForTeam = payAmount;
    // register investor
    investors[msg.sender].level = 1;
    investors[msg.sender].claimAmount += yhClaimAmount100;
    referrals[msg.sender] = recommender;
    totalTokensToProvide += yhClaimAmount100;
    // reward to recommender
    if (    recommender != address(0) 
        &&  investors[recommender].level != 0
        /*&&  yhNft.balanceOf(recommender) > 0*/) {
      uint256 reward = (payAmount*5)/100;
      paymentToken.transfer(recommender, reward); // 5%
      amountForTeam -= reward;
      address recommenderLv2 = referrals[recommender];
      if (recommenderLv2 != address(0)) {
        reward = (payAmount*3)/100;
        paymentToken.transfer(recommenderLv2, reward); // 3%
        amountForTeam -= reward;
      }
      investors[recommender].inviteCount ++;
      if (investors[recommender].level == 2) {
        if (investors[recommender].inviteCount >= targetInviteNumber) {
          // refund ticket and reward NFT
          investors[recommender].level = 3;
        }
      }
    } 
    // else {
    //   uint256 reward = (payAmount*5)/100;
    //   paymentToken.transfer(0x7DEfe04FEEd55f771226627f1c7550Ca89742D91, reward); // 5%
    //   amountForTeam -= reward;
    // }
    paymentToken.transfer(teamWallet, amountForTeam);
    totalInvestors ++;
    emit ParticipateIDO100(msg.sender, recommender, idoPrice);
  }

  function claimPartnerReward() public {
    require(investors[msg.sender].level >= 3, "[YHIDO] You are not the partner!");
    require(!investors[msg.sender].rewardReceived, "[YHIDO] You have already received the partner reward!");
    paymentToken.transfer(msg.sender, ticketPrice);
    yhNft.mint(msg.sender);
    emit ClaimPartnerReward(msg.sender);
  }

  function participateIDO300() public onlyInIdo {
    require(investors[msg.sender].level == 3, "[YHIDO] You have not priviledge to participate IDO 300!");
    paymentToken.transferFrom(msg.sender, teamWallet, idoPriceLv2);
    investors[msg.sender].claimAmount += yhClaimAmount300;
    investors[msg.sender].level = 4;
    totalTokensToProvide += yhClaimAmount300;
    totalInvestors ++;
    emit ParticipateIDO300(msg.sender, idoPriceLv2);
  }

  function participatePartner() public onlyInIdo {
    require(investors[msg.sender].level == 1, "[YHIDO] You are not allowed to buy ticket!");
    require(paymentToken.balanceOf(msg.sender) >= ticketPrice, "[YHIDO] Your USDT balance is less then ticket cost!");
    // deposit 300 usdt
    paymentToken.transferFrom(msg.sender, address(this), ticketPrice);
    investors[msg.sender].level = 2;

    emit ParticipatePartner(msg.sender, ticketPrice);
  }

  function isAvailToIDO300(address account) public view returns(bool) {
    return investors[account].level == 3;
  }

  function setIdoEndFlag(bool flag) public onlyOwner {
    idoFinished = flag;
  }

  function endIDO() public onlyOwner {
    idoFinished = true;
    // add liquidity
    // uint256 totalUsdtAmount = paymentToken.balanceOf(address(this));
    // uint256 usdtForLiquidity = totalUsdtAmount * percentLiquidity / 100;
    // uint256 yhForLiquidity = getAmountYhForUsdt(usdtForLiquidity);
    // addLiquidity(yhForLiquidity, usdtForLiquidity);

    if (totalTokensToProvide > 0)
      yhToken.transferFrom(owner(), address(this), totalTokensToProvide);
    // send remain usdt to team wallet
    uint256 remainUsdt = paymentToken.balanceOf(address(this));
    if (remainUsdt > 0)
      paymentToken.transfer(teamWallet, remainUsdt);
    // enable trade token
    // yhToken.setTradeEnable(true);
    emit EndIDO(totalTokensToProvide, remainUsdt);
  }

  function withdrawAll() public onlyOwner {
    require(idoFinished, "[YHIDO] IDO is not finished yet!");
    uint256 totalUsdtBalance = paymentToken.balanceOf(address(this));
    if (totalUsdtBalance > 0)
      paymentToken.transfer(owner(), totalUsdtBalance);
    uint256 totalYhBalance = yhToken.balanceOf(address(this));
    if (totalYhBalance > 0)
      yhToken.transfer(owner(), totalYhBalance);
  }

  function getAmountYhForUsdt(uint256 usdtAmount) public view returns(uint256) {
    // (uint256 yh, uint256 usdt) = getLiquidityPairAmount();
    // return (yh * usdtAmount) / usdt;
    uint8 yhDecimal = yhToken.decimals();
    uint8 ptDecimal = paymentToken.decimals();
    uint256 amount = (usdtAmount * (10**yhDecimal) * 100) / (10**ptDecimal);
    return amount; // 1 usdt = 100 YH
  }

  function getLiquidityPairAmount() public view returns(uint256 amountYh, uint256 amountUsdt)  {
    (uint256 token0, uint256 token1, ) = pair.getReserves();
    if (pair.token0() == address(yhToken)) {
      amountYh = token0;
      amountUsdt = token1;
    }
    else {
      amountYh = token1;
      amountUsdt = token0;
    }
  }

  function addLiquidity(uint256 yhAmount, uint256 usdtAmount) private returns(uint256 stakedToken, uint256 stakedUsdt, uint256 liquidity) {
    // approve token transfer to cover all possible scenarios
    paymentToken.approve(address(router), usdtAmount);
    yhToken.transferFrom(owner(), address(this), yhAmount);
    yhToken.approve(address(router), yhAmount);
    // add the liquidity
    (stakedToken,stakedUsdt,liquidity) = router.addLiquidity(
        address(paymentToken),
        address(yhToken),
        usdtAmount,
        yhAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        owner(),
        block.timestamp
    );
  }

  function claimYh() public {
    require(idoFinished, "[YHIDO] IDO is still in progress.");
    require(investors[msg.sender].level != 0, "[YHIDO] You are not the investor, or you have already received tokens!");
    investors[msg.sender].level = 0;
    yhToken.transfer(msg.sender, investors[msg.sender].claimAmount);
    investors[msg.sender].claimAmount = 0;
    investors[msg.sender].inviteCount = 0;
    emit Claim(msg.sender, investors[msg.sender].claimAmount);
  }

  function clearInvestor(address addr) public onlyOwner {
    investors[addr].level = 0;
    investors[addr].inviteCount = 0;
    investors[addr].claimAmount = 0;
  }

  function clearTotalTokensToProvide() public onlyOwner {
    totalTokensToProvide = 0;
  }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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