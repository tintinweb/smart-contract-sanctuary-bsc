import "./IBEP20.sol";

// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

contract TokenPledge {
  address private _owner;
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = msg.sender;
  }

  // 是否初始化
  bool private _isInit = false;
  modifier initialized() {
    require(_isInit == true, "The contract has not been initialized");
    // 调用前执行
    _;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    // 调用前执行
    _;
  }

  // 质押代币地址
  address private _pledgeToken;

  // 质押产品
  struct PledgeProduct {
    // id
    uint256 id;
    // 名称
    string name;
    // 周期
    uint256 cycle;
    // 权重
    uint256 weight;
    // 剩余数量
    uint256 amounts;
    // 已发行数量
    uint256 totalAmounts;
    // 是否可用
    bool isEnable;
  }

  // 质押产品列表
  PledgeProduct[] private _productArr;
  event eventCreateProduct(uint256 indexed id);
  event eventAddProduct(uint256 indexed id, uint256 indexed amounts);
  event eventEditProduct(uint256 indexed id);

  // 质押订单
  struct PledgeOrder {
    uint id;
    // 质押用户
    address user;
    // 产品id，它有可能被修改
    uint productID;
    // 开始质押时间
    uint startTime;
    // 质押周期
    uint cycle;
    // 权重
    uint weight;
    // 质押数量
    uint amounts;
  }

  // 质押订单列表
  PledgeOrder[] private _pledgeOrderArr;
  event eventPledgeOrderCreate(uint indexed id);

  // 用户地址 => 用户的订单id列表
  mapping(address => uint[]) private _mpPledgeOrderIDArrByAddress;

  // ==public write==
  // admin 添加质押产品
  function adminCreateProduct(
    string memory name_,
    uint256 cycle_,
    uint256 weight_,
    uint256 amounts_,
    bool isEnable_
  ) public onlyOwner {
    _createProduct(name_, cycle_, weight_, amounts_, isEnable_);
  }

  // 增发质押产品
  function adminAddProduct(uint256 id_, uint256 amounts_) public onlyOwner {
    _addProduct(id_, amounts_);
  }

  // admin 修改质押产品
  function adminEditProduct(
    uint256 id_,
    string memory name_,
    uint256 cycle_,
    uint256 weight_,
    bool isEnable_
  ) public onlyOwner {
    _editProduct(id_, name_, cycle_, weight_, isEnable_);
  }

  // 质押
  // 创建质押订单
  function createOrder(uint productID_, uint amounts_) public initialized {
    _createPledgOrder(productID_, amounts_, msg.sender);
  }

  // 移交owner
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  // 设置质押代币
  function init(address token_) public onlyOwner {
    require(_isInit == false, "contract is initialized.");
    _pledgeToken = token_;
    _isInit = true;
  }

  // ==public view==

  // 获取质押代币地址
  function getPledgeTokenAddress() public view returns (address) {
    return _pledgeToken;
  }

  // 获取质押的产品列表
  function getProductList(
    uint256 startIndex,
    uint256 endIndex
  ) public view returns (PledgeProduct[] memory) {
    require(startIndex <= endIndex, "endIndex must greater than startIndex.");
    if (endIndex >= _productArr.length - 1) {
      endIndex = _productArr.length - 1;
    }
    uint256 arrLength = endIndex - startIndex + 1;
    PledgeProduct[] memory arr = new PledgeProduct[](arrLength);
    uint256 current = startIndex;
    for (uint256 i = 0; i < arrLength; i++) {
      arr[i] = _productArr[current];
      current++;
    }
    return arr;
  }

  // 获取质押产品的总数
  function getProductTCounts() public view returns (uint256) {
    return _productArr.length;
  }

  // 获取质押产品 按id
  function getProductByID(
    uint256 id_
  ) public view returns (PledgeProduct memory) {
    return _productArrFindByID(id_);
  }

  // 获取质押订单 按id
  function getOrderByID(uint256 id_) public view returns (PledgeOrder memory) {
    return _pledgeOrderArrFindByID(id_);
  }

  // 获取质押订单列表
  function getOrderListByIndex(
    uint256 startIndex,
    uint256 endIndex
  ) public view returns (PledgeOrder[] memory) {
    require(startIndex <= endIndex, "endIndex must greater than startIndex.");
    if (endIndex >= _pledgeOrderArr.length - 1) {
      endIndex = _pledgeOrderArr.length - 1;
    }
    if (endIndex < 0) {
      endIndex = 0;
    }
    uint256 arrLength = endIndex - startIndex + 1;
    PledgeOrder[] memory arr = new PledgeOrder[](arrLength);
    uint256 current = startIndex;
    for (uint256 i = 0; i < arrLength; i++) {
      arr[i] = _pledgeOrderArr[current];
      current++;
    }
    return arr;
  }

  // 获取质押订单总数
  function getOrderTotal() public view returns (uint) {
    return _pledgeOrderArr.length;
  }

  // 获取用户的全部质押订单
  function getAddressOrderList(
    address user_
  ) public view returns (PledgeOrder[] memory) {
    return _getAddressOrder(user_);
  }

  // 获取用户的质押订单总数
  function getAddressOrderTotal(address user_) public view returns (uint) {
    PledgeOrder[] memory arr = _getAddressOrder(user_);
    return arr.length;
  }

  // 获取用户的全部质押订单 - 分页
  function getAddressOrderListByIndex(
    address user_,
    uint256 startIndex,
    uint256 endIndex
  ) public view returns (PledgeOrder[] memory) {
    // arrOrder 用户的全部质押订单
    PledgeOrder[] memory arrOrder = _getAddressOrder(user_);
    // 分页校验
    require(startIndex <= endIndex, "endIndex must greater than startIndex.");
    if (endIndex >= arrOrder.length - 1) {
      endIndex = arrOrder.length - 1;
    }
    if (endIndex < 0) {
      endIndex = 0;
    }
    uint256 arrLength = endIndex - startIndex + 1;
    // arr 分页订单
    PledgeOrder[] memory arr = new PledgeOrder[](arrLength);
    uint256 current = startIndex;
    for (uint256 i = 0; i < arrLength; i++) {
      arr[i] = arrOrder[current];
      current++;
    }
    return arr;
  }

  function getOwner() public view returns (address) {
    return _owner;
  }

  // ==private==
  function _createProduct(
    string memory name_,
    uint256 cycle_,
    uint256 weight_,
    uint256 amounts_,
    bool isEnable_
  ) private returns (uint256) {
    uint256 id = _productArrCreateNewID();
    PledgeProduct storage pd = _productArr.push();
    pd.id = id;
    pd.name = name_;
    pd.cycle = cycle_;
    pd.weight = weight_;
    pd.amounts = amounts_;
    pd.totalAmounts = amounts_;
    pd.isEnable = isEnable_;
    emit eventCreateProduct(id);
    return id;
  }

  function _addProduct(uint256 id_, uint256 amounts_) private {
    require(amounts_ > 0, "amounts must greater than zero.");
    PledgeProduct storage pd = _productArrFindByID(id_);
    pd.amounts += amounts_;
    pd.totalAmounts += amounts_;
    emit eventAddProduct(id_, amounts_);
  }

  function _editProduct(
    uint256 id_,
    string memory name_,
    uint256 cycle_,
    uint256 weight_,
    bool isEnable_
  ) private {
    PledgeProduct storage pd = _productArrFindByID(id_);
    pd.name = name_;
    pd.cycle = cycle_;
    pd.weight = weight_;
    pd.isEnable = isEnable_;
    emit eventEditProduct(id_);
  }

  // 获取用户的全部质押订单
  function _getAddressOrder(
    address user_
  ) private view returns (PledgeOrder[] memory) {
    uint[] memory orderIDs = _mpPledgeOrderIDArrByAddress[user_];
    // arrOrder 用户的全部质押订单
    PledgeOrder[] memory arrOrder = new PledgeOrder[](orderIDs.length);
    for (uint i = 0; i < orderIDs.length; i++) {
      arrOrder[i] = _pledgeOrderArrFindByID(orderIDs[i]);
    }
    return arrOrder;
  }

  // 创建_productArr的新id
  function _productArrCreateNewID() private view returns (uint256) {
    return _productArr.length + 1;
  }

  // 按id获取_productArr的PledgeProduct对象
  function _productArrFindByID(
    uint256 id_
  ) private view returns (PledgeProduct storage) {
    _checkID(id_, _productArr.length);
    return _productArr[id_ - 1];
  }

  // 创建_pledgeOrderArr的新id
  function _pledgeOrderArrCreateNewID() private view returns (uint256) {
    return _pledgeOrderArr.length + 1;
  }

  // 按id获取_pledgeOrderArr的PledgeOrder对象
  function _pledgeOrderArrFindByID(
    uint256 id_
  ) private view returns (PledgeOrder storage) {
    _checkID(id_, _pledgeOrderArr.length);
    return _pledgeOrderArr[id_ - 1];
  }

  // 创建质押订单
  function _createPledgOrder(
    uint productID_,
    uint amounts_,
    address user_
  ) private {
    PledgeProduct storage pd = _productArrFindByID(productID_);
    // 校验可质押数量
    require(pd.amounts >= amounts_, "The product amounts is not enough.");
    IBEP20 contractToken = IBEP20(_pledgeToken);
    // 用户的质押代币转账到owner
    contractToken.transferFrom(user_, _owner, amounts_);
    // 削减产品的可质押数量
    pd.amounts -= amounts_;
    // 创建对象的id
    uint newID = _pledgeOrderArrCreateNewID();
    // 添加到列表
    PledgeOrder storage po = _pledgeOrderArr.push();
    po.id = newID;
    po.user = user_;
    po.productID = productID_;
    po.startTime = block.timestamp;
    po.cycle = pd.cycle;
    po.weight = pd.weight;
    po.amounts = amounts_;
    // 添加到映射
    _mpPledgeOrderIDArrByAddress[user_].push(po.id);
    // 触发事件
    emit eventPledgeOrderCreate(po.id);
    // 分配收益和释放质押由中心化程序完成
  }

  // 检查id有效性
  function _checkID(uint256 id_, uint256 length_) private pure {
    require(id_ > 0 && id_ <= length_, "Invalid ID.");
  }
}