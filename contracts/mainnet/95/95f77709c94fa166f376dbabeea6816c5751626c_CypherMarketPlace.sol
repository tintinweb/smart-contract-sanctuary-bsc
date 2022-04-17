/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

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

// File: Cypher/CypherMarketplace.sol


pragma solidity ^0.8.6;



interface IERC1155 {
    function setApprovalForAll(address operator, bool approved) external;
}

contract CypherMarketPlace is Ownable {

    struct infoSale {
        bytes32 hashId;
        address author;
        uint256 idToken;
        uint256 price;
        uint256 timePublished;
    }

    mapping (bytes32 => infoSale) private _sale;
    mapping (address => bytes32[]) private _userSales;

    bytes32[] private _allSales;

    IERC20 private cypherToken;
    IERC1155 private cypherCollectionable;
    address public cypherRouter;

    event newSale(address indexed seller, uint256 tokenId, uint256 tokenPrice, uint256 timestamp, bytes32 hashId);
    event removeSale(address indexed seller, bytes32 hashId);
    event Sold(address indexed seller, address indexed buyer, uint256 tokenId, uint256 tokenPrice);

    constructor (address _cypherContract, address _collectionContract) {
        cypherToken = IERC20(_cypherContract);
        cypherCollectionable = IERC1155(_collectionContract);
    }

    function setRouter(address _router) public onlyOwner {
         cypherRouter = _router;
         cypherCollectionable.setApprovalForAll(cypherRouter, true);
    }

    modifier onlyRouter {
        require(msg.sender == cypherRouter);
        _;
    }

    function getSaleId(bytes32 _hashId, bytes32[] memory array) private pure returns (uint256) {
        uint256 _saleId = 0;

        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == _hashId) {
                _saleId = i;
            }
        }

        return _saleId;
    }

    function _removeItemOfArray(bytes32[] storage array, uint256 tmpId) private {
        if ((array.length > 0) && tmpId != (array.length - 1)) {
            bytes32 tmpHash = array[array.length - 1];
            array[tmpId] = tmpHash;
        }

        array.pop();
    }

    function _removeSale(address _seller, bytes32 _hashId) private returns (bool) {
        _removeItemOfArray(_allSales, getSaleId(_hashId, _allSales));
        _removeItemOfArray(_userSales[_seller], getSaleId(_hashId, _userSales[_seller]));

        delete _sale[_hashId];
        return true;
    }

    function addSale(address sender, uint256 _idToken, uint256 _priceToken) public onlyRouter returns(bool) {        
        bytes32 hashId = keccak256(abi.encodePacked(sender, _idToken, _priceToken, block.timestamp));
        _sale[hashId] = infoSale(hashId, sender, _idToken, _priceToken, block.timestamp);

        _userSales[sender].push(hashId);
        _allSales.push(hashId);
        emit newSale(sender, _idToken, _priceToken, block.timestamp, hashId);
        return true;
    }

    function sellItem(address _seller, address _buyer, uint256 _tokenId, uint256 _priceToken, bytes32 _hashId) public onlyRouter returns(bool) {        
        _removeSale(_seller, _hashId);
        emit Sold(_seller, _buyer, _tokenId, _priceToken);
        return true;
    }

    function salePriceByHash(bytes32 _hashId) public view returns (uint256) {
        return _sale[_hashId].price;
    }

    function saleOwnerByHash(bytes32 _hashId) public view returns (address) {
        return _sale[_hashId].author;
    }

    function saleTokenByHash(bytes32 _hashId) public view returns (uint256) {
        return _sale[_hashId].idToken;
    }

    function removeUserSale(address _sender, uint256 _tokenId, bytes32 _hashId) public onlyRouter returns (bool) {
        address seller = _sale[_hashId].author;
        uint256 tokenId = _sale[_hashId].idToken;
        require(_sender == seller, "not owner");
        require(_tokenId == tokenId, "error");

        _removeSale(seller, _hashId);
        emit removeSale(seller, _hashId);
        return true;
    }

    function userSales(address _user) public view returns (bytes32[] memory) {
        return _userSales[_user];
    }

    function allSales() public view returns(infoSale[] memory) {
        infoSale[] memory ret = new infoSale[](_allSales.length);

        for (uint256 i = 0; i < _allSales.length; i++) {
            if (_sale[_allSales[i]].author != address(0)) {
                ret[i] = _sale[_allSales[i]];   
            }
        }
        return ret;
    }

}