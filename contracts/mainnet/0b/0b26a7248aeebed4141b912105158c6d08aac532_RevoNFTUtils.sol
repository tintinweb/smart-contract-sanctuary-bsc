/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.8.3;
pragma experimental ABIEncoderV2;

interface IRevoTokenContract{
  function balanceOf(address account) external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
}

interface IRevoLib{
  function getLiquidityValue(uint256 liquidityAmount) external view returns (uint256 tokenRevoAmount, uint256 tokenBnbAmount);
  function getLpTokens(address _wallet) external view returns (uint256);
  function tokenRevoAddress() external view returns (address);
  function calculatePercentage(uint256 _amount, uint256 _percentage, uint256 _precision, uint256 _percentPrecision) external view returns (uint256);
}

interface IRevoNFT{
    struct Token {
        string collection;
        string dbId;
        uint256 tokenId;
    }
    
    function nftsDbIds(string memory _collection, string memory _dbId) external view returns (uint256);
    function getTokensDbIdByOwnerAndCollection(address _owner, string memory _collection) external view returns(string[] memory ownerTokensDbId);
    function burn(uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function getTokensByOwner(address _owner) external view returns(Token[] memory ownerTokens);
}

interface IRevoTierContract{
    function getRealTimeTier(address _wallet) external view returns (Tier memory);
    function getTier(uint256 _index) external view returns(Tier memory);
    
    struct Tier {
        uint256 index;
        uint256 minRevoToHold;
        uint256 stakingAPRBonus;
        string name;
    }
}

interface IRevoNFTUtilsBurnLimit{
    function getCount(uint256 _burnIndex, address _address) external view returns(uint256);
    function setCount(uint256 _burnIndex, address _address, uint256 _count) external;
    function getFirstBuyTs(uint256 _burnIndex, address _address) external view returns(uint256);
    function setFirstBuyTs(uint256 _burnIndex, address _address, uint256 _firstBuyTS) external;
    function burnLimitValue() external returns(uint256);
}

interface IRevoEggFarmer{
    function hatchEgg(uint256 _tokenId, address user) external;
}
    

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() public view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _owner2;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function owner2() public view returns (address) {
        return _owner2;
    }

