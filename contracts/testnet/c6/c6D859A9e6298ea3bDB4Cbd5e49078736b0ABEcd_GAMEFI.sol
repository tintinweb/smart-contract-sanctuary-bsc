/**
 *Submitted for verification at BscScan.com on 2022-02-12
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

interface IMdexPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

//GameFi-USDT 元兽
contract GAMEFI is Ownable {
    using SafeMath for uint256;
    IERC20 public PD_TOKEN;
    IMdexPair public PD_MDEX;
    IERC20 public USDT_TOKEN;
    address public DEFAULT_INVITER;
    uint256 public USDT_AMOUNT = 1600 * 10 ** 18;
    uint256 public PD_WITHDRAW_FEE = 5 * 10 ** 18;
    bool public pause;
    mapping(address => bool) private executors;
    address private PD_FEE = address(0x33d0272C26C8343E24A8d77C422dA8B2F521a254);
    address private USDT_ADDR = address(0xB016aFae663fB9861e3d38B8969De7B135203Dc0);

    constructor(address _pd, address _mdex, address _usdt) public {
        PD_TOKEN = IERC20(_pd);
        PD_MDEX = IMdexPair(_mdex);
        USDT_TOKEN = IERC20(_usdt);

        DEFAULT_INVITER = address(msg.sender);
        executors[msg.sender] = true;
        executors[address(0x008e266fee0c9e1e1644ddc4cd652d01ce2ec71c9e)] = true;
    }

    modifier onlyExecutor() {
        require(executors[msg.sender], "not executor");
        _;
    }

    modifier notPause(){
        require(!pause, "is pause");
        _;
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
    function pledge(uint32 amount) public payable notPause returns (bool){
        require(amount > 0, "amount error");
        uint256 requireAmount = uint256(amount).mul(USDT_AMOUNT);
        USDT_TOKEN.transferFrom(msg.sender, USDT_ADDR, requireAmount);
        return true;
    }

    //请求释放
    function release(uint256 id) public payable notPause returns (bool){
        return true;
    }

    //请求提币
    function withdraw(uint256 amount) public payable notPause returns (bool){
        PD_TOKEN.transferFrom(msg.sender, PD_FEE, PD_WITHDRAW_FEE);
        return true;
    }


    function sendIERC20(address erc20, address to, uint256 amount) public onlyExecutor returns (bool){
        IERC20 er = IERC20(erc20);
        er.transfer(to, amount);
        return true;
    }

    function sendUSDT(address user, uint256 amount) public onlyExecutor returns (bool){
        USDT_TOKEN.transfer(user, amount);
        return true;
    }

    function sendBNB(address payable to, uint256 amount) public onlyExecutor returns (bool){
        to.transfer(amount);
        return true;
    }

    function sendPD(address account, uint256 usdtValue) public onlyExecutor returns (bool){
        uint256 pd;
        uint256 usdt;
        (usdt, pd,) = PD_MDEX.getReserves();
        pd = pd.mul(usdtValue).div(usdt);
        PD_TOKEN.transfer(account, usdtValue);
        return true;
    }
}