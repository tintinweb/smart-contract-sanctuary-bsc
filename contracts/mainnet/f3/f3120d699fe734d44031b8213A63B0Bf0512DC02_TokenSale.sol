// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/ITokenSale.sol";
import "./interfaces/IAdmin.sol";
import "./interfaces/IERC20D.sol";
import "./interfaces/IStaking.sol";

/*
A tokensale includes 3 stages: 
1. Private round. Only EBSC token holders can participate in this round. The BNB/USD price is fixed in the beginning of the tokensale. All tokens available in the pre-sale will be made available through the private sale round. A single investor can purchase up to their maximum allowed investment defined by the tier. Investors can claim their tokens only when the private round is finished. If the total supply is higher than the total demand for this tokensale, investors purchase tokens up to their max allocation. If the the demand is higher than supply, the number of tokens investors will receive is adjusted, and then the native token used to invest are partially refunded.

2. Public round. After the private round has been completed, the public round opens. Any unsold tokens from the private round  become available publicly. Anyone can participate in the public round. Investment in the public sale round is limited to 1000$ per wallet. Investors who have purchased tokens in the private sale round will be able to invest further in the public sale round.

3. Airdrop. 1% of tokens allocated to each tokensale are transferred to the distributor address to be distributed among participants with two highest tiers. (The distribution is centralised in this version)
*/

