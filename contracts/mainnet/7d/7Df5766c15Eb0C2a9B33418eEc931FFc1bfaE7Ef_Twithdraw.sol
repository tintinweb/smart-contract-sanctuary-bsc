/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.8.11;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


contract Twithdraw is Ownable {
    using SafeMath for uint256;

    uint256 public _starttime;
    uint256 public _totalAmount;
    uint256 public _yearAmount;
    address public withdrawAddress = address(0xEa3A2805F128Fb7Ad2870D827E1083f594229B00);
    address public tokenAddress = address(0xc84ef1A547BB705A711C28cb5eB4Dcd2130d2932);

    uint256 public _yearAdd;
    uint256 public _secondAdd;

    mapping(uint256 => bool) public wdList;
    mapping(uint256 => uint256) public yearList;


    constructor(uint256 totalAmount,uint256 yearAmount) {
        _totalAmount = totalAmount;
        _yearAmount = yearAmount;
        _owner = msg.sender;
        _starttime = dayZero();
    }


    function setAddr(address account) public onlyOwner {
        withdrawAddress = account;
    }
    function setTokenAddr(address account) public onlyOwner {
        tokenAddress = account;
    }

    function setTime(uint256 num) public onlyOwner {
        _starttime = num;
    }


    function set_yearAdd(uint256 num) public onlyOwner {
        _yearAdd = num;
    }


    function set_secondAdd(uint256 num) public onlyOwner {
        _secondAdd = num;
    }

    function wd() public onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        uint256 today = dayZero();
        uint256 year = getYear();

        require(!wdList[today],"today has wd");

        (uint256 todayYearAmount,uint256 amount) = getYearAmount();
        require(amount > 0 && balance >= amount, "Illegal amount");
        require(yearList[year] < todayYearAmount, "todayYearAmount error");

        yearList[year]=yearList[year].add(amount);
        wdList[today]=true;
        IERC20(tokenAddress).transfer(withdrawAddress, amount);

    }

    function getAmount() public view  returns(uint256) {
        (,uint256 todayDayAmount) = getYearAmount();

        return todayDayAmount;
    }

    function getYearAmount () public view returns(uint256,uint256){
        uint256 yearNum = getYear();
        uint256 todayYearAmount = _yearAmount/yearNum;
        uint256 dayAmount = todayYearAmount/365;
        return (todayYearAmount,dayAmount);
    }

    function getYear () public view returns(uint256){
        uint256 today = dayZero();
        uint256 second = today.sub(_starttime);
        return second/(365*24*3600)+1+_yearAdd;
    }

    function dayZero () public view returns(uint256){
        return block.timestamp-(block.timestamp%(24*3600))-(8*3600)+_secondAdd;
    }

    receive() external payable {}


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }



}