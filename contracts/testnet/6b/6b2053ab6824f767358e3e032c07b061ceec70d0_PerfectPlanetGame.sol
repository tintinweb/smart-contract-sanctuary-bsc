/**
 *Submitted for verification at BscScan.com on 2022-03-29
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
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
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
    function test() external view returns (address);
}

contract PerfectPlanetGame is ERC721Holder,Ownable {
    using SafeMath for uint256;
    //武器1
    IERC721 public wep1Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //武器2
    IERC721 public wep2Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //武器1
    IERC721 public wep3Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //设备1
    IERC721 public dev1Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //设备2
    IERC721 public dev2Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //设备3
    IERC721 public dev3Nft = IERC721(0x9fAF4a02916E458340c7ac559068DF9aaD00dCaA);
    //领地
    IERC721 public landNft = IERC721(0x3161344fC0ced6a184D70DC71af730B02c027b01);
    //盲盒
    IERC721 public boxNft = IERC721(0x0C51588C194F891893aeddD1CEB6540E9e4444C0);
    //金币PPG
    IBEP20 public ppgToken = IBEP20(0xc1E0932BA301fB0044383bd6b84c02b14b66d6d1);
    //肉币PPF
    IBEP20 public ppfToken = IBEP20(0xed9066Bcb04Cdc9D76246E57AB64Fd3f55Ff994E);
    //USDT合约
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    //收款地址
    address private devAddress = 0xA356A7A8aC0c780dd28125aeB7F6A832313C7536;

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

    function getPriceOfPPG(uint256 typeVal) public pure returns (uint256){
        if(typeVal == 1){
            return 4000000000000000000000;
        }else if(typeVal == 2){
            return 4000000000000000000000;
        }else if(typeVal == 3){
            return 4000000000000000000000;
        }else if(typeVal == 4){
            return 4000000000000000000000;
        }else if(typeVal == 5){
            return 4000000000000000000000;
        }else{
            return 4000000000000000000000;
        }
    }

    function getPriceOfPPF(uint256 typeVal) public pure returns(uint256){
        if(typeVal == 1){
            return 800000000000000000000;
        }else if(typeVal == 2){
            return 800000000000000000000;
        }else if(typeVal == 3){
            return 800000000000000000000;
        }else if(typeVal == 4){
            return 800000000000000000000;
        }else if(typeVal == 5){
            return 800000000000000000000;
        }else{
            return 800000000000000000000;
        }
    }

    function getLossDurableOneHour(uint256 typeVal) public pure returns(uint256){
        if(typeVal == 1){
            return 5;
        }else if(typeVal == 2){
            return 15;
        }else if(typeVal == 3){
            return 45;
        }else if(typeVal == 4){
            return 5;
        }else if(typeVal == 5){
            return 20;
        }else{
            return 32;
        }
    }

    function getLossEnergyOneHour(uint256 typeVal) public pure returns(uint256){
        if(typeVal == 1){
            return 10;
        }else if(typeVal == 2){
            return 30;
        }else if(typeVal == 3){
            return 60;
        }else{
            return 0;
        }
    }

    //每小时的产出数量
    function getProduceOneHour(uint256 typeVal) public pure returns(uint256){
        if(typeVal == 1){
            return 5;
        }else if(typeVal == 2){
            return 17;
        }else if(typeVal == 3){
            return 54;
        }else if(typeVal == 4){
            return 5;
        }else if(typeVal == 5){
            return 20;
        }else{
            return 80;
        }
    }

    //================购买武器、装备start===============
    function buyGoods(uint256 typeVal,uint256 num) public {
        require(typeVal >= 1 && typeVal <= 6,"type error");
        require(num >= 1 && num <= 5,"num error");

        IERC721 nftObj = getNftObj(typeVal);
        require(nftObj.balanceOf(msg.sender).add(num) <= 5,"exceed personal limit");
        require(nftObj.balanceOf(address(this)) >= num,"goods balance not enough");

        uint256 ppgPrice = getPriceOfPPG(typeVal);
        uint256 ppfPrice = getPriceOfPPF(typeVal);
        uint256 ppgCost = num.mul(ppgPrice);
        uint256 ppfCost = num.mul(ppfPrice);
        ppgToken.transferFrom(address(msg.sender),address(this),ppgCost);
        ppfToken.transferFrom(address(msg.sender),address(this),ppfCost);

        uint256[] memory tokenIds = nftObj.tokensOfOwner(address(this));
        for(uint256 i = 0;i < num;i++){
            uint256 tokenId = tokenIds[i];
            nftObj.transferFrom(address(this), address(msg.sender), tokenId);
        }
    }
    //================购买武器、装备 end===============


    //================领地 start===============
    using EnumerableSet for EnumerableSet.UintSet;
    //领地价格1500U
    uint256 public landPrice = 1500000000000000000000;
    //领地tokenId => (位置编号 =》 ConfGoods)
    mapping(uint256 => mapping(uint256 => ConfGoods)) private confDetail;
    //领地tokenId => [位置编号集合])
    mapping(uint256 => EnumerableSet.UintSet) private seatNosOfLandId;
    //装备类型（1-6）=》（装备tokenId => 耐久）
    mapping(uint256 => mapping(uint256 => uint256)) private durableDetail;
    //装备类型（1-6）=》（装备tokenId => 体能)
    mapping(uint256 => mapping(uint256 => uint256)) private energyDetail;
    //已经参与过配置的装备集合，装备类型（1-6）=》（装备tokenId集合)
    mapping(uint256 => EnumerableSet.UintSet) private tokenIdsOfType;
    //领地最近领取时间
    mapping(uint256 => uint256) private lastTakeTimeDetail;
    //地址对应的生肉资产
    mapping(address => uint256) private rawMeatAssets;
    //地址对应的矿石资产
    mapping(address => uint256) private mineralAssets;



    //购买领地
    function buyLand(uint256 num) public {
        require(num == 1,"num error");
        require(landNft.balanceOf(msg.sender) == 0,"owned land");
        require(landNft.balanceOf(address(this)) >= num,"land balance not enough");
        uint256[] memory tokenIds = landNft.tokensOfOwner(address(this));

        uint256 cost = num.mul(landPrice);
        usdtToken.transferFrom(address(msg.sender),devAddress,cost);

        uint256 tokenId = tokenIds[0];
        landNft.transferFrom(address(this), address(msg.sender), tokenId);
    }

    //在领地上组装道具
    struct ConfGoods {
        bool isConf;
        uint256 goodsType;//道具类型
        uint256 goodsTokenId;//道具ID
        uint256 landTokenId;//领地ID
        uint256 seatNo;//位置编号 1~30
        uint256 confTime;//配置时间
    }

    //在领地上配置道具
    function addGoodsToLand(uint256 landTokenId,uint256 seatNo,uint256 goodsType,uint256 goodsTokenId) public {
        require(goodsType >= 1 && goodsType <= 6,"type error");
        require(seatNo >= 1 && seatNo <= 30 ,"seatNo error");
        IERC721 nftObj = getNftObj(goodsType);
        require(nftObj.ownerOf(goodsTokenId) == msg.sender, "the goodsTokenId is not own");
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");

        //道具没有被锁住
        require(nftObj.isLocked(goodsTokenId) == false, "goods is Locked");
        //领地位置必须空的
        require(confDetail[landTokenId][seatNo].isConf == false, "seatNo is not empty");

        ConfGoods memory confInfo = ConfGoods({
            isConf:true,
            goodsType:goodsType,
            goodsTokenId:goodsTokenId,
            landTokenId:landTokenId,
            seatNo:seatNo,
            confTime:block.timestamp
        });
        confDetail[landTokenId][seatNo] = confInfo;
        seatNosOfLandId[landTokenId].add(seatNo);
        
        //首次添加，配置初始耐久和体能值
        if(!tokenIdsOfType[goodsType].contains(goodsTokenId)){
            durableDetail[goodsType][goodsTokenId] = 10000;
            energyDetail[goodsType][goodsTokenId] = 10000;
        }
        tokenIdsOfType[goodsType].add(goodsTokenId);
        
        //将领地和道具设置为锁定状态
        landNft.setLocked(landTokenId);
        nftObj.setLocked(goodsTokenId);
    }

    //卸下领地上的道具
    function removeGoodsFromLand(uint256 landTokenId,uint256 seatNo) public {
        require(seatNo >= 1 && seatNo <= 30 ,"seatNo error");
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        //领地位置必须不是空的
        require(confDetail[landTokenId][seatNo].isConf == true, "seatNo is empty");

        ConfGoods memory confInfo = confDetail[landTokenId][seatNo];
        uint256 goodsType = confInfo.goodsType;
        uint256 goodsTokenId = confInfo.goodsTokenId;

        //结算单个装备的收益
        (uint256 rawMeatVal,uint256 mineralVal) = calcConfInfoPro(confInfo);
        if(rawMeatVal > 0){
            rawMeatAssets[msg.sender] = rawMeatAssets[msg.sender] + rawMeatVal;
        }
        if(mineralVal > 0){
            mineralAssets[msg.sender] = mineralAssets[msg.sender] + mineralVal;
        }

        //更新装备的剩余耐久和体能值
        (uint256 remainDu,uint256 remainEn) = calcConfInfoRemain(confInfo);
        durableDetail[goodsType][goodsTokenId] = remainDu;
        energyDetail[goodsType][goodsTokenId] = remainEn;

        //解除道具的锁定状态
        IERC721 nftObj = getNftObj(goodsType);
        nftObj.unLocked(goodsTokenId);

        //删除配置数据
        delete confDetail[landTokenId][seatNo];
        seatNosOfLandId[landTokenId].remove(seatNo);

        //检查领地是否可以解除锁定状态
        ConfGoods[] memory confList = getConfList(landTokenId);
        if(confList.length == 0){
            landNft.unLocked(landTokenId);
        }
    }

    //卸下领地上的道具
    function removeAllFromLand(uint256 landTokenId) public {
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        ConfGoods[] memory confList = getConfList(landTokenId);
        require(confList.length > 0 , "the land is empty");

        //结算领地收益
        takeAll(landTokenId);
        
        //循环计算领地上每件装备的剩余耐久和体能值
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            uint256 goodsType = confInfo.goodsType;
            uint256 goodsTokenId = confInfo.goodsTokenId;

            (uint256 remainDu,uint256 remainEn) = calcConfInfoRemain(confInfo);
            durableDetail[goodsType][goodsTokenId] = remainDu;
            energyDetail[goodsType][goodsTokenId] = remainEn;

            //解除装备的锁定状态
            IERC721 nftObj = getNftObj(goodsType);
            nftObj.unLocked(goodsTokenId);
        }
        
        //删除领地配置数据
        // delete confDetail[landTokenId];
        delete seatNosOfLandId[landTokenId];
        delete lastTakeTimeDetail[landTokenId];

        //解除领地锁定状态
        landNft.unLocked(landTokenId);
    }

    //计算领地配置的装备的实际产出
    function calcConfInfoPro(ConfGoods memory confInfo) public view returns (uint256 rawMeatVal,uint256 mineralVal){
        //领地的上次领取时间
        uint256 lastTakeTime = lastTakeTimeDetail[confInfo.landTokenId];
        uint256 goodsType = confInfo.goodsType;
        uint256 goodsTokenId = confInfo.goodsTokenId;

        //已损耗时长
        uint256 lastLossHour = 0;
        if(confInfo.confTime < lastTakeTime){
            lastLossHour = (lastTakeTime - confInfo.confTime) / 3600;
        }
        //耐久坚持时长
        uint256 durableHour = durableDetail[goodsType][goodsTokenId] / getLossDurableOneHour(goodsType);
        //体能坚持时长
        uint256 energyHour = energyDetail[goodsType][goodsTokenId] / getLossEnergyOneHour(goodsType);
        
        //耐久或体能上次已经消耗完了，没有产出了
        if(lastLossHour >= durableHour || lastLossHour >= energyHour){
            return (0,0);
        }
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

        uint256 proVal = getProduceOneHour(goodsType) * proHour;
        if(goodsType <= 3){
            return (proVal,0);
        }
        return (0,proVal);
    }

    //计算领地配置的装备剩余的耐久和体能值
    function calcConfInfoRemain(ConfGoods memory confInfo) public view returns (uint256 remainDu,uint256 remainEn){
        //领地的上次领取时间
        uint256 goodsType = confInfo.goodsType;
        uint256 goodsTokenId = confInfo.goodsTokenId;
        
        //计算实际损耗时长，不满一小时按0小时计算
        uint256 diffHour = (block.timestamp - confInfo.confTime) / 3600;
        //耐久坚持时长
        uint256 durableHour = durableDetail[goodsType][goodsTokenId] / getLossDurableOneHour(goodsType);
        //体能坚持时长
        uint256 energyHour = energyDetail[goodsType][goodsTokenId] / getLossEnergyOneHour(goodsType);

        //实际损耗时长
        uint256 lossHour = 0;
        if(diffHour <= durableHour && diffHour <= energyHour){
            lossHour = diffHour;
        }else if(durableHour < diffHour && durableHour < energyHour){
            lossHour = durableHour;
        }else {
            lossHour = energyHour;
        }
        //实际损耗耐久
        uint256 lossDu = lossHour * getLossDurableOneHour(goodsType);
        //实际损耗体能
        uint256 lossEn = lossHour * getLossEnergyOneHour(goodsType);
        return (durableDetail[goodsType][goodsTokenId] - lossDu , energyDetail[goodsType][goodsTokenId] - lossEn);
    }

    //获取领地上所有的装备配置数据
    function getConfList(uint256 landTokenId) public view returns (ConfGoods[] memory){
        EnumerableSet.UintSet storage setNos = seatNosOfLandId[landTokenId];
        uint256 size = setNos.length();
        if (size == 0) {
            return new ConfGoods[](0);
        } else {
            ConfGoods[] memory result = new ConfGoods[](size);
            for (uint256 i = 0; i < size; i++) {
                result[i] = confDetail[landTokenId][setNos.at(i)];
            }
            return result;
        }
    }

    //一键领取
    function takeAll(uint256 landTokenId) public {
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        ConfGoods[] memory confList = getConfList(landTokenId);
        require(confList.length > 0 , "the land is empty");

        uint256 rawMeatTotal = 0;
        uint256 mineralTotal = 0;
        //循环计算领地上每件装备的产出
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            (uint256 rawMeatVal,uint256 mineralVal) = calcConfInfoPro(confInfo);
            rawMeatTotal = rawMeatTotal + rawMeatVal;
            mineralTotal = mineralTotal + mineralVal;
        }
        if(rawMeatTotal > 0){
            rawMeatAssets[msg.sender] = rawMeatAssets[msg.sender] + rawMeatTotal;
        }
        if(mineralTotal > 0 ){
            mineralAssets[msg.sender] = mineralAssets[msg.sender] + mineralTotal;
        }
        //更新最近领取时间
        lastTakeTimeDetail[landTokenId] = block.timestamp;
    }
    
    //一键修复领地上的所有装备的耐久值和体能
    function repairAll(uint256 landTokenId) public {
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        ConfGoods[] memory confList = getConfList(landTokenId);
        require(confList.length > 0 , "the land is empty");

        //结算所有收益
        takeAll(landTokenId);

        //计算得出所需要的金币和肉币
        (uint256 ppgCost,uint256 ppfCost) = calcRepairCost(landTokenId);
        if(ppgCost > 0){
            ppgToken.transferFrom(address(msg.sender),address(this),ppgCost);
        }
        if(ppfCost > 0){
            ppfToken.transferFrom(address(msg.sender),address(this),ppfCost);
        }

        //恢复所有装备的耐久值，和配置时间
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            uint256 goodsType = confInfo.goodsType;
            uint256 goodsTokenId = confInfo.goodsTokenId;
            confInfo.confTime = block.timestamp;
            durableDetail[goodsType][goodsTokenId] = 10000;
            energyDetail[goodsType][goodsTokenId] = 10000;
        }
    }
    
    // 计算修复领地所有装备的耐久和体能值需要的金币和肉币数量
    function calcRepairCost(uint256 landTokenId) public view returns (uint256 ppgCost,uint256 ppfCost){
        ConfGoods[] memory confList = getConfList(landTokenId);
        uint256 needDurableVal = 0;
        uint256 needEnergyVal = 0;
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            (uint256 remainDu,uint256 remainEn) = calcConfInfoRemain(confInfo);
            needDurableVal = needDurableVal + (10000 - remainDu);
            needEnergyVal = needEnergyVal + (10000 - remainEn);
        }

        //计算得出所需要的金币和肉币
        uint256 ppgCostVal = 0;
        if(needDurableVal > 0){
            ppgCostVal = needDurableVal * 1000000000000000000 / 5;
        }
        uint256 ppfCostVal = 0;
        if(needEnergyVal > 0){
            ppfCostVal = needEnergyVal * 1000000000000000000 / 5;
        }
        return (ppgCostVal,ppfCostVal);
    }

    //计算领地配置的装备是否还有产能效果
    function canProduce(ConfGoods memory confInfo) public view returns (bool){
        uint256 goodsType = confInfo.goodsType;
        uint256 goodsTokenId = confInfo.goodsTokenId;
        //计算实际损耗时长，不满一小时按0小时计算
        uint256 diffHour = (block.timestamp - confInfo.confTime) / 3600;
        //耐久坚持时长
        uint256 durableHour = durableDetail[goodsType][goodsTokenId] / getLossDurableOneHour(goodsType);
        //体能坚持时长
        uint256 energyHour = energyDetail[goodsType][goodsTokenId] / getLossEnergyOneHour(goodsType);
        //实际损耗时长必须小于耐久坚持时长 且小于 体能坚持时长 才有产能
        if(diffHour < durableHour && diffHour < energyHour){
            return true;
        }
        return false;
    }

    //计算领地每小时的产能
    function calcLandProOneHour(uint256 landTokenId) public view returns  (uint256 rawMeatTotal,uint256 mineralTotal){
        require(landNft.ownerOf(landTokenId) == msg.sender, "the landTokenId is not own");
        ConfGoods[] memory confList = getConfList(landTokenId);
        require(confList.length > 0 , "the land is empty");

        uint256 rawMeatTotalVal = 0;
        uint256 mineralTotalVal = 0;
        //循环计算领地上每件装备的产出
        for (uint256 i = 0; i < confList.length; i++) {
            ConfGoods memory confInfo = confList[i];
            uint256 goodsType = confInfo.goodsType;
            if(canProduce(confInfo)){
                if(goodsType <= 3){
                    rawMeatTotalVal = rawMeatTotalVal + getProduceOneHour(goodsType);
                }else{
                    mineralTotalVal = mineralTotalVal + getProduceOneHour(goodsType);
                }
            }
        }
        return (rawMeatTotalVal,mineralTotalVal);
    }
    //================领地 end===============


    //================兑换 start===============
    uint256 public mineralExchangeRate = 1000000000000000000; //1 mineral = 1 PPG
    uint256 public rawMeatExchangeRate = 1000000000000000000; //1 raw meat = 1 PPG

    function getMineralBalance(address addr) public view returns (uint256){
        return mineralAssets[addr];
    }

    function getMineralExchangeRate() public view returns (uint256){
        return mineralExchangeRate;
    }
    function setMineralExchangeRate(uint256 _rate) public {
        mineralExchangeRate = _rate;
    }

    function getRawMeatBalance(address addr) public view returns (uint256){
        return rawMeatAssets[addr];
    }
    
    function getRawMeatExchangeRate() public view returns (uint256){
        return rawMeatExchangeRate;
    }

    function setRawMeatExchangeRate(uint256 _rate) public {
        rawMeatExchangeRate = _rate;
    }

    function exchange(uint256 exType,uint256 amount) public {
        if(exType == 1){
            uint256 mineralBalance = getMineralBalance(msg.sender);
            require(mineralBalance >= amount, "mineral balance is not enough");
            mineralAssets[msg.sender] = mineralBalance - amount;
            uint256 receivePPG = mineralExchangeRate * amount;
            ppgToken.transfer(address(msg.sender),receivePPG);
        }else{
            uint256 rawMeatBalance = getRawMeatBalance(msg.sender);
            require(rawMeatBalance >= amount, "raw meat balance is not enough");
            rawMeatAssets[msg.sender] = rawMeatBalance - amount;
            uint256 receivePPF = rawMeatExchangeRate * amount;
            ppfToken.transfer(address(msg.sender),receivePPF);
        }
    }
    //================兑换 end===============
    function test() public view returns (address){
        return wep1Nft.test();
    }

    //在领地上配置道具
    function test2(uint256 goodsType,uint256 goodsTokenId) public {
        IERC721 nftObj = getNftObj(goodsType);
        nftObj.setLocked(goodsTokenId);
    }
}