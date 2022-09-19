// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    string public name;
    string public symbol;
    uint256 public tokenCount;

    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function tokenURI(uint256 tokenID) public view returns (string memory) {
        require(ownerOf(tokenID) != address(0), "tokenID is not exist");
        return _tokenURIs[tokenID];
    }

    function mintNFT(string memory _tokenURI) public onlyOwner {
        tokenCount += 1;
        _balances[msg.sender] += 1;
        _owners[tokenCount] = msg.sender;
        _tokenURIs[tokenCount] = _tokenURI;

        emit Transfer(address(0), msg.sender, tokenCount);
    }

    function mintBulk(uint256 _amount, string memory _tokenURI)
        public
        onlyOwner
    {
        uint256 index;
        for (index = 0; index < _amount; ++index) {
            mintNFT(_tokenURI);
        }
    }

    function mintNFTTo(string memory _tokenURI, address _to) public onlyOwner {
        tokenCount += 1;
        _balances[_to] += 1;
        _owners[tokenCount] = _to;
        _tokenURIs[tokenCount] = _tokenURI;

        emit Transfer(address(0), _to, tokenCount);
    }

    function mintBulkTo(
        uint256 _amount,
        string memory _tokenURI,
        address _to
    ) public onlyOwner {
        uint256 index;
        for (index = 0; index < _amount; ++index) {
            mintNFTTo(_tokenURI, _to);
        }
    }

    function totalSupply() public view virtual returns (uint256) {
        return tokenCount;
    }

    function supportsInterface(bytes4 interfaceID)
        public
        pure
        override
        returns (bool)
    {
        return interfaceID == 0x80ac58cd || interfaceID == 0x5b5e139f;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.4;

contract ERC721 {

    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _owners;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    // return the number of NFTS of an user
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "address must not different account 0");
        return  _balances[_owner];
    }
    
    // find the owner of an NFT    
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner =  _owners[_tokenId];
        require(owner != address(0),"tokenID does not exist");
        return owner;
    }

    // enable or disable an operator    
    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] =  _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // check if an address is an operator for another address
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }

    // update an approved address for an NFT
    function approve(address _approved, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), 
                "sender is not the owner or the approved operator");
        require(owner != address(0), "owner is not exist");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    // get the approved address for an NFT
    function getApproved(uint256 _tokenId) public view returns (address) {
        require(ownerOf(_tokenId) != address(0), "tokenID is not exist");
        return _tokenApprovals[_tokenId];
    }

    // transfer ownership for an NFT
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        address owner =  ownerOf(_tokenId);
        require(
            msg.sender == owner ||
            getApproved(_tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender),
            "sender is not the owner or approved for transfer"
        );
        require(owner == _from, "from address is not the owner");
        require(_to != address(0), "address is the zero address");
        approve(address(0), _tokenId);
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] =  _to;
        emit Transfer(_from, _to, _tokenId);
    }  

    // standard transferFrom method but check if the receiver smart contract is capable of receiving NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable {
         transferFrom(_from, _to, _tokenId);
         require(_checkOnERC721Receiver(), "receiver is not implemented");
    }

    // without data for safeTransferFrom
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
         safeTransferFrom(_from, _to, _tokenId, "");        
    }

    // simple version to check for NFT receivability of a smart contract
    function _checkOnERC721Receiver() private pure returns (bool){
         return true;
    }

    // EIP165 prososal: query if a contract implements another interface
    function supportsInterface(bytes4 interfaceID) public pure virtual returns(bool) {
        return interfaceID == 0x80ac58cd;
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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