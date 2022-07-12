/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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


pragma solidity ^0.8.11;
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721  {
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
    

    function royaltyFee(uint256 tokenId) external view returns (uint256);

    function getCreator(uint256 tokenId) external view returns (address);
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
}

pragma solidity ^0.8.11;

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

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(string value, uint256 indexed id);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function royaltyFee(uint256 tokenId) external view returns (uint256);

    function getCreator(uint256 tokenId) external view returns (address);
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

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
    
}
pragma solidity ^0.8.11;
contract OffersNFT 
{
  using Strings for string;
   IERC20  tokenContract;
   IERC721  nftContract;
   IERC1155  nftContract1155;
   address payable owner;
    address payable ContractAddress;
  constructor() {
        owner = payable(msg.sender);
     
        
    }
    address public ownAddress= msg.sender;
   
       struct OffersDetails {
        uint256 OfferId;
        uint256 TokenId;
        address OffersAddress;
        uint256 Offeramount;
        uint256 StartDate;
        uint256 EndDate;
        bool isWinner;
        bool isReturn;
        string  NFTType;
        address TokenAddress;
        string TokenName;

    }
     struct OfferByUser {
        address NFTAddress;
        uint256 TokenId;
        uint256 OfferId;
        uint256 Offeramount;
        uint256 StartDate;
        uint256 EndDate;
        bool isWinner;
        bool isReturn;
        string  NFTType;
        address TokenAddress;
        string TokenName;
    }
    mapping(address => mapping(uint256 =>  mapping(uint256 => OffersDetails))) public OffersDetail;
    mapping(address => mapping(uint256 =>  uint256)) public totalOffers;
    mapping(address => mapping(uint256 =>  OfferByUser)) public allOfferByUser ;
    mapping(address => uint256 ) public totalUserOffer ;
     event LogErrorString(string message);
    event LogErrorBytes(bytes data);

  
   function createOffer(address _nftAddress , uint256 _offersAmount,uint256 _endDate,uint256 _tokenId,string memory _nftType, address _tokenAddress,string memory _tokenName )  public payable  returns (uint256) 
       { 
           
            require(
          _nftType.upper().compareTo("SINGLE")  || _nftType.upper().compareTo("BATCH") ,
            "Allow only BATCH or SINGLE NFTType"
             );   
              if(_tokenName.upper().compareTo("BNB")) {            
            require(msg.value >= _offersAmount, "Token Balance is low");
            }
            else {
                tokenContract = IERC20(_tokenAddress);
            require(tokenContract.balanceOf(msg.sender) >= _offersAmount, "Token Balance is low");
                       
           }
        
            uint256 totalItemCount = totalOffers[_nftAddress][_tokenId];
            uint256 incrementedId=totalItemCount+1;
            totalOffers[_nftAddress][_tokenId]+=1;
            uint256 totalUserOfferCount = totalUserOffer[ msg.sender];
            totalUserOffer[msg.sender]+=1;
            OffersDetail[_nftAddress][_tokenId][incrementedId] = OffersDetails (
             incrementedId,
              _tokenId,
              msg.sender,
              _offersAmount,
              block.timestamp,
              _endDate,
             false,
             false,
             _nftType,
             _tokenAddress,
             _tokenName
            );
            allOfferByUser[msg.sender][totalUserOfferCount+1]=OfferByUser(
              _nftAddress,
              _tokenId,
              incrementedId,
              _offersAmount,
              block.timestamp,
              _endDate,
               false,
             false,
             _nftType,
             _tokenAddress,
             _tokenName
            );
            
             if(_tokenName.upper().compareTo("BNB")) {    
             }else{
                tokenContract = IERC20(_tokenAddress);
                tokenContract.transferFrom(msg.sender, address(this), _offersAmount);
             }
        return incrementedId;
    }
      function GetOffers(address _nftAddress ,uint256 _tokenId) public view returns(OffersDetails[] memory) {
        uint256 totalItemCount = totalOffers[_nftAddress][_tokenId];
        OffersDetails[] memory items = new OffersDetails[](totalItemCount);
        uint256 currentIndex=0;
        for (uint256 i = 0; i < totalItemCount; i++) {
              currentIndex ++;
                items[i].OfferId = OffersDetail[_nftAddress][_tokenId][currentIndex].OfferId;
                items[i].TokenId =  OffersDetail[_nftAddress][_tokenId][currentIndex].TokenId;
                items[i].OffersAddress = OffersDetail[_nftAddress][_tokenId][currentIndex].OffersAddress;
                items[i].Offeramount =  OffersDetail[_nftAddress][_tokenId][currentIndex].Offeramount;
                items[i].StartDate =  OffersDetail[_nftAddress][_tokenId][currentIndex].StartDate;
                items[i].EndDate =  OffersDetail[_nftAddress][_tokenId][currentIndex].EndDate;
                items[i].isWinner =  OffersDetail[_nftAddress][_tokenId][currentIndex].isWinner;
                items[i].isReturn =  OffersDetail[_nftAddress][_tokenId][currentIndex].isReturn;
                items[i].NFTType =  OffersDetail[_nftAddress][_tokenId][currentIndex].NFTType;
                items[i].TokenAddress =  OffersDetail[_nftAddress][_tokenId][currentIndex].TokenAddress;
                items[i].TokenName =  OffersDetail[_nftAddress][_tokenId][currentIndex].TokenName;
                
             
        }
        return items;
    }
    function GetUserActiveOffers( ) public view returns(OfferByUser[] memory) {
           uint256 count=totalUserOffer[msg.sender];
           OfferByUser[] memory items = new OfferByUser[](count);
         uint256 currentIndex=0;
         for (uint256 i = 0; i < count; i++) 
         {
            currentIndex ++;
            if(allOfferByUser[msg.sender][currentIndex].isReturn==false)
            {
                items[i].OfferId = allOfferByUser[msg.sender][currentIndex].OfferId;
                items[i].NFTAddress = allOfferByUser[msg.sender][currentIndex].NFTAddress;
                items[i].TokenId =  allOfferByUser[msg.sender][currentIndex].TokenId;
                items[i].Offeramount =  allOfferByUser[msg.sender][currentIndex].Offeramount;
                items[i].StartDate =  allOfferByUser[msg.sender][currentIndex].StartDate;
                items[i].EndDate =  allOfferByUser[msg.sender][currentIndex].EndDate;
                items[i].isWinner =  allOfferByUser[msg.sender][currentIndex].isWinner;
                items[i].isReturn =  allOfferByUser[msg.sender][currentIndex].isReturn;
                items[i].NFTType =  allOfferByUser[msg.sender][currentIndex].NFTType;
                items[i].TokenAddress =  allOfferByUser[msg.sender][currentIndex].TokenAddress;
                items[i].TokenName =  allOfferByUser[msg.sender][currentIndex].TokenName;
             }
         }
        return items;
    }
  function GetUserUnActiveOffers( ) public view returns(OfferByUser[] memory) {
           uint256 count=totalUserOffer[msg.sender];
           OfferByUser[] memory items = new OfferByUser[](count);
         uint256 currentIndex=0;
         for (uint256 i = 0; i < count; i++) 
         {
            currentIndex ++;
            if(allOfferByUser[msg.sender][currentIndex].isReturn==true)
            {
                items[i].OfferId = allOfferByUser[msg.sender][currentIndex].OfferId;
                items[i].NFTAddress = allOfferByUser[msg.sender][currentIndex].NFTAddress;
                items[i].TokenId =  allOfferByUser[msg.sender][currentIndex].TokenId;
                items[i].Offeramount =  allOfferByUser[msg.sender][currentIndex].Offeramount;
                items[i].StartDate =  allOfferByUser[msg.sender][currentIndex].StartDate;
                items[i].EndDate =  allOfferByUser[msg.sender][currentIndex].EndDate;
                items[i].isWinner =  allOfferByUser[msg.sender][currentIndex].isWinner;
                items[i].isReturn =  allOfferByUser[msg.sender][currentIndex].isReturn;
                items[i].NFTType =  allOfferByUser[msg.sender][currentIndex].NFTType;
                items[i].TokenAddress =  allOfferByUser[msg.sender][currentIndex].TokenAddress;
                items[i].TokenName =  allOfferByUser[msg.sender][currentIndex].TokenName;
             }
         }
        return items;
    }
    
   
    function acceptOffer(address _nftAddress ,uint256 _tokenId, uint256 _offerId) public payable  returns (bool) {
      if(OffersDetail[_nftAddress][_tokenId][_offerId].NFTType.upper().compareTo("SINGLE")){
           nftContract = IERC721(_nftAddress);
           require(nftContract.ownerOf(_tokenId) == msg.sender, "ERC721: caller is not the owner");
      }else{          
           nftContract1155 = IERC1155(_nftAddress);
           require(nftContract1155.balanceOf(msg.sender, _tokenId) > 0, "ERC721: caller is not the owner");
      }
       
       uint256 royaltyFeeAmount = 0;
       uint256 merchantFeeAmount = 0;
       uint256 price = OffersDetail[_nftAddress][_tokenId][_offerId].Offeramount; 
       string memory tokenName = OffersDetail[_nftAddress][_tokenId][_offerId].TokenName;

      if( OffersDetail[_nftAddress][_tokenId][_offerId].isWinner==false)
      {
        OffersDetail[_nftAddress][_tokenId][_offerId].isWinner=true;
        OffersDetail[_nftAddress][_tokenId][_offerId].isReturn=true;
        AcceptActiveOffers(_nftAddress,_tokenId,_offerId);
        tokenContract = IERC20(OffersDetail[_nftAddress][_tokenId][_offerId].TokenAddress);

        

        if(tokenName.upper().compareTo("BNB")) {            
        if( OffersDetail[_nftAddress][_tokenId][_offerId].NFTType.upper().compareTo("SINGLE")){               
            try nftContract.royaltyInfo(_tokenId, price) returns (address creator, uint256 royaltyFee) {
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
             try nftContract.merchantRoyaltyInfo(_tokenId, price) returns (address merchant, uint256 merchantFee) {
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
        }
            uint256 actualPrice = price - royaltyFeeAmount - merchantFeeAmount;
        

            payable(msg.sender).transfer(actualPrice);
        }  
        else {
            if( OffersDetail[_nftAddress][_tokenId][_offerId].NFTType.upper().compareTo("SINGLE")){
                 try nftContract.royaltyInfo(_tokenId, price) returns (address creator, uint256 royaltyFee) {
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
            try nftContract.merchantRoyaltyInfo(_tokenId, price) returns (address merchant, uint256 merchantFee) {
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
            }
            uint256 actualPrice = price - royaltyFeeAmount-merchantFeeAmount;
           
            tokenContract.transfer(msg.sender, actualPrice);
        }         

        if( OffersDetail[_nftAddress][_tokenId][_offerId].NFTType.upper().compareTo("SINGLE")){
            nftContract.safeTransferFrom(msg.sender, OffersDetail[_nftAddress][_tokenId][_offerId].OffersAddress, _tokenId);
        }
        else{
            nftContract1155.safeTransferFrom(msg.sender, OffersDetail[_nftAddress][_tokenId][_offerId].OffersAddress, _tokenId,1,"");
        }
      }
      return true;
    }

    function withdrawalOffer(address _nftAddress ,uint256 _tokenId, uint256 _offerId) public payable returns (bool) {
      
         require(msg.sender == OffersDetail[_nftAddress][_tokenId][_offerId].OffersAddress, "Only user can withdrawal offer.");
      bool sucess=false;
      if(OffersDetail[_nftAddress][_tokenId][_offerId].isReturn==false)
      {
         
       OffersDetail[_nftAddress][_tokenId][_offerId].isReturn=true;
        UnActiveOffers(_nftAddress,_tokenId,_offerId);
        if(OffersDetail[_nftAddress][_tokenId][_offerId].TokenName.upper().compareTo("BNB")) { 
                    payable(msg.sender).transfer(OffersDetail[_nftAddress][_tokenId][_offerId].Offeramount); 
         }else{
                   tokenContract = IERC20(OffersDetail[_nftAddress][_tokenId][_offerId].TokenAddress);
                   tokenContract.transfer( OffersDetail[_nftAddress][_tokenId][_offerId].OffersAddress,  OffersDetail[_nftAddress][_tokenId][_offerId].Offeramount);
        }
       
        sucess=true;
      }
      return sucess;
    }
    function UnActiveOffers(address _nftAddress ,uint256 _tokenId, uint256 _offerId) private {
           uint256 count=totalUserOffer[msg.sender];
         uint256 currentIndex=0;
         for (uint256 i = 0; i < count; i++) 
         {
            currentIndex ++;
            
            if(allOfferByUser[msg.sender][currentIndex].isReturn==false && allOfferByUser[msg.sender][currentIndex].NFTAddress==_nftAddress &&
            allOfferByUser[msg.sender][currentIndex].TokenId ==_tokenId && allOfferByUser[msg.sender][currentIndex].OfferId==_offerId)
            {
                allOfferByUser[msg.sender][currentIndex].isReturn=true;
               
             }
         }
       
    }
      function AcceptActiveOffers(address _nftAddress ,uint256 _tokenId, uint256 _offerId) private {
           uint256 count=totalUserOffer[msg.sender];
         uint256 currentIndex=0;
         for (uint256 i = 0; i < count; i++) 
         {
            currentIndex ++;
            
            if(allOfferByUser[msg.sender][currentIndex].isWinner==false && allOfferByUser[msg.sender][currentIndex].NFTAddress==_nftAddress &&
            allOfferByUser[msg.sender][currentIndex].TokenId ==_tokenId && allOfferByUser[msg.sender][currentIndex].OfferId==_offerId)
            {
                allOfferByUser[msg.sender][currentIndex].isReturn=true;
                 allOfferByUser[msg.sender][currentIndex].isWinner=true;
               
             }
         }
       
    }
   
}