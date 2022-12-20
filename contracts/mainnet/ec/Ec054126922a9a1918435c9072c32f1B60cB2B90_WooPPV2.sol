// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import "./interfaces/IWooracleV2.sol";
import "./interfaces/IWooPPV2.sol";
import "./interfaces/AggregatorV3Interface.sol";
import "./interfaces/IWooLendingManager.sol";

import "./libraries/TransferHelper.sol";

// OpenZeppelin contracts
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// REMOVE IT IN PROD
// import "hardhat/console.sol";

/// @title Woo pool for token swap, version 2.
/// @notice the implementation class for interface IWooPPV2, mainly for query and swap tokens.
contract WooPPV2 is Ownable, ReentrancyGuard, Pausable, IWooPPV2 {
    /* ----- Type declarations ----- */
    struct DecimalInfo {
        uint64 priceDec; // 10**(price_decimal)
        uint64 quoteDec; // 10**(quote_decimal)
        uint64 baseDec; // 10**(base_decimal)
    }

    struct TokenInfo {
        uint192 reserve; // balance reserve
        uint16 feeRate; // 1 in 100000; 10 = 1bp = 0.01%; max = 65535
    }

    /* ----- State variables ----- */
    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public unclaimedFee; // NOTE: in quote token

    // wallet address --> is admin
    mapping(address => bool) public isAdmin;

    // token address --> fee rate
    mapping(address => TokenInfo) public tokenInfos;

    /// @inheritdoc IWooPPV2
    address public immutable override quoteToken;

    IWooracleV2 public wooracle;

    address public feeAddr;

    mapping(address => IWooLendingManager) public lendManagers;

    /* ----- Modifiers ----- */

    modifier onlyAdmin() {
        require(msg.sender == owner() || isAdmin[msg.sender], "WooPPV2: !admin");
        _;
    }

    constructor(address _quoteToken) {
        quoteToken = _quoteToken;
    }

    function init(address _wooracle, address _feeAddr) external onlyOwner {
        require(address(wooracle) == address(0), "WooPPV2: INIT_INVALID");
        wooracle = IWooracleV2(_wooracle);
        feeAddr = _feeAddr;
    }

    /* ----- External Functions ----- */

    /// @inheritdoc IWooPPV2
    function tryQuery(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view override returns (uint256 toAmount) {
        if (fromToken == quoteToken) {
            toAmount = _tryQuerySellQuote(toToken, fromAmount);
        } else if (toToken == quoteToken) {
            toAmount = _tryQuerySellBase(fromToken, fromAmount);
        } else {
            (toAmount, ) = _tryQueryBaseToBase(fromToken, toToken, fromAmount);
        }
    }

    /// @inheritdoc IWooPPV2
    function query(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view override returns (uint256 toAmount) {
        if (fromToken == quoteToken) {
            toAmount = _tryQuerySellQuote(toToken, fromAmount);
        } else if (toToken == quoteToken) {
            toAmount = _tryQuerySellBase(fromToken, fromAmount);
        } else {
            uint256 swapFee;
            (toAmount, swapFee) = _tryQueryBaseToBase(fromToken, toToken, fromAmount);
            require(swapFee <= tokenInfos[quoteToken].reserve, "WooPPV2: INSUFF_QUOTE_FOR_SWAPFEE");
        }
        require(toAmount <= tokenInfos[toToken].reserve, "WooPPV2: INSUFF_BALANCE");
    }

    /// @inheritdoc IWooPPV2
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address to,
        address rebateTo
    ) external override returns (uint256 realToAmount) {
        if (fromToken == quoteToken) {
            // case 1: quoteToken --> baseToken
            realToAmount = _sellQuote(toToken, fromAmount, minToAmount, to, rebateTo);
        } else if (toToken == quoteToken) {
            // case 2: fromToken --> quoteToken
            realToAmount = _sellBase(fromToken, fromAmount, minToAmount, to, rebateTo);
        } else {
            // case 3: fromToken --> toToken (base to base)
            realToAmount = _swapBaseToBase(fromToken, toToken, fromAmount, minToAmount, to, rebateTo);
        }
    }

    /// @dev OKAY to be public method
    function claimFee() external nonReentrant {
        require(feeAddr != address(0), "WooPPV2: !feeAddr");
        uint256 amountToTransfer = unclaimedFee;
        unclaimedFee = 0;
        TransferHelper.safeTransfer(quoteToken, feeAddr, amountToTransfer);
    }

    /// @inheritdoc IWooPPV2
    /// @dev pool size = tokenInfo.reserve
    function poolSize(address token) public view override returns (uint256) {
        return tokenInfos[token].reserve;
    }

    /// @dev User pool balance (substracted unclaimed fee)
    function balance(address token) public view returns (uint256) {
        return token == quoteToken ? _rawBalance(token) - unclaimedFee : _rawBalance(token);
    }

    function decimalInfo(address baseToken) public view returns (DecimalInfo memory) {
        return
            DecimalInfo({
                priceDec: uint64(10)**(IWooracleV2(wooracle).decimals(baseToken)), // 8
                quoteDec: uint64(10)**(IERC20Metadata(quoteToken).decimals()), // 18 or 6
                baseDec: uint64(10)**(IERC20Metadata(baseToken).decimals()) // 18 or 8
            });
    }

    /* ----- Admin Functions ----- */

    function setWooracle(address _wooracle) external onlyAdmin {
        wooracle = IWooracleV2(_wooracle);
        emit WooracleUpdated(_wooracle);
    }

    function setFeeAddr(address _feeAddr) external onlyAdmin {
        feeAddr = _feeAddr;
        emit FeeAddrUpdated(_feeAddr);
    }

    function setFeeRate(address token, uint16 rate) external onlyAdmin {
        require(rate <= 1e5, "!rate");
        tokenInfos[token].feeRate = rate;
    }

    function pause() external onlyAdmin {
        super._pause();
    }

    function unpause() external onlyAdmin {
        super._unpause();
    }

    function setAdmin(address addr, bool flag) external onlyAdmin {
        require(addr != address(0), "WooPPV2: !admin");
        isAdmin[addr] = flag;
        emit AdminUpdated(addr, flag);
    }

    function deposit(address token, uint256 amount) public override nonReentrant onlyAdmin {
        uint256 balanceBefore = balance(token);
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        uint256 amountReceived = balance(token) - balanceBefore;
        require(amountReceived >= amount, "AMOUNT_INSUFF");

        tokenInfos[token].reserve = uint192(tokenInfos[token].reserve + amount);

        emit Deposit(token, msg.sender, amount);
    }

    function depositAll(address token) external onlyAdmin {
        deposit(token, IERC20(token).balanceOf(msg.sender));
    }

    function repayWeeklyLending(address wantToken) external nonReentrant onlyAdmin {
        IWooLendingManager lendManager = lendManagers[wantToken];
        lendManager.accureInterest();
        uint256 amount = lendManager.weeklyRepayment();
        address repaidToken = lendManager.want();
        if (amount > 0) {
            tokenInfos[repaidToken].reserve = uint192(tokenInfos[repaidToken].reserve - amount);
            TransferHelper.safeApprove(repaidToken, address(lendManager), amount);
            lendManager.repayWeekly();
        }
        emit Withdraw(repaidToken, address(lendManager), amount);
    }

    function withdraw(address token, uint256 amount) public nonReentrant onlyAdmin {
        require(tokenInfos[token].reserve >= amount, "WooPPV2: !amount");
        tokenInfos[token].reserve = uint192(tokenInfos[token].reserve - amount);
        TransferHelper.safeTransfer(token, owner(), amount);
        emit Withdraw(token, owner(), amount);
    }

    function withdrawAll(address token) external onlyAdmin {
        withdraw(token, poolSize(token));
    }

    function skim(address token) public nonReentrant onlyAdmin {
        TransferHelper.safeTransfer(token, owner(), balance(token) - tokenInfos[token].reserve);
    }

    function skimMulTokens(address[] memory tokens) external nonReentrant onlyAdmin {
        unchecked {
            uint256 len = tokens.length;
            for (uint256 i = 0; i < len; i++) {
                skim(tokens[i]);
            }
        }
    }

    function sync(address token) external nonReentrant onlyAdmin {
        tokenInfos[token].reserve = uint192(balance(token));
    }

    /* ----- Owner Functions ----- */

    function setLendManager(IWooLendingManager _lendManager) external onlyOwner {
        lendManagers[_lendManager.want()] = _lendManager;
        isAdmin[address(_lendManager)] = true;
        emit AdminUpdated(address(_lendManager), true);
    }

    function migrateToNewPool(address token, address newPool) external onlyOwner {
        require(token != address(0), "WooPPV2: !token");
        require(newPool != address(0), "WooPPV2: !newPool");

        tokenInfos[token].reserve = 0;

        uint256 bal = balance(token);
        TransferHelper.safeApprove(token, newPool, bal);
        WooPPV2(newPool).depositAll(token);

        emit Migrate(token, newPool, bal);
    }

    function inCaseTokenGotStuck(address stuckToken) external onlyOwner {
        if (stuckToken == ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        } else {
            uint256 amount = IERC20(stuckToken).balanceOf(address(this));
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    /* ----- Private Functions ----- */

    function _tryQuerySellBase(address baseToken, uint256 baseAmount)
        private
        view
        whenNotPaused
        returns (uint256 quoteAmount)
    {
        IWooracleV2.State memory state = IWooracleV2(wooracle).state(baseToken);
        (quoteAmount, ) = _calcQuoteAmountSellBase(baseToken, baseAmount, state);
        uint256 fee = (quoteAmount * tokenInfos[baseToken].feeRate) / 1e5;
        quoteAmount = quoteAmount - fee;
    }

    function _tryQuerySellQuote(address baseToken, uint256 quoteAmount)
        private
        view
        whenNotPaused
        returns (uint256 baseAmount)
    {
        uint256 swapFee = (quoteAmount * tokenInfos[baseToken].feeRate) / 1e5;
        quoteAmount = quoteAmount - swapFee;
        IWooracleV2.State memory state = IWooracleV2(wooracle).state(baseToken);
        (baseAmount, ) = _calcBaseAmountSellQuote(baseToken, quoteAmount, state);
    }

    function _tryQueryBaseToBase(
        address baseToken1,
        address baseToken2,
        uint256 base1Amount
    ) private view whenNotPaused returns (uint256 base2Amount, uint256 swapFee) {
        if (
            baseToken1 == address(0) || baseToken2 == address(0) || baseToken1 == quoteToken || baseToken2 == quoteToken
        ) {
            return (0, 0);
        }

        IWooracleV2.State memory state1 = IWooracleV2(wooracle).state(baseToken1);
        IWooracleV2.State memory state2 = IWooracleV2(wooracle).state(baseToken2);

        uint64 spread = _maxUInt64(state1.spread, state2.spread) / 2;
        uint16 feeRate = _maxUInt16(tokenInfos[baseToken1].feeRate, tokenInfos[baseToken2].feeRate);

        state1.spread = spread;
        state2.spread = spread;

        (uint256 quoteAmount, ) = _calcQuoteAmountSellBase(baseToken1, base1Amount, state1);

        swapFee = (quoteAmount * feeRate) / 1e5;
        quoteAmount = quoteAmount - swapFee;

        (base2Amount, ) = _calcBaseAmountSellQuote(baseToken2, quoteAmount, state2);
    }

    function _sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) private nonReentrant whenNotPaused returns (uint256 quoteAmount) {
        require(baseToken != address(0), "WooPPV2: !baseToken");
        require(to != address(0), "WooPPV2: !to");
        require(baseToken != quoteToken, "WooPPV2: baseToken==quoteToken");

        require(balance(baseToken) - tokenInfos[baseToken].reserve >= baseAmount, "WooPPV2: BASE_BALANCE_NOT_ENOUGH");

        {
            uint256 newPrice;
            IWooracleV2.State memory state = IWooracleV2(wooracle).state(baseToken);
            (quoteAmount, newPrice) = _calcQuoteAmountSellBase(baseToken, baseAmount, state);
            IWooracleV2(wooracle).postPrice(baseToken, uint128(newPrice));
            // console.log('Post new price:', newPrice, newPrice/1e8);
        }

        uint256 swapFee = (quoteAmount * tokenInfos[baseToken].feeRate) / 1e5;
        quoteAmount = quoteAmount - swapFee;
        require(quoteAmount >= minQuoteAmount, "WooPPV2: quoteAmount_LT_minQuoteAmount");

        unclaimedFee = unclaimedFee + swapFee;

        tokenInfos[baseToken].reserve = uint192(tokenInfos[baseToken].reserve + baseAmount);
        tokenInfos[quoteToken].reserve = uint192(tokenInfos[quoteToken].reserve - quoteAmount - swapFee);

        if (to != address(this)) {
            TransferHelper.safeTransfer(quoteToken, to, quoteAmount);
        }

        emit WooSwap(
            baseToken,
            quoteToken,
            baseAmount,
            quoteAmount,
            msg.sender,
            to,
            rebateTo,
            quoteAmount + swapFee,
            swapFee
        );
    }

    function _sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) private nonReentrant whenNotPaused returns (uint256 baseAmount) {
        require(baseToken != address(0), "WooPPV2: !baseToken");
        require(to != address(0), "WooPPV2: !to");
        require(baseToken != quoteToken, "WooPPV2: baseToken==quoteToken");

        require(
            balance(quoteToken) - tokenInfos[quoteToken].reserve >= quoteAmount,
            "WooPPV2: QUOTE_BALANCE_NOT_ENOUGH"
        );

        uint256 swapFee = (quoteAmount * tokenInfos[baseToken].feeRate) / 1e5;
        quoteAmount = quoteAmount - swapFee;
        unclaimedFee = unclaimedFee + swapFee;

        {
            uint256 newPrice;
            IWooracleV2.State memory state = IWooracleV2(wooracle).state(baseToken);
            (baseAmount, newPrice) = _calcBaseAmountSellQuote(baseToken, quoteAmount, state);
            IWooracleV2(wooracle).postPrice(baseToken, uint128(newPrice));
            // console.log('Post new price:', newPrice, newPrice/1e8);
            require(baseAmount >= minBaseAmount, "WooPPV2: baseAmount_LT_minBaseAmount");
        }

        tokenInfos[baseToken].reserve = uint192(tokenInfos[baseToken].reserve - baseAmount);
        tokenInfos[quoteToken].reserve = uint192(tokenInfos[quoteToken].reserve + quoteAmount);

        if (to != address(this)) {
            TransferHelper.safeTransfer(baseToken, to, baseAmount);
        }

        emit WooSwap(
            quoteToken,
            baseToken,
            quoteAmount + swapFee,
            baseAmount,
            msg.sender,
            to,
            rebateTo,
            quoteAmount + swapFee,
            swapFee
        );
    }

    function _swapBaseToBase(
        address baseToken1,
        address baseToken2,
        uint256 base1Amount,
        uint256 minBase2Amount,
        address to,
        address rebateTo
    ) private nonReentrant whenNotPaused returns (uint256 base2Amount) {
        require(baseToken1 != address(0) && baseToken1 != quoteToken, "WooPPV2: !baseToken1");
        require(baseToken2 != address(0) && baseToken2 != quoteToken, "WooPPV2: !baseToken2");
        require(to != address(0), "WooPPV2: !to");

        require(balance(baseToken1) - tokenInfos[baseToken1].reserve >= base1Amount, "WooPPV2: !BASE1_BALANCE");

        IWooracleV2.State memory state1 = IWooracleV2(wooracle).state(baseToken1);
        IWooracleV2.State memory state2 = IWooracleV2(wooracle).state(baseToken2);

        uint256 swapFee;
        uint256 quoteAmount;
        {
            uint64 spread = _maxUInt64(state1.spread, state2.spread) / 2;
            uint16 feeRate = _maxUInt16(tokenInfos[baseToken1].feeRate, tokenInfos[baseToken2].feeRate);

            state1.spread = spread;
            state2.spread = spread;

            uint256 newBase1Price;
            (quoteAmount, newBase1Price) = _calcQuoteAmountSellBase(baseToken1, base1Amount, state1);
            IWooracleV2(wooracle).postPrice(baseToken1, uint128(newBase1Price));
            // console.log('Post new base1 price:', newBase1Price, newBase1Price/1e8);

            swapFee = (quoteAmount * feeRate) / 1e5;
        }

        quoteAmount = quoteAmount - swapFee;
        unclaimedFee = unclaimedFee + swapFee;

        tokenInfos[quoteToken].reserve = uint192(tokenInfos[quoteToken].reserve - swapFee);
        tokenInfos[baseToken1].reserve = uint192(tokenInfos[baseToken1].reserve + base1Amount);

        {
            uint256 newBase2Price;
            (base2Amount, newBase2Price) = _calcBaseAmountSellQuote(baseToken2, quoteAmount, state2);
            IWooracleV2(wooracle).postPrice(baseToken2, uint128(newBase2Price));
            // console.log('Post new base2 price:', newBase2Price, newBase2Price/1e8);
            require(base2Amount >= minBase2Amount, "WooPPV2: base2Amount_LT_minBase2Amount");
        }

        tokenInfos[baseToken2].reserve = uint192(tokenInfos[baseToken2].reserve - base2Amount);

        if (to != address(this)) {
            TransferHelper.safeTransfer(baseToken2, to, base2Amount);
        }

        emit WooSwap(
            baseToken1,
            baseToken2,
            base1Amount,
            base2Amount,
            msg.sender,
            to,
            rebateTo,
            quoteAmount + swapFee,
            swapFee
        );
    }

    /// @dev Get the pool's balance of the specified token
    /// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
    /// @dev forked and curtesy by Uniswap v3 core
    function _rawBalance(address token) private view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, address(this))
        );
        require(success && data.length >= 32, "WooPPV2: !BALANCE");
        return abi.decode(data, (uint256));
    }

    function _calcQuoteAmountSellBase(
        address baseToken,
        uint256 baseAmount,
        IWooracleV2.State memory state
    ) private view returns (uint256 quoteAmount, uint256 newPrice) {
        require(state.woFeasible, "WooPPV2: !ORACLE_FEASIBLE");

        DecimalInfo memory decs = decimalInfo(baseToken);

        // quoteAmount = baseAmount * oracle.price * (1 - oracle.k * baseAmount * oracle.price - oracle.spread)
        {
            uint256 coef = uint256(1e18) -
                ((uint256(state.coeff) * baseAmount * state.price) / decs.baseDec / decs.priceDec) -
                state.spread;
            quoteAmount = (((baseAmount * decs.quoteDec * state.price) / decs.priceDec) * coef) / 1e18 / decs.baseDec;
        }

        // newPrice = oracle.price * (1 - 2 * k * oracle.price * baseAmount)
        newPrice =
            ((uint256(1e18) - (uint256(2) * state.coeff * state.price * baseAmount) / decs.priceDec / decs.baseDec) *
                state.price) /
            1e18;
    }

    function _calcBaseAmountSellQuote(
        address baseToken,
        uint256 quoteAmount,
        IWooracleV2.State memory state
    ) private view returns (uint256 baseAmount, uint256 newPrice) {
        require(state.woFeasible, "WooPPV2: !ORACLE_FEASIBLE");

        DecimalInfo memory decs = decimalInfo(baseToken);

        // baseAmount = quoteAmount / oracle.price * (1 - oracle.k * quoteAmount - oracle.spread)
        {
            uint256 coef = uint256(1e18) - (quoteAmount * state.coeff) / decs.quoteDec - state.spread;
            baseAmount = (((quoteAmount * decs.baseDec * decs.priceDec) / state.price) * coef) / 1e18 / decs.quoteDec;
        }

        // new_price = oracle.price * (1 + 2 * k * quoteAmount)
        newPrice =
            ((uint256(1e18) * decs.quoteDec + uint256(2) * state.coeff * quoteAmount) * state.price) /
            decs.quoteDec /
            1e18;
    }

    function _maxUInt16(uint16 a, uint16 b) private pure returns (uint16) {
        return a > b ? a : b;
    }

    function _maxUInt64(uint64 a, uint64 b) private pure returns (uint64) {
        return a > b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title The oracle V2 interface by Woo.Network.
/// @notice update and posted the latest price info by Woo.
interface IWooracleV2 {
    struct State {
        uint128 price;
        uint64 spread;
        uint64 coeff;
        bool woFeasible;
    }

    /// @notice Wooracle spread value
    function woSpread(address base) external view returns (uint64);

    /// @notice Wooracle coeff value
    function woCoeff(address base) external view returns (uint64);

    /// @notice Wooracle state for the specified base token
    function woState(address base) external view returns (State memory);

    /// @notice Chainlink oracle address for the specified base token
    function cloAddress(address base) external view returns (address clo);

    /// @notice ChainLink price of the base token / quote token
    function cloPrice(address base) external view returns (uint256 price, uint256 timestamp);

    /// @notice Wooracle price of the base token
    function woPrice(address base) external view returns (uint128 price, uint256 timestamp);

    /// @notice Returns Woooracle price if available, otherwise fallback to ChainLink
    function price(address base) external view returns (uint256 priceNow, bool feasible);

    /// @notice Updates the Wooracle price for the specified base token
    function postPrice(address base, uint128 newPrice) external;

    /// @notice State of the specified base token.
    function state(address base) external view returns (State memory);

    /// @notice The price decimal for the specified base token (e.g. 8)
    function decimals(address base) external view returns (uint8);

    /// @notice The quote token for calculating WooPP query price
    function quoteToken() external view returns (address);

    /// @notice last updated timestamp
    function timestamp() external view returns (uint256);

    /// @notice Flag for Wooracle price feasible
    function isWoFeasible(address base) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2022 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Interface for WooLendingManager
interface IWooLendingManager {
    function want() external returns (address);

    function repayWeekly() external returns (uint256 repaidAmount);

    function repayAll() external returns (uint256 repaidAmount);

    function repay(uint256 amount) external;

    /// @notice Borrow the fund from super charger and then deposit directly into WooPP.
    /// @param amount the borrowing amount
    function borrow(uint256 amount) external;

    function accureInterest() external;

    function weeklyRepayment() external view returns (uint256 repayAmount);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present"
    /// if they do not have data to report, instead of returning unset values
    /// which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Woo private pool for swap.
/// @notice Use this contract to directly interfact with woo's synthetic proactive
///         marketing making pool.
/// @author woo.network
interface IWooPPV2 {
    /* ----- Events ----- */

    event Deposit(address indexed token, address indexed sender, uint256 amount);
    event Withdraw(address indexed token, address indexed receiver, uint256 amount);
    event Migrate(address indexed token, address indexed receiver, uint256 amount);
    event AdminUpdated(address indexed addr, bool flag);
    event FeeAddrUpdated(address indexed newFeeAddr);
    event WooracleUpdated(address indexed newWooracle);
    event WooSwap(
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address from,
        address indexed to,
        address rebateTo,
        uint256 swapVol,
        uint256 swapFee
    );

    /* ----- External Functions ----- */

    /// @notice The quote token address (immutable).
    /// @return address of quote token
    function quoteToken() external view returns (address);

    /// @notice Gets the pool size of the specified token (swap liquidity).
    /// @param token the token address
    /// @return the pool size
    function poolSize(address token) external view returns (uint256);

    /// @notice Query the amount to swap `fromToken` to `toToken`, without checking the pool reserve balance.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @return toAmount the swapped amount of `toToken`
    function tryQuery(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @notice Query the amount to swap `fromToken` to `toToken`, with checking the pool reserve balance.
    /// @dev tx reverts when 'toToken' balance is insufficient.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @return toAmount the swapped amount of `toToken`
    function query(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @notice Swap `fromToken` to `toToken`.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @param minToAmount the minimum amount of `toToken` to receive
    /// @param to the destination address
    /// @param rebateTo the rebate address (optional, can be address ZERO)
    /// @return realToAmount the amount of toToken to receive
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address to,
        address rebateTo
    ) external returns (uint256 realToAmount);

    /// @notice Deposit the specified token into the liquidity pool of WooPPV2.
    /// @param token the token to deposit
    /// @param amount the deposit amount
    function deposit(address token, uint256 amount) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}