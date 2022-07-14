// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import './INFTDescriptor.sol';
import './SafeMath.sol';
import './SafeCast.sol';
import './String.sol';
import './Base64.sol';
import "./IERC20.sol";
import "./Member.sol";
import "./ERC721Enumerable.sol";
abstract contract FreeMetadata{
    function setTokenData(uint level, uint rare, string memory rareName, uint tokenId) external virtual;
    function burnData(uint tokenId) external virtual;
    function getTokenLevel(uint tokenId) public view virtual returns (uint);
    function getTokenRare(uint tokenId) public view virtual returns (uint);
    function getTokenRareName(uint rare) public view virtual returns (string memory);
    function getTokenName(uint tokenId) public view virtual returns (string memory);
    function getThisRareName(uint _count) external view virtual returns (string memory);
    function getThisRare(uint _count) external view virtual returns (uint);
    function getNameProbability(string memory rareName) external view virtual returns (uint);
    function getSalt(uint account) public view virtual returns (uint);
    function getMaxLevel() external view virtual returns (uint);
    function rareIsTotalRares(uint isRare) view public virtual returns (bool);
    function rareNameIsTotalNames(string memory rareName) view public virtual returns (bool);
    function setNftRare(uint256 tokenId, uint256 updateRare, uint updateType) external virtual;
}
contract FreeNft is Member, ERC721Enumerable {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using String for string;

    address private _rareAddress;

    uint256 private _rareAmount;

    FreeMetadata public immutable metadata;


    uint256 public constant NFT_SIGN_BIT = 1 << 255;
    
    address public immutable wbnb; 

    string public _DESCRIPTION;

    string private _imageBaseURI;

    address public tokenDescriptor;

    event Minted(address minter, address to,uint packageId, uint tokenId,  uint rare, uint256 logeType,string rareName);

    function setBaseUrl(string memory imageBaseURI_) external ContractOwnerOnly{
        _imageBaseURI = imageBaseURI_;
    }

    function setRareAddress(address rareAddress_, uint256 rareAmount_) external ContractOwnerOnly{
        _rareAddress = rareAddress_;
        _rareAmount = rareAmount_;
    }
  
    function getRareAddress() external view ContractOwnerOnly returns(address,uint256){
        return (_rareAddress, _rareAmount);
    }


    
    function getTokenId(uint level, uint rare, string memory rareName) internal view returns (uint){
        return NFT_SIGN_BIT |
        (uint256(uint32(level)) << 224) |
        (uint256(uint64(rare)) << 160) |
        (uint256(uint16(metadata.getNameProbability(rareName))) << 144) |
        (uint256(uint40(metadata.getSalt(totalSupply() + 1))) << 104) |
        (block.timestamp << 64) |
        (uint64(totalSupply() + 1));
    }



   
    function mintByAdmin(
        uint level, 
        uint rare, 
        string memory rareName, 
        address to
    ) external CheckPermit("NFTAdmin") returns (uint tokenId){
        require(to != address(0) && level <= metadata.getMaxLevel() && metadata.rareIsTotalRares(rare) && metadata.rareNameIsTotalNames(rareName));

        tokenId = getTokenId(level, rare, rareName);
        _mintOld(to, tokenId);
        metadata.setTokenData(level, rare, rareName, tokenId);

        emit Minted(address(0), to, tokenId, tokenId, rare, 1, rareName);
    }



    
    function mintByPackage(address to, uint packageId,uint256 rare) external CheckPermit("FreePackage") returns (uint tokenId){
        require(to != address(0), "Address cannot be zero");
        
        string memory rareName = metadata.getThisRareName(totalSupply() + 1);
       
        tokenId = getTokenId(1, rare, rareName);
        _mintOld(to, tokenId);
        metadata.setTokenData(1, rare, rareName, tokenId);
        emit Minted(address(0), to, packageId, tokenId, rare, 2, rareName);
    }


    
    function setTokenRare(uint256 tokenId) external {
        IERC20(manager.members("UnoToken")).transferFrom(
            msg.sender,
            _rareAddress,
            _rareAmount
        );
        metadata.setNftRare(tokenId,1,1);
    }

    
    
    function imageOf(uint tokenId) public view returns (string memory){

        return string(abi.encodePacked(_imageBaseURI, metadata.getTokenRareName(metadata.getTokenRare(tokenId)), "/", Strings.toString(metadata.getTokenLevel(tokenId)), "/", metadata.getTokenName(tokenId), ".png"));
        //return _imageBaseURI.concat(thisTokenRareName).concat("/").concat(thisTokenName).concat(".png");
    }

    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        if (tokenDescriptor != address(0)) {
            return INFTDescriptor(tokenDescriptor).tokenURI(address(this), tokenId);
        }

        return string(
            abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked('{"name": "', name(), ' #', Strings.toString(tokenId), '","description": "', _DESCRIPTION, '", "image": "', imageOf(tokenId), '","attributes":', string(abi.encodePacked('[{"trait_type":"Rartiy","value":"', metadata.getTokenRareName(metadata.getTokenRare(tokenId)), '"}', ',{"trait_type":"Type","value":"', metadata.getTokenName(tokenId), '"}', ',{"trait_type":"Level","value":"', Strings.toString(metadata.getTokenLevel(tokenId)), '"}]')), '}')))))
        );
    }


    
    constructor(
        string memory imageBaseURI, 
        string memory DESCRIPTION, 
        string memory name, 
        string memory symbol,
        uint256 rareAmount,
        address rareAddress,
        address _wbnb,
        address _metadata
    ) ERC721(name, symbol) {
        _DESCRIPTION = DESCRIPTION;
        _imageBaseURI = imageBaseURI;
        wbnb = _wbnb;
        _rareAmount = rareAmount;
        _rareAddress = rareAddress;
        metadata = FreeMetadata(_metadata);
    }


    
    function getAccountAllTokens(address account) external view returns (uint256[] memory){
        uint balance_ = balanceOf(account);
        uint[] memory ids = new uint[](balance_);
        if (balance_ > 0) {
            for (uint i = 0; i < balance_; i++) {
                ids[i] = tokenOfOwnerByIndex(account, i);
            }
        }
        return ids;
    }


    
    function burn(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId), "burn: caller must be owner of token");
        _burnOld(tokenId);
        metadata.burnData(tokenId);
    }


}