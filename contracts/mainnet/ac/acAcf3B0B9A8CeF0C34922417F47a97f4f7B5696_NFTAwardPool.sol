/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}


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



contract NFTAwardPool is Ownable{

  using SafeMath for uint256;

  // reference to the Block NFT contract
  IERC721Enumerable genis_nft=IERC721Enumerable(0x856af1619929028798fda2f81eE7D2BF9dCB0d74);
  IERC721Enumerable honor_nft=IERC721Enumerable(0x37B1e9897A661993D2225E7D353717cfB0b9F4d7);
  IERC721Enumerable legend_nft=IERC721Enumerable(0xC5EE34305347B8B105b397fD070E34212Fe3E193);
  IERC20 busd=IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
  address public releaseAwardWallet=0x9F084FC7cc5c6D990dCc1Bb3c43eed9dB97F3a22;
  mapping(uint256=>NFT_Award_Pool) private awardOfGenisTokenId;
  mapping(uint256=>NFT_Award_Pool) private awardOfHonorTokenId;
  mapping(uint256=>NFT_Award_Pool) private awardOfLegendTokenId;
  
  
  struct NFT_Award_Pool{
      uint256 genisUintPriceAcc;
      uint256 honorUintPriceAcc;
      uint256 legendUintPriceAcc;
      uint256 claimedLastBlock;
      uint256 awardBlock;
      uint256 claimedAwardAmount;
  }

  NFT_Award_Pool poolRecord=NFT_Award_Pool(0,0,0,0,0,0);

  constructor() { 
    
  }

  function setReleaseAwardWallet(address addr) external onlyOwner{
      releaseAwardWallet=addr;
  }


  function setGenisNFT(address addr) external onlyOwner{
      genis_nft=IERC721Enumerable(addr);
  }

  function setHonorNFT(address addr) external onlyOwner{
      honor_nft=IERC721Enumerable(addr);
  }


  function setLegendNFT(address addr) external onlyOwner{
      legend_nft=IERC721Enumerable(addr);
  }



  function claimAward() external {
    uint256 balanceGenis = genis_nft.balanceOf(msg.sender);
    uint256 balanceHonor = honor_nft.balanceOf(msg.sender);
    uint256 balanceLegend= legend_nft.balanceOf(msg.sender);
    require(!(balanceGenis==0 && balanceHonor==0 && balanceLegend==0),'you have no nft of 9cc1, pls check!');

    uint256 rewardBusdOfSender=0;
    for (uint256 i = 0; i < balanceGenis; i++) {
        uint256 tokenId=genis_nft.tokenOfOwnerByIndex(msg.sender, i);
        if(awardOfGenisTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.genisUintPriceAcc;

        }else if(awardOfGenisTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfGenisTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.genisUintPriceAcc.sub(awardOfGenisTokenId[tokenId].claimedAwardAmount);
        }
        awardOfGenisTokenId[tokenId].claimedAwardAmount=poolRecord.genisUintPriceAcc;
        awardOfGenisTokenId[tokenId].claimedLastBlock=block.number;
    }

    for (uint256 i = 0; i < balanceHonor; i++) {
        uint256 tokenId=honor_nft.tokenOfOwnerByIndex(msg.sender, i);
        
        if(awardOfHonorTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.honorUintPriceAcc;

        }else if(awardOfHonorTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfHonorTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.honorUintPriceAcc.sub(awardOfHonorTokenId[tokenId].claimedAwardAmount);
        }
        awardOfHonorTokenId[tokenId].claimedAwardAmount=poolRecord.honorUintPriceAcc;
        awardOfHonorTokenId[tokenId].claimedLastBlock=block.number;


    }

    for (uint256 i = 0; i < balanceLegend; i++) {
        uint256 tokenId=legend_nft.tokenOfOwnerByIndex(msg.sender, i);
        
        if(awardOfLegendTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.legendUintPriceAcc;

        }else if(awardOfLegendTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfLegendTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.legendUintPriceAcc.sub(awardOfLegendTokenId[tokenId].claimedAwardAmount);
        }
        awardOfLegendTokenId[tokenId].claimedAwardAmount=poolRecord.legendUintPriceAcc;
        awardOfLegendTokenId[tokenId].claimedLastBlock=block.number;

    }

    if(rewardBusdOfSender>0){
        IERC20(busd).transfer(msg.sender, rewardBusdOfSender);
    }
    

  }




  
  function releaseAwardTrigger() external {
    
    require(msg.sender==releaseAwardWallet,"no permission to release award");
    uint256 balance_busd_sender=busd.balanceOf(msg.sender);
    require( balance_busd_sender>0, "the balance of busd is 0,pls check!");
    busd.transferFrom(msg.sender, address(this), balance_busd_sender);
    


    

    uint totalSupplyGenis = genis_nft.totalSupply();

    uint totalSupplyHonor = honor_nft.totalSupply();

    uint totalSupplyLegend = legend_nft.totalSupply();

    uint256 genis_nft_basis=10;

    uint256 honor_nft_basis=25;

    uint256 legend_nft_basis=50;

    uint totalNFTWeight=totalSupplyGenis.mul(genis_nft_basis)+totalSupplyHonor.mul(honor_nft_basis)+totalSupplyLegend.mul(legend_nft_basis);

    poolRecord.awardBlock=block.number;
    
    uint256 genisNFTUnitAward=genis_nft_basis.mul(balance_busd_sender).div(totalNFTWeight);

    poolRecord.genisUintPriceAcc+=genisNFTUnitAward;

    uint256 honorNFTUnitAward=honor_nft_basis.mul(balance_busd_sender).div(totalNFTWeight);

    poolRecord.honorUintPriceAcc+=honorNFTUnitAward;

    uint256 legendNFTUnitAward=legend_nft_basis.mul(balance_busd_sender).div(totalNFTWeight);

    poolRecord.legendUintPriceAcc+=legendNFTUnitAward;


    

  }


  



  function privewUnclaimedAward(address account) external view returns(uint256) {
    uint256 balanceGenis = genis_nft.balanceOf(account);
    uint256 balanceHonor = honor_nft.balanceOf(account);
    uint256 balanceLegend= legend_nft.balanceOf(account);
    require(!(balanceGenis==0 && balanceHonor==0 && balanceLegend==0),'you have no nft of 9cc1, pls check!');

    uint256 rewardBusdOfSender=0;
    for (uint256 i = 0; i < balanceGenis; i++) {
        uint256 tokenId=genis_nft.tokenOfOwnerByIndex(account, i);
        if(awardOfGenisTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.genisUintPriceAcc;

        }else if(awardOfGenisTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfGenisTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.genisUintPriceAcc.sub(awardOfGenisTokenId[tokenId].claimedAwardAmount);
        }
        //awardOfGenisTokenId[tokenId].claimedAwardAmount=poolRecord.genisUintPriceAcc;
        //awardOfGenisTokenId[tokenId].claimedLastBlock=block.number;
    }

    for (uint256 i = 0; i < balanceHonor; i++) {
        uint256 tokenId=honor_nft.tokenOfOwnerByIndex(account, i);
        
        if(awardOfHonorTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.honorUintPriceAcc;

        }else if(awardOfHonorTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfHonorTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.honorUintPriceAcc.sub(awardOfHonorTokenId[tokenId].claimedAwardAmount);
        }
        //awardOfHonorTokenId[tokenId].claimedAwardAmount=poolRecord.honorUintPriceAcc;
        //awardOfHonorTokenId[tokenId].claimedLastBlock=block.number;


    }

    for (uint256 i = 0; i < balanceLegend; i++) {
        uint256 tokenId=legend_nft.tokenOfOwnerByIndex(account, i);
        
        if(awardOfLegendTokenId[tokenId].claimedLastBlock==0 && poolRecord.awardBlock>0){
            rewardBusdOfSender+=poolRecord.legendUintPriceAcc;

        }else if(awardOfLegendTokenId[tokenId].claimedLastBlock>0 && poolRecord.awardBlock>awardOfLegendTokenId[tokenId].claimedLastBlock){
            rewardBusdOfSender+=poolRecord.legendUintPriceAcc.sub(awardOfLegendTokenId[tokenId].claimedAwardAmount);
        }
        //awardOfLegendTokenId[tokenId].claimedAwardAmount=poolRecord.legendUintPriceAcc;
        //awardOfLegendTokenId[tokenId].claimedLastBlock=block.number;

    }

    return rewardBusdOfSender;

  }

  

  function getTotalWeightNFT() public view returns(uint256){
    uint totalSupplyGenis = genis_nft.totalSupply();

    uint totalSupplyHonor = honor_nft.totalSupply();

    uint totalSupplyLegend = legend_nft.totalSupply();

    uint totalNFTWeight=totalSupplyGenis.mul(10)+totalSupplyHonor.mul(25)+totalSupplyLegend.mul(50);

    return totalNFTWeight;

  }

  function getTotalSupplyGenisNFT() public view returns(uint256){
    uint totalSupplyGenis = genis_nft.totalSupply();

    return totalSupplyGenis;

  }

  function getTotalSupplyHonorNFT() public view returns(uint256){

    uint totalSupplyHonor = honor_nft.totalSupply();

    

    return totalSupplyHonor;

  }


  function getTotalSupplyLegendNFT() public view returns(uint256){

    uint totalSupplyLegend = legend_nft.totalSupply();

    return totalSupplyLegend;

  }



  function withdrawAllOfToken(address token) external onlyOwner{
    //require(amount > 0,'Why do it?');
    require(token != address(0),'Why do it?');
    IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
  }

}