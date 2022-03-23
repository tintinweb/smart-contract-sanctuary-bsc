/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// File: ..\..\..\..\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol

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

// File: @openzeppelin\contracts\token\ERC721\IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol


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

// File: @openzeppelin\contracts\security\ReentrancyGuard.sol


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

// File: @openzeppelin\contracts\utils\math\SafeMath.sol


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

// File: @openzeppelin\contracts\token\ERC721\IERC721Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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

// File: contracts\stake.sol


pragma solidity >=0.8.4;
contract NftStake is IERC721Receiver, ReentrancyGuard {
    using SafeMath for uint256;

    IERC721 public nftToken;
    IERC20 public erc20Token;

    address public daoAdmin;
        uint256 coins;


    uint256 public copper_tokensPerBlock = 0.001 ether;
    uint256 public SILVER_tokensPerBlock = 0.002 ether;
    uint256 public GOLD_tokensPerBlock = 0.003 ether;
    uint256 public DIAMOND_tokensPerBlock = 0.004 ether;


    struct stake {
        uint256 tokenId;
        uint256 stakedFromBlock;
        address owner;
        uint256 rango;
    }
    struct jefes{
        uint256 mount;
        uint256[] idnft;
        uint256[] nftrango;

    }

    // TokenID => Stake
    mapping(uint256 => stake) public receipt;
    mapping(address => jefes) public jefe;

    event NftStaked(address indexed staker, uint256 tokenId, uint256 blockNumber);
    event NftUnStaked(address indexed staker, uint256 tokenId, uint256 blockNumber);
    event StakePayout(address indexed staker, uint256 tokenId, uint256 stakeAmount, uint256 fromBlock, uint256 toBlock);

    modifier onlyStaker(uint256 tokenId) {
        // require that this contract has the NFT
        require(nftToken.ownerOf(tokenId) == address(this), "onlyStaker: Contract is not owner of this NFT");

        // require that this token is staked
        require(receipt[tokenId].stakedFromBlock != 0, "onlyStaker: Token is not staked");

        // require that msg.sender is the owner of this nft
        require(receipt[tokenId].owner == msg.sender, "onlyStaker: Caller is not NFT stake owner");

        _;
    }

    modifier requireTimeElapsed(uint256 tokenId) {
        // require that some time has elapsed (IE you can not stake and unstake in the same block)
        require(
            receipt[tokenId].stakedFromBlock < block.number,
            "requireTimeElapsed: Can not stake/unStake/harvest in same block"
        );
        _;
    }

    modifier onlyDao() {
        require(msg.sender == daoAdmin, "reclaimTokens: Caller is not the DAO");
        _;
    }

    constructor(
        IERC721 _nftToken,
        IERC20 _erc20Token,
        address _daoAdmin
    ) {
        nftToken = _nftToken;
        erc20Token = _erc20Token;
        daoAdmin = _daoAdmin;


    }

    /**
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

    //User must give this contract permission to take ownership of it.
    function stakeNFT(uint256[] calldata tokenId, uint256[] calldata _rango) public nonReentrant returns (bool) {
        // allow for staking multiple NFTS at one time.

        for (uint256 i = 0; i < tokenId.length; i++) {
            _stakeNFT(tokenId[i], _rango[i]);
        }

        return true;
    }

    function getStakeContractBalance() public view returns (uint256) {
        return erc20Token.balanceOf(address(this));
    }
    function getStakeNftBalance() public view returns (uint256) {
        return nftToken.balanceOf(address(this));
    }
    function getCurrentStakeEarned(uint256 tokenId) public view returns (uint256) {
        if(receipt[tokenId].rango == 0){
            return _getTimeStaked(tokenId).mul(copper_tokensPerBlock);

        }else if(receipt[tokenId].rango == 1){
           return _getTimeStaked(tokenId).mul(SILVER_tokensPerBlock);

        }else if(receipt[tokenId].rango == 2){
            return _getTimeStaked(tokenId).mul(GOLD_tokensPerBlock);

        }else if(receipt[tokenId].rango == 3){
           return _getTimeStaked(tokenId).mul(DIAMOND_tokensPerBlock);

        }
        return 0;
    }

    function unStakeNFT(uint256[] calldata tokenId) public nonReentrant returns (bool) {

         for (uint256 i = 0; i < tokenId.length; i++) {
           _unStakeNFT(tokenId[i]);
        }

        return true;
        //return _unStakeNFT(tokenId);
    }


    function _unStakeNFT(uint256 tokenId) internal onlyStaker(tokenId) requireTimeElapsed(tokenId) returns (bool) {
        // payout stake, this should be safe as the function is non-reentrant
        _payoutStake(tokenId);

        // delete stake record, effectively unstaking it
        delete receipt[tokenId];
        jefe[msg.sender].mount = jefe[msg.sender].mount - 1;
        
          
      //  uint256 tokenCount = nftToken.balanceOf(address(this));
        //uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i <  jefe[msg.sender].idnft.length; i++) {
            if ( jefe[msg.sender].idnft[i] == tokenId) { 
                 //delete jefe[msg.sender].idnft[i];
               jefe[msg.sender].idnft =  remove(jefe[msg.sender].idnft,i);

                 
             }
        }
        

        // return token
        nftToken.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NftUnStaked(msg.sender, tokenId, block.number);

        return true;
    }
 
    function remove(uint256[] memory array, uint256 index) internal returns(uint256[] memory value) {
       
        uint256[] memory arrayNew = new uint256[](array.length-1);
        for (uint256 i = 0; i<arrayNew.length; i++){
            if(i != index && i<index){
                arrayNew[i] = array[i];
            } else {
                arrayNew[i] = array[i+1];
            }
        }
        delete jefe[msg.sender].idnft;
        delete array;
        return arrayNew;
    }
    function harvest(uint256 tokenId) public nonReentrant onlyStaker(tokenId) requireTimeElapsed(tokenId) {
        // This 'payout first' should be safe as the function is nonReentrant
        _payoutStake(tokenId);

        // update receipt with a new block number
        receipt[tokenId].stakedFromBlock = block.number;
    }

    function changeTokensPerblock(uint256 _copper_tokensPerBlock,uint256 _SILVER_tokensPerBlock,uint256 _GOLD_tokensPerBlock,uint256 _DIAMOND_tokensPerBlock) public onlyDao {
        copper_tokensPerBlock = _copper_tokensPerBlock;
        SILVER_tokensPerBlock = _SILVER_tokensPerBlock;
        GOLD_tokensPerBlock = _GOLD_tokensPerBlock;
        DIAMOND_tokensPerBlock = _DIAMOND_tokensPerBlock;
}

    function reclaimTokens() external onlyDao {
        erc20Token.transfer(daoAdmin, erc20Token.balanceOf(address(this)));
    }

    function updateStakingReward(uint256 _copper_tokensPerBlock,uint256 _SILVER_tokensPerBlock,uint256 _GOLD_tokensPerBlock,uint256 _DIAMOND_tokensPerBlock) external onlyDao {
        copper_tokensPerBlock = _copper_tokensPerBlock;
        SILVER_tokensPerBlock = _SILVER_tokensPerBlock;
        GOLD_tokensPerBlock = _GOLD_tokensPerBlock;
        DIAMOND_tokensPerBlock = _DIAMOND_tokensPerBlock;

     }

    function _stakeNFT(uint256 tokenId, uint256 _rango) internal returns (bool) {
        // require this token is not already staked
        require(receipt[tokenId].stakedFromBlock == 0, "Stake: Token is already staked");

        // require this token is not already owned by this contract
        require(nftToken.ownerOf(tokenId) != address(this), "Stake: Token is already staked in this contract");

        // take possession of the NFT
        nftToken.safeTransferFrom(msg.sender, address(this), tokenId);

        // check that this contract is the owner
        require(nftToken.ownerOf(tokenId) == address(this), "Stake: Failed to take possession of NFT");

        // start the staking from this block.
        jefe[msg.sender].mount = jefe[msg.sender].mount + 1;
        jefe[msg.sender].idnft.push(tokenId);
        jefe[msg.sender].nftrango.push(_rango);
        receipt[tokenId].tokenId = tokenId;
        receipt[tokenId].rango = _rango;
        receipt[tokenId].stakedFromBlock = block.number;
        receipt[tokenId].owner = msg.sender;

        emit NftStaked(msg.sender, tokenId, block.number);

        return true;
    }
   
    function _payoutStake(uint256 tokenId) internal {
        /* NOTE : Must be called from non-reentrant function to be safe!*/

        // double check that the receipt exists and we're not staking from block 0
        require(receipt[tokenId].stakedFromBlock > 0, "_payoutStake: Can not stake from block 0");

        // earned amount is difference between the stake start block, current block multiplied by stake amount
        uint256 timeStaked = _getTimeStaked(tokenId).sub(1); // don't pay for the tx block of withdrawl
        uint256 payout;
        if(receipt[tokenId].rango == 0){

              payout = timeStaked.mul(copper_tokensPerBlock);

        }else if(receipt[tokenId].rango == 1){

              payout = timeStaked.mul(SILVER_tokensPerBlock);
        }else if(receipt[tokenId].rango== 2){

              payout = timeStaked.mul(GOLD_tokensPerBlock);

        }else if(receipt[tokenId].rango == 3){

              payout = timeStaked.mul(DIAMOND_tokensPerBlock);

        }
        // If contract does not have enough tokens to pay out, return the NFT without payment
        // This prevent a NFT being locked in the contract when empty
        if (erc20Token.balanceOf(address(this)) < payout) {
            emit StakePayout(msg.sender, tokenId, 0, receipt[tokenId].stakedFromBlock, block.number);
            return;
        }

        // payout stake
        erc20Token.transfer(receipt[tokenId].owner, payout);

        emit StakePayout(msg.sender, tokenId, payout, receipt[tokenId].stakedFromBlock, block.number);
    }

    function _getTimeStaked(uint256 tokenId) internal view returns (uint256) {
        if (receipt[tokenId].stakedFromBlock == 0) {
            return 0;
        }

        return block.number.sub(receipt[tokenId].stakedFromBlock);
    }





     function _mount() public view returns (uint256) {


       return jefe[msg.sender].mount;
    }

    function misnft(address add)  public view returns(uint256[] memory){
        
        uint256 tokenCount = nftToken.balanceOf(address(this));
        uint256[] memory tokensId = new uint256[](tokenCount);

        for (uint256 i = 0; i <  tokenCount; i++) {
            tokensId[i] = jefe[add].idnft[i];
        }
        return tokensId;
    }

    function setPrice(uint256 _newPriceCopper, uint256 _newPriceSilver ,uint256 _newPriceGold,uint256 _newPriceDiamon ) public onlyDao {        
            copper_tokensPerBlock = _newPriceCopper;
            SILVER_tokensPerBlock =_newPriceSilver;
            GOLD_tokensPerBlock = _newPriceGold;
            DIAMOND_tokensPerBlock = _newPriceDiamon;

    }

    /** Add Function to allow the DAO to forcibly unstake an NFT and return it to the owner */
}