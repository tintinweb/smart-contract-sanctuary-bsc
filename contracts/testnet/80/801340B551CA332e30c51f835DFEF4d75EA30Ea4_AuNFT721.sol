// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC165.sol";
import "./ERC721.sol";
import "./ERC721TokenReceiver.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Metadata.sol";
import "./IAuthCenter.sol";
import "./IAuNFT721.sol";

contract AuNFT721 is ERC165, 
                     ERC721Metadata,
                     ERC721TokenReceiver,
                     ERC721Enumerable,
                     ERC721,
                     IAuNFT721 {

address private owner;
address private authCenter;

//ERC-721 Metadata Non-Fungible Token Standard, optional metadata extension
string private NFT_collection_name;
string private NFT_collection_symbol;
string private NFT_collection_URI;

//ERC-721 Non-Fungible Token Standard, optional enumeration extension
uint256 private NFTtotalSupply;

// mapping (NFT idx => token)
mapping (uint256 => T_NFT) private NFTs;

// mapping (NFT idx => owner address)
mapping (uint256 => address) private NFT_Owners;

// mapping one-time NFT approvals (granted NFT idx => spender address)
mapping(uint256 => address) spenders;

struct TBalance {
    //client's NFTs amount
    uint256 NFTsAmount;
    //client's full-granted (for NFT only) allowances
    mapping(address => bool) allowancesForAll;
}
mapping (address => TBalance) private balances;

    //------------------------------------------------------------------------------
    // Let's go
    //------------------------------------------------------------------------------
    constructor() {
        owner = msg.sender;
        NFT_collection_name = "AuCollection";
        NFT_collection_symbol = "AUG";
        NFT_collection_URI = "http://127.0.0.1";
    }

    function supportsInterface(bytes4 interfaceID) override external pure returns (bool) {
        return  interfaceID == 0x01ffc9a7 || //ERC165 support
                interfaceID == 0x80ac58cd || //ERC721 support
                interfaceID == 0x150b7a02 || //ERC721TokenReceiver support
                interfaceID == 0x5b5e139f || //ERC721Metadata support
                interfaceID == 0x780e9d63;   //ERC721Enumerable support
    }

    // @dev Only owner can change owner of contract.
    function updateOwner(address _address) override external returns (bool) {
        require(msg.sender == owner, "AuNFT721: You are not contract owner");
        owner = _address;
        emit UpdateOwner(owner);
        return true;
    }

    // @dev Link AuthCenter reference to contract
    function setAuthCenter(address _address) override external returns (bool) {
        require(msg.sender == owner, "AuNFT721: You are not contract owner");
        require(_address != address(0), "AuNFT721: authCenter is the zero address");
        authCenter = _address;
        return true;
    }

    // @dev Only owner can put ethers to contract.
    // @dev (some gas ethers may be need for a normal work of this contract).
    receive() external payable {
        require(msg.sender == owner, "AuNFT721: You are not contract owner");
    }

    // @dev Only owner can return to himself gas ethers before closing contract
    function withDrawAll() external override {
        require(msg.sender == owner, "AuNFT721: You are not contract owner");
        payable(owner).transfer(address(this).balance);
    }

    //------------------------------------------------------------------------------
    // ERC-721 Metadata Non-Fungible Token Standard, optional metadata extension
    //------------------------------------------------------------------------------
    // Returns a descriptive name for a collection of NFTs in this contract.
    function name() external override view returns (string memory _name)
    { return NFT_collection_name; }

    // Returns an abbreviated name for NFTs in this contract.
    function symbol() external override view returns (string memory _symbol)
    { return NFT_collection_symbol; }

    // Returns a distinct Uniform Resource Identifier (URI) for a given asset.
    function tokenURI(uint256 _tokenId) external override view returns (string memory)
    { return NFT_collection_URI; }

    // Set a descriptive name for a collection of NFTs in this contract.
    function setName(string memory _name) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        NFT_collection_name = _name;
    }

    // Set an abbreviated name for NFTs in this contract.
    function setSymbol(string memory _symbol) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        NFT_collection_symbol = _symbol;
    }

    // Set a distinct Uniform Resource Identifier (URI) for a given asset.
    function setTokenURI(string memory _URI) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        NFT_collection_URI = _URI;
    }

    //------------------------------------------------------------------------------
    // ERC-721 Non-Fungible Token Standard, optional enumeration extension
    //------------------------------------------------------------------------------
    /// Count NFTs tracked by this contract
    function totalSupply() external override view returns (uint256) 
    { return NFTtotalSupply; }

    /// Enumerate valid NFTs
    function tokenByIndex(uint256 _index) external override view returns (T_NFT memory)
    { return NFTs[_index]; }

    /// Enumerate NFTs assigned to an owner
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external override view returns (T_NFT memory) {
        require(_owner != address(0), "AuNFT721: Owner is the zero address");
        require(_owner == NFT_Owners[_index], "AuNFT721: Owner have not this NFT");
        return NFTs[_index];
    }

    //------------------------------------------------------------------------------
    //ERC-721 Non-Fungible Token Standard, Handle the receipt of an NFT
    //------------------------------------------------------------------------------
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external override returns(bytes4)
    { return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")); }

    //------------------------------------------------------------------------------
    // ERC-721 Non-Fungible Token Standard
    //------------------------------------------------------------------------------
    // Count all NFTs assigned to an owner
    function balanceOf(address _owner) external override view returns (uint256) 
    { return balances[_owner].NFTsAmount; }

    // Find the owner of an NFT
    function ownerOf(uint256 _tokenId) external override view returns (address) 
    { return NFT_Owners[_tokenId]; }

    // Transfers the ownership of an NFT from one address to another address
    // @dev in this contract we are never send NFT to another contract
    // so safeTransferFrom is equal transferFrom
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external override 
    { _transferFrom(_from, _to, _tokenId); }

    //Transfers the ownership of an NFT from one address to another address
    // @dev in this contract we are never send NFT to another contract
    // so safeTransferFrom is equal transferFrom    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override
    { _transferFrom(_from, _to, _tokenId); }

    // Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    //  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    //  THEY MAY BE PERMANENTLY LOST
    function transferFrom(address _from, address _to, uint256 _tokenId) external override
    { _transferFrom(_from, _to, _tokenId); }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(!IAuthCenter(authCenter).isContractPaused(), "AuNFT721: contract paused");
        require(IAuthCenter(authCenter).isClient(msg.sender), "AuNFT721: You are not our client");
        require(_from == NFT_Owners[_tokenId], "AuNFT721: From are not owner of this NFT");
        require(msg.sender == _from ||
                msg.sender == spenders[_tokenId] ||
                balances[_from].allowancesForAll[msg.sender],
                "AuNFT721: You are not granted to transfer this NFT");
        require(_to != address(0), "AuNFT721: To is the zero address");
        NFT_Owners[_tokenId] = _to;
        delete(spenders[_tokenId]);
        balances[_from].NFTsAmount--;
        balances[_to].NFTsAmount++;
        emit Transfer(_from, _to, _tokenId);
    }

    // Change or reaffirm the approved address for an NFT
    function approve(address _approved, uint256 _tokenId) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(!IAuthCenter(authCenter).isContractPaused(), "AuNFT721: contract paused");
        require(IAuthCenter(authCenter).isClient(msg.sender), "AuNFT721: You are not our client");
        require(msg.sender == NFT_Owners[_tokenId], "AuNFT721: You are not owner of this NFT");
        spenders[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    // Enable or disable approval for a third party ("operator") to manage
    //  all of `msg.sender`'s assets
    function setApprovalForAll(address _operator, bool _approved) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(!IAuthCenter(authCenter).isContractPaused(), "AuNFT721: contract paused");
        require(IAuthCenter(authCenter).isClient(msg.sender), "AuNFT721: You are not our client");
        balances[msg.sender].allowancesForAll[_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Get the approved address for a single NFT
    function getApproved(uint256 _tokenId) external override view returns (address) 
    { return spenders[_tokenId]; }

    // Query if an address is an authorized operator for another address
    function isApprovedForAll(address _owner, address _operator) external override view returns (bool)
    { return balances[_owner].allowancesForAll[_operator]; }

    //------------------------------------------------------------------------------
    // ERC-721 Metadata Non-Fungible Token Standard, optional mintable extension
    //------------------------------------------------------------------------------
    function mint(address _to, uint256 _tokenId) external override returns (bool) {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        if (NFT_Owners[_tokenId] != _to) {
            NFT_Owners[_tokenId] = _to;
            balances[_to].NFTsAmount++;
            NFTtotalSupply++;
            emit Transfer(address(0), _to, _tokenId);
        }
        return true;
    }

    //------------------------------------------------------------------------------
    // ERC-721 Metadata Non-Fungible Token Standard, optional burnable extension
    //------------------------------------------------------------------------------
    function burn(uint256 _tokenId) override external {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        address ownerNFT = NFT_Owners[_tokenId];
        delete(NFT_Owners[_tokenId]);
        delete(spenders[_tokenId]);
        if (ownerNFT != address(0))
            if (balances[ownerNFT].NFTsAmount > 0) balances[ownerNFT].NFTsAmount--;
            if (NFTtotalSupply > 0) NFTtotalSupply--;
        emit Transfer(ownerNFT, address(0), _tokenId);
    }

    function destroyNFT(uint256 _tokenId) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        delete(NFTs[_tokenId]);
        emit DestroyNFT(_tokenId);
    }

    function setNFTParams(uint256 _tokenId,
                          string memory _name,
                          string memory _description,
                          string memory _image) external override {
        require(authCenter != address(0), "AuNFT721: AuthCenter is the zero address");
        require(IAuthCenter(authCenter).isAdmin(msg.sender), "AuNFT721: You are not admin");
        NFTs[_tokenId].name = _name;
        NFTs[_tokenId].description = _description;
        NFTs[_tokenId].image = _image;
        emit SetNFTParams(_tokenId, _name, _description, _image);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAuthCenter {
    event UpdateOwner(address indexed _address);
    event AddAdmin(address indexed _address);
    event DiscardAdmin(address indexed _address);
    event FreezeAddress(address indexed _address);
    event UnFreezeAddress(address indexed _address);
    event AddClient(address indexed _address);
    event RemoveClient(address indexed _address);
    event ContractPausedState(bool value);

    function addAdmin(address _address) external returns (bool);
    function discardAdmin(address _address) external returns (bool);
    function freezeAddress(address _address) external returns (bool);
    function unfreezeAddress(address _address) external returns (bool);
    function addClient(address _address) external returns (bool);
    function removeClient(address _address) external returns (bool);
    function isClient(address _address) external view returns (bool);
    function isAdmin(address _address) external view returns (bool);
    function isAddressFrozen(address _address) external view returns (bool);
    function setContractPaused() external returns (bool);
    function setContractUnpaused() external returns (bool);
    function isContractPaused() external view returns (bool);
    function withDrawAll() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAuNFT721 {
    event UpdateOwner(address indexed _address);
    event DestroyNFT(uint256 indexed _tokenId);
    event SetNFTParams(uint256 indexed _tokenId, 
                       string indexed _name,
                       string _description,
                       string _image);

    function updateOwner(address _address) external returns (bool);
    function setAuthCenter(address _address) external returns (bool);
    function withDrawAll() external;

    //create ownership of NFT to client
    //generate Transfer event from address(0) to '_to'
    function mint(address _to, uint256 _tokenId) external returns (bool);

    //burn ownership of NFT to client and his spender
    //generate Transfer event from NFT owner to address(0)
    function burn(uint256 _tokenId) external;

    //destroy NFT description
    //this function dont touch client's ownership of this NFT (empty de facto)
    //generate DestroyNFT event
    function destroyNFT(uint256 _tokenId) external;

    //refresh (create) NFT description
    //this function dont touch client's ownership of this NFT
    //generate SetNFTParams event
    function setNFTParams(uint256 _tokenId,
                          string memory _name,
                          string memory _description,
                          string memory _image) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    //setters (only admins can set it's)
    function setName(string memory _name) external;
    function setSymbol(string memory _symbol) external;
    function setTokenURI(string memory _URI) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface ERC721Enumerable /* is ERC721 */ {
    // NFT description
    // see https://eips.ethereum.org/EIPS/eip-721 the “ERC721 Metadata JSON Schema”
    struct T_NFT {
        string name;                // Identifies the asset to which this NFT represents
        string description;         // Describes the asset to which this NFT represents
        string image;               // A URI pointing to a resource with mime type image
                                    // representing the asset to which this NFT represents.
                                    // Consider making any images at a width between 320 and 1080 pixels
                                    // and aspect ratio between 1.91:1 and 4:5 inclusive.
    }

    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// //@param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (T_NFT memory);

    /// @notice Enumerate NFTs assigned to an owner
    /// //@dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// //@param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (T_NFT memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    /// --------------
    /// @dev in our AU contract we are never send NFT to another contract
    /// so safeTransferFrom is equal transferFrom
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external; //payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// --------------
    /// @dev in our AU contract we are never send NFT to another contract
    /// so safeTransferFrom is equal transferFrom
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external; //payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external; //payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external; //payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}