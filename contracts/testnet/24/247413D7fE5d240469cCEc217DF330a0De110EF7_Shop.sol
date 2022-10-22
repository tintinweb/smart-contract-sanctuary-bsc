// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./libs/item/Item.sol";
import "./libs/item/ItemPrice.sol";
import "./libs/SafeMath.sol";
import "./libs/Address.sol";
import "./interfaces/IShop.sol";
import "./interfaces/IERC20.sol";
import "./abstracts/order/Orders.sol";


contract Shop  is IShop,Orders{
    using SafeMath for uint256;
    using Address for address;


    // 商品id, 商品详情
    mapping(uint256=>Item) shopItems;

    //商品列表
    uint256[] items;


    //店主地址
    address public shopOwner;

    address public feeAddress;

    uint256 public feeRate;


    constructor() {
    }



    function buy(uint256 id,uint256 number,address payAddress)public{
        //购买数量错误
        require(number==0, 'buy:Wrong quantity purchased');
        Item memory item=  shopItems[id];
        //商品不存在
        require(item.totalStock<=0,'buy:GOODS NOT EXISTS');
        //库存不足
        require(item.totalStock<=item.sales, 'buy:Item sold out');
        //商品还没开售
        require(item.status!=ItemStatus.SALE, 'buy:Item not available for sale');
        //库存不足
        require(number.add(item.sales)>=item.totalStock, 'buy:Inventory shortage');


    
        ItemPrice memory buyToken=item.payType.getByToken(payAddress);
        
        require(buyToken.token==address(0), 'buy:wrong payment currency');


        address buyer=msg.sender;   

        uint256 totalAmount=buyToken.price.mul(number);


        IERC20(buyToken.token).transferFrom(buyer, address(this), totalAmount);
        item.sales=item.sales.add(1);

        if(item.sales>=item.totalStock){
            //售馨下架
            item.status=ItemStatus.SOLI_OUT;
        }

        //更新商品信息
        shopItems[id]=item;

       uint256 fee= totalAmount.mul(feeRate).div(10000);

        //创建订单
        _createOrder(buyer, totalAmount,buyToken.token,address(this),fee,item);

    }

    function mint( Item memory item) public {
        require(item.totalStock<=0, 'Mint:GOODS STOCK ZERO'); 
        require(item.payType.getSize()==0,'Mint:PRICE NOT EXISTS');
        for(uint i=0;i<item.payType.getSize();i++){
            ItemPrice memory price=  item.payType.getItem(i);
            IERC20(price.token);
            require(price.price==0, 'Mint:Token Price error'); 
        }
        item.owner=msg.sender;
        item.status=ItemStatus.SALE;

        uint256 id=  _getId();

        shopItems[id]=item;
        items.push(id);

        emit ItemCreated(id);
        emit ItemStock(id, item.totalStock);
    }






    
}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return
        functionDelegateCall(
            target,
            data,
            "Address: low-level delegate call failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../../interfaces/IERC20.sol";
import "./ItemStatus.sol";
import "./ItemPrice.sol";
import "./ItemType.sol";
import "./PayType.sol";

struct Item {

    uint256 id;
    //标题
    string title;
    //商品类型
    ItemType itemType;
    //介绍
    string body;
    //状态
    ItemStatus status; 

    PayType payType;

    //总库存
    uint256 totalStock;
    //销量
    uint256 sales;
    //商品发布者
    address owner;




}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
import "./IOrders.sol";
interface IShop is IOrders{

    event ItemCreated(uint256 indexed id);

    event ItemStock(uint256 id,uint256 stock);

    //获取店主地址
    function shopOwner() external view returns (address);



}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
interface IERC20{
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../../interfaces/IERC20.sol";
import "../SafeMath.sol";
import "../Address.sol";

struct ItemPrice {

    //价格
    uint256 price;
    //币种
    address token;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../../libs/item/Item.sol";
import "../Index.sol";
import "../../libs/order/OrderItem.sol";
import "../../libs/order/OrderStatus.sol";
import "../../interfaces/IOrders.sol";
import "../Ownable.sol";

abstract contract Orders is Index ,IOrders ,Ownable{
    //总订单列表
    mapping(uint256=>OrderItem) orders;
    //我买到的订单列表
    mapping(address=>uint256[]) buyerOrders;
    //我卖出的订单列表
    mapping(address=>uint256[]) sellerOrders;


    //创建订单        买家地址      总金额      支付token       店铺地址      手续费     商品信息
    function _createOrder(address buyer,uint256 totalAmount,address payToken,address shopAddr,uint256 fee,Item memory item) internal {
          uint256 id=  _getId();
        OrderItem memory order;
        order.buyer=buyer;
        order.seller=item.owner;
        order.id=id;
        order.itemId=item.id;
        order.payAmount=totalAmount;
        order.payment=payToken;
        order.shop=shopAddr;
        order.fee=fee;
        order.status=OrderStatus.WAIT_SELLER_CONFIRM;
        orders[id ]=order;          

        buyerOrders[buyer].push(id);
        sellerOrders[order.seller].push(id);

        emit OrderCreated(buyer, order.seller, order.shop , id);


    }

    function   buyerConfirm(uint256 id)public returns(bool) {
        OrderItem memory item= orders[id];
        require(msg.sender!=item.buyer||msg.sender!=owner(), 'sellerConfirm:');

        item.status=OrderStatus.SUCCESS;
        orders[id]=item;
        return true;
    }

    function   sellerConfirm(uint256 id)public returns(bool) {
        OrderItem memory item= orders[id];
        require(msg.sender!=item.seller||msg.sender!=owner(), 'sellerConfirm:');
        item.status=OrderStatus.WAIT_BUYER_CONFIRM;
        orders[id]=item;
        return true;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
enum ItemStatus{
    //销售中
    SALE,
    //下架
    DOWN,
    //售罄
    SOLI_OUT
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

enum ItemType {
    //虚拟 买家确认收货卖家才能收到钱
    VIRTUAL,
    //实物 需要卖家确认, 买家才能确认收货 ,买家确认收货卖家才能收到钱
    REAL
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./ItemPrice.sol";
contract PayType{


        //多币种价格
    ItemPrice[]  prices;

    function getByToken(address token) public view returns (ItemPrice memory item) {

        for(uint i=0;i<prices.length;i++){
            ItemPrice memory price= prices[i];
            if(price.token==token){
                item= price;
            }
        }
    }


    function getItem(uint index) public view returns (ItemPrice memory item) {

        return prices[index];
    }


    function getSize() public view returns(uint){
        return prices.length;
    }

}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
interface IOrders{

    event OrderCreated(address buyer,address seller,address shop,uint256 id);

    function buyerConfirm(uint256 id)external returns(bool);

    function sellerConfirm(uint256 id) external returns(bool);

    

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../libs/SafeMath.sol";

contract Index{
        using SafeMath for uint256;

     uint256 public index ;

    function _getId() internal  returns(uint256){
        index=index.add(1);
        return index;

    }


}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
import "./Context.sol"; 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../../interfaces/IERC20.sol";
import "./OrderStatus.sol";
struct OrderItem {


    //订单id
    uint256 id;
    //商品id
    uint256 itemId;
    //买家
    address buyer;
    //卖家
    address seller;
    //店铺
    address shop;
    //支付
    address payment;
    //支付金额
    uint256 payAmount;
    //手续费
    uint256 fee;
    //订单状态
    OrderStatus status;
    


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
enum OrderStatus{
    //等待卖家发货
    WAIT_SELLER_CONFIRM,
    //等待买家确认
    WAIT_BUYER_CONFIRM,
    //确认成功,
    SUCCESS,
    //买家申诉
    APPEAL,
    //退款
    REFUND


}

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}