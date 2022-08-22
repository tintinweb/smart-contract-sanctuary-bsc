pragma solidity =0.5.16;

import "./IUSDFIPair.sol";
import "./UniswapERC20.sol";
import "./Math.sol";
import "./UQ112x112.sol";
import "./IERC20.sol";
import "./IUSDFIFactory.sol";
import "./IUniswapCallee.sol";

contract USDFIPair is IUSDFIPair, UniswapERC20 {
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public protocolFeeTo;
    address public token0;
    address public token1;

    uint256 public constant FEE_DENOMINATOR = 100000; // = 100%
    uint256 public constant MAX_FEE_AMOUNT = 300; // = 0.3%
    uint256 public constant MIN_FEE_AMOUNT = 10; // = 0.01%
    uint256 public constant PROTOCOL_FEE_SHARE_MAX = 90000; // = 90%
    uint256 public constant OWNER_FEE_SHARE_MAX = 90000; // = 90%

    uint256 public feeAmount;
    uint256 public protocolFeeShare;
    uint256 public ownerFeeShare;
    address public feeTo;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "USDFIPair: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "USDFIPair: TRANSFER_FAILED"
        );
    }

    event FeeAmountUpdated(
        uint256 prevFeeAmount,
        uint256 indexed feeAmount,
        uint256 prevProtocolFeeShare,
        uint256 indexed protocolFeeShare,
        uint256 prevNewOwnerFeeShare,
        uint256 indexed ownerFeeShare
    );

    event DrainWrongToken(address indexed token, address to);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;
        feeAmount = IUSDFIFactory(factory).baseFeeAmount();
        ownerFeeShare = IUSDFIFactory(factory).baseOwnerFeeShare();
        protocolFeeShare = IUSDFIFactory(factory).baseProtocolFeeShare();
        feeTo = IUSDFIFactory(factory).baseFeeTo();
        protocolFeeTo = IUSDFIFactory(factory).baseProtocolVault();
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "USDFIPair: FORBIDDEN");
        // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        require(
            balance0 <= uint112(-1) && balance1 <= uint112(-1),
            "USDFIPair: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast +=
                uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            price1CumulativeLast +=
                uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to "ownerFeeShare" of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1)
        private
        returns (bool feeOn)
    {
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast;
        // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0).mul(_reserve1));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 d = (FEE_DENOMINATOR / ownerFeeShare).sub(1);
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.mul(d).add(rootKLast);
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply;
        // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY);
            // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "USDFIPair: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1);
        // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to)
        external
        lock
        returns (uint256 amount0, uint256 amount1)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        // gas savings
        address _token0 = token0;
        // gas savings
        address _token1 = token1;
        // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply;
        // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply;
        // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply;
        // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "USDFIPair: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1);
        // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        _swap(amount0Out, amount1Out, to, data, protocolFeeTo);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function _swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes memory data,
        address protocol
    ) internal lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "USDFIPair: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        require(
            amount0Out < reserve0 && amount1Out < reserve1,
            "USDFIPair: INSUFFICIENT_LIQUIDITY"
        );
        uint256 balance0;
        uint256 balance1;

        uint256 _feeAmount = feeAmount;
        uint256 feeDenominator = FEE_DENOMINATOR;

        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "USDFIPair: INVALID_TO"); // optimistically transfer tokens
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
            if (data.length > 0)
                IUniswapCallee(to).uniswapCall(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > reserve0 - amount0Out
            ? balance0 - (reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > reserve1 - amount1Out
            ? balance1 - (reserve1 - amount1Out)
            : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "USDFIPair: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = balance0.mul(feeDenominator).sub(
                amount0In.mul(_feeAmount)
            );
            uint256 balance1Adjusted = balance1.mul(feeDenominator).sub(
                amount1In.mul(_feeAmount)
            );
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint256(reserve0).mul(reserve1).mul(feeDenominator**2),
                "USDFIPair: K"
            );
        }
        {
            // scope for protocol fee management
            uint256 protocolInputFeeAmount = protocol != address(0)
                ? protocolFeeShare.mul(_feeAmount)
                : 0;
            if (protocolInputFeeAmount > 0) {
                if (amount0In > 0) {
                    address _token0 = token0;
                    _safeTransfer(
                        _token0,
                        protocol,
                        amount0In.mul(protocolInputFeeAmount) /
                            (feeDenominator**2)
                    );
                    balance0 = IERC20(_token0).balanceOf(address(this));
                }
                if (amount1In > 0) {
                    address _token1 = token1;
                    _safeTransfer(
                        _token1,
                        protocol,
                        amount1In.mul(protocolInputFeeAmount) /
                            (feeDenominator**2)
                    );
                    balance1 = IERC20(_token1).balanceOf(address(this));
                }
            }
        }
        _update(balance0, balance1, reserve0, reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0;
        // gas savings
        address _token1 = token1;
        // gas savings
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)).sub(reserve1)
        );
    }

    // force reserves to match balances
    function sync() external lock {
        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));
        require(
            token0Balance != 0 && token1Balance != 0,
            "USDFIPair: liquidity ratio not initialized"
        );
        _update(token0Balance, token1Balance, reserve0, reserve1);
    }

    /**
     * @dev Allow to recover token sent here by mistake
     *
     * Can only be called by factory's owner
     */
    function drainWrongToken(address token, address to) external {
        require(
            msg.sender == IUSDFIFactory(factory).owner(),
            "USDFIPair: only factory's owner"
        );
        require(token != token0 && token != token1, "USDFIPair: invalid token");
        _safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        emit DrainWrongToken(token, to);
    }

    ////////////////

    /**
     * @dev Updates the fees
     *
     * - updates the swap fees amount
     * - updates the share of fees attributed to the given protocol when a swap went through him
     * - updates the share of fees attributed to the FeeToOwner
     *
     * Can only be called by the factory's owner (feeAmountOwner)
     */
    function setFeeAmount(
        uint256 _newFeeAmount,
        uint256 _newProtocolFeeShare,
        uint256 _newOwnerFeeShare
    ) external {
        require(
            msg.sender == IUSDFIFactory(factory).feeAmountOwner(),
            "USDFIPair: only factory's feeAmountOwner"
        );
        require(
            _newFeeAmount <= MAX_FEE_AMOUNT,
            "USDFIPair: feeAmount mustn't exceed the maximum"
        );
        require(
            _newFeeAmount >= MIN_FEE_AMOUNT,
            "USDFIPair: feeAmount mustn't exceed the minimum"
        );
        uint256 prevFeeAmount = feeAmount;
        feeAmount = _newFeeAmount;

        require(
            _newProtocolFeeShare.add(_newOwnerFeeShare) < FEE_DENOMINATOR,
            "USDFIPair: fees mustn't exceed maximum (FEE_DENOMINATOR)"
        );

        require(
            _newProtocolFeeShare <= PROTOCOL_FEE_SHARE_MAX,
            "USDFIPair: protocolFeeShare mustn't exceed maximum"
        );
        uint256 prevProtocolFeeShare = protocolFeeShare;
        protocolFeeShare = _newProtocolFeeShare;

        require(
            _newOwnerFeeShare > 0,
            "USDFIPair: ownerFeeShare mustn't exceed minimum"
        );
        require(
            _newOwnerFeeShare <= OWNER_FEE_SHARE_MAX,
            "USDFIPair: ownerFeeShare mustn't exceed maximum"
        );
        uint256 prevNewOwnerFeeShare = ownerFeeShare;
        ownerFeeShare = _newOwnerFeeShare;

        emit FeeAmountUpdated(
            prevFeeAmount,
            feeAmount,
            prevProtocolFeeShare,
            protocolFeeShare,
            prevNewOwnerFeeShare,
            ownerFeeShare
        );
    }

    ////////////////

    /**
     * @dev Updates the new mintet LPs (fees) recipient
     *
     * Can only be called by the factory's owner (feeAmountOwner)
     */
    function setFeeTo(address _feeTo) external {
        require(
            msg.sender == IUSDFIFactory(factory).feeAmountOwner(),
            "USDFIPair: only factory's feeAmountOwner"
        );
        feeTo = _feeTo;
    }

    /**
     * @dev Updates the swap fees recipient
     *
     * Can only be called by the factory's owner (feeAmountOwner)
     */
    function setProtocolFeeTo(address _protocolFeeTo) external {
        require(
            msg.sender == IUSDFIFactory(factory).feeAmountOwner(),
            "USDFIPair: only factory's feeAmountOwner"
        );
        protocolFeeTo = _protocolFeeTo;
    }
}