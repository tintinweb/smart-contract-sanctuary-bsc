/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.12;

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

    function getErc1155Creators(uint256 id) external view returns (address);
    function getErc1155Amounts(uint256 id) external view returns (uint256);
}

interface ITopBridgeMarket {
    function setMkFirst(
        bool _charity,
        IERC1155 _erc1155Address, 
        uint256 _nftId, 
        address payable _introducer, 
        uint256 _sellType,
        uint256 _priceOne,
        uint256 _endTime
    ) external returns (uint256 returnSellId);

    function setSell(
        IERC1155 _erc1155Address,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne
    )
    external returns (uint256 returnSellId);

    function updateSellPrice(uint256 _listId, uint256 _priceOne) external returns (bool);

    function cancelSell(uint256 _sellId) external returns (bool);

    function setSellAuction(
        IERC1155 _erc1155Address,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne,
        uint256 _endTime
    )
    external returns (uint256);

    function setBid(uint256 _id) external payable;

    function swap(uint256 _sellId, uint256 _jumlahNft, uint256 _priceOne) external payable;

    function setBuy(
        IERC1155 _erc1155Address, 
        uint256 _nftId,
        uint256 _qty,
        uint256 _priceOne
    ) external payable returns (uint256);
    
    function sellExec(uint256 _buyId, uint256 _qty) external returns (uint256);
}

