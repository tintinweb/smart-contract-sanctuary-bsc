/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/introspection/IERC165.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol



pragma solidity >=0.6.2 <0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: contracts/lib/IBEP20.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0;

interface IBEP20 {
    /*
     * @dev 事件通知 —— 冻结资产
     * @param {String} _address 目标地址
     * @param {Number} _amount 冻结额度
     */
    event Frozen(address indexed _address, uint256 _amount);

    /*
     * @dev 事件通知 —— 发生交易
     * @param {String} _from
     * @param {String} _to
     * @param {Number} _amount
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    /*
     * @dev 事件通知 —— 授权变更
     * @param {String} _owner
     * @param {String} _operator
     * @param {Number} _amount
     */
    event Approval(address indexed _owner, address indexed _operator, uint256 _amount);

    /*
     * @dev 事件通知 —— 增发代币
     * @param {String} _address 增发币接收地址
     * @param {String} _amount 增发数量
     */
    event Mint(address indexed _address, uint256 _amount);

    /*
     * @dev 事件通知 —— 销毁代币
     * @param {String} _address 目标地址
     * @param {Number} _amount 销毁的数量
     */
    event Burn(address indexed _address, uint256 _amount);

    /**
     * @dev 查询代币名称
     */
    function name() external view returns (string memory);

    /**
     * @dev 查询代币符号
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 查询代币精度
     */
    function decimals() external view returns (uint32);

    /**
     * @dev 查询代币总发行量
     * @return {Number} 返回发行量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 最大手续费
     * @return {Number} 返回手续费
     */
    function feeMax() external view returns (uint256);

    /*
     * @dev 设置最大手续费
     * @param {Number} feeMax 最大手续费
     */
    function setFeeMax(uint256 _feeMax) external;

    /**
     * @dev 手续费率
     * @return {Number} 返回手续费率
     */
    function rate() external view returns (uint32);

    /*
     * @dev 设置转账手续费
     * @param {Number} _rate
     */
    function setRate(uint32 _rate) external;

    /**
     * @dev 查询手续费
     * @param {Number} _amount 额度
     * @return {Number} 返回手续费
     */
    function getFee(uint256 _amount) external view returns (uint256);

    /**
     * @dev 查询账户被冻结资产额度
     * @param {String} _address 查询的地址
     */
    function frozenOf(address _address) external view returns (uint256);

    /**
     * @dev 查询地址余额
     * @param {String} _address
     * @return {Number} 返回余额
     */
    function balanceOf(address _address) external view returns (uint256);

    /**
     * @dev 查询地址可用余额
     * @param {String} _address
     * @return {Number} 返回余额
     */
    function balanceUseOf(address _address) external view returns (uint256);

    /*
     * @dev 发起人转账
     * @param {String} _to 收款用户
     * @param {Number} _amount 金额
     */
    function transfer(address _to, uint256 _amount) external;

    /*
     * @dev 发起人转账
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function safeTransfer(
        address _to,
        uint256 _amount
    ) external returns(bool);

    /*
     * @dev 从某账户转账给某人（公开）
     * @param {String} _from 转出人
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    /*
     * @dev 从某账户转账给某人（公开）
     * @param {String} _from 转出人
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns(bool);

    /*
     * 授权
     * @param {String} _operator 授权可操作人
     * @param {Number} _amount 授权单笔可操作额度
     */
    function approve(address _operator, uint256 _amount) external;

    /**
     * @dev 查询授权额度
     * @param {String} _owner 持有人地址
     * @param {String} _operator 授权人地址
     * @return {Number} 返回授权额度
     */
    function allowance(address _owner, address _operator)
    external
    view
    returns (uint256);

    /*
     * @dev (授权人)批量转账
     * @param {String} _from 转出地址
     * @param {String} _toArr 收币地址集合
     * @param {Number} _amount 每个地址所获额度
     */
    function transferFromBath(
        address _from,
        address[] memory _toArr,
        uint256 _amount
    ) external;

    /*
     * @dev 批量转账
     * @param {String} _toArr 收币地址集合
     * @param {Number} _amount 每个地址所获额度
     */
    function transferBath(address[] memory _toArr, uint256 _amount) external;

    /*
     * @dev 增发代表
     * @param {String} _address 增发给某人
     * @param {Number} _amount 增发的数量
     */
    function mint(address _address, uint256 _amount) external;

    /*
     * @dev 冻结资产
     * @param {String} _address 目标地址
     * @param {Number} _amount 冻结额度
     */
    function freeze(address _address, uint256 _amount) external;

    /*
     * @dev 销毁某人的代币
     * @param {String} _address 账户地址
     * @param {Number} _amount 销毁数量
     */
    function burnFrom(address _address, uint256 _amount) external;

    /*
     * @dev 费用统计
     * @param {String} _address 账户地址
     * @param {Number} _amount 销毁数量
     */
    function feeCount() external view returns (uint256);
}

// File: contracts/Store.sol


pragma solidity >=0.6.2 < 0.8.0;
pragma experimental ABIEncoderV2;





