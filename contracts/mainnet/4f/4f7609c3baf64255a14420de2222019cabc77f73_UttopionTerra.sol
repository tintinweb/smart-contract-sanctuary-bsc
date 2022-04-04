// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Counters.sol";
import "./AccessControl.sol";
import "./IERC2981.sol";
import "./ERC721Enumerable.sol";

contract UttopionTerra is AccessControl, ERC721Enumerable, IERC2981 {
    using Strings for uint256;
    using Counters for Counters.Counter;

    struct Metadata {
        int112 x_coordinate;
        int112 y_coordinate;
        uint256 id;
        string community;
        string locally;
        string url;
    }

    struct SimpleMetadata {
        bool hasValue;
        uint256 id;
        string url;
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant DEFAULT_ROYALTY = 1; // 1%

    address public creator;
    uint256 public royalty;

    mapping(address => bool) public blacklist;

    Counters.Counter internal _tokenIdTracker;
    mapping(uint256 => Metadata) public metadata;
    mapping(string => bool) public registeredUrls;

    event SetCreator(address indexed sender, address indexed creator);
    event SetRoyalty(address indexed sender, uint256 indexed royalty);
    event AddAddressToBlacklist(address indexed sender,address indexed account);
    event RemoveAddressToBlacklist(address indexed sender,address indexed account);

    constructor(string memory name, string memory symbol, address _creator) ERC721(name, symbol) {
        require(bytes(name).length > 0, 'Name is required');
        require(bytes(symbol).length > 0, 'Symbol is required');
        require(_creator != address(0), 'Creator address cannot be zero');
        
        if(_creator != msg.sender) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(MINTER_ROLE, msg.sender);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, _creator);
        _grantRole(MINTER_ROLE, _creator);

        creator = _creator;

        royalty = DEFAULT_ROYALTY;
    }

    function mint(Metadata memory _metadata) public onlyRole(MINTER_ROLE) returns(uint256 _tokenID) {
        _tokenID = _tokenIdTracker.current();
        require(_tokenID == _metadata.id, 'Incorrect tokenId');
        require(!registeredUrls[_metadata.url], 'URL already registered');
        _tokenIdTracker.increment();

        _mint(msg.sender, _tokenID);

        _setMetadata(_tokenID, _metadata);

        return _tokenID;
    }

    function mintMasive(Metadata[] memory list) external onlyRole(MINTER_ROLE) returns(uint256 _tokenID) {

        for(uint8 i = 0; i < list.length; i++) _tokenID = mint(list[i]);
    }

    function setRoyalty(uint256 _royalty) onlyRole(DEFAULT_ADMIN_ROLE) external {
        royalty = _royalty;
        emit SetRoyalty(msg.sender, _royalty);
    }

    function setCreator(address _creator) onlyRole(DEFAULT_ADMIN_ROLE) external {
        creator = _creator;
        emit SetCreator(msg.sender, _creator);
    }

    function addAddressToBlacklist(address _account) onlyRole(DEFAULT_ADMIN_ROLE) external {
        blacklist[_account] = true;
        emit AddAddressToBlacklist(msg.sender, _account);
    }

    function removeAddressToBlacklist(address _account) onlyRole(DEFAULT_ADMIN_ROLE) external {
        blacklist[_account] = false;
        emit RemoveAddressToBlacklist(msg.sender, _account);
    }

    function tokenURI(uint256 _tokenID) public view virtual override returns (string memory) {
        require(_exists(_tokenID), "ERC721Metadata: URI query for nonexistent token");

        return metadata[_tokenID].url;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual 
        override(AccessControl, ERC721Enumerable, IERC165) returns (bool) {

        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override
        returns (address receiver, uint256 royaltyAmount) {

        receiver = creator;
        royaltyAmount = (_salePrice * royalty) / 100;
        _tokenId;
    }

    function allTokens(address _owner) external view returns(SimpleMetadata[] memory) {

        return allTokensByBounds(_owner, 0, totalSupply());
    }

    function allTokensByBounds(address _owner, uint256 _start, uint _end) public view returns(SimpleMetadata[] memory) {

        uint256 counter = 0;

        SimpleMetadata[] memory _allTokens = new SimpleMetadata[](_end - _start);

        for(uint256 i = _start; i < _end; i++){
            if(ownerOf(i) == _owner) {
                _allTokens[counter] = SimpleMetadata(true,i, metadata[i].url);
                counter++;
            }
        }

        return _allTokens;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        require(!blacklist[to], 'Blacklisted address');
        super.approve(to, tokenId);
    }

    function _setMetadata(uint256 tokenId, Metadata memory _metadata) internal virtual {
        metadata[tokenId] = _metadata;
        registeredUrls[_metadata.url] = true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        require(!blacklist[to], 'Blacklisted address');
        super._beforeTokenTransfer(from, to, tokenId);
    }
}