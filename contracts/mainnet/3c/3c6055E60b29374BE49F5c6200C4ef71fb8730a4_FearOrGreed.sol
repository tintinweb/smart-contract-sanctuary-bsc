// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./libraries/fogLib.sol";
import "./tokenSwaper.sol";

contract FearOrGreed is Ownable, TokenSwaper {
    // constants
    uint256 constant FOG_GREEDER = 1080000;
    uint256 constant PSN = 10000;
    uint256 constant PSNH = 5000;

    // attributes
    uint256 public marketFnGIndex;
    uint256 public startTime = 7777777777;
    uint256 public minimumPrice = 10000000000000000;
    address public badgeAddress;

    mapping(address => uint256) private lastGreeding;
    mapping(address => uint256) private greedingGreeders;
    mapping(address => uint256) private claimedFog;
    mapping(address => uint256) private tempClaimedFog;
    mapping(address => address) private referrals;
    mapping(address => ReferralData) private referralData;

    // structs
    struct ReferralData {
        address[] invitees;
        uint256 rebates;
    }

    // modifiers

    modifier onlyOpen() {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen() {
        require(marketFnGIndex > 0, "not start open");
        _;
    }

    modifier onlyBadge() {
        require(msg.sender == badgeAddress, "not badge contract caller");
        _;
    }

    // events
    event Create(address indexed sender, uint256 indexed amount);
    event Fear(address indexed sender, uint256 indexed amount);

    //router address
    constructor(address _routerAddress, address _wEthAddress)
        TokenSwaper(_routerAddress, _wEthAddress)
    {}

    //  Lambo!
    function winLambo(address _ref) external payable onlyStartOpen onlyOpen{
        require(msg.value >= minimumPrice, "wrong minimum price");
        uint256 fogGreed = calculateFogGreed(
            msg.value,
            address(this).balance - msg.value
        );
        fogGreed -= devFee(fogGreed);
        uint256 fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner().call{value: (fee * 100) / 100}("");
        require(ownerSuccess, "owner pay failed");

        claimedFog[msg.sender] += fogGreed;
        iamGreed(_ref);

        emit Create(msg.sender, msg.value);
    }

    function winLamboFromBadges(
        address _badgeOwner,
        uint256 _amount,
        address _ref
    ) public payable onlyStartOpen onlyBadge onlyOpen{
        uint256 fogGreed = calculateFogGreed(
            _amount,
            address(this).balance - _amount
        );
        fogGreed -= devFee(fogGreed);

        claimedFog[_badgeOwner] += fogGreed;
        greedFromBadge(_badgeOwner, _ref);

        emit Create(_badgeOwner, _amount);
    }

    // greed
    function iamGreed(address _ref) public onlyStartOpen onlyOpen{
        address _owner = owner();
        if (
            _ref == msg.sender ||
            _ref == address(0) ||
            greedingGreeders[_ref] == 0
        ) {
            _ref = _owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint256 fogInx = getMyFogIndex(msg.sender);
        uint256 newGreeders = fogInx / FOG_GREEDER;
        greedingGreeders[msg.sender] += newGreeders;
        claimedFog[msg.sender] = 0;
        lastGreeding[msg.sender] = block.timestamp > startTime
            ? block.timestamp
            : startTime;

        // referral rebate
        uint256 fogRebate = (fogInx * 13) / 100;
        if (referrals[msg.sender] == _owner) {
            claimedFog[_owner] += (fogRebate * 100) / 100;
            tempClaimedFog[_owner] += (fogRebate * 100) / 100;
        } else {
            claimedFog[referrals[msg.sender]] += fogRebate;
            tempClaimedFog[referrals[msg.sender]] += fogRebate;
        }

        marketFnGIndex += fogInx / 5;
    }

    function greedFromBadge(address _badgeOwner, address _ref) private {
        address _owner = owner();
        if (
            _ref == _badgeOwner ||
            _ref == address(0) ||
            greedingGreeders[_ref] == 0
        ) {
            _ref = _owner;
        }

        if (referrals[_badgeOwner] == address(0)) {
            referrals[_badgeOwner] = _ref;
            referralData[_ref].invitees.push(_badgeOwner);
        }

        uint256 fogInx = getMyFogIndex(_badgeOwner);
        uint256 newGreeders = fogInx / FOG_GREEDER;
        greedingGreeders[_badgeOwner] += newGreeders;
        claimedFog[_badgeOwner] = 0;
        lastGreeding[_badgeOwner] = block.timestamp > startTime
            ? block.timestamp
            : startTime;

        // referral rebate
        uint256 fogRebate = (fogInx * 15) / 100;
        if (referrals[_badgeOwner] == _owner) {
            claimedFog[_owner] += (fogRebate * 100) / 100;
            tempClaimedFog[_owner] += (fogRebate * 100) / 100;
        } else {
            claimedFog[referrals[_badgeOwner]] += fogRebate;
            tempClaimedFog[referrals[_badgeOwner]] += fogRebate;
        }

        marketFnGIndex += fogInx / 5;
    }

    // fog iamFear
    function iamFear(string calldata _tokenName) external onlyOpen {
        uint256 fogInx = getMyFogIndex(msg.sender);
        uint256 fogValue = calculateFogFear(fogInx);
        uint256 fee = devFee(fogValue);
        uint256 realReward = fogValue - fee;

        if (tempClaimedFog[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculateFogFear(
                tempClaimedFog[msg.sender]
            );
        }

        // dev fee
        (bool ownerSuccess, ) = owner().call{value: (fee * 100) / 100}("");
        require(ownerSuccess, "owner pay failed");

        claimedFog[msg.sender] = 0;
        tempClaimedFog[msg.sender] = 0;
        lastGreeding[msg.sender] = block.timestamp;
        marketFnGIndex += fogInx;

        bool isSuccess = TokenSwaper.swapETHforToken(
            realReward,
            msg.sender,
            _tokenName
        );
        require(isSuccess, "claim failed");
        emit Fear(msg.sender, realReward);
    }

    function letsLambo(uint256 _startTime) external onlyOwner {
        require(marketFnGIndex == 0);
        require(_startTime > 0);
        startTime = _startTime;
        marketFnGIndex = 108000000000;
    }

    function fogRewards(address _address) public view returns (uint256) {
        return calculateFogFear(getMyFogIndex(_address));
    }

    function getMyFogIndex(address _address) public view returns (uint256) {
        return claimedFog[_address] + getFogSinceLastGreed(_address);
    }

    function getClaimFog(address _address) public view returns (uint256) {
        return claimedFog[_address];
    }

    function getFogSinceLastGreed(address _address)
        public
        view
        returns (uint256)
    {
        if (block.timestamp > startTime) {
            uint256 secondsPassed = min(
                FOG_GREEDER,
                block.timestamp - lastGreeding[_address]
            );
            return secondsPassed * greedingGreeders[_address];
        } else {
            return 0;
        }
    }

    function getTempClaimFog(address _address) public view returns (uint256) {
        return tempClaimedFog[_address];
    }

    function getPoolAmount() public view returns (uint256) {
        return address(this).balance;
    }

    function getgreedingGreeders(address _address)
        public
        view
        returns (uint256)
    {
        return greedingGreeders[_address];
    }

    function getReferralData(address _address)
        public
        view
        returns (ReferralData memory)
    {
        return referralData[_address];
    }

    function getReferralAllRebate(address _address)
        public
        view
        returns (uint256)
    {
        return referralData[_address].rebates;
    }

    function getReferralAllInvitee(address _address)
        public
        view
        returns (uint256)
    {
        return referralData[_address].invitees.length;
    }

    function calculateFogGreed(uint256 _eth, uint256 _contractBalance)
        private
        view
        returns (uint256)
    {
        return calculateTrade(_eth, _contractBalance, marketFnGIndex);
    }

    function calculateFogFear(uint256 fog) public view returns (uint256) {
        return calculateTrade(fog, marketFnGIndex, address(this).balance);
    }

    function calculateTrade(
        uint256 fog,
        uint256 marketIndex,
        uint256 balance
    ) private pure returns (uint256) {
        return
            (PSN * balance) / (PSNH + ((PSN * marketIndex + PSNH * fog) / fog));
    }

    function devFee(uint256 _amount) private pure returns (uint256) {
        return (_amount * 3) / 100;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setBadgeContract(address _badgeAddress) public onlyOwner {
        badgeAddress = _badgeAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ISWAP.sol";

contract TokenSwaper is Ownable {
    using SafeMath for uint256;

    uint256 public supportedTokenCount = 0;

    mapping(string => address) public tokenAddressByName;
    IPancakeRouter02 public router;
    address public caller;

    constructor(address _router, address _wETH) {
        router = IPancakeRouter02(_router);
        tokenAddressByName["ETH"] = _wETH;
        supportedTokenCount.add(1);
    }

    event ClaimToken(uint256 amount, string tokenName);
    event AddNewToken(string tokenName, address tokenAddress);
    event RemoveSupportToken(string tokenName);

    modifier onlyCaller() {
        require(msg.sender == caller, "not caller");
        _;
    }

    function addClaimToken(string calldata _tokenName, address _tokenAddress)
        public
        onlyOwner
    {
        tokenAddressByName[_tokenName] = _tokenAddress;
        supportedTokenCount.add(1);

        emit AddNewToken(_tokenName, _tokenAddress);
    }

    function deleteClaimToken(string calldata _tokenName) public onlyOwner {
        delete tokenAddressByName[_tokenName];
        supportedTokenCount.sub(1);
        emit RemoveSupportToken(_tokenName);
    }

    function getEstimatedAmountOut(
        uint256 _rewardAmount,
        string calldata _tokenOut
    ) public view returns (uint256[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenAddressByName[_tokenOut];

        return router.getAmountsOut(_rewardAmount, path);
    }

    function swapETHforToken(
        uint256 _amount,
        address _to,
        string memory _tokenName
    ) internal returns (bool) {
        require(_amount > 0, "amount must grater than zero");
        require(_to != address(this), "wrong target");

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenAddressByName[_tokenName];

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amount
        }(0, path, _to, block.timestamp);

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library fogLib {
      function isContract(address _addr) internal view returns(bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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