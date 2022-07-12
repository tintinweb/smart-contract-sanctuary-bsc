/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * Strings Library
 * 
 * In summary this is a simple library of string functions which make simple 
 * string operations less tedious in solidity.
 * 
 * Please be aware these functions can be quite gas heavy so use them only when
 * necessary not to clog the blockchain with expensive transactions.
 * 
 * @author James Lockhart <[email protected]>
 */
library Strings {

    /**
     * Concat (High gas cost)
     * 
     * Appends two strings together and returns a new value
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length +
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string memory _base, string memory _value)
        internal
        pure
        returns (int) {
        return _indexOf(_base, _value, 0);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function _indexOf(string memory _base, string memory _value, uint _offset)
        internal
        pure
        returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }

    /**
     * Length
     * 
     * Returns the length of the specified string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string to be measured
     * @return uint The length of the passed string
     */
    function length(string memory _base)
        internal
        pure
        returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    /**
     * Sub String
     * 
     * Extracts the beginning part of a string based on the desired length
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @return string The extracted sub string
     */
    function substring(string memory _base, int _length)
        internal
        pure
        returns (string memory) {
        return _substring(_base, _length, 0);
    }

    /**
     * Sub String
     * 
     * Extracts the part of a string based on the desired length and offset. The
     * offset and length must not exceed the lenth of the base string.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @param _offset The starting point to extract the sub string from
     * @return string The extracted sub string
     */
    function _substring(string memory _base, int _length, int _offset)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);

        assert(uint(_offset + _length) <= _baseBytes.length);

        string memory _tmp = new string(uint(_length));
        bytes memory _tmpBytes = bytes(_tmp);

        uint j = 0;
        for (uint i = uint(_offset); i < uint(_offset + _length); i++) {
            _tmpBytes[j++] = _baseBytes[i];
        }

        return string(_tmpBytes);
    }

    /**
     * Compare To
     * 
     * Compares the characters of two strings, to ensure that they have an 
     * identical footprint
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent
     */
    function compareTo(string memory _base, string memory _value)
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for (uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i]) {
                return false;
            }
        }

        return true;
    }

    /**
     * Compare To Ignore Case (High gas cost)
     * 
     * Compares the characters of two strings, converting them to the same case
     * where applicable to alphabetic characters to distinguish if the values
     * match.
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent value
     *              discarding case
     */
    function compareToIgnoreCase(string memory _base, string memory _value)
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for (uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i] &&
            _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {
                return false;
            }
        }

        return true;
    }

    /**
     * Upper
     * 
     * Converts all the values of a string to their corresponding upper case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to upper case
     * @return string 
     */
    function upper(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Lower
     * 
     * Converts all the values of a string to their corresponding lower case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to lower case
     * @return string 
     */
    function lower(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Upper
     * 
     * Convert an alphabetic character to upper case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to upper case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a lower case otherwise returns the original value
     */
    function _upper(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1) - 32);
        }

        return _b1;
    }

    /**
     * Lower
     * 
     * Convert an alphabetic character to lower case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to lower case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a upper case otherwise returns the original value
     */
    function _lower(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }
}

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {
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

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

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

    function royaltyInfo(uint256 tokenId, uint256 price)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function merchantRoyaltyInfo(uint256 tokenId, uint256 price)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function royaltyInfo(uint256 tokenId)
        external
        view
        returns (address receiver, uint256 royalty);

        function merchantRoyaltyInfo(uint256 tokenId)
        external
        view
        returns (address receiver, uint256 royalty);

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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract NFTBuySell is IERC721Receiver,ReentrancyGuard {
    using Strings for string;
    using Counters for Counters.Counter;
    Counters.Counter public _itemIds;
    Counters.Counter public _itemsSold;
    
    IERC20 public tokenContract;
    IERC721 public musicNFTContractAddress;
    IERC721 public loudlingNFTContractAddress;
    address payable owner;
    uint256 public fee;
    address payable marketingWallet;    

    constructor(address _musicNFTContractAddress, address _loudlingNFTContractAddress, address _tokenContract,uint256 _fee,address _marketingWallet) {
        owner = payable(msg.sender);
        tokenContract = IERC20(_tokenContract);
        musicNFTContractAddress = IERC721(_musicNFTContractAddress);
        loudlingNFTContractAddress = IERC721(_loudlingNFTContractAddress);
        fee = _fee;
        marketingWallet = payable(_marketingWallet);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    struct MarketItem {
        address nftAddress;
        address tokenAddress;
        string tokenName;
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 fee;
        uint256 feeAmount;
        uint256 totalPrice;
        bool sold;            
    }

    mapping(uint256 => MarketItem) public idToMarketItem;

    struct MarketItemInfo {
        address nftAddress;
        address tokenAddress;
        string tokenName;
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 fee;
        uint256 feeAmount;
        uint256 totalPrice;
        bool sold;
        address creator;
        uint256 royaltyFee;
        uint256 merchantFee;
        address merchant;            
    }

    struct UserNFT {
        address nftAddress;        
        uint256 tokenId;
        string uri;
        string nameNFT;
        address owner;
        address creator;
        uint256 royaltyFee;
        uint256 merchantFee;
        address merchant;
    }    
    
    event MarketItemCreated(
        address nftAddress,
        address tokenAddress,
        string tokenName,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 fee,
        uint256 feeAmount,
        uint256 totalPrice,
        bool sold
    );

    event LogErrorString(string message);
    event LogErrorBytes(bytes data);

    function SetMarketingFee(uint256 _fee) public onlyOwner  {
        fee = _fee;
    } 

    function SetMusicNFTContractAddress(address _musicNFTContractAddress) public onlyOwner  {
        musicNFTContractAddress = IERC721(_musicNFTContractAddress);
    } 

    function SetLoudlingNFTContractAddress(address _loudlingNFTContractAddress) public onlyOwner {
        loudlingNFTContractAddress = IERC721(_loudlingNFTContractAddress);
    } 

    function SetMarketingWallet(address _marketingWallet) public onlyOwner {
        marketingWallet = payable(_marketingWallet);
    } 
    
    /* Places an item for sale on the marketplace */
    function createMarketItem(uint256 tokenId, uint256 price, address _nftContract, address _tokenAddress,string memory _tokenName) public nonReentrant {
        require(price > 0, "Price must be cannot be zero");         
        IERC721 nftContract = IERC721(_nftContract);
               _itemIds.increment();
        uint256 itemId = _itemIds.current();

        uint256 calFee = (price * fee) / 100;
        uint256 totalPrice = price + calFee;
       
        idToMarketItem[itemId] = MarketItem(
            _nftContract,
            _tokenAddress,
            _tokenName,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            fee,
            calFee,
            totalPrice,
            false
              );

        nftContract.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
       
        emit MarketItemCreated(
            _nftContract,
            _tokenAddress,
            _tokenName,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            fee,
            calFee,
            totalPrice,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId) public payable nonReentrant {
        uint256 totalPrice = idToMarketItem[itemId].totalPrice;
        uint256 price = idToMarketItem[itemId].price; 
        string memory tokenName = idToMarketItem[itemId].tokenName; 

        if(tokenName.upper().compareTo("BNB")) {            
            require(msg.value >= totalPrice, "Token Balance is low");
        }  
        else {
            require(tokenContract.balanceOf(msg.sender) >= totalPrice, "Token Balance is low");
            
            tokenContract = IERC20(idToMarketItem[itemId].tokenAddress);
        }
        
        IERC721 nftContract = IERC721(idToMarketItem[itemId].nftAddress);

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;        
        uint256 royaltyFeeAmount = 0;
        uint256 merchantFeeAmount = 0;
        uint256 feeAmount = idToMarketItem[itemId].feeAmount; 

        if(tokenName.upper().compareTo("BNB")) {            
                      
            try nftContract.royaltyInfo(tokenId, price) returns (address creator, uint256 royaltyFee) {
                royaltyFeeAmount = royaltyFee;
                if (royaltyFeeAmount > 0) {
                    payable(creator).transfer(royaltyFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }
            // merchant Fee
             try nftContract.merchantRoyaltyInfo(tokenId, price) returns (address merchant, uint256 merchantFee) {
                merchantFeeAmount = merchantFee;
                if (merchantFeeAmount > 0) {
                    payable(merchant).transfer(merchantFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }

            if (feeAmount > 0) {
                payable(marketingWallet).transfer(feeAmount);  
            }

            uint256 actualPrice = totalPrice - royaltyFeeAmount - feeAmount - merchantFeeAmount;

            payable(seller).transfer(actualPrice);
        }  
        else {
            try nftContract.royaltyInfo(tokenId, price) returns (address creator, uint256 royaltyFee) {
                royaltyFeeAmount = royaltyFee;
                if (royaltyFeeAmount > 0) {
                    tokenContract.transferFrom(msg.sender, creator, royaltyFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }
            try nftContract.merchantRoyaltyInfo(tokenId, price) returns (address merchant, uint256 merchantFee) {
                merchantFeeAmount = merchantFee;
                if (merchantFeeAmount > 0) {
                    tokenContract.transferFrom(msg.sender, merchant, merchantFeeAmount);
                }
            }
            catch Error(string memory reason) {
                emit LogErrorString(reason);
            } 
            catch (bytes memory reason) {
                // catch failing assert()
                emit LogErrorBytes(reason);
            }

            if (feeAmount > 0) {
                tokenContract.transferFrom(msg.sender, marketingWallet, feeAmount);  
            }

            uint256 actualPrice = totalPrice - royaltyFeeAmount - feeAmount - merchantFeeAmount;

            tokenContract.transferFrom(msg.sender, seller, actualPrice);
        }

        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
    }

    /* Calnce the sale of a marketplace item */
    /* Transfers ownership of the item */
    function cancleMarketItem(uint256 itemId) public nonReentrant {
        require(idToMarketItem[itemId].sold == false, "NFT already sold.");
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            idToMarketItem[itemId].seller == msg.sender,
            "Caller not an owner of the market item"
        );

        IERC721 nftContract = IERC721(idToMarketItem[itemId].nftAddress);        
        
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns all market items */
    function fetchAllMarketItems() public view returns (MarketItemInfo[] memory) {
        uint256 itemCount = _itemIds.current();
         uint256 currentIndex = 0;
         string memory _error;
         bytes memory _reason;
        MarketItemInfo[] memory items = new MarketItemInfo[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {   
             uint256 currentId = i + 1;
             IERC721 _nftContract = IERC721(idToMarketItem[currentId].nftAddress);
            
            try _nftContract.royaltyInfo(idToMarketItem[currentId].tokenId) returns (address creator, uint256 royaltyFee) {
                items[currentIndex].royaltyFee=royaltyFee;
                 items[currentIndex].creator=creator;
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }

            try _nftContract.merchantRoyaltyInfo(idToMarketItem[currentId].tokenId) returns (address merchant, uint256 merchantFee) {
                items[currentIndex].merchantFee=merchantFee;
                items[currentIndex].merchant=merchant;
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }            

             items[currentIndex].nftAddress=idToMarketItem[currentId].nftAddress;
             items[currentIndex].tokenAddress=idToMarketItem[currentId].tokenAddress;
             items[currentIndex].tokenName=idToMarketItem[currentId].tokenName;
             items[currentIndex].itemId=idToMarketItem[currentId].itemId;
             items[currentIndex].tokenId=idToMarketItem[currentId].tokenId;
             items[currentIndex].seller=idToMarketItem[currentId].seller;
             items[currentIndex].owner=idToMarketItem[currentId].owner;
             items[currentIndex].price=idToMarketItem[currentId].price;
             items[currentIndex].fee=idToMarketItem[currentId].fee;
             items[currentIndex].feeAmount=idToMarketItem[currentId].feeAmount;
             items[currentIndex].totalPrice=idToMarketItem[currentId].totalPrice;
             items[currentIndex].sold=idToMarketItem[currentId].sold;      
                currentIndex += 1;            
        }
        return items;
    }

    function fetchUserNFTs(address userAddress) public view returns (UserNFT[] memory) {
        uint256 musicCount = musicNFTContractAddress.balanceOf(userAddress);
        uint256 loudlingCount = loudlingNFTContractAddress.balanceOf(userAddress);
         uint256 totalItemMarketCount = _itemIds.current();
        uint256 itemCount = 0;
          itemCount = musicCount + loudlingCount;
          string memory _error;
         bytes memory _reason;

        for (uint256 i = 0; i < totalItemMarketCount; i++) {
            if (idToMarketItem[i + 1].seller == userAddress && idToMarketItem[i + 1].sold==false) {
                itemCount += 1;
            }
        }
      
         uint256 currentIndex = 0;

        UserNFT[] memory items = new UserNFT[](itemCount);
        for (uint256 i = 0; i < musicCount; i++) {            
                items[currentIndex].nftAddress = address(musicNFTContractAddress);
                uint256 tokenId = musicNFTContractAddress.tokenOfOwnerByIndex(userAddress,i);
                items[currentIndex].tokenId = tokenId;
                items[currentIndex].uri = musicNFTContractAddress.tokenURI(tokenId);
                items[currentIndex].nameNFT = "MUSIC";
                items[currentIndex].owner = userAddress;
             
                 try musicNFTContractAddress.royaltyInfo(tokenId) returns (address creator, uint256 royaltyFee) {
                    items[currentIndex].royaltyFee=royaltyFee;
                    items[currentIndex].creator=creator;
                }
                catch Error(string memory reason) {
                    _error=reason;
                } 
                catch (bytes memory reason) {
                    _reason=reason;
                }

                try musicNFTContractAddress.merchantRoyaltyInfo(idToMarketItem[i + 1].tokenId) returns (address merchant, uint256 merchantFee) {
                    items[currentIndex].merchantFee=merchantFee;
                    items[currentIndex].merchant=merchant;
                }
                catch Error(string memory reason) {
                    _error=reason;
                } 
                catch (bytes memory reason) {
                    _reason=reason;
                }

                currentIndex += 1;            
        }
        for (uint256 i = 0; i < loudlingCount; i++) {            
                items[currentIndex].nftAddress = address(loudlingNFTContractAddress);
                uint256 tokenId = loudlingNFTContractAddress.tokenOfOwnerByIndex(userAddress,i);
                items[currentIndex].tokenId = tokenId;
                items[currentIndex].uri = loudlingNFTContractAddress.tokenURI(tokenId);
                items[currentIndex].nameNFT = "LOUDLING";
                items[currentIndex].owner = userAddress;
                currentIndex += 1;             
        }
        for (uint256 i = 0; i < totalItemMarketCount; i++) {  

              if (idToMarketItem[i + 1].seller == userAddress && idToMarketItem[i + 1].sold==false) {
                   IERC721 _nftContract = IERC721(idToMarketItem[i + 1].nftAddress);
               items[currentIndex].nftAddress=idToMarketItem[i + 1].nftAddress;
               items[currentIndex].tokenId=idToMarketItem[i + 1].tokenId;
               items[currentIndex].uri=_nftContract.tokenURI(idToMarketItem[i + 1].tokenId);
               items[currentIndex].nameNFT = "MARKET";
               items[currentIndex].owner = userAddress;
                          
                try _nftContract.royaltyInfo(idToMarketItem[i + 1].tokenId) returns (address creator, uint256 royaltyFee) {
                    items[currentIndex].royaltyFee=royaltyFee;
                    items[currentIndex].creator=creator;
                }
                catch Error(string memory reason) {
                    _error=reason;
                } 
                catch (bytes memory reason) {
                    _reason=reason;
                }

                try _nftContract.merchantRoyaltyInfo(idToMarketItem[i + 1].tokenId) returns (address merchant, uint256 merchantFee) {
                    items[currentIndex].merchantFee=merchantFee;
                     items[currentIndex].merchant=merchant;
                }
                catch Error(string memory reason) {
                    _error=reason;
                } 
                catch (bytes memory reason) {
                    _reason=reason;
                }               

                currentIndex += 1;             
            }

                  
        }
        return items;
    }

    /* Returns onlyl items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
        
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}