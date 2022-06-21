// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

interface IReed {
    function connectToOtherContracts(address[] calldata _contracts) external;
}

interface IICO {
    function updatePriceForOneToken(uint256 price) external;

    function buy() external payable;

    function claimProfits() external;

    function claimTokensNotSold() external;

    function exchangeRate() external view returns (uint256);
}

contract ICOStorage {
    address public Token;
    uint256 public priceForOneToken; //Number of REEDS for 1BNB
}

contract ReedICO is ICOStorage, IICO, Ownable, IReed {
    using SafeMath for uint256;
    event PriceForOneTokenChanged(address setter, uint256 price);
    event TokenAddressSet(address setter, address token);
    event TokenBought(address buyer, uint256 amount);

    uint256 public totalREEDBought;
    uint256 public totalBNBraised;

    constructor() {
        totalREEDBought = 0;
        totalBNBraised = 0;
    }

    receive() external payable {
        buy();
    }

    function connectToOtherContracts(address[] calldata _contracts)
        external
        override
        onlyOwner
    {
        setTokenAddress(_contracts[0]);
    }

    function setTokenAddress(address token) internal {
        require(
            Token != token,
            "ICO: new token address is the same as the old one"
        );
        emit TokenAddressSet(msg.sender, token);
        Token = token;
    }

    function updatePriceForOneToken(uint256 price) external override onlyOwner {
        require(
            priceForOneToken != price,
            "ICO: new price is not different from the old price"
        );
        emit PriceForOneTokenChanged(msg.sender, price);
        priceForOneToken = price;
    }

    function buy() public payable override {
        require(Token != address(0), "ICO: Token address is not set yet");
        require(priceForOneToken != 0, "ICO: Price for one token not set yet");
        uint256 amount = msg.value;
        require(amount > 0, "ICO: Amount have to be bigger then 0");
        IERC20 token = IERC20(Token);
        require(
            token.balanceOf(address(this)) > 0,
            "ICO: No more tokens for sale"
        );

        uint256 tokensBought = amount.mul(priceForOneToken);
        totalREEDBought = totalREEDBought.add(tokensBought);
        totalBNBraised = totalBNBraised.add(amount);
        token.transfer(msg.sender, tokensBought);
        emit TokenBought(msg.sender, tokensBought);
    }

    function claimProfits() external override onlyOwner {
        address _owner = owner();
        payable(_owner).transfer(address(this).balance);
    }

    function claimTokensNotSold() external override onlyOwner {
        require(Token != address(0), "ICO: Token address is not set yet");
        IERC20 token = IERC20(Token);
        uint256 contractBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractBalance);
    }

    function exchangeRate() public view override returns (uint256) {
        return priceForOneToken;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

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
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    // Owner, Treasurer & Developer are Signers
    // both must sign for some Contract based
    // transactions to occur or to use TREASURY
    mapping(address => bool) public _signers;
    // This is our Reserve Bank (Multi-sig) Wallet
    // only the treasurer recieves or spends
    // fundings in the wallet and must be
    // signed by [owner], [treasurer], and [developer]
    address public treasurer;
    address public developer;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event TreasurySinged(address _signer);

    constructor() {
        _owner = _msgSender();
    }

    // check if sender can sign
    modifier canSign() {
        require(isSigner(_msgSender()), "REED: Not an authorised signer");
        _;
    }

    // check if all signers has signed
    modifier whenSigned() {
        require(
            _signers[_owner] && _signers[treasurer] && _signers[developer],
            "REED: All three ADMIN parties must sign"
        );
        _;
        _signers[treasurer] = false;
        _signers[developer] = false;
    }

    // Add signature to allow owner use
    // treasury transactional functions
    function signTreasury() external canSign {
        _signers[_msgSender()] = true;
        emit TreasurySinged(_msgSender());
    }

    // is account a registered signer
    // only owner / developer / treasurer
    // are registered signers
    function isSigner(address _account) private view returns (bool) {
        bool yesOrNo = (_account == _owner ||
            _account == treasurer ||
            _account == developer);
        return yesOrNo;
    }

    //

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
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _setOwner(address(0));
    }

    // set a new owner
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        _signers[newOwner] = true;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}