// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./ERC721Enumerable.sol";

contract VicGemNFT is ERC721Enumerable {
    address private admin;
    address public GearContract;
    address public VicShoesContract;
    address public PoolContract;
    uint256 public MaxMintToPool;
    uint256 public CurrentMintToPool;
    mapping(uint256 => uint256) public Gemetric;
    mapping(uint256 => uint256) public GemetricVIM;
    mapping(uint256 => uint256) public Time2Earn;
    uint256 public minTime2Earn;//second

    event changeadmin(address admin);
    event changeGearContract(address GearContract);
    event changeVicShoesContract(address VicShoesContract);
    event changePoolContract(address PoolContract);
    event changeburnGem(uint256[] lstGemID, uint256 VicGearID);
    event changeearngem(uint256 VicGearID,uint256 VicGemID);
    event changeGemetric(uint256 VicGearID,uint256 amount);
    event changeGemetricVIM(uint256 VicShoseID,uint256 amount);
    event event_mint60000ToPoolOnly(uint256 amount, uint256 NewMintAmount);
    event changeminTime2Earn(uint256 _minTime2Earn);

    constructor() ERC721("VicGem NFT", "VicGemNFT") {
        admin = 0x3Cab9C6aAE23699cBd9d0CCAA37e9716e554034F;
        GearContract = 0x15546756eD7Ab24BC5B89F1885157Af309E83c00;
        VicShoesContract = 0xC184af52Ca4E1B1f085aA8236Ff8508F52dc6eA7;
        PoolContract = 0xD10dBf70198DD87520A472e6c461714c31e7cac6;
        MaxMintToPool = 60000;
        minTime2Earn = 86400;//1 day
    }
    function setminTime2Earn(uint256 _minTime2Earn) external onlyOwner {
        minTime2Earn = _minTime2Earn;
        emit changeminTime2Earn(minTime2Earn);
    } 
    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
        emit changeadmin(_admin);
    } 
    function setGearContract(address _GearContract) external onlyOwner {
        GearContract = _GearContract;
        emit changeGearContract(_GearContract);
    } 
    function setVicShoesContract(address _VicShoesContract) external onlyOwner {
        VicShoesContract = _VicShoesContract;
        emit changeVicShoesContract(_VicShoesContract);
    } 
    function setPoolContract(address _PoolContract) external {
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        PoolContract = _PoolContract;
        emit changePoolContract(_PoolContract);
    } 
    function mint60000ToPoolOnly(uint256 amount) external{
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        require(MaxMintToPool > CurrentMintToPool + amount,"can not mint more 60000");
        for(uint256 i = 0;i<amount;i++){
            _mint(PoolContract,CurrentMintToPool+i);
        }
        CurrentMintToPool = CurrentMintToPool + amount;
        emit event_mint60000ToPoolOnly(amount,CurrentMintToPool);
    }
    function burnGem_VicGear(uint256[] memory lstGemID, uint256 VicGearID) external{
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        address gearowner = IERC721Enumerable(GearContract).ownerOf(VicGearID);
        require(gearowner != address(0),"Not allow address 0");
        uint256 currentFGem = Gemetric[VicGearID];
        for(uint256 i = 0;i<lstGemID.length;i++){
            uint256 gemID = lstGemID[i];
            require(IERC721Enumerable(address(this)).ownerOf(gemID) == gearowner,"Gear And VicGem's owner need same");
            _burn(gemID);
            currentFGem = currentFGem + 7;
        }
        if(Gemetric[VicGearID] == 0){
            Time2Earn[VicGearID] = block.timestamp;
        }
        Gemetric[VicGearID] = currentFGem;
        emit changeGemetric(VicGearID,Gemetric[VicGearID]);
        emit changeburnGem(lstGemID,VicGearID);
    }
    function burnGem_VicShoes(uint256[] memory lstGemID, uint256 VicShoesID) external{
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        address gearowner = IERC721Enumerable(VicShoesContract).ownerOf(VicShoesID);
        require(gearowner != address(0),"Not allow address 0");
        uint256 currentFGem = GemetricVIM[VicShoesID];
        for(uint256 i = 0;i<lstGemID.length;i++){
            uint256 gemID = lstGemID[i];
            require(IERC721Enumerable(address(this)).ownerOf(gemID) == gearowner,"Gear And VicGem's owner need same");
            _burn(gemID);
            currentFGem = currentFGem + 7;
        }
        if(GemetricVIM[VicShoesID] == 0){
            Time2Earn[VicShoesID] = block.timestamp;
        }
        GemetricVIM[VicShoesID] = currentFGem;
        emit changeGemetricVIM(VicShoesID,GemetricVIM[VicShoesID]);
        emit changeburnGem(lstGemID,VicShoesID);
    }
    function earngem_VicGear(uint256 VicGearID,uint256 VicGemID) external {
        require(VicGemID > 60000,"Mint ID need to > 60000");
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        address gearowner = IERC721Enumerable(GearContract).ownerOf(VicGearID);
        require(gearowner != address(0),"Not allow address 0");
        require(Gemetric[VicGearID] >= 0,"future can not be zero");
        require(block.timestamp - Time2Earn[VicGearID] > minTime2Earn,"Time 2 earn not ok");
        _mint(gearowner,VicGemID);
        Gemetric[VicGearID] = Gemetric[VicGearID] - 1;
        Time2Earn[VicGearID] = Time2Earn[VicGearID] + minTime2Earn;
        emit changeGemetric(VicGearID,Gemetric[VicGearID]);
        emit changeearngem(VicGearID, VicGemID);
    }
    function earngem_VicShoes(uint256 VicShoesID,uint256 VicGemID) external {
        require(VicGemID > 60000,"Mint ID need to > 60000");
        require(msg.sender == admin || msg.sender == owner(),"Allow admin only");
        address gearowner = IERC721Enumerable(VicShoesContract).ownerOf(VicShoesID);
        require(gearowner != address(0),"Not allow address 0");
        require(GemetricVIM[VicShoesID] >= 0,"future can not be zero");
        require(block.timestamp - Time2Earn[VicShoesID] > minTime2Earn,"Time 2 earn not ok");
        _mint(gearowner,VicShoesID);
        GemetricVIM[VicShoesID] = GemetricVIM[VicShoesID] - 1;
        Time2Earn[VicShoesID] = Time2Earn[VicShoesID] + minTime2Earn;
        emit changeGemetricVIM(VicShoesID,GemetricVIM[VicShoesID]);
        emit changeearngem(VicShoesID, VicGemID);
    }
    function _baseURI() override internal view virtual returns (string memory) {
        return "https://vicstep.com/nft/vicgemnft/";
    }
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        return _tokensOfOwner(owner,0,~uint256(0));
    }
    function tokensOfOwnerv2(address owner,uint256 start, uint256 end) external view returns (uint256[] memory) {
        return _tokensOfOwner(owner,start,end);
    }

    function getAllToken() external view returns (uint256[] memory _tokenID, address[] memory _Address) {
        return _getAllToken(0,~uint256(0));
    }
    function getAllTokenv2(uint256 start, uint256 end) external view returns (uint256[] memory _tokenID, address[] memory _Address) {
        return _getAllToken(start,end);
    }
}