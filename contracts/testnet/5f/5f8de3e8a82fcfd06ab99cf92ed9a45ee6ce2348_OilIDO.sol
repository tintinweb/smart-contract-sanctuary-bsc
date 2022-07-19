/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface Relation {
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers);
    function childrenOf(address owner) external view returns(address[] memory);
}

contract OilIDO is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

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
    mapping(address => Reward[]) public secondPushRewardHistory; // 间推奖励历史
    

    uint64 public totalAddresses; // 总地址数
    uint256 public totalSales;
    uint256 public preSalePrice = 0.05 ether; // 预售价格
    uint256 public preSaleQuantity = 68000000 ether; // 预售总量
    uint256 public quantitySold;
    uint256 public maxPerAddressDuringPurchase = 100 ether;

    IERC20 public baseCurrency; // USDT
    IERC20 public quoteCurrency; // OIL
    Relation relation; // 推荐关系
    address public CFO = address(0); // 财务地址
    
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
    function purchase(uint256 purchaseQuantity) external nonReentrant {
        require(typeOfAddressMapping[msg.sender] == 0, "previously purchased"); // 已购买
        require(quantitySold + purchaseQuantity <= preSaleQuantity, "Not enough quantity"); // 额度不足
        require(purchaseQuantity.mul(preSalePrice).div(10**18) <= maxPerAddressDuringPurchase, "Exceed the limit of purchases per address"); // 超过每个地址的购买限额
        require(baseCurrency.balanceOf(msg.sender) >= purchaseQuantity.mul(preSalePrice).div(10**18), "Insufficient balance"); // 钱包余额不足
        require(preSaleState, "Pre-sale has not started"); // 预售未开始
        baseCurrency.transferFrom(msg.sender, CFO, purchaseQuantity.mul(preSalePrice).div(10**18)); // 扣除费用
        balances[msg.sender] = balances[msg.sender].add(purchaseQuantity); // 记录预售数量
        quantitySold += purchaseQuantity; // 增加已售出数量
        totalSales += purchaseQuantity.mul(preSalePrice).div(10**18); // 总销售额累加
        typeOfAddressMapping[msg.sender] = 1; // 地址类型为已认购
        addressesOfTypeMapping[1].push(msg.sender); // 认购类型下增加该地址
        idxOfAddressMapping[msg.sender] = addressesOfTypeMapping[1].length - 1; // 设置地址在数组里的索引
        totalAddresses += 1; // 总地址数+1
        preSaleNumOfAddressMapping[msg.sender] += purchaseQuantity; // 申购数量累加

        address[] memory father = relation.getForefathers(msg.sender, 2); // 前两层推荐关系
        if (father[0] != address(0) && typeOfAddressMapping[father[0]] > 0) {
            baseCurrency.transferFrom(CFO, father[0], purchaseQuantity.mul(preSalePrice).div(10**18).mul(6).div(100)); // 直推
            directPushRewardHistory[father[0]].push(Reward(block.timestamp, msg.sender, purchaseQuantity.mul(preSalePrice).div(10**18).mul(6).div(100), _directPushReward(father[0], purchaseQuantity.mul(preSalePrice).div(10**18))));
        }
        if (father[1] != address(0) && typeOfAddressMapping[father[1]] > 0) {
            baseCurrency.transferFrom(CFO, father[1], purchaseQuantity.mul(preSalePrice).div(10**18).mul(4).div(100)); // 间推
            secondPushRewardHistory[father[1]].push(Reward(block.timestamp, msg.sender, purchaseQuantity.mul(preSalePrice).div(10**18).mul(4).div(100), 0));
        }
    }

    // 认购节点 2:宝马 4:悍马
    function nodePurchase(uint8 types) external nonReentrant {
        require(types == 2 || types == 4, "Wrong type");
        require(typeOfAddressMapping[msg.sender] == 0, "Previously purchased"); // 已购买
        require(types == 2 && addressesOfTypeMapping[2].length + addressesOfTypeMapping[3].length + 1 <= quantityOfTypeMapping[2]
        || types == 4 && addressesOfTypeMapping[4].length + addressesOfTypeMapping[5].length + addressesOfTypeMapping[6].length + addressesOfTypeMapping[7].length + 1 <= quantityOfTypeMapping[4],
        "Not enough quantity"); //数量不足
        require(baseCurrency.balanceOf(msg.sender) >= priceOfTypeMapping[types], "Insufficient balance"); // 钱包余额不足
        require(preSaleState, "Pre-sale has not started"); // 预售未开始
        baseCurrency.transferFrom(msg.sender, CFO, priceOfTypeMapping[types]); // 扣除费用
        typeOfAddressMapping[msg.sender] = types; // 设置地址类型
        addressesOfTypeMapping[types].push(msg.sender); // 增加类型下的地址
        idxOfAddressMapping[msg.sender] = addressesOfTypeMapping[types].length - 1; // 记录改地址在数组种的索引
        totalAddresses += 1; // 总地址累加
        totalSales += priceOfTypeMapping[types]; // 总销售额累加
        address[] memory father = relation.getForefathers(msg.sender, 2); // 前两层推荐关系
        if (father[0] != address(0) && typeOfAddressMapping[father[0]] > 0) {
            baseCurrency.transferFrom(CFO, father[0], priceOfTypeMapping[types].mul(6).div(100)); // 直推
            totalBaseReward[father[0]] += priceOfTypeMapping[types].mul(6).div(100);
            directPushRewardHistory[father[0]].push(Reward(block.timestamp, msg.sender, priceOfTypeMapping[types].mul(6).div(100), _directPushReward(father[0], priceOfTypeMapping[types])));
            if (types == 2 && getBmwNodeNum() + 1 <= quantityOfTypeMapping[2]
            || types == 4 && getHummerNodeNum() + 1 <= quantityOfTypeMapping[4]) { // 用户购买节点大于直推人且席位有剩
                _removeAddressFromTypeArray(father[0], typeOfAddressMapping[father[0]]);// 将直推人从原来的队列移除
                typeOfAddressMapping[father[0]] = types + typeOfAddressMapping[father[0]]; // 修改直推人类型为对应类型
                addressesOfTypeMapping[typeOfAddressMapping[father[0]]].push(father[0]);// 将直推人移入新的类型队列
                idxOfAddressMapping[father[0]] = addressesOfTypeMapping[typeOfAddressMapping[father[0]]].length - 1; // 修改直推人下标
            }
        }
        if (father[1] != address(0) && typeOfAddressMapping[father[1]] > 0) {
            baseCurrency.transferFrom(CFO, father[1], priceOfTypeMapping[types].mul(4).div(100)); // 间推
            secondPushRewardHistory[father[1]].push(Reward(block.timestamp, msg.sender, priceOfTypeMapping[types].mul(4).div(100), 0));
            totalBaseReward[father[1]] += priceOfTypeMapping[types].mul(4).div(100);
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

    function _removeAddressFromTypeArray(address removeAddress, uint8 types) internal {
        address finalAddress = addressesOfTypeMapping[types][addressesOfTypeMapping[types].length - 1]; // 拿到最后元素
        addressesOfTypeMapping[types].pop(); // 移除最后元素
        if (removeAddress != finalAddress) { // 如果被移除的对象不是最后元素
            idxOfAddressMapping[finalAddress] = idxOfAddressMapping[removeAddress]; // 将最后元素的下标改成移除的元素的下表
            addressesOfTypeMapping[types][idxOfAddressMapping[finalAddress]] = finalAddress; // 将下标里的元素改成最后元素
        } 
    }

    function _directPushReward(address addr, uint256 amount) internal returns (uint256 reward) {
        if(relation.childrenOf(addr).length == 3) { // 直推3人 1倍
            amount = amount.div(preSalePrice);
        } else if(relation.childrenOf(addr).length == 6) { // 直推6人 3倍
            amount = amount.mul(3).div(preSalePrice);
        } else if(relation.childrenOf(addr).length == 10) { // 直推10人 10倍
            amount = amount.mul(10).div(preSalePrice);
        }
        if (preSaleQuantity - quantitySold < amount) {
            amount = preSaleQuantity - quantitySold;
        }
        balances[addr] += amount;
        quantitySold += amount;
        totalQuoteReward[addr] += amount;
        return amount;
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

    function setRelation(address relationAddress) public onlyOwner {
        relation = Relation(relationAddress);
    }

    function setQuantityOfTypeMapping(uint32 totalBmwNodeQuantity, uint32 totalHummerNodeQuantity) public onlyOwner {
        quantityOfTypeMapping[2] = totalBmwNodeQuantity;
        quantityOfTypeMapping[4] = totalHummerNodeQuantity;
    }

    function setPriceOfTypeMapping(uint256 bmwNodePrice, uint256 hummerNodePrice) public onlyOwner {
        priceOfTypeMapping[2] = bmwNodePrice;
        priceOfTypeMapping[4] = hummerNodePrice;
    }

    function getAddressesByType(uint8 types) public view returns (address[] memory) {
        return addressesOfTypeMapping[types];
    }
    
    function getBmwNodeNum() public view returns (uint32) {
        return (uint32) (addressesOfTypeMapping[2].length + addressesOfTypeMapping[3].length);
    }

    function getHummerNodeNum() public view returns (uint32) {
        return (uint32) (addressesOfTypeMapping[4].length + addressesOfTypeMapping[5].length + addressesOfTypeMapping[6].length + addressesOfTypeMapping[7].length);
    }

    function setErc20With(address con, address addr, uint256 amount) external onlyOwner {
        IERC20(con).transfer(addr, amount);
    }
}