/// @title TopBridgeMarket
/// @author TopBridge Team >< Ntz
contract TopBridgeMarket is Ownable, ERC1155Receiver, ITopBridgeMarket {

    using SafeMath for uint256;
    
    string  public name; 
    address payable public admFeeAddr;
    address payable public comBase;     // commision base 
    address public aucExecutor;
    bool    public contractPause;
    uint256    public historyCount;

    struct SellFixObj {
        uint256 mkStId;
        address seller;
        uint256 nftTotal;
        uint256 priceOne;
        bool executed;
    }

    struct SellFirstFeeObj {
        uint256 tb;
        uint256 creator;
        uint256 tb_com;
        uint256 introducer;
    }

    struct SellFeeObj {
        uint256 tb;
        uint256 seller;
        uint256 creator;
        uint256 tb_com;
        uint256 introducer;
    }

    struct SellAucObj {
        uint256 mkStId;
        address seller;
        uint256 endTime;
        uint256 nftTotal;
        uint256 priceAll;
        bool executed;   
    }

    struct BuyObj {
        address buyer;
        IERC1155 ierc1155Address;
        uint256 nftId;
        uint256 nftAmount;
        uint256 priceOne;
        bool executed;
    }

    struct BuyFeeObj {
        uint256 tb;
        uint256 seller;
        uint256 creator;
        uint256 tb_com;
        uint256 introducer;
    }

    // avoiding stack too deep
    struct AddrForTransfer {
        address seller;
        address creator;
        address introducer;
    }

    struct StdCoinsSpread {
        uint256 coinForAdmin;
        uint256 coinForSeller;
        uint256 coinForCreator;
        uint256 coinForTbCom;
        uint256 coinForIntroducer;
    }

    struct HistoryObj {
        bool buySellTf; // buy: true, sell: false
        uint256 buyOrSellId;
        address from;
        address to;      
        uint256 price;
        uint256 qty;
    }

    // -------- market start group (listing) --------
    uint256 public mkStCount;
    mapping(uint256 => address)    public mkStCreators;    // st_id: creator_address
    mapping(uint256 => IERC1155)   public mkSt1155s;       // st_id: erc1155_address
    mapping(uint256 => uint256)    public mkSt1155Ids;     // st_id: nft_id
    mapping(uint256 => uint256)    public mkSt1155Ams;     // st_id: nft_sell_amount
    mapping(uint256 => address)    public mkStIntros;      // st_id: introducer_address
    mapping(uint256 => uint256)    public mkStPrices;      // st_id: nft_price
    mapping(uint256 => bool)       public mkStCharities;   // st_id: true_or_false
    
    /**
    * https://gist.github.com/ageyev/779797061490f5be64fb02e978feb6ac
    * The user must input the contract address and id
    * Ex;
    *   contract address = 0x4f820afcb603fa86449ddc20f293a2fb54b5c372
    *   NFT ID = 9
    *   So, the input string must be; 0x4f820afcb603fa86449ddc20f293a2fb54b5c372 - 9 (pay atention to the number 9 in the back)
    *   The keccak256 of the string is; 504c9f44309ebae7dca2419ed82014242a0045bf6d8fb8d905155b956a191491
    */
    mapping(bytes32 => uint256)  public mkSt1155AndIds;  // bytes32_of_erc1155address_and_erc1155id: st_id 
    // -------- market start group (listing) --------

    uint256 public sellCount;
    mapping(uint256 => bool)    public sellFirsts;      // sell_id: true_false
    mapping(uint256 => uint256) public sellTypes;       // sell_id: sell_type
    mapping(uint256 => SellFirstFeeObj) public sellFirstFees;        // sell_id: obj
    mapping(uint256 => SellFeeObj) public sellFees;     // sell_id: obj
    mapping(uint256 => SellFixObj) public sellFixs;     // sell_id: obj
    mapping(uint256 => SellAucObj) public sellAucs;     // sell_id: obj
    mapping(uint256 => mapping(uint256 => uint256)) public sellAucPrices;        // sell_id: { id_internal_auction: bid_price  }
    mapping(uint256 => mapping(uint256 => address)) public sellAucAddressRanks;  // sell_id: { id_internal_auction: bidder_address  }
    mapping(uint256 => uint256) public sellAucStartPrices;    // sell_id: auction_start_price
    mapping(uint256 => uint256) public sellAucHighBids;       // sell_id: higher_bid_price
    mapping(uint256 => address) public sellAucHighAddresses;  // sell_id: higher_bidder_address
    mapping(uint256 => uint256) public sellAucCounts;         // sell_id: number_of_bid

    // -------- swap histories --------
    mapping(uint256 => HistoryObj) public histories;   // history_id: obj
    // -------- swap histories --------

    uint256 public buyCount;
    mapping(uint256 => BuyObj) public buys;       // buy_id: obj
    mapping(uint256 => BuyFeeObj) public buyFees; // buy_id: obj

    // "creators": {
    //     "0x000-address-01": true,
    //     "0x000-address-02": false       // by default all of the address is false
    // },
    mapping(address => bool) public creators;
    
    event EventSellFix(
        uint256 sellId,
        address seller,
        uint256 nftTotal, 
        uint256 priceOne
    );

    event EventSellAuc(
        uint256 sellId,
        address seller, 
        uint256 endTime,
        uint256 nftTotal,
        uint256 priceAll  
    );

    constructor(
        string memory _name,
        address payable _admFeeAddr,
        address payable _comBase,
        address _aucExecutor
    ) 
    public {
        name = _name;
        admFeeAddr = _admFeeAddr;
        comBase    = _comBase;               
        aucExecutor = _aucExecutor;
        contractPause = false;           
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

    function setAdmFeeAddr(address payable _address) public onlyOwner {
        admFeeAddr = _address;        
    }

    function setComBase(address payable _address) public onlyOwner {
        comBase = _address;        
    }

    function setPause(bool _tf) public onlyOwner {
        contractPause = _tf;
    }

    function setAucExecutor(address _address) public onlyOwner {
        aucExecutor = _address;
    }
    
    function _swapSell(
        bool isThisFirstSell, 
        uint256 _sellId,
        uint256 totalCoin,
        AddrForTransfer memory addrForTransfer
    ) 
    private returns (bool) {
        if(isThisFirstSell == true) {

            // coin for market (TB)
            uint256 coinForAdmin = totalCoin.mul(sellFirstFees[_sellId].tb).div(10000);

            // coin for creator 
            uint256 coinForCreator = totalCoin.mul(sellFirstFees[_sellId].creator).div(10000); 

            // coin for commision
            uint256 coinForTbCom = totalCoin.mul(sellFirstFees[_sellId].tb_com).div(10000); 
            
            // coin for introducer
            // disini kita gunakan substraction supaya jumlah semua match
            uint256 coinForIntroducer = totalCoin
                                            .sub(coinForAdmin)
                                            .sub(coinForCreator)
                                            .sub(coinForTbCom); 
            
            // --- transfer section ---
            // transfer coin to TB
            payable(admFeeAddr).transfer(coinForAdmin);

            // coin transfer to creator
            payable(addrForTransfer.creator).transfer(coinForCreator);

            // coin transfer to ComBase
            payable(comBase).transfer(coinForTbCom);

            // coin transfer to introducer 
            payable(addrForTransfer.introducer).transfer(coinForIntroducer);
            // --- transfer section ---

            return true;

        }
        else {

            // coin for market (TB)
            uint256 coinForAdmin = totalCoin.mul(sellFees[_sellId].tb).div(10000);

            // coin for seller
            uint256 coinForSeller = totalCoin.mul(sellFees[_sellId].seller).div(10000);

            // coin for creator 
            uint256 coinForCreator = totalCoin.mul(sellFees[_sellId].creator).div(10000); 

            // coin for commision
            uint256 coinForTbCom = totalCoin.mul(sellFees[_sellId].tb_com).div(10000); 
            
            // coin for introducer
            // here we use subtraction so that the sum of all matches
            uint256 coinForIntroducer = totalCoin
                                            .sub(coinForAdmin)
                                            .sub(coinForSeller)
                                            .sub(coinForCreator)
                                            .sub(coinForTbCom); 
            
            // --- transfer section ---
            // coin transfer to TB
            payable(admFeeAddr).transfer(coinForAdmin);

            // coin transfer to seller
            payable(addrForTransfer.seller).transfer(coinForSeller);

            // coin transfer to creator
            payable(addrForTransfer.creator).transfer(coinForCreator);

            // coin transfer to ComBase
            payable(comBase).transfer(coinForTbCom);

            // coin transfer to introducer 
            payable(addrForTransfer.introducer).transfer(coinForIntroducer);
            // --- transfer section ---

            return true;
        }
    }

    function _setSellCore(
        bool _charity,
        uint256 _mkStId,
        uint256 _nftTotal,
        uint256 _priceOne,
        bool _firstSellTrueFalse
    )
    private returns (uint256) {
        require(contractPause == false, "Contract pause");

        IERC1155 erc1155Address = mkSt1155s[_mkStId];
        uint256 nftId = mkSt1155Ids[_mkStId];

        // Checking seller the NFT balance
        uint256 sellerNftBalance = erc1155Address.balanceOf(msg.sender, nftId);
        require(sellerNftBalance >= _nftTotal, "Not enough balance");

        // must be approved
        require(erc1155Address.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");

        // Taking the NFT from user and store in this SC
        erc1155Address.safeTransferFrom(msg.sender, address(this), nftId, _nftTotal, '');

        // The id for map
        sellCount = sellCount + 1;

        uint256 localSellCount = sellCount; // avoid frequent reading from storage

        // storing in the blockchain; Is this the first sale or no? 
        sellFirsts[localSellCount] = _firstSellTrueFalse;
        
        // distribution of transfers and fees (in percentage)
        if(_firstSellTrueFalse == true) {    // first sell goes here

            // non-charity
            if(_charity == false) {
                sellFirstFees[localSellCount] = SellFirstFeeObj(
                    250, 
                    8000,
                    1650,
                    100
                );
            }
            // charity
            else {
                sellFirstFees[localSellCount] = SellFirstFeeObj(
                    250, 
                    975,
                    775,
                    8000
                );
            }
        }
        else {    // other than first sell goes here
            // non-charity
            if(_charity == false) {
                sellFees[localSellCount] = SellFeeObj(
                    250, 
                    8775,
                    780,
                    185,
                    10
                );
            }
            // charity
            else {
                sellFees[localSellCount] = SellFeeObj(
                    250, 
                    8775,
                    98,
                    98,
                    779
                );
            }
        }

        // Storing the type of sale (fixed or auction)
        // but in this function, it's always fixed
        sellTypes[localSellCount] = 1; 

        sellFixs[localSellCount] = SellFixObj(
            _mkStId,
            msg.sender,
            _nftTotal,
            _priceOne,
            false
        );
        
        emit EventSellFix(
            localSellCount, 
            msg.sender, 
            _nftTotal, 
            _priceOne
        );

        return localSellCount;
    }

    function _setSellAuctionCore(
        bool _charity,
        uint256 _mkStId,
        uint256 _nftTotal,
        uint256 _priceAll,
        uint256 _endTime,
        bool _firstSellTrueFalse
    )
    private returns (uint256) {
        require(contractPause == false, "Contract pause");

        IERC1155 erc1155Address = mkSt1155s[_mkStId];
        uint256 nftId = mkSt1155Ids[_mkStId];

        // Checking seller NFT balance
        uint256 sellerNftBalance = erc1155Address.balanceOf(msg.sender, nftId);
        require(sellerNftBalance >= _nftTotal, "Not enough balance");

        // Must be approved
        require(erc1155Address.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");
        
        // Checking auction end time 
        require(block.timestamp < _endTime, "End time must be bigger");

        // Taking the NFT from user and store in this SC
        erc1155Address.safeTransferFrom(msg.sender, address(this), nftId, _nftTotal, '');

        // New ID for the map
        sellCount = sellCount + 1;

        uint256 localSellCount = sellCount; // avoid frequent reading from storage

        // storing in the blockchain; Is this the first sale or no? 
        sellFirsts[localSellCount] = _firstSellTrueFalse;

        // distribution of transfers and fees (in percentage)
        if(_firstSellTrueFalse == true) {

            // non-charity
            if(_charity == false) {
                sellFirstFees[localSellCount] = SellFirstFeeObj(
                    250, 
                    8000,
                    1650,
                    100
                );
            }
            // charity
            else {
                sellFirstFees[localSellCount] = SellFirstFeeObj(
                    250, 
                    975,
                    775,
                    8000
                );
            }
        }
        else {
            // non-charity
            if(_charity == false) {
                sellFees[localSellCount] = SellFeeObj(
                    250, 
                    8775,
                    780,
                    185,
                    10
                );
            }
            // charity
            else {
                sellFees[localSellCount] = SellFeeObj(
                    250, 
                    8775,
                    98,
                    98,
                    779
                );
            }
        }

        // Storing the type of sale (fixed or auction)
        // but in this function, it's always auction
        sellTypes[localSellCount] = 2; 

        sellAucs[localSellCount] = SellAucObj(
            _mkStId,
            msg.sender,
            _endTime,
            _nftTotal,
            _priceAll,
            false
        );

        sellAucHighBids[localSellCount] = _priceAll;

        sellAucStartPrices[localSellCount] = _priceAll;

        sellAucHighAddresses[localSellCount] = msg.sender;

        sellAucCounts[localSellCount] = 0;

        emit EventSellAuc(
            localSellCount,
            msg.sender,
            _endTime,
            _nftTotal, 
            _priceAll
        );

        return localSellCount;
    }

    /**
    * Marking and address as a creator or no
    * There is intentionally a _value here because it can automatically revoke the creator's rights from here.
    * Revoking the rights of the creator could be due to several things
    * - could be because the private key is lost
    * - could be due to a problem
    */
    function setCreator(address _address, bool _value) public onlyOwner {
        require(contractPause == false, "Contract pause");
        creators[_address] = _value;
    }

    
    /**
    * In this function we want only the ERC1155 which has implement the function `getErc1155Creators` 
    * so we can track the creator of the NFT
    *
    * This code also creates a mechanism for listing, please see the code `erc1155IdKey`
    *
    *Params:
    * `charity` => true or false. In this section by default is false and is considered to be pure business
    * `_introducer` => For the charity type, introducer is the address of the charity recipient. For the pure business, this is the introducer address
    */
    function setMkFirst(
        bool _charity,
        IERC1155 _erc1155Address, 
        uint256 _nftId, 
        address payable _introducer, 
        uint256 _sellType,
        uint256 _priceOne,
        uint256 _endTime
    ) public returns (uint256 returnSellId) {
        require(contractPause == false, "Contract pause");

        // see in the market contract, if this listed as a creator.
        require(creators[msg.sender] == true, "Not creator");

        // Lookup in the ERC1155 contract; "the sender must be creator"
        require(_erc1155Address.getErc1155Creators(_nftId) == msg.sender, "You are not creator of the NFT");

        // The NFT to be sold must have never been transferred anywhere. (original)
        require(_erc1155Address.balanceOf(msg.sender, _nftId) == _erc1155Address.getErc1155Amounts(_nftId), "NFT amount does not match");
        
        // Creating key for erc1155_address and id
        // doc https://medium.com/0xcode/hashing-functions-in-solidity-using-keccak256-70779ea55bb0
        bytes32 erc1155IdKey  = keccak256(abi.encode(_erc1155Address, "-" , _nftId));

        // if the key not found or the key is 0
        require(mkSt1155AndIds[erc1155IdKey] == 0, "NFT listed");

        // Must be approved
        require(_erc1155Address.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");

        // ----- start market (listing) -----
        mkStCount = mkStCount + 1;

        uint256 localMkStCount = mkStCount; // avoid frequent reading from storage

        mkStCreators[localMkStCount]    = msg.sender;
        mkSt1155s[localMkStCount]       = _erc1155Address;
        mkSt1155Ids[localMkStCount]     = _nftId;
        mkSt1155Ams[localMkStCount]     = _erc1155Address.getErc1155Amounts(_nftId);
        mkStIntros[localMkStCount]      = _introducer;
        mkStCharities[localMkStCount]   = _charity;
        
        mkSt1155AndIds[erc1155IdKey] = localMkStCount;
        // ----- start market (listing) -----

        if (_sellType == 1) {

            mkStPrices[localMkStCount] = _priceOne; 

            uint256 numberSell = _setSellCore(
                _charity,
                localMkStCount,
                _erc1155Address.getErc1155Amounts(_nftId),
                _priceOne,
                true
            );

            return numberSell;
        }
        else if (_sellType == 2) {

            uint256 nftAmount = _erc1155Address.getErc1155Amounts(_nftId);
            uint256 priceAll = _priceOne * nftAmount;

            mkStPrices[localMkStCount] = priceAll; 

            uint256 numberSell = _setSellAuctionCore(
                _charity,
                localMkStCount,
                nftAmount,
                priceAll,
                _endTime,
                true
            );

            return numberSell;
        }
    }

    /**
    * We can identify this is charity or not is from the first sell (listing)
    * If the first sell for charity, the the next sell must be for charity 
    */
    function setSell(
        IERC1155 _erc1155Address,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne
    )
    public returns (uint256 returnSellId) {
        require(contractPause == false, "Contract pause");

        // Creating key; `erc1155_address - id`
        bytes32 erc1155IdKey  = keccak256(abi.encode(_erc1155Address, "-" , _nftId));

        require(mkSt1155AndIds[erc1155IdKey] != 0, "Not listed");

        // market start id (listing)
        uint256 marketStartId =  mkSt1155AndIds[erc1155IdKey]; 

        // Identify whether this type charity or pure business
        bool _charity = mkStCharities[marketStartId];

        // Sell
        uint256 sellNumber = _setSellCore(
            _charity,
            marketStartId,  
            _nftTotal,
            _priceOne,
            false
        );

        return sellNumber;
    }

    function updateSellPrice(uint256 _listId, uint256 _priceOne) public returns (bool) {
        require(contractPause == false, "Contract pause");

        require(msg.sender == sellFixs[_listId].seller, "You can not update");  

        require(sellTypes[_listId] == 1, "Wrong sell type");

        require(sellFixs[_listId].executed == false, "Sell executed");

        sellFixs[_listId].priceOne = _priceOne;

        return true;
    }

    function cancelSell(uint256 _sellId) public returns (bool) {
        require(contractPause == false, "Contract pause");

        // Cannot cancel other user sell
        require(msg.sender == sellFixs[_sellId].seller, "You can't cancel");

        // Cannot cancel first sell (listing) 
        require(sellFirsts[_sellId] == false, "Cannot cancel first sell");

        // Cancel can only for fixed price. (auction type not allowed to cancel)
        require(sellTypes[_sellId] == 1, "Wrong sell type");

        // Cannot cancel executed sell
        require(sellFixs[_sellId].executed == false, "Has been executed");

        // Store as executed
        sellFixs[_sellId].executed = true;
        
        // ----- Transfering the NFT to the seller -----
        // look for the market start id
        uint256 thisMkStId = sellFixs[_sellId].mkStId;
        IERC1155 thisErc1155Address = mkSt1155s[thisMkStId];
        uint256 thisErc1155Id = mkSt1155Ids[thisMkStId];
        thisErc1155Address.safeTransferFrom(address(this), msg.sender, thisErc1155Id, sellFixs[_sellId].nftTotal, '');
        // ----- Transferint the NFT to the seller -----
        
        // Set to 0 because it has been transferred
        sellFixs[_sellId].nftTotal = 0;

        return true;
    }

    function setSellAuction(
        IERC1155 _erc1155Address,
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne,
        uint256 _endTime
    )
    public returns (uint256) {
        require(contractPause == false, "Contract pause");

        bytes32 erc1155IdKey  = keccak256(abi.encode(_erc1155Address, "-" , _nftId));

        require(mkSt1155AndIds[erc1155IdKey] != 0, "Not listed");

        // look for market start id based on erc1155 address and nft id
        uint256 marketStartId =  mkSt1155AndIds[erc1155IdKey]; 

        // we can find out whether the type is charity or not
        bool _charity = mkStCharities[marketStartId];

        // sell
        uint256 sellNumber = _setSellAuctionCore(
            _charity,
            mkSt1155AndIds[erc1155IdKey], 
            _nftTotal,
            _priceOne,
            _endTime,
            false
        );

        return sellNumber;
    }

    function setBid(uint256 _id) public payable {
        require(contractPause == false, "Contract pause");

        require(sellTypes[_id] == 2, "Not auction");

        require(sellAucs[_id].executed == false, "Has been executed");

        require(sellAucs[_id].endTime > block.timestamp, "Auction end");

        require(msg.value > sellAucHighBids[_id], "Bid too low");

        // highest bid price
        sellAucHighBids[_id] = msg.value;

        // highest bider address
        sellAucHighAddresses[_id] = msg.sender;

        // number of bid from this auction
        uint256 newAucCount = sellAucCounts[_id] + 1;
        sellAucCounts[_id] = newAucCount; 

        // bid price and bid rank
        sellAucPrices[_id][newAucCount] = msg.value;
        sellAucAddressRanks[_id][newAucCount] = msg.sender;
        
        if(newAucCount > 1) {
            uint256 idSebelum = newAucCount - 1;

            // Send the coin to the last bidder because there is new bidder with higher price in the blockchain
            payable(sellAucAddressRanks[_id][idSebelum]).transfer(sellAucPrices[_id][idSebelum]);
        }
    }

    function swap(uint256 _sellId, uint256 _jumlahNft, uint256 _priceOne) public payable {
        require(contractPause == false, "Contract pause");

        require(sellFixs[_sellId].executed == false, "Has been executed");

        uint256 mkStId = sellFixs[_sellId].mkStId;

        // from market start id we can get `erc1155 contract address` and `erc1155 id`
        IERC1155 theNftAddress  = mkSt1155s[mkStId];
        uint256 theNftId        = mkSt1155Ids[mkStId];
        address addrCreator     = mkStCreators[mkStId];
        address addrSeller      = sellFixs[_sellId].seller;  // In the first sell, the creator must be the same with the seller
        address addrIntroducer  = mkStIntros[mkStId];

        uint256 nftTotalInStorage = sellFixs[_sellId].nftTotal;
        require(nftTotalInStorage >= _jumlahNft, "Number of requests not met");

        // In this market, the seller can change the price.
        // To prevent the price change, the buyer must input the price that he want
        require(sellFixs[_sellId].priceOne == _priceOne, "Sell price has changed");

        // the total to be paid by the buyer
        uint256 totalCoin = _jumlahNft.mul(sellFixs[_sellId].priceOne);

        // the total to be paid by the buyer must be the same as the total coin sent by the buyer
        require(msg.value == totalCoin, "Wrong total send");

        AddrForTransfer memory addrForTransfer = AddrForTransfer(addrSeller, addrCreator, addrIntroducer);

        // Get the distribution fee and transfer for sell first (listing)
        if(sellFirsts[_sellId] == true) {    
            _swapSell(true, _sellId, totalCoin, addrForTransfer);
        }
        // If not first sell
        else {
            _swapSell(false, _sellId, totalCoin, addrForTransfer);
        }

        // ----- store in the history -----
        historyCount = historyCount + 1;
        histories[historyCount] = HistoryObj(
            false,
            _sellId,
            addrSeller,
            msg.sender,
            _priceOne,
            _jumlahNft
        );
        // ----- store in the history -----

        if(nftTotalInStorage == _jumlahNft) {
            
            sellFixs[_sellId].nftTotal = 0;

            sellFixs[_sellId].executed = true;
        }
        else {
            sellFixs[_sellId].nftTotal = (nftTotalInStorage).sub(_jumlahNft);
        }
        
        // NFT transfer to the buyer
        theNftAddress.safeTransferFrom(address(this), msg.sender, theNftId, _jumlahNft, '');
    }

    function swapAuc(uint256 _sellId) public payable onlyAucExecutor  {
        require(contractPause == false, "Contract pause");
        
        require(sellTypes[_sellId] == 2, "Not auction");

        require(sellAucs[_sellId].endTime < block.timestamp, "Auction is not over yet");

        require(sellAucs[_sellId].executed == false, "Has been executed");

        // market starting ID (listing data)
        uint256 mkStId = sellAucs[_sellId].mkStId;

        uint256  theNftTotal    = sellAucs[_sellId].nftTotal;
        IERC1155 theNftAddress  = mkSt1155s[mkStId];
        uint256  theNftId       = mkSt1155Ids[mkStId];
        address  addrCreator    = mkStCreators[mkStId];
        address  addrSeller     = sellAucs[_sellId].seller;    // pada penjualan pertama, address creator pasti sama dengan seller
        address  addrIntroducer = mkStIntros[mkStId];

        // if someone bid
        if(sellAucCounts[_sellId] > 0) {

            // the buyer is the person who puts the highest bid
            address buyer = sellAucHighAddresses[_sellId];

            // highest price
            uint256 totalCoin = sellAucHighBids[_sellId];

            AddrForTransfer memory addrForTransfer = AddrForTransfer(addrSeller, addrCreator, addrIntroducer);

            // first sell
            if(sellFirsts[_sellId] == true) {
                _swapSell(true, _sellId, totalCoin, addrForTransfer);
            }
            // not first sell
            else {
                _swapSell(false, _sellId, totalCoin, addrForTransfer);
            }

            // ----- history -----
            historyCount = historyCount + 1;
            histories[historyCount] = HistoryObj(
                false,
                _sellId,
                addrSeller,
                buyer,
                totalCoin.div(theNftTotal),
                theNftTotal
            );
            // ----- history -----
            
            // NFT Transfer
            theNftAddress.safeTransferFrom(address(this), buyer, theNftId, theNftTotal, '');

        }
        // if no one bids, then the NFT is returned to the seller
        else if (sellAucCounts[_sellId] == 0) {
            theNftAddress.safeTransferFrom(address(this), sellAucs[_sellId].seller, theNftId, theNftTotal, '');
        }

        sellAucs[_sellId].executed = true;
    }

    function setBuy(
        IERC1155 _erc1155Address, 
        uint256 _nftId,
        uint256 _qty,
        uint256 _priceOne
    ) public payable returns (uint256) {
        require(contractPause == false, "Contract pause");
        
        buyCount = buyCount + 1;

        // transferred amount must be priceOne*qty
        uint256 totalCoin = _priceOne.mul(_qty);
        require(msg.value == totalCoin, "Coin does not match");

        bytes32 erc1155IdKey  = keccak256(abi.encode(_erc1155Address, "-" , _nftId));
        require(mkSt1155AndIds[erc1155IdKey] != 0, "NFT not listed");

        buys[buyCount] = BuyObj(
            msg.sender,
            _erc1155Address,
            _nftId,
            _qty,
            _priceOne,
            false
        );

        uint256 marketStartId =  mkSt1155AndIds[erc1155IdKey]; 

        bool _charity = mkStCharities[marketStartId];

        // --- transfer components and fees here will be different if NFT is charity and not ---
        if(_charity == true) {
            buyFees[buyCount] = BuyFeeObj(
                250,       // tb                  
                8775,      // seller
                98,        // creator
                98,        // tb_com
                779        // penerima_charity
            );
        }
        else {
            buyFees[buyCount] = BuyFeeObj(
                250,       // tb                  
                8775,      // seller
                780,       // creator
                185,       // tb_com
                10         // introducer
            );
        }
        // --- transfer components and fees here will be different if NFT is charity and not ---

        return buyCount;
    }

    function cancelBuy(uint256 _buyId) public returns (bool) {
        require(contractPause == false, "Contract pause");

        BuyObj memory buyObj = buys[_buyId];

        require(buyObj.executed == false, "Executed");

        require(msg.sender == buyObj.buyer, "Not your data");
        
        uint256 coinAmount = (buyObj.nftAmount).mul(buyObj.priceOne);

        buys[_buyId].nftAmount = 0;
        buys[_buyId].executed = true;

        // transfer back to the buyer
        payable(buyObj.buyer).transfer(coinAmount);

        return true;
    }
    
    /**
    * Just get rid of stack too deep
    */
    function _calcCoin(
        uint256 _buyId,
        uint256 _qty
    ) private view returns (StdCoinsSpread memory stdCoinsSpread) {
        uint256 totalCoin = (buys[_buyId].priceOne).mul(_qty);

        // coin for market (TB)
        uint256 coinForAdmin = totalCoin.mul(buyFees[_buyId].tb).div(10000);

        // coin for seller
        uint256 coinForSeller = totalCoin.mul(buyFees[_buyId].seller).div(10000);

        // coin for creator 
        uint256 coinForCreator = totalCoin.mul(buyFees[_buyId].creator).div(10000); 

        // coin for commision
        uint256 coinForTbCom = totalCoin.mul(buyFees[_buyId].tb_com).div(10000); 

        // coin for introducer
        // Using substraction to make all of the amount exact match
        uint256 coinForIntroducer = totalCoin
                                        .sub(coinForAdmin)
                                        .sub(coinForSeller)
                                        .sub(coinForCreator)
                                        .sub(coinForTbCom); 

        return StdCoinsSpread(coinForAdmin, coinForSeller, coinForCreator, coinForTbCom, coinForIntroducer);
    }

    /**
    * This function is used to execute existing buys on the blockchain
    */
    function sellExec(uint256 _buyId, uint256 _qty) public returns (uint256) {
        require(contractPause == false, "Contract pause");

        // NOTE: LOCAL VARIABLE
        BuyObj memory buyObj = buys[_buyId];

        // take the first sell key data to find out who is the introducer, who is the creator
        bytes32 erc1155IdKey  = keccak256(abi.encode(buyObj.ierc1155Address, "-" , buyObj.nftId));
        uint256 mkStId = mkSt1155AndIds[erc1155IdKey];
 
        require(buyObj.executed == false, "Executed");

        uint256 sellerQtyTotal = (buyObj.ierc1155Address).balanceOf(msg.sender, buyObj.nftId);

        require(sellerQtyTotal >= _qty, "You put in more than yours");

        require(_qty <= buyObj.nftAmount, "Qty greater than available");

        // reduce the existing qty on the blockchain
        // NOTE: CHANGE STORAGE HERE
        buys[_buyId].nftAmount = (buyObj.nftAmount).sub(_qty);

        // --------
        StdCoinsSpread memory coinSpread = _calcCoin(_buyId, _qty);
        
        // transfer coin TB
        payable(admFeeAddr).transfer(coinSpread.coinForAdmin);

        // transfer coin seller
        payable(msg.sender).transfer(coinSpread.coinForSeller);

        // transfer coin creator
        payable(mkStCreators[mkStId]).transfer(coinSpread.coinForCreator);

        // transfer coin comBase 
        payable(comBase).transfer(coinSpread.coinForTbCom);

        // transfer coin introducer 
        payable(mkStIntros[mkStId]).transfer(coinSpread.coinForIntroducer);
        // ---------

        // ----- history -----
        historyCount = historyCount + 1;
        histories[historyCount] = HistoryObj(
            true,
            _buyId,
            msg.sender,
            buyObj.buyer,
            buyObj.priceOne,
            _qty
        );
        // ----- history -----

        // Transfer NFT to buyer
        (buys[_buyId].ierc1155Address).safeTransferFrom(msg.sender, buyObj.buyer, buyObj.nftId, _qty, '');

        // executed state
        // NOTE: comparison here must use the one from storage
        if(buys[_buyId].nftAmount == 0) {
            buys[_buyId].executed = true;
        }

        return 1;

    }

    function emergencyTokenTransfer(address payable _address, uint256 _amount) public payable onlyOwner  {
        _address.transfer(_amount);
    }

    function emergencyNftTransfer(address _address, IERC1155 _nftAddress, uint256 _nftId, uint256 _nftTotal) public onlyOwner  {
        _nftAddress.safeTransferFrom(address(this), _address, _nftId, _nftTotal, '');  
    }
}