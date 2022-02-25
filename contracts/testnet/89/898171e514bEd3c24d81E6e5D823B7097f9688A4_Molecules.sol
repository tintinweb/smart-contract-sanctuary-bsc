// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721Metadata.sol";

contract Molecules is ERC721Metadata {
  using Address for address;
  using Strings for uint256;

  // EVENTS
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );

  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );

  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  event Generated(uint256 indexed index, address indexed a, string value);

  event NameChanged (uint256 indexed pepeIndex, string newName);

  event NftBought(address _seller, address _buyer, uint256 _price);

  mapping(uint256 => address)   internal idToOwner;
  mapping(address => uint256[]) internal ownerToIds;
  mapping(uint256 => uint256)   internal idToOwnerIndex;
  mapping(address => mapping(address => bool)) internal ownerToOperators;
  mapping(uint256 => address)   internal idToApproval;

  mapping(uint256 => string)  internal idToSmiles;
  mapping(uint256 => uint256) internal hashToId;

  // Mapping from token ID to name
  mapping (uint256 => string) private _tokenName;

  // Mapping if certain name string has already been reserved
  mapping (string => bool) private _nameReserved;

  // Mapping from token ID to price 
  mapping (uint256 => uint256) private _tokenPrice;

  uint256 internal numTokens = 0;
  uint256 public constant TOKEN_LIMIT = 4096;
  bool public hasSaleStarted = false;
  uint256 public constant NAME_CHANGE_PRICE = 0.1 * (10 ** 18); // 0.1 BNB

  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

  modifier validNFToken(uint256 tokenId) {
    require(
      idToOwner[tokenId] != address(0),
      "ERC721: query for nonexistent token"
    );
    _;
  }

  modifier canOperate(uint256 tokenId) {
    address owner = idToOwner[tokenId];

    require(
      owner == _msgSender() || ownerToOperators[owner][_msgSender()],
      "ERC721: approve caller is not owner nor approved for all"
    );
    _;
  }

  modifier canTransfer(uint256 tokenId) {
    address tokenOwner = idToOwner[tokenId];

    require(
      tokenOwner == _msgSender() ||
        idToApproval[tokenId] == _msgSender() ||
        ownerToOperators[tokenOwner][_msgSender()],
      "ERC721: transfer caller is not owner nor approved"
    );
    _;
  }

  constructor() {
    _registerInterface(_INTERFACE_ID_ERC721);
    _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
  }

  function createMolecule(string memory smiles) external payable returns (string memory) {
    return _mint(_msgSender(), smiles);
  }

  function calculatePrice() internal view returns (uint256) {
    uint256 price;
    if (numTokens < 512) {
      price = 250000000000000000;
    } else if (numTokens >= 512 && numTokens < 1024) {
      price = 500000000000000000;
    } else if (numTokens >= 1024 && numTokens < 2048) {
      price = 750000000000000000;
    } else if (numTokens >= 2048 && numTokens < 3072) {
      price = 1500000000000000000;
    } else {
      price = 3000000000000000000;
    }
    return price;
  }

  function _mint(address to, string memory smiles) internal returns (string memory) {
    require(hasSaleStarted == true, "Sale hasn't started");
    require(to != address(0), "ERC721: mint to the zero address");
    require(
      numTokens < TOKEN_LIMIT,
      "ERC721: maximum number of tokens already minted"
    );
    require(msg.value >= calculatePrice(), "ERC721: insufficient ether");
    // todo проверить длину строки smiles

    uint256 hash = uint256(
      // keccak256(abi.encodePacked(_seed, block.timestamp, msg.sender, numTokens))
      keccak256(abi.encodePacked(smiles))
    );

    require(hashToId[hash] == 0, "ERC721: smiles already used");

    uint256 id = numTokens + 1;

    hashToId[hash] = id;

    numTokens = numTokens + 1;
    _registerToken(to, id, smiles);

    emit Generated(id, to, smiles);
    emit Transfer(address(0), to, id);

    return smiles;
  }

  function _registerToken(address to, uint256 tokenId, string memory smiles) internal {
    require(idToOwner[tokenId] == address(0));
    idToOwner[tokenId] = to;

    ownerToIds[to].push(tokenId);
    uint256 length = ownerToIds[to].length;
    idToOwnerIndex[tokenId] = length - 1;

    idToSmiles[tokenId] = smiles;

    _tokenPrice[tokenId] = 0;
  }

  function getSmiles(uint256 tokenId)
    external
    view
    validNFToken(tokenId)
    returns (string memory)
  {
    return idToSmiles[tokenId];
  }


  function totalSupply() public view returns (uint256) {
    return numTokens;
  }

  function tokenByIndex(uint256 index) public view returns (uint256) {
    require(index < numTokens, "ERC721Enumerable: global index out of bounds");
    return index;
  }

  function tokenOfOwnerByIndex(address owner, uint256 _index)
    external
    view
    returns (uint256)
  {
    require(
      _index < ownerToIds[owner].length,
      "ERC721Enumerable: owner index out of bounds"
    );
    return ownerToIds[owner][_index];
  }

  function balanceOf(address owner) external view returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return ownerToIds[owner].length;
  }

  function ownerOf(uint256 tokenId) external view returns (address) {
    return _ownerOf(tokenId);
  }

  function _ownerOf(uint256 tokenId)
    internal
    view
    validNFToken(tokenId)
    returns (address)
  {
    address owner = idToOwner[tokenId];
    require(owner != address(0), "ERC721: query for nonexistent token");
    return owner;
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external validNFToken(tokenId) canTransfer(tokenId) {
    address tokenOwner = idToOwner[tokenId];
    require(tokenOwner == from, "ERC721: transfer of token that is not own");
    require(to != address(0), "ERC721: transfer to the zero address");
    _transfer(to, tokenId);
  }

  function _transfer(address to, uint256 tokenId) internal {
    address from = idToOwner[tokenId];
    _clearApproval(tokenId);
    emit Approval(from, to, tokenId);

    _removeNFToken(from, tokenId);
    string memory smiles = idToSmiles[tokenId];
    _registerToken(to, tokenId, smiles);

    emit Transfer(from, to, tokenId);
  }

  function _removeNFToken(address from, uint256 tokenId) internal {
    require(idToOwner[tokenId] == from);
    delete idToOwner[tokenId];

    uint256 tokenToRemoveIndex = idToOwnerIndex[tokenId];
    uint256 lastTokenIndex = ownerToIds[from].length - 1;

    if (lastTokenIndex != tokenToRemoveIndex) {
      uint256 lastToken = ownerToIds[from][lastTokenIndex];
      ownerToIds[from][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    ownerToIds[from].pop();
  }

  function approve(address approved, uint256 tokenId)
    external
    validNFToken(tokenId)
    canOperate(tokenId)
  {
    address owner = idToOwner[tokenId];
    require(approved != owner, "ERC721: approval to current owner");
    idToApproval[tokenId] = approved;
    emit Approval(owner, approved, tokenId);
  }

  function _clearApproval(uint256 tokenId) private {
    if (idToApproval[tokenId] != address(0)) {
      delete idToApproval[tokenId];
    }
  }

  function getApproved(uint256 tokenId)
    external
    view
    validNFToken(tokenId)
    returns (address)
  {
    return idToApproval[tokenId];
  }

  function setApprovalForAll(address operator, bool approved) external {
    require(operator != _msgSender(), "ERC721: approve to caller");
    ownerToOperators[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }

  function isApprovedForAll(address owner, address operator)
    external
    view
    returns (bool)
  {
    return ownerToOperators[owner][operator];
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external {
    _safeTransferFrom(from, to, tokenId, data);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external {
    _safeTransferFrom(from, to, tokenId, "");
  }

  function _safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) private validNFToken(tokenId) canTransfer(tokenId) {
    address tokenOwner = idToOwner[tokenId];
    require(tokenOwner == from, "ERC721: transfer of token that is not own");
    require(to != address(0), "ERC721: transfer to the zero address");

    _transfer(to, tokenId);
    require(
      _checkOnERC721Received(from, to, tokenId, data),
      "ERC721: transfer to non ERC721Receiver implementer"
    );
  }

  function tokenURI(uint256 tokenId)
    external
    view
    validNFToken(tokenId)
    returns (string memory)
  {
    string memory uri = _baseURI();
    return
      bytes(uri).length > 0
        ? string(abi.encodePacked(uri, "molecules/", tokenId.toString()))
        : "";
  }

  function startSale() public onlyOwner {
    hasSaleStarted = true;
  }

  function pauseSale() public onlyOwner {
    hasSaleStarted = false;
  }

  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) private returns (bool) {
    if (to.isContract()) {
      try
        IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data)
      returns (bytes4 retval) {
        return retval == IERC721Receiver(to).onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }

  /**
   * @dev Returns name of the NFT at ID.
   */
  function tokenNameById(uint256 tokenId) public view returns (string memory) {
      return _tokenName[tokenId];
  }

   /**
   * @dev Changes the name for molecules by tokenId
   */
  function changeName(uint256 tokenId, string memory newName) public payable {
      address owner = _ownerOf(tokenId);

      require(_msgSender() == owner, "ERC721: caller is not the owner");
      require(validateName(newName) == true, "Not a valid new name");
      require(sha256(bytes(newName)) != sha256(bytes(_tokenName[tokenId])), "New name is same as the current one");
      require(isNameReserved(newName) == false, "Name already reserved");
      require(NAME_CHANGE_PRICE == msg.value, "ETH value sent is not correct");


      // If already named, dereserve old name
      if (bytes(_tokenName[tokenId]).length > 0) {
          toggleReserveName(_tokenName[tokenId], false);
      }
      toggleReserveName(newName, true);
      _tokenName[tokenId] = newName;
      emit NameChanged(tokenId, newName);
  }

  /**
   * @dev Returns if the name has been reserved.
   */
  function isNameReserved(string memory nameString) public view returns (bool) {
      return _nameReserved[toLower(nameString)];
  }

  /**
   * @dev Reserves the name if isReserve is set to true, de-reserves if set to false
   */
  function toggleReserveName(string memory str, bool isReserve) internal {
      _nameReserved[toLower(str)] = isReserve;
  }

  /**
   * @dev Check if the name string is valid (Alphanumeric and spaces without leading or trailing space)
   */
  function validateName(string memory str) public pure returns (bool){
      bytes memory b = bytes(str);
      if(b.length < 1) return false;
      if(b.length > 25) return false; // Cannot be longer than 25 characters
      if(b[0] == 0x20) return false; // Leading space
      if (b[b.length - 1] == 0x20) return false; // Trailing space

      bytes1 lastChar = b[0];

      for(uint i; i<b.length; i++){
          bytes1 char = b[i];

          if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

          if(
              !(char >= 0x30 && char <= 0x39) && //9-0
              !(char >= 0x41 && char <= 0x5A) && //A-Z
              !(char >= 0x61 && char <= 0x7A) && //a-z
              !(char == 0x20) && // space
              !(char == 0x2D)    // "-"
          )
              return false;

          lastChar = char;
      }

      return true;
  }

  /**
   * @dev Converts the string to lowercase
   */
  function toLower(string memory str) public pure returns (string memory){
      bytes memory bStr = bytes(str);
      bytes memory bLower = new bytes(bStr.length);
      for (uint i = 0; i < bStr.length; i++) {
          // Uppercase character
          if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
              bLower[i] = bytes1(uint8(bStr[i]) + 32);
          } else {
              bLower[i] = bStr[i];
          }
      }
      return string(bLower);
  }

  // ===========================================================================
  function allowBuy(uint256 tokenId, uint256 _price) external {
      require(msg.sender == _ownerOf(tokenId), 'Not owner of this token');
      require(_price > 0, 'The price must be non zero');
      _tokenPrice[tokenId] = _price;
  }

  function disallowBuy(uint256 tokenId) external {
      require(msg.sender == _ownerOf(tokenId), 'Not owner of this token');
      _tokenPrice[tokenId] = 0;
  }

  // function disallowBuyForAll() onlyOwner public  {
  //     uint total = totalSupply();
  //     for (uint tokenId = 0; tokenId < total; tokenId++) {
  //         _tokenPrice[tokenId] = 0;
  //     }
  // }
  
  function buy(uint256 tokenId) external payable {
      uint256 price = _tokenPrice[tokenId];
      require(price > 0, 'This token is not for sale');
      require(msg.value == price, 'Incorrect value');
      require(msg.sender != _ownerOf(tokenId), 'impossible buy own token');
      
      address seller = _ownerOf(tokenId);
      // _transfer(seller, msg.sender, tokenId);
      _transfer(msg.sender, tokenId);
      _tokenPrice[tokenId] = 0; // not for sale anymore
      payable(seller).transfer(msg.value); // send the BNB to the seller

      emit NftBought(seller, msg.sender, msg.value);
  }

  function tokenPriceById(uint256 tokenId) public view returns (uint256) {
      return _tokenPrice[tokenId];
  }
  // ===========================================================================

  /**
   * @dev Withdraw BNB from this contract (Callable by owner)
  */
  function withdraw() onlyOwner public {
      uint balance = address(this).balance;
      payable(msg.sender).transfer(balance);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC165.sol";

contract ERC721Metadata is Ownable, ERC165 {
  /*
  *     bytes4(keccak256('name()')) == 0x06fdde03
  *     bytes4(keccak256('symbol()')) == 0x95d89b41
  *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
  *
  *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
  */
  bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
  string private _baseTokenURI;
  string private _NFTName = "Molecules";
  string private _NFTSymbol = "H2O";

  constructor() {
    _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    _baseTokenURI = "https://nft-h2o.com/";
  }

  function name() external view returns (string memory) {
    return _NFTName;
  }

  function symbol() external view returns (string memory) {
    return _NFTSymbol;
  }

  function setBaseURI(string calldata newBaseTokenURI) public onlyOwner {
    _baseTokenURI = newBaseTokenURI;
  }

  function baseURI() public view returns (string memory) {
    return _baseURI();
  }

  function _baseURI() internal view returns (string memory) {
    return _baseTokenURI;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC165 {
  mapping(bytes4 => bool) private _supportedInterfaces;

  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

  constructor() {
    _registerInterface(_INTERFACE_ID_ERC165);
  }

  function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    return _supportedInterfaces[interfaceId];
  }

  function _registerInterface(bytes4 interfaceId) internal {
    require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
    _supportedInterfaces[interfaceId] = true;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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