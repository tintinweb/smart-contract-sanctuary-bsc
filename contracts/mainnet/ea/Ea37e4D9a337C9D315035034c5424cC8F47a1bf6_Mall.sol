/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
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
        return msg.data;
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// 
interface Token {      
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Mall is Ownable{
    using SafeMath for uint256;
    Token pledgeToken;
    Token wbnb;
    IUniswapV2Pair lp;
    address public lpAddress;
    // address _swapV2Pair;
    


    constructor(address contractAddress,address _lp){
         pledgeToken = Token(contractAddress);
         wbnb = Token(0x0dE8FCAE8421fc79B29adE9ffF97854a424Cad09);
         lp=IUniswapV2Pair(_lp);
         lpAddress=_lp;
    }
    
    uint256 private _minimum = 10000*10**18;//最低1万u可升级为商家
    uint256 private _releaseDays= 14;//赎回等待期
    uint private unlocked = 1;

    //单次质押记录
    struct pledgeRecord {
        uint256 num;//质押数量
        uint256 time;//时间
        address pledgor;//质押地址
    }
    //单次赎回记录
    struct releaseRecord {
        uint256 rid;
        uint256 num;//赎回数量
        uint256 time;//时间
        uint256 releaseTime;//释放时间
        bool isCol;//是否已经领取
        address pledgor;//地址
    }
    //商家列表
    struct mallInfo {
        uint256 allNum;//总质押
        uint256 currentNum;//当前质押
        bool state;//满足商家条件1
    }

    pledgeRecord[] public pledgeRecords;//
    releaseRecord[] public releaseRecords;//
    //mapping (uint256 => Record) public pledgeRecords;//质押记录
    mapping (address => mallInfo) public malls;//商家详情
    mapping (address => uint256) public pledgeCount;//质押次数
    mapping (address => uint256) public releaseCount;//赎回次数

    event pledgeEvent(uint num,address pledgor);
    event releaseEvent(uint num,uint releaseTime,address  pledgor);
    event collectEvent(uint num,address pledgor);

    //质押
    function pledge(uint num) public lock returns(bool) {
        require(num >= 1 ether);

        //Token pledgeToken = Token(contractAddress);
        require(pledgeToken.allowance(msg.sender,address(this))>=num);

        pledgeToken.transferFrom(msg.sender, address(this), num);

        pledgeRecords.push(pledgeRecord(
            num,block.timestamp,msg.sender
        ));

        if(malls[msg.sender].allNum == 0){
            malls[msg.sender] = mallInfo(num,num,false);
        }else{
            malls[msg.sender].allNum = malls[msg.sender].allNum.add(num);
            malls[msg.sender].currentNum = malls[msg.sender].currentNum.add(num);
        }
        malls[msg.sender].state =isMall(msg.sender);

        pledgeCount[msg.sender]=pledgeCount[msg.sender].add(1);

        emit pledgeEvent(num,msg.sender);

        return true;
    }

    //赎回
    function release(uint num) public lock returns(bool) {
        require(malls[msg.sender].allNum >= 0 && num <= malls[msg.sender].currentNum);

        malls[msg.sender].currentNum = malls[msg.sender].currentNum.sub(num);
        malls[msg.sender].state =isMall(msg.sender);

        releaseRecords.push(releaseRecord(
            releaseRecords.length,num,block.timestamp,block.timestamp.add(_releaseDays*24*60*60),false,msg.sender
        ));

        releaseCount[msg.sender]=releaseCount[msg.sender].add(1);

        emit releaseEvent(num,block.timestamp.add(_releaseDays*24*60*60),msg.sender);

        return true;
    }

    //领取赎回
    function collect(uint256 releaseIndex) public lock returns(bool) {
        require(releaseRecords[releaseIndex].pledgor == msg.sender && !releaseRecords[releaseIndex].isCol && block.timestamp >= releaseRecords[releaseIndex].releaseTime);
        require(pledgeToken.balanceOf(address(this))>=releaseRecords[releaseIndex].num);
        releaseRecords[releaseIndex].isCol=true;
        pledgeToken.transfer(releaseRecords[releaseIndex].pledgor,releaseRecords[releaseIndex].num);

        emit collectEvent(releaseRecords[releaseIndex].num,msg.sender);
        return true;
    }

    function getMallInfo(address _address) public view returns(mallInfo memory){
        return malls[_address];
    }

    function isMall(address input) public view returns(bool){

        // if(malls[input].currentNum >= _minimum && getStake2bnb(input)>=10 ether){
        //     return true;
        // }else{
        //     return false;
        // }

        if(malls[input].currentNum >= _minimum ){
            return true;
        }else{
            return false;
        }
        
    }

    // function getStake2bnb(address _account) public view returns (uint){
    //     uint _totalSupplyOfLp = lp.totalSupply();

    //     if(_totalSupplyOfLp ==0){
    //         return 0;
    //     }
    //     uint _totalUInPair = wbnb.balanceOf(lpAddress);

     

    //     return  lp.balanceOf(_account) * _totalUInPair / _totalSupplyOfLp;
    // }

    function getPledgeRecords(address pledgor) public view returns (pledgeRecord[] memory) {
        pledgeRecord[] memory result ;
        result= new pledgeRecord[](pledgeCount[pledgor]);
        uint counter = 0;
        for (uint i = 0; i < pledgeRecords.length; i++) {
            if (pledgeRecords[i].pledgor== pledgor) {
                result[counter] = pledgeRecords[i];
                counter++;
            }
        }
            
        return result;
    }

    function getReleaseRecords(address pledgor) public view returns (releaseRecord[] memory) {
        releaseRecord[] memory result ;
        result= new releaseRecord[](releaseCount[pledgor]);
        uint counter = 0;
        for (uint i = 0; i < releaseRecords.length; i++) {
            if (releaseRecords[i].pledgor== pledgor) {
                result[counter] = releaseRecords[i];
                counter++;
            }
        }
            
        return result;
    }

    function getRecordIndex(address pledgor,uint256 classes) public view returns(uint256[] memory){
        uint[] memory result ;
        if(classes==0){
            result= new uint[](pledgeCount[pledgor]);
            uint counter = 0;
            for (uint i = 0; i < pledgeRecords.length; i++) {
                if (pledgeRecords[i].pledgor== pledgor) {
                    result[counter] = i;
                    counter++;
                }
            }
            
        }else if(classes==1){
            result = new uint[](releaseCount[pledgor]);
            uint counter = 0;
            for (uint i = 0; i < releaseRecords.length; i++) {
                if (releaseRecords[i].pledgor== pledgor) {
                    result[counter] = i;
                    counter++;
                }
            }
        }
        return result;
        
    }

    function subMallPledge(uint256 num , address mallAddress,address outAddress) external onlyOwner returns(bool){
        require(pledgeToken.balanceOf(address(this))>=num);
        require(malls[mallAddress].currentNum>=num);

        pledgeToken.transfer(outAddress,num);
        malls[mallAddress].currentNum=malls[mallAddress].currentNum.sub(num);
        return true;
    }

    function setMin(uint256 num ) external onlyOwner {
        _minimum=num;
    }

    function setReleaseDays(uint256 newDays) external onlyOwner {
        _releaseDays=newDays;
    }

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    
}