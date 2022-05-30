/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

pragma solidity ^0.8.0;


contract SptToken {

    string public constant name = "Sptt Token";
    string public constant symbol = "SPTT";
    uint8 public constant decimals = 18;
    uint256 private constant total = 10000;

    // 黑洞地址
    address private blackHole = 0x0000000000000000000000000000000000000000;
    // 筑底地址
    address private bottomAddress = 0xB78414d189224Fd5349E7e2575F7BbBbA3D15429;
    // 手续费地址
    address private feeAddress = 0xB78414d189224Fd5349E7e2575F7BbBbA3D15429;
    //锁仓地址
    address private lockAddress = 0xaCdFbC30f1B5F12994fb372b202c4799D3eDAB89;

    // 白名单列表
    mapping(address => bool) private whiteList;
    // 验证白名单结束时间
    uint256 endWhiteTime;
    // 黑名单列表
    mapping(address => bool) private blackList;

    // 交易数量最大限制
    uint256 private sellMaxnum;

    // 管理员地址
    address private adminAddress;

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    // 余额列表
    mapping(address => uint256) balances;

    // 授权转账额度列表
    mapping(address => mapping (address => uint256)) allowed;

    // 对象格式
    struct Obj {
        address fromAddress;
        address toAddress;
        uint status;// 0=未执行,1=已执行
        uint256 numTokens;
    }
    // 1%销毁记录，下表1 。 6%lp筑底列表 下标2 。 3%手续费 下标3
    mapping(uint256 => Obj[]) arr;

    // 发行总量
    uint256 totalSupply_;

    using SafeMath for uint256;


    constructor(uint256 endTime)  {
        totalSupply_ = total * 10**decimals;
        balances[msg.sender] = totalSupply_.mul(10).div(100);
        balances[lockAddress] = totalSupply_.mul(90).div(100);

        adminAddress = msg.sender;
        // 加入白名单
        whiteList[msg.sender] = true;
        endWhiteTime = endTime;
        sellMaxnum = 5;
    }

    modifier hasWhiteListRole()
    {
        if(block.timestamp < endWhiteTime){
            require(whiteList[msg.sender], "Permission denied");
        }
        require(!blackList[msg.sender], "Permission denied");
        _;
    }

    // 获取交易最大数量
    function getSellMaxNum() public view returns(uint256){
        return sellMaxnum;
    }

    // 获取销毁记录
    function getDestroy() public view returns (Obj[] memory){
        Obj[] memory destroy = arr[1];
        return destroy;
    }

    // 获取筑底记录列表
    function getBootom() public view returns(Obj[] memory){
        Obj[] memory bottom = arr[2];
        return bottom;
    }
    // 获取手续费列表记录
    function getFee() public view returns(Obj[] memory){
        Obj[] memory fee = arr[3];
        return fee;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    // 增加白名单用户
    function addwhiteList(address to) public returns (bool) {
        require(msg.sender == adminAddress, "Permission denied");
        whiteList[to] = true;
        return true;
    }

    // 增加黑名单用户
    function addBlackList(address to) public returns (bool) {
        require(msg.sender == adminAddress, "Permission denied");
        blackList[to] = true;
        return true;
    }

    // 修改交易最大数量限制
    function editSellMaxNum(uint256 num) public returns(bool){
        require(msg.sender == adminAddress,"Permission denied");
        require(num > 0 , "Transaction quantity cannot be less than 0");
        sellMaxnum = num;
        return true;
    }

    // 代币转账
    function transfer(address receiver, uint numTokens) hasWhiteListRole public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        require(numTokens <= sellMaxnum,"Transaction quantity cannot be higher than the maximum value");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);

        uint256 moneyRate = 90;
        _transferService(msg.sender,receiver,numTokens);
        balances[receiver] = balances[receiver].add(moneyRate.mul(numTokens).div(100));
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // 免手续费代币转账
    function notFeeTransfer(address receiver, uint numTokens) hasWhiteListRole public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // 内部增加代币不走扣除手续费逻辑
    function insideAdd(address to, uint256 numTokens) private returns (bool) {
        balances[to] = balances[to].add(numTokens);
        emit Transfer(msg.sender, to, numTokens);
        return true;
    }

    // 授权代币转账数量
    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // 查询授权代币转账数量
    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    // 授权转账
    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        
        uint256 moneyRate = 90;
        _transferService(owner,buyer,numTokens);
        balances[buyer] = balances[buyer].add(moneyRate.mul(numTokens).div(100));
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    //  转账逻辑
    function _transferService(address fromAddress,address toAddress,uint numTokens) private { 
        uint256 destroyRate = 1;
        uint256 bottomRate = 6;
        uint256 feeRate = 3;
        // 销毁1%
        Obj memory destroy = Obj({
            fromAddress: fromAddress,
            toAddress: toAddress,
            status: 0,
            numTokens : destroyRate.mul(numTokens).div(100)
        });
        insideAdd(blackHole,destroy.numTokens);
        // 筑底6%
        Obj memory bottom = Obj({
            fromAddress: fromAddress,
            toAddress: toAddress,
            status: 0,
            numTokens : bottomRate.mul(numTokens).div(100)
        });
        insideAdd(bottomAddress,bottom.numTokens);
        // 手续费3%
        Obj memory fee = Obj({
            fromAddress: fromAddress,
            toAddress: toAddress,
            status: 0,
            numTokens : feeRate.mul(numTokens).div(100)
        });
        insideAdd(feeAddress,fee.numTokens);
        arr[1].push(destroy);
        arr[2].push(bottom);
        arr[3].push(fee);
    }
}

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