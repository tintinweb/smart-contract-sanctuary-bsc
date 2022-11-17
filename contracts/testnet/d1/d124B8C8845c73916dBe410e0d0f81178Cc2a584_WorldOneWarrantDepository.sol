// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

interface IERC20 {
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

interface IPangolinFactory {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

interface IPangolinPair {
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

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

interface ITreasury {
    function deposit( uint _amount, address _token, uint _fee ) external returns ( uint );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
    function convertToken( address _token, uint _amount ) external view returns ( uint value_ );
    function getTotalReserves() external view returns (uint);
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

library Address {

      function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value, 
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success, 
        bytes memory returndata, 
        string memory errorMessage
    ) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

import "./FullMath.sol";

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function add32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function sub32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function mul32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256 z){
        require(y > 0);
        z=x/y;
    }
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

import "./LowGasSafeMath.sol";
import "./Address.sol";
import "./../interfaces/IERC20.sol";

library SafeERC20 {
    using LowGasSafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender)
            .sub(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: Proprietary
pragma solidity 0.7.5;

contract OwnableData {
    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice `owner` defaults to msg.sender on construction.
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.
    /// Can only be invoked by the current `owner`.
    /// @param newOwner Address of the new owner.
    /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.
    /// @param renounce Allows the `newOwner` to be `address(0)` if `direct` and `renounce` is True. Has no effect otherwise.
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    /// @notice Needs to be called by `pendingOwner` to claim ownership.
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    /// @notice Only allows the `owner` to execute the function.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
pragma abicoder v2;

import "./libs/LowGasSafeMath.sol";
import "./libs/Address.sol";
import "./libs/SafeERC20.sol";
import "./libs/FullMath.sol";
import "./libs/FixedPoint.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IPangolinFactory.sol";
import "./interfaces/IPangolinPair.sol";
import "./utils/Ownable.sol";

contract WorldOneWarrantDepository is Ownable {
    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for uint32;

    /* ======== EVENTS ======== */
    event WarrantCreated(
        uint256 deposit,
        uint256 indexed payout,
        uint256 indexed expires,
        uint256 indexed priceInUSD
    );
    event WarrantRedeemed(
        address indexed recipient,
        uint256 payout,
        uint256 remaining
    );
    event WarrantPriceChanged(
        uint256 indexed priceInUSD,
        uint256 indexed internalPrice
    );
    event InitWarrantLot(WarrantLot terms);
    event LogSetFactory(address _factory);
    event LogRecoverLostToken(address indexed tokenToRecover, uint256 amount);

    /* ======== STATE VARIABLES ======== */

    IERC20 public immutable WorldOne; // token given as payment for warrant
    IERC20 public immutable principle; // token used to create warrant
    ITreasury public immutable treasury; // mints WorldOne when receives principle
    address public immutable DAO; // receives profit share from warrant
    IPangolinFactory public immutable dexFactory; // Factory address to get market price

    mapping(address => Warrant) public warrantInfo; // stores warrant information for depositors

    uint256 public warrantLotIndex = 0;

    uint32 constant MAX_PAYOUT_IN_PERCENTAGE = 100000; // in thousandths of a %. i.e. 500 = 0.5%
    uint32 constant MIN_VESTING_TERM =  129600;//129600; // in seconds. i.e. 1 day = 86400 seconds
    uint32 constant MAX_ALLOWED_DISCOUNT = 50000; // in thousandths of a %. i.e. 50000 = 50.00%
    uint8 constant CONVERSION_MIN = 0; // in thousandths of a %. i.e. 50000 = 50.00%
    uint8 constant CONVERSION_MAX = 10; // in thousandths of a %. i.e. 50000 = 50.00%

    /* ======== STRUCTS ======== */

    // Info for warrant holder
    struct Warrant {
        uint256 payout; // WorldOne remaining to be paid
        uint256 pricePaid; // In DAI, for front end viewing
        uint32 purchasedAt; // When the warrant was purchased in block number/timestamp
        uint32 warrantLotID; // ID of warrant lot
    }

    struct WarrantLot {
        uint256 discount; // discount variable
        uint32 vestingTerm; // in seconds
        uint256 totalCapacity; // Maximum amount of tokens that can be issued
        uint256 consumed; // Amount of tokens that have been issued
        uint256 fee; // as % of warrant payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint256 maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint256 price; // price of a bond in given bond lot
        uint256 startAt; // price of a bond in given bond lot
        bool status;
        uint8 conversionRate;
    }

    mapping(uint256 => WarrantLot) public warrantLots;

    /* ======== INITIALIZATION ======== */

    constructor(
        address _WorldOne,
        address _principle,
        address _treasury,
        address _DAO,
        address _factory
    ) public {
        require(_WorldOne != address(0));
        WorldOne = IERC20(_WorldOne);
        require(_principle != address(0));
        principle = IERC20(_principle);
        require(_treasury != address(0));
        treasury = ITreasury(_treasury);
        require(_DAO != address(0));
        DAO = _DAO;
        require(_factory != address(0));
        dexFactory = IPangolinFactory(_factory);
    }

    /**
     *  @notice initializes warrant lot parameters
     *  @param _discount uint
     *  @param _vestingTerm uint32
     *  @param _totalCapacity uint
     *  @param _fee uint
     *  @param _maxPayout uint
     *  @param _minimumPrice uint
     */

    function initializeWarrantLot(
        uint8 _conversionRate,
        uint256 _discount,
        uint32 _vestingTerm,
        uint256 _totalCapacity,
        uint256 _fee,
        uint256 _maxPayout,
        uint256 _minimumPrice
    ) external onlyOwner {
        require(
            CONVERSION_MIN < _conversionRate,
            "Must Greater then Zero"
        );
        require(
            CONVERSION_MAX >= _conversionRate,
            "Must less then OR Equal to 10"
        );
        require(_discount > 0, "Discount must be greater than 0");
        require(
            _discount <= MAX_ALLOWED_DISCOUNT,
            "Discount must be greater than 0"
        );
        require(
            _vestingTerm >= MIN_VESTING_TERM,
            "Vesting must be longer than 36 hours"
        );
        require(_totalCapacity > 0, "Total capacity must be greater than 0");
        require(_fee <= 10000, "DAO fee cannot exceed payout");
        require(
            _maxPayout <= MAX_PAYOUT_IN_PERCENTAGE,
            "Payout cannot be above 100 percent"
        );
        require(_minimumPrice > 0, "Minimum price must be greater than 0");
        if (warrantLotIndex > 0) {
            require(
                currentWarrantLot().consumed ==
                    currentWarrantLot().totalCapacity,
                "Warrant lot already in progress"
            );
        }
        uint256 _price = getLatestPrice();
        if (_price < _minimumPrice) {
            _price = _minimumPrice;
        }
        WarrantLot memory warrantLot = WarrantLot({
            discount: _discount,
            vestingTerm: _vestingTerm,
            totalCapacity: _totalCapacity.mul(10**WorldOne.decimals()),
            consumed: 0,
            fee: _fee,
            maxPayout: _maxPayout,
            price: _price,
            startAt: block.timestamp,
            status: true,
            conversionRate: _conversionRate
        });
        warrantLots[warrantLotIndex] = warrantLot;
        warrantLotIndex += 1;
        emit InitWarrantLot(warrantLot);
        emit WarrantPriceChanged(warrantPriceInUSD(), warrantPrice());
    }

    /* ======== POLICY FUNCTIONS ======== */

    /* ======== USER FUNCTIONS ======== */

    /**
     *  @notice deposit warrant
     *  @param _amount uint
     *  @param _maxPrice uint
     *  @param _depositor address
     *  @return uint
     */

    function deposit(
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor
    ) external returns (uint256) {
        require(_depositor != address(0), "Invalid address");
        require(msg.sender == _depositor);
        require(warrantLotIndex > 0, "Warrant lot has not been initialized");
        require(
            isPurchasable(),
            "Market price must be greater than warrant lot price"
        );

        uint256 priceInUSD = warrantPriceInUSD(); // Stored in warrant info
        uint256 nativePrice = warrantPrice();
        require(
            _maxPrice >= nativePrice,
            "Slippage limit: more than max price"
        ); // slippage protection

        uint256 value = treasury.convertToken(address(principle), _amount);

        uint256 payout = payoutFor(value); // payout to warranter is computed
        // payout = payout.mul(currentWarrantLot().conversionRate);

        require(payout >= 10_000_000, "Warrant too small"); // must be > 0.01 WorldOne ( underflow protection )
        // require(payout <= maxPayout(), "Warrant too large"); // size protection because there is no slippage
        require(
            currentWarrantLot().consumed.add(payout) <=
                currentWarrantLot().totalCapacity,
            "Exceeding maximum allowed purchase in current warrant lot"
        );


        uint256 fee = payout.mul(currentWarrantLot().fee) / 100_00;

        principle.safeTransferFrom(msg.sender, address(this), _amount);
        principle.approve(address(treasury), 10**WorldOne.decimals());

        treasury.deposit(payout.mul(10**WorldOne.decimals()), address(principle), fee);
        principle.safeTransferFrom(address(this),address(treasury) ,_amount);

        if (fee != 0) {
            // fee is transferred to dao
            WorldOne.safeTransfer(DAO, fee);
        }

        // depositor info is stored
        warrantInfo[_depositor] = Warrant({
            payout: warrantInfo[_depositor].payout.add(payout),
            warrantLotID: uint32(warrantLotIndex - 1),
            purchasedAt: uint32(block.timestamp),
            pricePaid: priceInUSD
        });

        warrantLots[warrantLotIndex - 1] = WarrantLot({
            discount: currentWarrantLot().discount,
            vestingTerm: currentWarrantLot().vestingTerm,
            totalCapacity: currentWarrantLot().totalCapacity,
            consumed: currentWarrantLot().consumed.add(payout),
            fee: currentWarrantLot().fee,
            maxPayout: currentWarrantLot().maxPayout,
            price: currentWarrantLot().price,
            startAt: currentWarrantLot().startAt,
            status: currentWarrantLot().status,
            conversionRate: currentWarrantLot().conversionRate
        });

        emit WarrantCreated(
            _amount,
            payout,
            block.timestamp.add(currentWarrantLot().vestingTerm),
            priceInUSD
        );

        return payout;
    }

    function updateWarrantLot(
        uint256 _warrantLotIndex,
        uint8 _conversionRate,
        uint256 _discount,
        uint256 _price,
        uint256 _totalCapacity,
        uint32 _maxPayout,
        uint32 _vestingTime,
        bool _status
    ) external onlyOwner {
             require(
            CONVERSION_MIN < _conversionRate,
            "Must Greater then Zero"
        );
        require(
            CONVERSION_MAX >= _conversionRate,
            "Must less then OR Equal to 10"
        );
        require(_totalCapacity > 0, "Total capacity must be greater than 0");
        require(_vestingTime > 0, "Vesting must be greater then zero");
        require(
            _maxPayout <= MAX_PAYOUT_IN_PERCENTAGE,
            "Payout cannot be above 100 percent"
        );
        if (warrantLotIndex > 0) {
            require(
                currentWarrantLot().consumed !=
                    currentWarrantLot().totalCapacity,
                "Warrant lot already in progress"
            );
        }


        warrantLots[_warrantLotIndex - 1] = WarrantLot({
            discount: _discount,
            vestingTerm: _vestingTime,
            totalCapacity: _totalCapacity.mul(10**WorldOne.decimals()),
            consumed: currentWarrantLot().consumed,
            fee: currentWarrantLot().fee,
            maxPayout: _maxPayout,
            price: _price,
            startAt: currentWarrantLot().startAt,
            status: _status,
            conversionRate: _conversionRate
        });

    }

    /**
     *  @notice redeem warrant for user
     *  @param _recipient address
     *  @return uint
     */
    function redeem(address _recipient) external returns (uint256) {
        require(msg.sender == _recipient, "NA");
        Warrant memory info = warrantInfo[_recipient];
        require(
            uint32(block.timestamp) >=
                info.purchasedAt.add32(
                    warrantLots[info.warrantLotID].vestingTerm
                ),
            "Cannot redeem before vesting period is over"
        );
        delete warrantInfo[_recipient]; // delete user info
        emit WarrantRedeemed(_recipient, info.payout, 0); // emit warrant data
        return send(_recipient, info.payout); // pay user everything due
    }

    /**
     *  @notice get remaining WorldOne available in current warrant lot. THIS IS FOR TESTING PURPOSES ONLY
     *  @return uint
     */
    function remainingAvailable() public view returns (uint256) {
        return
            currentWarrantLot().totalCapacity.sub(currentWarrantLot().consumed);
    }

    /**
     *  @notice Get cost of all remaining WorldOne tokens.  THIS IS FOR TESTING PURPOSES ONLY
     *  @return uint
     */
    function allCost() public view returns (uint256) {
        return
            remainingAvailable()
                .mul(10**principle.decimals())
                .mul(warrantPrice())
                .div(10**WorldOne.decimals()) / 100;
    }

    /* ======== INTERNAL HELPER FUNCTIONS ======== */

    /**
     *  @notice check if warrant is purchaseable
     *  @return bool
     */

    function isPurchasable() internal view returns (bool) {
        uint256 price = warrantPrice(); // 1100 x
        price = price.mul(10**principle.decimals()) / 100;
        if (price < getMarketPrice()) {
            //1*000000.019970000099699
            return true;
        } else {
            return false;
        }
    }

    /**
     *  @notice get current market price
     *  @return uint
     */
    function getMarketPrice() internal view returns (uint256) {
        IPangolinPair pair = IPangolinPair(
            dexFactory.getPair(address(principle), address(WorldOne))
        );
        IERC20 token1 = IERC20(pair.token1());
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();

        // decimals
        uint256 res0 = Res0 * (10**token1.decimals());
        return (res0 / Res1); // return _amount of token0 needed to buy token1 :: token0 = DAI, token1 = WorldOne
    }

    /**
     *  @notice allow user to send payout
     *  @param _amount uint
     *  @return uint
     */
    function send(address _recipient, uint256 _amount)
        internal
        returns (uint256)
    {
        WorldOne.transfer(_recipient, _amount); // send payout
        return _amount;
    }

    /**
     *  @notice get current warrant lot terms
     *  @return WarrantLot
     */
    function currentWarrantLot() internal view returns (WarrantLot memory) {
        require(warrantLotIndex > 0, "No bond lot has been initialised");
        return warrantLots[warrantLotIndex - 1];
    }

    /* ======== VIEW FUNCTIONS ======== */

    /**
     *  @notice determine maximum warrant size
     *  @return uint
     */
    function maxPayout() public view returns (uint256) {
        return
            currentWarrantLot().totalCapacity.mul(
                currentWarrantLot().maxPayout
            ) / 100000;
    }

    /**
     *  @notice calculate interest due for new warrant
     *  @param _value uint
     *  @return uint
     */
    function payoutFor(uint256 _value) public view returns (uint256) {
        return
            FixedPoint.fraction(_value.mul(currentWarrantLot().conversionRate), warrantPrice()).decode112with18() /
            1e16;
    }

    /**
     *  @notice calculate value of token via token amount
     *  @param _amount uint
     *  @return uint
     */
    function valueCheckOf(uint256 _amount) external view returns (uint256) {
        return
            FixedPoint.fraction(_amount, warrantPrice()).decode112with18() /
            1e16;
    }

    /**
     *  @notice calculate current warrant premium
     *  @return price_ uint
     */
    function warrantPrice() public view returns (uint256 price_) {
        price_ = currentWarrantLot().price;
    }

    function getLatestPrice() public view returns (uint256 price_) {
        uint256 circulatingSupply = WorldOne.totalSupply();
        uint256 treasuryBalance = treasury.getTotalReserves().mul(1e9); //IERC20(principle).balanceOf(address(treasury));
        if (circulatingSupply == 0) {
            // On first warrant sale, there will be no circulating supply
            price_ = 0;
        } else {
            if (warrantLotIndex > 0) {
                price_ = treasuryBalance
                    .div(circulatingSupply)
                    .mul(getYieldFactor())
                    .div(1e11);
            } else {
                price_ = treasuryBalance.div(circulatingSupply).div(1e11);
            }
        }
    }

    function getYieldFactor() public view returns (uint256) {
        return currentWarrantLot().discount.add(1e4); // add extra 100_00 to add 100% to original discount value
    }

    /**
     *  @notice converts warrant price to DAI value
     *  @return price_ uint
     */
    function warrantPriceInUSD() public view returns (uint256 price_) {
        price_ = warrantPrice().mul(10**principle.decimals()) / 100;
    }

    /* ======= AUXILLIARY ======= */
    /**
     *  @notice allow anyone to send lost tokens (excluding principle or WorldOne) to the DAO
     *  @return bool
     */
     
    function recoverLostToken(IERC20 _token) external returns (bool) {
        require(_token != WorldOne, "NAT");
        require(_token != principle, "NAP");
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(DAO, balance);
        emit LogRecoverLostToken(address(_token), balance);
        return true;
    }
}