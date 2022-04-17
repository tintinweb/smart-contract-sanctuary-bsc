/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(address,address,uint256,bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    struct UintSet {
        uint256[] _values;
        // key => _values中的位置 （1 ~ _values.length）
        mapping (uint256 => uint256) _indexes;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            uint256 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function clear(UintSet storage set) internal  {
        for(uint256 i=0;i<set._values.length;i++){
            delete set._indexes[set._values[i]];
        }
        set._values = new uint256[](0);
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct AddressSet {
        address[] _values;
        // key => _values中的位置 （1 ~ _values.length）
        mapping (address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            address lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}


interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function isLocked(uint256 tokenId) external view returns (bool);
    function setLocked(uint256 tokenId) external;
    function unLocked(uint256 tokenId) external;
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
    function unLockedTokensOfOwner(address owner) external view returns (uint256[] memory);
}

contract PerfectPlanetGame is ERC721Holder,Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    IBEP20 public ppgToken = IBEP20(0x1a1C3147e0363164CFD529160bbC723700CcB129);
    IBEP20 public ppfToken = IBEP20(0xDc82e692B9eb8AAC0E12A59a8A35423008C0B011);

    IERC721 public wep1Nft = IERC721(0x0728c36dCCc9D84fcBC4F00683E243266923982c);
    IERC721 public wep2Nft = IERC721(0x2378a042ccBd2D3c06b8d7974Cda1384B70350a6);
    IERC721 public wep3Nft = IERC721(0x5E9AB50bA6C978028eb5eA9484C9155f073755B9);
    IERC721 public dev1Nft = IERC721(0xCC31ECADDb7FD135912878B0f9fc3a916DB1732a);
    IERC721 public dev2Nft = IERC721(0x32a8ec97411E2869e7Eb0033615a06A03ea0e703);
    IERC721 public dev3Nft = IERC721(0x419E1765101636D4BEc24517602fF04A8A11Be9d);
    IERC721 public landNft = IERC721(0x55b099E2a979bbA25f904dc2F2D5341752Fc1fd3);

    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    address private devAddress = 0xA356A7A8aC0c780dd28125aeB7F6A832313C7536;
    uint256 public landPrice = 1500000000000000000000;
    uint256 public mineralExchangeRate = 2000000000000000000;
    uint256 public energyExchangeRate = 3000000000000000000;
    uint256[] public ppgPriceList = [3800,10100,25200,4200,11200,28000];
    uint256[] public ppfPriceList = [2200,5900,14800,1800,4800,12000];
    uint256[] public hourDurable = [75,200,450,100,250,550];
    uint256[] public hourEnergy = [0,0,0,75,225,600];
    uint256[] public hourProduce = [645,1750,4374,830,2270,5700];
    
    //领地上线时间
    mapping(uint256 => uint256) private onlineTime;
    //领地税收
    mapping(uint256 => uint256) private energyTax;
    //领地税收
    mapping(uint256 => uint256) private mineralTax;
    //地址 =>  领地tokenId  猎场
    mapping(address => uint256) private huntLandDetail;
    //领地tokenId => (位置编号 => ConfGoods)
    mapping(uint256 => mapping(uint256 => ConfGoods)) private confDetail;
    //领地tokenId => [位置编号集合])
    mapping(uint256 => EnumerableSet.UintSet) private seatNosOfLandId;
    //地址对应的生肉资产
    mapping(address => uint256) private energyAssets;
    //地址对应的矿石资产
    mapping(address => uint256) private mineralAssets;

    function getNftObj(uint256 typeVal) public view returns (IERC721){
        if(typeVal == 1){
            return wep1Nft;
        }else if(typeVal == 2){
            return wep2Nft;
        }else if(typeVal == 3){
            return wep3Nft;
        }else if(typeVal == 4){
            return dev1Nft;
        }else if(typeVal == 5){
            return dev2Nft;
        }else{
            return dev3Nft;
        }
    }

    function getPriceOfPPG(uint256 typeVal) public view returns(uint256){
        return ppgPriceList[typeVal-1].mul(1000000000000000000);
    }
    function getPriceOfPPF(uint256 typeVal) public view returns(uint256){
        return ppfPriceList[typeVal-1].mul(1000000000000000000);
    }
    function getHourDurable(uint256 typeVal) public view returns(uint256){
        return hourDurable[typeVal-1];
    }
    function getHourEnergy(uint256 typeVal) public view returns(uint256){
        return hourEnergy[typeVal-1];
    }
    function getHourProduce(uint256 typeVal) public view returns(uint256){
        return hourProduce[typeVal-1];
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setLandPrice(uint256 _landPrice) external onlyOwner {
        landPrice = _landPrice;
    }

    function setNftObj(address goods1,address goods2,address goods3,address goods4,address goods5,address goods6,address land) external onlyOwner {
        wep1Nft = IERC721(goods1);
        wep2Nft = IERC721(goods2);
        wep3Nft = IERC721(goods3);
        dev1Nft = IERC721(goods4);
        dev2Nft = IERC721(goods5);
        dev3Nft = IERC721(goods6);
        landNft = IERC721(land);
    }

    function buyGoods(uint256 typeVal,uint256 num) public {
        require(typeVal >= 1 && typeVal <= 6,"type error");
        require(num >= 1 && num <= 5,"num error");

        IERC721 nftObj = getNftObj(typeVal);
        require(nftObj.balanceOf(msg.sender).add(num) <= 5,"exceed personal limit");
        require(nftObj.balanceOf(address(this)) >= num,"goods balance not enough");

        uint256 ppgCost = num.mul(getPriceOfPPG(typeVal));
        uint256 ppfCost = num.mul(getPriceOfPPF(typeVal));
        
        //50%销毁
        uint256 ppgDestroy = ppgCost/2;
        uint256 ppfDestroy = ppfCost/2;
        ppgToken.transferFrom(address(msg.sender),address(0),ppgDestroy);
        ppfToken.transferFrom(address(msg.sender),address(0),ppfDestroy);

        ppgToken.transferFrom(address(msg.sender),devAddress,ppgCost-ppgDestroy);
        ppfToken.transferFrom(address(msg.sender),devAddress,ppfCost-ppfDestroy);

        uint256[] memory tokenIds = nftObj.tokensOfOwner(address(this));
        for(uint256 i = 0;i < num;i++){
            uint256 tokenId = tokenIds[i];
            nftObj.transferFrom(address(this), address(msg.sender), tokenId);
        }
    }

    function buyLand() public {
        require(landNft.balanceOf(msg.sender) == 0,"owned land");
        uint256[] memory tokenIds = landNft.unLockedTokensOfOwner(address(this));
        require(tokenIds.length > 0,"no land to sold");

        usdtToken.transferFrom(address(msg.sender),devAddress,landPrice);

        uint256 tokenId = tokenIds[0];
        landNft.transferFrom(address(this), address(msg.sender), tokenId);
    }

    function getAssetsBalance(address addr) public view returns (uint256,uint256){
        return (energyAssets[addr],mineralAssets[addr]);
    }

    struct ConfGoods {
        bool isConf;
        address holder;//拥有者
        uint256 goodsType;//道具类型
        uint256 goodsTokenId;//道具ID
        uint256 landTokenId;//领地ID
        uint256 seatNo;//位置编号 1~30
        uint256 confTime;//配置时间
        uint256 takeTime;//上次领取时间
        uint256 takeCount;//领取次数
    }

    function onlineMyLand(uint256 landTokenId) public {
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        require(!landNft.isLocked(landTokenId),"the landTokenId is locked");
        onlineTime[landTokenId] = block.timestamp;
        landNft.setLocked(landTokenId);
    }

    function offlineMyLand(uint256 landTokenId) public {
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        require(landNft.isLocked(landTokenId),"the landTokenId is unlocked");
        ConfGoods[] memory confList = getConfList(landTokenId);
        require(confList.length == 0,"the landTokenId is not empty");
        delete onlineTime[landTokenId];
        landNft.unLocked(landTokenId);
    }

    function onlineLand(uint256[] memory tokenIds) external onlyOwner {
        require(tokenIds.length > 0,"tokenIds is empty");
        for(uint256 i = 0;i < tokenIds.length; i++){
            uint256 landTokenId = tokenIds[i];
            require(landNft.ownerOf(landTokenId) == address(this), "the landTokenId is not own");
            require(!landNft.isLocked(landTokenId),"the landTokenId is locked");
            onlineTime[landTokenId] = block.timestamp;
            landNft.setLocked(landTokenId);
        }
    }

    function offlineLand(uint256[] memory tokenIds) external onlyOwner {
        for(uint256 i = 0;i < tokenIds.length; i++){
            uint256 landTokenId = tokenIds[i];
            require(landNft.ownerOf(landTokenId) == address(this), "the landTokenId is not own");
            require(landNft.isLocked(landTokenId),"the landTokenId is unlocked");
            ConfGoods[] memory confList = getConfList(landTokenId);
            require(confList.length == 0,"the landTokenId is not empty");
            delete onlineTime[landTokenId];
            landNft.unLocked(landTokenId);
        }
    }

    function getLandInfo(uint256 landTokenId) public view returns(bool landStatus,uint256 landTime,uint256 landCount,uint256 tax1,uint256 tax2){
        landStatus = landNft.isLocked(landTokenId);
        landTime = onlineTime[landTokenId];
        landCount = seatNosOfLandId[landTokenId].length();
        tax1 = mineralTax[landTokenId];
        tax2 = energyTax[landTokenId];
    }

    function addManyGoodsToLand(uint256 landTokenId,uint256 goodsType,uint256 goodsNum) public {
        require(landNft.isLocked(landTokenId), "the landTokenId is not online");
        require(goodsType >= 1 && goodsType <= 6,"goodsType error");
        require(goodsNum >= 1 && goodsNum <= 5,"goodsNum error");
        
        IERC721 nftObj = getNftObj(goodsType);
        uint256[] memory unlockedTokenIds = nftObj.unLockedTokensOfOwner(msg.sender);
        require(goodsNum <= unlockedTokenIds.length, "unlocked goods not enough");

        ConfGoods[] memory confList = getConfList(landTokenId);
        uint256 remainSeatNum = 30-confList.length;
        require(goodsNum <= remainSeatNum, "remain seat not enough");

        if(huntLandDetail[msg.sender] == 0){
            huntLandDetail[msg.sender] = landTokenId;
        }else{
            require(huntLandDetail[msg.sender] == landTokenId,"not my huntgound");
            ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
            if(myConfList.length > 0){
                uint256 type1Count = 0;
                uint256 type2Count = 0;
                for (uint256 i = 0; i < myConfList.length; i++) {
                    if(myConfList[i].goodsType <=3){
                        type1Count = type1Count +1;
                    }else{
                        type2Count = type2Count +1;
                    }
                }
                if(goodsType<=3){
                    require(type1Count+goodsNum <=5,"weapon is out range");
                }else{
                    require(type2Count+goodsNum <=5,"device is out range");
                }
            }
        }

        uint256 addNum = 0;
        for(uint256 seatNo=1;seatNo<=30;seatNo++){
            if(goodsNum > addNum && !confDetail[landTokenId][seatNo].isConf){
                uint256 goodsTokenId = unlockedTokenIds[addNum];
                ConfGoods memory confInfo = ConfGoods({
                    isConf:true,
                    holder:msg.sender,
                    goodsType:goodsType,
                    goodsTokenId:goodsTokenId,
                    landTokenId:landTokenId,
                    seatNo:seatNo,
                    confTime:block.timestamp,
                    takeTime:block.timestamp,
                    takeCount:0
                });
                confDetail[landTokenId][seatNo] = confInfo;
                seatNosOfLandId[landTokenId].add(seatNo);
                nftObj.setLocked(goodsTokenId);
                addNum = addNum+1;
            }
        }
    }

    function getConfList(uint256 landTokenId) public view returns (ConfGoods[] memory){
        EnumerableSet.UintSet storage seatNos = seatNosOfLandId[landTokenId];
        uint256 size = seatNos.length();
        if (size == 0) {
            return new ConfGoods[](0);
        }
        ConfGoods[] memory result = new ConfGoods[](size);
        for (uint256 i = 0; i < size; i++) {
            result[i] = confDetail[landTokenId][seatNos.at(i)];
        }
        return result;
    }

    function getHuntLand(address holder) public view returns (uint256){
        return huntLandDetail[holder];
    }

    function calcLandRepairTotalCost(uint256 landTokenId,address holder) public view returns (uint256,uint256){
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,holder);
        if(myConfList.length==0){
            return (0,0);
        }
        return _calcLandRepairTotalCost(myConfList);   
    }

    function getConfListByHolder(uint256 landTokenId,address holder) public view returns (ConfGoods[] memory){
        ConfGoods[] memory confList = getConfList(landTokenId);
        uint256 count = 0;
        for (uint256 i = 0; i < confList.length; i++) {
            if(confList[i].holder == holder){
                count = count +1;
            }
        }
        if(count == 0){
            return new ConfGoods[](0);
        }
        ConfGoods[] memory result = new ConfGoods[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < confList.length; i++) {
            if(confList[i].holder == holder){
                result[index] = confList[i];
                index = index + 1;
            }
        }
        return result;
    }

    function removeAll(uint256 landTokenId) public {
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        require(myConfList.length>0,"no conf");
        repairAll(landTokenId);
        uint256[] memory seatNos = new uint256[](myConfList.length);
        for (uint256 i = 0; i < myConfList.length; i++) {
            ConfGoods memory confInfo = myConfList[i];
            seatNos[i] = confInfo.seatNo;
            IERC721 nftObj = getNftObj(confInfo.goodsType);
            nftObj.unLocked(confInfo.goodsTokenId);
        }
        for (uint256 i = 0; i < seatNos.length; i++) {
            delete confDetail[landTokenId][seatNos[i]];
            seatNosOfLandId[landTokenId].remove(seatNos[i]);
        }
        delete huntLandDetail[msg.sender];
    }

    function repairAll(uint256 landTokenId) public {
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        require(myConfList.length>0,"no conf");
        (uint256 ppgCost,uint256 ppfCost) = _calcLandRepairTotalCost(myConfList);
        if(ppgCost > 0){
            ppgToken.transferFrom(address(msg.sender),address(this),ppgCost);
        }
        if(ppfCost > 0){
            ppfToken.transferFrom(address(msg.sender),address(this),ppfCost);
        }
        for (uint256 i = 0; i < myConfList.length; i++) {
            confDetail[landTokenId][myConfList[i].seatNo].takeCount = 0;
        }
    }

    function _calcLandRepairTotalCost(ConfGoods[] memory confList) internal view returns (uint256 ppgCost,uint256 ppfCost){
        uint256 needDu = 0;
        uint256 needEn = 0;
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            needDu = needDu + confInfo.takeCount*getHourDurable(confInfo.goodsType);
            needEn = needEn + confInfo.takeCount*getHourEnergy(confInfo.goodsType);
        }
        if(needDu > 0){
            ppgCost = needDu * 1000000000000000000 / 5;
        }
        if(needEn > 0){
            ppfCost = needEn * 1000000000000000000 / 5;
        }
    }

    function takeConf(uint256 landTokenId,uint256 seatNo) public {
        ConfGoods memory confInfo = confDetail[landTokenId][seatNo];
        require(confDetail[landTokenId][seatNo].isConf,"seat is empty");
        require(confInfo.takeCount < 20,"is stop");
        require(block.timestamp-confInfo.takeTime >= 3600,"Less than an hour");
        address landOwner = landNft.ownerOf(confInfo.landTokenId);
        if(confInfo.goodsType <= 3){
            uint256 energyTotal = getHourProduce(confInfo.goodsType);
            uint256 tax1 = energyTotal*5/100;
            energyAssets[landOwner] = energyAssets[landOwner] + tax1;
            energyTax[confInfo.landTokenId] = energyTax[confInfo.landTokenId] + tax1;
            energyAssets[msg.sender] = energyAssets[msg.sender] + energyTotal - tax1;
        }else{
            uint256 mineralTotal = getHourProduce(confInfo.goodsType);
            uint256 tax2 = mineralTotal*5/100;
            mineralAssets[landOwner] = mineralAssets[landOwner] + tax2;
            mineralTax[confInfo.landTokenId] = mineralTax[confInfo.landTokenId] + tax2;
            mineralAssets[msg.sender] = mineralAssets[msg.sender] + mineralTotal - tax2;
        }
        confDetail[landTokenId][seatNo].takeCount = confDetail[landTokenId][seatNo].takeCount + 1;
        confDetail[landTokenId][seatNo].takeTime = block.timestamp;
    }

    function getExchangeRate() public view returns (uint256,uint256){
        return (energyExchangeRate,mineralExchangeRate);
    }

    function setExchangeRate(uint256 _energyRate,uint256 _mineralRate) external onlyOwner {
        energyExchangeRate = _energyRate;
        mineralExchangeRate = _mineralRate;
    }

    function exchange(uint256 exType,uint256 amount) public {
        if(exType == 1){
            uint256 mineralBalance = mineralAssets[msg.sender];
            require(mineralBalance >= amount, "mineral balance is not enough");
            mineralAssets[msg.sender] = mineralBalance - amount;
            uint256 receivePPG = mineralExchangeRate * amount;
            ppgToken.transfer(address(msg.sender),receivePPG);
        }else{
            uint256 energyBalance = energyAssets[msg.sender];
            require(energyBalance >= amount, "energy balance is not enough");
            energyAssets[msg.sender] = energyBalance - amount;
            uint256 receivePPF = energyExchangeRate * amount;
            ppfToken.transfer(address(msg.sender),receivePPF);
        }
    }
}