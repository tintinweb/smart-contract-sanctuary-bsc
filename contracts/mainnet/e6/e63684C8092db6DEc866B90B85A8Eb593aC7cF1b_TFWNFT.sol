// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Counters.sol";
import "./Ownable.sol";
import "./ERC721Enumerable.sol";

contract TFWNFT is ERC721Enumerable, Ownable {
    struct Level{
        string  name;
        string  uri;
        uint    weight;
        uint    limit; 
        uint    upgradePrice;
        uint    mintedAmount;
    }

    uint256 public totalWeight;
    mapping(address => uint) public userWeight;

    using Counters for Counters.Counter;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the bunnyId for each tokenId
    mapping(uint256 => uint8) private levelIds;
    // Map the kindId for each tokenId
    mapping(uint256 => uint8) private kinds;

    //Map Map the kinds and level uri [level][king]
    mapping(uint8 => mapping(uint8 => string)) private globalURI;

    // Address map with mint permissions
    mapping(address => bool) private mintAccess;

    mapping(uint8 => Level) public levelMap;

    constructor() ERC721("The Future World", "TFWNFT") {
        levelMap[0] = Level("G","",0,88,0,0); //gensisi NFT
        levelMap[1] = Level("N","",100,10000,100,0);
        levelMap[2] = Level("R","",400,6000,200,0);
        levelMap[3] = Level("S","",1500,2000,500,0);
        levelMap[4] = Level("SR","",6000,600,1200,0);
        levelMap[5] = Level("SSR","",2000,200,0,0);
    }

    modifier onlyMinter() {
        require(mintAccess[msg.sender], "Access denied");
        _;
    }

   /**
     * @dev Mint NFTs.
     */
    function batchMint(
        address _to,
        uint8 _levelId,
        uint256 size
    ) external onlyMinter {
        for(uint i = 0; i < size; i++){
            mint(_to,_levelId);
        }
    }

    /**
     * @dev Mint NFT.
     */
    function mint(
        address _to,
        uint8 _levelId
    ) public onlyMinter returns (uint256) {
        Level memory _level = levelMap[_levelId];
        require(_levelId < 6, "unknow level");
        require(_level.limit >= _level.mintedAmount + 1,"exceed mint limit");
        levelMap[_levelId].mintedAmount++;

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        levelIds[tokenId] = _levelId;
        kinds[tokenId] = _randomKind();

        _mint(_to, tokenId);

        totalWeight += _level.weight;
        userWeight[_to] += _level.weight;

        return tokenId;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal  virtual override {
        Level memory level = levelMap[levelIds[tokenId]];
        userWeight[from] -= level.weight;
        userWeight[to] += level.weight;
        super._transfer(from,to,tokenId);
    }

    function upgrade(
        uint256 tokenID
    ) public onlyMinter returns (uint256) {
        require(levelIds[tokenID] > 0 && levelIds[tokenID] < 5,"unable to upgrade");

        Level memory level = levelMap[levelIds[tokenID]];

        levelIds[tokenID] += 1;

        uint256 newWeight = levelMap[levelIds[tokenID]].weight;
        uint256 oldWeight = level.weight;
        totalWeight += newWeight - oldWeight;
        userWeight[ownerOf(tokenID)] += newWeight - oldWeight;

        return level.upgradePrice;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(address _from, uint256 _tokenId) external {
        require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "nft: illegal request");
        require(ownerOf(_tokenId) == _from, "from is not owner");
        _burn(_tokenId);
    }

    function getLevelId(uint256 _tokenId) public view returns (uint8) {
        return levelIds[_tokenId];
    }

    function getKindId(uint256 _tokenId) public view returns (uint8) {
        return kinds[_tokenId];
    }

    function getLevelIdsByTokenIds(uint256[] memory _tokenArray) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_tokenArray.length);
        for (uint256 i = 0; i < _tokenArray.length; i++) {
            result[i] = getLevelId(_tokenArray[i]);
        }
        return result;
    }

    function getKindsByTokenIds(uint256[] memory _tokenArray) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_tokenArray.length);
        for (uint256 i = 0; i < _tokenArray.length; i++) {
            result[i] = getKindId(_tokenArray[i]);
        }
        return result;
    }

    function _randomKind() private view returns(uint8){
        uint _val = uint(blockhash(block.number-1)) % 5;
        return uint8(_val+1);
    }

    // ERC721URIStorage
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        uint8 _level = levelIds[tokenId];
        uint8 _kind = kinds[tokenId];

        return globalURI[_level][_kind];
    }

    /**
     * @dev Access operations.
     */
    function setAccess(address _account) public onlyOwner {
        mintAccess[_account] = true;
    }

    function removeAccess(address _account) public onlyOwner {
        mintAccess[_account] = false;
    }

    function setURI(uint8 _level,uint8 _kind,string calldata newURI) public onlyOwner {
        require(_level < 6 && _kind < 6, "invalid level && kind");
        globalURI[_level][_kind] = newURI;
    }


    function getAccess(address _account) public view returns (bool) {
        return mintAccess[_account];
    }
}