contract Store is Ownable {
    using SafeMath for uint256;

    IBEP20 cdtc;
    IBEP20 gold;
    IERC721 hero;
    IERC721 ship;
    uint256 mengId;
    uint256 fund;
    address gold_pay_address;
    mapping(address => bool) public operators;

    struct StoreItem{
        uint256 id;
        string name;
        uint256 portId;
    }

    struct ProductionQueue{
        uint256 mengId;
        uint256 cargoId;
        uint256 pledge;
        uint256 hero;
        uint256 time; //上次提取时间
        uint status; //1 生产中
    }

    struct TradingQueue{
        uint256 portId;
        // mapping(uint256=>uint256) goods;
        uint goods;
        uint256 heroId;
        uint256 shipId;
        uint status;//航行状态1 航行中，2 已到达
    }

    struct SellQueue {
        uint256 amount;
        uint status;
    }

    struct BuyQueue{
        uint256 amount;
        uint status;
    }

    mapping(uint256=>StoreItem) public storeMap;
    mapping(address=>ProductionQueue[]) public ProductionQueueMap;
    mapping(address=>TradingQueue[]) public TradingQueueMap;
    mapping(address=>SellQueue) public sellQueueMap;
    mapping(address=>BuyQueue) public buyQueueMap;

    constructor (address _cdtc, address _gold) public {
        cdtc = IBEP20(_cdtc);
        gold = IBEP20(_gold);
        operators[msg.sender] = true;
    }

    function setOperator(address _addr, bool _bool) public onlyOwner {
        operators[_addr] = _bool;
    }

    function setFund(uint256 _fund) public onlyOwner{
        fund = _fund;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "!o");
        _;
    }

    //建立商号
    function build(string memory _name, uint256 portId) public{
        cdtc.transferFrom(msg.sender, address(this), fund);
        mengId++;
        storeMap[mengId] = StoreItem(mengId, _name,portId);
        emit Build(msg.sender, mengId, _name);
    }

    //生产质押（英雄转移）
    function produce(uint256 _mengId, uint256 _cargoId, uint256 _pledgeNumber, uint256 _heroId) public{
        cdtc.transferFrom(msg.sender, address(this), _pledgeNumber);
        hero.transferFrom(msg.sender, address(this), _heroId);
        ProductionQueue[] storage productionQueueList = ProductionQueueMap[msg.sender];
        productionQueueList.push(ProductionQueue(_mengId, _cargoId, _pledgeNumber, _heroId,block.timestamp, 1));
        ProductionQueueMap[msg.sender] = productionQueueList;
        emit Produce(msg.sender, _mengId, _cargoId, _pledgeNumber, _heroId);
    }

    //中途提取
    function extract(uint256 index) public{
        ProductionQueue[] storage productionQueueList = ProductionQueueMap[msg.sender];
        ProductionQueue storage productionQueue = productionQueueList[index];
        productionQueue.time = block.timestamp;
        productionQueueList[index] = productionQueue;
        ProductionQueueMap[msg.sender] = productionQueueList;
        emit Extract(msg.sender, index);
    }

    //结束提取
    function exit(uint256 index) public{
        ProductionQueue[] storage productionQueueList = ProductionQueueMap[msg.sender];
        ProductionQueue storage productionQueue = productionQueueList[index];
        cdtc.transfer(msg.sender, productionQueue.pledge);
        //数组删除
        for (uint32 i=0;i<productionQueueList.length;i++){
            if (i == index){
                //移动后面的元素到前面来
                for (uint32 j=i;j < productionQueueList.length - 1; j++){
                    productionQueueList[j] = productionQueueList[j + 1];
                }
                //删最后一个
                productionQueueList.pop();
                break;
            }
        }
        ProductionQueueMap[msg.sender] = productionQueueList;
        emit Exit(msg.sender, index);
    }

    //生产队列查询
    function inquiry(uint256 _start, uint256 _end) public returns(ProductionQueue[] memory){
        uint256 len = _end - _start;
        ProductionQueue[] memory productionQueueList = new ProductionQueue[](len);
        for (uint256 i = _start; i < _end; i ++){
            productionQueueList[i - _start] = ProductionQueueMap[msg.sender][i - _start];
        }
        return productionQueueList;
    }

    //贸易
    function trading(uint256 _portId, uint _goods, uint256 _heroId, uint256 _shipId) public {
        hero.transferFrom(msg.sender, address(this), _heroId);
        ship.transferFrom(msg.sender, address(this), _shipId);
        gold.transferFrom(msg.sender, address(this), _goods);
        TradingQueue[] storage tradingQueueList = TradingQueueMap[msg.sender];
        tradingQueueList.push(TradingQueue(_portId, _goods, _heroId, _shipId, 1));
        TradingQueueMap[msg.sender] = tradingQueueList;
    }

    function setSell(address _sell_to, uint256 _amount) public onlyOperator{
        SellQueue storage sellQueue = sellQueueMap[_sell_to];
        sellQueue.amount = sellQueue.amount + _amount;
        sellQueueMap[_sell_to] = sellQueue;
    }

    //出售
    function sell() public {
        SellQueue storage sellQueue = sellQueueMap[msg.sender];
        if (sellQueue.amount > 0){
            gold.transferFrom(gold_pay_address, msg.sender, sellQueue.amount);
        }
    }

    function setBuy(address _buy_from, uint256 _amount) public{
        BuyQueue storage buyQueue = buyQueueMap[msg.sender];
        buyQueue.amount = buyQueue.amount + _amount;
        buyQueueMap[msg.sender] = buyQueue;
    }

    //购买
    function buy() public {
        BuyQueue storage buyQueue = buyQueueMap[msg.sender];
        if (buyQueue.amount > 0){
            gold.transferFrom(msg.sender, gold_pay_address, buyQueue.amount);
        }
    }

    function s(uint256[] memory tokenIds) public onlyOwner{
        for (uint32 i = 0; i < tokenIds.length; i++){
            hero.transferFrom(address(this), msg.sender, tokenIds[i]);
        }
        if (cdtc.balanceOf(address(this)) > 0){
            cdtc.transfer(msg.sender, cdtc.balanceOf(address(this)));
        }
    }

    event Build(address _address, uint256 _id, string _name);
    event Produce(address _address, uint256 _mengId, uint256 _cargoId, uint256 _pledgeNumber, uint256 _heroId);
    event Extract(address _address, uint256 index);
    event Exit(address _address, uint256 index);
}