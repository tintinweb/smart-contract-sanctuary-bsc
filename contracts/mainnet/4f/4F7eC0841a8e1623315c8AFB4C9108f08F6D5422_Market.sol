// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IERC20BurnableMinter.sol";
import "./interfaces/IStakePool.sol";
import "./interfaces/IMarket.sol";
import "./utils/Initializer.sol";
import "./utils/DelegateGuard.sol";
import "./utils/Math.sol";

contract Market is
    Context,
    AccessControlEnumerable,
    Pausable,
    DelegateGuard,
    Initializer,
    IMarket
{
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant ADD_STABLECOIN_ROLE =
        keccak256("ADD_STABLECOIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STARTUP_ROLE = keccak256("STARTUP_ROLE");

    // Chaos token address
    IERC20BurnableMinter public override Chaos;
    // prChaos token address
    IERC20BurnableMinter public override prChaos;
    // StakePool contract address
    IStakePool public override pool;

    // target funding ratio (target/10000)
    //
    // price supporting funding(PSF) = (t - p) * (c - f) / 2
    //
    // floor supporting funding(FSF) = f * t
    //
    //                              PSF
    // current funding ratio = -------------
    //                           PSF + FSF
    //
    uint32 public override target;
    // target adjusted funding ratio (targetAdjusted/10000),
    // if the current funding ratio reaches targetAjusted, f and p will be increased to bring the funding ratio back to target
    uint32 public override targetAdjusted;
    // minimum value of target
    uint32 public override minTarget;
    // maximum value of the targetAdjusted
    uint32 public override maxTargetAdjusted;
    // step value of each raise
    uint32 public override raiseStep;
    // step value of each lower
    uint32 public override lowerStep;
    // interval of each lower
    uint32 public override lowerInterval;
    // the time when ratio was last modified
    uint256 public override latestUpdateTimestamp;

    // developer address
    address public override dev;
    // fee for buying Chaos
    uint32 public override buyFee;
    // fee for selling Chaos
    uint32 public override sellFee;

    // the slope of the price function (1/(k * 1e18))
    uint256 public override k;
    // current Chaos price
    uint256 public override c;
    // floor Chaos price
    uint256 public override f;
    // floor supply,
    // if t <= p, the price of Chaos will always be f
    uint256 public override p;
    // total worth
    uint256 public override w;
    //
    //     ^
    //   c |_____________/
    //     |            /|
    //     |           / |
    //   f |__________/  |
    //     |          |  |
    //     |          |  |
    //      ------------------>
    //                p  t

    // stablecoins that can be used to buy Chaos
    EnumerableSet.AddressSet internal stablecoinsCanBuy;
    // stablecoins that can be exchanged with Chaos
    EnumerableSet.AddressSet internal stablecoinsCanSell;
    // stablecoins decimals
    mapping(address => uint8) public override stablecoinsDecimals;

    event Buy(
        address indexed from,
        address indexed token,
        uint256 input,
        uint256 output,
        uint256 fee
    );

    event Realize(
        address indexed from,
        address indexed token,
        uint256 input,
        uint256 output
    );

    event Sell(
        address indexed from,
        address indexed token,
        uint256 input,
        uint256 output,
        uint256 fee
    );

    event Burn(address indexed user, uint256 amount);

    event Raise(address trigger, uint256 target, uint256 targetAdjusted);

    event Lower(uint256 target, uint256 targetAdjusted);

    event Adjust(uint256 c, uint256 f, uint256 p);

    event AdjustOptionsChanged(
        uint32 minTarget,
        uint32 maxTargetAdjusted,
        uint32 raiseStep,
        uint32 lowerStep,
        uint32 lowerInterval
    );

    event FeeOptionsChanged(address dev, uint32 buyFee, uint32 sellFee);

    event StablecoinsChanged(address token, bool buyOrSell, bool addOrDelete);

    modifier isStarted() {
        require(f > 0 && initialized, "Market: is not started");
        _;
    }

    modifier canBuy(address token) {
        require(stablecoinsCanBuy.contains(token), "Market: invalid buy token");
        _;
    }

    modifier canSell(address token) {
        require(
            stablecoinsCanSell.contains(token),
            "Market: invalid sell token"
        );
        _;
    }

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Chaos - Chaos token address.
     * @param _prChaos - prChaos token address.
     * @param _pool - StakePool contract addresss.
     * @param _k - Slope.
     * @param _target - Target funding ratio.
     * @param _targetAdjusted - Target adjusted funding ratio.
     * @param _manager - Manager address.
     * @param _stablecoins - Stablecoin addresses.
     */
    function constructor1(
        IERC20BurnableMinter _Chaos,
        IERC20BurnableMinter _prChaos,
        IStakePool _pool,
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted,
        address _manager,
        address[] memory _stablecoins
    ) external override isDelegateCall isUninitialized {
        minTarget = 1;
        maxTargetAdjusted = 10000;
        require(_Chaos.decimals() == 18, "Market: invalid Chaos token");
        require(_prChaos.decimals() == 18, "Market: invalid prChaos token");
        require(
            _k > 0 &&
                _target >= minTarget &&
                _targetAdjusted > _target &&
                _targetAdjusted <= maxTargetAdjusted,
            "Market: invalid constructor args"
        );
        Chaos = _Chaos;
        prChaos = _prChaos;
        pool = _pool;
        k = _k;
        target = _target;
        targetAdjusted = _targetAdjusted;
        _setupRole(MANAGER_ROLE, _manager);
        _setupRole(DEFAULT_ADMIN_ROLE, _manager);
        for (uint256 i = 0; i < _stablecoins.length; i++) {
            address token = _stablecoins[i];
            uint8 decimals = IERC20Metadata(token).decimals();
            require(decimals > 0, "Market: invalid token");
            stablecoinsCanBuy.add(token);
            stablecoinsCanSell.add(token);
            stablecoinsDecimals[token] = decimals;
            emit StablecoinsChanged(token, true, true);
            emit StablecoinsChanged(token, false, true);
        }
    }

    /**
     * @dev Startup market.
     *      The caller has STARTUP_ROLE.
     * @param _token - Initial stablecoin address
     * @param _w - Initial stablecoin worth
     * @param _t - Initial chaos total supply
     */
    function startup(
        address _token,
        uint256 _w,
        uint256 _t
    ) external override onlyRole(STARTUP_ROLE) isInitialized canBuy(_token) {
        require(raiseStep > 0, "Market: setAdjustOptions");
        require(dev != address(0), "Market: setFeeOptions");
        require(f == 0, "Market: is started");
        uint256 woth1e18 = Math.convertDecimals(
            _w,
            stablecoinsDecimals[_token],
            18
        );
        require(
            woth1e18 > 0 && _t > 0 && Chaos.totalSupply() == 0,
            "Market: invalid startup"
        );
        IERC20(_token).safeTransferFrom(_msgSender(), address(this), _w);
        Chaos.mint(_msgSender(), _t);
        w = woth1e18;
        adjustMustSucceed(_t);
    }

    /**
     * @dev Get the number of stablecoins that can buy Chaos.
     */
    function stablecoinsCanBuyLength()
        external
        view
        override
        returns (uint256)
    {
        return stablecoinsCanBuy.length();
    }

    /**
     * @dev Get the address of the stablecoin that can buy Chaos according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanBuyAt(uint256 index)
        external
        view
        override
        returns (address)
    {
        return stablecoinsCanBuy.at(index);
    }

    /**
     * @dev Get whether the token can be used to buy Chaos.
     * @param token - Token address
     */
    function stablecoinsCanBuyContains(address token)
        external
        view
        override
        returns (bool)
    {
        return stablecoinsCanBuy.contains(token);
    }

    /**
     * @dev Get the number of stablecoins that can be exchanged with Chaos.
     */
    function stablecoinsCanSellLength()
        external
        view
        override
        returns (uint256)
    {
        return stablecoinsCanSell.length();
    }

    /**
     * @dev Get the address of the stablecoin that can be exchanged with Chaos,
     *      according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanSellAt(uint256 index)
        external
        view
        override
        returns (address)
    {
        return stablecoinsCanSell.at(index);
    }

    /**
     * @dev Get whether the token can be exchanged with Chaos.
     * @param token - Token address
     */
    function stablecoinsCanSellContains(address token)
        external
        view
        override
        returns (bool)
    {
        return stablecoinsCanSell.contains(token);
    }

    /**
     * @dev Calculate current funding ratio.
     */
    function currentFundingRatio()
        public
        view
        override
        isStarted
        returns (uint256 numerator, uint256 denominator)
    {
        return currentFundingRatio(Chaos.totalSupply());
    }

    /**
     * @dev Calculate current funding ratio.
     * @param _t - Total supply
     */
    function currentFundingRatio(uint256 _t)
        internal
        view
        returns (uint256 numerator, uint256 denominator)
    {
        if (_t > p) {
            uint256 temp = _t - p;
            numerator = temp * temp;
            denominator = 2 * f * _t * k + numerator;
        } else {
            denominator = 1;
        }
    }

    /**
     * @dev Estimate adjust result.
     * @param _k - Slope
     * @param _tar - Target funding ratio
     * @param _w - Total worth
     * @param _t - Total supply
     * @return success - Whether the calculation was successful
     * @return _c - Current price
     * @return _f - Floor price
     * @return _p - Point of intersection
     */
    function estimateAdjust(
        uint256 _k,
        uint256 _tar,
        uint256 _w,
        uint256 _t
    )
        public
        pure
        override
        returns (
            bool success,
            uint256 _c,
            uint256 _f,
            uint256 _p
        )
    {
        _f = (1e18 * _w - 1e14 * _w * _tar) / _t;
        uint256 temp = Math.sqrt(2 * _tar * _w * _k * 1e14);
        if (_t >= temp) {
            _p = _t - temp;
            _c = (temp + _k * _f) / _k;
            // make sure the price is greater than 0
            if (_f > 0 && _c > _f) {
                success = true;
            }
        }
    }

    /**
     * @dev Estimate next raise price.
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches targetAdjusted
     * @return _c - The price when the funding ratio reaches targetAdjusted
     * @return _w - The total worth when the funding ratio reaches targetAdjusted
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice()
        external
        view
        override
        isStarted
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        )
    {
        return estimateRaisePrice(f, k, p, target, targetAdjusted);
    }

    /**
     * @dev Estimate raise price by input value.
     * @param _f - Floor price
     * @param _k - Slope
     * @param _p - Floor supply
     * @param _tar - Target funding ratio
     * @param _tarAdjusted - Target adjusted funding ratio
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches _tar
     * @return _c - The price when the funding ratio reaches _tar
     * @return _w - The total worth when the funding ratio reaches _tar
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice(
        uint256 _f,
        uint256 _k,
        uint256 _p,
        uint256 _tar,
        uint256 _tarAdjusted
    )
        public
        pure
        override
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        )
    {
        uint256 temp = (2 * _f * _tarAdjusted * _k) / (10000 - _tarAdjusted);
        _t = (2 * _p + temp + Math.sqrt(temp * temp + 4 * temp * _p)) / 2;
        if (_t > _p) {
            temp = _t - _p;
            _c = (temp + _k * _f) / _k;
            _w = (temp * temp + 2 * _f * _t * _k) / (2 * _k * 1e18);
            // make sure the price is greater than 0
            if (_f > 0 && _c > _f) {
                // prettier-ignore
                (success, , raisedFloorPrice, ) = estimateAdjust(_k, _tar, _w, _t);
            }
        }
    }

    /**
     * @dev Adjust will call estimateAdjust and set the result to storage,
     *      if the adjustment fails, the transaction will be reverted
     * @param _t - Total supply
     */
    function adjustMustSucceed(uint256 _t) internal {
        // update timestamp
        latestUpdateTimestamp = block.timestamp;
        // prettier-ignore
        (bool success, uint256 _c, uint256 _f, uint256 _p) = estimateAdjust(k, target, w, _t);
        require(success, "Market: adjust failed");
        c = _c;
        f = _f;
        p = _p;
        emit Adjust(_c, _f, _p);
    }

    /**
     * @dev Adjust will call estimateAdjust and set the result to storage.
     * @param _t - Total supply
     * @param _trigger - Trigger user address, if it is address(0), the rise will never be triggered
     */
    function adjustAndRaise(uint256 _t, address _trigger) internal {
        // update timestamp
        latestUpdateTimestamp = block.timestamp;
        // prettier-ignore
        (bool success, uint256 _c, uint256 _f, uint256 _p) = estimateAdjust(k, target, w, _t);
        // only update the storage data when the estimate is successful
        if (success && _f >= f) {
            c = _c;
            f = _f;
            p = _p;
            emit Adjust(_c, _f, _p);
            if (_trigger != address(0) && targetAdjusted < maxTargetAdjusted) {
                uint32 raisedStep = raiseStep;
                if (targetAdjusted + raisedStep > maxTargetAdjusted) {
                    raisedStep = maxTargetAdjusted - targetAdjusted;
                }
                if (raisedStep > 0) {
                    target += raisedStep;
                    targetAdjusted += raisedStep;
                    emit Raise(_trigger, target, targetAdjusted);
                }
            }
        }
    }

    /**
     * @dev Lower target and targetAdjusted with lowerStep.
     */
    function lowerAndAdjust() public override isStarted whenNotPaused {
        lowerAndAdjust(Chaos.totalSupply());
    }

    /**
     * @dev Lower target and targetAdjusted with lowerStep.
     * @param _t - Total supply
     */
    function lowerAndAdjust(uint256 _t) internal {
        if (block.timestamp > latestUpdateTimestamp && lowerInterval > 0) {
            uint32 loweredStep = (lowerStep *
                uint32(block.timestamp - latestUpdateTimestamp)) /
                lowerInterval;
            if (loweredStep > 0) {
                // update timestamp.
                latestUpdateTimestamp = block.timestamp;
                if (target == minTarget) {
                    // there is no need to lower ratio.
                    return;
                }
                if (target < loweredStep || target - loweredStep < minTarget) {
                    loweredStep = target - minTarget;
                }
                target -= loweredStep;
                targetAdjusted -= loweredStep;
                emit Lower(target, targetAdjusted);
                // check if we need to adjust again
                (uint256 n, uint256 d) = currentFundingRatio(_t);
                if (n * 10000 > d * targetAdjusted) {
                    adjustAndRaise(_t, address(0));
                }
            }
        }
    }

    /**
     * @dev Set market options.
     *      The caller must has MANAGER_ROLE.
     *      This function can only be called before the market is started.
     * @param _k - Slope
     * @param _target - Target funding ratio
     * @param _targetAdjusted - Target adjusted funding ratio
     */
    function setMarketOptions(
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted
    ) external override onlyRole(MANAGER_ROLE) {
        require(f == 0, "Market: is started");
        require(_k > 0, "Market: invalid slope");
        require(
            _target >= minTarget &&
                _targetAdjusted > _target &&
                _targetAdjusted <= maxTargetAdjusted,
            "Market: invalid ratio"
        );
        k = _k;
        target = _target;
        targetAdjusted = _targetAdjusted;
    }

    /**
     * @dev Set adjust options.
     *      The caller must has MANAGER_ROLE.
     * @param _minTarget - Minimum value of target
     * @param _maxTargetAdjusted - Maximum value of the targetAdjusted
     * @param _raiseStep - Step value of each raise
     * @param _lowerStep - Step value of each lower
     * @param _lowerInterval - Interval of each lower
     */
    function setAdjustOptions(
        uint32 _minTarget,
        uint32 _maxTargetAdjusted,
        uint32 _raiseStep,
        uint32 _lowerStep,
        uint32 _lowerInterval
    ) external override onlyRole(MANAGER_ROLE) {
        require(
            _minTarget > 0 && _minTarget <= target,
            "Market: invalid minTarget"
        );
        require(
            _maxTargetAdjusted <= 10000 && _maxTargetAdjusted >= targetAdjusted,
            "Market: invalid maxTargetAdjusted"
        );
        require(_raiseStep <= 10000, "Market: raiseStep is too large");
        require(_lowerStep <= 10000, "Market: lowerStep is too large");
        minTarget = _minTarget;
        maxTargetAdjusted = _maxTargetAdjusted;
        raiseStep = _raiseStep;
        lowerStep = _lowerStep;
        lowerInterval = _lowerInterval;
        emit AdjustOptionsChanged(
            _minTarget,
            _maxTargetAdjusted,
            _raiseStep,
            _lowerStep,
            _lowerInterval
        );
    }

    /**
     * @dev Set fee options.
     *      The caller must has MANAGER_ROLE.
     * @param _dev - Dev address
     * @param _buyFee - Fee for buying Chaos
     * @param _sellFee - Fee for selling Chaos
     */
    function setFeeOptions(
        address _dev,
        uint32 _buyFee,
        uint32 _sellFee
    ) external override onlyRole(MANAGER_ROLE) {
        require(_dev != address(0), "Market: zero dev address");
        require(_buyFee <= 10000, "Market: invalid buyFee");
        require(_sellFee <= 10000, "Market: invalid sellFee");
        dev = _dev;
        buyFee = _buyFee;
        sellFee = _sellFee;
        emit FeeOptionsChanged(_dev, _buyFee, _sellFee);
    }

    /**
     * @dev Add a stablecoin that can buy CHAOS.
     *      The caller must has ADD_STABLECOIN_ROLE.
     * @param token - Stablecoin address
     */
    function addBuyStablecoin(address token)
        external
        onlyRole(ADD_STABLECOIN_ROLE)
    {
        uint8 decimals = IERC20Metadata(token).decimals();
        require(decimals > 0, "Market: invalid token");
        stablecoinsDecimals[token] = decimals;
        stablecoinsCanBuy.add(token);
        emit StablecoinsChanged(token, true, true);
    }

    /**
     * @dev Manage stablecoins.
     *      Add/Delete token to/from stablecoinsCanBuy/stablecoinsCanSell.
     *      The caller must has MANAGER_ROLE.
     * @param token - Stablecoin address
     * @param buyOrSell - Buy or sell token
     * @param addOrDelete - Add or delete token
     */
    function manageStablecoins(
        address token,
        bool buyOrSell,
        bool addOrDelete
    ) external override onlyRole(MANAGER_ROLE) {
        if (addOrDelete) {
            uint8 decimals = IERC20Metadata(token).decimals();
            require(decimals > 0, "Market: invalid token");
            stablecoinsDecimals[token] = decimals;
            if (buyOrSell) {
                // we need to ensure that other stable coins will not be exchanged for air coins
                // stablecoinsCanBuy[token] = decimals;
                revert("Market: please call addBuyStablecoin!");
            } else {
                stablecoinsCanSell.add(token);
            }
        } else {
            if (buyOrSell) {
                stablecoinsCanBuy.remove(token);
            } else {
                stablecoinsCanSell.remove(token);
            }
        }
        emit StablecoinsChanged(token, buyOrSell, addOrDelete);
    }

    /**
     * @dev Estimate how much Chaos user can buy.
     * @param token - Stablecoin address
     * @param tokenWorth - Number of stablecoins
     * @return amount - Number of Chaos
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return newPrice - New Chaos price
     */
    function estimateBuy(address token, uint256 tokenWorth)
        public
        view
        override
        canBuy(token)
        isStarted
        returns (
            uint256 amount,
            uint256 fee,
            uint256 worth1e18,
            uint256 newPrice
        )
    {
        uint256 _c = c;
        uint256 _k = k;
        // convert token decimals to 18
        worth1e18 = Math.convertDecimals(
            tokenWorth,
            stablecoinsDecimals[token],
            18
        );
        uint256 a = Math.sqrt(_c * _c * _k * _k + 2 * worth1e18 * _k * 1e18);
        uint256 b = _c * _k;
        if (a > b) {
            uint256 _amount = a - b;
            uint256 _newPrice = (_c * _k + _amount) / _k;
            if (_newPrice > _c && _amount > 0) {
                amount = _amount;
                newPrice = _newPrice;
            }
        }
        // calculate developer fee
        fee = (amount * buyFee) / 10000;
        // calculate amount
        amount -= fee;
    }

    /**
     * @dev Estimate how many stablecoins will be needed to realize prChaos.
     * @param amount - Number of prChaos user want to realize
     * @param token - Stablecoin address
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     */
    function estimateRealize(uint256 amount, address token)
        public
        view
        override
        canBuy(token)
        isStarted
        returns (uint256 worth1e18, uint256 worth)
    {
        // calculate amount of stablecoins being exchanged at the floor price
        worth1e18 = (f * amount) / 1e18;
        // convert decimals
        uint8 decimals = stablecoinsDecimals[token];
        worth = Math.convertDecimalsCeil(worth1e18, 18, decimals);
        if (decimals < 18) {
            // if decimals is less than 18, drop precision
            worth1e18 = Math.convertDecimals(worth, decimals, 18);
        }
    }

    /**
     * @dev Estimate how much stablecoins user can sell.
     * @param amount - Number of Chaos user want to sell
     * @param token - Stablecoin address
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     * @return newPrice - New Chaos price
     */
    function estimateSell(uint256 amount, address token)
        public
        view
        override
        canSell(token)
        isStarted
        returns (
            uint256 fee,
            uint256 worth1e18,
            uint256 worth,
            uint256 newPrice
        )
    {
        uint256 _c = c;
        uint256 _f = f;
        uint256 _k = k;
        uint256 _t = Chaos.totalSupply();
        // calculate developer fee
        fee = (amount * sellFee) / 10000;
        // calculate amount
        amount -= fee;
        // calculate the Chaos worth that can be sold with the slope
        if (_t > p) {
            uint256 available = _t - p;
            if (available <= amount) {
                uint256 _worth = ((_f + _c) * available) / (2 * 1e18);
                newPrice = _f;
                worth1e18 += _worth;
                amount -= available;
            } else {
                uint256 _newPrice = (_c * _k - amount) / _k;
                uint256 _worth = ((_newPrice + _c) * amount) / (2 * 1e18);
                if (_newPrice < _c && _newPrice >= _f && _worth > 0) {
                    newPrice = _newPrice;
                    worth1e18 += _worth;
                }
                amount = 0;
            }
        }
        // calculate the Chaos worth that can be sold at the floor price
        if (amount > 0) {
            newPrice = _f;
            worth1e18 += (amount * _f) / 1e18;
        }
        // convert decimals
        uint8 decimals = stablecoinsDecimals[token];
        worth = Math.convertDecimals(worth1e18, 18, decimals);
        if (decimals < 18) {
            // if decimals is less than 18, drop precision
            worth1e18 = Math.convertDecimals(worth, decimals, 18);
        }
    }

    /**
     * @dev Buy Chaos.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buy(
        address token,
        uint256 tokenWorth,
        uint256 desired
    ) external override whenNotPaused returns (uint256, uint256) {
        return buyFor(token, tokenWorth, desired, _msgSender());
    }

    /**
     * @dev Buy Chaos for user.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @param user - User address
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buyFor(
        address token,
        uint256 tokenWorth,
        uint256 desired,
        address user
    ) public override whenNotPaused returns (uint256, uint256) {
        (
            uint256 amount,
            uint256 fee,
            uint256 worth1e18,
            uint256 newPrice
        ) = estimateBuy(token, tokenWorth);
        require(
            worth1e18 > 0 && amount > 0 && newPrice > 0,
            "Market: useless transaction"
        );
        require(
            amount >= desired,
            "Market: mint amount is less than desired amount"
        );
        IERC20(token).safeTransferFrom(_msgSender(), address(this), tokenWorth);
        pool.massUpdatePools();
        Chaos.mint(_msgSender(), amount);
        Chaos.mint(dev, fee);
        emit Buy(user, token, tokenWorth, amount, fee);
        // update current price
        c = newPrice;
        // cumulative total worth
        w += worth1e18;
        // if the current funding ratio reaches targetAjusted,
        // we will increase f and p to bring the funding ratio back to target,
        // otherwise we will try to lower funding ratio
        uint256 _t = Chaos.totalSupply();
        (uint256 n, uint256 d) = currentFundingRatio(_t);
        if (n * 10000 > d * targetAdjusted) {
            adjustAndRaise(_t, user);
        } else {
            lowerAndAdjust(_t);
        }
        return (amount, fee);
    }

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @return worth - The amount of stablecoins being exchanged
     */
    function realize(
        uint256 amount,
        address token,
        uint256 desired
    ) public override whenNotPaused returns (uint256) {
        return realizeFor(amount, token, desired, _msgSender());
    }

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos for user.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @param user - User address
     * @return worth - The amount of stablecoins being exchanged
     */
    function realizeFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) public override whenNotPaused returns (uint256) {
        (uint256 worth1e18, uint256 worth) = estimateRealize(amount, token);
        require(worth > 0, "Market: useless transaction");
        require(
            worth <= desired,
            "Market: worth is greater than desired worth"
        );
        IERC20(token).safeTransferFrom(_msgSender(), address(this), worth);
        prChaos.burnFrom(_msgSender(), amount);
        pool.massUpdatePools();
        Chaos.mint(_msgSender(), amount);
        emit Realize(user, token, worth, amount);
        // cumulative total worth
        w += worth1e18;
        // let p translate to the right
        p += amount;
        // try to lower funding ratio
        lowerAndAdjust();
        return worth;
    }

    /**
     * @dev Sell Chaos.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sell(
        uint256 amount,
        address token,
        uint256 desired
    ) external override whenNotPaused returns (uint256, uint256) {
        return sellFor(amount, token, desired, _msgSender());
    }

    /**
     * @dev Sell Chaos for user.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @param user - User address
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sellFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) public override whenNotPaused returns (uint256, uint256) {
        (
            uint256 fee,
            uint256 worth1e18,
            uint256 worth,
            uint256 newPrice
        ) = estimateSell(amount, token);
        require(worth > 0 && newPrice > 0, "Market: useless transaction");
        require(worth >= desired, "Market: worth is less than desired worth");
        pool.massUpdatePools();
        Chaos.burnFrom(_msgSender(), amount - fee);
        Chaos.transferFrom(_msgSender(), dev, fee);
        IERC20(token).safeTransfer(_msgSender(), worth);
        emit Sell(user, token, amount - fee, worth, fee);
        // update current price
        c = newPrice;
        // reduce total worth
        w -= worth1e18;
        // if we reach the floor price,
        // let p translate to the left
        if (newPrice == f) {
            p = Chaos.totalSupply();
        }
        // try to lower funding ratio
        lowerAndAdjust();
        return (worth, fee);
    }

    /**
     * @dev Burn Chaos.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     */
    function burn(uint256 amount) external override isStarted whenNotPaused {
        burnFor(amount, _msgSender());
    }

    /**
     * @dev Burn Chaos for user.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     * @param user - User address
     */
    function burnFor(uint256 amount, address user)
        public
        override
        isStarted
        whenNotPaused
    {
        require(amount > 0, "Market: amount is zero");
        pool.massUpdatePools();
        Chaos.burnFrom(_msgSender(), amount);
        uint256 _t = Chaos.totalSupply();
        require(_t > 0, "Market: can't burn all chaos");
        uint256 _f = f;
        uint256 _k = k;
        uint256 _w = w;
        // x = t - p
        uint256 x = Math.sqrt(2 * _w * _k * 1e18 - 2 * _f * _t * _k);
        require(x > 0, "Market: amount is too small");
        if (x < _t) {
            uint256 _c = (_f * _k + x) / _k;
            require(_c > _f, "Market: amount is too small");
            c = _c;
            p = _t - x;
        } else {
            _f = (2 * _w * _k * 1e18 - _t * _t) / (2 * _t * _k);
            uint256 _c = (_f * _k + _t) / _k;
            require(_f > f && _c > _f, "Market: burn failed");
            c = _c;
            f = _f;
            p = 0;
        }
        emit Burn(user, amount);
        // if the current funding ratio reaches targetAjusted,
        // we will increase f and p to bring the funding ratio back to target,
        // otherwise we will try to lower funding ratio
        (uint256 n, uint256 d) = currentFundingRatio(_t);
        if (n * 10000 > d * targetAdjusted) {
            adjustAndRaise(_t, user);
        } else {
            lowerAndAdjust(_t);
        }
    }

    /**
     * @dev Triggers stopped state.
     *      The caller must has MANAGER_ROLE.
     */
    function pause() external override onlyRole(MANAGER_ROLE) {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *      The caller must has MANAGER_ROLE.
     */
    function unpause() external override onlyRole(MANAGER_ROLE) {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20BurnableMinter is IERC20Metadata {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20BurnableMinter.sol";
import "./IBank.sol";

// The stakepool will mint prChaos according to the total supply of Chaos and
// then distribute it to all users according to the amount of Chaos deposited by each user.
interface IStakePool {
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of prChaoss
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. prChaoss to distribute per block.
        uint256 lastRewardBlock; // Last block number that prChaoss distribution occurs.
        uint256 accPerShare; // Accumulated prChaoss per share, times 1e12. See below.
    }

    // The Chaos token
    function Chaos() external view returns (IERC20);

    // The prChaos token
    function prChaos() external view returns (IERC20BurnableMinter);

    // The bank contract address
    function bank() external view returns (IBank);

    // Info of each pool.
    function poolInfo(uint256 index)
        external
        view
        returns (
            IERC20,
            uint256,
            uint256,
            uint256
        );

    // Info of each user that stakes LP tokens.
    function userInfo(uint256 pool, address user)
        external
        view
        returns (uint256, uint256);

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    function totalAllocPoint() external view returns (uint256);

    // Daily minted Chaos as a percentage of total supply, the value is mintPercentPerDay / 1000.
    function mintPercentPerDay() external view returns (uint32);

    // How many blocks are there in a day.
    function blocksPerDay() external view returns (uint256);

    // Developer address.
    function dev() external view returns (address);

    // Withdraw fee(Chaos).
    function withdrawFee() external view returns (uint32);

    // Mint fee(prChaos).
    function mintFee() external view returns (uint32);

    // Constructor.
    function constructor1(
        IERC20 _Chaos,
        IERC20BurnableMinter _prChaos,
        IBank _bank,
        address _owner
    ) external;

    function poolLength() external view returns (uint256);

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) external;

    // Update the given pool's prChaos allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    // Set options. Can only be called by the owner.
    function setOptions(
        uint32 _mintPercentPerDay,
        uint256 _blocksPerDay,
        address _dev,
        uint32 _withdrawFee,
        uint32 _mintFee,
        bool _withUpdate
    ) external;

    // View function to see pending prChaoss on frontend.
    function pendingRewards(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() external;

    // Deposit LP tokens to StakePool for prChaos allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Deposit LP tokens to StakePool for user for prChaos allocation.
    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    // Withdraw LP tokens from StakePool.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Claim reward.
    function claim(uint256 _pid) external;

    // Claim reward for user.
    function claimFor(uint256 _pid, address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/IAccessControlEnumerable.sol";
import "./IERC20BurnableMinter.sol";
import "./IStakePool.sol";

interface IMarket is IAccessControlEnumerable {
    function Chaos() external view returns (IERC20BurnableMinter);

    function prChaos() external view returns (IERC20BurnableMinter);

    function pool() external view returns (IStakePool);

    // target funding ratio (target/10000)
    function target() external view returns (uint32);

    // target adjusted funding ratio (targetAdjusted/10000)
    function targetAdjusted() external view returns (uint32);

    // minimum value of target
    function minTarget() external view returns (uint32);

    // maximum value of the targetAdjusted
    function maxTargetAdjusted() external view returns (uint32);

    // step value of each raise
    function raiseStep() external view returns (uint32);

    // step value of each lower
    function lowerStep() external view returns (uint32);

    // interval of each lower
    function lowerInterval() external view returns (uint32);

    // the time when ratio was last modified
    function latestUpdateTimestamp() external view returns (uint256);

    // developer address
    function dev() external view returns (address);

    // fee for buying Chaos
    function buyFee() external view returns (uint32);

    // fee for selling Chaos
    function sellFee() external view returns (uint32);

    // the slope of the price function (1/(k * 1e18))
    function k() external view returns (uint256);

    // current Chaos price
    function c() external view returns (uint256);

    // floor Chaos price
    function f() external view returns (uint256);

    // floor supply
    function p() external view returns (uint256);

    // total worth
    function w() external view returns (uint256);

    // stablecoins decimals
    function stablecoinsDecimals(address token) external view returns (uint8);

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Chaos - Chaos token address.
     * @param _prChaos - _prChaos token address.
     * @param _pool - StakePool contract addresss.
     * @param _k - Slope.
     * @param _target - Target funding ratio.
     * @param _targetAdjusted - Target adjusted funding ratio.
     * @param _manager - Manager address.
     * @param _stablecoins - Stablecoin addresses.
     */
    function constructor1(
        IERC20BurnableMinter _Chaos,
        IERC20BurnableMinter _prChaos,
        IStakePool _pool,
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted,
        address _manager,
        address[] memory _stablecoins
    ) external;

    /**
     * @dev Startup market.
     *      The caller must be owner.
     * @param _token - Initial stablecoin address
     * @param _w - Initial stablecoin worth
     * @param _t - Initial Chaos total supply
     */
    function startup(
        address _token,
        uint256 _w,
        uint256 _t
    ) external;

    /**
     * @dev Get the number of stablecoins that can buy Chaos.
     */
    function stablecoinsCanBuyLength() external view returns (uint256);

    /**
     * @dev Get the address of the stablecoin that can buy Chaos according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanBuyAt(uint256 index) external view returns (address);

    /**
     * @dev Get whether the token can be used to buy Chaos.
     * @param token - Token address
     */
    function stablecoinsCanBuyContains(address token)
        external
        view
        returns (bool);

    /**
     * @dev Get the number of stablecoins that can be exchanged with Chaos.
     */
    function stablecoinsCanSellLength() external view returns (uint256);

    /**
     * @dev Get the address of the stablecoin that can be exchanged with Chaos,
     *      according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanSellAt(uint256 index)
        external
        view
        returns (address);

    /**
     * @dev Get whether the token can be exchanged with Chaos.
     * @param token - Token address
     */
    function stablecoinsCanSellContains(address token)
        external
        view
        returns (bool);

    /**
     * @dev Calculate current funding ratio.
     */
    function currentFundingRatio()
        external
        view
        returns (uint256 numerator, uint256 denominator);

    /**
     * @dev Estimate adjust result.
     * @param _k - Slope
     * @param _tar - Target funding ratio
     * @param _w - Total worth
     * @param _t - Total supply
     * @return success - Whether the calculation was successful
     * @return _c - Current price
     * @return _f - Floor price
     * @return _p - Point of intersection
     */
    function estimateAdjust(
        uint256 _k,
        uint256 _tar,
        uint256 _w,
        uint256 _t
    )
        external
        pure
        returns (
            bool success,
            uint256 _c,
            uint256 _f,
            uint256 _p
        );

    /**
     * @dev Estimate next raise price.
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches targetAdjusted
     * @return _c - The price when the funding ratio reaches targetAdjusted
     * @return _w - The total worth when the funding ratio reaches targetAdjusted
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice()
        external
        view
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        );

    /**
     * @dev Estimate raise price by input value.
     * @param _f - Floor price
     * @param _k - Slope
     * @param _p - Floor supply
     * @param _tar - Target funding ratio
     * @param _tarAdjusted - Target adjusted funding ratio
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches _tar
     * @return _c - The price when the funding ratio reaches _tar
     * @return _w - The total worth when the funding ratio reaches _tar
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice(
        uint256 _f,
        uint256 _k,
        uint256 _p,
        uint256 _tar,
        uint256 _tarAdjusted
    )
        external
        pure
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        );

    /**
     * @dev Lower target and targetAdjusted with lowerStep.
     */
    function lowerAndAdjust() external;

    /**
     * @dev Set market options.
     *      The caller must has MANAGER_ROLE.
     *      This function can only be called before the market is started.
     * @param _k - Slope
     * @param _target - Target funding ratio
     * @param _targetAdjusted - Target adjusted funding ratio
     */
    function setMarketOptions(
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted
    ) external;

    /**
     * @dev Set adjust options.
     *      The caller must be owner.
     * @param _minTarget - Minimum value of target
     * @param _maxTargetAdjusted - Maximum value of the targetAdjusted
     * @param _raiseStep - Step value of each raise
     * @param _lowerStep - Step value of each lower
     * @param _lowerInterval - Interval of each lower
     */
    function setAdjustOptions(
        uint32 _minTarget,
        uint32 _maxTargetAdjusted,
        uint32 _raiseStep,
        uint32 _lowerStep,
        uint32 _lowerInterval
    ) external;

    /**
     * @dev Set fee options.
     *      The caller must be owner.
     * @param _dev - Dev address
     * @param _buyFee - Fee for buying Chaos
     * @param _sellFee - Fee for selling Chaos
     */
    function setFeeOptions(
        address _dev,
        uint32 _buyFee,
        uint32 _sellFee
    ) external;

    /**
     * @dev Manage stablecoins.
     *      Add/Delete token to/from stablecoinsCanBuy/stablecoinsCanSell.
     *      The caller must be owner.
     * @param token - Token address
     * @param buyOrSell - Buy or sell token
     * @param addOrDelete - Add or delete token
     */
    function manageStablecoins(
        address token,
        bool buyOrSell,
        bool addOrDelete
    ) external;

    /**
     * @dev Estimate how much Chaos user can buy.
     * @param token - Stablecoin address
     * @param tokenWorth - Number of stablecoins
     * @return amount - Number of Chaos
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return newPrice - New Chaos price
     */
    function estimateBuy(address token, uint256 tokenWorth)
        external
        view
        returns (
            uint256 amount,
            uint256 fee,
            uint256 worth1e18,
            uint256 newPrice
        );

    /**
     * @dev Estimate how many stablecoins will be needed to realize prChaos.
     * @param amount - Number of prChaos user want to realize
     * @param token - Stablecoin address
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     */
    function estimateRealize(uint256 amount, address token)
        external
        view
        returns (uint256 worth1e18, uint256 worth);

    /**
     * @dev Estimate how much stablecoins user can sell.
     * @param amount - Number of Chaos user want to sell
     * @param token - Stablecoin address
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     * @return newPrice - New Chaos price
     */
    function estimateSell(uint256 amount, address token)
        external
        view
        returns (
            uint256 fee,
            uint256 worth1e18,
            uint256 worth,
            uint256 newPrice
        );

    /**
     * @dev Buy Chaos.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buy(
        address token,
        uint256 tokenWorth,
        uint256 desired
    ) external returns (uint256, uint256);

    /**
     * @dev Buy Chaos for user.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @param user - User address
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buyFor(
        address token,
        uint256 tokenWorth,
        uint256 desired,
        address user
    ) external returns (uint256, uint256);

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @return worth - The amount of stablecoins being exchanged
     */
    function realize(
        uint256 amount,
        address token,
        uint256 desired
    ) external returns (uint256);

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos for user.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @param user - User address
     * @return worth - The amount of stablecoins being exchanged
     */
    function realizeFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) external returns (uint256);

    /**
     * @dev Sell Chaos.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sell(
        uint256 amount,
        address token,
        uint256 desired
    ) external returns (uint256, uint256);

    /**
     * @dev Sell Chaos for user.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @param user - User address
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sellFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) external returns (uint256, uint256);

    /**
     * @dev Burn Chaos.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     */
    function burn(uint256 amount) external;

    /**
     * @dev Burn Chaos for user.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     * @param user - User address
     */
    function burnFor(uint256 amount, address user) external;

    /**
     * @dev Triggers stopped state.
     *      The caller must be owner.
     */
    function pause() external;

    /**
     * @dev Returns to normal state.
     *      The caller must be owner.
     */
    function unpause() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Initializer {
    bool public initialized = false;

    modifier isUninitialized() {
        require(!initialized, "Initializer: initialized");
        _;
        initialized = true;
    }

    modifier isInitialized() {
        require(initialized, "Initializer: uninitialized");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract DelegateGuard {
    // a global variable used to determine whether it is a delegatecall
    address private immutable self = address(this);

    modifier isDelegateCall() {
        require(self != address(this), "DelegateGuard: delegate call");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Math {
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Convert value from srcDecimals to dstDecimals.
     */
    function convertDecimals(
        uint256 value,
        uint8 srcDecimals,
        uint8 dstDecimals
    ) internal pure returns (uint256 result) {
        if (srcDecimals == dstDecimals) {
            result = value;
        } else if (srcDecimals < dstDecimals) {
            result = value * (10**(dstDecimals - srcDecimals));
        } else {
            result = value / (10**(srcDecimals - dstDecimals));
        }
    }

    /**
     * @dev Convert value from srcDecimals to dstDecimals, rounded up.
     */
    function convertDecimalsCeil(
        uint256 value,
        uint8 srcDecimals,
        uint8 dstDecimals
    ) internal pure returns (uint256 result) {
        if (srcDecimals == dstDecimals) {
            result = value;
        } else if (srcDecimals < dstDecimals) {
            result = value * (10**(dstDecimals - srcDecimals));
        } else {
            uint256 temp = 10**(srcDecimals - dstDecimals);
            result = value / temp;
            if (value % temp != 0) {
                result += 1;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

import "./IERC20BurnableMinter.sol";
import "./IStakePool.sol";
import "./IMarket.sol";

interface IBank {
    // Order token address
    function Order() external view returns (IERC20BurnableMinter);

    // Market contract address
    function market() external view returns (IMarket);

    // StakePool contract address
    function pool() external view returns (IStakePool);

    // helper contract address
    function helper() external view returns (address);

    // user debt
    function debt(address user) external view returns (uint256);

    // developer address
    function dev() external view returns (address);

    // fee for borrowing Order
    function borrowFee() external view returns (uint32);

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Order - Order token address.
     * @param _market - Market contract address.
     * @param _pool - StakePool contract address.
     * @param _helper - Helper contract address.
     * @param _owner - Owner address.
     */
    function constructor1(
        IERC20BurnableMinter _Order,
        IMarket _market,
        IStakePool _pool,
        address _helper,
        address _owner
    ) external;

    /**
     * @dev Set bank options.
     *      The caller must be owner.
     * @param _dev - Developer address
     * @param _borrowFee - Fee for borrowing Order
     */
    function setOptions(address _dev, uint32 _borrowFee) external;

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     */
    function withdrawable(address user) external view returns (uint256);

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     * @param amountChaos - User staked Chaos amount
     */
    function withdrawable(address user, uint256 amountChaos)
        external
        view
        returns (uint256);

    /**
     * @dev Calculate the amount of Order that can be borrowed.
     * @param user - User address
     */
    function available(address user) external view returns (uint256);

    /**
     * @dev Borrow Order.
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrow(uint256 amount)
        external
        returns (uint256 borrowed, uint256 fee);

    /**
     * @dev Borrow Order from user and directly mint to msg.sender.
     *      The caller must be helper contract.
     * @param user - User address
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrowFrom(address user, uint256 amount)
        external
        returns (uint256 borrowed, uint256 fee);

    /**
     * @dev Repay Order.
     * @param amount - The amount of Order
     */
    function repay(uint256 amount) external;

    /**
     * @dev Triggers stopped state.
     *      The caller must be owner.
     */
    function pause() external;

    /**
     * @dev Returns to normal state.
     *      The caller must be owner.
     */
    function unpause() external;
}