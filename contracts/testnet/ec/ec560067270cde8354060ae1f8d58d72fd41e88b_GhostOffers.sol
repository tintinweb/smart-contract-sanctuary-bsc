/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

//SPDX-License-Identifier: No License

//Author @tyeler - littleghosts

pragma solidity ^0.8.0;


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
 
/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


interface IDEXRouter {
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
   * desired value afterwards: tyeler
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

/**
* @dev Wrappers over Solidity's arithmetic operations with added overflow
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

abstract contract MarketRewards {
    function reflectToMinters() public payable virtual;
    function reflectToHolders() public payable virtual;
}

contract GhostOffers is Auth,ERC721Holder {
    using SafeMath for uint256;

    struct TokenOffer {
        uint256 tokenOfferId;
        address tokenAddress;
        uint256 nftId;
        address nftAddress;
        uint256 price;
        address buyer;
        bytes32 status;
    }

    struct NFTOffer {
        uint256 nftOfferId;
        address buyer;
        address soldNftAddress;
        uint256[] soldNftIds;
        address wantedNftAddress;
        uint256 wantedNftId;
        bytes32 status;
    }

    IDEXRouter public router;
    address payable _devWallet;
    MarketRewards marketRewards;


    // (collection address) -> (nftid -> offer)
    mapping (address => mapping(uint256 => NFTOffer[])) public _nftOffersByCollection;
    mapping (address => mapping(uint256 => TokenOffer[])) public _tokenOffersByCollection;
    mapping(address => uint256) public pendingRewards;

    //acceptable tokens & nfts you can offer
    address[] public acceptablePaymentTokens;
    address[] public acceptablePaymentNFTs;
    //nfts that can receive offers
    address[] public acceptableOfferedNFTs;


    uint256 public nftOfferIndex = 0;
    uint256 public tokenOfferIndex = 0;

    address busdContract = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address ectoContract = 0xEA340B35207b2C795C5CCF9a1B78bEfC838516E8;
    address wbnbContract = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address rewardsContract = 0x744480f678242574BCd145bc6A3cE80b4b86510a;


    constructor() Auth(msg.sender) {
        router = IDEXRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        _devWallet = payable(0x896986Db81727B2C7253cE533DF44fC6A42d7A78);
        marketRewards = MarketRewards(rewardsContract);
    }

    receive() payable external {}


    function sellToken(address contractAddress, uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = contractAddress;
        path[1] = router.WETH();

        IERC20(contractAddress).approve(address(router), amount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        pendingRewards[contractAddress] = 0;
    }

    function swapBUSD() external onlyOwner{
        uint256 pendingBUSD = pendingRewards[busdContract];
        uint256 amountToSwap = pendingBUSD;
        if(amountToSwap > 0){
            sellToken(busdContract,amountToSwap);
        }
    }
    function swapECTO() external onlyOwner{
        uint256 pendingECTO = pendingRewards[ectoContract];
        uint256 amountToSwap = pendingECTO;
        if(amountToSwap > 0){
            sellToken(ectoContract,amountToSwap);
        }
    }
    function swapWBNB()external onlyOwner{
        uint256 pendingWBNB = pendingRewards[wbnbContract];
        uint256 amountToSwap = pendingWBNB;
        if(amountToSwap > 0){
            IWETH(wbnbContract).withdraw(amountToSwap);
            pendingRewards[wbnbContract] = 0;
        }
    }
    function addBNBToRewardContract() external onlyOwner{
        uint256 minterReward = address(this).balance.div(2);
        uint256 holderReward = address(this).balance.div(4);

        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();

    }
    function transferToDevWallet() external onlyOwner{
        _devWallet.transfer(address(this).balance);
    }

    function swapForRewards() external onlyOwner{
        uint256 pendingBUSD = pendingRewards[busdContract];
        uint256 pendingECTO = pendingRewards[ectoContract];
        uint256 pendingWBNB = pendingRewards[wbnbContract];

        //Sell BUSD & ECTO for BNB, Convert WBNB to BNB
        if(pendingBUSD > 0){sellToken(busdContract,pendingBUSD);}
        if(pendingECTO > 0){sellToken(ectoContract,pendingECTO);}
        if(pendingWBNB > 0){IWETH(wbnbContract).withdraw(pendingWBNB);
            pendingRewards[wbnbContract] = 0;}

        uint256 minterReward = address(this).balance.div(2);
        uint256 holderReward = address(this).balance.div(4);
        uint256 devReward = (address(this).balance - (minterReward + holderReward));

        //Transfer 25% to minters and 50% to holders to the Reward Contract
        marketRewards.reflectToHolders{value: holderReward}();
        marketRewards.reflectToMinters{value: minterReward}();

        //Transfer 25% to the development wallet
        _devWallet.transfer(devReward);
    }

    function setRouter(address addr) external authorized {
        require(addr != address(0), "Can not be the zero address.");
        router = IDEXRouter(addr);
    }
    function setDevWallet(address addr) external onlyOwner {
        require(addr != address(0), "Can not be the zero address.");
        _devWallet = payable(addr);
    }
    function setEctoContract(address addr) external onlyOwner {
        require(addr != address(0), "Can not be the zero address.");
        ectoContract = addr;
    }
    function setAcceptablePaymentToken(address addr) external authorized {
        require(addr != address(0), "Can not be the zero address.");
        require(isAcceptablePaymentToken(addr) == false, "Already added to the acceptable token list.");
        acceptablePaymentTokens.push(addr);
    }

    function isAcceptablePaymentToken(address addr) private view returns(bool) {
        for (uint256 i = 0; i < acceptablePaymentTokens.length; i++)
        {
            if(acceptablePaymentTokens[i] == addr)
            {
                return true;
            }
        }
        return false;
    }

    function setAcceptableNFT(address addr) external authorized {
        require(addr != address(0), "Can not be the zero address.");
        require(isAcceptableNFT(addr) == false, "Already added to the acceptable nft list.");
        acceptablePaymentNFTs.push(addr);
    }

    function isAcceptableNFT(address addr) private view returns(bool) {
        for (uint256 i = 0; i < acceptablePaymentNFTs.length; i++)
        {
            if(acceptablePaymentNFTs[i] == addr)
            {
                return true;
            }
        }
        return false;
    }

    function setAcceptableOfferedNFT(address addr) external authorized {
        require(addr != address(0), "Can not be the zero address.");
        require(isAcceptableOfferedNFT(addr) == false, "Already added to nft list.");
        acceptableOfferedNFTs.push(addr);
    }

    function isAcceptableOfferedNFT(address addr) private view returns(bool) {
        for (uint256 i = 0; i < acceptableOfferedNFTs.length; i++)
        {
            if(acceptableOfferedNFTs[i] == addr)
            {
                return true;
            }
        }
        return false;
    }

    function removeTokenOffer(address nftAddress, uint256 nftId, uint256 offerIndex) internal{
        if (offerIndex >= _tokenOffersByCollection[nftAddress][nftId].length) return;

        for (uint i = offerIndex; i<_tokenOffersByCollection[nftAddress][nftId].length-1; i++){
            _tokenOffersByCollection[nftAddress][nftId][i] = _tokenOffersByCollection[nftAddress][nftId][i+1];
        }
        _tokenOffersByCollection[nftAddress][nftId].pop();
    }

    function removeNFTOffer(address nftAddress, uint256 nftId, uint256 offerIndex) internal{
        if (offerIndex >= _nftOffersByCollection[nftAddress][nftId].length) return;

        for (uint i = offerIndex; i<_nftOffersByCollection[nftAddress][nftId].length-1; i++){
            _nftOffersByCollection[nftAddress][nftId][i] = _nftOffersByCollection[nftAddress][nftId][i+1];
        }
        _nftOffersByCollection[nftAddress][nftId].pop();
    }


    function rejectOffer(address _nftAddress, uint256 _nftId, uint256 offerIndex, uint256 offerId, bool isToken) public {
        IERC721 n = IERC721(_nftAddress);
        require(n.ownerOf(_nftId) == msg.sender, "You can not reject an offer for a nft you don't own.");

        if(isToken){ //token offer
            require(_tokenOffersByCollection[_nftAddress][_nftId][offerIndex].tokenOfferId == offerId, "The offers have updated.");
            _tokenOffersByCollection[_nftAddress][_nftId][offerIndex].status="Rejected";
        }else{ //nft offer
            require(_nftOffersByCollection[_nftAddress][_nftId][offerIndex].nftOfferId == offerId, "The offers have updated.");
            _nftOffersByCollection[_nftAddress][_nftId][offerIndex].status="Rejected";
        }

    }

    function acceptTokenOffer(address _nftAddress, uint256 _nftId, uint256 offerIndex, uint256 offerId) public{
        IERC721 nft = IERC721(_nftAddress);
        IERC20 token = IERC20(_tokenOffersByCollection[_nftAddress][_nftId][offerIndex].tokenAddress);
        TokenOffer memory offer = _tokenOffersByCollection[_nftAddress][_nftId][offerIndex];

        uint256 rewardFee = offer.price.mul(1000).div(10000); //10%

        require(nft.ownerOf(_nftId) == msg.sender, "You are not the owner to accept this offer.");
        require(_tokenOffersByCollection[_nftAddress][_nftId][offerIndex].tokenOfferId == offerId, "The offers have updated.");

        nft.transferFrom(msg.sender, offer.buyer, _nftId);
        token.transfer(msg.sender, offer.price.sub(rewardFee));
        pendingRewards[offer.tokenAddress] += rewardFee;
        removeTokenOffer(_nftAddress,_nftId,offerIndex);
    }

    function acceptNFTOffer(address _nftAddress, uint256 _nftId, uint256 offerIndex, uint256 offerId) public{
        IERC721 nft = IERC721(_nftAddress);
        IERC721 soldNftAddress = IERC721(_nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftAddress);

        require(nft.ownerOf(_nftId) == msg.sender, "You are not the owner to accept this offer.");
        require(_nftOffersByCollection[_nftAddress][_nftId][offerIndex].nftOfferId == offerId, "The offers have updated.");

        //transfer the wanted nft to the offerer
        nft.transferFrom(msg.sender, _nftOffersByCollection[_nftAddress][_nftId][offerIndex].buyer, _nftId);

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for(uint256 i= 0 ; i < expectedTokenAmount; i++){
            soldNftAddress.safeTransferFrom(address(this), msg.sender, _nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftIds[i]);
        }

        //lastly remove the nft offer
        removeNFTOffer(_nftAddress,_nftId,offerIndex);
    }

    function cancelTokenOffer(address _nftAddress, uint256 _nftId, uint256 offerIndex, uint256 offerId) public{
        IERC20 token = IERC20(_tokenOffersByCollection[_nftAddress][_nftId][offerIndex].tokenAddress);

        require(msg.sender == _tokenOffersByCollection[_nftAddress][_nftId][offerIndex].buyer, "You are not the person who made the offer.");
        require(_tokenOffersByCollection[_nftAddress][_nftId][offerIndex].tokenOfferId == offerId, "The offers have updated.");

        token.transfer(msg.sender, _tokenOffersByCollection[_nftAddress][_nftId][offerIndex].price);
        removeTokenOffer(_nftAddress,_nftId,offerIndex);
    }

    function cancelNFTOffer(address _nftAddress, uint256 _nftId, uint256 offerIndex, uint256 offerId) public{
        IERC721 soldNftAddress = IERC721(_nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftAddress);

        require(msg.sender == _nftOffersByCollection[_nftAddress][_nftId][offerIndex].buyer, "You are not the person who made the offer.");
        require(_nftOffersByCollection[_nftAddress][_nftId][offerIndex].nftOfferId == offerId, "The offers have updated.");

        uint256 expectedTokenAmount = _nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftIds.length;

        //transfer the nfts from the contract to the person who accepted them
        for(uint256 i= 0 ; i < expectedTokenAmount; i++){
            soldNftAddress.safeTransferFrom(address(this), msg.sender, _nftOffersByCollection[_nftAddress][_nftId][offerIndex].soldNftIds[i]);
        }

        //lastly remove the nft offer
        removeNFTOffer(_nftAddress,_nftId,offerIndex);
    }

    function createTokenOffer(address _nftAddress, uint256 _nftId,  address offeredToken, uint256 offeredAmount) public{
        require(isAcceptablePaymentToken(offeredToken), "You can not offer this token currently.");
        require(isAcceptableOfferedNFT(_nftAddress), "You can not create an offer on this NFT.");

        IERC20 token = IERC20(offeredToken);

        token.transferFrom(msg.sender, address(this), offeredAmount);

        tokenOfferIndex = tokenOfferIndex.add(1);

        _tokenOffersByCollection[_nftAddress][_nftId].push(TokenOffer({
        tokenOfferId : tokenOfferIndex,
        tokenAddress : offeredToken,
        nftId : _nftId,
        nftAddress : _nftAddress,
        price : offeredAmount,
        buyer : msg.sender,
        status : "Active"
        }));
    }
    function createNFTOffer(address _nftAddress, uint256 _nftId,  address offeredNFT, uint256[] calldata offeredIds) public{
        IERC721 offeredNftAddress = IERC721(offeredNFT);

        require(isAcceptableNFT(offeredNFT), "You can not offer this token currently.");
        require(isAcceptableOfferedNFT(_nftAddress), "You can not create an offer on this NFT.");

        for(uint256 i= 0; i < offeredIds.length; i++){
            require(offeredNftAddress.ownerOf(offeredIds[i]) == msg.sender, "You do not own one of the nft's you are offering.");
            offeredNftAddress.transferFrom(msg.sender, address(this), offeredIds[i]);
        }

        nftOfferIndex = nftOfferIndex.add(1);

        _nftOffersByCollection[_nftAddress][_nftId].push(NFTOffer({
        nftOfferId : nftOfferIndex,
        buyer : msg.sender,
        soldNftAddress : offeredNFT,
        soldNftIds : offeredIds,
        wantedNftAddress : _nftAddress,
        wantedNftId : _nftId,
        status : "Active"
        }));
    }
}