// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC1155.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./Strings.sol";
import "./ReentrancyGuard.sol";

contract LaunchpadSell is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;

    event FillOrder(uint256 indexed tokenId, address buyer, uint256 qty, string launchpad_id);

    struct ProjectSale {
        uint256 total_sell;
        uint256 qty_sell;
        address contract_token;
        uint256 price_token;
        uint256 price_chain;
        uint256 price_usdt;
        uint256 percentage_of_shares;
        bool active_save;
        uint256 start_time_sell;
        uint256 end_time_sell;
    }

    // launchpad id => ProjectSale
    mapping(string => ProjectSale) public optionSale;

    mapping(address => bool) public blackList;

    LaunchpadNFTERC1155Core private LaunchpadCore;
    IERC1155 private LaunchpadNFT;
    uint256 public feeLaunchpad = 35;
    address payable public feeWallet = payable(0xd44174532d77fE3C0fD3058964582510E7E07A34);
    address payable public launchpadWallet = payable(0x8b9588F69e04D69655e0d866cD701844177360A7);
    uint256 constant public PERCENTS_DIVIDER = 1000;
    IERC20 private USDT;

    address admin = 0x36b5628e587C257B64c41c63c9f0b67c0D27cad4;
    address supervisor = 0x317A449138Dd7D2FD2c11a66D2FCB2B315e4711D;
    address bot = 0xCAF84d187C3DD9d8ee91aFef9C9af5194dd3916e;
    bool public activeControl = true;
    bool public offContract = false;

    constructor(
        IERC20 _USDT,
        address _LaunchpadNFT
    )  {
        USDT = _USDT;
        LaunchpadNFT = IERC1155(_LaunchpadNFT);
        LaunchpadCore = LaunchpadNFTERC1155Core(_LaunchpadNFT);
    }

    modifier onlySupervisor() {
        require(activeControl == true, "ask admin for approval");
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }
    modifier onlyBot(){
        require(_msgSender() == bot, "require safe Bot Address.");
        _;
    }
    modifier onlyAdmin(){
        require(_msgSender() == admin, "require safe Admin Address.");
        _;
    }
    function changeActiveControl(bool active) public onlyAdmin {
        activeControl = active;
    }

    function changeOffContract(bool active) public onlyAdmin {
        offContract = active;
    }

    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }

    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function changeBot(address _bot) public onlyOwner {
        bot = _bot;
    }

    function setFeeWallet(address payable _wallet) public onlySupervisor {
        feeWallet = _wallet;
    }

    function setLaunchpadWallet(address payable _wallet) public onlySupervisor {
        launchpadWallet = _wallet;
    }

    function setFeeLaunchpad(uint256 _fee) public onlySupervisor {
        feeLaunchpad = _fee;
    }

    function setBlackList(address[] memory _user, bool _block) onlySupervisor public {
        for (uint256 index; index < _user.length; index++) {
            blackList[_user[index]] = _block;
        }
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure virtual returns (bytes32) {
        return this.onERC1155Received.selector;
    }

    /**
      * @dev Withdraw bnb from this contract (Callable by owner only)
      */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }
    receive() external payable{}

    function placeOrder(
        string memory launchpad_id,
        uint256 total_sell,
        address contract_token,
        uint256 price_token,
        uint256 price_chain,
        uint256 price_usdt,
        uint256 percentage_of_shares,
        uint256 start_time_sell,
        uint256 end_time_sell
    ) public onlyBot {
        require(offContract == false, "Contract is not active");
        require(price_token > 0 || price_chain > 0 || price_usdt > 0, "nothing is free");
        require(total_sell > 0, "qty sell 0");
        require(percentage_of_shares > 0, "percentage of shares 0");
        require(start_time_sell < end_time_sell, "started time must be less than end time");
        require(optionSale[launchpad_id].total_sell > 0, "launchpad created");

        optionSale[launchpad_id].total_sell = total_sell;
        if(optionSale[launchpad_id].contract_token != address(0)) {
            optionSale[launchpad_id].contract_token = contract_token;
        }
        optionSale[launchpad_id].price_token = price_token;
        optionSale[launchpad_id].price_chain = price_chain;
        optionSale[launchpad_id].price_usdt = price_usdt;
        optionSale[launchpad_id].percentage_of_shares = percentage_of_shares;
        optionSale[launchpad_id].start_time_sell = start_time_sell;
        optionSale[launchpad_id].end_time_sell = end_time_sell;
        optionSale[launchpad_id].active_save = true;
    }

    function updateOrder(
        string memory launchpad_id,
        uint256 total_sell,
        address contract_token,
        uint256 price_token,
        uint256 price_chain,
        uint256 price_usdt,
        uint256 percentage_of_shares
    ) public onlyBot {
        require(offContract == false, "Contract is not active");
        if(total_sell > 0){
            require(total_sell > optionSale[launchpad_id].total_sell || total_sell > optionSale[launchpad_id].qty_sell, "Invalid sells total");
            optionSale[launchpad_id].total_sell = total_sell;
        }
        if(optionSale[launchpad_id].contract_token != address(0)) optionSale[launchpad_id].contract_token = contract_token;
        if(price_token > 0) optionSale[launchpad_id].price_token = price_token;
        if(price_chain > 0) optionSale[launchpad_id].price_chain = price_chain;
        if(price_usdt > 0) optionSale[launchpad_id].price_usdt = price_usdt;
        if(percentage_of_shares > 0) optionSale[launchpad_id].percentage_of_shares = percentage_of_shares;
    }

    function activeOrder(string memory launchpad_id, bool active, uint256 start_time_sell, uint256 end_time_sell) public onlyBot {
        require(offContract == false, "Contract is not active");
        optionSale[launchpad_id].active_save = active;
        if(start_time_sell > 0) optionSale[launchpad_id].start_time_sell = start_time_sell;
        if(end_time_sell > 0) optionSale[launchpad_id].end_time_sell = end_time_sell;
    }

    function updateTimeSale(string[] memory launchpad_id, uint256 start_time_sell, uint256 end_time_sell) public onlyBot {
        require(offContract == false, "Contract is not active");
        for(uint256 i = 0; i < launchpad_id.length; i++) {
            optionSale[launchpad_id[i]].start_time_sell = start_time_sell;
            optionSale[launchpad_id[i]].end_time_sell = end_time_sell;
        }
    }

    // 1 price token, 2 price chain (BNB/CSC/ONUS/...), 3 price usdt
    function fillOrder(string memory launchpad_id, uint256 qty, uint256 priceType) public payable nonReentrant {
        require(offContract == false, "Contract is not active");
        require(qty > 0, "Invalid purchase quantity");
        require(priceType == 1 || priceType == 2 || priceType == 3, "Invalid purchased token type");
        require(blackList[_msgSender()] == false, "owner in black list");
        require(optionSale[launchpad_id].start_time_sell >= block.timestamp, "not open for sale yet");
        require(optionSale[launchpad_id].end_time_sell < block.timestamp, "sale period has ended");
        require(optionSale[launchpad_id].qty_sell < optionSale[launchpad_id].total_sell, "sold out");
        require(optionSale[launchpad_id].active_save == true, "launchpad is not sell");

        if (priceType == 1) {
            require(optionSale[launchpad_id].contract_token != address(0), "contract token not found");
            require(optionSale[launchpad_id].price_token > 0, "not sell via Token");
            uint256 price = optionSale[launchpad_id].price_token.mul(qty);

            uint256 tokenBalance = IERC20(optionSale[launchpad_id].contract_token).balanceOf(_msgSender());
            require(tokenBalance >= price, "Not enough Tokens in the account to buy");

            IERC20(optionSale[launchpad_id].contract_token).transferFrom(_msgSender(), address(this), price);
            uint256 launchpadReceive = IERC20(optionSale[launchpad_id].contract_token).balanceOf(address(this));
            require(launchpadReceive > 0, "Buy NFT Fail");

            if(feeLaunchpad > 0) {
                uint256 _feeLaunchpad = price.mul(feeLaunchpad).div(PERCENTS_DIVIDER);
                launchpadReceive -= _feeLaunchpad;
                IERC20(optionSale[launchpad_id].contract_token).transfer(feeWallet, _feeLaunchpad);
            }
            IERC20(optionSale[launchpad_id].contract_token).transfer(launchpadWallet, launchpadReceive);
        } else if (priceType == 2) {
            require(optionSale[launchpad_id].price_chain > 0, "not sell via Token");
            uint256 price = optionSale[launchpad_id].price_chain.mul(qty);
            require(msg.value >= price, "The price to send is not correct");

            if(feeLaunchpad > 0) {
                uint256 _feeLaunchpad = price.mul(feeLaunchpad).div(PERCENTS_DIVIDER);
                price -= _feeLaunchpad;
                payable(feeWallet).transfer(_feeLaunchpad);
            }
            payable(launchpadWallet).transfer(price);
        } else {
            require(optionSale[launchpad_id].price_usdt > 0, "not sell via Token");
            uint256 price = optionSale[launchpad_id].price_usdt.mul(qty);
            uint256 UsdtBalance = USDT.balanceOf(_msgSender());
            require(UsdtBalance >= price, "Not enough USDT in the account to buy");

            if(feeLaunchpad > 0) {
                uint256 _feeLaunchpad = price.mul(feeLaunchpad).div(PERCENTS_DIVIDER);
                price -= _feeLaunchpad;
                USDT.transferFrom(_msgSender(), feeWallet, _feeLaunchpad);
            }
            USDT.transferFrom(_msgSender(), launchpadWallet, price);
        }

        uint256 tokenId = LaunchpadCore.getLaunchpadToTokenId(launchpad_id);
        if (tokenId == 0) {
            tokenId = LaunchpadCore.getNextNFTId();
            LaunchpadNFTERC1155 memory launchpad = LaunchpadNFTERC1155(
                tokenId,
                launchpad_id,
                optionSale[launchpad_id].percentage_of_shares,
                0,
                "",
                0,
                "",
                0,
                "",
                0,
                ""
            );
            LaunchpadCore.setNFTFactory(launchpad, tokenId);
        }
        LaunchpadCore.safeMintNFT(_msgSender(), tokenId, qty);
        emit FillOrder(tokenId, _msgSender(), qty, launchpad_id);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    function approve(address spender, uint256 tokenId, uint256 amount) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    function getApproved(address account, address spender, uint256 tokenId) external view returns (uint256);

    function isApprovedOrOwner(address account, address spender, uint256 tokenId, uint256 amount) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function _exists(address account, uint256 tokenId) external view returns (bool);
}

struct LaunchpadNFTERC1155 {
    uint256 tokenId;
    string launchpad_id;
    uint256 percentage_of_shares;
    uint256 attr1;
    string attr2;
    uint256 attr3;
    string attr4;
    uint256 attr5;
    string attr6;
    uint256 attr7;
    string attr8;
}
interface LaunchpadNFTERC1155Core {
    function setNFTFactory(LaunchpadNFTERC1155 memory _launchpad, uint256 _tokenId) external;
    function safeMintNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function safeBatchMintNFT(address _addr, uint256[] memory tokenId, uint256[] memory amount) external;
    function burnNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function burnBatchNFT(address _addr, uint256[] memory ids, uint256[] memory amounts) external;
    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view returns (LaunchpadNFTERC1155[] memory);
    function getLaunchpadFactory(uint256 _tokenId) external view returns (LaunchpadNFTERC1155 memory);
    function getLaunchpadToTokenId(string memory _launchpad_id) external view returns (uint256);
    function getNextNFTId() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}