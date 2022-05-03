/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: GPL-3.0

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

interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
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
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver { 
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
* TODO: History!
*/
contract MarketMultipleNft is Ownable, ERC1155Receiver {

    using SafeMath for uint256;
    
    string public name; 
    uint256 public feebp;
    address payable public admFeeAddr;
    address public aucExecutor;
    bool public contractPause;

    IERC20 public tokenAddress;

    uint256 public listCount;

    struct SellFixObj {
        IERC1155 nftAddress;
        address seller;
        uint256 nftId;
        uint256 nftTotal;
        uint256 priceOne;
        bool executed;
        uint256 feeMarket;
        uint256 feeArtist;
    }

    struct SellAucObj {
        IERC1155 nftAddress;
        address seller;
        uint256 endTime;
        uint256 nftId;
        uint256 nftTotal;
        uint256 priceAll;
        bool executed;
        uint256 feeMarket;
        uint256 feeArtist;
    }

    mapping(uint256 => uint256) public sells;
    mapping(uint256 => SellFixObj) public sellFixs;
    mapping(uint256 => SellAucObj) public sellAucs;
    mapping(uint256 => mapping(uint256 => uint256)) public sellAucPrices;
    mapping(uint256 => mapping(uint256 => address)) public sellAucAddressRanks;
    mapping(uint256 => uint256) public sellAucStartPrices;
    mapping(uint256 => uint256) public sellAucHighBids;
    mapping(uint256 => address) public sellAucHighAddresses;
    mapping(uint256 => uint256) public sellAucCounts;

    // "artists": {
    //     "0x000-address-01": true,
    //     "0x000-address-02": false       // pada tahapan ini, tidak perlu ditulis
    // },
    mapping(address => bool) public artists;
    
    // listing Nft
    // "artistNfts": {
    //     "0x000-nft-address-01": {      // IERC1155
    //         "1": "0x000-address-01",   // nftId : address
    //         "2": "0x000-address-02"    // nftId : address
    //     },
    // },
    mapping(IERC1155 => mapping(uint256 => address)) public artistNfts; 

    // fee yang didapat artist untuk setiap penjualan
    // "artistFees": {
    //     "0x000-nft-address-01": {      // IERC1155
    //         "1": "1000",   // nftId : int256 (10%)
    //         "2": "1500"    // nftId : int256 (15%)
    //     },
    // },
    mapping(IERC1155 => mapping(uint256 => uint256)) public artistFees; 
    
    mapping(uint256 => int256) public marketFees; // fee yang didapat market untuk setiap penjualan

    // bagian dimana mencatat nft yang pernah listing
    //mapping(IERC1155 => mapping(uint256 => int8)) public nftListings;

    mapping(address => int256) public repSellers;
    mapping(address => int256) public repBuyers;

    event EventSellFix(
        IERC1155 nftAddress,
        uint256 sellId,
        address seller,
        uint256 nftId,
        uint256 nftTotal, 
        uint256 priceOne,
        uint256 feeMarket,
        uint256 feeArtist 
    );

    event EventSellAuc(
        IERC1155 nftAddress,
        uint256 sellId,
        address seller, 
        uint256 endTime,
        uint256 nftId,
        uint256 nftTotal,
        uint256 priceAll,
        uint256 feeMarket,
        uint256 feeArtist  
    );

    event EventSellAucBid(
        uint256 sellId,
        address user, 
        uint256 priceAll
    );

    event EventDeleteSell(
        uint256 indexed sellId
    );

    constructor(
        string memory _name,
        address payable _admFeeAddr,
        address _aucExecutor,
        IERC20 _tokenAddress
    ) 
    public {
        name = _name;
        feebp = 175;           // 1.75% in basis points (parts per 10,000)
        admFeeAddr = _admFeeAddr;
        aucExecutor = _aucExecutor;
        contractPause = false;           
        tokenAddress = _tokenAddress;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    modifier onlyAucExecutor {
        require(msg.sender == aucExecutor);
        _;
    }

    function setFeebp(uint256 _feebp) public onlyOwner {
        // fee ditetapkan tidak boleh > 40%
        // fee artist juga tidak boleh > 40%
        // sehingga kalau ditotal fee terbesar hanya 80%
        
        require(_feebp <= 4000, "Too big");

        feebp = _feebp;    
    }

    function setAdmFeeAddr(address payable _address) public onlyOwner {
        admFeeAddr = _address;        
    }

    function setPause(bool _tf) public onlyOwner {
        contractPause = _tf;
    }

    function setAucExecutor(address _address) public onlyOwner {
        aucExecutor = _address;
    }

    function setTokenAddress(IERC20 _erc20Address) public onlyOwner {
        tokenAddress = _erc20Address;
    }

    function _safeTwTransferFrom(IERC20 token, address sender, address recipient, uint256 amount) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
    
    function _getTwAllowanceValue(IERC20 token, address owner, address spender) private view returns (uint256) {
        return token.allowance(owner, spender);
    }
    
    function _safeNftTransferFrom(address sender, address recipient, IERC1155 nftAddress, uint256 tokenId, uint256 amount) private {
        nftAddress.safeTransferFrom(sender, recipient, tokenId, amount, '');
    }

    /**
    * function yang bertugas untuk mencatatkan available yang mendaftarkan karyanya
    * disini sengaja ada _value karena otomatis bisa cabut hak artist dari sini
    * mencabut hak artist bisa karena beberapa hal
    * - bisa karena private key hilang
    * - bisa karena sebuah masalah
    */
    function setArtist(address _address, bool _value) public onlyOwner {
        require(contractPause == false, "Contract pause");
        artists[_address] = _value;
    }

    /**
    * disini bertujuan untuk mendaftarkan karyanya sebelum ditaro di penjualan
    * disini kita juga bisa tarik fee listing
    * 
    * TODO:
    * fee listing untuk market
    */
    function setNftArtist(IERC1155 _nftAddress, uint256 _nftId, uint256 _fee) public returns (bool) {
        require(contractPause == false, "Contract pause");

        require(_fee <= 4000, "Fee too big");

        // lihat apakah dia memang artist yang terdaftar
        require(artists[msg.sender] == true, "Not artist");

        // cek apakah dia memiliki nft yang dimaksud 
        require(_nftAddress.balanceOf(msg.sender, _nftId) > 0, "You don't have NFT");

        // lihat apakah nftnya sudah listing
        // TODO....
        // DILIHAT APAKAH FUNCTION INI BISA DIPAKAI
        require(artistNfts[_nftAddress][_nftId] == address(0), "NFT listed");
                
        // dicatatkan address artist
        artistNfts[_nftAddress][_nftId] = msg.sender;

        // dicatatkan feenya 
        artistFees[_nftAddress][_nftId] = _fee;

        return true;
    }

    function setSell(
        IERC1155 _nftAddress,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne
    )
    public payable returns (uint256 _listId) {
        require(contractPause == false, "Contract pause");

        // cek apakah sudah listing atau belum 
        require(artistNfts[_nftAddress][_nftId] != address(0), "NFT not listed");

        // cari fee artist 
        uint256 feeArtist = artistFees[_nftAddress][_nftId];

        // jumlah fee tidak boleh besar sama dengan 10000 (10%)
        require(feeArtist + feebp <= 10000, "Fee too big, contact artist or contract owner");

        // cek NFT balance dari seller
        uint256 sellerNftBalance = _nftAddress.balanceOf(msg.sender, _nftId);
        require(sellerNftBalance >= _nftTotal, "Not enough balance");

        // apakah sudah approval?
        require(_nftAddress.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");

        _safeNftTransferFrom(msg.sender, address(this), _nftAddress, _nftId, _nftTotal);

        listCount = listCount + 1;

        sells[listCount] = 1; 

        sellFixs[listCount] = SellFixObj(
            _nftAddress,
            msg.sender,
            _nftId,
            _nftTotal,
            _priceOne,
            false,
            feebp,
            feeArtist
        );

        emit EventSellFix(
            _nftAddress,
            listCount, 
            msg.sender, 
            _nftId, 
            _nftTotal, 
            _priceOne,
            feebp,
            feeArtist
        );

        return listCount;
    }

    function updateSellPrice(uint256 _listId, uint256 _priceOne) public returns (bool) {
        require(contractPause == false, "Contract pause");

        require(msg.sender == sellFixs[_listId].seller, "You can not update");  

        require(sells[_listId] == 1, "Wrong sell type");

        require(sellFixs[_listId].executed == false, "Sell executed");

        sellFixs[_listId].priceOne = _priceOne;

        return true;
    }

    function cancelSell(uint256 _listId) public returns (bool) {
        require(contractPause == false, "Contract pause");

        require(msg.sender == sellFixs[_listId].seller, "You can't cancel");  

        require(sells[_listId] == 1, "Wrong sell type");

        require(sellFixs[_listId].executed == false, "Sell executed");

        sellFixs[_listId].executed = true;
        
        _safeNftTransferFrom(address(this), msg.sender, sellFixs[_listId].nftAddress, sellFixs[_listId].nftId, sellFixs[_listId].nftTotal);

        sellFixs[_listId].nftTotal = 0;

        return true;
    }

    function setSellAuction(
        IERC1155 _nftAddress,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceAll,
        uint256 _endTime
    )
    public returns (uint256 _listId) {
        require(contractPause == false, "Contract pause");

        // cek apakah sudah listing atau belum 
        require(artistNfts[_nftAddress][_nftId] != address(0), "NFT not listed");

        // cari fee artist 
        uint256 feeArtist = artistFees[_nftAddress][_nftId];

        // jumlah fee tidak boleh besar sama dengan 10000 (10%)
        require(feeArtist + feebp <= 10000, "Fee too big, contact artist or contract owner");

        // cek nft apakah dipunyai oleh si seller
        uint256 sellerNftBalance = _nftAddress.balanceOf(msg.sender, _nftId);
        require(sellerNftBalance >= _nftTotal, "You don't have NFT");
        
        // apakah NFT sudah di approve?
        require(_nftAddress.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");
        
        // waktu berakhir auction disini
        require(block.timestamp < _endTime, "End time must be bigger");

        // transfer NFT dari seller ke market address
        _safeNftTransferFrom(msg.sender, address(this), _nftAddress, _nftId, _nftTotal);

        listCount = listCount + 1;

        sells[listCount] = 2; 

        sellAucs[listCount] = SellAucObj(
            _nftAddress,
            msg.sender,
            _endTime,
            _nftId,
            _nftTotal,
            _priceAll,
            false,
            feebp,
            feeArtist
        );

        sellAucHighBids[listCount] = _priceAll;

        sellAucStartPrices[listCount] = _priceAll;

        sellAucHighAddresses[listCount] = msg.sender;

        sellAucCounts[listCount] = 0;

        emit EventSellAuc(
            _nftAddress,
            listCount, 
            msg.sender,
            _endTime,
            _nftId, 
            _nftTotal, 
            _priceAll,
            feebp,
            feeArtist
        );

        return listCount;
    }

    function setBid(uint256 _id, uint256 _priceAll) public payable {
        require(contractPause == false, "Contract pause");

        require(sells[_id] == 2, "Not auction");

        require(sellAucs[_id].endTime > block.timestamp, "Auction end");

        require(_priceAll > sellAucHighBids[_id], "Bid too low");

        require(tokenAddress.allowance(msg.sender, address(this)) >= _priceAll, "Allowance too low" );

        _safeTwTransferFrom(tokenAddress, msg.sender, address(this), _priceAll);
        
        // harga tertinggi bid
        sellAucHighBids[_id] = _priceAll;

        // address bid tertinggi
        sellAucHighAddresses[_id] = msg.sender;

        // jumlah bid pada auction ini
        uint256 newAucCount = sellAucCounts[_id] + 1;
        sellAucCounts[_id] = newAucCount; 

        // harga dan renking bid
        sellAucPrices[_id][newAucCount] = _priceAll;
        sellAucAddressRanks[_id][newAucCount] = msg.sender;
        
        if(newAucCount > 1) {
            uint256 idSebelum = newAucCount - 1;            
            tokenAddress.transfer(sellAucAddressRanks[_id][idSebelum], sellAucPrices[_id][idSebelum]);
        }
    }

    function swap(uint256 _id, uint256 _amount, uint256 _priceOne) public payable {
        require(contractPause == false, "Contract pause");

        // atur variable 
        address seller         = sellFixs[_id].seller;
        address buyer          = msg.sender;
        IERC1155 theNftAddress = sellFixs[_id].nftAddress;
        uint256 theNftId       = sellFixs[_id].nftId;
        address theArtist      = artistNfts[theNftAddress][theNftId];

        require(sellFixs[_id].nftTotal >= _amount, "Number of requests not met");

        require(sellFixs[_id].priceOne == _priceOne, "Sell price has changed");

        // total yang harus dibayarkan oleh buyer
        uint256 total = _amount.mul(sellFixs[_id].priceOne);

        // allowance dari buyer harus lebih besar dan sama dengan total yang akan dibayarkan
        require(tokenAddress.allowance(buyer, address(this)) >= total, "Token allowance too low");

        // token fee for market
        uint256 tokenFeeForAdmin = total.mul(sellFixs[_id].feeMarket).div(10000);

        // token fee for artist 
        uint256 tokenFeeForArtist = total.mul(sellFixs[_id].feeArtist).div(10000);

        // token yang akan dikirim kepada seller
        uint256 tokenForSeller = total.sub(tokenFeeForAdmin).sub(tokenFeeForArtist);
        
        // transfer token kepada seller
        _safeTwTransferFrom(tokenAddress, buyer, seller, tokenForSeller);

        // transfer token kepada market
        _safeTwTransferFrom(tokenAddress, buyer, admFeeAddr, tokenFeeForAdmin);

        // transfer token kepada artist
        _safeTwTransferFrom(tokenAddress, buyer, theArtist, tokenFeeForArtist);

        if(sellFixs[_id].nftTotal == _amount) {
        
            sellFixs[_id].nftTotal = 0;

            sellFixs[_id].executed = true;
            
            emit EventDeleteSell( _id );
        }
        else {
            sellFixs[_id].nftTotal = (sellFixs[_id].nftTotal).sub(_amount);
        }
        
        // transfer NFT kepada si pembeli
        _safeNftTransferFrom(address(this), buyer, theNftAddress, theNftId, _amount);
    }

    function swapAuc(uint256 _id) public payable onlyAucExecutor  {
        require(contractPause == false, "Contract pause");
        
        require(sells[_id] == 2, "Not auction");

        require(sellAucs[_id].endTime < block.timestamp, "Auction is not over yet");

        require(sellAucs[_id].executed == false, "Has been executed");

        // ambil variable
        uint256  theNftTotal   = sellAucs[_id].nftTotal;
        IERC1155 theNftAddress = sellAucs[_id].nftAddress;
        uint256  theNftId      = sellAucs[_id].nftId;
        address  theArtist     = artistNfts[theNftAddress][theNftId];

        if(sellAucCounts[_id] > 0) {

            address seller = sellAucs[_id].seller;

            address buyer = sellAucHighAddresses[_id];

            uint256 priceAllNft = sellAucHighBids[_id];
            
            uint256 tokenFeeForAdmin = priceAllNft.mul(sellAucs[_id].feeMarket).div(10000);

            uint256 tokenFeeForArtist = priceAllNft.mul(sellAucs[_id].feeArtist).div(10000);

            uint256 tokenForSeller = priceAllNft.sub(tokenFeeForAdmin).sub(tokenFeeForArtist);

            _safeNftTransferFrom(address(this), buyer, theNftAddress, theNftId, theNftTotal);

            tokenAddress.transfer(seller, tokenForSeller);
            tokenAddress.transfer(admFeeAddr, tokenFeeForAdmin);
            tokenAddress.transfer(theArtist, tokenFeeForArtist);

        }
        else if (sellAucCounts[_id] == 0) {
            _safeNftTransferFrom(address(this), sellAucs[_id].seller, theNftAddress, theNftId, theNftTotal);       
        }

        sellAucs[_id].executed = true;
    }

    function emergencyTokenTransfer(address _address, uint256 _amount) public onlyOwner  {
        tokenAddress.transfer(_address, _amount);
    }

    function emergencyNftTransfer(address _address, IERC1155 _nftAddress, uint256 _nftId, uint256 _nftTotal) public onlyOwner  {
        _safeNftTransferFrom(address(this), _address, _nftAddress, _nftId, _nftTotal);       
    }
}