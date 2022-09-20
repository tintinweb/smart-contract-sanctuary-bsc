/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// File: contracts/Common/IERC20.sol

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: MIT"

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/DSMath.sol

pragma solidity >0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

// File: contracts/Common/Ownable.sol

pragma solidity ^0.7.4;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/SafeMath.sol

pragma solidity >=0.5.16;


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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/LeverageToken.sol

pragma solidity ^0.7.4;


contract LeverageTokenERC20 is IERC20 {
    using SafeMath for uint256;

    /* solhint-disable const-name-snakecase */
    string public constant name = "Polars Leverage Liquidity";
    string public constant symbol = "PL";
    uint8 public constant decimals = 18;
    /* solhint-enable const-name-snakecase */
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "UniswapV2: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "UniswapV2: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

// File: contracts/IPendingOrders.sol

pragma solidity ^0.7.4;

interface IPendingOrders {
    function eventStart(uint256 _eventId) external;

    function eventEnd(uint256 _eventId) external;

    function createOrder(
        uint256 _amount,
        bool _isWhite,
        uint256 _eventId
    ) external;

    function cancelOrder(uint256 orderId) external;

    function _eventContractAddress() external view returns (address);

    function _predictionPool() external view returns (address);

    function withdrawCollateral() external returns (uint256);
}

// File: contracts/IEventLifeCycle.sol

pragma solidity ^0.7.4;

// pragma abicoder v2;

interface IEventLifeCycle {
    struct GameEvent {
        /* solhint-disable prettier/prettier */
        uint256 priceChangePart;        // in percent
        uint256 eventStartTimeExpected; // in seconds since 1970
        uint256 eventEndTimeExpected;   // in seconds since 1970
        string blackTeam;
        string whiteTeam;
        string eventType;
        string eventSeries;
        string eventName;
        uint256 eventId;
        /* solhint-enable prettier/prettier */
    }

    function addNewEvent(
        uint256 priceChangePart_,
        uint256 eventStartTimeExpected_,
        uint256 eventEndTimeExpected_,
        string calldata blackTeam_,
        string calldata whiteTeam_,
        string calldata eventType_,
        string calldata eventSeries_,
        string calldata eventName_,
        uint256 eventId_
    ) external;

    function addAndStartEvent(
        uint256 priceChangePart_, // in 0.0001 parts percent of a percent dose
        uint256 eventStartTimeExpected_,
        uint256 eventEndTimeExpected_,
        string calldata blackTeam_,
        string calldata whiteTeam_,
        string calldata eventType_,
        string calldata eventSeries_,
        string calldata eventName_,
        uint256 eventId_
    ) external returns (uint256);

    function startEvent() external returns (uint256);

    function endEvent(int8 _result) external;

    function _ongoingEvent()
        external
        view
        returns (
            uint256 priceChangePart,
            uint256 eventStartTimeExpected,
            uint256 eventEndTimeExpected,
            string calldata blackTeam,
            string calldata whiteTeam,
            string calldata eventType,
            string calldata eventSeries,
            string calldata eventName,
            uint256 gameEventId
        );

    function _usePendingOrders() external view returns (bool);

    function _pendingOrders() external view returns (address);

    function setPendingOrders(
        address pendingOrdersAddress,
        bool usePendingOrders
    ) external;

    function changeGovernanceAddress(address governanceAddress) external;
    // function _queuedEvent() external view;
}

// File: contracts/IPredictionPool.sol

pragma solidity ^0.7.4;

interface IPredictionPool {
    function buyWhite(uint256 maxPrice, uint256 payment) external;

    function buyBlack(uint256 maxPrice, uint256 payment) external;

    function sellWhite(uint256 tokensAmount, uint256 minPrice) external;

    function sellBlack(uint256 tokensAmount, uint256 minPrice) external;

    function changeGovernanceAddress(address governanceAddress) external;

    function _whitePrice() external returns (uint256);

    function _blackPrice() external returns (uint256);

    function _whiteBought() external returns (uint256);

    function _blackBought() external returns (uint256);

    function _whiteToken() external returns (address);

    function _blackToken() external returns (address);

    function _thisCollateralization() external returns (address);

    function _eventStarted() external view returns (bool);

    // solhint-disable-next-line func-name-mixedcase
    function FEE() external returns (uint256);

    function init(
        address governanceWalletAddress,
        address eventContractAddress,
        address controllerWalletAddress,
        address ordererAddress,
        bool onlyOrderer
    ) external;

    function changeFees(
        uint256 fee,
        uint256 governanceFee,
        uint256 controllerFee,
        uint256 bwAdditionFee
    ) external;

    function changeOrderer(address newOrderer) external;

    function setOnlyOrderer(bool only) external;
}

// File: contracts/Leverage.sol

pragma solidity ^0.7.4;







contract Leverage is DSMath, Ownable, LeverageTokenERC20 {
    IERC20 public _collateralToken;
    IPendingOrders public _pendingOrders;
    IEventLifeCycle public _eventLifeCycle;
    IPredictionPool public _predictionPool;

    uint256 public _maxUsageThreshold = 0.8 * 1e18; // Default 80%
    uint256 public _maxLossThreshold = 0.5 * 1e18; // Default 50%

    uint256 public _lpTokens = 0; // in 1e18
    uint256 public _collateralTokens = 0; // in 1e18
    uint256 public _borrowedCollateral = 0; // in 1e18

    uint256 public _predictionPoolFee = 0;

    uint256 public _leverageFee = 0.001 * 1e18; // Default 0.1%

    bool public _onlyCurrentEvent = true;

    uint256 public _priceChangePart = 0.05 * 1e18; // Default 0.05%

    struct Order {
        /* solhint-disable prettier/prettier */
        address orderer;        // address of user placing order
        uint256 cross;          // multiplicator
        uint256 ownAmount;      // amount of user`s collateral tokens
        uint256 borrowedAmount; // amount of given collateral tokens
        bool isWhite;           // TRUE for white side, FALSE for black side
        uint256 eventId;        // order target eventId
        bool isPending;        // TRUE when placed, FALSE when canceled
        /* solhint-enable prettier/prettier */
    }

    uint256 public _ordersCounter = 0;

    // mapping from order ID to Cross Order detail
    mapping(uint256 => Order) public _orders;

    // mapping from user address to order IDs for that user
    mapping(address => uint256[]) public _ordersOfUser;

    struct LeverageEvent {
        /* solhint-disable prettier/prettier */
        uint256 eventId;
        uint256 whitePriceBefore;       // price of white token before the event
        uint256 blackPriceBefore;       // price of black token before the event
        uint256 whitePriceAfter;        // price of white token after the event
        uint256 blackPriceAfter;        // price of black token after the event
        uint256 blackCollateral;        // total amount of collateral for black side of the event
        uint256 whiteCollateral;        // total amount of collateral for white side of the event
        bool isExecuted;                // FALSE before the event, TRUE after the event start
        bool isStarted;                 // FALSE before the event, TRUE after the event end
        uint256 totalBorrowed;             // total borrowed amount of collateral of the event
        /* solhint-enable prettier/prettier */
    }

    mapping(uint256 => LeverageEvent) public _events;

    // Modifier to ensure call has been made by event contract
    modifier onlyEventContract() {
        require(
            msg.sender == address(_eventLifeCycle),
            "CALLER SHOULD BE EVENT CONTRACT"
        );
        _;
    }

    event OrderCreated(
        address user,
        uint256 maxLoss,
        uint256 priceChangePart,
        uint256 cross,
        uint256 ownAmount,
        uint256 orderAmount,
        bool isWhite,
        uint256 eventId
    );
    event OrderCanceled(uint256 id, address user);
    event AddLiquidity(
        address user,
        uint256 lpAmount,
        uint256 colaterallAmount
    );
    event WithdrawLiquidity(
        address user,
        uint256 lpAmount,
        uint256 colaterallAmount
    );
    event CollateralWithdrew(uint256 amount, address user, address caller);

    constructor(address collateralTokenAddress, address pendingOrdersAddress) {
        require(
            collateralTokenAddress != address(0),
            "Collateral token address should not be null"
        );
        require(
            pendingOrdersAddress != address(0),
            "PendingOrders address should not be null"
        );

        _collateralToken = IERC20(collateralTokenAddress);
        _pendingOrders = IPendingOrders(pendingOrdersAddress);
        _eventLifeCycle = IEventLifeCycle(
            _pendingOrders._eventContractAddress()
        );
        _predictionPool = IPredictionPool(_pendingOrders._predictionPool());

        _predictionPoolFee = _predictionPool.FEE();

        _collateralToken.approve(address(_pendingOrders), type(uint256).max);
    }

    function ordersOfUser(address user)
        external
        view
        returns (uint256[] memory)
    {
        return _ordersOfUser[user];
    }

    function getOngoingEvent() public view returns (uint256, uint256) {
        /* solhint-disable prettier/prettier */
        (
            uint256 priceChangePart,
            , // uint256 eventStartTimeExpected
            , // uint256 eventEndTimeExpected
            , // string blackTeam
            , // string whiteTeam
            , // string eventType
            , // string eventSeries
            , // string eventName
            uint256 gameEventId
        ) = _eventLifeCycle._ongoingEvent();
        /* solhint-enable prettier/prettier */
        return (priceChangePart, gameEventId);
    }

    function isPendingEnabled() public view returns (bool) {
        return (_eventLifeCycle._usePendingOrders() &&
            _eventLifeCycle._pendingOrders() == address(_pendingOrders));
    }

    function allowedBorrowTotal() public view returns (uint256) {
        return wmul(_collateralTokens, _maxUsageThreshold);
    }

    function allowedBorrowLeft() public view returns (uint256) {
        return sub(allowedBorrowTotal(), _borrowedCollateral);
    }

    function createOrder(
        uint256 amount,
        bool isWhite,
        uint256 maxLoss,
        uint256 eventId
    ) external {
        require(maxLoss != 0, "MAX LOSS PERCENT CANNOT BE 0");
        require(maxLoss <= _maxLossThreshold, "MAX LOSS PERCENT IS VERY BIG");

        require(
            _collateralToken.balanceOf(msg.sender) >= amount,
            "NOT ENOUGH COLLATERAL IN USER ACCOUNT"
        );
        require(
            _collateralToken.allowance(msg.sender, address(this)) >= amount,
            "NOT ENOUGHT DELEGATED TOKENS"
        );

        uint256 cross = wdiv(maxLoss, _priceChangePart);
        uint256 orderAmount = wmul(amount, cross);

        uint256 userBorrowAmount = sub(orderAmount, amount);

        uint256 threshold = allowedBorrowLeft();

        require(
            userBorrowAmount <= threshold,
            "NOT ENOUGH COLLATERAL BALANCE FOR BORROW"
        );

        /* solhint-disable prettier/prettier */
        _orders[_ordersCounter] = Order(
            msg.sender,         // address orderer
            cross,              // uint256 cross
            amount,             // uint256 ownAmount
            userBorrowAmount,   // uint256 borrowedAmount
            isWhite,            // bool    isWhite
            eventId,            // uint256 eventId
            true
        );
        /* solhint-enable prettier/prettier */

        _events[eventId].eventId = eventId;
        _events[eventId].totalBorrowed = add(
            _events[eventId].totalBorrowed,
            userBorrowAmount
        );

        _ordersOfUser[msg.sender].push(_ordersCounter);

        _ordersCounter = add(_ordersCounter, 1);

        _borrowedCollateral = add(_borrowedCollateral, userBorrowAmount);

        /* solhint-disable prettier/prettier */
        isWhite
            ? _events[eventId].whiteCollateral = add(_events[eventId].whiteCollateral, orderAmount)
            : _events[eventId].blackCollateral = add(_events[eventId].blackCollateral, orderAmount);
        /* solhint-enable prettier/prettier */

        _collateralToken.transferFrom(msg.sender, address(this), amount);
        emit OrderCreated(
            msg.sender,
            maxLoss,
            _priceChangePart,
            cross,
            amount,
            orderAmount,
            isWhite,
            eventId
        );
    }

    function cancelOrder(uint256 orderId) external {
        Order memory order = _orders[orderId];
        require(msg.sender == order.orderer, "NOT YOUR ORDER");

        require(order.isPending, "ORDER HAS ALREADY BEEN CANCELED");

        LeverageEvent memory eventById = _events[order.eventId];

        require(!eventById.isExecuted, "EVENT ALREADY ENDED");

        require(!eventById.isStarted, "EVENT IN PROGRESS");

        uint256 totalAmount = add(order.ownAmount, order.borrowedAmount);

        /* solhint-disable prettier/prettier */
        order.isWhite
            ? _events[order.eventId].whiteCollateral = sub(eventById.whiteCollateral, totalAmount)
            : _events[order.eventId].blackCollateral = sub(eventById.blackCollateral, totalAmount);

        _borrowedCollateral = sub(_borrowedCollateral, _orders[orderId].borrowedAmount);

        _events[order.eventId].totalBorrowed = sub(
            eventById.totalBorrowed,
            order.borrowedAmount
        );
        /* solhint-enable prettier/prettier */

        _orders[orderId].isPending = false;

        _collateralToken.transfer(order.orderer, order.ownAmount);
        emit OrderCanceled(orderId, msg.sender);
    }

    function withdrawCollateral(address user) external returns (uint256) {
        require(_ordersOfUser[user].length > 0, "ACCOUNT HAS NO ORDERS");

        // total amount of collateral token that should be returned to user
        // feeAmount should be subtracted before actual return
        uint256 totalWithdrawAmount = 0;

        uint256 i = 0;
        while (i < _ordersOfUser[user].length) {
            uint256 _oId = _ordersOfUser[user][i]; // order ID
            Order memory order = _orders[_oId];
            uint256 _eId = order.eventId; // event ID
            LeverageEvent memory eventDetail = _events[_eId];

            // calculate and sum up collaterals to be returned
            // exclude canceled orders, only include executed orders
            if (order.isPending && eventDetail.isExecuted) {
                uint256 withdrawAmount = 0;
                uint256 priceAfter = 0;
                uint256 priceBefore = 0;

                uint256 orderAmount = add(
                    order.ownAmount,
                    order.borrowedAmount
                );

                if (order.isWhite) {
                    priceBefore = eventDetail.whitePriceBefore;
                    priceAfter = eventDetail.whitePriceAfter;
                } else {
                    priceBefore = eventDetail.blackPriceBefore;
                    priceAfter = eventDetail.blackPriceAfter;
                }

                withdrawAmount = sub(
                    orderAmount,
                    wmul(orderAmount, _predictionPoolFee)
                );
                withdrawAmount = wdiv(withdrawAmount, priceBefore);
                withdrawAmount = wmul(withdrawAmount, priceAfter);
                withdrawAmount = sub(
                    withdrawAmount,
                    wmul(withdrawAmount, _predictionPoolFee)
                );
                withdrawAmount = sub(withdrawAmount, order.borrowedAmount);
                totalWithdrawAmount = add(totalWithdrawAmount, withdrawAmount);
            }

            // pop IDs of canceled or executed orders from ordersOfUser array
            if (!_orders[_oId].isPending || eventDetail.isExecuted) {
                delete _ordersOfUser[user][i];
                _ordersOfUser[user][i] = _ordersOfUser[user][
                    _ordersOfUser[user].length - 1
                ];
                _ordersOfUser[user].pop();

                delete _orders[_oId];
            } else {
                i++;
            }
        }
        _collateralToken.transfer(user, totalWithdrawAmount);

        emit CollateralWithdrew(totalWithdrawAmount, user, msg.sender);

        return totalWithdrawAmount;
    }

    function eventStart(uint256 eventId) external onlyEventContract {
        LeverageEvent memory eventById = _events[eventId];

        eventById.whitePriceBefore = _predictionPool._whitePrice();
        eventById.blackPriceBefore = _predictionPool._blackPrice();

        (uint256 priceChangePart, ) = getOngoingEvent();

        require(isPendingEnabled(), "PENDING ORDERS DISABLED");

        require(priceChangePart == _priceChangePart, "WRONG PRICE CHANGE PART");

        eventById.isStarted = true;

        if (eventById.whiteCollateral > 0) {
            _pendingOrders.createOrder(
                eventById.whiteCollateral,
                true,
                eventId
            );
        }
        if (eventById.blackCollateral > 0) {
            _pendingOrders.createOrder(
                eventById.blackCollateral,
                false,
                eventId
            );
        }
        _events[eventId] = eventById;
    }

    function eventEnd(uint256 eventId) external onlyEventContract {
        LeverageEvent memory nowEvent = _events[eventId];

        nowEvent.whitePriceAfter = _predictionPool._whitePrice();
        nowEvent.blackPriceAfter = _predictionPool._blackPrice();

        nowEvent.isExecuted = true;

        if ((nowEvent.whiteCollateral > 0) || (nowEvent.blackCollateral > 0)) {
            _pendingOrders.withdrawCollateral();
        }

        _borrowedCollateral = sub(_borrowedCollateral, nowEvent.totalBorrowed);

        uint256 fee = wmul(nowEvent.totalBorrowed, _leverageFee);
        _collateralTokens = add(_collateralTokens, fee);

        _events[eventId] = nowEvent;
    }

    function getLpRatio() public view returns (uint256) {
        if ((_collateralTokens == _lpTokens) || (_lpTokens == 0)) {
            return 1e18;
        }
        return wdiv(_collateralTokens, _lpTokens);
    }

    function updateBalances(uint256 collateralAmount, uint256 lpAmount)
        public
        onlyOwner
    {
        _collateralTokens = add(_collateralTokens, collateralAmount);
        _lpTokens = add(_lpTokens, lpAmount);
    }

    function addLiquidity(uint256 tokensAmount) public {
        require(tokensAmount > 0, "TOKENS AMOUNT CANNOT BE 0");
        require(
            _collateralToken.allowance(msg.sender, address(this)) >=
                tokensAmount,
            "NOT ENOUGH COLLATERAL TOKENS ARE DELEGATED"
        );
        require(
            _collateralToken.balanceOf(msg.sender) >= tokensAmount,
            "NOT ENOUGH COLLATERAL TOKENS ON THE USER BALANCE"
        );

        uint256 lpRatio = getLpRatio();
        uint256 lpAmount = wdiv(tokensAmount, lpRatio);

        _collateralTokens = add(_collateralTokens, tokensAmount);
        _lpTokens = add(_lpTokens, lpAmount);

        _mint(msg.sender, lpAmount);

        emit AddLiquidity(msg.sender, lpAmount, tokensAmount);

        _collateralToken.transferFrom(msg.sender, address(this), tokensAmount);
    }

    function withdrawLiquidity(uint256 lpTokensAmount) public {
        require(
            balanceOf[msg.sender] >= lpTokensAmount,
            "NOT ENOUGH LIQUIDITY TOKENS ON THE USER BALANCE"
        );
        require(
            allowance[msg.sender][address(this)] >= lpTokensAmount,
            "NOT ENOUGH LIQUIDITY TOKENS ARE DELEGATED"
        );

        uint256 lpRatio = getLpRatio();
        uint256 collateralToSend = wmul(lpTokensAmount, lpRatio);

        require(
            _collateralToken.balanceOf(address(this)) >= collateralToSend,
            "NOT ENOUGH COLLATERAL IN THE CONTRACT"
        );

        _collateralTokens = sub(_collateralTokens, collateralToSend);
        _lpTokens = sub(_lpTokens, lpTokensAmount);

        _burn(msg.sender, lpTokensAmount);

        emit WithdrawLiquidity(msg.sender, lpTokensAmount, collateralToSend);

        _collateralToken.transfer(msg.sender, collateralToSend);
    }

    function changeMaxUsageThreshold(uint256 percent) external onlyOwner {
        require(
            percent >= 0.1 * 1e18,
            "NEW MAX USAGE THRESHOLD SHOULD BE MORE THAN 10%"
        );
        _maxUsageThreshold = percent;
    }

    function changeMaxLossThreshold(uint256 percent) external onlyOwner {
        require(
            percent <= 0.5 * 1e18,
            "NEW MAX LOSS THRESHOLD SHOULD BE LESS THAN 50%"
        );
        _maxLossThreshold = percent;
    }

    function changePriceChangePart(uint256 priceChangePart) external onlyOwner {
        _priceChangePart = priceChangePart;
    }

    function changeLeverageFee(uint256 leverageFee) external onlyOwner {
        _leverageFee = leverageFee;
    }

    function updatePredictionPoolFee() external onlyOwner {
        _predictionPoolFee = _predictionPool.FEE();
    }

    function emergencyWithdrawCollateral() public onlyOwner {
        uint256 balance = _collateralToken.balanceOf(address(this));
        require(
            _collateralToken.transfer(msg.sender, balance),
            "Unable to transfer"
        );
    }
}