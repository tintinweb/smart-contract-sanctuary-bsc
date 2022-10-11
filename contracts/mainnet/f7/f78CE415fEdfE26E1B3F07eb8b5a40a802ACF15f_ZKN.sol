/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

abstract contract BEP721Receiver {
    // return byte4 when BEP721 token received
    function onBEP721Received(address operator, address from, uint256 tokenId, bytes calldata data) external virtual returns (bytes4);
}

contract ZKN {

    // admin addresses
    address admin;

    // assets and tokens count
    uint256 _assetsCount;
    uint256 _tokensCount;

    // featured and user generated assets
    uint256[] _featuredAssets;
    uint256[] _usergenAssets;

    // asset structure
    struct _asset {
        string name;
        string symbol;
        string summary;
        string description;
        string[] pairs;
        uint256 issued;
        address creator;
        uint256 status;
    }
    mapping(uint => _asset) _assets;

    // nft name
    string private _name = "ZAKAX NFTs";

    // nft symbol
    string private _symbol = "ZKN";

    // _owner balance
    mapping(address => uint256) private _ownerTokens;

    // map _tokenId to _owner
    mapping(uint256 => address) private _tokenOwner;

    // map _tokenId to _tokenURI
    mapping(uint256 => string) private _tokenURI;

    // map _tokenId to _approved
    mapping(uint256 => address) private _tokenApprovals;

    // map _owner to _operator approvals for all
    mapping(address => mapping(address => bool)) private _allTokenApprovals;

    // bytes4 for token received by contract
    bytes4 private _BEP721_RECEIVED = bytes4(keccak256("onBEP721Received(address,address,uint256,bytes)"));

    constructor() {
        admin = msg.sender;
        _assetsCount = 0;
        _tokensCount = 0;
    }

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // returns number of assets
    function getNumAssets() public view returns(uint) {
        return _assetsCount;
    }
    
    // returns featured assets
    function getFeaturedAssets() public view returns(uint[] memory) {
        return _featuredAssets;
    }
    
    // returns user generated assets
    function getUsergenAssets() public view returns(uint[] memory) {
        return _usergenAssets;
    }
    
    // returns asset info
    function getAsset(uint256 index) public view returns(string memory nm, string memory symb, string memory summ, string memory desc, string[] memory pairs, uint issued, address creator, uint stat) {
        nm = _assets[index].name;
        symb = _assets[index].symbol;
        summ = _assets[index].summary;
        desc = _assets[index].description;
        pairs = _assets[index].pairs;
        issued = _assets[index].issued;
        creator = _assets[index].creator;
        stat = _assets[index].status;
    }

    // returns token collection name
    function name() external view returns (string memory) {
        return _name;
    }

    // returns token collection symbol
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    // returns the _tokensCount
    function tokensCount() external view returns (uint256) {
        return _tokensCount;
    }

    // returns number of all _owner's tokens
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "Balance of zero address");

        return _ownerTokens[owner];
    }

    // returns the owner of _tokenId
    function ownerOf(uint256 tokenId) external view returns (address) {
        return _tokenOwner[tokenId];
    }

    // returns the _tokenURI of _tokenId
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return _tokenURI[tokenId];
    }

    // add a new asset
    function addAsset(string memory nm, string memory symb, string memory summ, string memory desc, string[] memory pairs, address creator) public {
        require(msg.sender == admin, "Not admin");
        
        _assetsCount++;
        uint index = _assetsCount;
        _assets[index] = _asset(nm, symb, summ, desc, pairs, 0, creator, 1);
        
        if(creator == admin) {
            _featuredAssets.push(index);
        } else {
            _usergenAssets.push(index);
        }
    }

    // update status of asset (1 = active / 0 = inactive)
    function updateAssetStatus(uint asset, uint status) public {
        require(msg.sender == admin, "Not admin");

        _assets[asset].status = status;
    }

    // safely transfer _tokenId from _from to _to and emit Transfer event
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        _safeTransfer(from, to, tokenId, data);
    }

    // safely transfer _tokenId from _from to _to and emit Transfer event
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        _safeTransfer(from, to, tokenId, "");
    }

    // transfer _tokenId from _from to _to and emit Transfer event
    function transferFrom(address from, address to, uint256 tokenId) external {
        _transfer(from, to, tokenId);
    }

    // approve _approved form _tokenId and emit Approval event
    function approve(address approved, uint256 tokenId) external {
        if(_tokenOwner[tokenId] != msg.sender || _allTokenApprovals[_tokenOwner[tokenId]][msg.sender] != true) {
            revert("Transfer of non-owned/approved token");
        }

        require(approved != _tokenOwner[tokenId], "Approving to owner address");
        require(approved != address(0), "Approving to zero address");

        _tokenApprovals[tokenId] = approved;
        emit Approval(_tokenOwner[tokenId], approved, tokenId);
    }

    // approve/disapprove _operator for all msg.sender assets and emit ApproveForAll event
    function setApprovalForAll(address operator, bool approved) external {
        require(operator != address(0), "Approving zero address");

        _allTokenApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // return approved for _tokenId
    function getApproved(uint256 tokenId) external view returns (address) {
        return _tokenApprovals[tokenId];
    }

    // return true/false if _operator approved for all _owner's assets
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _allTokenApprovals[owner][operator];
    }

    // safe transfer function
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnBEP721Received(from, to, tokenId, data), "Transfer to non BEP721Receiver implementer");
    }

    // transfer function
    function _transfer(address from, address to, uint256 tokenId) internal {
        if(
            _tokenOwner[tokenId] != from ||
            _tokenApprovals[tokenId] != from ||
            _allTokenApprovals[_tokenOwner[tokenId]][msg.sender] != true
        ) {
            revert("Transfer of non-owned/approved token");
        }

        require(to != address(0), "Transfer to zero address");

        _tokenApprovals[tokenId] = address(0);
        _tokenOwner[tokenId] = to;
        _ownerTokens[from] = _ownerTokens[from] - 1;
        _ownerTokens[to] = _ownerTokens[to] + 1;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnBEP721Received(address from, address to, uint256 tokenId, bytes memory data) internal returns (bool) {
        if (_isContract(to)) {
            BEP721Receiver receiver = BEP721Receiver(to);
            bytes4 retval = receiver.onBEP721Received(msg.sender, from, tokenId, data);

            return (retval == _BEP721_RECEIVED);
        } else {
            return true;
        }
    }

    function _isContract(address addr) internal view returns(bool) {
        uint size;

        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // mint function
    function mint(address to, uint256 tokenId, uint256 asset, uint256 units, string memory uri) external {
        require(msg.sender == admin, "Not admin");
        require(to != address(0), "Minting to zero address");

        _tokenOwner[tokenId] = to;
        _tokenURI[tokenId] = uri;
        _ownerTokens[to] = _ownerTokens[to] + 1;
        _tokensCount = _tokensCount + 1;

        _assets[asset].issued = _assets[asset].issued + units;

        emit Transfer(address(0), to, tokenId);
    }

    // burn function
    function burn(uint256 tokenId, uint256 asset, uint256 units) external {
        require(msg.sender == admin, "Not admin");

        address owner = _tokenOwner[tokenId];

        _tokenOwner[tokenId] = address(0);
        _tokenApprovals[tokenId] = address(0);
        _ownerTokens[owner] = _ownerTokens[owner] - 1;

        _assets[asset].issued = _assets[asset].issued - units;

        emit Transfer(owner, address(0), tokenId);
    }

    // change admin
    function changeAdmin(address newAdmin) external {
        require(msg.sender == admin, "Not admin");

        admin = newAdmin;
    }

}