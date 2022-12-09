// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import "./IERC20.sol";

interface IBentoBoxV1 {

    function strategyData(
        address _token
    ) external view returns (
        uint64 strategyStartDate,
        uint64 targetPercentage,
        uint128 balance
    );

    function toAmount(
        address _token,
        uint256 _share,
        bool _roundUp
    ) external view returns (uint256);

    function withdraw(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256, uint256);

    function deposit(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256, uint256);

    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) external payable returns (address cloneAddress);

    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function balanceOf(IERC20, address) external view returns (uint256);

    function totals(IERC20) external view returns (uint128 elastic, uint128 base);

    function flashLoan(
        address borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;

    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import "./IBentoBoxV1.sol";

interface ICauldron {

    function accrueInfo()
    external
    view
    returns (
        uint64 lastAccrued,
        uint128 feesEarned,
        uint64 INTEREST_PER_SECOND
    );
    
    function LIQUIDATION_MULTIPLIER() external view returns (uint256);

    function BORROW_OPENING_FEE() external view returns (uint256);

    function COLLATERIZATION_RATE() external view returns (uint256);

    function magicInternetMoney() external view returns (IERC20);

    function userCollateralShare(address account) external view returns (uint256);

    function bentoBox() external view returns (IBentoBoxV1);

    function oracle() external view returns (address);

    function oracleData() external view returns (bytes memory);

    function collateral() external view returns (address);

    function totalBorrow() external view returns (uint128 elastic, uint128 base);

    function updateExchangeRate() external returns (bool updated, uint256 rate);

    function addCollateral(
        address to,
        bool skim,
        uint256 share
    ) external;

    function borrow(address to, uint256 amount) external returns (uint256 part, uint256 share);

    function cook(
        uint8[] calldata actions,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external payable returns (uint256 value1, uint256 value2);

    function removeCollateral(address to, uint256 share) external;

    function userBorrowPart(address) external view returns (uint256);

    function liquidate(
        address[] calldata users,
        uint256[] calldata maxBorrowParts,
        address to,
        address swapper
    ) external;

    function liquidate(
        address[] calldata users,
        uint256[] calldata maxBorrowParts,
        address to,
        address swapper,
        bytes calldata swapperData
    ) external;

    function exchangeRate() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice EIP 2612
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface IOracle {
    /// @notice Get the latest exchange rate.
    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    /// @return success if no valid (recent) rate is available, return false else true.
    /// @return rate The rate of the requested asset / pair / pool.
    function get(bytes calldata data) external returns (bool success, uint256 rate);

    /// @notice Check the last exchange rate without any state changes.
    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    /// @return success if no valid (recent) rate is available, return false else true.
    /// @return rate The rate of the requested asset / pair / pool.
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);

    /// @notice Check the current spot exchange rate without any state changes. For oracles like TWAP this will be different from peek().
    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    /// @return rate The rate of the requested asset / pair / pool.
    function peekSpot(bytes calldata data) external view returns (uint256 rate);

    /// @notice Returns a human readable (short) name about this oracle.
    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    /// @return (string) A human readable symbol name about this oracle.
    function symbol(bytes calldata data) external view returns (string memory);

    /// @notice Returns a human readable name about this oracle.
    /// @param data Usually abi encoded, implementation specific data that contains information and arguments to & about the oracle.
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    /// @return (string) A human readable name about this oracle.
    function name(bytes calldata data) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IOracleGetter {

    function getPrice(address) external view returns (uint256);
    function getAllPrice(address[] memory) external view returns (uint256[] memory);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

// inherit
import "../interfaces/ICauldron.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IOracleGetter.sol";


contract UiDataProvider {
    using SafeMath for uint256;

    uint256 public constant SEC_IN_YEAR = 86400 * 365;
    uint256 public constant LTV_PRECISION = 1e5;
    uint256 public constant FEE_PRECISION = 1e5;
    uint256 public constant PADDING = 98;
    IOracleGetter public oracleGetter;

    constructor(address oracleGetter_) public {
        oracleGetter = IOracleGetter(oracleGetter_);
    }

    function getPeek(address[] memory cualdron_) public view returns (
        uint256[] memory peekOracle,
        uint256[] memory peekSpot
    ) {
        peekOracle = new uint256[](cualdron_.length);
        peekSpot = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            IOracle oracle = IOracle(cualdron.oracle());
            (,peekOracle[i]) = oracle.peek(cualdron.oracleData());
            peekSpot[i] = oracle.peekSpot(cualdron.oracleData());
        }
    }

    function getTotalBorrow(address[] memory cualdron_) public view returns (
        uint256[] memory elastic,
        uint256[] memory base
    ) {
        elastic = new uint256[](cualdron_.length);
        base = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            (elastic[i], base[i]) = cualdron.totalBorrow();
        }
    }

    function getPoolInfo(address[] memory cualdron_) public view returns (
        uint256[] memory ltv,
        uint256[] memory liquidityFee,
        uint256[] memory borrowFee
    ) {
        ltv = new uint256[](cualdron_.length);
        liquidityFee = new uint256[](cualdron_.length);
        borrowFee = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            ltv[i] = cualdron.COLLATERIZATION_RATE();
            liquidityFee[i] = cualdron.LIQUIDATION_MULTIPLIER();
            borrowFee[i] = cualdron.BORROW_OPENING_FEE();
        }
    }

    function getInterest(address[] memory cualdron_) public view returns (
        uint256[] memory interest,
        uint256[] memory apy
    ) {
        interest = new uint256[](cualdron_.length);
        apy = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            (,, interest[i]) = cualdron.accrueInfo();
            apy[i] = interest[i].mul(SEC_IN_YEAR).mul(100); 
        }
    }

    function userCollateralWithdraw(address user_, address[] memory cualdron_) public view returns (
        uint256[] memory collateralMax, 
        uint256[] memory collateralMaxInDollar
    ) {
        collateralMax = new uint256[](cualdron_.length);
        collateralMaxInDollar = new uint256[](cualdron_.length);
        uint256 minHF = 102; // 102%
        (uint256[] memory borrowed,,) = userDollarBorrowed(user_, cualdron_);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            uint256 ltv = cualdron.COLLATERIZATION_RATE();
            uint256 price = oracleGetter.getPrice(address(cualdron.collateral()));
            collateralMax[i] = borrowed[i].mul(minHF).mul(LTV_PRECISION).div(100).div(ltv);
            collateralMaxInDollar[i] = (collateralMax[i].mul(price)).div(1e18);
        }
    }

    function userCollateralDeposit(address user_, address[] memory cualdron_) public view returns (
        uint256[] memory collateralShare, 
        uint256[] memory collateralInDollar
    ) {
        collateralShare = new uint256[](cualdron_.length);
        collateralInDollar = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            uint256 price = oracleGetter.getPrice(address(cualdron.collateral()));
            collateralShare[i] = cualdron.userCollateralShare(user_);
            collateralInDollar[i] = (collateralShare[i].mul(price)).div(1e18);
        }
    }

    function userDollarBorrowed(address user_, address[] memory cualdron_) public view returns (
        uint256[] memory borrowedAmount,
        uint256[] memory borrowedLeft,
        uint256[] memory borrowedLeftPad
    ) {
        borrowedAmount = new uint256[](cualdron_.length);
        borrowedLeft = new uint256[](cualdron_.length);
        borrowedLeftPad = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            (uint256 elastic, uint256 base) = cualdron.totalBorrow();
            uint256 borrowShare = cualdron.userBorrowPart(user_);
            if(base > 0){
                borrowedAmount[i] = (borrowShare.mul(elastic)).div(base);
            }else{
                borrowedAmount[i] = 0;
            }
            uint256 userColl = cualdron.userCollateralShare(user_);
            uint256 ltv = cualdron.COLLATERIZATION_RATE();
            IOracle oracle = IOracle(cualdron.oracle());
            (,uint256 peekOracle) = oracle.peek(cualdron.oracleData());
            uint256 peekSpot = oracle.peekSpot(cualdron.oracleData());
            if(peekOracle > peekSpot){
                borrowedLeft[i] = (userColl.mul(ltv).mul(1e18).div(LTV_PRECISION)).div(peekSpot);
            }else{
                borrowedLeft[i] = (userColl.mul(ltv).mul(1e18).div(LTV_PRECISION)).div(peekOracle);
            }
            borrowedLeftPad[i] = borrowedLeft[i].mul(PADDING).div(100);
        } 
    }

    function userCurrentLqPrice(address user_, address[] memory cualdron_) public view returns (
        uint256[] memory lqPrice
    ) {
        lqPrice = new uint256[](cualdron_.length);
       (uint256[] memory borrowed,,) = userDollarBorrowed(user_, cualdron_);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            uint256 collateralShare = cualdron.userCollateralShare(user_);
            uint256 ltv = cualdron.COLLATERIZATION_RATE();
            if(borrowed[i] > 0){
                lqPrice[i] = (borrowed[i].mul(1e18).mul(ltv)).div(collateralShare.mul(LTV_PRECISION));
            }else{
                lqPrice[i] = 0;
            }
        }
    }

    function userHealthFactor(address user_, address[] memory cualdron_) public view returns (
        uint256[] memory hf,
        bool[] memory liquidate
    ) {
        hf = new uint256[](cualdron_.length);
        liquidate = new bool[](cualdron_.length);
        (uint256[] memory borrowed,,) = userDollarBorrowed(user_, cualdron_);
        (,uint256[] memory collateralInDollar) = userCollateralDeposit(user_, cualdron_);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            uint256 ltv = cualdron.COLLATERIZATION_RATE();
            if(borrowed[i] > 0){
                hf[i] = (collateralInDollar[i].mul(ltv).mul(1e18)).div(borrowed[i].mul(LTV_PRECISION));
            }else{
                hf[i] = type(uint256).max;
            }
            liquidate[i] = hf[i] < 1e18 ? true : false;
        }  
    }

    function balanceLeftToBorrow(address[] memory cualdron_) public view returns (
        uint256[] memory remain
    ) {
        remain = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            IBentoBoxV1 bento = IBentoBoxV1(cualdron.bentoBox());
            remain[i] = bento.balanceOf(cualdron.magicInternetMoney(), cualdron_[i]);
        }
    }

    function getTotalValue(address[] memory cualdron_) public view returns (
        uint256[] memory totalDepositedAmount,
        uint256[] memory totalDepositedPrice,
        uint256[] memory totalBorrowed
    ) {
        totalDepositedAmount = new uint256[](cualdron_.length);
        totalDepositedPrice = new uint256[](cualdron_.length);
        totalBorrowed = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            IBentoBoxV1 bento = IBentoBoxV1(cualdron.bentoBox());
            uint256 totalShare = bento.balanceOf(IERC20(cualdron.collateral()), cualdron_[i]);
            totalDepositedAmount[i] = bento.toAmount(cualdron.collateral(), totalShare, true);
            uint256 price = oracleGetter.getPrice(address(cualdron.collateral()));
            totalDepositedPrice[i] = (totalDepositedAmount[i].mul(price)).div(1e18);
            (,totalBorrowed[i]) = cualdron.totalBorrow();
        }
    }

    function getWithdrawableAmount(address[] memory cualdron_) public view returns (
        uint256[] memory totalAmount
    ) {
        totalAmount = new uint256[](cualdron_.length);
        for (uint256 i = 0; i < cualdron_.length; i++) {
            ICauldron cualdron =  ICauldron(cualdron_[i]);
            IBentoBoxV1 bento = IBentoBoxV1(cualdron.bentoBox());
            (uint256 elastic,) = bento.totals(IERC20(cualdron.collateral()));
            (,,uint256 stratBalance) = bento.strategyData(cualdron.collateral());
            totalAmount[i] = elastic.sub(stratBalance);
        }
    }

}