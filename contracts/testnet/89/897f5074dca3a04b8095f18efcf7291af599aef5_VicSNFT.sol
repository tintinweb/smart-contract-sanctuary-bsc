// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./ERC721Enumerable.sol";

contract VicSNFT is ERC721Enumerable {
    uint256 private maxBox;
    uint256 private curentBox;
    address private admin;
    mapping(uint256 => uint256) private parentID;
    mapping(uint256 => uint256[]) private listChildID;
    mapping(uint256 => uint256) private countChildID;
    mapping(uint256 => uint256) private lastClone;

    event changeadmin(address admin);
    event changeunbox5000Shose(address to, uint256 tokenId);
    event changeFusioningShose(address to,uint256 burntokenId1,uint256 burntokenId2,uint256 tokenId);
    event changeShoesClone(uint256 origintokenId, uint256 newTokenID);

    constructor() ERC721("Vic Shose NFT", "VicSNFT") {
        maxBox = 5000;
        curentBox = 0;
        admin = 0x4F866dE40E5c98e554606242f74667f4F295FC9c;
    }
    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
        emit changeadmin(_admin);
    } 
    function getBoxCount() external view returns (uint256 _maxBox, uint256 _curentBox) {
        return (maxBox, curentBox);
    }  
    function getAdmin() external view returns (address _admin) {
        return (admin);
    }  

    //Only 5000 boxes are open for sale. After that, the community will have to dig out shoes and buy and sell on the market
    function unbox5000Shose(address to, uint256 tokenId) external {
        require(msg.sender == admin);
        require(curentBox<maxBox,"The maximum number of boxes has been reached, can't open any more");
        _mint(to,tokenId);
        parentID[tokenId] = 0;
        countChildID[tokenId] = 0;
        lastClone[tokenId]=block.timestamp;
        curentBox++;
        emit changeunbox5000Shose(to, tokenId);
    }

    //Cloning shoes, Shoes can only be cloned up to 7 times, and each must be 30 days apart
    function ShoesClone(uint256 origintokenId, uint256 tokenId) external{
        require(msg.sender == admin);
        require(lastClone[origintokenId] < (block.timestamp - 30 days), "Each clone must be 30 days apart");
        require(countChildID[origintokenId] < 7,"Each shoe is only allowed to clone 7 times");
        //mint and set data for TokenID
        _mint(ownerOf(origintokenId),tokenId);
        parentID[tokenId] = origintokenId;
        countChildID[tokenId] = 0;
        lastClone[tokenId]=block.timestamp;
        //set data for parentid
        if(countChildID[origintokenId]==0){
            listChildID[origintokenId] = new uint256[](tokenId);
        }else{
            listChildID[origintokenId].push(tokenId);
        }
        countChildID[origintokenId]++;
        lastClone[origintokenId]=block.timestamp;
        emit changeShoesClone(origintokenId, tokenId);
    }

    //Had to burn 2 shoes to get 1 new and better shoe
    function FusioningShose(address to,uint256 burntokenId1,uint256 burntokenId2,uint256 tokenId) external {
        require(msg.sender == admin);
        _burn(burntokenId1);
        _burn(burntokenId2);
        _mint(to,tokenId);
        parentID[tokenId] = 0;
        countChildID[tokenId] = 0;
        lastClone[tokenId]=block.timestamp;
        emit changeFusioningShose(to, burntokenId1, burntokenId2, tokenId);
    }

    function getlistchild(uint256 tokenId) external view returns (uint256[] memory, uint256 _Parent, uint256 _lastClone) {
        return (listChildID[tokenId],parentID[tokenId],lastClone[tokenId]);
    }
    

    function _baseURI() override internal view virtual returns (string memory) {
        return "https://vicmove.com/api/nft/vicsnft/";
    }
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }
}