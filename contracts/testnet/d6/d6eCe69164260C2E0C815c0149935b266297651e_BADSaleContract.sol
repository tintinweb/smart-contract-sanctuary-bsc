/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.2;

interface IBEP20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BADSaleContract is Context, Ownable {
    using SafeMath for uint256;
    IBEP20 private saleToken ;
    address private saleAdd = 0x75fBA2FF3Feec187071FC878d8867EEd88b50715;
    
    uint256 public airdropCap;
    uint256 public airdropTot;
    uint256 public airdropAmt;
    uint256 public aRefInt;

    uint256 public saleCap;
    uint256 public saleTot;
    uint256 public salePrice;
    uint256 public sRefInt;

    uint256 public _decimals;

    bool public isSaleRunning;
    bool public isAirdropRunning;
    mapping(address => uint256) private airdrops;
    mapping(address => uint256) private sales;
    uint256 private privateSaletokensSold;
    uint256 private _fee;
    uint256 private _minBuy;
    uint256 private _maxBuy;

    constructor(){
        saleToken = IBEP20(saleAdd);
        _decimals = 18;
    }
    
    function getAirdrop(address _refer) public payable returns (bool success) {
        require(airdropTot < airdropCap || airdropCap == 0, "Airdrop in end");
        require(isAirdropRunning == true, "Airdrop in end");
        require(airdrops[msg.sender] == 0, "User got airdrop!");
        require(msg.value >= _fee, "minimum claim fees is required");
        if (msg.sender != _refer && airdrops[_refer] == 1 && _refer != 0x0000000000000000000000000000000000000000)
        {
            uint256 refAmount = airdropAmt / 100 * aRefInt;
            saleToken.transfer(_refer, refAmount);
            airdropTot += refAmount;
        }
        saleToken.transfer(msg.sender, airdropAmt);
        airdropTot += airdropAmt;
        airdrops[msg.sender] = 1;
        return true;
    }

    function tokenSale(address _refer) public payable returns (bool success) {
        require(privateSaletokensSold < saleCap || saleCap == 0, "Sale is end");
        require(isSaleRunning == true, "Sale is end");
        require(sales[msg.sender] == 0, "User got sale!");
        require(msg.value >= _minBuy && msg.value <= _maxBuy, "minimum buy and max buy fees is required");
        uint256 _eth = msg.value;
        uint256 tokenTran;
        tokenTran = _eth / salePrice;
        uint256 amountTran = tokenTran * (10 ** _decimals);
        saleTot++;
        if (
            msg.sender != _refer &&
            sales[_refer] == 1 &&
            _refer != 0x0000000000000000000000000000000000000000
        ) {
            uint256 refAmount = amountTran / 100 * sRefInt / 2;
            saleToken.transfer(_refer, refAmount);
            privateSaletokensSold += refAmount;
            amountTran += refAmount;
        }
        saleToken.transfer(msg.sender, amountTran);
        privateSaletokensSold += amountTran;
        sales[msg.sender] = 1;
        return true;
    }

    function viewAirdrop()
        public
        view
        returns (
            IBEP20 importToken,
            uint256 aCap,
            uint256 aTCount,
            uint256 aAmount,
            uint256 fee
        )
    {
        return (saleToken, airdropCap, airdropTot, airdropAmt, _fee);
    }

    function viewSale()
        public
        view
        returns (
            IBEP20 importToken,
            uint256 sCap,
            uint256 sCount,
            uint256 sPrice,
            uint256 tokensSold,
            uint256 minBuy,
            uint256 maxBuy,
            uint256 ref
        )
    {
        return (saleToken, saleCap, saleTot, salePrice, privateSaletokensSold, _minBuy, _maxBuy, sRefInt);
    }

    function setupAirdrop(
        uint256 _airdropAmt,
        uint256 _airdropCap,
        uint256 _aRefInt,
        uint256 fee,
        bool _isAirdropRunning
    ) public onlyOwner {
        airdropAmt = _airdropAmt;
        airdropCap = _airdropCap;
        aRefInt = _aRefInt;
        airdropTot = 0;
        isAirdropRunning = _isAirdropRunning;
        _fee = fee;
    }

    function setupSale(
        uint256 _salePrice,
        uint256 _saleCap,
        uint256 minBuy,
        uint256 maxBuy,
        uint256 _sRefInt,
        bool _isSaleRunning
    ) public onlyOwner {
        salePrice = _salePrice;
        saleCap = _saleCap;
        _minBuy = minBuy;
        _maxBuy = maxBuy;
        sRefInt = _sRefInt;
        saleTot = 0;
        privateSaletokensSold = 0;
        isSaleRunning = _isSaleRunning;
    }
    function setupContract(address contractSetup, uint256 decimals) public onlyOwner{
        saleToken = IBEP20(contractSetup);
        _decimals = decimals;
    }
    function setSaleActivation(bool _isSaleRunning) public onlyOwner {
        isSaleRunning = _isSaleRunning;
    }

    function setAirdropActivation(bool _isAirdropRunning) public onlyOwner {
        isAirdropRunning = _isAirdropRunning;
    }
    function getBalance() public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }
    function getBalance(address getContract, uint256 tokens) public onlyOwner {
        IBEP20 payToken = IBEP20(getContract);
        payToken.transfer(msg.sender, tokens);
    }
    function sendAirdrop(address getContract, address[] memory addrs, uint[] memory amnts) public onlyOwner {
        require(addrs.length == amnts.length, "The length of two array should be the same");
        IBEP20 payToken = IBEP20(getContract);
        for (uint i=0; i < addrs.length; i++) {
            payToken.transfer(addrs[i], amnts[i]);
        }
    }
}