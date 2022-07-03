// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { Owned } from "solmate/auth/Owned.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { FixedPointMathLib } from "solmate/utils/FixedPointMathLib.sol";

import { IFLT } from "./interfaces/IFLT.sol";
import { IUniswapV2Pair } from "./interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";
import { IfERC20 } from "./interfaces/IfERC20.sol";
import { IFuseComptroller } from "./interfaces/IFuseComptroller.sol";

import { FLTFactory } from "./FLTFactory.sol";
import { RariFusePriceOracleAdapter } from "./adapters/RariFusePriceOracleAdapter.sol";

/**
 * @title Fuse Leveraged Token via Single Pair
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @dev This is optimized version of RiseToken for single pair token such as
 *      WETH/USDC pair
 */
contract FLTSinglePair is IFLT, ERC20, Owned {

    /// ███ Libraries ████████████████████████████████████████████████████████

    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;


    /// ███ Storages █████████████████████████████████████████████████████████

    FLTFactory                 public factory;
    RariFusePriceOracleAdapter public oracleAdapter;
    IUniswapV2Pair             public pair;
    IUniswapV2Router02         public router;

    ERC20   public collateral;
    ERC20   public debt;
    IfERC20 public fCollateral;
    IfERC20 public fDebt;

    uint256 public totalCollateral;
    uint256 public totalDebt;
    uint256 public maxMint;
    uint256 public fees;
    uint256 public minLeverageRatio;
    uint256 public maxLeverageRatio;
    uint256 public step;
    uint256 public discount;
    bool    public isInitialized;

    // Deployment status
    bool    internal isDeployed;

    constructor() ERC20("SP", "FLT", 18) Owned(msg.sender) {}

    /// ███ Modifiers ████████████████████████████████████████████████████████

    modifier whenInitialized() {
        if (!isInitialized) revert Uninitialized();
        _;
    }


    /// ███ Deployment ███████████████████████████████████████████████████████
    event Debug(string key, address val);

    /// @inheritdoc IFLT
    function deploy(
        address _factory,
        string memory _name,
        string memory _symbol,
        bytes  memory _data
    ) external {
        if (isDeployed) revert Deployed();
        isDeployed = true;

        // Set token metadata
        name = _name;
        symbol = _symbol;
        owner = Owned(_factory).owner();

        // Parse data
        (
            address fc,
            address fd,
            address o,
            address p,
            address r
        ) = abi.decode(_data, (address,address,address,address,address));

        // Setup storages
        factory = FLTFactory(_factory);
        fCollateral = IfERC20(fc);
        collateral = ERC20(fCollateral.underlying());
        fDebt = IfERC20(fd);
        debt = ERC20(fDebt.underlying());
        oracleAdapter = RariFusePriceOracleAdapter(o);
        pair = IUniswapV2Pair(p);
        router = IUniswapV2Router02(r);

        maxMint = type(uint256).max;
        fees = 0.001 ether; // 0.1%
        minLeverageRatio = 1.6 ether;
        maxLeverageRatio = 2.5 ether;
        step = 0.4 ether;
        discount = 0.006 ether; // 0.6%

        // Enter the markets
        address[] memory markets = new address[](2);
        markets[0] = address(fCollateral);
        markets[1] = address(fDebt);
        IFuseComptroller troll = IFuseComptroller(fCollateral.comptroller());
        uint256[] memory res = troll.enterMarkets(markets);
        if (res[0] != 0 || res[1] != 0) revert FuseError(res[0]);

        increaseAllowance();
    }


    /// ███ Internal functions ███████████████████████████████████████████████

    function supplyThenBorrow(uint256 _ca, uint256 _ba) internal {
        // Deposit to Rari Fuse
        uint256 fuseResponse;
        fuseResponse = fCollateral.mint(_ca);
        if (fuseResponse != 0) revert FuseError(fuseResponse);
        totalCollateral = fCollateral.balanceOfUnderlying(address(this));

        // Borrow from Rari Fuse
        if (_ba == 0) return;
        fuseResponse = fDebt.borrow(_ba);
        if (fuseResponse != 0) revert FuseError(fuseResponse);
        totalDebt = fDebt.borrowBalanceCurrent(address(this));
    }

    function repayThenRedeem(uint256 _rAmount, uint256 _cAmount) internal {
        // Repay debt to Rari Fuse
        uint256 repayResponse = fDebt.repayBorrow(_rAmount);
        if (repayResponse != 0) revert FuseError(repayResponse);

        // Redeem from Rari Fuse
        uint256 redeemResponse = fCollateral.redeemUnderlying(_cAmount);
        if (redeemResponse != 0) revert FuseError(redeemResponse);

        // Cache the value
        totalCollateral = fCollateral.balanceOfUnderlying(address(this));
        totalDebt = fDebt.borrowBalanceCurrent(address(this));
    }

    function onMint(FlashSwapParams memory _params) internal {
        /// ███ Checks
        if (_params.amountIn == 0) revert AmountInTooLow();
        if (_params.amountOut == 0) revert AmountOutTooLow();

        /// ███ Effects
        supplyThenBorrow(_params.collateralAmount, _params.debtAmount);
        debt.safeTransfer(address(pair), _params.repayAmount);
        if (_params.refundAmount > 0) {
            _params.tokenIn.safeTransfer(
                _params.refundRecipient,
                _params.refundAmount
            );
        }
        if (_params.feeAmount > 0) {
            _params.tokenIn.safeTransfer(
                factory.feeRecipient(),
                _params.feeAmount
            );
        }

        // Mint the shares
        _mint(_params.recipient, _params.amountOut);

        // Emit Swap event
        emit Swap(
            _params.sender,
            _params.recipient,
            address(_params.tokenIn),
            address(_params.tokenOut),
            _params.amountIn,
            _params.amountOut,
            _params.feeAmount,
            price()
        );
    }

    function onBurn(FlashSwapParams memory _params) internal {
        /// ███ Checks
        if (_params.amountIn == 0) revert AmountInTooLow();
        if (_params.amountOut == 0) revert AmountOutTooLow();

        /// ███ Effects
        repayThenRedeem(_params.debtAmount, _params.collateralAmount);
        collateral.safeTransfer(address(pair), _params.repayAmount);
        if (_params.feeAmount > 0) {
            _params.tokenOut.safeTransfer(
                factory.feeRecipient(),
                _params.feeAmount
            );
        }

        // Burn the shares and send the tokenOut
        _burn(address(this), _params.amountIn);
        _params.tokenOut.safeTransfer(_params.recipient, _params.amountOut);

        // Emit Swap event
        emit Swap(
            _params.sender,
            _params.recipient,
            address(_params.tokenIn),
            address(_params.tokenOut),
            _params.amountIn,
            _params.amountOut,
            _params.feeAmount,
            price()
        );
    }


    /// ███ Owner actions ████████████████████████████████████████████████████

    /// @inheritdoc IFLT
    function setParams(
        uint256 _minLeverageRatio,
        uint256 _maxLeverageRatio,
        uint256 _step,
        uint256 _discount,
        uint256 _newMaxMint
    ) external onlyOwner {
        // Checks
        if (
            _minLeverageRatio < 1.2 ether ||
            _maxLeverageRatio > 3 ether ||
            _minLeverageRatio > _maxLeverageRatio
        ) {
            revert InvalidLeverageRatio();
        }

        uint256 delta = _maxLeverageRatio - _minLeverageRatio;
        if (delta < _step) revert InvalidLeverageRatio();

        // plus or minus 0.5x leverage in one rebalance is too much
        if (_step > 0.5 ether || _step < 0.1 ether) revert InvalidRebalancingStep();
        // 5% discount too much; 0.1% discount too low
        if (_discount > 0.05 ether || _discount < 0.001 ether)  {
            revert InvalidDiscount();
        }

        // Effects
        minLeverageRatio = _minLeverageRatio;
        maxLeverageRatio = _maxLeverageRatio;
        step = _step;
        discount = _discount;
        maxMint = _newMaxMint;

        emit ParamsUpdated(
            minLeverageRatio,
            maxLeverageRatio,
            step,
            discount,
            maxMint
        );
    }

    /// @inheritdoc IFLT
    function initialize(
        uint256 _ca,
        uint256 _da,
        uint256 _shares
    ) external onlyOwner {
        if (isInitialized) revert Uninitialized();
        isInitialized = true;

        address[] memory path = new address[](2);
        path[0] = address(debt);
        path[1] = address(collateral);
        uint256 repayAmount = router.getAmountsIn(_ca, path)[0];
        if (repayAmount < _da) revert AmountInTooLow();

        uint256 amountInUsed = repayAmount - _da;
        uint256 amountIn = debt.balanceOf(address(this));
        if(amountIn < amountInUsed) revert AmountInTooLow();
        uint256 refundAmount = amountIn - amountInUsed;

        // Borrow collateral from pair
        address c = address(collateral);
        uint256 amount0Out = c == pair.token0() ? _ca : 0;
        uint256 amount1Out = c == pair.token1() ? _ca : 0;

        // Do the instant leverage
        FlashSwapParams memory params = FlashSwapParams({
            flashSwapType: FlashSwapType.Mint,
            sender: msg.sender,
            recipient: msg.sender,
            refundRecipient: msg.sender,
            tokenIn: debt,
            tokenOut: ERC20(address(this)),
            amountIn: amountInUsed,
            amountOut: _shares,
            feeAmount: 0,
            refundAmount: refundAmount,
            borrowAmount: _ca,
            repayAmount: repayAmount,
            collateralAmount: _ca,
            debtAmount: _da
        });
        bytes memory data = abi.encode(params);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }


    /// ███ External functions ███████████████████████████████████████████████

    function pancakeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes memory _data
    ) external {
        _callback(_sender, _amount0, _amount1, _data);
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes memory _data
    ) external {
        _callback(_sender, _amount0, _amount1, _data);
    }

    function _callback(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes memory _data
    ) internal {
        /// ███ Checks
        if (msg.sender != address(pair)) revert Unauthorized();
        if (_sender != address(this)) revert Unauthorized();

        FlashSwapParams memory params = abi.decode(_data, (FlashSwapParams));
        // Make sure borrowed amount from flash swap is correct
        uint256 r = _amount0 == 0 ? _amount1 : _amount0;
        if (r != params.borrowAmount) revert InvalidFlashSwapAmount();

        if (params.flashSwapType == FlashSwapType.Mint) {
            onMint(params);
            return;
        } else if (params.flashSwapType == FlashSwapType.Burn) {
            onBurn(params);
            return;
        } else revert InvalidFlashSwapType();
    }

    /// @inheritdoc IFLT
    function increaseAllowance() public {
        uint256 max = type(uint256).max;
        collateral.safeApprove(address(fCollateral), max);
        debt.safeApprove(address(fDebt), max);
    }


    /// ███ Read-only functions ██████████████████████████████████████████████

    /// @inheritdoc IFLT
    function sharesToUnderlying(
        uint256 _amount
    ) public view whenInitialized returns (uint256 _ca, uint256 _da) {
        _ca = _amount.mulDivDown(totalCollateral, totalSupply);
        _da = _amount.mulDivDown(totalDebt, totalSupply);
    }

    /// @inheritdoc IFLT
    function collateralPerShare() public view whenInitialized returns (uint256 _cps) {
        (_cps, ) = sharesToUnderlying(1 ether);
    }

    /// @inheritdoc IFLT
    function debtPerShare() public view whenInitialized returns (uint256 _dps) {
        ( ,_dps) = sharesToUnderlying(1 ether);
    }

    /// @inheritdoc IFLT
    function value(
        uint256 _shares
    ) public view whenInitialized returns (uint256 _value) {
        if (_shares == 0) return 0;

        // Get the collateral & debt amount
        (uint256 ca, uint256 da) = sharesToUnderlying(_shares);

        // Get the collateral value in ETH
        uint256 cv = oracleAdapter.totalValue(
            address(collateral),
            address(0),
            ca
        );
        uint256 dv = oracleAdapter.totalValue(
            address(debt),
            address(0),
            da
        );

        // Get total value in terms of debt token
        _value = cv - dv;
    }

    /// @inheritdoc IFLT
    function price() public view whenInitialized returns (uint256 _price) {
        _price = value(1 ether);
    }

    /// @inheritdoc IFLT
    function leverageRatio() public whenInitialized view returns (uint256 _lr) {
        uint256 cv = oracleAdapter.totalValue(
            address(collateral),
            address(debt),
            totalCollateral
        );
        _lr = cv.divWadUp(cv - totalDebt);
    }


    /// ███ User actions █████████████████████████████████████████████████████

    /// @inheritdoc IFLT
    function mintd(
        uint256 _shares,
        address _recipient,
        address _refundRecipient
    ) external whenInitialized {
        /// ███ Checks
        if (_shares == 0) revert AmountOutTooLow();
        if (_shares > maxMint) revert AmountOutTooHigh();

        FlashSwapParams memory params;

        {
            (uint256 ca, uint256 da) = sharesToUnderlying(_shares);
            address[] memory path = new address[](2);
            path[0] = address(debt);
            path[1] = address(collateral);
            uint256 repayAmount = router.getAmountsIn(ca, path)[0];
            uint256 borrowAmount = ca;

            if (repayAmount < da) revert AmountInTooLow();
            uint256 amountInUsed = repayAmount - da;
            uint256 feeAmount = fees.mulWadDown(amountInUsed);
            uint256 amountIn = debt.balanceOf(address(this));

            if (amountIn < amountInUsed + feeAmount) revert AmountInTooLow();
            uint256 refundAmount = amountIn - (amountInUsed + feeAmount);

            params = FlashSwapParams({
                flashSwapType: FlashSwapType.Mint,
                sender: msg.sender,
                recipient: _recipient,
                refundRecipient: _refundRecipient,
                tokenIn: debt,
                tokenOut: ERC20(address(this)),
                amountIn: amountInUsed,
                amountOut: _shares,
                feeAmount: feeAmount,
                refundAmount: refundAmount,
                borrowAmount: borrowAmount,
                repayAmount: repayAmount,
                collateralAmount: ca,
                debtAmount: da
            });
        }

        // Do the instant leverage
        address c = address(collateral);
        uint256 amount0Out = c == pair.token0() ? params.borrowAmount : 0;
        uint256 amount1Out = c == pair.token1() ? params.borrowAmount : 0;
        bytes memory data = abi.encode(params);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    /// @inheritdoc IFLT
    function mintc(
        uint256 _shares,
        address _recipient,
        address _refundRecipient
    ) external whenInitialized {
        /// ███ Checks
        if (_shares == 0) revert AmountOutTooLow();
        if (_shares > maxMint) revert AmountOutTooHigh();

        FlashSwapParams memory params;

        {
            (uint256 ca, uint256 da) = sharesToUnderlying(_shares);
            address[] memory path = new address[](2);
            path[0] = address(debt);
            path[1] = address(collateral);
            uint256 repayAmount = da;
            uint256 borrowAmount = router.getAmountsOut(repayAmount, path)[1];

            if (ca < borrowAmount) revert AmountInTooLow();
            uint256 amountInUsed = ca - borrowAmount;
            uint256 feeAmount = fees.mulWadDown(amountInUsed);
            uint256 amountIn = collateral.balanceOf(address(this));

            if (amountIn < amountInUsed + feeAmount) revert AmountInTooLow();
            uint256 refundAmount = amountIn - (amountInUsed + feeAmount);

            params = FlashSwapParams({
                flashSwapType: FlashSwapType.Mint,
                sender: msg.sender,
                recipient: _recipient,
                refundRecipient: _refundRecipient,
                tokenIn: collateral,
                tokenOut: ERC20(address(this)),
                amountIn: amountInUsed,
                amountOut: _shares,
                feeAmount: feeAmount,
                refundAmount: refundAmount,
                borrowAmount: borrowAmount,
                repayAmount: repayAmount,
                collateralAmount: ca,
                debtAmount: da
            });
        }

        // Do the instant leverage
        address c = address(collateral);
        uint256 amount0Out = c == pair.token0() ? params.borrowAmount : 0;
        uint256 amount1Out = c == pair.token1() ? params.borrowAmount : 0;
        bytes memory data = abi.encode(params);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    /// @inheritdoc IFLT
    function burnd(
        address _recipient,
        uint256 _minAmountOut
    ) external whenInitialized {
        uint256 burnAmount = balanceOf[address(this)];
        if (burnAmount == 0) revert AmountInTooLow();

        FlashSwapParams memory params;

        {
            (uint256 ca, uint256 da) = sharesToUnderlying(burnAmount);
            address[] memory path = new address[](2);
            path[0] = address(collateral);
            path[1] = address(debt);
            uint256 repayAmount = ca;
            uint256 borrowAmount = router.getAmountsOut(repayAmount, path)[1];

            if (borrowAmount < da) revert AmountOutTooLow();
            uint256 amountOut = borrowAmount - da;
            uint256 feeAmount = fees.mulWadDown(amountOut);
            amountOut -= feeAmount;
            if (amountOut < _minAmountOut) revert AmountOutTooLow();

            params = FlashSwapParams({
                flashSwapType: FlashSwapType.Burn,
                sender: msg.sender,
                recipient: _recipient,
                refundRecipient: address(0),
                tokenIn: ERC20(address(this)),
                tokenOut: debt,
                amountIn: burnAmount,
                amountOut: amountOut,
                feeAmount: feeAmount,
                refundAmount: 0,
                borrowAmount: borrowAmount,
                repayAmount: repayAmount,
                collateralAmount: ca,
                debtAmount: da
            });
        }

        // Do the instant close position
        address d = address(debt);
        uint256 amount0Out = d == pair.token0() ? params.borrowAmount : 0;
        uint256 amount1Out = d == pair.token1() ? params.borrowAmount : 0;
        bytes memory data = abi.encode(params);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    /// @inheritdoc IFLT
    function burnc(
        address _recipient,
        uint256 _minAmountOut
    ) external whenInitialized {
        uint256 burnAmount = balanceOf[address(this)];
        if (burnAmount == 0) revert AmountInTooLow();

        FlashSwapParams memory params;

        {
            (uint256 ca, uint256 da) = sharesToUnderlying(burnAmount);
            address[] memory path = new address[](2);
            path[0] = address(collateral);
            path[1] = address(debt);
            uint256 repayAmount = router.getAmountsIn(da, path)[0];
            uint256 borrowAmount = da;

            if (ca < repayAmount) revert AmountOutTooLow();
            uint256 amountOut = ca - repayAmount;
            uint256 feeAmount = fees.mulWadDown(amountOut);
            amountOut -= feeAmount;
            if (amountOut < _minAmountOut) revert AmountOutTooLow();

            params = FlashSwapParams({
                flashSwapType: FlashSwapType.Burn,
                sender: msg.sender,
                recipient: _recipient,
                refundRecipient: address(0),
                tokenIn: ERC20(address(this)),
                tokenOut: collateral,
                amountIn: burnAmount,
                amountOut: amountOut,
                feeAmount: feeAmount,
                refundAmount: 0,
                borrowAmount: borrowAmount,
                repayAmount: repayAmount,
                collateralAmount: ca,
                debtAmount: da
            });
        }

        // Do the instant close position
        address d = address(debt);
        uint256 amount0Out = d == pair.token0() ? params.borrowAmount : 0;
        uint256 amount1Out = d == pair.token1() ? params.borrowAmount : 0;
        bytes memory data = abi.encode(params);
        pair.swap(amount0Out, amount1Out, address(this), data);
    }


    /// ███ Market makers ████████████████████████████████████████████████████

    /// @inheritdoc IFLT
    function pushc() external whenInitialized {
        /// ███ Checks
        uint256 lr = leverageRatio();
        uint256 amountIn = collateral.balanceOf(address(this));

        if (lr > minLeverageRatio) revert Balance();
        if (amountIn == 0) revert AmountInTooLow();

        uint256 amountOutInETH = step.mulWadDown(value(totalSupply));
        uint256 amountOut = oracleAdapter.totalValue(
            address(0),
            address(debt),
            amountOutInETH
        );
        uint256 expectedAmountIn = oracleAdapter.totalValue(
            address(0),
            address(collateral),
            amountOutInETH
        );
        uint256 amountInDiscount = discount.mulWadDown(expectedAmountIn);
        uint256 minAmountIn = expectedAmountIn - amountInDiscount;

        // Make sure collateral token is sent to this contract
        if (amountIn < minAmountIn) revert AmountInTooLow();
        uint256 refundAmountIn = amountIn - minAmountIn;

        // Prev states
        uint256 prevLeverageRatio = lr;
        uint256 prevTotalCollateral = totalCollateral;
        uint256 prevTotalDebt = totalDebt;
        uint256 prevPrice = price();

        /// ███ Effects
        // Supply then borrow
        supplyThenBorrow(minAmountIn, amountOut);
        debt.safeTransfer(msg.sender, amountOut);
        if (refundAmountIn > 0) {
            collateral.safeTransfer(msg.sender, refundAmountIn);
        }

        // Emit event
        emit Rebalanced(
            msg.sender,
            prevLeverageRatio,
            leverageRatio(),
            prevTotalCollateral,
            totalCollateral,
            prevTotalDebt,
            totalDebt,
            prevPrice,
            price()
        );
    }

    /// @inheritdoc IFLT
    function pushd() external whenInitialized {
        /// ███ Checks
        uint256 lr = leverageRatio();
        if (lr < maxLeverageRatio) revert Balance();
        uint256 amountIn = debt.balanceOf(address(this));
        if (amountIn == 0) revert AmountInTooLow();

        uint256 amountOutInETH = step.mulWadDown(value(totalSupply));
        uint256 amountOut = oracleAdapter.totalValue(
            address(0),
            address(collateral),
            amountOutInETH
        );
        uint256 expectedAmountIn = oracleAdapter.totalValue(
            address(0),
            address(debt),
            amountOutInETH
        );
        uint256 amountInDiscount = discount.mulWadDown(expectedAmountIn);
        uint256 minAmountIn = expectedAmountIn - amountInDiscount;

        // Make sure debt token is sent to this contract
        if (amountIn < minAmountIn) revert AmountInTooLow();
        uint256 refundAmountIn = amountIn - minAmountIn;

        // Prev states
        uint256 prevLeverageRatio = lr;
        uint256 prevTotalCollateral = totalCollateral;
        uint256 prevTotalDebt = totalDebt;
        uint256 prevPrice = price();

        /// ███ Effects
        // Repay then redeem
        repayThenRedeem(minAmountIn, amountOut);
        collateral.safeTransfer(msg.sender, amountOut);
        if (refundAmountIn > 0) {
            debt.safeTransfer(msg.sender, refundAmountIn);
        }

        // Emit event
        emit Rebalanced(
            msg.sender,
            prevLeverageRatio,
            leverageRatio(),
            prevTotalCollateral,
            totalCollateral,
            prevTotalDebt,
            totalDebt,
            prevPrice,
            price()
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // First, divide z - 1 by the denominator and add 1.
            // We allow z - 1 to underflow if z is 0, because we multiply the
            // end result by 0 if z is zero, ensuring we return 0 if z is zero.
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // Start off with z at 1.
            z := 1

            // Used below to help find a nearby power of 2.
            let y := x

            // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                // Equivalent to 2 ** z.
                z := shl(1, z)
            }

            // Shifting right by 1 is like dividing by 2.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // Compute a rounded down version of z.
            let zRoundDown := div(x, z)

            // If zRoundDown is smaller, use it.
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { ERC20 } from "solmate/tokens/ERC20.sol";

import { IfERC20 } from "./IfERC20.sol";

import { RariFusePriceOracleAdapter } from "../adapters/RariFusePriceOracleAdapter.sol";
import { FLTFactory } from "../FLTFactory.sol";

/**
 * @title Fuse Leveraged Token Interface
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @dev Optimized version of RiseToken to work with single or multi-pair
 */
interface IFLT {

    /// ███ Types ████████████████████████████████████████████████████████████

    /// @notice Flashswap types
    enum FlashSwapType { Mint, Burn }

    /// @notice Mint & Burn params
    struct FlashSwapParams {
        FlashSwapType flashSwapType;

        address sender;
        address recipient;
        address refundRecipient;
        ERC20   tokenIn;
        ERC20   tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
        uint256 refundAmount;
        uint256 borrowAmount;
        uint256 repayAmount;
        uint256 collateralAmount;
        uint256 debtAmount;
    }

    /// ███ Events ███████████████████████████████████████████████████████████

    /// @notice Event emitted when new supply is minted or burned
    event Swap(
        address indexed sender,
        address indexed recipient,
        address indexed tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeAmount,
        uint256 priceInETH
    );

    /**
     * @notice Event emitted when params updated
     * @param maxLeverageRatio The maximum leverage ratio
     * @param minLeverageRatio The minimum leverage ratio
     * @param step The rebalancing step
     * @param discount The incentives for the market makers
     * @param maxMint The maximum amount to mint in one transaction
     */
    event ParamsUpdated(
        uint256 maxLeverageRatio,
        uint256 minLeverageRatio,
        uint256 step,
        uint256 discount,
        uint256 maxMint
    );

    /**
     * @notice Event emitted when the Rise Token is rebalanced
     * @param executor The address who execute the rebalance
     * @param prevLeverageRatio Previous leverage ratio
     * @param leverageRatio Current leverage ratio
     * @param prevTotalCollateral Previous total collateral
     * @param totalCollateral Current total collateral
     * @param prevTotalDebt Previoes total debt
     * @param totalDebt Current total debt
     * @param prevPriceInETH Previous price in ETH
     * @param priceInETH Current price in ETH
     */
    event Rebalanced(
        address executor,
        uint256 prevLeverageRatio,
        uint256 leverageRatio,
        uint256 prevTotalCollateral,
        uint256 totalCollateral,
        uint256 prevTotalDebt,
        uint256 totalDebt,
        uint256 prevPriceInETH,
        uint256 priceInETH
    );

    /// ███ Errors ███████████████████████████████████████████████████████████

    /// @notice Error is raised if contract is deployed twice
    error Deployed();

    /// @notice Error is raised if the caller is unauthorized
    error Unauthorized();

    /// @notice Error is raised if the owner run the initialize() twice
    error Uninitialized();

    /// @notice Error is raised if rebalance is executed but leverage ratio is invalid
    error Balance();

    /// @notice Error is raised if something happen when interacting with Rari Fuse
    error FuseError(uint256 code);

    /// @notice Errors are raised if params invalid
    error InvalidLeverageRatio();
    error InvalidRebalancingStep();
    error InvalidDiscount();

    /// @notice Errors are raised if flash swap is invalid
    error InvalidFlashSwapType();
    error InvalidFlashSwapAmount();

    /// @notice Errors are raised if amountIn or amountOut is invalid
    error AmountInTooLow();
    error AmountOutTooLow();
    error AmountOutTooHigh();


    /// ███ Owner actions ████████████████████████████████████████████████████

    /**
     * @notice Update the Rise Token parameters
     * @param _minLeverageRatio Minimum leverage ratio
     * @param _maxLeverageRatio Maximum leverage ratio
     * @param _step Rebalancing step
     * @param _discount Discount for market makers to incentivize the rebalance
     * @param _maxMint Maximum mint amount
     */
    function setParams(
        uint256 _minLeverageRatio,
        uint256 _maxLeverageRatio,
        uint256 _step,
        uint256 _discount,
        uint256 _maxMint
    ) external;

    /**
     * @notice Initialize the Rise Token using debt token
     * @dev Owner must send enough debt token to the rise token contract  in
     *      order to initialize the Rise Token.
     *
     *      Required amount is defined below:
     *
     *          Given:
     *            - lr: Leverage Ratio
     *            - ca: Collateral Amount
     *            - p : Initial Price
     *
     *          Steps:
     *            1. Get `amountIn` to swap `ca` amount of collateral via
     *               uniswap v2 router.
     *            2. tcv = ca * collateral price (via oracle.totalValue)
     *            3. td = ((lr*tcv)-tcv)/lr
     *            4. amountSend = amountIn - td
     *            5. shares = amountSend / initialPrice
     *
     *          Outputs: td (Total debt), amountSend & shares
     *
     * @param _ca Initial total collateral
     * @param _da Initial total debt
     * @param _shares Initial supply of Rise Token
     */
    function initialize(uint256 _ca, uint256 _da, uint256 _shares) external;


    /// ███ Read-only functions ██████████████████████████████████████████████

    /// @notice storages
    function debt() external view returns (ERC20);
    function collateral() external view returns (ERC20);
    function fDebt() external view returns (IfERC20);
    function fCollateral() external view returns (IfERC20);
    function step() external view returns (uint256);
    function discount() external view returns (uint256);
    function totalCollateral() external view returns (uint256);
    function totalDebt() external view returns (uint256);
    function minLeverageRatio() external view returns (uint256);
    function maxLeverageRatio() external view returns (uint256);
    function maxMint() external view returns (uint256);
    function fees() external view returns (uint256);
    function oracleAdapter() external view returns (RariFusePriceOracleAdapter);
    function isInitialized() external view returns (bool);
    function factory() external view returns (FLTFactory);

    /**
     * @notice Gets the collateral and debt amount give the shares amount
     * @param _amount The shares amount
     * @return _ca Collateral amount (ex: gOHM is 1e18 precision)
     * @return _da Debt amount (ex: USDC is 1e6 precision)
     */
    function sharesToUnderlying(
        uint256 _amount
    ) external view returns (uint256 _ca, uint256 _da);

    /**
     * @notice Gets the total collateral per share
     * @return _cps Collateral per share in collateral token decimals precision
     *         (ex: gOHM is 1e18 precision)
     */
    function collateralPerShare() external view returns (uint256 _cps);

    /**
     * @notice Gets the total debt per share
     * @return _dps Debt per share in debt token decimals precision
     *         (ex: USDC is 1e6 precision)
     */
    function debtPerShare() external view returns (uint256 _dps);

    /**
     * @notice Gets the value of the Rise Token in terms of debt token
     * @param _shares The amount of Rise Token
     * @return _value The value of the Rise Token is terms of debt token
     */
    function value(uint256 _shares) external view returns (uint256 _value);

    /**
     * @notice Gets the latest price of the Rise Token in ETH base units
     * @return _price The latest price of the Rise Token
     */
    function price() external view returns (uint256 _price);

    /**
     * @notice Gets the leverage ratio of the Rise Token
     * @return _lr Leverage ratio in 1e18 precision (e.g. 2x is 2*1e18)
     */
    function leverageRatio() external view returns (uint256 _lr);


    /// ███ External functions ███████████████████████████████████████████████

    /**
     * @notice Deploy this contract
     * @dev Can be deployed once per clone
     */
    function deploy(
        address _factory,
        string memory _name,
        string memory _symbol,
        bytes  memory _data
    ) external;

    /**
     * @notice Increase allowance at once
     */
    function increaseAllowance() external;

    /// @notice callbacks
    function uniswapV2Call(address,uint256,uint256,bytes memory) external;
    function pancakeCall(address,uint256,uint256,bytes memory) external;


    /// ███ User actions █████████████████████████████████████████████████████

    /**
     * @notice Mint Rise Token using debt token
     * @dev This is low-level call for minting new supply of Rise Token.
     *      This function only expect the exact amount of debt token available
     *      owned by this contract at the time of minting. Otherwise the
     *      minting process will be failed.
     *
     *      This function should be called via high-level conctract such as
     *      router that dealing with swaping any token to exact amount
     *      of debt token.
     * @param _shares The amount of Rise Token to mint
     * @param _recipient The recipient of Rise Token
     * @param _refundRecipient The recipient of unused debt token
     */
    function mintd(
        uint256 _shares,
        address _recipient,
        address _refundRecipient
    ) external;

    /**
     * @notice Mint Rise Token using collateral token
     * @dev This is low-level call for minting new supply of Rise Token.
     *      This function only expect the exact amount of collateral token
     *      available owned by this contract at the time of minting. Otherwise
     *      the minting process will be failed.
     *
     *      This function should be called via high-level conctract such as
     *      router that dealing with swaping any token to exact amount
     *      of debt token.
     * @param _shares The amount of Rise Token to mint
     * @param _recipient The recipient of Rise Token
     * @param _refundRecipient The recipient of unused collateral token
     */
    function mintc(
        uint256 _shares,
        address _recipient,
        address _refundRecipient
    ) external;

    /**
     * @notice Burn Rise Token to debt token
     * @dev This is low-level call for burning new supply of Rise Token in
     *      order to get minAmountOut of debt token.
     *      This function expect the exact amount of Rise Token owned by this
     *      contract. Otherwise the function will revert.
     * @param _recipient The recipient of debt token
     * @param _minAmountOut The minimum amount of debt token
     */
    function burnd(address _recipient, uint256 _minAmountOut) external;

    /**
     * @notice Burn Rise Token to collateral token
     * @dev This is low-level call for burning new supply of Rise Token in
     *      order to get minAmountOut of collateral token.
     *      This function expect the exact amount of Rise Token owned by this
     *      contract. Otherwise the function will revert.
     * @param _recipient The recipient of collateral token
     * @param _minAmountOut The minimum amount of collateral token
     */
    function burnc(address _recipient, uint256 _minAmountOut) external;


    /// ███ Market makers ████████████████████████████████████████████████████

    /**
     * FLT is designed in such way that users get protection against
     * liquidation, while market makers are well-incentivized to execute the
     * rebalancing process.
     *
     * ===== Leveraging Up
     * When collateral (ex: gOHM) price is going up, the net-asset value of
     * Fuse Leveraged Token (ex: gOHMRISE) will going up and the leverage
     * ratio will going down.
     *
     * If leverage ratio is below specified minimum leverage ratio (ex: 1.7x),
     * Fuse Leveraged Token need to borrow more asset from Fuse (ex: USDC),
     * in order to buy more collateral then supply the collateral to Rari Fuse.
     *
     * If leverageRatio < minLeverageRatio:
     *     Rise Token want collateral (ex: gOHM)
     *     Rise Token have liquid asset (ex: USDC)
     *
     * Market makers can swap collateral (ex: gOHM) to the debt token
     * (ex: USDC) if leverage ratio below minimal Leverage ratio.
     *
     * ===== Leveraging Down
     * When collateral (ex: gOHM) price is going down, the net-asset value of
     * Fuse Leveraged Token (ex: gOHMRISE) will going down and the leverage
     * ratio  will going up.
     *
     * If leverage ratio is above specified maximum leverage ratio (ex: 2.3x),
     * Fuse Leveraged Token need to sell collateral in order to repay debt to
     * Fuse.
     *
     * If leverageRatio > maxLeverageRatio:
     *     Rise Token want liquid asset (ex: USDC)
     *     Rise Token have collateral (ex: gOHM)
     *
     * Market makers can swap debt token (ex: USDC) to collateral token
     * (ex: gOHM) if leverage ratio above maximum Leverage ratio.
     *
     * -----------
     *
     * In order to incentives the rebalancing process, FLT will give specified
     * discount price 0.6%.
     *
     * pushc: Market Makers can sell collateral +0.6% above the market price.
     *        For example: suppose the gOHM price is 2000 USDC, when Fuse
     *        Leveraged Token need to increase the leverage ratio, anyone can
     *        send 1 gOHM to Fuse Leveraged Token contract then they will
     *        receive 2000 USDC + 12 USDC in exchange.
     *
     * pushd: Market Makers can buy collateral -0.6% below the market price
     *        For example: suppose the gOHM price is 2000 USDC, when Fuse
     *        Leveraged Token need to decrease the leverage ratio, anyone can
     *        send 2000 USDC to Fuse Leveraged Token contract then they will
     *        receive 1 gOHM + 0.006 gOHM in exchange.
     *
     * In this case, market price is determined using Rari Fuse Oracle Adapter.
     *
     * ------------
     * Maximum Swap Amount
     *
     * The maximum swap amount is determined by the rebalancing step.
     *
     * Lr : Leverage ratio after rebalancing
     * L  : Current leverage ratio
     * ΔL : The rebelancing step
     *      ΔL > 0 leveraging up
     *      ΔL < 0 leveraging down
     * V  : Net asset value
     * C  : Current collateral value
     * Cr : Collateral value after rebalancing
     * D  : Current debt value
     * Dr : Debt value after rebalancing
     *
     * The rebalancing process is defined as below:
     *
     *     Lr = L + ΔL ................................................... (1)
     *
     * The leverage ratio is defined as below:
     *
     *     L  = C / V .................................................... (2)
     *     Lr = Cr / Vr .................................................. (3)
     *
     * The net asset value is defined as below:
     *
     *     V  = C - D .................................................... (4)
     *     Vr = Cr - Dr .................................................. (5)
     *
     * The net asset value before and after rebalancing should be equal.
     *
     *     V = Vr ........................................................ (6)
     *
     * Using equation above we got the debt value after rebalancing given ΔL:
     *
     *     Dr = C - D + Cr ............................................... (7)
     *     Dr = D + (ΔL * V) ............................................. (8)
     *
     * So the maximum swap amount is ΔLV.
     *     ΔL > 0 Supply collateral then borrow
     *     ΔL < 0 Repay debt and redeem collateral
     */

     /**
      * @notice Push the leverage ratio up by sending collateral token to
      *         contract.
      * @dev Anyone can execute this if leverage ratio is below minimum.
      */
    function pushc() external;

     /**
      * @notice Push the leverage ratio down by sending debt token to contract.
      * @dev Anyone can execute this if leverage ratio is below minimum.
      */
    function pushd() external;

}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/**
 * @title Uniswap V2 Pair Interface
 * @author bayu (github.com/pyk)
 */
interface IUniswapV2Pair {
    function token1() external view returns (address);
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/**
 * @title Uniswap V2 Router Interface
 * @author bayu <[email protected]> <https://github.com/pyk>
 */
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/**
 * @title Rari Fuse ERC20 Interface
 * @author bayu (github.com/pyk)
 * @dev docs: https://docs.rari.capital/fuse/#ftoken-s
 */
interface IfERC20 {
    function mint(uint256 mintAmount) external returns (uint256);
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlying(uint redeemAmount) external returns (uint256);
    function borrow(uint256 borrowAmount) external returns (uint256);
    function repayBorrow(uint256 repayAmount) external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function borrowBalanceCurrent(address account) external returns (uint256);
    function comptroller() external returns (address);
    function underlying() external returns (address);
    function balanceOfUnderlying(address account) external returns (uint256);
    function totalBorrowsCurrent() external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/**
 * @title Rari Fuse Comptroller Interface
 * @author bayu (github.com/pyk)
 * @dev docs: https://docs.rari.capital/fuse/#comptroller
 */
interface IFuseComptroller {
    function getAccountLiquidity(address account) external returns (uint256 error, uint256 liquidity, uint256 shortfall);
    function enterMarkets(address[] calldata fTokens) external returns (uint256[] memory);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { Clones } from "openzeppelin/proxy/Clones.sol";
import { Owned } from "solmate/auth/Owned.sol";

import { IFLTFactory } from "./interfaces/IFLTFactory.sol";
import { IFLT } from "./interfaces/IFLT.sol";

/**
 * @title FLT Factory
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @notice Factory contract to create new RISE or DROP token
 */
contract FLTFactory is IFLTFactory, Owned {

    /// ███ Storages █████████████████████████████████████████████████████████

    address[] public tokens;
    address   public feeRecipient;
    mapping(address => bool) public isValid;


    /// ███ Constructor ██████████████████████████████████████████████████████

    constructor(address _feeRecipient) Owned(msg.sender) {
        feeRecipient = _feeRecipient;
    }

    /// ███ Owner actions ████████████████████████████████████████████████████

    /// @inheritdoc IFLTFactory
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        if (_newRecipient == feeRecipient) revert FeeRecipientNotChanged();
        feeRecipient = _newRecipient;
        emit FeeRecipientUpdated(_newRecipient);
    }

    /// @inheritdoc IFLTFactory
    function create(
        string memory _name,
        string memory _symbol,
        bytes memory _data,
        address _implementation
    ) external onlyOwner returns (IFLT _flt) {
        // Clone implementation
        address token = Clones.clone(_implementation);

        isValid[token] = true;
        tokens.push(token);

        _flt = IFLT(token);
        _flt.deploy(address(this), _name, _symbol, _data);

        emit TokenCreated(token, _name, _symbol, _data, tokens.length);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { Ownable } from "openzeppelin/access/Ownable.sol";
import { FixedPointMathLib } from "solmate/utils/FixedPointMathLib.sol";

import { IRariFusePriceOracleAdapter } from "../interfaces/IRariFusePriceOracleAdapter.sol";
import { IRariFusePriceOracle } from "../interfaces/IRariFusePriceOracle.sol";

/**
 * @title Rari Fuse Price Oracle Adapter
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @notice Adapter for Rari Fuse Price Oracle
 */
contract RariFusePriceOracleAdapter is IRariFusePriceOracleAdapter, Ownable {

    /// ███ Libraries ████████████████████████████████████████████████████████

    using FixedPointMathLib for uint256;


    /// ███ Storages █████████████████████████████████████████████████████████

    /// @notice Map token to Rari Fuse Price oracle contract
    mapping(address => OracleMetadata) public oracles;


    /// ███ Owner actions ████████████████████████████████████████████████████

    /// @inheritdoc IRariFusePriceOracleAdapter
    function configure(
        address _token,
        address _rariFusePriceOracle,
        uint8 _decimals
    ) external onlyOwner {
        oracles[_token] = OracleMetadata({
            oracle: IRariFusePriceOracle(_rariFusePriceOracle),
            precision: 10**_decimals
        });
        emit OracleConfigured(_token, oracles[_token]);
    }


    /// ███ Read-only functions ██████████████████████████████████████████████

    /// @inheritdoc IRariFusePriceOracleAdapter
    function isConfigured(address _token) external view returns (bool) {
        if (_token == address(0)) return true;
        if (oracles[_token].precision == 0) return false;
        return true;
    }


    /// ███ Adapters █████████████████████████████████████████████████████████

    /// @inheritdoc IRariFusePriceOracleAdapter
    function price(address _token) public view returns (uint256 _price) {
        if (_token == address(0)) return 1 ether;
        if (oracles[_token].precision == 0) revert OracleNotExists(_token);
        _price = oracles[_token].oracle.price(_token);
    }

    /// @inheritdoc IRariFusePriceOracleAdapter
    function price(
        address _base,
        address _quote
    ) public view returns (uint256 _price) {
        uint256 basePriceInETH = price(_base);
        if (_quote == address(0)) return basePriceInETH;
        uint256 quotePriceInETH = price(_quote);
        uint256 priceInETH = basePriceInETH.divWadDown(quotePriceInETH);
        _price = priceInETH.mulWadDown(oracles[_quote].precision);
    }

    /// @inheritdoc IRariFusePriceOracleAdapter
    function totalValue(
        address _base,
        address _quote,
        uint256 _baseAmount
    ) external view returns (uint256 _value) {
        uint256 p = price(_base, _quote);
        if(_base == address(0)) return _baseAmount.mulWadDown(p);
        _value = _baseAmount.mulDivDown(p, oracles[_base].precision);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { IFLT } from "./IFLT.sol";

/**
 * @title FLT Factory Interface
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @notice Factory contract to create new FLT
 */
interface IFLTFactory {

    /// ███ Events ███████████████████████████████████████████████████████████

    /// @notice Event emitted when new Rise Token is created
    event TokenCreated(
        address token,
        string  name,
        string  symbol,
        bytes   data,
        uint256 totalTokens
    );

    /**
     * @notice Event emitted when feeRecipient is updated
     * @param newRecipient The new fee recipient address
     */
    event FeeRecipientUpdated(address newRecipient);


    /// ███ Errors ███████████████████████████████████████████████████████████

    /// @notice Error is raised when Fee recipient is similar with existing
    error FeeRecipientNotChanged();


    /// ███ Owner actions ████████████████████████████████████████████████████

    /**
     * @notice Sets fee recipient
     * @param _newRecipient New fee recipient
     */
    function setFeeRecipient(address _newRecipient) external;

    /// @notice Create new FLT
    function create(
        string memory _name,
        string memory _symbol,
        bytes  memory _data,
        address _implementation
    ) external returns (IFLT _token);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { IRariFusePriceOracle } from "./IRariFusePriceOracle.sol";

/**
 * @title Rari Fuse Price Oracle Adapter
 * @author bayu <[email protected]> <https://github.com/pyk>
 * @notice Adapter for Rari Fuse Price Oracle
 */
interface IRariFusePriceOracleAdapter {
    /// ███ Types ████████████████████████████████████████████████████████████

    /**
     * @notice Oracle metadata
     * @param oracle The Rari Fuse oracle
     * @param precision The token precision (e.g. USDC is 1e6)
     */
    struct OracleMetadata {
        IRariFusePriceOracle oracle;
        uint256 precision;
    }


    /// ███ Events ███████████████████████████████████████████████████████████

    /**
     * @notice Event emitted when oracle data is updated
     * @param token The ERC20 address
     * @param metadata The oracle metadata
     */
    event OracleConfigured(
        address token,
        OracleMetadata metadata
    );


    /// ███ Errors ███████████████████████████████████████████████████████████

    /// @notice Error is raised when base or quote token oracle is not exists
    error OracleNotExists(address token);


    /// ███ Owner actions ████████████████████████████████████████████████████

    /**
     * @notice Configure oracle for token
     * @param _token The ERC20 token
     * @param _rariFusePriceOracle Contract that conform IRariFusePriceOracle
     * @param _decimals The ERC20 token decimals
     */
    function configure(
        address _token,
        address _rariFusePriceOracle,
        uint8 _decimals
    ) external;


    /// ███ Read-only functions ██████████████████████████████████████████████

    /**
     * @notice Returns true if oracle for the `_token` is configured
     * @param _token The token address
     */
    function isConfigured(address _token) external view returns (bool);


    /// ███ Adapters █████████████████████████████████████████████████████████

    /**
     * @notice Gets the price of `_token` in terms of ETH (1e18 precision)
     * @param _token Token address (e.g. gOHM)
     * @return _price Price in ETH (1e18 precision)
     */
    function price(address _token) external view returns (uint256 _price);

    /**
     * @notice Gets the price of `_base` in terms of `_quote`.
     *         For example gOHM/USDC will return current price of gOHM in USDC.
     *         (1e6 precision)
     * @param _base Base token address (e.g. gOHM/XXX)
     * @param _quote Quote token address (e.g. XXX/USDC)
     * @return _price Price in quote decimals precision (e.g. USDC is 1e6)
     */
    function price(
        address _base,
        address _quote
    ) external view returns (uint256 _price);

    /**
     * @notice Gets the total value of `_baseAmount` in terms of `_quote`.
     *         For example 100 gOHM/USDC will return current price of 10 gOHM
     *         in USDC (1e6 precision).
     * @param _base Base token address (e.g. gOHM/XXX)
     * @param _quote Quote token address (e.g. XXX/USDC)
     * @param _baseAmount The amount of base token (e.g. 100 gOHM)
     * @return _value The total value in quote decimals precision (e.g. USDC is 1e6)
     */
    function totalValue(
        address _base,
        address _quote,
        uint256 _baseAmount
    ) external view returns (uint256 _value);

}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


/**
 * @title Rari Fuse Price Oracle Interface
 * @author bayu <[email protected]> <https://github.com/pyk>
 */
interface IRariFusePriceOracle {
    /**
     * @notice Gets the price in ETH of `_token`
     * @param _token ERC20 token address
     * @return _price Price in 1e18 precision
     */
    function price(address _token) external view returns (uint256 _price);
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