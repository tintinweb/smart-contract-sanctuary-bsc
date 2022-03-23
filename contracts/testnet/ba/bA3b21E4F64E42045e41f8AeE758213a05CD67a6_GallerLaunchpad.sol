// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IGodNFT.sol";
import "../utils/Manageable.sol";


interface ILaunchpadNFT {
    
    // return max supply config for launchpad, if no reserved will be collection's max supply
    function getMaxLaunchpadSupply() external view returns (uint256);
    
    // return current launchpad supply
    function getLaunchpadSupply() external view returns (uint256);
    
    // this function need to restrict mint permission to launchpad contract
    function mintTo(address to, uint256 size) external;
}

interface IBASEURI{
     function baseURI() external view  returns (string memory);
}

contract GallerLaunchpad is Manageable,ILaunchpadNFT{
    
    IGodNFT god = IGodNFT(0xD4fD679fA138589e81148bb2Dac6f0E8631e404e);
    
    string public baseURI;
    string public suffix;

    // must impl this in your NFT contract, and make it public
    uint256 public LAUNCH_MAX_SUPPLY;    // max launch supply
    uint256 public LAUNCH_SUPPLY;        // current launch supply
    
    address public LAUNCHPAD;
    
    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must set");
        require(msg.sender == LAUNCHPAD, "must call by launchpad");
        _;
    }
    
    struct tokenList_S{
        uint256 _tokenId;
        uint256 _nameIdx; 
        uint256 _campIdx;
        uint256 _godIdx;
        uint256 _rarityIdx; 
        uint256 _skillID;
        uint256[]  _canCreate;
    }
    
    mapping(uint256 => tokenList_S) public tokenList; // index = > token;
    mapping(uint256 => bool) public tokenMintFlag; // index = > token;
    
    event SetTokenList(
        uint256 _index,
        uint256 _tokenId,
        uint256 _nameIdx, 
        uint256 _campIdx,
        uint256 _godIdx,
        uint256 _rarityIdx, 
        uint256 _skillID,
        uint256[]  _canCreate);
    
    constructor(string memory suffix_, address launchpad, uint256 maxSupply){
        suffix = suffix_;
        baseURI = IBASEURI(address(god)).baseURI();
        
        LAUNCHPAD = launchpad;
        LAUNCH_MAX_SUPPLY = maxSupply;
    }
    
    function getMaxLaunchpadSupply() view public override returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    function getLaunchpadSupply() view public override returns (uint256) {
        return LAUNCH_SUPPLY;
    }
    
    function setTokenList(
        uint256[] memory _indexs,
        uint256[] memory _tokenIds,
        uint256[] memory _nameIdxs,
        uint256[] memory _campIdxs,
        uint256[] memory _godIdxs,
        uint256[] memory _rarityIdxs,
        uint256[] memory _skillIDs,
        uint256[][] memory _canCreates
        ) public onlyManager{
        
        uint256 len = _indexs.length;
        
        for(uint256 i = 0; i< len;i++){
            require(tokenList[_indexs[i]]._tokenId == 0,"already set this index");
            tokenList[_indexs[i]] = tokenList_S({
                _tokenId :_tokenIds[i],
                _nameIdx : _nameIdxs[i],
                _campIdx : _campIdxs[i],
                _godIdx : _godIdxs[i],
                _rarityIdx : _rarityIdxs[i],
                _skillID : _skillIDs[i],
                 _canCreate : _canCreates[i]
            });
            
            emit SetTokenList(
                _indexs[i],
                _tokenIds[i],
                _nameIdxs[i],
                _campIdxs[i],
                _godIdxs[i],
                 _rarityIdxs[i],
                 _skillIDs[i],
                 _canCreates[i]
                );
        }
        
    }
    
    function modifierTokenList(
        uint256 _index,
        uint256 _tokenId,
        uint256 _nameIdx, 
        uint256 _campIdx,
        uint256 _godIdx,
        uint256 _rarityIdx, 
        uint256 _skillID,
        uint256[] memory _canCreate) public onlyManager{
            
            tokenList[_index] = tokenList_S({
                _tokenId :_tokenId,
                _nameIdx : _nameIdx,
                _campIdx : _campIdx,
                _godIdx : _godIdx,
                _rarityIdx : _rarityIdx,
                _skillID : _skillID,
                 _canCreate : _canCreate
            });
        }
    
    // you must impl this in your NFT contract
    // you NFT contract is responsible to maintain the tokenId
    // you may have another mint function hold by yourself, to skip the process after presale end
    // max size will be 10
    function mintTo(address to, uint size) external  override onlyLaunchpad {
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");
        
        
        for (uint256 i=1; i <= size; i++) {
            LAUNCH_SUPPLY++;
            require(tokenList[LAUNCH_SUPPLY]._tokenId > 0 && !tokenMintFlag[LAUNCH_SUPPLY],"tokenID not set or alread mint");
            _mint(to, LAUNCH_SUPPLY);
        }
    }
    
    function _mint(address to,uint256 index) internal{
        
        tokenMintFlag[index] = true;
        
        god.mint(
            to, 
            tokenList[index]._tokenId, 
            tokenList[index]._nameIdx,  
            tokenList[index]._campIdx,
            tokenList[index]._godIdx, 
            tokenList[index]._rarityIdx, 
            tokenList[index]._skillID, 
            tokenList[index]._canCreate); 
        
    }
    
    

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGodNFT {
    event Mint(address _owner, uint256 _tokenID, uint256 _nameIdx, uint256 _campIdx, uint256 _godId, uint256 _rarityIdx, uint256 _skillID, uint256[] _canCreate);
    event SetBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] _values);
    event SetExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value);
    event AddExtendAttributes(uint256 _tokenId,uint256 _value);

    struct CAttributes_S {
        uint256 nameIdx; 
        uint256 campIdx; 
        uint256 godIdx;
        uint256 rarityIdx; 
        uint256 skillID;  
        uint256[] canCreate;
        uint256[] extendsAttrs;
    }

    function mint(
        address _to, 
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx,
        uint256 _godIdx, 
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate) external;

    function safeMint(
        address _to,
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx,
        uint256 _godIdx, 
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate, 
        bytes memory _data) external;

    function cAttributes(uint256 _tokenId) external view returns(CAttributes_S memory);

    function setBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] memory _values) external;

    function getExtendAttributesLength(uint256 _tokenId) external view  returns(uint256);

    function getExtendAttributesValuebyIndex(uint256 _tokenId, uint256 _index) external view returns(uint256);

    function setExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value) external;

    function addExtendAttributes(uint256 _tokenId,uint256 _value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Manageable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;
    mapping(address=>bool) public managers;

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }


     modifier onlyManager(){
        require(managers[_msgSender()], "NOT_MANAGER");
        _;
    }

    function addManager(address _manager) public onlyOwner {
        require(_manager != address(0), "ZERO_ADDRESS");
        managers[_manager] = true;
    }
  
    function delManager(address _manager) public onlyOwner {
        require(_manager != address(0), "ZERO_ADDRESS");
        managers[_manager] = false;
    }
    
}

// SPDX-License-Identifier: MIT

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