    function setOwner2(address _address) public onlyOwner{
        _owner2 = _address;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender() || _owner2 == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract RevoNFTUtils is Ownable {
    using SafeMath for uint256;
     
    address public revoAddress;
    IRevoTokenContract private revoToken;
    address public revoLibAddress;
    IRevoLib private revoLib;
    address public tierAddress;
    IRevoTierContract revoTier;
    IRevoEggFarmer revoEggFarmer;
    IRevoNFTUtilsBurnLimit burnLimit;
    
    IRevoNFT private revoNFT;
    
    uint256 private nextRevoId;
    uint256 public revoFees;
    
    uint256 public counter;
    uint256 public minTierBooster = 4;
    
    ITEMS_SALEABLE[99] public itemSaleable;
    BURN_TYPE[20] public burnType;
    //PENDING BUY
    mapping(uint256 => PENDING_TX) pendingTx;
    uint256 public firstPending = 1;
    uint256 public lastPending = 0;

    mapping(address => mapping(string => mapping(string => uint256))) public triggerMintHistory; 
    
    struct ITEMS_SALEABLE {
        uint256 index;
        string name;
        string description;
        uint256 price;
        string itemType;
        bool enabled;
        uint256 count;
        uint256 maxItems;
        uint256[3] prices;
    }
    
    struct PENDING_TX {
        uint256 itemIndex;
        string dbId;
        string collection;
        uint256 uniqueId;
        string itemType;
        address sender;
        uint256[] tokenIds;
    }

    struct BURN_TYPE {
        uint256 burnIndex;
        string name;
        string burnType;
        uint256 count;
        bool sameRevo;
        uint256 rarity;
        uint256 rewardDollar;
    }

    
    
    event CreateNFT(address sender, string dbId, string collection);
    event BuyItem(address sender, uint256 index);
    event HatchEgg(address sender, uint256 tokenId);
    event OpenBooster(address sender, uint256 tokenId);
    event BurnNFTs(address sender, uint256[] tokenIds);

    constructor(address _revoLibAddress, address _revoNFT, address _revoTier) {
        setRevoLib(_revoLibAddress);
        setRevo(revoLib.tokenRevoAddress());
        setRevoNFT(_revoNFT);
        setRevoTier(_revoTier);
        
        revoFees = 12000000000000000000;

        editBurnType(0, "Common Burn", "BURN_COMMON_SAME_REVO", 30, true, 1, 150);
        editBurnType(1, "Rare Burn", "BURN_RARE_SAME_REVO", 12, true, 2, 110);
        editBurnType(2, "Legendary Burn", "BURN_LEGENDARY_DIFFERENT_REVO", 4, false, 3, 420);
        editBurnType(3, "Shiny Burn", "BURN_SHINY_DIFFERENT_REVO", 2, false, 4, 410);
    }
    
    /*
    Trigger nft creation
    */
    function triggerCreateNFT(string memory _dbId, string memory _collection) public {
        require(canMint(msg.sender), "You must own a R3V-UP to mint.");

        revoToken.transferFrom(msg.sender, address(this), revoFees);
        
        triggerMintHistory[msg.sender][_collection][_dbId] = revoFees;
        
        enqueuePendingTx(PENDING_TX(0, _dbId, _collection, counter, "", msg.sender, new uint[](0)));
        
        emit CreateNFT(msg.sender, _dbId, _collection);
        
        counter++;
    }
    
    /*
    Buy item sellable & add pending buy to queue
    */
    function buyItem(uint256 _itemIndex) public {
        //Check if item is available in inventory
        require(itemSaleable[_itemIndex].count < itemSaleable[_itemIndex].maxItems, "All items sold");
        //Must be master to buy booster
        require(!compareStrings(itemSaleable[_itemIndex].itemType, "BOOSTER") || revoTier.getRealTimeTier(msg.sender).index >= minTierBooster, "Must belong to minTier to buy booster");
        
        enqueuePendingTx(PENDING_TX(_itemIndex, "", "", counter, itemSaleable[_itemIndex].itemType, msg.sender, new uint[](0)));
        
        revoToken.transferFrom(msg.sender, address(this), getItemPrice(_itemIndex));
        
        itemSaleable[_itemIndex].count = itemSaleable[_itemIndex].count.add(1);
        
        emit BuyItem(msg.sender, itemSaleable[_itemIndex].index);
        
        counter++;
    }

    function hatchEgg(uint256 _tokenId) public {
        revoEggFarmer.hatchEgg(_tokenId, msg.sender);

        enqueuePendingTx(PENDING_TX(_tokenId, "", "EGG", counter, "HATCH", msg.sender, new uint[](0)));

        emit HatchEgg(msg.sender, _tokenId);

        counter++;
    }

    function openBooster(uint256 _tokenId) public {
        require(isNFTBooster(_tokenId, msg.sender), "NFT is not a booster");

        //TRANSFER AND BURN BOOSTER NFT
        revoNFT.transferFrom(msg.sender, address(this), _tokenId);
        revoNFT.burn(_tokenId);

        enqueuePendingTx(PENDING_TX(_tokenId, "", "BOOSTER", counter, "OPEN", msg.sender, new uint[](0)));

        emit OpenBooster(msg.sender, _tokenId);

        counter++;
    }

    function burnNFT(uint256 _burnIndex, uint256[] memory _tokenIds) public {
        require(revoToken.balanceOf(address(this)) > 2000000000000000000000, "No more Revo reward available.");
        require(canMint(msg.sender), "You must own a R3V-UP to burn.");
        require(_tokenIds.length == burnType[_burnIndex].count, "Wrong number of NFTs");

        if(block.timestamp - burnLimit.getFirstBuyTs(_burnIndex, msg.sender) < 2592000){
            require(burnLimit.getCount(_burnIndex, msg.sender) < burnLimit.burnLimitValue(), "Burn limit reached");
            burnLimit.setCount(_burnIndex, msg.sender, burnLimit.getCount(_burnIndex, msg.sender).add(1));
        }else{
            burnLimit.setFirstBuyTs(_burnIndex, msg.sender, block.timestamp);
            burnLimit.setCount(_burnIndex, msg.sender, 1);
        }

        for(uint256 i; i < _tokenIds.length; i++){
            revoNFT.transferFrom(msg.sender, address(this), _tokenIds[i]);
            revoNFT.burn(_tokenIds[i]);
        }

        enqueuePendingTx(PENDING_TX(0, "", "BURN_NFT", counter, burnType[_burnIndex].burnType, msg.sender, _tokenIds));

        emit BurnNFTs(msg.sender, _tokenIds);

        counter++;
    }

    function sendBurnReward(address _receiver, uint256 _revoAmount) public onlyOwner {
        revoToken.transfer(_receiver, _revoAmount);
        dequeuePendingTx();
    }

    function isNFTBooster(uint256 _tokenId, address _user) public view returns(bool){
        IRevoNFT.Token[] memory tokens = revoNFT.getTokensByOwner(_user);
        for(uint256 i = 0; i < tokens.length; i++){
            if(tokens[i].tokenId == _tokenId && compareStrings(tokens[i].collection, "BOOSTER")){
                return true;
            }
        }
        return false;
    }
    
    function getItemPrice(uint256 _itemIndex) public view returns(uint256){
        uint256 price = itemSaleable[_itemIndex].price;
        
        if(!compareStrings(itemSaleable[_itemIndex].itemType, "R3VUP")){
            
            uint256 step = itemSaleable[_itemIndex].maxItems / 3;
            uint priceIndex = itemSaleable[_itemIndex].count < step ? 0 :
            itemSaleable[_itemIndex].count < (step * 2) ? 1 : 2;
            
            price = itemSaleable[_itemIndex].prices[priceIndex];
        }
        
        return price;
    }

    function canMint(address user) public view returns(bool){
        return revoNFT.getTokensDbIdByOwnerAndCollection(user, "R3VUP").length > 0;
    }
    
    function setRevoFees(uint256 _fees) public onlyOwner {
        revoFees = _fees;
    }
    
    /*
    Set revo Address & token
    */
    function setRevo(address _revo) public onlyOwner {
        revoAddress = _revo;
        revoToken = IRevoTokenContract(revoAddress);
    }
    
    /*
    Set revoLib Address & libInterface
    */
    function setRevoLib(address _revoLib) public onlyOwner {
        revoLibAddress = _revoLib;
        revoLib = IRevoLib(revoLibAddress);
    }
    
    function setRevoNFT(address _revoNFT) public onlyOwner {
        revoNFT = IRevoNFT(_revoNFT);
    }

    /*
    Set revo tier Address & contract
    */
    function setRevoTier(address _revoTier) public onlyOwner {
        tierAddress = _revoTier;
        revoTier = IRevoTierContract(tierAddress);
    }

    function setBurnLimit(address _burnLimit) public onlyOwner {
        burnLimit = IRevoNFTUtilsBurnLimit(_burnLimit);
    }

    /*
    Set revo egg farmer contract
    */
    function setRevoEggFarmer(address _revoEggFarmer) public onlyOwner {
        revoEggFarmer = IRevoEggFarmer(_revoEggFarmer);
    }
    
    function withdrawRevo(uint256 _amount) public onlyOwner {
        revoToken.transfer(owner(), _amount);
    }

    function setMinTierBooster(uint256 _minTierBooster) public onlyOwner {
        minTierBooster = _minTierBooster;
    }
    
    function editItemsaleable(uint256 _index, string memory _name, string memory _description, uint256 _price, string memory _itemType, bool _enabled,
    uint256 _count, uint256 _maxItems, uint256[3] memory _prices) public onlyOwner{
        itemSaleable[_index].index = _index;
        itemSaleable[_index].name = _name;
        itemSaleable[_index].description = _description;
        itemSaleable[_index].price = _prices[0];
        itemSaleable[_index].itemType = _itemType;
        itemSaleable[_index].enabled = _enabled;
        editInventory(_index, _count, _maxItems);
        editItemsaleablePrices(_index, _prices);
    }
    
    function editItemsaleablePrices(uint256 _index, uint256[3] memory _prices) public onlyOwner{
        itemSaleable[_index].prices = _prices;
    }
    
    function editInventory(uint256 _index, uint256 _count, uint256 _maxItems) public onlyOwner{
        itemSaleable[_index].count = _count;
        itemSaleable[_index].maxItems = _maxItems;
    }

    function editBurnType(uint256 _index, string memory _name, string memory _type, uint256 _count, bool _sameRevo, uint256 _rarity, uint256 _rewardDollar) public onlyOwner{
        burnType[_index].burnIndex = _index;
        burnType[_index].name = _name;
        burnType[_index].burnType = _type;
        burnType[_index].count = _count;
        burnType[_index].sameRevo = _sameRevo;
        burnType[_index].rarity = _rarity;
        burnType[_index].rewardDollar = _rewardDollar;
    }
    
    function getAllItemssaleable() public view  returns(ITEMS_SALEABLE[] memory){
        uint256 count;
        for(uint i = 0; i < itemSaleable.length; i++){
            if(itemSaleable[i].enabled){
                count++;
            }
        }
        
        ITEMS_SALEABLE[] memory itemToReturn = new ITEMS_SALEABLE[](count);
        for(uint256 i = 0; i < itemSaleable.length; i++){
            if(itemSaleable[i].enabled){
                itemToReturn[i] = itemSaleable[i];
                itemToReturn[i].price = getItemPrice(i);
            }
        }
        return itemToReturn;
    }

    function getAllBurnType() public view  returns(BURN_TYPE[] memory){
        uint256 count;
        for(uint i = 0; i < burnType.length; i++){
            if(burnType[i].count > 0){
                count++;
            }
        }
        
        BURN_TYPE[] memory itemToReturn = new BURN_TYPE[](count);
        for(uint256 i = 0; i < burnType.length; i++){
            if(burnType[i].count > 0){
                itemToReturn[i] = burnType[i];
            }
        }
        return itemToReturn;
    }
    
    /*
    PENDING BUY QUEUE
    */
    
    function enqueuePendingTx(PENDING_TX memory data) private {
        lastPending += 1;
        pendingTx[lastPending] = data;
    }

    function dequeuePendingTx() public onlyOwner returns (PENDING_TX memory data) {
        require(lastPending >= firstPending);  // non-empty queue

        data = pendingTx[firstPending];

        delete pendingTx[firstPending];
        firstPending += 1;
    }
    
    function countPendingTx() public view returns(uint256){
        return firstPending <= lastPending ? (lastPending - firstPending) + 1 : 0;
    }
    
    function getPendingTx(uint256 _maxItems) public view returns(PENDING_TX[] memory items){
        uint256 count = countPendingTx();
        count = count > _maxItems ? _maxItems : count;
        PENDING_TX[] memory itemToReturn = new PENDING_TX[](count);
        
        for(uint256 i = 0; i < count; i ++){
            itemToReturn[i] =  pendingTx[firstPending + i];
        }
        
        return itemToReturn;
    }
    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}