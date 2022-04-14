// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Counters.sol";
import "./ERC721Pausable.sol";
import "./Applications.sol";
import "./IGoldToken.sol"; //cambiar el nombre

interface tokenGoldDetails {
    function goldWeight(uint tokenId) external view returns(uint);
    function goldPurity(uint tokenId) external view returns(uint);
}

contract Refinery is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable, Applications {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    address OracleAUG;
    address OracleMATIC;

    struct TokenDetail {
        uint creationDate;
        uint units;
        uint weight;
        bool valid;
    }
    address GOLD;

    mapping(uint=>mapping(uint=>uint)) tokenIdOwner;
    /*
    tokenId de este contrato en la posicion XXX tiene el token de gold YYY
    0=>1=>50
    0=>2=>45 
    0=>3=>99
    */
    mapping(uint=>uint) tokenCounter;
    mapping(uint=>TokenDetail) TokenDetails;
    uint private counterCollections;
    bool private safeTX=true;

    constructor( address _OracleAUG, address _OracleMATIC, address _gold) ERC721("RefineryToken", "GRT") {
        pause(true);
        counterCollections=0; // first one
        OracleAUG = _OracleAUG;
        OracleMATIC = _OracleMATIC;
        GOLD = _gold;
        IERC721(GOLD).isApprovedForAll(address(this), GOLD);
    }

    function pause(bool val) public onlyOwner {
        val ? _pause() : _unpause();
    }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }
   
    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }
   
    function convertGold(uint16[] calldata tokensIds) public {
        for (uint i = 0; i < tokensIds.length; i++) {
            //Si no se frena por error, entonces podemos seguir adelante.
            require(IERC721(GOLD).ownerOf(tokensIds[i])==msg.sender,string("Sender must be owner"));
        }
        uint nextTokenId = _totalSupply();
        uint _weight;
        for (uint x=0; x < tokensIds.length; x++) {
            IERC721(GOLD).transferFrom(msg.sender, address(this), tokensIds[x]);
            tokenIdOwner[nextTokenId][x]=tokensIds[x];
            _weight = tokenGoldDetails(GOLD).goldWeight(tokensIds[x])+_weight;
        }
        tokenCounter[nextTokenId]=tokensIds.length;
        TokenDetails[nextTokenId] = TokenDetail({
            creationDate: uint(block.timestamp),
            units: uint(tokensIds.length),
            weight: uint(_weight),
            valid: bool(true)
        });
        _tokenIdTracker.increment();
        _safeMint(msg.sender, nextTokenId);
    }

    function addMoreGold(uint16[] calldata tokensIds, uint _refineryTokenId) public {
        require(_exists(_refineryTokenId), "ERC721Metadata: nonexistent token");
        for (uint i = 0; i < tokensIds.length; i++) {
            //Si no se frena por error, entonces podemos seguir adelante.
            require(IERC721(GOLD).ownerOf(tokensIds[i])==msg.sender,string("Sender must be owner"));
        }
        uint _weight;
        uint _newUnits;
        for (uint x=0; x < tokensIds.length; x++) {
            IERC721(GOLD).transferFrom(msg.sender, address(this), tokensIds[x]);
            tokenIdOwner[_refineryTokenId][x+tokenCounter[_refineryTokenId]]=tokensIds[x];
            _weight += tokenGoldDetails(GOLD).goldWeight(tokensIds[x]);
        }
        _newUnits = TokenDetails[_refineryTokenId].units+tokensIds.length;
        tokenCounter[_refineryTokenId]=tokenCounter[_refineryTokenId]+tokensIds.length;
        TokenDetails[_refineryTokenId].weight += _weight;
        TokenDetails[_refineryTokenId].units=_newUnits;
    }

    function unConvertGold(uint16 _tokenId) public {
        require(safeTX,string("Invalid entrancy"));
        safeTX=false;
        require(ownerOf(_tokenId)==msg.sender,string("Sender must be owner"));
        transferFrom(msg.sender, address(this), _tokenId);
        for (uint i=0; i<tokenCounter[_tokenId];i++) {
            IERC721(GOLD).safeTransferFrom(address(this), msg.sender, tokenIdOwner[_tokenId][i],"");
        }
        TokenDetails[_tokenId].valid=false;
        safeTX=true;
    }

    function stakeOfOwner(uint _tokenId) external view returns (uint256[] memory) {
        uint256 tokenCount = tokenCounter[_tokenId];

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i]= tokenIdOwner[_tokenId][i];
        }
        return tokensId;
    }
    
    function averagePurity(uint256 _tokenId) internal view returns (uint) {
        uint _totalPurity;
        uint _counter;
        for (uint256 i = 0; i<tokenCounter[_tokenId]; i++) {
            _totalPurity = tokenGoldDetails(GOLD).goldPurity(_tokenId)+_totalPurity;
            _counter++;
        }
        uint _averagePurity = _totalPurity.div(_counter);
        return _averagePurity;
    }
    
    function averagePrice(uint256 _tokenId) internal view returns (uint) {
        uint _totalPrice;
        uint _counter;
        uint256 _augPrice = OracleInterface(OracleAUG).getPrice();
        for (uint i = 0; i<tokenCounter[_tokenId]; i++) {
            _totalPrice = (_augPrice.mul(tokenGoldDetails(GOLD).goldWeight(i)))+_totalPrice;
            _counter++;
        }
        uint _averagePrice = _totalPrice.div(_counter);
        return _averagePrice;
    }

    function goldRefineryTokenTraits(uint256 _tokenId) external view returns (uint,uint) {
        return (averagePurity(_tokenId),averagePrice(_tokenId));
    }   
    function compiledAttributes (uint256 _tokenId) internal view returns (string memory) {
        return string(abi.encodePacked(
            '"CreationDate":"',uint2str(TokenDetails[_tokenId].creationDate),'",',
            '"Gold NFT Units":"',uint2str(tokenCounter[_tokenId]),'",',
            '"Total Weight":"',uint2str(TokenDetails[_tokenId].weight),'",',
            '"Average Purity":"',uint2str(averagePurity(_tokenId)),'",',
            '"Estimated Price":"',uint2str(averagePrice(_tokenId)),'",'
        ));
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(TokenDetails[tokenId].valid,string("Invalid Token"));
        string memory imageToken = "Fixed_Image";
        string memory metadata = string(abi.encodePacked(
            '{"description":"Gold Refinery NFT Token",',
            '"image":"',imageToken,'",',
            '"external_url":"http://www.elorodealito.com",',
            '"attributes":{',
                compiledAttributes(tokenId),
            '}}'
        ));
        return string(abi.encodePacked(
            "data:application/json,",
            bytes(metadata)
        ));
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}