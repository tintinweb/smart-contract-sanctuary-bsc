/**
 *Submitted for verification at BscScan.com on 2022-04-09
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
    IERC721 public wep1Nft = IERC721(0x1ACf37b41b2A04117275C209d5Ded82A596979cb);
    IERC721 public wep2Nft = IERC721(0x78337874C55c7946858c3C1dC779f1285c65b4d3);
    IERC721 public wep3Nft = IERC721(0x2383BFA317cCa4fB793B6D763dAD5fa9A7e7DD17);
    IERC721 public dev1Nft = IERC721(0x1ACf37b41b2A04117275C209d5Ded82A596979cb);
    IERC721 public dev2Nft = IERC721(0x1ACf37b41b2A04117275C209d5Ded82A596979cb);
    IERC721 public dev3Nft = IERC721(0x1ACf37b41b2A04117275C209d5Ded82A596979cb);
    IERC721 public landNft = IERC721(0x3084BC0de90Cf8081836A1418aa28af3E0dE04ff);
    IBEP20 public ppgToken = IBEP20(0xc1E0932BA301fB0044383bd6b84c02b14b66d6d1);
    IBEP20 public ppfToken = IBEP20(0xed9066Bcb04Cdc9D76246E57AB64Fd3f55Ff994E);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    address private devAddress = 0xA356A7A8aC0c780dd28125aeB7F6A832313C7536;
    uint256 public landPrice = 1500000000000000000000;
    uint256 public mineralExchangeRate = 1000000000000000000;
    uint256 public rawMeatExchangeRate = 1000000000000000000;
    uint256[] public ppgPriceList = [3800,10100,25200,4200,11200,28000];
    uint256[] public ppfPriceList = [2200,5900,14800,1800,4800,12000];
    uint256[] public initDurable = [1500,4000,9000,2000,5000,11000];
    uint256[] public lossDurable = [75,200,450,100,250,550];
    uint256[] public initEnergy = [0,0,0,1500,4500,12000];
    uint256[] public lossEnergy = [0,0,0,75,225,600];
    uint256[] public produce = [645,1750,4374,830,2270,5700];

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
    function getInitDurable(uint256 typeVal) public view returns(uint256){
        return initDurable[typeVal-1];
    }
    function getLossDurableOneHour(uint256 typeVal) public view returns(uint256){
        return lossDurable[typeVal-1];
    }
    function getInitEnergy(uint256 typeVal) public view returns(uint256){
        return initEnergy[typeVal-1];
    }
    function getLossEnergyOneHour(uint256 typeVal) public view returns(uint256){
        return lossEnergy[typeVal-1];
    }
    function getProduceOneHour(uint256 typeVal) public view returns(uint256){
        return produce[typeVal-1];
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setLandPrice(uint256 _landPrice) external onlyOwner {
        landPrice = _landPrice;
    }

    function getGoodsKeepHour(uint256 typeVal) public view returns (uint256 durableHour,uint256 energyHour){
        durableHour = getInitDurable(typeVal) / getLossDurableOneHour(typeVal);
        uint256 lossEnOneHour = getLossEnergyOneHour(typeVal);
        if(lossEnOneHour == 0){
            energyHour = 99999999999999;
        }else{
            energyHour = getInitEnergy(typeVal)/ lossEnOneHour;
        }
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

    //================商店 start===============
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
    //================商店 end===============


    //================领地 start===============
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    //领地上线时间
    mapping(uint256 => uint256) private onlineTime;
    //领地税收
    mapping(uint256 => uint256) private rawMeatTax;
    //领地税收
    mapping(uint256 => uint256) private mineralTax;
    

    //地址 =>  [猎场领地tokenId集合]  猎场
    mapping(address => EnumerableSet.UintSet) private huntLandDetail;
    //领地tokenId => [猎手地址集合])  猎手
    mapping(uint256 => EnumerableSet.AddressSet) private hunterDetail;

    //领地tokenId => (位置编号 => ConfGoods)
    mapping(uint256 => mapping(uint256 => ConfGoods)) private confDetail;
    //领地tokenId => [位置编号集合])
    mapping(uint256 => EnumerableSet.UintSet) private seatNosOfLandId;
    // 领地tokenId => (地址 => 最近领取时间)
    mapping(uint256 => mapping(address => uint256)) private lastTakeTimeDetail;
    //地址对应的生肉资产
    mapping(address => uint256) private rawMeatAssets;
    //地址对应的矿石资产
    mapping(address => uint256) private mineralAssets;

    function getAssetsBalance(address addr) public view returns (uint256,uint256){
        return (rawMeatAssets[addr],mineralAssets[addr]);
    }

    //在领地上组装道具
    struct ConfGoods {
        bool isConf;
        address holder;//拥有者
        uint256 goodsType;//道具类型
        uint256 goodsTokenId;//道具ID
        uint256 landTokenId;//领地ID
        uint256 seatNo;//位置编号 1~30
        uint256 confTime;//配置时间
        uint256 remainDu;
        uint256 remainEn;
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
        tax2 = rawMeatTax[landTokenId];
    }


    function addManyGoodsToLand(uint256 landTokenId,uint256 goodsType,uint256 goodsNum) public {
        require(landNft.isLocked(landTokenId), "the landTokenId is not online");
        require(goodsType >= 1 && goodsType <= 6,"goodsType error");
        require(goodsNum >= 1,"goodsNum error");
        
        IERC721 nftObj = getNftObj(goodsType);
        uint256[] memory unlockedTokenIds = nftObj.unLockedTokensOfOwner(msg.sender);
        require(goodsNum <= unlockedTokenIds.length, "unlocked goods not enough");

        ConfGoods[] memory confList = getConfList(landTokenId);
        uint256 remainSeatNum = 30-confList.length;
        require(goodsNum <= remainSeatNum, "remain seat not enough");

        if(!huntLandDetail[msg.sender].contains(landTokenId)){
            huntLandDetail[msg.sender].add(landTokenId);
        }
        if(!hunterDetail[landTokenId].contains(msg.sender)){
            hunterDetail[landTokenId].add(msg.sender);
        }

        uint256 addNum = 0;
        for(uint256 seatNo=1;seatNo<=30;seatNo++){
            if(goodsNum > addNum && !confDetail[landTokenId][seatNo].isConf){
                uint256 goodsTokenId = unlockedTokenIds[addNum];
                //创建配置数据
                ConfGoods memory confInfo = ConfGoods({
                    isConf:true,
                    holder:msg.sender,
                    goodsType:goodsType,
                    goodsTokenId:goodsTokenId,
                    landTokenId:landTokenId,
                    seatNo:seatNo,
                    confTime:block.timestamp,
                    remainDu:0,
                    remainEn:0
                });
                confDetail[landTokenId][seatNo] = confInfo;
                seatNosOfLandId[landTokenId].add(seatNo);
                //将道具设置为锁定状态
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
            ConfGoods memory conf = confDetail[landTokenId][seatNos.at(i)];
            (uint256 remainDu,uint256 remainEn) = _calcConfInfoRemain(conf);
            conf.remainDu = remainDu;
            conf.remainEn = remainEn;
            result[i] = conf;
        }
        return result;
    }

    function getHuntLand() public view returns (uint256[] memory){
        return huntLandDetail[msg.sender]._values;
    }

    function getConfListByHolder(uint256 landTokenId,address holder) public view returns (ConfGoods[] memory){
        EnumerableSet.UintSet storage seatNos = seatNosOfLandId[landTokenId];
        uint256 size = seatNos.length();
        if (size == 0) {
            return new ConfGoods[](0);
        }
        ConfGoods[] memory confList = new ConfGoods[](size);
        for (uint256 i = 0; i < size; i++) {
            ConfGoods memory conf = confDetail[landTokenId][seatNos.at(i)];
            confList[i] = conf;
        }
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

    //卸下领地上的道具
    function removeAll(uint256 landTokenId) public {
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        if(myConfList.length == 0){
            return;
        }
        //修复装备耐久和体能
        repairAll(landTokenId);

        uint256[] memory seatNos = new uint256[](myConfList.length);
        //解除每件装备的锁定状态
        for (uint256 i = 0; i < myConfList.length; i++) {
            ConfGoods memory confInfo = myConfList[i];
            seatNos[i] = confInfo.seatNo;
            IERC721 nftObj = getNftObj(confInfo.goodsType);
            nftObj.unLocked(confInfo.goodsTokenId);
        }
        
        //根据位置编号集合循环删除领地配置数据
        for (uint256 i = 0; i < seatNos.length; i++) {
            delete confDetail[landTokenId][seatNos[i]];
            seatNosOfLandId[landTokenId].remove(seatNos[i]);
        }
        //删除领地最近领取时间数据
        delete lastTakeTimeDetail[landTokenId][msg.sender];

        huntLandDetail[msg.sender].remove(landTokenId);
        hunterDetail[landTokenId].remove(msg.sender);
    }

    //修复该领地上我的所有装备的耐久值和体能
    function repairAll(uint256 landTokenId) public {
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        if(myConfList.length == 0){
            return;
        }
        //结算所有收益
        takeAll(landTokenId);
        //计算得出所需要的金币和肉币
        (uint256 ppgCost,uint256 ppfCost) = calcLandRepairTotalCost(landTokenId);
        if(ppgCost > 0){
            ppgToken.transferFrom(address(msg.sender),address(this),ppgCost);
        }
        if(ppfCost > 0){
            ppfToken.transferFrom(address(msg.sender),address(this),ppfCost);
        }
        //重置配置时间
        for (uint256 i = 0; i < myConfList.length; i++) {
            ConfGoods memory confInfo = myConfList[i];
            confInfo.confTime = block.timestamp;
        }
    }
    
    // 计算修复我在该领地上所有装备的耐久和体能值需要的PPG和PPF数量
    function calcLandRepairTotalCost(uint256 landTokenId) public view returns (uint256 ppgCost,uint256 ppfCost){
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        if(myConfList.length == 0){
            return (0,0);
        }
        uint256 needDu = 0;
        uint256 needEn = 0;
        for (uint256 i = 0; i < myConfList.length; i++) {
            ConfGoods memory confInfo = myConfList[i];
            (uint256 remainDu,uint256 remainEn) = _calcConfInfoRemain(confInfo);
            needDu = needDu + (getInitDurable(confInfo.goodsType) - remainDu);
            needEn = needEn + (getInitEnergy(confInfo.goodsType) - remainEn);
        }
        if(needDu > 0){
            ppgCost = needDu * 1000000000000000000 / 5;
        }
        if(needEn > 0){
            ppfCost = needEn * 1000000000000000000 / 5;
        }
    }

    //一键领取该领地上我的所有装备的产出
    function takeAll(uint256 landTokenId) public {
        (uint256 rawMeatTotal,uint256 mineralTotal) = calcLandTotalProduce(landTokenId);

        address landOwner = landNft.ownerOf(landTokenId);
        if(rawMeatTotal > 0){
            uint256 tax1 = rawMeatTotal*5/100;
            rawMeatAssets[landOwner] = rawMeatAssets[landOwner] + tax1;
            rawMeatTax[landTokenId] = rawMeatTax[landTokenId] + tax1;
            rawMeatAssets[msg.sender] = rawMeatAssets[msg.sender] + rawMeatTotal-tax1;
        }
        if(mineralTotal > 0 ){
            uint256 tax2 = mineralTotal*5/100;
            mineralAssets[landOwner] = mineralAssets[landOwner] + tax2;
            mineralTax[landTokenId] = mineralTax[landTokenId] + tax2;
            mineralAssets[msg.sender] = mineralAssets[msg.sender] + mineralTotal-tax2;
        }
        //更新最近领取时间
        lastTakeTimeDetail[landTokenId][msg.sender] = block.timestamp;
    }

    //计算我在该领地上所有装备的全部产出
    function calcLandTotalProduce(uint256 landTokenId) public view returns (uint256,uint256){
        ConfGoods[] memory myConfList = getConfListByHolder(landTokenId,msg.sender);
        uint256 rawMeatTotal = 0;
        uint256 mineralTotal = 0;
        for (uint256 i = 0; i < myConfList.length; i++) {
            ConfGoods memory confInfo = myConfList[i];
            (uint256 rawMeatVal,uint256 mineralVal) = _calcConfInfoProduce(confInfo);
            rawMeatTotal = rawMeatTotal + rawMeatVal;
            mineralTotal = mineralTotal + mineralVal;
        }
        return (rawMeatTotal,mineralTotal);
    }


    //================ 公共方法部分 ===============
    //计算配置的修复实际消耗
    function _calcConfInfoRepairCost(ConfGoods memory confInfo) internal view returns (uint256 ppgCost,uint256 ppfCost){
        (uint256 remainDu,uint256 remainEn) = _calcConfInfoRemain(confInfo);
        uint256 needDu = getInitDurable(confInfo.goodsType) - remainDu;
        uint256 needEn = getInitEnergy(confInfo.goodsType) - remainEn;
        if(needDu > 0){
            ppgCost = needDu * 1000000000000000000 / 5;
        }
        if(needEn > 0){
            ppfCost = needEn * 1000000000000000000 / 5;
        }
    }
    //计算配置的实际产出
    function _calcConfInfoProduce(ConfGoods memory confInfo) internal view returns (uint256 rawMeatVal,uint256 mineralVal){
        //领地的上次领取时间
        uint256 lastTakeTime = lastTakeTimeDetail[confInfo.landTokenId][confInfo.holder];

        //已损耗时长
        uint256 lastLossHour = 0;
        if(confInfo.confTime < lastTakeTime){
            lastLossHour = (lastTakeTime - confInfo.confTime) / 3600;
        }
        //耐久和体能坚持时长
        (uint256 durableHour,uint256 energyHour) = getGoodsKeepHour(confInfo.goodsType);
        
        //耐久或体能上次已经消耗完了，没有产出了
        if(lastLossHour >= durableHour || lastLossHour >= energyHour){
            return (0,0);
        }else{
            //当前距离配置总时长
            uint256 diffHour = (block.timestamp - confInfo.confTime) / 3600;
            //本次生产时长 = 实际坚持时长（距离配置总时长、耐久坚持时长、体能坚持时长中的最小值）- 已损耗的时长
            uint256 proHour = 0;
            if(diffHour <= durableHour && diffHour <= energyHour){
                proHour = diffHour - lastLossHour;
            }else if(durableHour <= diffHour && durableHour <= energyHour){
                proHour = durableHour - lastLossHour;
            }else{
                proHour = energyHour - lastLossHour;
            }
            uint256 proVal = getProduceOneHour(confInfo.goodsType) * proHour;
            if(confInfo.goodsType <= 3){
                return (proVal,0);
            }else{
                return (0,proVal);
            }
        }
    }
    //计算配置的剩余耐久和体能值
    function _calcConfInfoRemain(ConfGoods memory confInfo) internal view returns (uint256 remainDu,uint256 remainEn){
        //计算实际损耗时长，不满一小时按0小时计算
        uint256 diffHour = (block.timestamp - confInfo.confTime) / 3600;
        //耐久和体能坚持时长
        (uint256 durableHour,uint256 energyHour) = getGoodsKeepHour(confInfo.goodsType);
        //实际损耗时长
        uint256 lossHour = 0;
        if(diffHour <= durableHour && diffHour <= energyHour){
            lossHour = diffHour;
        }else if(durableHour < diffHour && durableHour < energyHour){
            lossHour = durableHour;
        }else {
            lossHour = energyHour;
        }
        //实际损耗耐久和体能
        uint256 lossDu = lossHour * getLossDurableOneHour(confInfo.goodsType);
        uint256 lossEn = lossHour * getLossEnergyOneHour(confInfo.goodsType);
        return (getInitDurable(confInfo.goodsType) - lossDu,getInitEnergy(confInfo.goodsType) - lossEn);
    }
    //================领地 end===============


    //================兑换 start===============
    function getExchangeRate() public view returns (uint256,uint256){
        return (rawMeatExchangeRate,mineralExchangeRate);
    }

    function setExchangeRate(uint256 _rawMeatRate,uint256 _mineralRate) external onlyOwner {
        rawMeatExchangeRate = _rawMeatRate;
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
            uint256 rawMeatBalance = rawMeatAssets[msg.sender];
            require(rawMeatBalance >= amount, "rawmeat balance is not enough");
            rawMeatAssets[msg.sender] = rawMeatBalance - amount;
            uint256 receivePPF = rawMeatExchangeRate * amount;
            ppfToken.transfer(address(msg.sender),receivePPF);
        }
    }
}