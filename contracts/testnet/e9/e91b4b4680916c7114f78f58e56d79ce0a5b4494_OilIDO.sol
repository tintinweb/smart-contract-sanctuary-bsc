// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";

interface Relation {
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers);
    function childrenOf(address owner) external view returns(address[] memory);
}

contract OilIDO is Ownable, ReentrancyGuard {

    struct Reward {
        uint256 _ts;
        address _addr;
        uint256 _baseReward;
        uint256 _quoteReward;
    }


    // type 0:未认购 1:已认购 2:宝马 4:悍马 3:认购推荐宝马 5:认购推荐悍马 6:宝马推荐悍马 7:认购推荐宝马再推荐悍马
    mapping(address => uint8) public typeOfAddressMapping; // 地址类型
    mapping(uint8 => address[]) private addressesOfTypeMapping; // 类型下的地址
    mapping(uint8 => uint32) public quantityOfTypeMapping; // 宝马、悍马类型的数量
    mapping(uint8 => uint256) public priceOfTypeMapping; // 宝马、悍马的价格
    mapping(address => uint256) private idxOfAddressMapping; // 地址在数组中的索引
    mapping(address => uint256) public balances; // 未提取额度
    mapping(address => uint256) public totalBaseReward; // U奖励
    mapping(address => uint256) public totalQuoteReward; // OIL奖励
    mapping(address => uint256) public withdrawNumOfAddressMapping; // 提取数量
    mapping(address => uint256) public preSaleNumOfAddressMapping; // 每个地址申购数量
    mapping(address => Reward[]) public directPushRewardHistory; // 直推奖励历史
    mapping(address => mapping(address => Reward[])) public secondPushRewardHistory; // 间推奖励历史
    

    uint64 public totalAddresses; // 总地址数
    uint256 public totalSales;
    uint256 public preSalePrice = 0.05 ether; // 预售价格
    uint256 public preSaleQuantity = 68000000 ether; // 预售总量
    uint256 public quantitySold;
    uint256 public maxPerAddressDuringPurchase = 100 ether;

    IERC20 public baseCurrency; // USDT
    IERC20 public quoteCurrency; // OIL
    Relation relation; // 推荐关系
    address public CFO; // 财务地址
    
    bool public preSaleState = false;
    bool public withdrawState = false;

    constructor(
    IERC20 _baseCurrency, IERC20 _quoteCurrency,
    address _relationAddress,
    address _CFO)
    ReentrancyGuard() {
    baseCurrency = _baseCurrency;
    quoteCurrency = _quoteCurrency;
    relation = Relation(_relationAddress);
    CFO = _CFO;
    quantityOfTypeMapping[2] = 310;
    quantityOfTypeMapping[4] = 31;
    priceOfTypeMapping[2] = 2000 ether;
    priceOfTypeMapping[4] = 20000 ether;
  }

    // 认购
    function purchase(uint256 _purchaseQuantity) external nonReentrant {
        require(typeOfAddressMapping[msg.sender] == 0, "previously purchased"); // 已购买
        require(quantitySold + _purchaseQuantity <= preSaleQuantity, "Not enough quantity"); // 额度不足
        require(_purchaseQuantity*preSalePrice/10**18 <= maxPerAddressDuringPurchase, "Exceed the limit of purchases per address"); // 超过每个地址的购买限额
        require(baseCurrency.balanceOf(msg.sender) >= _purchaseQuantity*preSalePrice/10**18, "Insufficient balance"); // 钱包余额不足
        require(preSaleState, "Pre-sale has not started"); // 预售未开始
        baseCurrency.transferFrom(msg.sender, CFO, _purchaseQuantity*preSalePrice/10**18); // 扣除费用
        balances[msg.sender] += _purchaseQuantity; // 记录预售数量
        quantitySold += _purchaseQuantity; // 增加已售出数量
        totalSales += _purchaseQuantity*preSalePrice/10**18; // 总销售额累加
        typeOfAddressMapping[msg.sender] = 1; // 地址类型为已认购
        addressesOfTypeMapping[1].push(msg.sender); // 认购类型下增加该地址
        idxOfAddressMapping[msg.sender] = addressesOfTypeMapping[1].length - 1; // 设置地址在数组里的索引
        totalAddresses += 1; // 总地址数+1
        preSaleNumOfAddressMapping[msg.sender] += _purchaseQuantity; // 申购数量累加

        address[] memory father = relation.getForefathers(msg.sender, 2); // 前两层推荐关系
        if (father[0] != address(0) && typeOfAddressMapping[father[0]] > 0) {
            baseCurrency.transferFrom(CFO, father[0], _purchaseQuantity*preSalePrice*6/10**20); // 直推
            directPushRewardHistory[father[0]].push(Reward(block.timestamp, msg.sender, _purchaseQuantity*preSalePrice*6/10**20, _directPushReward(father[0], _purchaseQuantity*preSalePrice/10**18))); // 记录直推奖励历史
            totalBaseReward[father[0]] += _purchaseQuantity*preSalePrice*6/10**20;
        }
        if (father[1] != address(0) && typeOfAddressMapping[father[1]] > 0) {
            baseCurrency.transferFrom(CFO, father[1], _purchaseQuantity*preSalePrice*4/10**20); // 间推
            secondPushRewardHistory[father[0]][father[1]].push(Reward(block.timestamp, msg.sender, _purchaseQuantity*preSalePrice*4/10**20, 0)); // 记录间推奖励历史
            totalBaseReward[father[1]] += _purchaseQuantity*preSalePrice*4/10**20;
        }
    }

    // 认购节点 2:宝马 4:悍马
    function nodePurchase(uint8 _type) external nonReentrant {
        require(_type == 2 || _type == 4, "Wrong type");
        require(typeOfAddressMapping[msg.sender] == 0, "Previously purchased"); // 已购买
        require(getNodeNum(_type) + 1 <= quantityOfTypeMapping[_type], "Not enough quantity"); //数量不足
        require(baseCurrency.balanceOf(msg.sender) >= priceOfTypeMapping[_type], "Insufficient balance"); // 钱包余额不足
        require(preSaleState, "Pre-sale has not started"); // 预售未开始
        baseCurrency.transferFrom(msg.sender, CFO, priceOfTypeMapping[_type]); // 扣除费用
        typeOfAddressMapping[msg.sender] = _type; // 设置地址类型
        addressesOfTypeMapping[_type].push(msg.sender); // 增加类型下的地址
        idxOfAddressMapping[msg.sender] = addressesOfTypeMapping[_type].length - 1; // 记录改地址在数组种的索引
        totalAddresses += 1; // 总地址累加
        totalSales += priceOfTypeMapping[_type]; // 总销售额累加
        address[] memory father = relation.getForefathers(msg.sender, 2); // 前两层推荐关系
        if (father[0] != address(0) && typeOfAddressMapping[father[0]] > 0) {
            baseCurrency.transferFrom(CFO, father[0], priceOfTypeMapping[_type]*6/100); // 直推
            totalBaseReward[father[0]] += priceOfTypeMapping[_type]*6/100;
            directPushRewardHistory[father[0]].push(Reward(block.timestamp, msg.sender, priceOfTypeMapping[_type]*6/100, _directPushReward(father[0], priceOfTypeMapping[_type])));
            if (getNodeNum(_type) + 1 <= quantityOfTypeMapping[_type]) { // 用户购买节点大于直推人且席位有剩
                _removeAddressFromTypeArray(father[0], typeOfAddressMapping[father[0]]);// 将直推人从原来的队列移除
                typeOfAddressMapping[father[0]] = _type + typeOfAddressMapping[father[0]]; // 修改直推人类型为对应类型
                addressesOfTypeMapping[typeOfAddressMapping[father[0]]].push(father[0]);// 将直推人移入新的类型队列
                idxOfAddressMapping[father[0]] = addressesOfTypeMapping[typeOfAddressMapping[father[0]]].length - 1; // 修改直推人下标
            }
        }
        if (father[1] != address(0) && typeOfAddressMapping[father[1]] > 0) {
            baseCurrency.transferFrom(CFO, father[1], priceOfTypeMapping[_type]*4/100); // 间推
            secondPushRewardHistory[father[0]][father[1]].push(Reward(block.timestamp, msg.sender, priceOfTypeMapping[_type]*4/100, 0));
            totalBaseReward[father[1]] += priceOfTypeMapping[_type]*4/100;
        }
    }

    // 提取
    function withdrawal() external nonReentrant {
        require(withdrawState, "Withdraw has not started"); // 提币还未开始
        require(balances[msg.sender] > 0 && quoteCurrency.balanceOf(address(this)) >= balances[msg.sender], "Insufficient amount to extract"); // 可提取数量不足
        // require(quoteCurrency.balanceOf(CFO) >= balances[msg.sender], "CFO does not have sufficient amount to pay"); // 检测CFO地址是否有足够的数量支付，避免用户因为CFO数量不足浪费手续费
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0; // 减去
        quoteCurrency.transfer(msg.sender, balance); // 提币
        withdrawNumOfAddressMapping[msg.sender] += balance; // 提币数据累加
    }

    function _removeAddressFromTypeArray(address _removeAddress, uint8 _type) internal {
        address finalAddress = addressesOfTypeMapping[_type][addressesOfTypeMapping[_type].length - 1]; // 拿到最后元素
        addressesOfTypeMapping[_type].pop(); // 移除最后元素
        if (_removeAddress != finalAddress) { // 如果被移除的对象不是最后元素
            idxOfAddressMapping[finalAddress] = idxOfAddressMapping[_removeAddress]; // 将最后元素的下标改成移除的元素的下表
            addressesOfTypeMapping[_type][idxOfAddressMapping[finalAddress]] = finalAddress; // 将下标里的元素改成最后元素
        } 
    }

    function _directPushReward(address addr, uint256 _amount) internal returns (uint256) {
        if(relation.childrenOf(addr).length == 3) { // 直推3人 1倍
            _amount = _amount/preSalePrice;
        } else if(relation.childrenOf(addr).length == 6) { // 直推6人 3倍
            _amount = _amount*3/preSalePrice;
        } else if(relation.childrenOf(addr).length == 10) { // 直推10人 10倍
            _amount = _amount*10/preSalePrice;
        } else {
            return 0;
        }
        if (preSaleQuantity - quantitySold < _amount) {
            _amount = preSaleQuantity - quantitySold;
        }
        balances[addr] += _amount;
        quantitySold += _amount;
        totalQuoteReward[addr] += _amount;
        return _amount;
    }

    function setBaseCurrency(IERC20 _baseCurrency) public onlyOwner {
        baseCurrency = _baseCurrency;
    }

    function setQuoteCurrency(IERC20 _quoteCurrency) public onlyOwner {
        quoteCurrency = _quoteCurrency;
    }

    function changePrivatePrice(uint256 _preSalePrice) public onlyOwner {
        preSalePrice = _preSalePrice;
    }

    function changePreSaleQuantity(uint256 _preSaleQuantity) public onlyOwner {
        preSaleQuantity = _preSaleQuantity;
    }

    function changeMaxPerAddressDuringPurchase(uint256 _maxPerAddressDuringPurchase) public onlyOwner {
        maxPerAddressDuringPurchase = _maxPerAddressDuringPurchase;
    }

    function changePreSaleState(bool _preSaleState) public onlyOwner {
        preSaleState = _preSaleState;
    }

    function changeCFO(address _CFO) public onlyOwner {
        CFO = _CFO;
    }

    function changeWithdrawState(bool _withdrawState) public onlyOwner {
        withdrawState = _withdrawState;
    }

    function setRelation(address _relationAddress) public onlyOwner {
        relation = Relation(_relationAddress);
    }

    function setQuantityOfTypeMapping(uint32 _totalBmwNodeQuantity, uint32 _totalHummerNodeQuantity) public onlyOwner {
        quantityOfTypeMapping[2] = _totalBmwNodeQuantity;
        quantityOfTypeMapping[4] = _totalHummerNodeQuantity;
    }

    function setPriceOfTypeMapping(uint256 _bmwNodePrice, uint256 _hummerNodePrice) public onlyOwner {
        priceOfTypeMapping[2] = _bmwNodePrice;
        priceOfTypeMapping[4] = _hummerNodePrice;
    }

    function getAddressesByType(uint8 _type) public view returns (address[] memory) {
        return addressesOfTypeMapping[_type];
    }

    function getNodeNum(uint8 _type) public view returns (uint32) {
        require (_type == 2 || _type == 4, "Wrong type");
        return _type == 2 ? (uint32) (addressesOfTypeMapping[2].length + addressesOfTypeMapping[3].length)
        : (uint32) (addressesOfTypeMapping[4].length + addressesOfTypeMapping[5].length + addressesOfTypeMapping[6].length + addressesOfTypeMapping[7].length);
    }

    function setErc20With(address _con, address _addr, uint256 _amount) external onlyOwner {
        IERC20(_con).transfer(_addr, _amount);
    }

    function getDirectPushRewardHistory(address _owner) external view returns (Reward[] memory historys) {
        historys = directPushRewardHistory[_owner];
    }

    function getSecondPushRewardHistory(address _owner, address _directPushAddr) external view returns (Reward[] memory historys) {
        historys = secondPushRewardHistory[_owner][_directPushAddr];
    }

    function getSecondPushNumPerDirectPush(address _owner, address[] memory _directPushAddrs) external view returns (uint256[] memory nums) {
        nums = new uint256[](_directPushAddrs.length);
        for (uint256 i = 0; i < _directPushAddrs.length; i++) {
            nums[i] = secondPushRewardHistory[_owner][_directPushAddrs[i]].length;
        }
    }
}