contract TokenSale is Initializable, ITokenSale {
    using SafeERC20 for IERC20D;

    uint64 constant PCT_BASE = 1 ether;
    uint64 constant ORACLE_MUL = 1e10;
    uint64 constant POINT_BASE = 1000;
    AggregatorV3Interface priceFeed;

    IStaking stakingContract;
    IERC20D token;
    Params params;
    IAdmin admin;
    /**
     * @dev current tokensale stage (epoch)
     */
    Epoch public override epoch;

    mapping(address => Staked) public override stakes;

    /**
     * @dev The maximum amount for which a specific tier can buy in a private round
     */
    mapping(IStaking.Tiers => uint256) public override maxValuesByTier;
    mapping(address => bool) claimed;
    mapping(address => uint256) public override publicPurchased;
    mapping(address => IStaking.Tiers) public giftedTier;

    /** @dev The exchange rate BNB / USD at the time of the first deposit */
    int256 public override exchangeRate;

    /** @dev it was sold in a private round (in tokens) */
    uint256 public override totalPrivateSold;

    /** @dev it was sold in a public round (in tokens) */
    uint256 public override totalPublicSold;

    /** @dev the totalSupply reduced to 18 decimals*/
    uint256 totalSupplyDecimals;

    /** @dev maximum available amount to purchase in tokens*/
    uint256 public publicMaxValues;

    /** @dev decimals of the token which we sell */
    uint8 tokenDecimals;

    /** @dev price in $ at the time of first deposit */
    uint256 public privatePrice;

    /** @dev price in $ at the time of first deposit */
    uint256 public publicPrice; 

    bool fee;
    bool public only;
    bool airdrop;
    bool leftovers;
    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    receive() external payable {}

    function initialize(
        Params calldata _params,
        address _stakingContract,
        address _admin,
        address _priceFeed
    ) external override initializer {
        params = _params;
        stakingContract = IStaking(_stakingContract);
        admin = IAdmin(_admin);
        token = IERC20D(_params.token);
        tokenDecimals = token.decimals();
        totalSupplyDecimals = _multiply(_params.totalSupply);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function giftTier(address[] calldata users, IStaking.Tiers[] calldata tiers)
        public
    {
        require(admin.hasRole(OPERATOR, msg.sender), "OnlyOperator");
        require(users.length == tiers.length, "invalid length");
        for (uint256 i = 0; i < users.length; i++) {
            if (stakingContract.getTierOf(users[i]) < tiers[i]) {
                
                giftedTier[users[i]] = tiers[i];
            }
        }
    }

    function onlygiftTier(bool _onlytier) external {
            require(admin.hasRole(OPERATOR, msg.sender), "OnlyOperator");
            require(only != _onlytier,"Invalid bool");
            checkingEpoch();
            require(uint8(epoch) < 1, "Incorrect time");
            only = _onlytier;
    }

    /**
     * @dev setup the current tokensale stage (epoch)
     */
    function checkingEpoch() internal {
        uint256 time = block.timestamp;
        if (
            epoch != Epoch.Private &&
            time >= params.privateStart &&
            time <= params.privateEnd
        ) {
            epoch = Epoch.Private;
            return;
        }
        if (
            epoch != Epoch.Public &&
            time >= params.publicStart &&
            time <= params.publicEnd &&
            _overcomeThreshold()
        ) {
            epoch = Epoch.Public;
            return;
        }
        if (
            (epoch != Epoch.Finished &&
                (time > params.privateEnd && !_overcomeThreshold())) ||
            time > params.publicEnd
        ) {
            epoch = Epoch.Finished;
            return;
        }
        if (
            (epoch != Epoch.Waiting && epoch != Epoch.Finished) &&
            (time > params.privateEnd && time < params.publicStart)
        ) {
            epoch = Epoch.Waiting;
            return;
        }
    }

    /**
     * @dev invest BNB to the tokensale
     */
    function deposit() external payable {
        checkingEpoch();
        address sender = msg.sender;
        uint256 value = msg.value;
        require(
            epoch == Epoch.Private || epoch == Epoch.Public,
            "incorrect time"
        );
        require(value > 0, "Cannot deposit 0");
        if (exchangeRate == 0) {
            (, exchangeRate, , , ) = priceFeed.latestRoundData();
            privatePrice = (params.privateTokenPrice * PCT_BASE) / (uint256(exchangeRate) * ORACLE_MUL);
            publicPrice = (params.publicTokenPrice * PCT_BASE) / (uint256(exchangeRate) * ORACLE_MUL);
            _setMaxValueByPrice(params.tierLimits);
        }
        if (epoch == Epoch.Private) {
            _processPrivate(sender, value);
        }
        if (epoch == Epoch.Public) {
            _processPublic(sender, value);
        }
    }

    function getTimeParams()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            params.privateStart,
            params.privateEnd,
            params.publicStart,
            params.publicEnd
        );
    }

    function getParams()
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256[4] memory,
            uint256[2][] memory,
            uint256[2][] memory
        )
    {
        return (
            params.initial,
            params.token,
            params.totalSupply,
            params.privateTokenPrice,
            params.publicTokenPrice,
            params.escrowPercentage,
            params.thresholdPublicAmount,
            params.airdrop,
            params.tierLimits,
            params.escrowReturnMilestones,
            params.vestingPoints
        );
    }

    /**
     * @dev processing BNB investment to the private round
     * @param _sender - transaction sender
     * @param _amount - investment amount in BNB
     */
    function _processPrivate(address _sender, uint256 _amount) internal {
        IStaking.Tiers t;
        
        if(only) {
            t = giftedTier[_sender];
            
        } else {
            if (uint256(giftedTier[_sender]) > uint256(stakingContract.getTierOf(_sender))) {
                t = giftedTier[_sender];
            } else {
                t = stakingContract.getTierOf(_sender);
            }
            
        }

        require(uint8(t) > 0, "does not have tier");
        _amount = (_amount * PCT_BASE) / privatePrice;
        require(_amount > 0, "too little value");
        Staked storage s = stakes[_sender];
        uint256 max = maxValuesByTier[t];
        uint256 sum = s.amount + _amount;
        bool limit = sum >= max;
        uint256 left = limit ? sum - max : 0;
        uint256 add = limit ? (max - s.amount) : _amount;
        if (s.tier != t) {
            s.tier = t;
        }
        totalPrivateSold += add;
        s.amount += add;
        //to iterate through an array
        s.point = int8(uint8(params.vestingPoints.length - 1));
        /**@notice Forbid unstaking*/
        stakingContract.setPoolsEndTime(_sender, params.privateEnd);
        emit DepositPrivate(_sender, _shift(_amount));
        left = (left * privatePrice) / PCT_BASE;
        if (left > 0) {
            (bool success, ) = _sender.call{value: left}("");
            require(success);
        }
    }

    /**
     * @dev processing BNB investment to the public round
     * @param _sender - transaction sender
     * @param _amount - investment amount in BNB
     */
    function _processPublic(address _sender, uint256 _amount) internal {
        /** @notice Calculate the token price in BNB and maximum available amount to purchase in tokens*/
        if (totalPublicSold == 0) {
            uint256 inValue = (params.publicBuyLimit * PCT_BASE) /
                (uint256(exchangeRate) * ORACLE_MUL);
            publicMaxValues = (inValue * PCT_BASE) / (publicPrice);
        }

        /** @notice Calculate and transfer max amount of token the investor can purchase */
        (uint256 want, uint256 left) = _leftWant(_sender, _amount);
        uint256 amount = left < want ? left : want;
        token.safeTransfer(_sender, _shift(amount));
        publicPurchased[_sender] += amount;
        totalPublicSold += amount;

        /** @notice If the investor is trying to but more tokens than is allowed, the rest of BNB is returned to them */
        if (left < want) {
            uint256 refund = _amount -
                ((left * publicPrice) / PCT_BASE);
            (bool success, ) = _sender.call{value: refund}("");
            require(success);
        }
        emit DepositPublic(_sender, _shift(amount));
    }

    /**
     * @dev calculates the amount of tokens an investor want and can actually purchase
     * @param _sender - transaction sender
     * @param _amount - investment amount in BNB
     */
    function _leftWant(address _sender, uint256 _amount)
        internal
        view
        returns (uint256 want, uint256 left)
    {
        want = (_amount * PCT_BASE) / publicPrice;
        uint256 forUser = (publicMaxValues - publicPurchased[_sender]);
        uint256 forContract = saleTokensAmountWithoutAirdrop() -
            (totalPrivateSold + totalPublicSold);
        left = forUser < forContract ? forUser : forContract;
    }

    /**
     * @dev converts the amount of tokens from 18 decimals to {tokenDecimals}
     */
    function _shift(uint256 _amount) internal view returns (uint256 value) {
        if (tokenDecimals != 18) {
            value = tokenDecimals < 18
                ? (_amount / 10**(18 - tokenDecimals))
                : (_amount * 10**(tokenDecimals - 18));
        } else {
            value = _amount;
        }
    }

    /**
     * @dev converts the amount of tokens from {tokenDecimals} to 18 decimals
     */
    function _multiply(uint256 _amount) internal view returns (uint256 value) {
        if (tokenDecimals != 18) {
            value = tokenDecimals < 18
                ? (_amount * 10**(18 - tokenDecimals))
                : (_amount / 10**(tokenDecimals - 18));
        } else {
            value = _amount;
        }
    }

    /**
     * @dev allows the participants of the private round to claim their tokens
     */
    function claim() external override {
        checkingEpoch();
        require(uint8(epoch) > 1, "incorrect time");
        address sender = msg.sender;
        require(!claimed[sender], "already claims");
        Staked storage s = stakes[sender];
        require(s.amount != 0, "doest have a deposit");
        /** @notice An investor can withdraw no more tokens than they bought or than allowed by their tier */
        uint256 value;
        uint256 left;
        if (s.share == 0) {
            uint256 supply = saleTokensAmountWithoutAirdrop();
            /** @notice If the demand is higher than supply, the amount of available token for each investor is decreased proportionally to their tiers */
            if (totalPrivateSold > supply) {
                uint256 rate = (supply * PCT_BASE) / totalPrivateSold;
                s.share = (s.amount * rate) / PCT_BASE;
                left = s.amount - s.share;
                left = (left * privatePrice) / PCT_BASE;
            } else {
                s.share = s.amount;
            }
        }
        (int8 newPoint, uint256 pct) = _canClaim(block.timestamp, s.point);
        require(pct > 0 || left > 0, "nothing to claim");
        value = (s.share * pct) / POINT_BASE;
        s.point = newPoint;
        s.claim += value;
        claimed[sender] = newPoint == -1 ? true : false;
        token.safeTransfer(sender, _shift(value));
        emit Claim(sender, _shift(value), left);
        if (left > 0) {
            (bool success, ) = sender.call{value: left}("");
            require(success);
        }
    }

    function _canClaim(uint256 _now, int8 _curPoint)
        internal
        view
        returns (int8 _newPoint, uint256 _pct)
    {
        _newPoint = _curPoint;
        for (uint8 i = 0; i <= uint8(_curPoint); i++) {
            if (_now >= params.vestingPoints[i][0]) {
                _newPoint = int8(i) - 1;
                for (uint8 j = i; j <= uint8(_curPoint); j++) {
                    _pct = _pct + params.vestingPoints[j][1];
                }
                break;
            }
        }
    }


    /**
     * @dev sends the unsold tokens and corresponding part of the escrow to the admin address
     */
    function takeLeftovers() external override {
        checkingEpoch();
        require(epoch == Epoch.Finished && airdrop, "It is not time yet");
        require(!leftovers, "Already paid");
        // uint256 returnAmount = _returnEscrow();
        // uint256 escrowFee = (_escrowAmount() - returnAmount);
        uint256 returnAmount = 0;
        uint256 escrowFee = 0;
        uint256 earned = _earned(saleTokensAmountWithoutAirdrop());
        leftovers = true;
        if (saleTokensAmountWithoutAirdrop() > totalTokenSold()) {
            returnAmount += (saleTokensAmountWithoutAirdrop() -
                totalTokenSold());
        }
        // if (escrowFee > 0) {
        //     token.safeTransfer(admin.wallet(), _shift(escrowFee));
        // }
        if (returnAmount > 0) {
            token.safeTransfer(params.initial, _shift(returnAmount));
        }
        if (earned > 0) {
            earned = earned - _valueFee();
            uint256 value = earned <= address(this).balance
                ? earned
                : address(this).balance;
            (bool success, ) = params.initial.call{value: value}("");
            require(success, "not success");
        }
        emit TransferLeftovers(_shift(returnAmount), _shift(escrowFee), earned);
    }

    function takeFee() external {
        checkingEpoch();
        require(uint8(epoch) > 1, "It is not time yet");
        require(!fee, "Already paid");
        address wallet = admin.wallet();
        uint256 tokenFee = _tokenFee();
        uint256 valueFee = _valueFee();
        fee = true;
        if (tokenFee > 0) {
            token.safeTransfer(wallet, _shift(tokenFee));
        }
        if (valueFee > 0) {
            (bool success, ) = wallet.call{value: valueFee}("");
            require(success);
        }
    }

    function _valueFee() internal view returns (uint256) {
        uint256 totalForSale = saleTokensAmountWithoutAirdrop();
        uint256 totalValue;
        if (totalPrivateSold > totalForSale) {
            totalValue = (totalForSale * privatePrice) / PCT_BASE;
        } else {
            totalValue =
                (totalPrivateSold * privatePrice) /
                PCT_BASE;
        }
        return (totalValue * params.valueFeePct) / POINT_BASE;
    }

    function _earned(uint256 _saleAmount)
        internal
        view
        returns (uint256 earned)
    {
        bool soldOut = totalTokenSold() > _saleAmount;
        if (soldOut) {
            earned =
                (((_saleAmount - totalPublicSold) * privatePrice) +
                    (totalPublicSold * publicPrice)) /
                PCT_BASE;
        } else {
            earned =
                ((totalPrivateSold * privatePrice) +
                    (totalPublicSold * publicPrice)) /
                PCT_BASE;
        }
    }

    /**
     * @dev sends the tokens locked for airdrop to the admin address
     */
    function takeAirdrop() external override {
        checkingEpoch();
        require(epoch == Epoch.Finished, "Sale is not over");
        require(!airdrop, "Already paid");
        uint256 amount = params.airdrop;
        airdrop = true;
        token.safeTransfer(admin.forAirdrop(), amount);
        emit TransferAirdrop(amount);
    }

    function takeLocked() external override {
        require(
            block.timestamp >= (params.publicEnd + 259200),
            "It is not time yet"
        );
        uint256 amountTkn = token.balanceOf(address(this));
        uint256 amountValue = address(this).balance;
        if (amountTkn > 0) {
            token.safeTransfer(admin.wallet(), amountTkn);
        }
        if (address(this).balance > 0) {
            (bool success, ) = admin.wallet().call{value: amountValue}("");
            require(success);
        }
    }

    /**
     * @dev sends the tokens locked for airdrop to the admin address
     */
    function _setMaxValueByPrice(uint256[4] memory _limits) internal {
        for (uint256 i = 0; i < _limits.length; i++) {
            unchecked {
                require(exchangeRate > 0);
                uint256 inValue = (_limits[i] * PCT_BASE) /
                (uint256(exchangeRate) * ORACLE_MUL);
                uint256 amount = (inValue * PCT_BASE) / privatePrice;
                maxValuesByTier[IStaking.Tiers(i + 1)] = amount;
            }
        }
    }

    // function _returnEscrow() internal view returns (uint256 returnAmount) {
    //     uint256 blockedAmount = _escrowAmount();
    //     uint256[2][] memory milestones = params.escrowReturnMilestones;
    //     for (uint256 i = 0; i < milestones.length; i++) {
    //         uint256 mustSold = (saleTokensAmountWithoutAirdrop() *
    //             milestones[i][0]) / POINT_BASE;
    //         if (mustSold <= totalTokenSold()) {
    //             if (milestones[i][1] > 0) {
    //                 returnAmount =
    //                     (blockedAmount * milestones[i][1]) /
    //                     POINT_BASE;
    //             } else {
    //                 returnAmount = blockedAmount;
    //             }
    //             break;
    //         }
    //     }
    // }

    function _tokenFee() internal view returns (uint256) {
        return (totalSupplyDecimals * params.tokenFeePct) / POINT_BASE;
    }

    function totalTokenSold() public view returns (uint256) {
        return totalPrivateSold + totalPublicSold;
    }

    // function _escrowAmount() internal view returns (uint256) {
    //     return (totalSupplyDecimals * params.escrowPercentage) / POINT_BASE;
    // }

    function _overcomeThreshold() internal view returns (bool overcome) {
        if (saleTokensAmountWithoutAirdrop() > totalPrivateSold) {
            overcome = ((saleTokensAmountWithoutAirdrop() - totalPrivateSold) >=
                _multiply(params.thresholdPublicAmount));
        }
    }

    /**
     * @dev amount reserved for entire process without airdrop
     */
    function saleTokensAmountWithoutAirdrop() public view returns (uint256) {
        return 
            (totalSupplyDecimals) -
            _multiply(params.airdrop) -
            _tokenFee();
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED

/**
 * @title ITokenSale.
 * @dev interface of ITokenSale
 * params structure and functions.
 */
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;
import "./IStaking.sol";

interface ITokenSale {
    struct Staked {
        IStaking.Tiers tier;
        uint256 amount;
        uint256 share;
        uint256 claim;
        int8 point;
    }
    enum Epoch {
        Incoming,
        Private,
        Waiting,
        Public,
        Finished
    }

    /**
     * @dev describe initial params for token sale
     * @param totalSupply set total amount of tokens. (Token decimals)
     * @param privateStart set starting time for private sale.
     * @param privateEnd set finish time for private sale.
     * @param publicStart set starting time for public sale.
     * @param privateEnd set finish time for private sale.
     * @param privateTokenPrice set price for private sale per token in $ (18 decimals).
     * @param publicTokenPrice set price for public sale per token in $ (18 decimals).
     * @param publicBuyLimit set limit for tokens per address in $ (18 decimals).
     * @param escrowPercentage set interest rate for depositor. >
     * @param tierPrices set price to calculate maximum value by tier for staking.
     * @param thresholdPublicAmount - should be sold more than that.
     * @param airdrop - amount reserved for airdrop
     */
    struct Params {
        address initial;
        address token;
        uint256 totalSupply; //MUST BE 10**18;
        uint256 privateStart;
        uint256 privateEnd;
        uint256 publicStart;
        uint256 publicEnd;
        uint256 privateTokenPrice; // MUST BE 10**18 in bnb
        uint256 publicTokenPrice; // MUST BE 10**18 in bnb
        uint256 publicBuyLimit; //// MUST BE 10**18 in $
        uint256 escrowPercentage; // Percentage base is 1000
        uint256[4] tierLimits; // MUST BE 10**18 in $
        uint256[2][] escrowReturnMilestones; // Percentage base is 1000
        //in erc decimals
        uint256 thresholdPublicAmount;
        uint256 airdrop;
        //[timeStamp, pct]
        uint256[2][] vestingPoints; // Percentage base is 1000
        uint256 tokenFeePct; // Percentage base is 1000
        uint256 valueFeePct; // Percentage base is 1000
    }

    /**
     * @dev initialize implementation logic contracts addresses
     * @param _stakingContract for staking contract.
     * @param _admin for admin contract.
     * @param _priceFeed for price aggregator contract.
     */
    function initialize(
        Params memory,
        address _stakingContract,
        address _admin,
        address _priceFeed
    ) external;

    /**
     * @dev claim to sell tokens in airdrop.
     */
    function claim() external;

    /**
     * @dev get banned list of addresses from participation in sales in this contract.
     */
    function epoch() external returns (Epoch);

    function maxValuesByTier(IStaking.Tiers) external returns (uint256);

    function publicPurchased(address) external returns (uint256);

    function exchangeRate() external returns (int256);

    function totalPrivateSold() external returns (uint256);

    function totalPublicSold() external returns (uint256);

    //function addToBlackList(address[] memory) external;

    function takeLeftovers() external;

    function takeAirdrop() external;

    function stakes(address)
        external
        returns (
            IStaking.Tiers,
            uint256,
            uint256,
            uint256,
            int8
        );

    function takeLocked() external;

    event DepositPrivate(address indexed user, uint256 amount);
    event DepositPublic(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount, uint256 change);
    event TransferAirdrop(uint256 amount);
    event TransferLeftovers(uint256 leftovers, uint256 fee, uint256 earned);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./ITokenSale.sol";

/**
 * @title IAdmin.
 * @dev interface of Admin contract
 * which can set addresses for contracts for:
 * airdrop, token sales maintainers, staking.
 * Also Admin can create new pool.
 */
interface IAdmin is IAccessControl {
    function forAirdrop() external returns (address);

    function exchangeOracle() external returns (address);

    function tokenSalesM(address) external returns (bool);

    function tokenSales(uint256) external returns (address);

    function masterTokenSale() external returns (address);

    function stakingContract() external returns (address);

    function setMasterContract(address) external;

    function setAirdrop(address _newAddress) external;

    function setStakingContract(address) external;

    function setOracleContract(address) external;

    function createPool(ITokenSale.Params calldata _params) external;

    function getTokenSales() external view returns (address[] memory);

    function wallet() external view returns (address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20D is IERC20{
   function decimals() external returns (uint8);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
/**
 * @title IStaking.
 * @dev interface for staking
 * with params enum and functions.
 */
interface IStaking {
    /**
    * @dev 
    * defines privelege type of address.
    */
    enum Tiers {
        None,
        Starter,
        Investor,
        Strategist,
        Evangelist
    }

    function setPoolsEndTime(address, uint256) external;

    function stakedAmountOf(address) external view returns (uint256);

    function stake(uint256) external;

    function unstake(uint256) external;

    function getTierOf(address) external view returns (Tiers);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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