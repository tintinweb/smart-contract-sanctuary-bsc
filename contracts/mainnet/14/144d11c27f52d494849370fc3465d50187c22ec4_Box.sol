pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "./Ownable.sol";

contract Box is Ownable, ERC721A {
    using Strings for uint256;
    address public FEE_MANAGER;
    string public baseurl;

    uint256 public INVITE_MAX = 60;
    uint256 public inviteNow = 1;

    uint256 public TYPE_COLOR_MAX = 50;
    uint256 public TYPE_MAX = TYPE_COLOR_MAX * 4;

    uint256 public type1 = 1;
    uint256 public type2 = 1;
    uint256 public type3 = 1;

    uint256 public color1 = 0;
    uint256 public color2 = 0;
    uint256 public color3 = 0;

    uint256 public MAX = TYPE_MAX * 3 + INVITE_MAX;//5550

    struct NftAttr{
        // 10: invite, 0,1,2,
        uint256 types;
        uint256 color;//0，1,2,3
    }

    mapping (uint256 => NftAttr) public attrMap;

    constructor() ERC721A("PawPatrol", "PPL") {
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseurl;
    }

    function canMintInvite(uint256 quantity) public view returns (bool) {
        return (inviteNow - 1 + quantity) <= INVITE_MAX;
    }

    function mintInvite(address user, uint256 quantity) public payable onlyManager
    {
        require(_currentIndex - 1 + quantity <= MAX, 'max nft num limit');
        require(inviteNow - 1 + quantity <= INVITE_MAX, 'max invite nft num limit');
        if(inviteNow <= INVITE_MAX){
            for(uint i=0;i<quantity;i++){
                attrMap[_currentIndex + i].types = 10;
            }
            _safeMint(user, quantity);
            inviteNow = inviteNow + quantity;
        }
    }

    function mintBatch(address user, uint256 types, uint256 quantity) public payable onlyManager maxCoinLimit
    {
        require(_currentIndex - 1 + quantity <= MAX, 'max nft num limit');
        require((types == 0 || types == 1 || types == 2), 'nft type error');
        uint color = 0;
        if(types == 0){ require(type1 - 1 + quantity <= TYPE_MAX, 'max type1 nft num limit');  type1 = type1 + quantity;color=color1;}
        if(types == 1){ require(type2 - 1 + quantity <= TYPE_MAX, 'max type2 nft num limit');  type2 = type2 + quantity;color=color2;}
        if(types == 2){ require(type3 - 1 + quantity <= TYPE_MAX, 'max type3 nft num limit');  type3 = type3 + quantity;color=color3;}

        for(uint i=0;i<quantity;i++){
            attrMap[_currentIndex + i].types = types;
            attrMap[_currentIndex + i].color = color;
            color ++;
            if(color > 3){color=0;}
        }
        if(types == 0){color1 = color;}
        if(types == 1){color2 = color;}
        if(types == 2){color3 = color;}
        _safeMint(user, quantity);
    }

    function nextId() public view returns (uint256) {
        return _currentIndex;
    }

    function setBaseurl(string memory url_) public onlyOwner{
        baseurl = url_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        uint256 types = attrMap[tokenId].types;
        return string(abi.encodePacked(baseurl, types.toString()));
    }

    modifier onlyManager() {
        require(msg.sender == FEE_MANAGER, 'you are not manager');
        _;
    }


    function setSellerManager(address work_) public onlyOwner{
        FEE_MANAGER = work_;
    }

    modifier maxCoinLimit() {
        require(_currentIndex - 1< MAX, 'max nft limit');
        _;
    }

    function myTokens() public view returns(
        uint256[] memory
    ) {
        uint256 balance = balanceOf(msg.sender);
        uint256[] memory results = new uint256[](balance);
        uint256 index = 0;
        for(uint256 curr = _startTokenId(); curr < _currentIndex; curr++) {
            if (_exists(curr) && ownerOf(curr) == msg.sender) {
                results[index] = curr;
                index = index + 1;
            }
        }
        return (results);
    }

    function tokenInfo(uint256 curr) public view returns(TokenOwnership memory){
        TokenOwnership memory ownership = _ownershipOf(curr);
        return ownership;
    }
}