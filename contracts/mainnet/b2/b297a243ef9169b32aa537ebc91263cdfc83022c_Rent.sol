/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT
// File: contracts/interfaces/IRent.sol


pragma solidity ^0.8.12;
interface IRent {
     struct RentalTokens {
        address mainOwner;
        address rentOwner;
        uint256 tokenId;
        uint256 price;
        uint256 tenancy;
        uint256 startTime;
        string asset_name;
    }
    struct Assets {
        string asset_name;
        uint256 supply;
    }
    
    function assetsCount() external view returns(uint256);
    function getRentAssets(uint256 assetId) external view returns(RentalTokens memory);

    event AddRoRent(address indexed owner, uint256 indexed tokenId,uint256 price);
    //Lessor=> the man who add to rent
    //Lessee=> the man who get the rent
    event LeaseAsset(uint256 indexed tokenId,uint256 assetId,address Lessor,  address Lessee,  uint256 price);
    event ClaimAssetRent(uint256 indexed tokenId, address owner );

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
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

// File: contracts/interfaces/IMetaverserItems.sol


pragma solidity ^0.8.12;


interface IMetaverserItems is IERC1155 {
    struct Assets {
        string asset_name;
        uint256 supply;
    }

    function mint(address _to, uint256 _amount, string memory _name) external;

    function getTokenName(uint256 _tokenId) external view returns(string memory);
    function getTokensByOwner(address _user) external view returns(Assets[] memory);
    function getTokenCount() external view returns(uint256);
    function getHolderAddressByIndex(uint256 _index) external view returns(address);
    function getExistAddress(address _holder) external view returns(bool);
    function usersCounter() external view returns(uint256);
}
// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



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

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
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
}

// File: contracts/Rent.sol


pragma solidity ^0.8.12;





