/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
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


interface IBEP20 {
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

contract ReentrancyGuard {
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

    constructor () public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

contract NFTStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IERC721 public farmerNFT;
    IERC721 public farmerNFTPlus;
    IERC721 public farmerNFTPlusPlus;
    IERC721 public mythic;
    IBEP20 public mgmc;

    // True - Staking Fee should be applied when restaking and when withdraw then stake
    // False - Staking Fee should apply to only withdraw then stake
    bool public gSFee = true;
    uint256 public dailyBlock = 28600;


    uint256 public unstakeFee = 20;
    uint256 public restakeFee = 15;
    uint256 public stakeFee = 10;

    mapping(address => Deposit[]) public deposits;


    mapping(address => uint256) public depositLength;
    mapping(uint256 => Term) public terms;

    uint256 public termIndex = 11;
    uint256 public minTermIndex = 0;
    mapping(uint256 => bool) public mythicId;
    
    struct Term{
        uint256 lockedPeriod;
        uint256 mgmcPerDay;
    }

    struct Deposit{
        address walletAddress;
        uint256 tokenID;
        address tokenContract;
        uint256 timeDepositBlock;
        uint256 lastWithdrawBlock;
        bool status;
        Term term;
        uint256 choice; // 0- unstake, 1 - restake
        bool sFeeApplied; // true staking fee take effects
    }

    constructor (address _farmerNFT, address _farmerNFTPlus, address _farmerNFTPlusPlus, address _mythic, address _mgmc) public{
        farmerNFT = IERC721(_farmerNFT);
        farmerNFTPlus = IERC721(_farmerNFTPlus);
        farmerNFTPlusPlus = IERC721(_farmerNFTPlusPlus);
        mythic = IERC721(_mythic);
        mgmc = IBEP20(_mgmc);

        // 7,15,30 Day Farmer NFT Term
        terms[0] = (Term(200200,267e16));
        terms[1] = (Term(429000,333e16));
        terms[2] = (Term(858000,4e18));

        // 7,15,30 Day FarmerPlus NFT Term
        terms[3] = (Term(200200,1333e16));
        terms[4] = (Term(429000,1667e16));
        terms[5] = (Term(858000,20e18));

        // 7,15,30 Day FarmerPlusPlus NFT Term
        terms[6] = (Term(200200,8333e16));
        terms[7] = (Term(429000,100e18));
        terms[8] = (Term(858000,11667e16));

        // 7,15,30 Day Mythic NFT Term
        terms[9] = (Term(200200,100e18));
        terms[10] = (Term(429000,120e18));
        terms[11] = (Term(858000,140e18));


        // // 7,15,30 Day Farmer NFT Term
        // terms[0] = (Term(1191,267e16));
        // terms[1] = (Term(2383,333e16));
        // terms[2] = (Term(4766,4e18));

        // // 7,15,30 Day FarmerPlus NFT Term
        // terms[3] = (Term(1191,1333e16));
        // terms[4] = (Term(2383,1667e16));
        // terms[5] = (Term(4766,20e18));

        // // 7,15,30 Day FarmerPlusPlus NFT Term
        // terms[6] = (Term(1191,8333e16));
        // terms[7] = (Term(2383,100e18));
        // terms[8] = (Term(4766,11667e16));

        // // 7,15,30 Day Mythic NFT Term
        // terms[9] = (Term(1191,100e18));
        // terms[10] = (Term(2383,120e18));
        // terms[11] = (Term(4766,140e18));


    }

    function depositFarmer(uint256 _tokenId, address _erc721, uint256 _termId, uint256 _choice) public nonReentrant{
        require(_erc721 == address(farmerNFT) || _erc721 == address(farmerNFTPlus) || _erc721 == address(farmerNFTPlusPlus)  || _erc721 == address(mythic), "Not supported erc721");
        require(IERC721(_erc721).ownerOf(_tokenId) == msg.sender,"not owner");
        if(_erc721 == address(mythic)){
            require(mythicId[_tokenId], "token is not a mythic");
        }
        require(_termId <= termIndex , "invalid termId");
        require(_choice <= 1, "invalid choice");
        require(_checkEligibleTerms(_erc721,_termId), "ineligible term for erc721 contract");
        IERC721(_erc721).transferFrom(msg.sender,address(this),_tokenId);
        deposits[msg.sender].push(Deposit(msg.sender,_tokenId,_erc721,block.number,block.number,true,terms[_termId],_choice,true));
        depositLength[msg.sender] = depositLength[msg.sender]+1;
        
        
    }

    function PerformChoiceFarmer(uint256 depositIndex, uint256 _choice) public nonReentrant{
        require(depositIndex < depositLength[msg.sender], "invalid index");
        Deposit storage userDeposit = deposits[msg.sender][depositIndex];
        require(userDeposit.status, "withdrawn");
        uint256 lockedPeriod = userDeposit.timeDepositBlock.add(userDeposit.term.lockedPeriod);
        require(block.number > lockedPeriod, "cant perofrm action with lockedPeriod");
        if(userDeposit.choice == 0){
            uint256 amountToWithdraw = _distributeRewards(depositIndex,msg.sender);
            userDeposit.lastWithdrawBlock = block.number;
            IERC721(userDeposit.tokenContract).transferFrom(address(this),msg.sender,userDeposit.tokenID);
            mgmc.transfer(msg.sender, amountToWithdraw);
            
            userDeposit.status = false;
        }else{
            uint256 amountToWithdraw = _distributeRewards(depositIndex,msg.sender);
            userDeposit.lastWithdrawBlock = block.number;
            mgmc.transfer(msg.sender, amountToWithdraw);
            userDeposit.choice = _choice;
            userDeposit.timeDepositBlock = block.number;
            userDeposit.sFeeApplied = false;
        }


    }

    function _checkEligibleTerms(address _erc721, uint256 _term) internal view returns (bool) {
        bool isEligible = false;
        //
        if(_erc721 == address(farmerNFT) && (_term == 0 || _term == 1 || _term == 2) ){
            isEligible = true;
        }

        if(_erc721 == address(farmerNFTPlus) && (_term == 3 || _term == 4 || _term == 5)){
            isEligible = true;
        }

        if(_erc721 == address(farmerNFTPlusPlus) && (_term == 6 || _term == 7 || _term == 8) ){
            isEligible = true;
        }

        if(_erc721 == address(mythic) && (_term == 9 || _term == 10 || _term == 11) ){
            isEligible = true;
        }

        return isEligible;

    }

    function collectRewards(uint256 depositIndex)public nonReentrant{
        require(depositIndex < depositLength[msg.sender], "invalid index");
        Deposit storage userDeposit = deposits[msg.sender][depositIndex];
        uint256 lockedPeriod = userDeposit.timeDepositBlock.add(userDeposit.term.lockedPeriod);
        require(block.number <= lockedPeriod, "please proceed to perform choice, locked period over");
        require(userDeposit.status, "withdrawn");
        uint256 amountToWithdraw = _distributeRewards(depositIndex,msg.sender);
        userDeposit.lastWithdrawBlock = block.number;
        mgmc.transfer(msg.sender, amountToWithdraw);

    }


    function _distributeRewards(uint256 depositIndex,address account) public view returns(uint256 amountOut){
        Deposit memory userDeposit = deposits[account][depositIndex];
        uint256 fee = 0;
        if(userDeposit.choice == 0){
            fee = stakeFee.add(unstakeFee);
        }else{
            fee = stakeFee.add(restakeFee);
        }

        if(!userDeposit.sFeeApplied && !gSFee){
            fee = fee.sub(stakeFee);
        }

        if(userDeposit.lastWithdrawBlock < block.number){
            uint256 lockedPeriod = userDeposit.timeDepositBlock.add(userDeposit.term.lockedPeriod);
            if(userDeposit.lastWithdrawBlock <= lockedPeriod){
                uint256 rewardsBlock = block.number.sub(userDeposit.lastWithdrawBlock);
                if(block.number > lockedPeriod){
                    rewardsBlock = lockedPeriod.sub(userDeposit.lastWithdrawBlock);
                }   
                uint256 rewards = userDeposit.term.mgmcPerDay;
                uint256 feeToDeduct = (rewardsBlock.mul(rewards).div(dailyBlock)).mul(fee).div(100);
                amountOut = (rewardsBlock.mul(rewards).div(dailyBlock)).sub(feeToDeduct);
            }
        }
    }

    function adjustDailyBlock(uint256 _newAmount) public onlyOwner{
        dailyBlock = _newAmount;
    }

    function adjustUnstakeFee(uint256 _newFee) public onlyOwner{
        unstakeFee = _newFee;
    }

    function adjustRestakeFee(uint256 _newFee) public onlyOwner{
        restakeFee = _newFee;
    }

    function adjustStakeFee(uint256 _newFee) public onlyOwner{
        stakeFee = _newFee;
    }

    function changeGlobalStakingFee (bool enabled) public onlyOwner{
        gSFee = enabled;
    }

    function addMythicTokenList(uint256[] memory tokenList) public onlyOwner{
        require(tokenList.length > 0, "tokenlist cant be empty");

        for(uint i = 0 ; i < tokenList.length ; i++){
            mythicId[tokenList[i]] = true;
        }
    }

    function removeMythicTokenList(uint256[] memory tokenList) public onlyOwner{
        require(tokenList.length > 0, "tokenlist cant be empty");

        for(uint i = 0 ; i < tokenList.length ; i++){
            mythicId[tokenList[i]] = false;
        }
    }

    function adjustTerms(uint256 _termId, uint256 _lockedPeriod, uint256 _mgmcPerDay) public onlyOwner{
        require(_termId <= termIndex, "invalid term to adjust");
        Term memory term = terms[_termId];
        term.lockedPeriod = _lockedPeriod;
        term.mgmcPerDay = _mgmcPerDay;
        terms[_termId] = term;
    }

    function addTerms(uint256 _lockedPeriod, uint256 _mgmcPerDay) public onlyOwner{
        termIndex = termIndex.add(1);
        terms[termIndex] = Term(_lockedPeriod,_mgmcPerDay);

    }
    
    function safe32(uint256 n) private pure returns (uint32) {
        require(n < 2**32, "UNSAFE_UINT32");
        return uint32(n);
    }

    function emergencyWithdraw() public onlyOwner{
        mgmc.transfer(msg.sender, mgmc.balanceOf(address(this)));
    }


}