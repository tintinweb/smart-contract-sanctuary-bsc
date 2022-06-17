/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ContractOwner {
    //　合约拥有者
    address public contractOwner = msg.sender; 
    
    modifier ContractOwnerOnly {
        // 只有合约拥有者可以调用
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

contract Manager is ContractOwner {

    // 映射members(成员)
    mapping(string => address) public members;

    // 映射userPermits(用户许可)  地址 => string => bool
    mapping(address => mapping(string => bool)) public userPermits;
    
    // 修改|添加|删除 member(成员)
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    // 修改|添加|删除 userPermit(用户许可) 
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    // 获得当前时间戳
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}

// 抽象生成合约
abstract contract Member {
    // 修饰 检查当前用户string行为的许可
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }

     modifier ContractOwnerOnly {
        // 只有合约拥有者可以调用
        require(msg.sender == admin, "contract owner only");
        _;
    }

    // 生成manager(经理)
    Manager public manager;

    address public  admin;

    address public newAdmin;

    constructor(){
      admin = msg.sender;
    }

    
    // 迁移
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }

     function setNewAdmin (address _newAdmin) external ContractOwnerOnly {
        require(admin == msg.sender,"you are not admin");
        newAdmin = _newAdmin;
    }
    
    function getNewAdmin () public {
        require(newAdmin == msg.sender,"you are not newAdmin");
        admin = msg.sender;
    }
}


interface IERC20 {
    function decimals()  external view returns (uint256);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function burn(uint256 amount) external returns (bool);
    

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
library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract FreedToken is Member {
    struct FreedInfo {
        uint256 freeTime;
        uint256 freeRate;
        bool isFish;
    }
    IERC20 public freeToken;
    using SafeMath for uint256;
  //  address[] public freeUser;
    address freeMan;
    uint256 public freeNo;
    uint256 public firstFree;
    mapping(uint256 => FreedInfo) public freeTeam;

    constructor(address _token) {
        freeToken = IERC20(_token);
        freeMan = msg.sender;
        freeTeam[0] = FreedInfo(1655447400, 200, true);
        freeTeam[1] = FreedInfo(1655447400, 83, true);
        freeTeam[2] = FreedInfo(1655447400, 83, true);
        freeTeam[3] = FreedInfo(1655447400, 83, true);
        freeTeam[4] = FreedInfo(1655447400, 83, true);
        freeTeam[5] = FreedInfo(1655447400, 83, true);
        freeTeam[6] = FreedInfo(1655447400, 83, true);
        freeTeam[7] = FreedInfo(1655447400, 83, true);
        freeTeam[8] = FreedInfo(1655447400, 83, true);
        freeTeam[9] = FreedInfo(1655447400, 83, true);
        freeTeam[10] = FreedInfo(1655447400, 83, true);
        freeTeam[11] = FreedInfo(1655447400, 83, true);
        freeTeam[12] = FreedInfo(1655447400, 83, true);
    }

    function freeStart() public {
        require(freeTeam[freeNo].freeTime < block.timestamp, "no time");
        require(freeTeam[freeNo].isFish, "is close");
        uint256 freeAmount;
        if (freeNo == 0) {
            freeAmount = freeToken.balanceOf(address(this)).sub(1).mul(20).div(
                100
            );
            firstFree = freeToken.balanceOf(address(this)).sub(freeAmount);
        } else {
            if (freeNo == 12) {
                freeAmount = freeToken.balanceOf(address(this));
            } else {
                freeAmount = firstFree.sub(1).mul(freeTeam[freeNo].freeRate).div(1000);
            }
        }
        freeTeam[freeNo].isFish = false;
        freeNo++;
        freeToken.transfer(freeMan, freeAmount);
    }

    // function safeFree() private view returns (uint256 amount) {
    //     uint256 length = freeUser.length + 1;
    //     amount = firstFree.sub(1).mul(freeTeam[freeNo].freeRate).div(1000).div(
    //         length
    //     );
    // }

    function setFreeUser(address _user) public CheckPermit("Config") {
        freeMan = _user;
    }

    function setFreeInfo(
        uint256 _no,
        uint256 _time,
        uint256 _rate
    ) public CheckPermit("Config") {
        freeTeam[_no] = FreedInfo(_time, _rate, true);
    }
}