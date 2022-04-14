/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// SPDX-License-Identifier: MIT


// IERC20 
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

// IERC165
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// IERC721 interface
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

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

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

pragma solidity >=0.8.0;
/// ERC-721 implementation of the solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol) realized by Pablo Estevez for Ingenious Miner
/// principal diferences are: all id are mapped to a type: (from 0 to 3).
/// there are two forms of mint. transfer on of the 5 contracts that will be reemplced by this, asociating the type to that specific nft.this system could be shutdown, but not reopen, by the administrator.
/// thw second form is the owner can determine a quantity and usdt price to new mintings. 
/// @dev Note that balanceOf does not revert if passed the zero address, in defiance of the ERC.
contract Miner{
    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event LevelUp(uint _tokenId, uint _typeOfMiner);

    event MintFromOld(address oldContract, uint oldId, uint newId);

    event CouldBeMinted(uint typeOfMiner, uint number, uint price);

    /*///////////////////////////////////////////////////////////////
                          METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    string public baseURI;


    function tokenURI(uint256 tokenId) public view returns (string memory){
        require(ownerOf[tokenId]!= address(0), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
    }

    /*///////////////////////////////////////////////////////////////
                            ERC721 STORAGE                        
    //////////////////////////////////////////////////////////////*/

    // sin limite de mineros.
    // posibilidad de mintear desde el back. 
    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    // dejar libre el limite de tipo de mineros.
    mapping(uint => uint) public typeOfMiner;

    struct couldBeMinted{uint q; uint price;}

    mapping(uint=>couldBeMinted) public couldBeMintedBy;

    //mapping(uint=>uint) public blockMinted;

    uint supply = 0;

    bool public initialChange = true;

    IERC721 constant oldPrincpiante = IERC721(0x612609EB05424442Ea8a4f97D25b1e9Dfb75467c);
    IERC721 constant oldPionero1 = IERC721(0xC4481F0Ec0283B2F43becb506176e4abA53761ea);
    IERC721 constant oldPionero2 = IERC721(0xAE583D18993F927DAAAc35F3c807EBae06CB76A5);
    IERC721 constant oldPionero3 = IERC721(0x0dA713A96F9A922e504E0EAF39363B19E9d96Cf6);
    IERC721 constant oldExperto = IERC721(0x327FafFf38be56e8667D25Cc5D2665690CEDE565);
    IERC721 constant oldEmpresario = IERC721(0x1Eb285501fe9d8273483ceE081d30C1d49DB32D7);
    IERC20 constant usdt = IERC20(0x87F33c19c580079E805caDB2D3555770e0477c0e);
    bytes32 constant keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    address public administrator;
    address public levelator;
    address public minter;
    address public treasury;
    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(){
        name = "Minero Ingenious Miner";
        symbol = "MIM";
        administrator = msg.sender;
        levelator = msg.sender;
        baseURI = "api.ingeniousminer.com/miner/";
        minter = msg.sender;
        treasury = msg.sender;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        require(typeOfMiner[id]>0, "miner 0 cant be transferred");

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint _typeOfMiner) internal virtual {
        supply=supply+1;
        require(to != address(0), "INVALID_RECIPIENT");

        require(ownerOf[supply] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            balanceOf[to]++;
        }
        //blockMinted[id] = block.timestamp;
        typeOfMiner[supply]= _typeOfMiner;
        ownerOf[supply] = to;

        emit Transfer(address(0), to, supply);
    }

    
    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            balanceOf[owner]--;
        }

        delete ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id,uint  _typeOfMiner) internal virtual {
        _mint(to, _typeOfMiner);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data,
        uint _typeOfMiner
    ) internal virtual {
        _mint(to, _typeOfMiner);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    /*///////////////////////////////////////////////////////////////
                       Administrator logic
    //////////////////////////////////////////////////////////////*/

    function changeAdministrator(address newAdmin) public{
        require(msg.sender==administrator);
        administrator=newAdmin;
    }
    function changeLevelator(address newLevelator) public{
        require(msg.sender==administrator);
        levelator=newLevelator;
    }
    function changeTreasury(address newTreasury) public{
        require(msg.sender==administrator);
        treasury=newTreasury;
    }
    function changeMinter(address newMinter) public{
        require(msg.sender==administrator);
        minter=newMinter;
    }
    function stopChange() public{
        require(msg.sender==administrator);
        initialChange = false;
    }

    function newMints(uint _typeOfMiner, uint _price, uint _number) public{
        require(msg.sender==administrator);
        couldBeMintedBy[_typeOfMiner]=couldBeMinted(_number, _price);
        emit CouldBeMinted(_typeOfMiner, _number, _price);
    }
    function levelUp(uint _tokenId, uint newLevel) public{
        require(msg.sender==levelator, "must be leverator");
        typeOfMiner[_tokenId] = newLevel;
        emit LevelUp(_tokenId, newLevel);
    }

    function setBaseUri(string memory _baseUri) public{
        require(msg.sender==administrator);
        baseURI = _baseUri;
    }
    /*///////////////////////////////////////////////////////////////
                       EXTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(uint _typeOfMiner, address _to) public{
        couldBeMinted storage could = couldBeMintedBy[_typeOfMiner];
        if(msg.sender != minter && msg.sender != administrator){
            require(usdt.transferFrom(msg.sender, treasury, could.price), "require usdt");
        }
        require(could.q>0, "nothing to mint");
        could.q --;
        _mint(_to, _typeOfMiner);
    }

    function mintFromPrincipiante(uint tokenId) public{
        require(initialChange);
        oldPrincpiante.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 1);
        emit MintFromOld(address(oldPrincpiante), tokenId, supply);
    }
    function mintFromPionero1(uint tokenId) public{
        require(initialChange);
        oldPionero1.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 0);
        emit MintFromOld(address(oldPionero1), tokenId, supply);
    }
    function mintFromPionero2(uint tokenId) public{
        require(initialChange);
        oldPionero2.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 0);
        emit MintFromOld(address(oldPionero2), tokenId, supply);
    }
    function mintFromPionero3(uint tokenId) public{
        require(initialChange);
        oldPionero3.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 0);
        emit MintFromOld(address(oldPionero3), tokenId, supply);
    }
    function mintFromExperto(uint tokenId) public{
        require(initialChange);
        oldExperto.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 2);
        emit MintFromOld(address(oldExperto), tokenId, supply);
    }
    function mintFromEmpresario(uint tokenId) public{
        require(initialChange);
        oldEmpresario.transferFrom(msg.sender, address(this), tokenId);
        _mint(msg.sender, 3);
        emit MintFromOld(address(oldEmpresario), tokenId, supply);
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);
}