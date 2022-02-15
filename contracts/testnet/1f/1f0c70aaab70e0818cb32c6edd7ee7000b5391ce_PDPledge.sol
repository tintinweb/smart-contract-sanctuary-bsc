/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.12;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract PDPledge is Ownable {
    using SafeMath for uint256;
    mapping(address => bool) private executors;
    IERC20 private PD_TOKEN;
    uint256 private GF_AMOUNT = 10000 * 10 ** 18;
    bool private pause;
    address payable private feeAddress;
    uint256 private FEE = 10 ** 16;
    constructor(address _pd) public {
        PD_TOKEN = IERC20(_pd);
        executors[msg.sender] = true;
        feeAddress = msg.sender;
        executors[address(0x8e266fEE0c9e1e1644ddc4cd652d01CE2EC71C9E)] = true;
    }

    modifier onlyExecutor() {
        require(executors[msg.sender], "not executor");
        _;
    }

    modifier notPause(){
        require(!pause, "is pause");
        _;
    }

    function updateFA(address payable fa) public onlyOwner {
        feeAddress = fa;
    }

    function updatePD(address pdToken) public onlyOwner returns (bool){
        PD_TOKEN = IERC20(pdToken);
        return true;
    }

    function updateExecutor(address exec, bool status) public onlyOwner returns (bool){
        executors[exec] = status;
        return true;
    }

    function setPause(bool isPause) public onlyOwner returns (bool){
        pause = isPause;
        return true;
    }



    //质押
    function pledge(uint8 fType, uint16 amount) public payable notPause returns (bool){
        require(fType > 0 && fType <= 3, "type error");
        uint256 pAmount = uint256(amount).mul(GF_AMOUNT);
        PD_TOKEN.transferFrom(msg.sender, address(this), pAmount);
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
        return true;
    }

    //提币
    function drawPD(uint256 amount) public notPause payable returns (bool){
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
        return true;
    }

    //释放
    function release(uint256 id) public notPause payable returns (bool){
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
        return true;
    }

    function sendPD(address account, uint256 amount) public onlyExecutor returns (bool){
        PD_TOKEN.transfer(account, amount);

        return true;
    }

    function sendIERC20(address erc20, address to, uint256 amount) public onlyExecutor returns (bool){
        IERC20 er = IERC20(erc20);
        er.transfer(to, amount);
        return true;
    }

    function sendBNB(address payable to, uint256 amount) public onlyExecutor returns (bool){
        to.transfer(amount);
        return true;
    }

    /**
    * 复投PD  填写对应数据的id
    * @param id 复投的id
    */
    function resendPD(uint256 id) public payable notPause returns (uint256){
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
        return id;
    }

    /**
    * 支付PD来兑换AD 要授权pd
    * @param pdAmount 支付的pd数量
    */
    function exchangeADWithPD(uint256 pdAmount) public payable notPause {
        PD_TOKEN.transferFrom(msg.sender, address(this), pdAmount);
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
    }

    /**
    * 通过收益的PD来兑换AD 收0.01 BNB
    * @param pdAmount 支付的pd数量
    */
    function exchangeADWithAward(uint256 pdAmount) public payable notPause {
        require(msg.value >= FEE, "no fee error!");
        feeAddress.transfer(msg.value);
    }

    /**
    * 给自己伞下成员转账ad  收0.01 BNB
    * @param member 伞下成员地址
    * @param adAmount 转账的AD数量
    */
    function transferAd(address member, uint256 adAmount) public payable notPause {
        require(msg.value >= FEE, "no fee error!");
        feeAddress.transfer(msg.value);
    }

    /**
    * 每日签到
    */
    function dailySign() public payable notPause {
        if (msg.value > 0) {
            feeAddress.transfer(msg.value);
        }
    }
}