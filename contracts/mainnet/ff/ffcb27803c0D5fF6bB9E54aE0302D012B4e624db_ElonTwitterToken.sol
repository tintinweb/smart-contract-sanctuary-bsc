// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "solady/src/utils/FixedPointMathLib.sol";
import "solady/src/auth/OwnableRoles.sol";

import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPancakeFactory.sol";

struct TValues {
    uint256 transferAmount;
    uint256 burnFee;
    uint256 liquidityFee;
    uint256 marketingFee;
}

contract ElonTwitterToken is OwnableRoles {
    /*//////////////////////////////////////////////////////////////
                                 LIBS
    //////////////////////////////////////////////////////////////*/

    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error KingChalesInu__InvalidFee();

    error KingCharlesInu__MaxTransferAmount();

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name = "Elon Twitter Token";

    string public symbol = "ETT";

    uint8 public constant decimals = 9;

    address public marketingAddress;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private immutable INITIAL_CHAIN_ID;

    bytes32 private immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                           REFLECTION LOGIC
    //////////////////////////////////////////////////////////////*/

    IPancakeRouter02 private immutable PCS_ROUTER =
        IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public immutable PCS_PAIR;

    bool private _startTrading;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private _tTotal = 42 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX_UINT256 - (MAX_UINT256 % _tTotal));
    uint256 private _tFeeTotal;

    uint256 private _burnFee = 0.01e18;
    uint256 private _marketingFee = 0.01e18;
    uint256 private _liquidityFee = 0.02e18;

    uint256 private _numTokensSellToAddToLiquidity = 2 * 10**4 * 10**9;
    uint256 private _maxTransferAmount = 2 * 10**5 * 10**9;

    mapping(address => uint256) private _rOwned;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _noMaxTransfer;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _marketingAddress) {
        _initializeOwner(msg.sender);

        _rOwned[msg.sender] = _rTotal;

        // Create a uniswap pair for this new token
        PCS_PAIR = IPancakeFactory(PCS_ROUTER.factory()).createPair(
            address(this),
            PCS_ROUTER.WETH()
        );

        marketingAddress = _marketingAddress;

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _noMaxTransfer[msg.sender] = true;
        _noMaxTransfer[_marketingAddress] = true;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();

        emit Transfer(address(0), msg.sender, _tTotal);
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

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIER
    //////////////////////////////////////////////////////////////*/

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /*//////////////////////////////////////////////////////////////
                             ERC20
    //////////////////////////////////////////////////////////////*/

    function balanceOf(address account) public view returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        uint256 allowed = allowance[sender][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max)
            _approve(sender, msg.sender, allowed - amount);

        _transfer(sender, recipient, amount);
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        (uint256 rAmount, uint256 rTransferAmount, , , , , ) = _getValues(
            tAmount
        );

        return deductTransferFee ? rAmount : rTransferAmount;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function hasNoMaxTransfer(address account) external view returns (bool) {
        return _noMaxTransfer[account];
    }

    //to recieve BNB from PCS ROUTER when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        TValues memory tValues = _getTValues(tAmount);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rBurnFee,
            uint256 rLiquidityFee,
            uint256 rMarketingFee
        ) = _getRValues(tAmount, tValues, _getRate());
        return (
            rAmount,
            rTransferAmount,
            tValues.transferAmount,
            rBurnFee,
            rLiquidityFee,
            rMarketingFee,
            tValues.burnFee + tValues.liquidityFee + tValues.marketingFee
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (TValues memory)
    {
        uint256 burnFee = _calculateBurnFee(tAmount);
        uint256 liquidityFee = _calculateLiquidityFee(tAmount);
        uint256 marketingFee = _calculateMarketingFee(tAmount);
        return
            TValues(
                tAmount - burnFee - liquidityFee - marketingFee,
                burnFee,
                liquidityFee,
                marketingFee
            );
    }

    function _getRValues(
        uint256 tAmount,
        TValues memory tValues,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rBurnFee,
            uint256 rLiquidityFee,
            uint256 rMarketingFee
        )
    {
        rAmount = tAmount * currentRate;
        rBurnFee = tValues.burnFee * currentRate;
        rLiquidityFee = tValues.liquidityFee * currentRate;
        rMarketingFee = tValues.marketingFee * currentRate;
        rTransferAmount = rAmount - rBurnFee - rLiquidityFee - rMarketingFee;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        allowance[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (!_noMaxTransfer[from] && !_noMaxTransfer[to])
            if (amount > _maxTransferAmount)
                revert KingCharlesInu__MaxTransferAmount();

        if (from != owner() && !_startTrading) revert();

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance > _maxTransferAmount) {
            contractTokenBalance = _maxTransferAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            _numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != PCS_PAIR &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = _numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PCS_ROUTER.WETH();

        _approve(address(this), address(PCS_ROUTER), tokenAmount);

        // make the swap
        PCS_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(PCS_ROUTER), tokenAmount);

        // add the liquidity
        PCS_ROUTER.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (takeFee) {
            (
                uint256 rAmount,
                uint256 rTransferAmount,
                uint256 tTransferAmount,
                uint256 rBurnFee,
                uint256 rLiquidityFee,
                uint256 rMarketingFee,
                uint256 tAllFees
            ) = _getValues(amount);

            _rOwned[sender] -= rAmount;
            _rOwned[recipient] += rTransferAmount;

            _rOwned[address(this)] += rLiquidityFee;
            _rOwned[marketingAddress] += rMarketingFee;
            _rTotal -= rBurnFee;

            _tFeeTotal += tAllFees;

            emit Transfer(sender, recipient, tTransferAmount);
        } else {
            uint256 rAmount = amount * _getRate();

            _rOwned[sender] -= rAmount;

            unchecked {
                _rOwned[recipient] += rAmount;
            }

            emit Transfer(sender, recipient, amount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              CALCULATE FEES
    //////////////////////////////////////////////////////////////*/

    function _calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mulWadUp(_liquidityFee);
    }

    function _calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mulWadUp(_burnFee);
    }

    function _calculateMarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mulWadUp(_marketingFee);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNER
    //////////////////////////////////////////////////////////////*/

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBurnFeePercent(uint256 taxFee) external onlyOwner {
        if (taxFee > 0.05e18) revert KingChalesInu__InvalidFee();
        _burnFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        if (liquidityFee > 0.05e18) revert KingChalesInu__InvalidFee();
        _liquidityFee = liquidityFee;
    }

    function setMarketingFee(uint256 marketingFee) external onlyOwner {
        if (marketingFee > 0.05e18) revert KingChalesInu__InvalidFee();
        _marketingFee = marketingFee;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = _marketingAddress;
    }

    function setNoMaxTransfer(address account, bool state) external onlyOwner {
        _noMaxTransfer[account] = state;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function startTrading() external onlyOwner {
        _startTrading = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IPancakeRouter01.sol";

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
pragma solidity 0.8.17;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, either due to a
    /// multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The multiply-divide operation failed, either due to a
    /// multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The output is undefined, as the input is zero.
    error Log2Undefined();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                // Store the function selector of `MulWadFailed()`.
                mstore(0x00, 0xbac65e5b)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                // Store the function selector of `MulWadFailed()`.
                mstore(0x00, 0xbac65e5b)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                // Store the function selector of `DivWadFailed()`.
                mstore(0x00, 0x7c5f487d)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                // Store the function selector of `DivWadFailed()`.
                mstore(0x00, 0x7c5f487d)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is < 0.5 we return zero. This happens when
            // x <= floor(log(0.5e18) * 1e18) ~ -42e18
            if (x <= -42139678854452767551) return 0;

            // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
            // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
            if (x >= 135305999368893231589) revert ExpOverflow();

            // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5**18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2**95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // k is in the range [-61, 195].

            // Evaluate using a (6, 7)-term rational approximation.
            // p is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r should be in the range (0.09, 0.25) * 2**96.

            // We now need to multiply r by:
            // * the scale factor s = ~6.031367120.
            // * the 2**k factor from the range reduction.
            // * the 1e18 / 2**96 factor for base conversion.
            // We do this all at once, with an intermediate result in 2**213
            // basis, so the final right shift is always by a positive amount.
            r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    function lnWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            if (x <= 0) revert LnWadUndefined();

            // We want to convert x from 10**18 fixed point to 2**96 fixed point.
            // We do this by multiplying by 2**96 / 10**18. But since
            // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
            // and add ln(2**96 / 10**18) at the end.

            // Compute k = log2(x) - 96.
            int256 k;
            assembly {
                let v := x
                k := shl(7, lt(0xffffffffffffffffffffffffffffffff, v))
                k := or(k, shl(6, lt(0xffffffffffffffff, shr(k, v))))
                k := or(k, shl(5, lt(0xffffffff, shr(k, v))))

                // For the remaining 32 bits, use a De Bruijn lookup.
                // See: https://graphics.stanford.edu/~seander/bithacks.html
                v := shr(k, v)
                v := or(v, shr(1, v))
                v := or(v, shr(2, v))
                v := or(v, shr(4, v))
                v := or(v, shr(8, v))
                v := or(v, shr(16, v))

                // prettier-ignore
                k := sub(or(k, byte(shr(251, mul(v, shl(224, 0x07c4acdd))),
                    0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f)), 96)
            }

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);

            // Evaluate using a (8, 8)-term rational approximation.
            // p is made monic, we will multiply by a scale factor later.
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            // q is monic by convention.
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial is known not to have zeros in the domain.
                // No scaling required because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r is in the range (0, 0.125) * 2**96

            // Finalization, we need to:
            // * multiply by the scale factor s = 5.549…
            // * add ln(2**96 / 10**18)
            // * add k * ln(2)
            // * multiply by 10**18 / 2**96 = 5**18 >> 78

            // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
            r *= 1677202110996718588342820967067443963516166;
            // add ln(2) * k * 5e18 * 2**192
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            // add ln(2**96 / 10**18) * 5e18 * 2**192
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            // base conversion: mul 2**18 / 2**192
            r >>= 174;
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `floor(x * y / denominator)`.
    /// Reverts if `x * y` overflows, or `denominator` is zero.
    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(not(0), y)))))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), denominator)
        }
    }

    /// @dev Returns `ceil(x * y / denominator)`.
    /// Reverts if `x * y` overflows, or `denominator` is zero.
    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(not(0), y)))))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), denominator))), div(mul(x, y), denominator))
        }
    }

    /// @dev Returns `ceil(x / denominator)`.
    /// Reverts if `denominator` is zero.
    function divUp(uint256 x, uint256 denominator) internal pure returns (uint256 z) {
        assembly {
            if iszero(denominator) {
                // Store the function selector of `DivFailed()`.
                mstore(0x00, 0x65244e4e)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, denominator))), div(x, denominator))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Returns the square root of `x`.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`.
            // We check `y >= 2**(k + 8)` but shift right by `k` bits
            // each branch to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, gt(x, 0xffffffffffffffffffffffffffffffffff))
            r := or(r, shl(6, gt(shr(r, x), 0xffffffffffffffffff)))
            r := or(r, shl(5, gt(shr(r, x), 0xffffffffff)))
            r := or(r, shl(4, gt(shr(r, x), 0xffffff)))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) public pure returns (uint256 result) {
        unchecked {
            if (x < 11) {
                // prettier-ignore
                result = (0x375f0016260009d80004ec0002d00001e0000180000180000200000400001 >> (x * 22)) & 0x3fffff;
            } else if (x < 32) {
                result = 3628800;
                do {
                    result = result * x;
                    x = x - 1;
                } while (x != 10);
            } else if (x < 58) {
                // Just cheat lol.
                result = 8222838654177922817725562880000000;
                do {
                    result = result * x;
                    x = x - 1;
                } while (x != 31);
            } else {
                revert FactorialOverflow();
            }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    function log2(uint256 x) internal pure returns (uint256 r) {
        assembly {
            if iszero(x) {
                // Store the function selector of `Log2Undefined()`.
                mstore(0x00, 0x5be3aa5c)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // See: https://graphics.stanford.edu/~seander/bithacks.html
            x := shr(r, x)
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))

            // prettier-ignore
            r := or(r, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
                0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f))
        }
    }

    /// @dev Returns the averege of `x` and `y`.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(and(x, y), shr(1, xor(x, y)))
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        assembly {
            let mask := mul(shr(255, x), not(0))
            z := xor(mask, add(mask, x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        assembly {
            let a := sub(y, x)
            z := xor(a, mul(xor(a, sub(x, y)), sgt(x, y)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns gcd of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // prettier-ignore
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(
        uint256 x,
        uint256 minValue,
        uint256 maxValue
    ) internal pure returns (uint256 z) {
        return min(max(x, minValue), maxValue);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner and multiroles authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/OwnableRoles.sol)
/// @dev While the ownable portion follows [EIP-173](https://eips.ethereum.org/EIPS/eip-173)
/// for compatibility, the nomenclature for the 2-step ownership handover and roles
/// may be unique to this codebase.
abstract contract OwnableRoles {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev `bytes4(keccak256(bytes("Unauthorized()")))`.
    uint256 private constant _UNAUTHORIZED_ERROR_SELECTOR = 0x82b42900;

    /// @dev `bytes4(keccak256(bytes("NewOwnerIsZeroAddress()")))`.
    uint256 private constant _NEW_OWNER_IS_ZERO_ADDRESS_ERROR_SELECTOR = 0x7448fbae;

    /// @dev `bytes4(keccak256(bytes("NoHandoverRequest()")))`.
    uint256 private constant _NO_HANDOVER_REQUEST_ERROR_SELECTOR = 0x6f5e8818;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been cancelled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev The `user`'s roles is updated to `roles`.
    /// Each bit of `roles` represents whether the role is set.
    event RolesUpdated(address indexed user, uint256 indexed roles);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /// @dev `keccak256(bytes("RolesUpdated(address,uint256)"))`.
    uint256 private constant _ROLES_UPDATED_EVENT_SIGNATURE =
        0x715ad5ce61fc9595c7b415289d59cf203f23a94fa06f04af7e489a0a76e1fe26;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by: `not(_OWNER_SLOT_NOT)`.
    /// It is intentionally choosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    ///
    /// The role slot of `user` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
    ///     let roleSlot := keccak256(0x00, 0x20)
    /// ```
    /// This automatically ignores the upper bits of the `user` in case
    /// they are not clean, as well as keep the `keccak256` under 32-bytes.
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        assembly {
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            // Store the new value.
            sstore(ownerSlot, newOwner)
        }
    }

    /// @dev Grants the roles directly without authorization guard.
    /// Each bit of `roles` represents the role to turn on.
    function _grantRoles(address user, uint256 roles) internal virtual {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
            let roleSlot := keccak256(0x00, 0x20)
            // Load the current value and `or` it with `roles`.
            let newRoles := or(sload(roleSlot), roles)
            // Store the new value.
            sstore(roleSlot, newRoles)
            // Emit the {RolesUpdated} event.
            log3(0, 0, _ROLES_UPDATED_EVENT_SIGNATURE, shr(96, shl(96, user)), newRoles)
        }
    }

    /// @dev Removes the roles directly without authorization guard.
    /// Each bit of `roles` represents the role to turn off.
    function _removeRoles(address user, uint256 roles) internal virtual {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
            let roleSlot := keccak256(0x00, 0x20)
            // Load the current value.
            let currentRoles := sload(roleSlot)
            // Use `and` to compute the intersection of `currentRoles` and `roles`,
            // `xor` it with `currentRoles` to flip the bits in the intersection.
            let newRoles := xor(currentRoles, and(currentRoles, roles))
            // Then, store the new value.
            sstore(roleSlot, newRoles)
            // Emit the {RolesUpdated} event.
            log3(0, 0, _ROLES_UPDATED_EVENT_SIGNATURE, shr(96, shl(96, user)), newRoles)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        assembly {
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Reverts if the `newOwner` is the zero address.
            if iszero(newOwner) {
                mstore(0x00, _NEW_OWNER_IS_ZERO_ADDRESS_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, caller(), newOwner)
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), newOwner)
        }
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public virtual onlyOwner {
        assembly {
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, caller(), 0)
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), 0)
        }
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will be automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            assembly {
                // Compute and set the handover slot to 1.
                mstore(0x00, or(shl(96, caller()), _HANDOVER_SLOT_SEED))
                sstore(keccak256(0x00, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public virtual {
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x00, or(shl(96, caller()), _HANDOVER_SLOT_SEED))
            sstore(keccak256(0x00, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public virtual onlyOwner {
        assembly {
            // Clean the upper 96 bits.
            pendingOwner := shr(96, shl(96, pendingOwner))
            // Compute and set the handover slot to 0.
            mstore(0x00, or(shl(96, pendingOwner), _HANDOVER_SLOT_SEED))
            let handoverSlot := keccak256(0x00, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, _NO_HANDOVER_REQUEST_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, caller(), pendingOwner)
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), pendingOwner)
        }
    }

    /// @dev Allows the owner to grant `user` `roles`.
    /// If the `user` already has a role, then it will be an no-op for the role.
    function grantRoles(address user, uint256 roles) public virtual onlyOwner {
        _grantRoles(user, roles);
    }

    /// @dev Allows the owner to remove `user` `roles`.
    /// If the `user` does not have a role, then it will be an no-op for the role.
    function revokeRoles(address user, uint256 roles) public virtual onlyOwner {
        _removeRoles(user, roles);
    }

    /// @dev Allow the caller to remove their own roles.
    /// If the caller does not have a role, then it will be an no-op for the role.
    function renounceRoles(uint256 roles) public virtual {
        _removeRoles(msg.sender, roles);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        assembly {
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner) public view virtual returns (uint256 result) {
        assembly {
            // Compute the handover slot.
            mstore(0x00, or(shl(96, pendingOwner), _HANDOVER_SLOT_SEED))
            // Load the handover slot.
            result := sload(keccak256(0x00, 0x20))
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
    }

    /// @dev Returns whether `user` has any of `roles`.
    function hasAnyRole(address user, uint256 roles) public view virtual returns (bool result) {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
            // Load the stored value, and set the result to whether the
            // `and` intersection of the value and `roles` is not zero.
            result := iszero(iszero(and(sload(keccak256(0x00, 0x20)), roles)))
        }
    }

    /// @dev Returns whether `user` has all of `roles`.
    function hasAllRoles(address user, uint256 roles) public view virtual returns (bool result) {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
            // Whether the stored value is contains all the set bits in `roles`.
            result := eq(and(sload(keccak256(0x00, 0x20)), roles), roles)
        }
    }

    /// @dev Returns the roles of `user`.
    function rolesOf(address user) public view virtual returns (uint256 roles) {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, user), _OWNER_SLOT_NOT))
            // Load the stored value.
            roles := sload(keccak256(0x00, 0x20))
        }
    }

    /// @dev Convenience function to return a `roles` bitmap from the `ordinals`.
    /// This is meant for frontends like Etherscan, and is therefore not fully optimized.
    /// Not recommended to be called on-chain.
    function rolesFromOrdinals(uint8[] memory ordinals) public pure returns (uint256 roles) {
        assembly {
            // Skip the length slot.
            let o := add(ordinals, 0x20)
            // `shl` 5 is equivalent to multiplying by 0x20.
            let end := add(o, shl(5, mload(ordinals)))
            // prettier-ignore
            for {} iszero(eq(o, end)) { o := add(o, 0x20) } {
                roles := or(roles, shl(and(mload(o), 0xff), 1))
            }
        }
    }

    /// @dev Convenience function to return a `roles` bitmap from the `ordinals`.
    /// This is meant for frontends like Etherscan, and is therefore not fully optimized.
    /// Not recommended to be called on-chain.
    function ordinalsFromRoles(uint256 roles) public pure returns (uint8[] memory ordinals) {
        assembly {
            // Grab the pointer to the free memory.
            let ptr := add(mload(0x40), 0x20)
            // The absence of lookup tables, De Bruijn, etc., here is intentional for
            // smaller bytecode, as this function is not meant to be called on-chain.
            // prettier-ignore
            for { let i := 0 } 1 { i := add(i, 1) } {
                mstore(ptr, i)
                // `shr` 5 is equivalent to multiplying by 0x20.
                // Push back into the ordinals array if the bit is set.
                ptr := add(ptr, shl(5, and(roles, 1)))
                roles := shr(1, roles)
                // prettier-ignore
                if iszero(roles) { break }
            }
            // Set `ordinals` to the start of the free memory.
            ordinals := mload(0x40)
            // Allocate the memory.
            mstore(0x40, ptr)
            // Store the length of `ordinals`.
            mstore(ordinals, shr(5, sub(ptr, add(ordinals, 0x20))))
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, _UNAUTHORIZED_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
        _;
    }

    /// @dev Marks a function as only callable by an account with `roles`.
    modifier onlyRoles(uint256 roles) virtual {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, caller()), _OWNER_SLOT_NOT))
            // Load the stored value, and if the `and` intersection
            // of the value and `roles` is zero, revert.
            if iszero(and(sload(keccak256(0x00, 0x20)), roles)) {
                mstore(0x00, _UNAUTHORIZED_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
        _;
    }

    /// @dev Marks a function as only callable by the owner or by an account
    /// with `roles`. Checks for ownership first, then lazily checks for roles.
    modifier onlyOwnerOrRoles(uint256 roles) virtual {
        assembly {
            // If the caller is not the stored owner.
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                // Compute the role slot.
                mstore(0x00, or(shl(96, caller()), _OWNER_SLOT_NOT))
                // Load the stored value, and if the `and` intersection
                // of the value and `roles` is zero, revert.
                if iszero(and(sload(keccak256(0x00, 0x20)), roles)) {
                    mstore(0x00, _UNAUTHORIZED_ERROR_SELECTOR)
                    revert(0x1c, 0x04)
                }
            }
        }
        _;
    }

    /// @dev Marks a function as only callable by an account with `roles`
    /// or the owner. Checks for roles first, then lazily checks for ownership.
    modifier onlyRolesOrOwner(uint256 roles) virtual {
        assembly {
            // Compute the role slot.
            mstore(0x00, or(shl(96, caller()), _OWNER_SLOT_NOT))
            // Load the stored value, and if the `and` intersection
            // of the value and `roles` is zero, revert.
            if iszero(and(sload(keccak256(0x00, 0x20)), roles)) {
                // If the caller is not the stored owner.
                if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                    mstore(0x00, _UNAUTHORIZED_ERROR_SELECTOR)
                    revert(0x1c, 0x04)
                }
            }
        }
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ROLE CONSTANTS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // IYKYK

    uint256 internal constant _ROLE_0 = 1 << 0;
    uint256 internal constant _ROLE_1 = 1 << 1;
    uint256 internal constant _ROLE_2 = 1 << 2;
    uint256 internal constant _ROLE_3 = 1 << 3;
    uint256 internal constant _ROLE_4 = 1 << 4;
    uint256 internal constant _ROLE_5 = 1 << 5;
    uint256 internal constant _ROLE_6 = 1 << 6;
    uint256 internal constant _ROLE_7 = 1 << 7;
    uint256 internal constant _ROLE_8 = 1 << 8;
    uint256 internal constant _ROLE_9 = 1 << 9;
    uint256 internal constant _ROLE_10 = 1 << 10;
    uint256 internal constant _ROLE_11 = 1 << 11;
    uint256 internal constant _ROLE_12 = 1 << 12;
    uint256 internal constant _ROLE_13 = 1 << 13;
    uint256 internal constant _ROLE_14 = 1 << 14;
    uint256 internal constant _ROLE_15 = 1 << 15;
    uint256 internal constant _ROLE_16 = 1 << 16;
    uint256 internal constant _ROLE_17 = 1 << 17;
    uint256 internal constant _ROLE_18 = 1 << 18;
    uint256 internal constant _ROLE_19 = 1 << 19;
    uint256 internal constant _ROLE_20 = 1 << 20;
    uint256 internal constant _ROLE_21 = 1 << 21;
    uint256 internal constant _ROLE_22 = 1 << 22;
    uint256 internal constant _ROLE_23 = 1 << 23;
    uint256 internal constant _ROLE_24 = 1 << 24;
    uint256 internal constant _ROLE_25 = 1 << 25;
    uint256 internal constant _ROLE_26 = 1 << 26;
    uint256 internal constant _ROLE_27 = 1 << 27;
    uint256 internal constant _ROLE_28 = 1 << 28;
    uint256 internal constant _ROLE_29 = 1 << 29;
    uint256 internal constant _ROLE_30 = 1 << 30;
    uint256 internal constant _ROLE_31 = 1 << 31;
    uint256 internal constant _ROLE_32 = 1 << 32;
    uint256 internal constant _ROLE_33 = 1 << 33;
    uint256 internal constant _ROLE_34 = 1 << 34;
    uint256 internal constant _ROLE_35 = 1 << 35;
    uint256 internal constant _ROLE_36 = 1 << 36;
    uint256 internal constant _ROLE_37 = 1 << 37;
    uint256 internal constant _ROLE_38 = 1 << 38;
    uint256 internal constant _ROLE_39 = 1 << 39;
    uint256 internal constant _ROLE_40 = 1 << 40;
    uint256 internal constant _ROLE_41 = 1 << 41;
    uint256 internal constant _ROLE_42 = 1 << 42;
    uint256 internal constant _ROLE_43 = 1 << 43;
    uint256 internal constant _ROLE_44 = 1 << 44;
    uint256 internal constant _ROLE_45 = 1 << 45;
    uint256 internal constant _ROLE_46 = 1 << 46;
    uint256 internal constant _ROLE_47 = 1 << 47;
    uint256 internal constant _ROLE_48 = 1 << 48;
    uint256 internal constant _ROLE_49 = 1 << 49;
    uint256 internal constant _ROLE_50 = 1 << 50;
    uint256 internal constant _ROLE_51 = 1 << 51;
    uint256 internal constant _ROLE_52 = 1 << 52;
    uint256 internal constant _ROLE_53 = 1 << 53;
    uint256 internal constant _ROLE_54 = 1 << 54;
    uint256 internal constant _ROLE_55 = 1 << 55;
    uint256 internal constant _ROLE_56 = 1 << 56;
    uint256 internal constant _ROLE_57 = 1 << 57;
    uint256 internal constant _ROLE_58 = 1 << 58;
    uint256 internal constant _ROLE_59 = 1 << 59;
    uint256 internal constant _ROLE_60 = 1 << 60;
    uint256 internal constant _ROLE_61 = 1 << 61;
    uint256 internal constant _ROLE_62 = 1 << 62;
    uint256 internal constant _ROLE_63 = 1 << 63;
    uint256 internal constant _ROLE_64 = 1 << 64;
    uint256 internal constant _ROLE_65 = 1 << 65;
    uint256 internal constant _ROLE_66 = 1 << 66;
    uint256 internal constant _ROLE_67 = 1 << 67;
    uint256 internal constant _ROLE_68 = 1 << 68;
    uint256 internal constant _ROLE_69 = 1 << 69;
    uint256 internal constant _ROLE_70 = 1 << 70;
    uint256 internal constant _ROLE_71 = 1 << 71;
    uint256 internal constant _ROLE_72 = 1 << 72;
    uint256 internal constant _ROLE_73 = 1 << 73;
    uint256 internal constant _ROLE_74 = 1 << 74;
    uint256 internal constant _ROLE_75 = 1 << 75;
    uint256 internal constant _ROLE_76 = 1 << 76;
    uint256 internal constant _ROLE_77 = 1 << 77;
    uint256 internal constant _ROLE_78 = 1 << 78;
    uint256 internal constant _ROLE_79 = 1 << 79;
    uint256 internal constant _ROLE_80 = 1 << 80;
    uint256 internal constant _ROLE_81 = 1 << 81;
    uint256 internal constant _ROLE_82 = 1 << 82;
    uint256 internal constant _ROLE_83 = 1 << 83;
    uint256 internal constant _ROLE_84 = 1 << 84;
    uint256 internal constant _ROLE_85 = 1 << 85;
    uint256 internal constant _ROLE_86 = 1 << 86;
    uint256 internal constant _ROLE_87 = 1 << 87;
    uint256 internal constant _ROLE_88 = 1 << 88;
    uint256 internal constant _ROLE_89 = 1 << 89;
    uint256 internal constant _ROLE_90 = 1 << 90;
    uint256 internal constant _ROLE_91 = 1 << 91;
    uint256 internal constant _ROLE_92 = 1 << 92;
    uint256 internal constant _ROLE_93 = 1 << 93;
    uint256 internal constant _ROLE_94 = 1 << 94;
    uint256 internal constant _ROLE_95 = 1 << 95;
    uint256 internal constant _ROLE_96 = 1 << 96;
    uint256 internal constant _ROLE_97 = 1 << 97;
    uint256 internal constant _ROLE_98 = 1 << 98;
    uint256 internal constant _ROLE_99 = 1 << 99;
    uint256 internal constant _ROLE_100 = 1 << 100;
    uint256 internal constant _ROLE_101 = 1 << 101;
    uint256 internal constant _ROLE_102 = 1 << 102;
    uint256 internal constant _ROLE_103 = 1 << 103;
    uint256 internal constant _ROLE_104 = 1 << 104;
    uint256 internal constant _ROLE_105 = 1 << 105;
    uint256 internal constant _ROLE_106 = 1 << 106;
    uint256 internal constant _ROLE_107 = 1 << 107;
    uint256 internal constant _ROLE_108 = 1 << 108;
    uint256 internal constant _ROLE_109 = 1 << 109;
    uint256 internal constant _ROLE_110 = 1 << 110;
    uint256 internal constant _ROLE_111 = 1 << 111;
    uint256 internal constant _ROLE_112 = 1 << 112;
    uint256 internal constant _ROLE_113 = 1 << 113;
    uint256 internal constant _ROLE_114 = 1 << 114;
    uint256 internal constant _ROLE_115 = 1 << 115;
    uint256 internal constant _ROLE_116 = 1 << 116;
    uint256 internal constant _ROLE_117 = 1 << 117;
    uint256 internal constant _ROLE_118 = 1 << 118;
    uint256 internal constant _ROLE_119 = 1 << 119;
    uint256 internal constant _ROLE_120 = 1 << 120;
    uint256 internal constant _ROLE_121 = 1 << 121;
    uint256 internal constant _ROLE_122 = 1 << 122;
    uint256 internal constant _ROLE_123 = 1 << 123;
    uint256 internal constant _ROLE_124 = 1 << 124;
    uint256 internal constant _ROLE_125 = 1 << 125;
    uint256 internal constant _ROLE_126 = 1 << 126;
    uint256 internal constant _ROLE_127 = 1 << 127;
    uint256 internal constant _ROLE_128 = 1 << 128;
    uint256 internal constant _ROLE_129 = 1 << 129;
    uint256 internal constant _ROLE_130 = 1 << 130;
    uint256 internal constant _ROLE_131 = 1 << 131;
    uint256 internal constant _ROLE_132 = 1 << 132;
    uint256 internal constant _ROLE_133 = 1 << 133;
    uint256 internal constant _ROLE_134 = 1 << 134;
    uint256 internal constant _ROLE_135 = 1 << 135;
    uint256 internal constant _ROLE_136 = 1 << 136;
    uint256 internal constant _ROLE_137 = 1 << 137;
    uint256 internal constant _ROLE_138 = 1 << 138;
    uint256 internal constant _ROLE_139 = 1 << 139;
    uint256 internal constant _ROLE_140 = 1 << 140;
    uint256 internal constant _ROLE_141 = 1 << 141;
    uint256 internal constant _ROLE_142 = 1 << 142;
    uint256 internal constant _ROLE_143 = 1 << 143;
    uint256 internal constant _ROLE_144 = 1 << 144;
    uint256 internal constant _ROLE_145 = 1 << 145;
    uint256 internal constant _ROLE_146 = 1 << 146;
    uint256 internal constant _ROLE_147 = 1 << 147;
    uint256 internal constant _ROLE_148 = 1 << 148;
    uint256 internal constant _ROLE_149 = 1 << 149;
    uint256 internal constant _ROLE_150 = 1 << 150;
    uint256 internal constant _ROLE_151 = 1 << 151;
    uint256 internal constant _ROLE_152 = 1 << 152;
    uint256 internal constant _ROLE_153 = 1 << 153;
    uint256 internal constant _ROLE_154 = 1 << 154;
    uint256 internal constant _ROLE_155 = 1 << 155;
    uint256 internal constant _ROLE_156 = 1 << 156;
    uint256 internal constant _ROLE_157 = 1 << 157;
    uint256 internal constant _ROLE_158 = 1 << 158;
    uint256 internal constant _ROLE_159 = 1 << 159;
    uint256 internal constant _ROLE_160 = 1 << 160;
    uint256 internal constant _ROLE_161 = 1 << 161;
    uint256 internal constant _ROLE_162 = 1 << 162;
    uint256 internal constant _ROLE_163 = 1 << 163;
    uint256 internal constant _ROLE_164 = 1 << 164;
    uint256 internal constant _ROLE_165 = 1 << 165;
    uint256 internal constant _ROLE_166 = 1 << 166;
    uint256 internal constant _ROLE_167 = 1 << 167;
    uint256 internal constant _ROLE_168 = 1 << 168;
    uint256 internal constant _ROLE_169 = 1 << 169;
    uint256 internal constant _ROLE_170 = 1 << 170;
    uint256 internal constant _ROLE_171 = 1 << 171;
    uint256 internal constant _ROLE_172 = 1 << 172;
    uint256 internal constant _ROLE_173 = 1 << 173;
    uint256 internal constant _ROLE_174 = 1 << 174;
    uint256 internal constant _ROLE_175 = 1 << 175;
    uint256 internal constant _ROLE_176 = 1 << 176;
    uint256 internal constant _ROLE_177 = 1 << 177;
    uint256 internal constant _ROLE_178 = 1 << 178;
    uint256 internal constant _ROLE_179 = 1 << 179;
    uint256 internal constant _ROLE_180 = 1 << 180;
    uint256 internal constant _ROLE_181 = 1 << 181;
    uint256 internal constant _ROLE_182 = 1 << 182;
    uint256 internal constant _ROLE_183 = 1 << 183;
    uint256 internal constant _ROLE_184 = 1 << 184;
    uint256 internal constant _ROLE_185 = 1 << 185;
    uint256 internal constant _ROLE_186 = 1 << 186;
    uint256 internal constant _ROLE_187 = 1 << 187;
    uint256 internal constant _ROLE_188 = 1 << 188;
    uint256 internal constant _ROLE_189 = 1 << 189;
    uint256 internal constant _ROLE_190 = 1 << 190;
    uint256 internal constant _ROLE_191 = 1 << 191;
    uint256 internal constant _ROLE_192 = 1 << 192;
    uint256 internal constant _ROLE_193 = 1 << 193;
    uint256 internal constant _ROLE_194 = 1 << 194;
    uint256 internal constant _ROLE_195 = 1 << 195;
    uint256 internal constant _ROLE_196 = 1 << 196;
    uint256 internal constant _ROLE_197 = 1 << 197;
    uint256 internal constant _ROLE_198 = 1 << 198;
    uint256 internal constant _ROLE_199 = 1 << 199;
    uint256 internal constant _ROLE_200 = 1 << 200;
    uint256 internal constant _ROLE_201 = 1 << 201;
    uint256 internal constant _ROLE_202 = 1 << 202;
    uint256 internal constant _ROLE_203 = 1 << 203;
    uint256 internal constant _ROLE_204 = 1 << 204;
    uint256 internal constant _ROLE_205 = 1 << 205;
    uint256 internal constant _ROLE_206 = 1 << 206;
    uint256 internal constant _ROLE_207 = 1 << 207;
    uint256 internal constant _ROLE_208 = 1 << 208;
    uint256 internal constant _ROLE_209 = 1 << 209;
    uint256 internal constant _ROLE_210 = 1 << 210;
    uint256 internal constant _ROLE_211 = 1 << 211;
    uint256 internal constant _ROLE_212 = 1 << 212;
    uint256 internal constant _ROLE_213 = 1 << 213;
    uint256 internal constant _ROLE_214 = 1 << 214;
    uint256 internal constant _ROLE_215 = 1 << 215;
    uint256 internal constant _ROLE_216 = 1 << 216;
    uint256 internal constant _ROLE_217 = 1 << 217;
    uint256 internal constant _ROLE_218 = 1 << 218;
    uint256 internal constant _ROLE_219 = 1 << 219;
    uint256 internal constant _ROLE_220 = 1 << 220;
    uint256 internal constant _ROLE_221 = 1 << 221;
    uint256 internal constant _ROLE_222 = 1 << 222;
    uint256 internal constant _ROLE_223 = 1 << 223;
    uint256 internal constant _ROLE_224 = 1 << 224;
    uint256 internal constant _ROLE_225 = 1 << 225;
    uint256 internal constant _ROLE_226 = 1 << 226;
    uint256 internal constant _ROLE_227 = 1 << 227;
    uint256 internal constant _ROLE_228 = 1 << 228;
    uint256 internal constant _ROLE_229 = 1 << 229;
    uint256 internal constant _ROLE_230 = 1 << 230;
    uint256 internal constant _ROLE_231 = 1 << 231;
    uint256 internal constant _ROLE_232 = 1 << 232;
    uint256 internal constant _ROLE_233 = 1 << 233;
    uint256 internal constant _ROLE_234 = 1 << 234;
    uint256 internal constant _ROLE_235 = 1 << 235;
    uint256 internal constant _ROLE_236 = 1 << 236;
    uint256 internal constant _ROLE_237 = 1 << 237;
    uint256 internal constant _ROLE_238 = 1 << 238;
    uint256 internal constant _ROLE_239 = 1 << 239;
    uint256 internal constant _ROLE_240 = 1 << 240;
    uint256 internal constant _ROLE_241 = 1 << 241;
    uint256 internal constant _ROLE_242 = 1 << 242;
    uint256 internal constant _ROLE_243 = 1 << 243;
    uint256 internal constant _ROLE_244 = 1 << 244;
    uint256 internal constant _ROLE_245 = 1 << 245;
    uint256 internal constant _ROLE_246 = 1 << 246;
    uint256 internal constant _ROLE_247 = 1 << 247;
    uint256 internal constant _ROLE_248 = 1 << 248;
    uint256 internal constant _ROLE_249 = 1 << 249;
    uint256 internal constant _ROLE_250 = 1 << 250;
    uint256 internal constant _ROLE_251 = 1 << 251;
    uint256 internal constant _ROLE_252 = 1 << 252;
    uint256 internal constant _ROLE_253 = 1 << 253;
    uint256 internal constant _ROLE_254 = 1 << 254;
    uint256 internal constant _ROLE_255 = 1 << 255;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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