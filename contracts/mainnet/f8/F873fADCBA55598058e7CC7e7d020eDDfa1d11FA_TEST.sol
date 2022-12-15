// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./interfaces/IDistribution.sol";

contract TEST is IERC20Metadata, AccessControl {
    using SafeMath for uint256;

    mapping(address => uint256) private balances;

    mapping(address => mapping(address => uint256)) private allowances;

    uint256 public override totalSupply;

    string public override name;
    string public override symbol;
    uint8 public constant override decimals = 18;

    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public token1;
    IUniswapV2Router02 public router;
    address public pair;

    mapping(address => bool) public isLpToken;
    mapping(address => bool) public excludedFromFee;
    mapping(address => bool) public excludedFromSwap;

    IDistribution public distribution;

    bool private inSwap;

    uint256 public feeCounter;
    uint256 public feeLimit;

    uint256 public burnFeeBuyRate;
    uint256 public burnFeeSellRate;
    uint256 public burnFeeTransferRate;
    address[] public burnFeeReceivers;
    uint256[] public burnFeeReceiversRate;

    uint256 public liquidityFeeBuyRate;
    uint256 public liquidityFeeSellRate;
    uint256 public liquidityFeeTransferRate;
    address[] public liquidityFeeReceivers;
    uint256[] public liquidityFeeReceiversRate;
    uint256 public liquidityFeeAmount;

    uint256 public swapFeeBuyRate;
    uint256 public swapFeeSellRate;
    uint256 public swapFeeTransferRate;
    address[] public swapFeeReceivers;
    uint256[] public swapFeeReceiversRate;
    uint256 public swapFeeAmount;

    address immutable public rewardSwapAddress;
    uint256 public rewardSellAmount;
    uint256 public rewardSellRate;
    uint256 public rewardBuyAmount;
    uint256 public rewardBuyRate;
    address[] public rewardSwapReceivers;
    uint256[] public rewardSwapReceiversRate;

    bool public enabledSwapForSell = true;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event RouterAndPairUpdated(address _router, address _pair);
    event LpTokenUpdated(address _lpToken, bool _lp);
    event TokenRecovered(address _address, uint256 _amount);
    event ExcludedFromFee(address _address, bool _isExcludedFromFee);
    event ExcludedFromSwap(address _address, bool _isExcludedFromSwap);
    event DistributionUpdated(address _distribution);
    event RewardSwapReceiversUpdated(address[] _rewardSwapReceivers, uint256[] _rewardSwapReceiversRate);
    event RewardSellRateUpdated(uint256 _rewardSellRate);
    event RewardBuyRateUpdated(uint256 _rewardBuyRate);
    event RewardsAmountReseted();
    event BuyFeesUpdated(uint256 _burnFeeBuyRate, uint256 _liquidityFeeBuyRate, uint256 _swapFeeBuyRate);
    event SellFeesUpdated(uint256 _burnFeeSellRate, uint256 _liquidityFeeSellRate, uint256 _swapFeeSellRate);
    event TransferFeesUpdated(uint256 _burnFeeTransferRate, uint256 _liquidityFeeTransferRate, uint256 _swapFeeTransferRate);
    event FeeCounterReseted();
    event FeeLimitUpdated();
    event BurnFeeReceiversUpdated(address[] _burnFeeReceivers, uint256[] _burnFeeReceiversRate);
    event LiquidityFeeReceiversUpdated(address[] _liquidityFeeReceivers, uint256[] _liquidityFeeReceiversRate);
    event LiquidityFeeReseted();
    event SwapFeeReceiversUpdated(address[] _swapFeeReceivers, uint256[] _swapFeeReceiversRate);
    event SwapFeeReseted();
    event EnabledSwapForSellUpdated(bool _enabledSwapForSell);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        IDistribution _distribution,
        address _rewardSwapAddress,
        IUniswapV2Router02 _router,
        address _token1
    ) {
        name = _name;
        symbol = _symbol;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _mint(msg.sender, _totalSupply * 10 ** 18);

        setDistribution(_distribution);

        require(_rewardSwapAddress != address(0), "zero reward swap address");
        rewardSwapAddress = _rewardSwapAddress;

        updateRouterAndPair(_router, _token1);

        setExcludedFromFee(msg.sender, true);
        setExcludedFromSwap(msg.sender, true);

        setExcludedFromFee(address(this), true);
        setExcludedFromSwap(address(this), true);
    }

    function balanceOf(address _account) public view override returns (uint256) {
        return balances[_account];
    }

    function transfer(address _recipient, uint256 _amount) external override returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint256 currentAllowance = allowances[_sender][msg.sender];
        require(currentAllowance >= _amount, "ERC20: transfer amount exceeds allowance");
        _approve(_sender, msg.sender, currentAllowance.sub(_amount));

        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool) {
        _approve(msg.sender, _spender, allowances[msg.sender][_spender].add(_addedValue));
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, _spender, currentAllowance.sub(_subtractedValue));

        return true;
    }

    function updateRouterAndPair(IUniswapV2Router02 _router, address _token1) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_token1 != address(0), "zero token1 address");

        address _pair = IUniswapV2Factory(_router.factory()).getPair(address(this), _token1);

        if (_pair == address(0)) {
            _pair = IUniswapV2Factory(_router.factory()).createPair(address(this), _token1);
        }

        router = _router;
        token1 = _token1;
        pair = _pair;
        isLpToken[pair] = true;

        emit RouterAndPairUpdated(address(_router), _token1);
    }

    function setLpToken(address _lpToken, bool _lp) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_lpToken != address(0), "BEP20: invalid LP address");
        require(_lpToken != pair, "ERC20: exclude default pair");

        isLpToken[_lpToken] = _lp;

        emit LpTokenUpdated(_lpToken, _lp);
    }

    function recoverTokens(address _address, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_address != address(this), "the token address can not be the current contract");
        IERC20(_address).transfer(msg.sender, _amount);

        emit TokenRecovered(_address, _amount);
    }

    function setExcludedFromFee(address _address, bool _isExcludedFromFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        excludedFromFee[_address] = _isExcludedFromFee;

        emit ExcludedFromFee(_address, _isExcludedFromFee);
    }

    function setExcludedFromSwap(address _address, bool _isExcludedFromSwap) public onlyRole(DEFAULT_ADMIN_ROLE) {
        excludedFromSwap[_address] = _isExcludedFromSwap;

        emit ExcludedFromSwap(_address, _isExcludedFromSwap);
    }

    function setDistribution(IDistribution _distribution) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(_distribution) != address(0), "zero distribution address");
        distribution = _distribution;

        emit DistributionUpdated(address(_distribution));
    }

    function setRewardSwapReceivers(address[] calldata _rewardSwapReceivers, uint256[] calldata _rewardSwapReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardSwapReceivers.length == _rewardSwapReceiversRate.length, "size");

        uint256 totalRate = 0;
        for (uint256 i = 0; i < _rewardSwapReceiversRate.length; i++) {
            totalRate = totalRate.add(_rewardSwapReceiversRate[i]);
        }
        require(totalRate == 10000, "rate");

        delete rewardSwapReceivers;
        delete rewardSwapReceiversRate;

        for (uint i = 0; i < _rewardSwapReceivers.length; i++) {
            rewardSwapReceivers.push(_rewardSwapReceivers[i]);
            rewardSwapReceiversRate.push(_rewardSwapReceiversRate[i]);
        }

        emit RewardSwapReceiversUpdated(_rewardSwapReceivers, _rewardSwapReceiversRate);
    }

    function setRewardSellRate(uint256 _rewardSellRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardSellRate <= 3000, "_rewardSellRate");
        // min: 0%; max: 30%
        rewardSellRate = _rewardSellRate;

        emit RewardSellRateUpdated(_rewardSellRate);
    }

    function setRewardBuyRate(uint256 _rewardBuyRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_rewardBuyRate <= 3000, "_rewardBuyRate");
        // min: 0%; max: 30%
        rewardBuyRate = _rewardBuyRate;

        emit RewardBuyRateUpdated(_rewardBuyRate);
    }

    function resetRewardsAmount() external onlyRole(DEFAULT_ADMIN_ROLE) {
        rewardSellAmount = 0;
        rewardBuyAmount = 0;

        emit RewardsAmountReseted();
    }

    function updateBuyFees(uint256 _burnFeeBuyRate, uint256 _liquidityFeeBuyRate, uint256 _swapFeeBuyRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeBuyRate.add(_liquidityFeeBuyRate).add(_swapFeeBuyRate) <= 1000, "rate");

        burnFeeBuyRate = _burnFeeBuyRate;
        liquidityFeeBuyRate = _liquidityFeeBuyRate;
        swapFeeBuyRate = _swapFeeBuyRate;

        emit BuyFeesUpdated(_burnFeeBuyRate, _liquidityFeeBuyRate, _swapFeeBuyRate);
    }

    function updateSellFees(uint256 _burnFeeSellRate, uint256 _liquidityFeeSellRate, uint256 _swapFeeSellRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeSellRate.add(_liquidityFeeSellRate).add(_swapFeeSellRate) <= 1000, "rate");

        burnFeeSellRate = _burnFeeSellRate;
        liquidityFeeSellRate = _liquidityFeeSellRate;
        swapFeeSellRate = _swapFeeSellRate;

        emit SellFeesUpdated(_burnFeeSellRate, _liquidityFeeSellRate, _swapFeeSellRate);
    }

    function updateTransferFees(uint256 _burnFeeTransferRate, uint256 _liquidityFeeTransferRate, uint256 _swapFeeTransferRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeTransferRate.add(_liquidityFeeTransferRate).add(_swapFeeTransferRate) <= 1000, "rate");

        burnFeeTransferRate = _burnFeeTransferRate;
        liquidityFeeTransferRate = _liquidityFeeTransferRate;
        swapFeeTransferRate = _swapFeeTransferRate;

        emit TransferFeesUpdated(_burnFeeTransferRate, _liquidityFeeTransferRate, _swapFeeTransferRate);
    }



    function setFeeLimit(uint256 _feeLimit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeLimit = _feeLimit;

        emit FeeLimitUpdated();
    }

    function updateBurnFeeReceivers(address[] calldata _burnFeeReceivers, uint256[] calldata _burnFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFeeReceivers.length == _burnFeeReceiversRate.length, "size");

        uint256 totalRate = 0;
        for (uint256 i = 0; i < _burnFeeReceiversRate.length; i++) {
            totalRate = totalRate.add(_burnFeeReceiversRate[i]);
        }
        require(totalRate == 10000, "rate");

        delete burnFeeReceivers;
        delete burnFeeReceiversRate;

        for (uint i = 0; i < _burnFeeReceivers.length; i++) {
            burnFeeReceivers.push(_burnFeeReceivers[i]);
            burnFeeReceiversRate.push(_burnFeeReceiversRate[i]);
        }

        emit BurnFeeReceiversUpdated(_burnFeeReceivers, _burnFeeReceiversRate);
    }

    function updateLiquidityFeeReceivers(address[] calldata _liquidityFeeReceivers, uint256[] calldata _liquidityFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_liquidityFeeReceivers.length == _liquidityFeeReceiversRate.length, "size");

        uint256 totalRate = 0;
        for (uint256 i = 0; i < _liquidityFeeReceiversRate.length; i++) {
            totalRate = totalRate.add(_liquidityFeeReceiversRate[i]);
        }
        require(totalRate == 10000, "rate");

        delete liquidityFeeReceivers;
        delete liquidityFeeReceiversRate;

        for (uint i = 0; i < _liquidityFeeReceivers.length; i++) {
            liquidityFeeReceivers.push(_liquidityFeeReceivers[i]);
            liquidityFeeReceiversRate.push(_liquidityFeeReceiversRate[i]);
        }

        emit LiquidityFeeReceiversUpdated(_liquidityFeeReceivers, _liquidityFeeReceiversRate);
    }

    function resetLiquidityFee() external onlyRole(DEFAULT_ADMIN_ROLE) {
        liquidityFeeAmount = 0;

        emit LiquidityFeeReseted();
    }

    function updateSwapFeeReceivers(address[] calldata _swapFeeReceivers, uint256[] calldata _swapFeeReceiversRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_swapFeeReceivers.length == _swapFeeReceiversRate.length, "size");

        uint256 totalRate = 0;
        for (uint256 i = 0; i < _swapFeeReceiversRate.length; i++) {
            totalRate = totalRate.add(_swapFeeReceiversRate[i]);
        }
        require(totalRate == 10000, "rate");

        delete swapFeeReceivers;
        delete swapFeeReceiversRate;

        for (uint i = 0; i < _swapFeeReceivers.length; i++) {
            swapFeeReceivers.push(_swapFeeReceivers[i]);
            swapFeeReceiversRate.push(_swapFeeReceiversRate[i]);
        }

        emit SwapFeeReceiversUpdated(_swapFeeReceivers, _swapFeeReceiversRate);
    }

    function resetSwapFee() external onlyRole(DEFAULT_ADMIN_ROLE) {
        swapFeeAmount = 0;

        emit SwapFeeReseted();
    }

    function setEnabledSwapForSell(bool _enabledSwapForSell) external onlyRole(DEFAULT_ADMIN_ROLE) {
        enabledSwapForSell = _enabledSwapForSell;

        emit EnabledSwapForSellUpdated(_enabledSwapForSell);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function burnFrom(address _account, uint256 _amount) external {
        uint256 currentAllowance = allowance(_account, msg.sender);
        require(currentAllowance >= _amount, "ERC20: burn amount exceeds allowance");
        _approve(_account, msg.sender, currentAllowance.sub(_amount));
        _burn(_account, _amount);
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(balances[_sender] >= _amount, "ERC20: transfer amount exceeds balance");

        uint256 calculatedAmount = _takeFees(_sender, _recipient, _amount);
        _transferAmount(_sender, _recipient, calculatedAmount);
    }

    function _takeFees(address _from, address _to, uint256 _amount) internal returns (uint256) {
        uint256 resultAmount = _amount;

        if (!inSwap) {

            if (
                !(excludedFromFee[_from] || excludedFromFee[_to])
            ) {

                feeCounter = feeCounter.add(1);

                uint256 burnFeeRes;
                uint256 liquidityFeeRes;
                uint256 swapFeeRes;

                if (_isBuy(_from, _to)) {
                    burnFeeRes = _calcFee(resultAmount, burnFeeBuyRate);
                    liquidityFeeRes = _calcFee(resultAmount, liquidityFeeBuyRate);
                    swapFeeRes = _calcFee(resultAmount, swapFeeBuyRate);

                    rewardBuyAmount = rewardBuyAmount.add(_calcFee(resultAmount, rewardBuyRate));
                } else if (_isSell(_from, _to)) {
                    burnFeeRes = _calcFee(resultAmount, burnFeeSellRate);
                    liquidityFeeRes = _calcFee(resultAmount, liquidityFeeSellRate);
                    swapFeeRes = _calcFee(resultAmount, swapFeeSellRate);

                    rewardSellAmount = rewardSellAmount.add(_calcFee(resultAmount, rewardSellRate));
                } else {
                    burnFeeRes = _calcFee(resultAmount, burnFeeTransferRate);
                    liquidityFeeRes = _calcFee(resultAmount, liquidityFeeTransferRate);
                    swapFeeRes = _calcFee(resultAmount, swapFeeTransferRate);
                }

                if (burnFeeRes > 0) {
                    if (burnFeeReceivers.length > 0) {
                        for (uint256 i = 0; i < burnFeeReceivers.length; i++) {
                            _transferAmount(_from, burnFeeReceivers[i], _calcFee(burnFeeRes, burnFeeReceiversRate[i]));
                        }
                    } else {
                        _transferAmount(_from, deadAddress, burnFeeRes);
                    }
                }

                if (liquidityFeeRes > 0 || swapFeeRes > 0) {
                    _transferAmount(_from, address(this), liquidityFeeRes.add(swapFeeRes));
                    liquidityFeeAmount = liquidityFeeAmount.add(liquidityFeeRes);
                    swapFeeAmount = swapFeeAmount.add(swapFeeRes);
                }

                resultAmount = resultAmount.sub(burnFeeRes).sub(liquidityFeeRes).sub(swapFeeRes);
            }

            if (
                !_isBuy(_from, _to) &&
            (!_isSell(_from, _to) || enabledSwapForSell) &&
            !(excludedFromSwap[_from] || excludedFromSwap[_to]) &&
            feeCounter >= feeLimit
            ) {
                uint256 amountToSwap = 0;


                uint256 liquidityFeeHalf = liquidityFeeAmount.div(2);
                uint256 liquidityFeeOtherHalf = liquidityFeeAmount.sub(liquidityFeeHalf);

                if (liquidityFeeOtherHalf > 0 && liquidityFeeHalf > 0) {
                    amountToSwap = amountToSwap.add(liquidityFeeHalf);
                }

                amountToSwap = amountToSwap.add(swapFeeAmount);

                uint256 rewardBuyToSwap = rewardBuyAmount.add(rewardSellAmount);
                if (
                    rewardBuyToSwap > 0 &&
                    balanceOf(rewardSwapAddress) >= rewardBuyToSwap
                ) {
                    _transferAmount(rewardSwapAddress, address(this), rewardBuyToSwap);
                    amountToSwap = amountToSwap.add(rewardBuyToSwap);
                }

                if (amountToSwap > 0) {
                    IERC20 _token1 = IERC20(token1);
                    uint256 oldToken1Balance = _token1.balanceOf(address(distribution));
                    _swapTokensForToken1(amountToSwap, address(distribution));
                    uint256 newToken1Balance = _token1.balanceOf(address(distribution));
                    uint256 token1Balance = newToken1Balance.sub(oldToken1Balance);


                    if (liquidityFeeOtherHalf > 0 && liquidityFeeHalf > 0) {
                        uint256 liquidityFeeToken1Amount = _calcFee(token1Balance, liquidityFeeHalf.mul(10000).div(amountToSwap));
                        distribution.recoverTokensFor(token1, liquidityFeeToken1Amount, address(this));

                        IERC20 _lp = IERC20(pair);
                        uint256 oldLpBalance = _lp.balanceOf(address(distribution));
                        if (liquidityFeeReceivers.length == 1) {
                            _addLiquidity(liquidityFeeOtherHalf, liquidityFeeToken1Amount, liquidityFeeReceivers[0]);
                        } else {
                            _addLiquidity(liquidityFeeOtherHalf, liquidityFeeToken1Amount, address(distribution));
                        }
                        uint256 newLpBalance = _lp.balanceOf(address(distribution));
                        uint256 lpBalance = newLpBalance.sub(oldLpBalance);

                        if (liquidityFeeReceivers.length > 1) {
                            for (uint256 i = 0; i < liquidityFeeReceivers.length; i++) {
                                distribution.recoverTokensFor(pair, _calcFee(lpBalance, liquidityFeeReceiversRate[i]), liquidityFeeReceivers[i]);
                            }
                        }
                    }

                    if (swapFeeAmount > 0) {
                        uint256 swapFeeToken1Amount = _calcFee(token1Balance, swapFeeAmount.mul(10000).div(amountToSwap));

                        for (uint256 i = 0; i < swapFeeReceivers.length; i++) {
                            distribution.recoverTokensFor(token1, _calcFee(swapFeeToken1Amount, swapFeeReceiversRate[i]), swapFeeReceivers[i]);
                        }
                    }

                    if (rewardBuyToSwap > 0) {
                        uint256 rewardToken1Amount = _calcFee(token1Balance, rewardBuyToSwap.mul(10000).div(amountToSwap));

                        for (uint256 i = 0; i < rewardSwapReceivers.length; i++) {
                            distribution.recoverTokensFor(token1, _calcFee(rewardToken1Amount, rewardSwapReceiversRate[i]), rewardSwapReceivers[i]);
                        }
                    }


                    feeCounter = 0;
                    liquidityFeeAmount = 0;
                    swapFeeAmount = 0;
                    rewardBuyAmount = 0;
                    rewardSellAmount = 0;
                }
            }
        }

        return resultAmount;
    }

    function _transferAmount(address _from, address _to, uint256 _amount) internal {
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(_from, _to, _amount);
    }

    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: mint to the zero address");

        totalSupply = totalSupply.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: burn from the zero address");
        require(_account != deadAddress, "ERC20: burn from the dead address");
        require(balances[_account] >= _amount, "ERC20: burn amount exceeds balance");

        _transferAmount(_account, deadAddress, _amount);
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _calcFee(uint256 _amount, uint256 _rate) internal pure returns (uint256) {
        return _rate > 0 ? _amount.mul(_rate).div(10000) : 0;
    }

    function _isSell(address _from, address _to) internal view returns (bool) {
        return !isLpToken[_from] && isLpToken[_to];
    }

    function _isBuy(address _from, address _to) internal view returns (bool) {
        return isLpToken[_from] && !isLpToken[_to];
    }

    function _swapTokensForToken1(uint256 _tokenAmount, address _recipient) internal lockTheSwap {
        // generate the uniswap pair path of token -> token1
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = token1;

        _approve(address(this), address(router), _tokenAmount);
        // make the swap

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of token1
            path,
            _recipient,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _token1Amount, address _recipient) internal lockTheSwap {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), _tokenAmount);
        IERC20(token1).approve(address(router), _token1Amount);

        // add the liquidity
        router.addLiquidity(
            address(this),
            token1,
            _tokenAmount,
            _token1Amount,
            0,
            0,
            _recipient,
            block.timestamp
        );
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
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

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
        _checkRole(role);
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
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IDistribution {

    function OPERATOR_ROLE() external view returns(bytes32);

    function recoverTokens(address _token, uint256 _amount) external;

    function recoverTokensFor(address _token, uint256 _amount, address _to) external;

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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}