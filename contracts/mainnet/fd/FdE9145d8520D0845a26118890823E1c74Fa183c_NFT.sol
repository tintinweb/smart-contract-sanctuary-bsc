/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;


interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

contract TokenAccessControl {

    bool public paused = false;
    address public owner;
    address public newContractOwner;
    mapping(address => bool) public authorizedContracts;

    event Pause();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
    }

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier onlyContractOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAuthorizedContract {
        require(authorizedContracts[msg.sender]);
        _;
    }

    modifier onlyContractOwnerOrAuthorizedContract {
        require(authorizedContracts[msg.sender] || msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyContractOwner {
        require(_newOwner != address(0));
        newContractOwner = _newOwner;
    }

    function acceptOwnership() public ifNotPaused {
        require(msg.sender == newContractOwner);
        emit OwnershipTransferred(owner, newContractOwner);
        owner = newContractOwner;
        newContractOwner = address(0);
    }

    function setAuthorizedContract(address _buyContract, bool _approve) public onlyContractOwner {
        if (_approve) {
            authorizedContracts[_buyContract] = true;
        } else {
            delete authorizedContracts[_buyContract];
        }
    }

    function setPause(bool _paused) public onlyContractOwner {
        paused = _paused;
        if (paused) {
            emit Pause();
        }
    }

}

contract NFT is TokenAccessControl {

    string public name;
    string public symbol;
    string public baseURI;
    uint256 public totalSupply;
    mapping (uint256 => address) royaltyReceiver;
    uint8 royaltyPercentage;

    uint256[] tokens;
    mapping (uint256 => address) tokenToOwner;
    mapping (uint256 => address) tokenToApproved;
    mapping (address => uint256) ownerBalance;
    mapping (address => mapping (address => bool)) ownerToOperators;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    bytes4 constant InterfaceSignature_ERC165 = 0x01ffc9a7;
    bytes4 constant InterfaceSignature_ERC721 = 0x80ac58cd;
    bytes4 constant InterfaceSignature_ERC721Metadata = 0x5b5e139f;
    bytes4 constant InterfaceSignature_ERC2981 = 0x2a55205a;

    constructor(string memory _name, string memory _symbol, string memory _baseURI) {
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
        totalSupply = 0;
    }

    function createToken() public onlyContractOwner ifNotPaused returns (uint256) {
        totalSupply++;
        tokens.push(tokens.length+1);
        _transfer(address(0), msg.sender, tokens.length);
        return tokens.length;
    }

    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return ((_interfaceID == InterfaceSignature_ERC165) ||
                (_interfaceID == InterfaceSignature_ERC721) ||
                (_interfaceID == InterfaceSignature_ERC721Metadata) ||
                (_interfaceID == InterfaceSignature_ERC2981));
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(tokenToOwner[_tokenId]!=address(0));
        return baseURI;
    }

    function setTokenURI(string memory _baseURI) external onlyContractOwner {
        baseURI = _baseURI;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenToApproved[_tokenId] == _claimant;
    }

    function _operatorFor(address _operator, address _owner) internal view returns (bool) {
        return ownerToOperators[_owner][_operator];
    }
    
    function _canReceive(address _addr, address _sender, address _owner, uint256 _tokenId, bytes memory _data) internal returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        bool isContract = (size > 0);
        
        if (isContract) {
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_addr);
            if (receiver.onERC721Received(_sender, _owner, _tokenId, _data) != 
                bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))) {
                return false;
            }
        }
        return true;
    }
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownerBalance[_to]++;
        tokenToOwner[_tokenId] = _to;
        
        if (_from != address(0)) {
            ownerBalance[_from]--;
            delete tokenToApproved[_tokenId];
        }
        
        emit Transfer(_from, _to, _tokenId);
    }

    function balanceOf(address _owner) external view returns (uint256 count) {
        require(_owner != address(0));
        return ownerBalance[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = tokenToOwner[_tokenId];
        require(owner != address(0));
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable ifNotPaused {
        require(_owns(msg.sender, _tokenId) || 
                _approvedFor(msg.sender, _tokenId) || 
                ownerToOperators[tokenToOwner[_tokenId]][msg.sender]);  // owns, is approved or is operator
        require(_to != address(0) && _to != address(this));  // valid address
        require(tokenToOwner[_tokenId] != address(0));  // is valid NFT

        _transfer(_from, _to, _tokenId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external payable ifNotPaused {
        this.transferFrom(_from, _to, _tokenId);
        require(_canReceive(_to, msg.sender, _from, _tokenId, _data));
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable ifNotPaused {
        this.safeTransferFrom(_from, _to, _tokenId, "");
    }

    function approve(address _to, uint256 _tokenId) external payable ifNotPaused {
        require(_owns(msg.sender, _tokenId) || 
                _operatorFor(msg.sender, this.ownerOf(_tokenId)));

        tokenToApproved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function setApprovalForAll(address _to, bool _approved) external ifNotPaused {
        if (_approved) {
            ownerToOperators[msg.sender][_to] = _approved;
        } else {
            delete ownerToOperators[msg.sender][_to];
        }
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        require(tokenToOwner[_tokenId] != address(0));
        return tokenToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return ownerToOperators[_owner][_operator];
    }
    
    function setRoyalty(uint256 _tokenId, address _receiver) external onlyContractOwner {
        royaltyReceiver[_tokenId] = _receiver;
    }
    
    function setRoyaltyPercentage(uint8 _percentage) external onlyContractOwner {
        royaltyPercentage = _percentage;
    }
    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = royaltyReceiver[_tokenId];
        royaltyAmount = uint256(_salePrice * royaltyPercentage) / 100;
    }
    
    receive() external payable {
        
    }
    
    fallback() external payable {
        
    }
    
    function withdrawBalance(uint256 _amount) external onlyContractOwner {
        payable(owner).transfer(_amount);
    }
}