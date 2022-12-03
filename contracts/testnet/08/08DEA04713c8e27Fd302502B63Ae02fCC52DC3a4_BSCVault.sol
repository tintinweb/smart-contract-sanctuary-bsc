// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC1155.sol";
import "./IERC721.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BSCVault is Ownable{
    using SafeMath for uint256;

    /// @notice NFT token type supported: 0-ERC721, 1-ERC1155
    enum TokenType {ERC721, ERC1155}
    
    /// @notice NFT token status flag: 0-empty, 1-for_rent, 2-rented, 3-not_rentable
    enum TokenState {empty, for_rent, rented, not_rentable}

    struct Term{
        TokenType  tkType;
        bool       renewable;
        address    lender;
        uint       coinIndex;
        uint       minTime;
        uint       maxTime;
        uint       price;
        uint       gameBonus;
        TokenState status;
        address    renter;
        uint       leaseTime;
        uint       endtime;
    }

    address[] public rentCoin;
    uint public adminFee;
    address public adminWallet;

    /// @notice NFT leasing term indexed by NFT contract address and token id
    mapping(address => mapping(uint => Term)) public term;
    mapping(address => mapping(uint => uint)) public userBalance;
    mapping(uint => uint) public adminBalance;
    mapping(address => mapping(address => uint[])) public userNFT;

    event Deposit(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus);
    event Withdraw(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID);
    event Rent(address _renter, address _NFTaddr, uint _tokenID, uint _rentTime);
    event ResetDeposit(address _lender, TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus);

    /// @notice Deposit NFT into vault with leasing term
    function deposit(TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus) public returns(bool){
        if(_tkType == TokenType.ERC721){
            require(IERC721(_NFTaddr).ownerOf(_tokenID) == msg.sender ,"Depositer must be owner!" );
        }else{
            require(IERC1155(_NFTaddr).balanceOf(msg.sender,_tokenID) > 0 ,"Depositer must be owner!" );
        }

        term[_NFTaddr][_tokenID] = Term({
            tkType: _tkType,
            renewable: _renewable,
            lender: msg.sender,
            coinIndex: _coinIndex,
            minTime: _minimumLeaseTime,
            maxTime: _maximumLeaseTime,
            price: _price,
            gameBonus: _gameBonus,
            status: TokenState.for_rent,
            renter: address(0),
            leaseTime: 0,
            endtime: 0});

        if(_tkType == TokenType.ERC721){
            IERC721(_NFTaddr).transferFrom(msg.sender,address(this),_tokenID);
        }else{
            IERC1155(_NFTaddr).safeTransferFrom(msg.sender,address(this),_tokenID,1,"0x00");
        }

        emit Deposit(msg.sender, _tkType, _NFTaddr, _tokenID, _renewable, _coinIndex, _minimumLeaseTime, _maximumLeaseTime, _price, _gameBonus);

        return true;
    }
    
    /// @notice change leasing term of NFT in vault
    function resetDeposit(TokenType _tkType, address _NFTaddr, uint _tokenID, bool _renewable, uint _coinIndex, uint8 _minimumLeaseTime, uint8 _maximumLeaseTime, uint _price, uint8 _gameBonus) public returns(bool){
        require(term[_NFTaddr][_tokenID].lender == msg.sender, "Only depositer allowed");

        Term storage rentTerm = term[_NFTaddr][_tokenID];
        rentTerm.renewable = _renewable;
        rentTerm.coinIndex = _coinIndex;
        rentTerm.minTime = _minimumLeaseTime;
        rentTerm.maxTime = _maximumLeaseTime;
        rentTerm.price = _price;
        rentTerm.gameBonus = _gameBonus;
        rentTerm.endtime = 0;

        emit ResetDeposit(msg.sender, _tkType, _NFTaddr, _tokenID, _renewable, _coinIndex, _minimumLeaseTime, _maximumLeaseTime, _price, _gameBonus);
        return true;
    }

    /// @notice Withdraw NFT from vault after leasing
    function withdraw(address _NFTaddr, uint _tokenID) public{
        require(term[_NFTaddr][_tokenID].status != TokenState.rented || term[_NFTaddr][_tokenID].endtime < block.timestamp, "NFT in rent!");
        require(term[_NFTaddr][_tokenID].lender == msg.sender, "Only depositer allowed");

        if(term[_NFTaddr][_tokenID].tkType == TokenType.ERC721){
            IERC721(_NFTaddr).safeTransferFrom(address(this), msg.sender, _tokenID);
        }else{
            IERC1155(_NFTaddr).safeTransferFrom(address(this), msg.sender, _tokenID, 1, "0x00");
        }

        term[_NFTaddr][_tokenID].status = TokenState.empty;

        emit Withdraw(msg.sender, term[_NFTaddr][_tokenID].tkType, _NFTaddr, _tokenID);
    }

    /// @notice Rent NFT in the vault
    function rent(address _NFTaddr, uint _tokenID, uint _rentTime) public{
        require(term[_NFTaddr][_tokenID].status != TokenState.empty, "NFT empty");
        require(term[_NFTaddr][_tokenID].lender != msg.sender, "Lender is self");
        require(term[_NFTaddr][_tokenID].status != TokenState.rented || term[_NFTaddr][_tokenID].endtime < block.timestamp, "NFT in rent");
        require(term[_NFTaddr][_tokenID].endtime == 0 || term[_NFTaddr][_tokenID].renewable , "NFT rent disabled");
        require(_rentTime >= term[_NFTaddr][_tokenID].minTime && _rentTime <= term[_NFTaddr][_tokenID].maxTime, "Out of time range");

        address coinAddress = rentCoin[term[_NFTaddr][_tokenID].coinIndex];
        uint fee = term[_NFTaddr][_tokenID].price.mul(_rentTime);
        IERC20(coinAddress).transferFrom(msg.sender, address(this), fee); 

        term[_NFTaddr][_tokenID].status = TokenState.rented;
        term[_NFTaddr][_tokenID].renter = msg.sender;
        term[_NFTaddr][_tokenID].leaseTime = _rentTime;
        term[_NFTaddr][_tokenID].endtime = block.timestamp.add(_rentTime.mul(3600).mul(24));
        userBalance[term[_NFTaddr][_tokenID].lender][term[_NFTaddr][_tokenID].coinIndex] += fee.mul(100 - adminFee).div(100);
        adminBalance[term[_NFTaddr][_tokenID].coinIndex] += fee.mul(adminFee).div(100);
        //_lendItemID
        userNFT[msg.sender][_NFTaddr].push(_tokenID);

        emit Rent(msg.sender, _NFTaddr, _tokenID, _rentTime);
    }

    function addRentCoin(address _rentCoin) public onlyOwner{
        for(uint i = 0 ; i< rentCoin.length ; i++){
            require(_rentCoin != rentCoin[i], "The coin has been added!");
        } 
        rentCoin.push(_rentCoin);
    }

    function setAdminFee(uint _fee) public onlyOwner{
        adminFee = _fee;
    }

    function balanceOf(address _renter, address _NFTaddr) public view returns(uint){
        uint balance = 0;
        for(uint i; i < userNFT[_renter][_NFTaddr].length; i++){
             uint tokenId = userNFT[_renter][_NFTaddr][i];
             if(term[_NFTaddr][tokenId].renter == _renter && 
             term[_NFTaddr][tokenId].status == TokenState.rented &&
             term[_NFTaddr][tokenId].endtime > block.timestamp){
                 balance += 1;
             }
        }
        return balance;
    }

    function tokenOfRenterByIndex(address _renter, address _NFTaddr, uint _index) public view returns(uint) {
        uint index = 0;
        for(uint i; i < userNFT[_renter][_NFTaddr].length; i++){
             uint tokenId = userNFT[_renter][_NFTaddr][i];
             if(term[_NFTaddr][tokenId].renter == _renter && 
             term[_NFTaddr][tokenId].status == TokenState.rented &&
             term[_NFTaddr][tokenId].endtime > block.timestamp){
                 if(index == _index){
                     return tokenId;
                 }
                 index += 1;
             }
        }
        return 0;
    }

    function renterOfToken(address _NFTaddr, uint tokenId) public view returns(address) {
        if(term[_NFTaddr][tokenId].status == TokenState.rented && term[_NFTaddr][tokenId].endtime > block.timestamp){
            return term[_NFTaddr][tokenId].renter;
        }
        return address(0);
    }

    function claimRentFee() public {
        for(uint i = 0; i < rentCoin.length; i ++){
            if(userBalance[msg.sender][i] > 0){
                address coinAddress = rentCoin[i];
                IERC20(coinAddress).transfer(msg.sender, userBalance[msg.sender][i]);
                userBalance[msg.sender][i] = 0;
            }
        }
    }

    function setAdminWallet(address _admin) public onlyOwner {
        adminWallet = _admin;
    }

    function claimAdminFee() public {
        require(adminWallet != address(0), "Admin wallet not set");
        for(uint i = 0; i < rentCoin.length; i ++){
            if(adminBalance[i] > 0){
                address coinAddress = rentCoin[i];
                IERC20(coinAddress).transfer(adminWallet, adminBalance[i]);
                adminBalance[i] = 0;
            }
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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