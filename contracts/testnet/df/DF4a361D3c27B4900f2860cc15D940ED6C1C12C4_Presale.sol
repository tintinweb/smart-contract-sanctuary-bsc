/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-02
 */
// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.0;

interface IBEP20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
contract Ownable {
    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = payable(tx.origin);
        emit OwnershipTransferred(address(0), tx.origin);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
        _owner = payable(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Presale is Ownable {
    using SafeMath for uint256;

    // Token
    IBEP20 Token;
    IBEP20 BNB;
    IBEP20 USDT;
    uint256 bnb_unit;
    uint256 usdt_unit;
    uint256 cost = 0;
    uint256 totalMoneySpend = 0;
    uint256 public min_buy;
    uint256 public max_buy;
    uint256 public price;
    bool public onSale = false;
    bool public onClaim = false;
    address owner;
    address payable public sender;
    address public usdt_bnb = 0xedd5860EAfE0Cef31EaFBe021B363f75D9b17110;
    address[] public whitelistedAddresses;
    mapping(address => uint256) public addressMintedBalance;
    mapping(address => uint256) public addressTotalAmount;
    Presale public presale;

    constructor(address payable _sender) {
        Token = IBEP20(0xA9Afb65805e143980C4FC231E008DA764FD29b53);
        BNB = IBEP20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        USDT = IBEP20(0x878Ca3AF8FDA0344BA7DDbb2186489d18433cfE9);

        bnb_unit = 10**uint256(BNB.decimals());
        usdt_unit = 10**uint256(USDT.decimals());

        min_buy = 1 * usdt_unit; //500
        max_buy = 5 * usdt_unit; //5400
        price =  44* (10**(18 - 3));

        sender = _sender;
        owner = msg.sender;
    }

    function updatePresalePrice(
        uint256 _min_buy,
        uint256 _max_buy,
        uint256 _price
    ) public onlyOwner {
        min_buy = _min_buy;
        max_buy = _max_buy;
        price = _price;
    }

    function updatePresaleSender(address payable _sender) public onlyOwner {
        sender = _sender;
    }

    // Open sale
    function setSaleStatus(bool _state) public onlyOwner {
        onSale = _state;
    }

    // Open claim
    function setClaimStatus(bool _state) public onlyOwner {
        onClaim = _state;
    }

    // Get BNB price by USDT
    function getBNBPrice(uint256 amount) public view returns (uint256) {
        uint256 bnb = BNB.balanceOf(usdt_bnb);
        uint256 usdt = USDT.balanceOf(usdt_bnb);
        return bnb.mul(amount).div(usdt);
    }

    // Get USDT price by BNB
    function getUSDTPrice(uint256 amount) public view returns (uint256) {
        uint256 bnb = BNB.balanceOf(usdt_bnb);
        uint256 usdt = USDT.balanceOf(usdt_bnb);
        return usdt.mul(amount).div(bnb);
    }

    ////////////////////
    //   WHITE LIST   //
    ////////////////////
    function addAddressToWhiteList(address[] calldata addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistedAddresses.push(addresses[i]);
        }
    }

    //clean White List
    function cleanWhiteList() public onlyOwner {
        delete whitelistedAddresses;
    }

    function isWhitelisted(address _user) public view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function testBuyAmount(uint256 _amount) public view returns (uint256){
        return getBNBPrice(_amount.mul(10**uint256(Token.decimals()))).mul(price).div(usdt_unit);
    }

    // Presale
    function buyToken(uint256 _amount) public payable{
        require(onSale != false, "Pre-sales period has ended");
        cost = _amount.mul(10**uint256(Token.decimals())).mul(price).div(usdt_unit);
        totalMoneySpend = cost + addressTotalAmount[msg.sender];
        require(msg.value >= getBNBPrice(cost), "insufficient funds");
        // if (msg.sender != owner) {
        if (onSale == true) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");
            // check if total token taken more than 5400 usdt
            require(
                totalMoneySpend <= max_buy,
                "Total amount bigger than max buy amount"
            );
            //check if total less than 500 usdt
            require(
                totalMoneySpend >= min_buy,
                "Total amount smaller than min buy amount"
            );
            // require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        }

        BNB.transferFrom(msg.sender, owner, getBNBPrice(cost));

        addressTotalAmount[msg.sender] += cost;
    }

    // Get more amount
    function claimToken() public payable {
        // uint256 amount = 0;
        // for(uint256 i=0; i<remains_time[tx.origin].length; i++){
        //     if(remains_time[tx.origin][i] <= block.timestamp) {
        //         // Get amount
        //         if(remains_amount[tx.origin][i] != 0) {
        //             amount = amount.add(remains_amount[tx.origin][i]);
        //             remains_amount[tx.origin][i] = 0;
        //         }
        //     }
        // }
        // require(token_out.balanceOf(sender) >= amount, "Pre-sales program has ended");
        // require(amount > 0, "You already get all the token");
        // token_out.transferFrom(sender, tx.origin, amount);
    }
}