contract Rent is  IRent,Ownable,ERC1155Holder  {
    IMetaverserItems public itemsContract;
    IERC20 public MTVTToken;
    uint256 private daoPercent = 4;
    uint256 private minerPercent = 1;
    //Count assets on market
    uint256 public assetsCount;
    //Count Users that have rented
    uint256 public usersCounter;

    address public daoAddr;
    address public minerAddr;

    bool public isPaused;

    mapping(uint256 => RentalTokens) private rentAssets;
    mapping(address => uint256[]) private lessorAssets;
    mapping(address => uint256[]) private lesseeAssets;
    mapping(uint256 => address) private holdersAddress;
    mapping(address=>bool)   private holders;
    mapping(address => bool) private whitelist;

    modifier openMarket() {
        require(!isPaused , "_Market_Is_paused");
        _;
    }
    
    constructor(IERC20 _erc20, IMetaverserItems _itemsContract) {
        itemsContract = _itemsContract;
        MTVTToken = _erc20;
        assetsCount=0;
        whitelist[msg.sender]= true;
        whitelist[address(this)]= true;
        daoAddr = msg.sender;
        minerAddr = msg.sender;
    }

    function transferToNewContract(address _newContract,uint256 _from, uint256 _to) public onlyOwner {
        if(_to > assetsCount) {
            _to =  assetsCount;
        }
        if(_from >  assetsCount ) {
            _from = assetsCount ;
        }
        for(uint256 i=_from;i<=_to ; i++) {
            RentalTokens memory _data = rentAssets[i];
            if(itemsContract.balanceOf( address(this) , _data.tokenId ) > 0 ){
               itemsContract.safeTransferFrom(address(this),_newContract ,_data.tokenId   , 1 ,'0x0' );  
            }
            
        }
    }
    function syncContractData(IRent oldContract, uint256 _from, uint256 _to) public onlyOwner   {
        uint256 oldAssetCount = oldContract.assetsCount();
        if(_to > oldAssetCount) {
            _to =  oldAssetCount;
        }
        if(_from >  oldAssetCount ) {
            _from = oldAssetCount ;
        }
        for(uint256 i=_from;i<=_to ; i++) {
            rentAssets[i]  =  oldContract.getRentAssets(i);
            address mainOwner= rentAssets[i].mainOwner;
            address rentOwner= rentAssets[i].rentOwner;
            
            lessorAssets[mainOwner ].push(i)   ;
            emit AddRoRent( mainOwner ,rentAssets[i].tokenId, rentAssets[i].price ); 

            if(rentOwner != address(0)){
                lesseeAssets[rentOwner].push(i)   ;
                if( !holders[rentOwner] ){
                    holdersAddress[ usersCounter ] = rentOwner;
                    holders[rentOwner]=true;
                    usersCounter++;
                }
                emit LeaseAsset(rentAssets[i].tokenId,i,rentAssets[i].rentOwner, rentOwner ,rentAssets[i].price);

            }
        }

        assetsCount = _to;
        
        //change owner from old contract 
    }

    function addToRent(uint256 tokenId,uint256 price,uint256 rentTime) public {
        require(tokenId <= itemsContract.getTokenCount() , 'tokenId does not exist') ;
        
        itemsContract.safeTransferFrom(msg.sender , address(this) , tokenId, 1 , '');

        rentAssets[assetsCount]=RentalTokens(msg.sender ,address(0),tokenId,price,rentTime,0,itemsContract.getTokenName(tokenId));

        lessorAssets[msg.sender ].push(assetsCount)   ;

        assetsCount++;

        emit AddRoRent( msg.sender ,tokenId,price); 
    }

    function rent(uint256 assetId) public openMarket{
        require(assetId <= assetsCount  , 'AssetId does not exist') ;
        require(rentAssets[assetId].price > 0 , 'AssetId does not hve price') ;
        require(rentAssets[assetId].mainOwner != address(0) , 'AssetId does not exist') ;
        require(rentAssets[assetId].rentOwner == address(0) , 'AssetId already rented by another') ;

        rentAssets[assetId].rentOwner=msg.sender;
        rentAssets[assetId].startTime= block.timestamp;

        lesseeAssets[msg.sender].push(  assetId )   ;
        uint256 DAOTax = (rentAssets[assetId].price * daoPercent) / 100;
        uint256 MinersTax = (rentAssets[assetId].price * minerPercent) / 100;

        MTVTToken.transferFrom(msg.sender, rentAssets[assetId].mainOwner , rentAssets[assetId].price ); 
        MTVTToken.transferFrom(msg.sender, daoAddr, DAOTax);
        MTVTToken.transferFrom(msg.sender, minerAddr, MinersTax);

        if( !holders[msg.sender]  ){
            
            holdersAddress[ usersCounter ] = msg.sender;
            holders[msg.sender]=true;
            usersCounter++;
        }

        emit LeaseAsset(rentAssets[assetId].tokenId,assetId,rentAssets[assetId].rentOwner, msg.sender ,rentAssets[assetId].price);

    }

    function claim(uint256 assetId) public {
        require(assetId <= assetsCount  , 'assetId does not exist') ;
        require(rentAssets[assetId].mainOwner == msg.sender  , 'You are not this asset owner') ;
        require(rentAssets[assetId].rentOwner == address(0) || block.timestamp > rentAssets[assetId].startTime + rentAssets[assetId].tenancy     , 'You can not calaim now') ;
        
        itemsContract.safeTransferFrom( address(this) ,msg.sender, rentAssets[assetId].tokenId , 1 , '');
        
        emit ClaimAssetRent( rentAssets[assetId].tokenId,rentAssets[assetId].mainOwner );
        
        delete rentAssets[assetId] ;
        
    }
    function setPause(bool _pause) public onlyOwner {
        isPaused = _pause;
    }

    function setDAOAddr(address _addr) public onlyOwner {
        daoAddr = _addr;
    }

    function setMinersAddress(address _addr) public onlyOwner {
        minerAddr = _addr;
    }
    //get function
    
    function getRentAssets(uint256 assetId) public view returns(RentalTokens memory) {
        return rentAssets[assetId];
    }

    function getLessorAssets(address user) public view returns(uint256[] memory) {
        return lessorAssets[user];
    }

    function getLesseeAssets(address user) public view returns(uint256[] memory) {
        return lesseeAssets[user];
    }

    function getHolderAddressByIndex(uint256 _index) external view returns(address){
        return holdersAddress[_index];
    }

    function getLesseeTokens(address user) public view returns(Assets[] memory) {

        uint256 totalToken = itemsContract.getTokenCount() ;
        Assets[] memory userAssets = new Assets[](totalToken);
        for(uint256 i=1;i<=totalToken;i++) {
            userAssets[i-1]=Assets( itemsContract.getTokenName(i) , 0 );
        }

        for(uint256 i=0;i<lesseeAssets[user].length;i++) {
           RentalTokens memory rentedItem = getRentAssets(lesseeAssets[user][i]);

           if(block.timestamp <= rentedItem.startTime + rentedItem.tenancy ) {

                uint256 tokenId = rentedItem.tokenId;
                uint256 userRentSupply= userAssets[tokenId-1].supply + 1 ;
                userAssets[tokenId-1] = Assets(  itemsContract.getTokenName(tokenId) ,  userRentSupply  ) ;

           }

        }
        
        return userAssets;
    }

    function getAllRentItems(uint256 _from,uint256 _end) public view returns(RentalTokens[] memory ) {
        if(_end >  assetsCount ) {
            _end = assetsCount ;
        }
        if(_from >  assetsCount ) {
            _from = assetsCount ;
        }
        uint256 total = _end - _from ;
        uint256 cnt=0;
        RentalTokens[] memory _data = new RentalTokens[](total);
        for(uint256 i=_from; i<_end ;i++) {
            _data[cnt]=rentAssets[i];
            cnt++;
        }
        return _data;
    }

}