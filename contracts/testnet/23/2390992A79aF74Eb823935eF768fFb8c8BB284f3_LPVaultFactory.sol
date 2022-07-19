// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../LPVault.sol";

contract LPVaultFactory is Ownable {
    address public controller;
    string public lpName;
    IERC20 public lpToken;

    event ControllerAdded(address _controller);

    modifier onlyController() {
        require(msg.sender == controller, "Only controller can called");
        _;
    }

    function addController(address _controller) external onlyOwner {
        require(_controller != address(0));
        controller = _controller;

        emit ControllerAdded(_controller);
    }

    function createLPVault(address _lpToken, string calldata _lpName, address _oracle)
        external
        onlyController
        returns (address)
    {
        LPVault vault = new LPVault(_lpToken, _lpName, controller, _oracle);
        return address(vault);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library HomoraMath {

  function divCeil(uint lhs, uint rhs) internal pure returns (uint) {
    return (lhs + rhs) - 1 / rhs;
  }

  function fmul(uint lhs, uint rhs) internal pure returns (uint) {
    return (lhs * rhs) / (2**112);
  }

  function fdiv(uint lhs, uint rhs) internal pure returns (uint) {
    return (lhs * (2**112)) / rhs;
  }

  // implementation from https://github.com/Uniswap/uniswap-lib/commit/99f3f28770640ba1bb1ff460ac7c5292fb8291a0
  // original implementation: https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
  function sqrt(uint x) internal pure returns (uint) {
    if (x == 0) return 0;
    uint xx = x;
    uint r = 1;

    if (xx >= 0x100000000000000000000000000000000) {
      xx >>= 128;
      r <<= 64;
    }

    if (xx >= 0x10000000000000000) {
      xx >>= 64;
      r <<= 32;
    }
    if (xx >= 0x100000000) {
      xx >>= 32;
      r <<= 16;
    }
    if (xx >= 0x10000) {
      xx >>= 16;
      r <<= 8;
    }
    if (xx >= 0x100) {
      xx >>= 8;
      r <<= 4;
    }
    if (xx >= 0x10) {
      xx >>= 4;
      r <<= 2;
    }
    if (xx >= 0x8) {
      r <<= 1;
    }

    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1; // Seven iterations should be enough
    uint r1 = x / r;
    return (r < r1 ? r : r1);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/HomoraMath.sol";

interface IPancakePair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
}

interface IPancakeRouter {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract UniswapV2Oracle is Ownable{
    IPancakeRouter uniswap;
    address constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // WBNB
    address constant USDT = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD

    constructor(address _uniswapRouter) {
        uniswap = IPancakeRouter(_uniswapRouter);
    }

    // Reference : https://blog.alphaventuredao.io/fair-lp-token-pricing/
    function getLPPrice(address _lpToken) external view returns (uint256) {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();
        uint256 totalSupply = IPancakePair(_lpToken).totalSupply();
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(_lpToken).getReserves();
        uint256 sqrtK = HomoraMath.fdiv(HomoraMath.sqrt(reserve0 * reserve1),totalSupply);
        uint256 priceETH0;
        uint256 priceETH1;
        if (token0 != WETH) {
            priceETH0 = serializeGetAmountsOut(1 ether, token0, WETH);
        }
        else {
            priceETH0 = 1 ether;
        }
        if (token1 != WETH) {
            priceETH1 = serializeGetAmountsOut(1 ether, token1, WETH);
        }
        else {
            priceETH1 = 1 ether;
        }
        uint256 priceUSDT0 = serializeGetAmountsOut(priceETH0, WETH, USDT);
        uint256 priceUSDT1 = serializeGetAmountsOut(priceETH1, WETH, USDT);
        return 2 * sqrtK * (HomoraMath.sqrt(priceUSDT0)) / (2**56) * (HomoraMath.sqrt(priceUSDT1)) / (2**56);
    }

    function getTokenPrice(address _Token) external view returns (uint256) {
        if(_Token != USDT) {
            return serializeGetAmountsOut(1 ether, _Token, USDT);
        }
        else {
            return 1 ether;
        }
    }

    function getTokenPricewithAmount(address _Token, uint256 _amount) external view returns (uint256) {
        if(_Token != USDT) {
            return serializeGetAmountsOut(_amount, _Token, USDT);
        }
        else {
            return _amount;
        }
    }

    function serializeGetAmountsOut(uint256 _amount, address _tokenIn, address _tokenOut) public view returns (uint256) {
        address[] memory addressArray = new address[](2);
        addressArray[0] = _tokenIn;
        addressArray[1] = _tokenOut;

        return uniswap.getAmountsOut(_amount, addressArray)[1];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LocalOracle is Ownable {
    address[] public LPaddress;
    address public SCaddress;

    mapping(address => uint256) public lpPrice;
    uint256 public scPrice;

    constructor(address[] memory lpAddress, address scAddress) {
        require(lpAddress.length == 3);
        require(scAddress != address(0));
        LPaddress = lpAddress;
        SCaddress = scAddress;

        lpPrice[LPaddress[0]] = 1e18;
        lpPrice[LPaddress[1]] = 2e18;
        lpPrice[LPaddress[2]] = 3e18;

        scPrice = 1e18;
    }

    function getLPPrice(address _lpToken) public view returns (uint256) {
        return lpPrice[_lpToken];
    }

    function getTokenPrice(address _Token) external view returns (uint256) {
        if (_Token == SCaddress) {
            return scPrice;
        } else {
            return getLPPrice(_Token);
        }
    }

    function getTokenPricewithAmount(address _Token, uint256 _amount)
        external
        view
        returns (uint256)
    {
        if (_Token == SCaddress) {
            return _amount;
        } else {
            return (getLPPrice(_Token) * _amount) / 1e18;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SCVaultI {
    function viewVaultName() external view returns (string memory);

    function viewVaultAsset() external view returns (address);

    function viewCashPrior() external view returns (uint256);

    function accrueInterest() external;

    function borrowBalancePrior(address _account) external view returns (uint256);

    function borrowBalanceCurrent(address _account) external returns (uint256);

    function viewTotalBorrow() external view returns (uint256);

    function _borrow(address _account, uint256 _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LPVaultI {
    function provideCollateral(uint256 _amount) external returns (bool);

    function withdrawCollateral(uint256 _amount) external returns (bool);

    function liquidateAccount(address _account, address _liquidator) external returns (bool);

    function viewCollateralAmountByAccount(address _account)
        external
        view
        returns (uint256);

    function viewTotalCollateral() external view returns (uint256);

    function viewVaultName() external view returns (string memory);

    function viewVaultAsset() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../SCVault.sol";

contract SCVaultFactory is Ownable {
    address public controller;
    string public scName;
    IERC20 public scToken;

    event ControllerAdded(address _controller);

    modifier onlyController() {
        require(msg.sender == controller, "Only controller can called");
        _;
    }

    function addController(address _controller) external onlyOwner {
        require(_controller != address(0));
        controller = _controller;

        emit ControllerAdded(_controller);
    }

    function createSCVault(
        address _scToken,
        string calldata _scName,
        address _oracle,
        address _interestRate,
        uint256 _reserveFactorMantissa
    ) external onlyController returns (address) {
        SCVault vault = new SCVault(
            _scToken,
            _scName,
            controller,
            _oracle,
            _interestRate,
            _reserveFactorMantissa
        );
        return address(vault);
    }
}

// SPDX-License-Identifier: BSD 3-Clause
pragma solidity ^0.8.0;

import "./BaseJumpRateModelV2.sol";

/**
 * @title Compound's JumpRateModel Contract V2 for V2 cTokens
 * @author Arr00
 * @notice Supports only for V2 cTokens
 */
contract JumpRateModelV2 is BaseJumpRateModelV2 {
    /**
     * @notice Calculates the current borrow rate per block
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @return The borrow rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256) {
        return getBorrowRateInternal(cash, borrows, reserves);
    }

    constructor(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_,
        address owner_
    )
        BaseJumpRateModelV2(
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_,
            owner_
        )
    {}
}

// SPDX-License-Identifier: BSD 3-Clause
pragma solidity ^0.8.0;

/**
 * @title Compound's InterestRateModel Interface
 * @author Compound
 */
abstract contract InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    bool public constant isInterestRateModel = true;

    /**
     * @notice Calculates the current borrow interest rate per block
     * @param cash The total amount of cash the market has
     * @param borrows The total amount of borrows the market has outstanding
     * @param reserves The total amount of reserves the market has
     * @return The borrow rate per block (as a percentage, and scaled by 1e18)
     */
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view virtual returns (uint256);

    /**
     * @notice Calculates the current supply interest rate per block
     * @param cash The total amount of cash the market has
     * @param borrows The total amount of borrows the market has outstanding
     * @param reserves The total amount of reserves the market has
     * @param reserveFactorMantissa The current reserve factor the market has
     * @return The supply rate per block (as a percentage, and scaled by 1e18)
     */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view virtual returns (uint256);
}

// SPDX-License-Identifier: BSD 3-Clause
pragma solidity ^0.8.0;

/**
 * @title Logic for Compound's JumpRateModel Contract V2.
 * @author Compound (modified by Dharma Labs, refactored by Arr00)
 * @notice Version 2 modifies Version 1 by enabling updateable parameters.
 */
abstract contract BaseJumpRateModelV2 {
    event NewInterestParams(
        uint256 baseRatePerBlock,
        uint256 multiplierPerBlock,
        uint256 jumpMultiplierPerBlock,
        uint256 kink
    );

    /**
     * @notice The address of the owner, i.e. the Timelock contract, which can update parameters directly
     */
    address public owner;

    /**
     * @notice The approximate number of blocks per year that is assumed by the interest rate model
     */
    uint256 public constant blocksPerYear = 2102400;

    /**
     * @notice The multiplier of utilization rate that gives the slope of the interest rate
     */
    uint256 public multiplierPerBlock;

    /**
     * @notice The base interest rate which is the y-intercept when utilization rate is 0
     */
    uint256 public baseRatePerBlock;

    /**
     * @notice The multiplierPerBlock after hitting a specified utilization point
     */
    uint256 public jumpMultiplierPerBlock;

    /**
     * @notice The utilization point at which the jump multiplier is applied
     */
    uint256 public kink;

    /**
     * @notice Construct an interest rate model
     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)
     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)
     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point
     * @param kink_ The utilization point at which the jump multiplier is applied
     * @param owner_ The address of the owner, i.e. the Timelock contract (which has the ability to update parameters directly)
     */
    constructor(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_,
        address owner_
    ) {
        owner = owner_;

        updateJumpRateModelInternal(
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_
        );
    }

    /**
     * @notice Update the parameters of the interest rate model (only callable by owner, i.e. Timelock)
     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)
     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)
     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point
     * @param kink_ The utilization point at which the jump multiplier is applied
     */
    function updateJumpRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_
    ) external {
        require(msg.sender == owner, "only the owner may call this function.");

        updateJumpRateModelInternal(
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_
        );
    }

    /**
     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows - reserves)`
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market (currently unused)
     * @return The utilization rate as a mantissa between [0, 1e18]
     */
    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public pure returns (uint256) {
        // Utilization rate is 0 when there are no borrows
        if (borrows == 0) {
            return 0;
        }

        return (borrows * (1e18)) / (cash + borrows - reserves);
    }

    /**
     * @notice Calculates the current borrow rate per block, with the error code expected by the market
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @return The borrow rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getBorrowRateInternal(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) internal view returns (uint256) {
        uint256 util = utilizationRate(cash, borrows, reserves);

        if (util <= kink) {
            return ((util * multiplierPerBlock) / 1e18) + baseRatePerBlock;
        } else {
            uint256 normalRate = ((kink * multiplierPerBlock) / 1e18) +
                baseRatePerBlock;
            uint256 excessUtil = util - kink;
            return ((excessUtil * jumpMultiplierPerBlock) / 1e18) + normalRate;
        }
    }

    /**
     * @notice Calculates the current supply rate per block
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @param reserveFactorMantissa The current reserve factor for the market
     * @return The supply rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) public view returns (uint256) {
        uint256 oneMinusReserveFactor = uint256(1e18) - reserveFactorMantissa;
        uint256 borrowRate = getBorrowRateInternal(cash, borrows, reserves);
        uint256 rateToPool = (borrowRate * oneMinusReserveFactor) / 1e18;
        return (utilizationRate(cash, borrows, reserves) * rateToPool) / 1e18;
    }

    /**
     * @notice Internal function to update the parameters of the interest rate model
     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by 1e18)
     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by 1e18)
     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point
     * @param kink_ The utilization point at which the jump multiplier is applied
     */
    function updateJumpRateModelInternal(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_
    ) internal {
        baseRatePerBlock = baseRatePerYear / blocksPerYear;
        multiplierPerBlock =
            (multiplierPerYear * 1e18) /
            (blocksPerYear * kink_);
        jumpMultiplierPerBlock = jumpMultiplierPerYear / blocksPerYear;
        kink = kink_;

        emit NewInterestParams(
            baseRatePerBlock,
            multiplierPerBlock,
            jumpMultiplierPerBlock,
            kink
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./oracle/UniswapV2Oracle.sol";
import "./oracle/LocalOracle.sol"; // Test on local and testnet only

import "./factory/LPVaultFactory.sol";
import "./factory/SCVaultFactory.sol";

import "./interface/LPVaultI.sol";
import "./interface/SCVaultI.sol";
import "./compound/JumpRateModelV2.sol";

contract TriflePrototype2 is Ownable {
    UniswapV2Oracle public oracle;
    LocalOracle public localOracle;
    LPVaultFactory public lpVaultFactory;
    SCVaultFactory public scVaultFactory;

    address[] public lpVaults;
    address[] public scVaults;

    mapping(address => address) public getAssetByVault;
    mapping(address => address) public getVaultInstanceByToken;

    event LPVaultCreated(
        string indexed _lpName,
        address _lpVault,
        address _lpToken
    );
    event LPVaultImported(
        string indexed _lpName,
        address _lpVault,
        address _lpToken
    );
    event SCVaultCreated(
        string indexed _scName,
        address _scVault,
        address _scToken,
        address _interestRateModel
    );
    event SCVaultImported(
        string indexed _scName,
        address _scVault,
        address _scToken
    );
    event NewBorrowed(
        address indexed _account,
        address _scToken,
        uint256 _amount
    );

    constructor(
        address _oracle,
        address _lpVaultFactory,
        address _scVaultFactory
    ) {
        // oracle = UniswapV2Oracle(_oracle);
        localOracle = LocalOracle(_oracle);
        lpVaultFactory = LPVaultFactory(_lpVaultFactory);
        scVaultFactory = SCVaultFactory(_scVaultFactory);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    //                                      Factory Function                                  //
    ////////////////////////////////////////////////////////////////////////////////////////////
    function createLPVault(
        address _lpToken,
        string calldata _lpName,
        address _oracle
    ) external onlyOwner {
        address newLPVaultAddress = lpVaultFactory.createLPVault(
            _lpToken,
            _lpName,
            _oracle
        );
        lpVaults.push(newLPVaultAddress);
        getVaultInstanceByToken[_lpToken] = newLPVaultAddress;
        getAssetByVault[newLPVaultAddress] = _lpToken;

        emit LPVaultCreated(_lpName, newLPVaultAddress, _lpToken);
    }

    function importLPVault(address _lpToken, address _lpVault)
        external
        onlyOwner
    {
        LPVaultI lpVaultInstance = LPVaultI(_lpVault);
        string memory lpName = lpVaultInstance.viewVaultName();
        address lpToken = lpVaultInstance.viewVaultAsset();
        require(
            lpToken == _lpToken,
            "LP Vault Asset isn't the same as input LP Token address"
        );
        lpVaults.push(_lpVault);
        getVaultInstanceByToken[lpToken] = _lpVault;
        getAssetByVault[_lpVault] = lpToken;

        emit LPVaultImported(lpName, _lpVault, lpToken);
    }

    function createSCVault(
        address _scToken,
        string calldata _scName,
        address _oracle,
        uint256 _reserveFactorMantissa,
        uint256 _baseRatePerYear,
        uint256 _multiplierPerYear,
        uint256 _jumpMultiplierPerYear,
        uint256 _optimal
    ) external onlyOwner {
        //create the interest rate model for this stablecoin
        address IR = address(
            new JumpRateModelV2(
                _baseRatePerYear,
                _multiplierPerYear,
                _jumpMultiplierPerYear,
                _optimal,
                address(this)
            )
        );

        address newSCVaultAddress = scVaultFactory.createSCVault(
            _scToken,
            _scName,
            _oracle,
            IR,
            _reserveFactorMantissa
        );

        scVaults.push(newSCVaultAddress);
        getVaultInstanceByToken[_scToken] = newSCVaultAddress;
        getAssetByVault[newSCVaultAddress] = _scToken;

        emit SCVaultCreated(_scName, newSCVaultAddress, _scToken, IR);
    }

    function importSCVault(address _scToken, address _scVault)
        external
        onlyOwner
    {
        SCVaultI scVaultInstance = SCVaultI(_scVault);
        string memory scName = scVaultInstance.viewVaultName();
        address scToken = scVaultInstance.viewVaultAsset();
        require(
            scToken == _scToken,
            "SC Vault Asset isn't the same as input SC Token address"
        );
        scVaults.push(_scVault);
        getVaultInstanceByToken[scToken] = _scVault;
        getAssetByVault[_scVault] = scToken;

        emit LPVaultImported(scName, _scVault, scToken);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    //                                Borrower & Lender Function                              //
    ////////////////////////////////////////////////////////////////////////////////////////////
    function getMaxWithdrawAllowed(address _account, address _lpToken)
        public
        returns (uint256)
    {
        uint256 totalBorrowed = getTotalBorrowedValue(_account);
        uint256 totalCollateral = getTotalAvailableCollateralValue(_account);
        uint256 requiredCollateral = calcBorrowedCollateral(totalBorrowed);
        if (requiredCollateral > totalCollateral) {
            return 0;
        }
        uint256 remainCollateral = totalCollateral - requiredCollateral;
        // uint256 lpPrice = oracle.getLPPrice(_lpToken);
        uint256 lpPrice = localOracle.getLPPrice(_lpToken);
        return (remainCollateral * (1e18)) / lpPrice; // Need Decimal Correction in remainCollateral (Testing on Testnet)
    }

    function getTotalAvailableCollateralValue(address _account)
        public
        returns (uint256)
    {
        uint256 amountLPVault = viewAmountLPVault();
        uint256 totalCollateral = 0;

        for (uint256 count = 0; count < amountLPVault; count++) {
            LPVaultI lpVaultInstance = LPVaultI(lpVaults[count]);
            address lpToken = lpVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getLPPrice(lpToken);
            uint256 assetPrice = localOracle.getLPPrice(lpToken);
            uint256 accountCollateral = lpVaultInstance
                .viewCollateralAmountByAccount(_account);
            uint256 collateralPrice = assetPrice * accountCollateral;
            totalCollateral += collateralPrice;
        }

        return totalCollateral / (1e18);
    }

    function getTotalBorrowedValue(address _account) public returns (uint256) {
        uint256 amountSCVault = viewAmountSCVault();
        uint256 totalBorrowed = 0;

        for (uint256 count = 0; count < amountSCVault; count++) {
            SCVaultI scVaultInstance = SCVaultI(scVaults[count]);
            address scToken = scVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getTokenPrice(scToken);
            uint256 assetPrice = localOracle.getTokenPrice(scToken);
            uint256 accountBorrowed = scVaultInstance.borrowBalanceCurrent(
                _account
            );
            uint256 borrowedPrice = assetPrice * accountBorrowed;
            totalBorrowed += borrowedPrice;
        }

        return totalBorrowed;
    }

    function getBorrowLimit(address _account) public returns (uint256) {
        uint256 totalCollateral = getTotalAvailableCollateralValue(_account);
        return calcBorrowLimit(totalCollateral);
    }

    function calcBorrowLimit(uint256 _totalCollateral)
        public
        pure
        returns (uint256)
    {
        return (_totalCollateral * 2) / 3;
    }

    function calcBorrowedCollateral(uint256 _borrowed)
        public
        pure
        returns (uint256)
    {
        return (_borrowed * 3) / 2;
    }

    function borrowSC(address _scToken, uint256 _amount) external {
        uint256 borrowedTotal = getTotalBorrowedValue(msg.sender);
        uint256 borrowLimit = getBorrowLimit(msg.sender);
        uint256 borrowAllowed = borrowLimit - borrowedTotal;

        uint256 borrowAmount = localOracle.getTokenPricewithAmount(
            _scToken,
            _amount
        );
        require(borrowAllowed >= borrowAmount, "Borrowing more than allowed");

        SCVaultI scVault = SCVaultI(getVaultInstanceByToken[_scToken]);
        bool success = scVault._borrow(msg.sender, _amount);

        if (success) {
            emit NewBorrowed(msg.sender, _scToken, _amount);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    //                                      View Function                                     //
    ////////////////////////////////////////////////////////////////////////////////////////////
    function viewAmountLPVault() public view returns (uint256) {
        return lpVaults.length;
    }

    function viewAmountSCVault() public view returns (uint256) {
        return scVaults.length;
    }

    function viewSCPrice(address _scToken) public view returns (uint256) {
        return localOracle.getTokenPrice(_scToken);
    }

    function viewLPPrice(address _lpToken) public view returns (uint256) {
        return localOracle.getLPPrice(_lpToken);
    }

    function viewAllCollateralValueAndPrice()
        public
        view
        returns (uint256[] memory, uint256)
    {
        uint256 amountLPVault = viewAmountLPVault();
        uint256[] memory collateralByVault = new uint256[](amountLPVault);
        uint256 totalCollateral;
        for (uint256 count = 0; count < amountLPVault; count++) {
            LPVaultI lpVaultInstance = LPVaultI(lpVaults[count]);
            address lpToken = lpVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getLPPrice(lpToken);
            uint256 assetPrice = localOracle.getLPPrice(lpToken);
            uint256 collateral = lpVaultInstance.viewTotalCollateral();
            uint256 collateralPrice = assetPrice * collateral;

            totalCollateral += collateralPrice;
            collateralByVault[count] = collateral;
        }

        return (collateralByVault, totalCollateral / (1e18));
    }

    function viewAllCollateralValueAndPriceByAccount(address _account)
        public
        view
        returns (uint256[] memory, uint256)
    {
        uint256 amountLPVault = viewAmountLPVault();
        uint256[] memory collateralByVault = new uint256[](amountLPVault);
        uint256 totalCollateral;
        for (uint256 count = 0; count < amountLPVault; count++) {
            LPVaultI lpVaultInstance = LPVaultI(lpVaults[count]);
            address lpToken = lpVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getLPPrice(lpToken);
            uint256 assetPrice = localOracle.getLPPrice(lpToken);
            uint256 accountCollateral = lpVaultInstance
                .viewCollateralAmountByAccount(_account);
            uint256 collateralPrice = assetPrice * accountCollateral;

            totalCollateral += collateralPrice;
            collateralByVault[count] = accountCollateral;
        }

        return (collateralByVault, totalCollateral / (1e18));
    }

    function viewAllBorrowValueAndPrice()
        public
        view
        returns (uint256[] memory, uint256)
    {
        uint256 amountSCVault = viewAmountSCVault();
        uint256[] memory borrowByVault = new uint256[](amountSCVault);
        uint256 totalBorrow;
        for (uint256 count = 0; count < amountSCVault; count++) {
            SCVaultI scVaultInstance = SCVaultI(scVaults[count]);
            address scToken = scVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getTokenPrice(scToken);
            uint256 assetPrice = localOracle.getTokenPrice(scToken);
            uint256 borrow = scVaultInstance.viewTotalBorrow();
            uint256 borrowPrice = assetPrice * borrow;

            totalBorrow += borrowPrice;
            borrowByVault[count] = borrow;
        }

        return (borrowByVault, totalBorrow / (1e18));
    }

    function viewAllBorrowValueAndPriceByAccount(address _account)
        public
        view
        returns (uint256[] memory, uint256)
    {
        uint256 amountSCVault = viewAmountSCVault();
        uint256[] memory borrowByVault = new uint256[](amountSCVault);
        uint256 totalBorrow;
        for (uint256 count = 0; count < amountSCVault; count++) {
            SCVaultI scVaultInstance = SCVaultI(scVaults[count]);
            address scToken = scVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getTokenPrice(scToken);
            uint256 assetPrice = localOracle.getTokenPrice(scToken);
            uint256 accountBorrow = scVaultInstance.borrowBalancePrior(
                _account
            );
            uint256 borrowPrice = assetPrice * accountBorrow;

            totalBorrow += borrowPrice;
            borrowByVault[count] = accountBorrow;
        }

        return (borrowByVault, totalBorrow / (1e18));
    }

    function viewAllSCValueAndPrice()
        public
        view
        returns (uint256[] memory, uint256)
    {
        uint256 amountSCVault = viewAmountSCVault();
        uint256[] memory borrowByVault = new uint256[](amountSCVault);
        uint256 totalSCPrice;
        for (uint256 count = 0; count < amountSCVault; count++) {
            SCVaultI scVaultInstance = SCVaultI(scVaults[count]);
            address scToken = scVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getTokenPrice(scToken);
            uint256 assetPrice = localOracle.getTokenPrice(scToken);
            uint256 vaultValue = scVaultInstance.viewCashPrior();
            uint256 vaultPrice = assetPrice * vaultValue;

            totalSCPrice += vaultPrice;
            borrowByVault[count] = vaultValue;
        }

        return (borrowByVault, totalSCPrice / (1e18));
    }

    function viewMaxWithdrawAllowed(address _account, address _lpToken)
        external
        view
        returns (uint256)
    {
        uint256 totalBorrowed = viewTotalBorrowedValue(_account);
        uint256 totalCollateral = viewTotalAvailableCollateralValue(_account);
        uint256 requiredCollateral = calcBorrowedCollateral(totalBorrowed);
        if (requiredCollateral > totalCollateral) {
            return 0;
        }
        uint256 remainCollateral = totalCollateral - requiredCollateral;
        // uint256 lpPrice = oracle.getLPPrice(_lpToken);
        uint256 lpPrice = localOracle.getLPPrice(_lpToken);
        return (remainCollateral * (1e18)) / lpPrice; // Need Decimal Correction in remainCollateral (Testing on Testnet)
    }

    function viewTotalAvailableCollateralValue(address _account)
        public
        view
        returns (uint256)
    {
        uint256 amountLPVault = viewAmountLPVault();
        uint256 totalCollateral = 0;

        for (uint256 count = 0; count < amountLPVault; count++) {
            LPVaultI lpVaultInstance = LPVaultI(lpVaults[count]);
            address lpToken = lpVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getLPPrice(lpToken);
            uint256 assetPrice = localOracle.getLPPrice(lpToken);
            uint256 accountCollateral = lpVaultInstance
                .viewCollateralAmountByAccount(_account);
            uint256 collateralPrice = assetPrice * accountCollateral;
            totalCollateral += collateralPrice;
        }

        return totalCollateral / (1e18);
    }

    function viewTotalBorrowedValue(address _account)
        public
        view
        returns (uint256)
    {
        uint256 amountSCVault = viewAmountSCVault();
        uint256 totalBorrowed = 0;

        for (uint256 count = 0; count < amountSCVault; count++) {
            SCVaultI scVaultInstance = SCVaultI(scVaults[count]);
            address scToken = scVaultInstance.viewVaultAsset();
            // uint256 assetPrice = oracle.getTokenPrice(scToken);
            uint256 assetPrice = localOracle.getTokenPrice(scToken);
            uint256 accountBorrowed = scVaultInstance.borrowBalancePrior(
                _account
            );
            uint256 borrowedPrice = assetPrice * accountBorrowed;
            totalBorrowed += borrowedPrice;
        }

        return totalBorrowed;
    }

    function viewBorrowLimit(address _account) external view returns (uint256) {
        uint256 totalCollateral = viewTotalAvailableCollateralValue(_account);
        return calcBorrowLimit(totalCollateral);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./TrifleImplement.sol";
import "./compound/InterestRateModel.sol";
import "./interface/SCVaultI.sol";

import "./oracle/UniswapV2Oracle.sol";
import "./oracle/LocalOracle.sol"; // Test on local and testnet only

contract SCVault is Ownable, SCVaultI {
    string public scName;
    IERC20 public scToken;

    TriflePrototype2 public controller;
    InterestRateModel public InterestRate;

    UniswapV2Oracle public oracle;
    LocalOracle public localOracle;

    mapping(address => BorrowSnapshot) public accountBorrowsSnapshot;
    mapping(address => uint256) public principalBalance;

    uint256 public accrualBlockNumber;
    uint256 public totalBorrows;
    uint256 public totalReserves;
    uint256 public borrowIndex;
    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;
    uint256 public reserveFactorMantissa;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    event SCBorrowed(address _account, uint256 _amount);
    event InterestRateModelUpdate(address _newIRM);
    event InterestShortCircuit(uint256 indexed _blockNumber);
    event InterestAccrued(
        uint256 indexed _accrualBlockNumber,
        uint256 _borrowIndex,
        uint256 _totalBorrows,
        uint256 _totalReserves
    );
    event StableCoinLent(address _lender, uint256 _amount);
    event StableCoinWithdraw(address _lender, uint256 _amount);
    event LoanPayed(
        address _borrower,
        uint256 _repayAmount,
        uint256 _remainingPrinciple,
        uint256 _remainingInterest
    );
    event StableCoinWithdraw(
        address _lender,
        uint256 _amountWithdrawn,
        uint256 _amountOfWarpBurnt
    );

    modifier onlyController() {
        require(msg.sender == address(controller), "Caller is not controller");
        _;
    }

    constructor(
        address _scToken,
        string memory _scName,
        address _controller,
        address _oracle,
        address _interestRate,
        uint256 _reserveFactorMantissa
    ) {
        scToken = IERC20(_scToken);
        scName = _scName;
        controller = TriflePrototype2(_controller);
        // oracle = UniswapV2Oracle(_oracle);
        localOracle = LocalOracle(_oracle);

        borrowIndex = 1e18;

        InterestRate = InterestRateModel(_interestRate);
        reserveFactorMantissa = _reserveFactorMantissa;
    }

    function setNewInterestModel(address _newModel) public onlyController {
        InterestRate = InterestRateModel(_newModel);
        emit InterestRateModelUpdate(_newModel);
    }

    function viewVaultAsset() external view returns (address) {
        return address(scToken);
    }

    function viewVaultName() external view returns (string memory) {
        return scName;
    }

    function viewCashPrior() public view returns (uint256) {
        return scToken.balanceOf(address(this));
    }

    function accrueInterest() public {
        //Remember the initial block number
        uint256 currentBlockNumber = block.number;
        uint256 accrualBlockNumberPrior = accrualBlockNumber;

        //Short-circuit accumulating 0 interest
        if (accrualBlockNumberPrior == currentBlockNumber) {
            emit InterestShortCircuit(currentBlockNumber);
            return;
        }

        //Read the previous values out of storage
        uint256 cashPrior = viewCashPrior();
        uint256 borrowsPrior = totalBorrows;
        uint256 reservesPrior = totalReserves;
        uint256 borrowIndexPrior = borrowIndex;
        //Calculate the current borrow interest rate
        uint256 borrowRateMantissa = InterestRate.getBorrowRate(
            cashPrior,
            borrowsPrior,
            reservesPrior
        );
        require(
            borrowRateMantissa <= borrowRateMaxMantissa,
            "Borrow Rate mantissa error"
        );
        //Calculate the number of blocks elapsed since the last accrual
        uint256 blockDelta = currentBlockNumber - accrualBlockNumberPrior;

        //Calculate the interest accumulated into borrows and reserves and the new index:
        uint256 simpleInterestFactor;
        uint256 interestAccumulated;
        uint256 totalBorrowsNew;
        uint256 totalReservesNew;
        uint256 borrowIndexNew;

        //simpleInterestFactor = borrowRate * blockDelta
        simpleInterestFactor = borrowRateMantissa * blockDelta;

        //interestAccumulated = simpleInterestFactor * totalBorrows
        interestAccumulated = (simpleInterestFactor * borrowsPrior) / 1e18;

        //totalBorrowsNew = interestAccumulated + totalBorrows
        totalBorrowsNew = interestAccumulated + borrowsPrior;

        //totalReservesNew = interestAccumulated * reserveFactor + totalReserves
        totalReservesNew =
            ((reserveFactorMantissa * interestAccumulated) / 1e18) +
            reservesPrior;

        //borrowIndexNew = simpleInterestFactor * borrowIndex + borrowIndex
        borrowIndexNew =
            ((simpleInterestFactor * borrowIndexPrior) / 1e18) +
            borrowIndexPrior;

        //Write the previously calculated values into storage
        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;
        emit InterestAccrued(
            accrualBlockNumber,
            borrowIndex,
            totalBorrows,
            totalReserves
        );
    }

    function borrowBalancePrior(address _account)
        public
        view
        returns (uint256)
    {
        uint256 balance;

        BorrowSnapshot storage borrowSnapshot = accountBorrowsSnapshot[
            _account
        ];
        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        // recentBorrowBalance = borrower.borrowBalance * market.borrowIndex / borrower.borrowIndex
        balance =
            (borrowSnapshot.principal * borrowIndex) /
            borrowSnapshot.interestIndex;

        return balance;
    }

    function borrowBalanceCurrent(address _account) public returns (uint256) {
        accrueInterest();

        return borrowBalancePrior(_account);
    }

    function viewTotalBorrow() public view returns (uint256) {
        return totalBorrows;
    }

    function lendToWarpVault(uint256 _amount) external {
        require(
            scToken.balanceOf(msg.sender) >= _amount,
            "Not enough Stable Coin to lend"
        );
        bool success = scToken.transferFrom(msg.sender, address(this), _amount);
        if (success) {
            principalBalance[msg.sender] += _amount;
            emit StableCoinLent(msg.sender, _amount);
        }
    }

    function redeem(uint256 _amount) external {
        require(
            principalBalance[msg.sender] >= _amount,
            "You redeem more than you lent"
        );
        bool success = scToken.transfer(msg.sender, _amount);
        if (success) {
            principalBalance[msg.sender] -= _amount;
            emit StableCoinWithdraw(msg.sender, _amount);
        }
    }

    struct BorrowLocalVars {
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
    }

    function _borrow(address _account, uint256 _amount)
        external
        onlyController
        returns (bool)
    {
        BorrowLocalVars memory vars;

        require(viewCashPrior() > _amount, "Not enough token in vault");
        vars.accountBorrows = borrowBalancePrior(_account);
        vars.accountBorrowsNew = vars.accountBorrows + _amount;
        vars.totalBorrowsNew = totalBorrows + _amount;
        accountBorrowsSnapshot[_account].principal = vars.accountBorrowsNew;
        accountBorrowsSnapshot[_account].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        bool success = scToken.transfer(_account, _amount);

        if (success) {
            emit SCBorrowed(_account, _amount);
        }

        return success;
    }

    function repayBorrow(uint256 _repayAmount) external returns (bool) {
        uint256 repayAmount;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;

        accountBorrows = borrowBalanceCurrent(msg.sender);
        require(
            accountBorrows >= _repayAmount,
            "Trying to pay back more than you owe"
        );
        if (_repayAmount == 0) {
            repayAmount = accountBorrows;
        } else {
            repayAmount = _repayAmount;
        }

        require(
            scToken.balanceOf(msg.sender) >= repayAmount,
            "Not enough stable coin to repay"
        );
        bool success = scToken.transferFrom(
            msg.sender,
            address(this),
            repayAmount
        );
        if (success) {
            accountBorrowsNew = accountBorrows - repayAmount;
            totalBorrowsNew = totalBorrows - repayAmount;
            totalBorrows = totalBorrowsNew;
            accountBorrowsSnapshot[msg.sender].principal = accountBorrowsNew;
            accountBorrowsSnapshot[msg.sender].interestIndex = borrowIndex;

            emit LoanPayed(
                msg.sender,
                repayAmount,
                accountBorrowsSnapshot[msg.sender].principal,
                accountBorrowsSnapshot[msg.sender].interestIndex
            );
        }

        return success;
    }

    function viewBorrowRatePerBlock() public view returns (uint256) {
        return
            InterestRate.getBorrowRate(
                viewCashPrior(),
                totalBorrows,
                totalReserves
            );
    }

    function viewSupplyRatePerBlock() public view returns (uint256) {
        return
            InterestRate.getSupplyRate(
                viewCashPrior(),
                totalBorrows,
                totalReserves,
                reserveFactorMantissa
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrifleImplement.sol";
import "./interface/LPVaultI.sol";

import "./oracle/UniswapV2Oracle.sol";
import "./oracle/LocalOracle.sol"; // Test on local and testnet only

contract LPVault is Ownable, LPVaultI {
    string public lpName;
    IERC20 public lpToken;
    TriflePrototype2 public controller;

    UniswapV2Oracle public oracle;
    LocalOracle public localOracle;

    uint256 public totalCollateral;

    mapping(address => uint256) public collateralizedLP;

    event CollateralProvided(address _account, uint256 _amount);
    event CollateralWithdraw(address _account, uint256 _amount);
    event AccountLiquidated(
        address _account,
        address _liquidator,
        uint256 _amount
    );

    modifier onlyController() {
        require(msg.sender == address(controller), "Caller is not controller");
        _;
    }

    constructor(
        address _lpToken,
        string memory _lpName,
        address _controller,
        address _oracle
    ) {
        lpToken = IERC20(_lpToken);
        lpName = _lpName;
        controller = TriflePrototype2(_controller);
        // oracle = UniswapV2Oracle(_oracle);
        localOracle = LocalOracle(_oracle);
    }

    function provideCollateral(uint256 _amount) external returns (bool) {
        require(_amount > 0, "Input Value must more than 0");
        require(
            lpToken.allowance(msg.sender, address(this)) >= _amount,
            "Vault must have enough allowance"
        );
        require(
            lpToken.balanceOf(msg.sender) >= _amount,
            "Don't have enough LP Token to provide"
        );
        bool success = lpToken.transferFrom(msg.sender, address(this), _amount);

        if (success) {
            collateralizedLP[msg.sender] += _amount;
            totalCollateral += _amount;
            emit CollateralProvided(msg.sender, _amount);
        }
        return success;
    }

    function withdrawCollateral(uint256 _amount) external returns (bool) {
        require(_amount > 0, "Input Value must more than 0");
        uint256 maxWithdrawAmount = controller.getMaxWithdrawAllowed(
            msg.sender,
            address(lpToken)
        );
        require(
            _amount <= maxWithdrawAmount,
            "Withdraw more than possible amount"
        );
        require(
            _amount <= collateralizedLP[msg.sender],
            "Withdraw more collateral than you locked"
        );
        collateralizedLP[msg.sender] -= _amount;
        totalCollateral -= _amount;
        bool success = lpToken.transfer(msg.sender, _amount);

        if (success) {
            emit CollateralWithdraw(msg.sender, _amount);
        }
        return success;
    }

    function liquidateAccount(address _account, address _liquidator)
        external
        onlyController
        returns (bool)
    {
        uint256 amount = collateralizedLP[_account];
        collateralizedLP[_account] = 0;
        totalCollateral -= amount;
        bool success = lpToken.transfer(_liquidator, amount);
        if (success) {
            emit AccountLiquidated(
                _account,
                _liquidator,
                collateralizedLP[_account]
            );
        }
        return success;
    }

    function viewCollateralAmountByAccount(address _account)
        external
        view
        returns (uint256)
    {
        return collateralizedLP[_account];
    }

    function viewTotalCollateral() public view returns (uint256) {
        return totalCollateral;
    }

    function viewVaultAsset() external view returns (address) {
        return address(lpToken);
    }

    function viewVaultName() external view returns (string memory) {
        return lpName;
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