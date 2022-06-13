//SPDX-License-Identifier: LICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;
pragma abicoder v2;
// We import this library to be able to use console.log
// import "hardhat/console.sol";
import "./libraries/TransferHelper.sol";
import "./interfaces/PriceOracle.sol";
import "./interfaces/ILimitManager.sol";
import "./interfaces/ILevelManager.sol";
import "./interfaces/IMarketManager.sol";
import "./interfaces/ICashBackManager.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/ISwapper.sol";
import "./interfaces/ERC20Interface.sol";
import "./interfaces/IConverter.sol";
import "./libraries/SafeMath.sol";

import "./OwnerConstants.sol";
import "./SignerRole.sol";

// This is the main building block for smart contracts.
contract OkseCard is OwnerConstants, SignerRole {
    //  bytes4 public constant PAY_MONTHLY_FEE = bytes4(keccak256(bytes('payMonthlyFee')));
    bytes4 public constant PAY_MONTHLY_FEE = 0x529a8d6c;
    //  bytes4 public constant WITHDRAW = bytes4(keccak256(bytes('withdraw')));
    bytes4 public constant WITHDRAW = 0x855511cc;
    //  bytes4 public constant BUYGOODS = bytes4(keccak256(bytes('buyGoods')));
    bytes4 public constant BUYGOODS = 0xa8fd19f2;
    //  bytes4 public constant SET_USER_MAIN_MARKET = bytes4(keccak256(bytes('setUserMainMarket')));
    bytes4 public constant SET_USER_MAIN_MARKET = 0x4a22142e;

    // uint256 public constant CARD_VALIDATION_TIME = 10 minutes; // 30 days in prodcution
    uint256 public constant CARD_VALIDATION_TIME = 30 days; // 30 days in prodcution

    using SafeMath for uint256;
    address public immutable converter;
    address public swapper;

    // Price oracle address, which is used for verification of swapping assets amount
    address public priceOracle;
    address public limitManager;
    address public levelManager;
    address public marketManager;
    address public cashbackManager;

    // Governor can set followings:
    address public governorAddress; // Governance address

    /*** Main Actions ***/
    // user's deposited balance.
    // user  => ( market => balances)
    mapping(address => mapping(address => uint256)) public usersBalances;

    mapping(address => uint256) public userValidTimes;

    //prevent reentrancy attack
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    bool private initialized;

    // uint256 public timeDiff;
    struct SignKeys {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct SignData {
        bytes4 method;
        uint256 id;
        address market;
        address userAddr;
        uint256 amount;
        uint256 validTime;
    }
    // emit event

    event UserBalanceChanged(
        address indexed userAddr,
        address indexed market,
        uint256 amount
    );

    event GovernorAddressChanged(
        address indexed previousGovernor,
        address indexed newGovernor
    );
    event MonthlyFeePaid(
        uint256 id,
        address userAddr,
        uint256 userValidTime,
        uint256 usdAmount
    );
    event UserDeposit(address userAddr, address market, uint256 amount);
    event UserWithdraw(
        uint256 id,
        address userAddr,
        address market,
        uint256 amount,
        uint256 remainedBalance
    );
    event SignerBuyGoods(
        uint256 id,
        address signer1,
        address signer2,
        address market,
        address userAddr,
        uint256 usdAmount
    );
    event UserMainMarketChanged(
        uint256 id,
        address userAddr,
        address market,
        address beforeMarket
    );
    event ContractAddressChanged(
        address priceOracle,
        address swapper,
        address limitManager,
        address levelManager,
        address marketManager,
        address cashbackManager
    );
    event WithdrawTokens(address token, address to, uint256 amount);

    // verified
    /**
     * Contract initialization.
     *
     * The `constructor` is executed only once when the contract is created.
     * The `public` modifier makes a function callable from outside the contract.
     */
    constructor(address _converter, address _initialSigner)
        SignerRole(_initialSigner)
    {
        converter = _converter;
        // The totalSupply is assigned to transaction sender, which is the account
        // that is deploying the contract.
    }

    // verified
    receive() external payable {
        // require(msg.sender == WETH, 'Not WETH9');
    }

    // verified
    function initialize(
        address _priceOracle,
        address _limitManager,
        address _levelManager,
        address _marketManager,
        address _cashbackManager,
        address _financialAddress,
        address _masterAddress,
        address _treasuryAddress,
        address _governorAddress,
        address _monthlyFeeAddress,
        address _stakeContractAddress,
        address _swapper
    ) public {
        require(!initialized, "ai");
        // owner = _owner;
        // _addSigner(_owner);
        priceOracle = _priceOracle;
        limitManager = _limitManager;
        levelManager = _levelManager;
        marketManager = _marketManager;
        cashbackManager = _cashbackManager;
        treasuryAddress = _treasuryAddress;
        financialAddress = _financialAddress;
        masterAddress = _masterAddress;
        governorAddress = _governorAddress;
        monthlyFeeAddress = _monthlyFeeAddress;
        stakeContractAddress = _stakeContractAddress;
        swapper = _swapper;
        //private variables initialize.
        _status = _NOT_ENTERED;
        //initialize OwnerConstants arrays

        stakePercent = 15 * (100 + 15);
        buyFeePercent = 250;
        buyTxFee = 0.7 ether;
        withdrawFeePercent = 0;
        monthlyFeeAmount = 6.99 ether;
        okseMonthlyProfit = 1000;
        initialized = true;
    }

    /// modifier functions
    // verified
    modifier onlyGovernor() {
        require(_msgSender() == governorAddress, "og");
        _;
    }
    // // verified
    modifier marketEnabled(address market) {
        require(IMarketManager(marketManager).marketEnable(market), "mdnd");
        _;
    }
    // verified
    modifier noExpired(address userAddr) {
        require(!getUserExpired(userAddr), "user expired");
        _;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    // verified
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "rc");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier validSignOfUser(
        SignData calldata sign_data,
        SignKeys calldata sign_key
    ) {
        require(
            sign_data.userAddr == getecrecover(sign_data, sign_key),
            "ssst"
        );
        _;
    }
    modifier noEmergency() {
        require(!IMarketManager(marketManager).emergencyStop(), "stopped");
        _;
    }

    function getUserOkseBalance(address userAddr)
        external
        view
        returns (uint256)
    {
        return usersBalances[userAddr][IMarketManager(marketManager).OKSE()];
    }

    // verified
    function getUserExpired(address _userAddr) public view returns (bool) {
        if (userValidTimes[_userAddr].add(25 days) > block.timestamp) {
            return false;
        }
        return true;
    }

    // set Governance address
    function setGovernor(address newGovernor) public onlyGovernor {
        address oldGovernor = governorAddress;
        governorAddress = newGovernor;
        emit GovernorAddressChanged(oldGovernor, newGovernor);
    }

    // verified
    function updateSigner(address _signer, bool bAddOrRemove)
        public
        onlyGovernor
    {
        if (bAddOrRemove) {
            _addSigner(_signer);
        } else {
            _removeSigner(_signer);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function onUpdateUserBalance(
        address userAddr,
        address market,
        uint256 amount,
        uint256 beforeAmount
    ) internal returns (bool) {
        emit UserBalanceChanged(userAddr, market, amount);
        if (market != IMarketManager(marketManager).OKSE()) return true;
        return
            ILevelManager(levelManager).updateUserLevel(userAddr, beforeAmount);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // newly verified
    function deposit(address market, uint256 amount)
        public
        marketEnabled(market)
        nonReentrant
        noEmergency
    {
        TransferHelper.safeTransferFrom(
            market,
            msg.sender,
            address(this),
            amount
        );
        _addUserBalance(market, msg.sender, amount);
        emit UserDeposit(msg.sender, market, amount);
    }

    // newly verified
    function depositETH() public payable nonReentrant {
        address WETH = IMarketManager(marketManager).WETH();
        require(IMarketManager(marketManager).marketEnable(WETH), "me");
        IWETH9(WETH).deposit{value: msg.value}();
        _addUserBalance(WETH, msg.sender, msg.value);
        emit UserDeposit(msg.sender, WETH, msg.value);
    }

    // verified
    function _addUserBalance(
        address market,
        address userAddr,
        uint256 amount
    ) internal marketEnabled(market) {
        uint256 beforeAmount = usersBalances[userAddr][market];
        usersBalances[userAddr][market] = usersBalances[userAddr][market].add(
            amount
        );
        onUpdateUserBalance(
            userAddr,
            market,
            usersBalances[userAddr][market],
            beforeAmount
        );
    }

    // newly verified
    function setUserMainMarket(
        uint256 id,
        address market,
        uint256 validTime,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        address userAddr = msg.sender;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        require(
            isSigner(
                ecrecover(
                    toEthSignedMessageHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                SET_USER_MAIN_MARKET,
                                id,
                                userAddr,
                                market,
                                chainId,
                                uint256(0),
                                validTime
                            )
                        )
                    ),
                    v,
                    r,
                    s
                )
            ),
            "summ"
        );
        require(signatureId[id] == false, "pru");
        signatureId[id] = true;
        require(validTime > block.timestamp, "expired");
        address beforeMarket = IMarketManager(marketManager).getUserMainMarket(
            userAddr
        );
        IMarketManager(marketManager).setUserMainMakret(userAddr, market);
        emit UserMainMarketChanged(id, userAddr, market, beforeMarket);
    }

    // verified
    function payMonthlyFee(
        uint256 id,
        SignData calldata _data,
        SignKeys calldata user_key,
        address market
    )
        public
        nonReentrant
        marketEnabled(market)
        noEmergency
        validSignOfUser(_data, user_key)
        onlySigner
    {
        address userAddr = _data.userAddr;
        require(userValidTimes[userAddr] <= block.timestamp, "e");
        require(monthlyFeeAmount <= _data.amount, "over paid");
        require(
            signatureId[id] == false && _data.method == PAY_MONTHLY_FEE,
            "pru"
        );
        signatureId[id] = true;
        // increase valid period

        // extend user's valid time
        uint256 _monthlyFee = getMonthlyFeeAmount(
            market == IMarketManager(marketManager).OKSE()
        );
        uint256 _tempVal = _monthlyFee;
        userValidTimes[userAddr] = block.timestamp.add(CARD_VALIDATION_TIME);

        if (stakeContractAddress != address(0)) {
            _tempVal = (_monthlyFee.mul(10000)).div(stakePercent.add(10000));
        }

        uint256 beforeAmount = usersBalances[userAddr][market];
        calculateAmount(
            market,
            userAddr,
            _tempVal,
            monthlyFeeAddress,
            stakeContractAddress,
            stakePercent
        );
        onUpdateUserBalance(
            userAddr,
            market,
            usersBalances[userAddr][market],
            beforeAmount
        );
        emit MonthlyFeePaid(
            id,
            userAddr,
            userValidTimes[userAddr],
            _monthlyFee
        );
    }

    // newly verified
    function withdraw(
        uint256 id,
        address market,
        uint256 amount,
        uint256 validTime,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant {
        address userAddr = msg.sender;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        require(
            isSigner(
                ecrecover(
                    toEthSignedMessageHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                WITHDRAW,
                                id,
                                userAddr,
                                market,
                                chainId,
                                amount,
                                validTime
                            )
                        )
                    ),
                    v,
                    r,
                    s
                )
            ),
            "ssst"
        );
        require(signatureId[id] == false, "pru");
        signatureId[id] = true;
        require(validTime > block.timestamp, "expired");
        uint256 beforeAmount = usersBalances[userAddr][market];
        // require(beforeAmount >= amount, "ib");
        usersBalances[userAddr][market] = beforeAmount.sub(amount);
        address WETH = IMarketManager(marketManager).WETH();
        if (market == WETH) {
            IWETH9(WETH).withdraw(amount);
            if (treasuryAddress != address(0)) {
                uint256 feeAmount = (amount.mul(withdrawFeePercent)).div(10000);
                if (feeAmount > 0) {
                    TransferHelper.safeTransferETH(treasuryAddress, feeAmount);
                }
                TransferHelper.safeTransferETH(
                    msg.sender,
                    amount.sub(feeAmount)
                );
            } else {
                TransferHelper.safeTransferETH(msg.sender, amount);
            }
        } else {
            if (treasuryAddress != address(0)) {
                uint256 feeAmount = (amount.mul(withdrawFeePercent)).div(10000);
                if (feeAmount > 0) {
                    TransferHelper.safeTransfer(
                        market,
                        treasuryAddress,
                        feeAmount
                    );
                }
                TransferHelper.safeTransfer(
                    market,
                    msg.sender,
                    amount.sub(feeAmount)
                );
            } else {
                TransferHelper.safeTransfer(market, msg.sender, amount);
            }
        }
        uint256 userBal = usersBalances[userAddr][market];
        onUpdateUserBalance(userAddr, market, userBal, beforeAmount);
        emit UserWithdraw(id, userAddr, market, amount, userBal);
    }

    // decimal of usdAmount is 18
    // newly verified
    function buyGoods(SignData calldata _data, SignKeys[2] calldata signer_key)
        external
        nonReentrant
        marketEnabled(_data.market)
        noExpired(_data.userAddr)
        noEmergency
    {
        address[2] memory signers = [
            getecrecover(_data, signer_key[0]),
            getecrecover(_data, signer_key[1])
        ];
        require(
            isSigner(signers[0]) &&
                isSigner(signers[1]) &&
                (signers[0] != signers[1]),
            "is"
        );
        require(
            signatureId[_data.id] == false && _data.method == BUYGOODS,
            "pru"
        );
        signatureId[_data.id] = true;
        if (_data.market == IMarketManager(marketManager).OKSE()) {
            require(IMarketManager(marketManager).oksePaymentEnable(), "jsy");
        }
        require(
            IMarketManager(marketManager).getUserMainMarket(_data.userAddr) ==
                _data.market,
            "jsy2"
        );
        uint256 spendAmount = _makePayment(
            _data.market,
            _data.userAddr,
            _data.amount
        );
        cashBack(_data.userAddr, spendAmount);
        emit SignerBuyGoods(
            _data.id,
            signers[0],
            signers[1],
            _data.market,
            _data.userAddr,
            _data.amount
        );
    }

    // deduce user assets using usd amount
    // decimal of usdAmount is 18
    // verified
    function _makePayment(
        address market,
        address userAddr,
        uint256 usdAmount
    ) internal returns (uint256 spendAmount) {
        uint256 beforeAmount = usersBalances[userAddr][market];
        spendAmount = calculateAmount(
            market,
            userAddr,
            usdAmount,
            masterAddress,
            treasuryAddress,
            buyFeePercent
        );
        ILimitManager(limitManager).updateUserSpendAmount(userAddr, usdAmount);

        onUpdateUserBalance(
            userAddr,
            market,
            usersBalances[userAddr][market],
            beforeAmount
        );
    }

    // calculate aseet amount from market and required usd amount
    // decimal of usdAmount is 18
    // spendAmount is decimal 18
    function calculateAmount(
        address market,
        address userAddr,
        uint256 usdAmount,
        address targetAddress,
        address feeAddress,
        uint256 feePercent
    ) internal returns (uint256 spendAmount) {
        uint256 _amount;
        address USDC = IMarketManager(marketManager).USDC();
        if (feeAddress != address(0)) {
            _amount = usdAmount.add((usdAmount.mul(feePercent)).div(10000)).add(
                    buyTxFee
                );
        } else {
            _amount = usdAmount;
        }
        // change _amount to USDC asset amounts
        uint256 assetAmountIn = IConverter(converter).getAssetAmount(
            market,
            _amount,
            priceOracle
        );
        assetAmountIn = assetAmountIn.add(
            (assetAmountIn.mul(IMarketManager(marketManager).slippage())).div(10000)
        );
        _amount = IConverter(converter).convertUsdAmountToAssetAmount(
            _amount,
            USDC
        );
        uint256 userBal = usersBalances[userAddr][market];
        if (market != USDC) {
            // we need to change somehting here, because if there are not pair {market, USDC} , then we have to add another path
            // so please check the path is exist and if no, please add market, weth, usdc to path
            address[] memory path = ISwapper(swapper).getOptimumPath(
                market,
                USDC
            );
            uint256[] memory amounts = ISwapper(swapper).getAmountsIn(
                _amount,
                path
            );

            require(amounts[0] < assetAmountIn, "ua");
            usersBalances[userAddr][market] = userBal.sub(amounts[0]);
            TransferHelper.safeTransfer(
                path[0],
                ISwapper(swapper).GetReceiverAddress(path),
                amounts[0]
            );
            ISwapper(swapper)._swap(amounts, path, address(this));
        } else {
            // require(_amount <= usersBalances[userAddr][market], "uat");
            require(_amount < assetAmountIn, "au");
            usersBalances[userAddr][market] = userBal.sub(_amount);
        }
        require(targetAddress != address(0), "mis");
        uint256 usdcAmount = IConverter(converter)
            .convertUsdAmountToAssetAmount(usdAmount, USDC);
        require(_amount >= usdcAmount, "sp");
        TransferHelper.safeTransfer(USDC, targetAddress, usdcAmount);
        uint256 fee = _amount.sub(usdcAmount);
        if (feeAddress != address(0))
            TransferHelper.safeTransfer(USDC, feeAddress, fee);
        spendAmount = IConverter(converter).convertAssetAmountToUsdAmount(
            _amount,
            USDC
        );
    }

    function cashBack(address userAddr, uint256 usdAmount) internal {
        if (!ICashBackManager(cashbackManager).cashBackEnable()) return;
        uint256 cashBackPercent = ICashBackManager(cashbackManager)
            .getCashBackPercent(
                ILevelManager(levelManager).getUserLevel(userAddr)
            );
        address OKSE = IMarketManager(marketManager).OKSE();
        uint256 okseAmount = IConverter(converter).getAssetAmount(
            OKSE,
            (usdAmount.mul(cashBackPercent)).div(10000),
            priceOracle
        );
        // require(ERC20Interface(OKSE).balanceOf(address(this)) >= okseAmount , "insufficient OKSE");
        if (usersBalances[financialAddress][OKSE] > okseAmount) {
            usersBalances[financialAddress][OKSE] = usersBalances[
                financialAddress
            ][OKSE].sub(okseAmount);
            //needs extra check that owner deposited how much OKSE for cashBack
            _addUserBalance(OKSE, userAddr, okseAmount);
        }
    }

    // verified
    function getUserAssetAmount(address userAddr, address market)
        public
        view
        returns (uint256)
    {
        return usersBalances[userAddr][market];
    }

    // verified
    function encodePackedData(SignData calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encodePacked(
                    this,
                    _data.method,
                    _data.id,
                    _data.userAddr,
                    _data.market,
                    chainId,
                    _data.amount,
                    _data.validTime
                )
            );
    }

    // verified
    function getecrecover(SignData calldata _data, SignKeys calldata key)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(
                        abi.encodePacked(
                            this,
                            _data.method,
                            _data.id,
                            _data.userAddr,
                            _data.market,
                            chainId,
                            _data.amount,
                            _data.validTime
                        )
                    )
                ),
                key.v,
                key.r,
                key.s
            );
    }

    // verified
    function setContractAddress(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setContractAddress")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (
            address _priceOracle,
            address _swapper,
            address _limitManager,
            address _levelManager,
            address _marketManager,
            address _cashbackManager
        ) = abi.decode(
                params,
                (address, address, address, address, address, address)
            );
        priceOracle = _priceOracle;
        swapper = _swapper;
        limitManager = _limitManager;
        levelManager = _levelManager;
        marketManager = _marketManager;
        cashbackManager = _cashbackManager;
        emit ContractAddressChanged(
            priceOracle,
            swapper,
            limitManager,
            levelManager,
            marketManager,
            cashbackManager
        );
    }

    // owner function
    function withdrawTokens(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "withdrawTokens")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address token, address to) = abi.decode(params, (address, address));

        require(!IMarketManager(marketManager).isMarketExist(token), "me");
        uint256 amount;
        if (token == address(0)) {
            amount = address(this).balance;
            TransferHelper.safeTransferETH(to, amount);
        } else {
            amount = ERC20Interface(token).balanceOf(address(this));
            TransferHelper.safeTransfer(token, to, amount);
        }
        emit WithdrawTokens(token, to, amount);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a cToken asset
      * @param market The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address market) external virtual view returns (uint);

}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface ILimitManager {
    function getUserLimit(address userAddr) external view returns (uint256);

    function getDailyLimit(uint256 level) external view returns (uint256);

    function getSpendAmountToday(address userAddr)
        external
        view
        returns (uint256);

    function withinLimits(address userAddr, uint256 usdAmount)
        external
        view
        returns (bool);

    function updateUserSpendAmount(address userAddr, uint256 usdAmount)
        external;
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface ILevelManager {
    function getUserLevel(address userAddr) external view returns (uint256);

    function getLevel(uint256 _okseAmount) external view returns (uint256);

    function updateUserLevel(
        address userAddr,
        uint256 beforeAmount
    ) external returns (bool);
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface IMarketManager {
    function WETH() external view returns (address);

    function USDC() external view returns (address);

    function OKSE() external view returns (address);

    function defaultMarket() external view returns (address);

    function oksePaymentEnable() external view returns (bool);

    function emergencyStop() external view returns (bool);

    function marketEnable(address market) external view returns (bool);

    function isMarketExist(address market) external view returns (bool);

    function userMainMarket(address userAddr) external view returns (address);

    function slippage() external view returns (uint256);

    function getUserMainMarket(address userAddr)
        external
        view
        returns (address);

    function setUserMainMakret(address userAddr, address market) external;
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface ICashBackManager {
    function cashBackEnable() external view returns (bool);

    function getCashBackPercent(uint256 level) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface ISwapper {
  function _swap(
    uint256[] memory amounts,
    address[] memory path,
    address _to
  ) external;

  function getAmountsIn(
    uint256 amountOut,
    address[] memory path
  ) external view returns (uint256[] memory amounts);

  function GetReceiverAddress(
    address[] memory path
  ) external view returns (address);
  
  function getOptimumPath(
    address token0,
    address token1
  ) external view returns (address[] memory);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;

interface IConverter {
    function convertUsdAmountToAssetAmount(
        uint256 usdAmount,
        address assetAddress
    ) external view returns (uint256);

    function convertAssetAmountToUsdAmount(
        uint256 assetAmount,
        address assetAddress
    ) external view returns (uint256);

    function getUsdAmount(
        address market,
        uint256 assetAmount,
        address priceOracle
    ) external view returns (uint256 usdAmount);

    function getAssetAmount(
        address market,
        uint256 usdAmount,
        address priceOracle
    ) external view returns (uint256 assetAmount);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

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
    return add(a, b, "SafeMath: addition overflow");
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
  function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);

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

//SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
import "./MultiSigOwner.sol";
import "./libraries/SafeMath.sol";

contract OwnerConstants is MultiSigOwner {
    using SafeMath for uint256;
    // daily limit contants
    uint256 public constant MAX_LEVEL = 5;

    // this is reward address for user's withdraw and payment for goods.
    address public treasuryAddress;
    // this address should be deposit okse in his balance and users can get cashback from this address.
    address public financialAddress;
    // master address is used to send USDC tokens when user buy goods.
    address public masterAddress;
    // monthly fee rewarded address
    address public monthlyFeeAddress;

    // staking contract address, which is used to receive 20% of monthly fee, so staked users can be rewarded from this contract
    address public stakeContractAddress;
    // statking amount of monthly fee
    uint256 public stakePercent; // 15 %

    // withdraw fee and payment fee should not exeed this amount, 1% is coresponding to 100.
    uint256 public constant MAX_FEE_AMOUNT = 500; // 5%
    // buy fee setting.
    uint256 public buyFeePercent; // 1%

    // withdraw fee setting.
    uint256 public withdrawFeePercent; // 0.1 %

    // set monthly fee of user to use card payment, unit is usd amount ( 1e18)
    uint256 public monthlyFeeAmount; // 6.99 USD
    // if user pay monthly fee using okse, then he will pay less amount fro this percent. 0% => 0, 100% => 10000
    uint256 public okseMonthlyProfit; // 10%
    // buy tx fee in usd
    uint256 public buyTxFee; // 0.7 usd
    event ManagerAddressChanged(
        address treasuryAddress,
        address financialAddress,
        address masterAddress,
        address monthlyFeeAddress
    );
    event FeeValuesChanged(
        uint256 monthlyFeeAmount,
        uint256 okseMonthlyProfit,
        uint256 withdrawFeePercent,
        uint256 buyTxFee,
        uint256 buyFeePercent
    );
    event StakeContractParamChanged(
        address stakeContractAddress,
        uint256 stakePercent
    );

    constructor() {}

    function getMonthlyFeeAmount(bool payFromOkse)
        public
        view
        returns (uint256)
    {
        uint256 result;
        if (payFromOkse) {
            result = monthlyFeeAmount.sub(
                (monthlyFeeAmount.mul(okseMonthlyProfit)).div(10000)
            );
        } else {
            result = monthlyFeeAmount;
        }
        return result;
    }

    function setManagerAddresses(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setManagerAddresses")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (
            address _newTreasuryAddress,
            address _newFinancialAddress,
            address _newMasterAddress,
            address _mothlyFeeAddress
        ) = abi.decode(params, (address, address, address, address));

        treasuryAddress = _newTreasuryAddress;
        financialAddress = _newFinancialAddress;
        masterAddress = _newMasterAddress;
        monthlyFeeAddress = _mothlyFeeAddress;
        emit ManagerAddressChanged(
            treasuryAddress,
            financialAddress,
            masterAddress,
            monthlyFeeAddress
        );
    }

    // verified
    function setFeeValues(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "setFeeValues")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (
            uint256 _monthlyFeeAmount,
            uint256 _okseMonthlyProfit,
            uint256 _withdrawFeePercent,
            uint256 newBuyFeePercent,
            uint256 newBuyTxFee
        ) = abi.decode(params, (uint256, uint256, uint256, uint256, uint256));
        require(_okseMonthlyProfit <= 10000, "over percent");
        require(_withdrawFeePercent <= MAX_FEE_AMOUNT, "mfo");
        monthlyFeeAmount = _monthlyFeeAmount;
        okseMonthlyProfit = _okseMonthlyProfit;
        withdrawFeePercent = _withdrawFeePercent;
        require(newBuyFeePercent <= MAX_FEE_AMOUNT, "mpo");
        buyFeePercent = newBuyFeePercent;
        buyTxFee = newBuyTxFee;
        emit FeeValuesChanged(
            monthlyFeeAmount,
            okseMonthlyProfit,
            withdrawFeePercent,
            buyTxFee,
            buyFeePercent
        );
    }

    function setStakeContractParams(
        bytes calldata signData,
        bytes calldata keys
    ) public validSignOfOwner(signData, keys, "setStakeContractParams") {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address _stakeContractAddress, uint256 _stakePercent) = abi.decode(
            params,
            (address, uint256)
        );
        stakeContractAddress = _stakeContractAddress;
        stakePercent = _stakePercent;
        emit StakeContractParamChanged(stakeContractAddress, stakePercent);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping(address => bool) bearer;
  }

  /**
   * @dev Give an account access to this role.
   */
  function add(Role storage role, address account) internal {
    require(!has(role, account), "Roles: account already has role");
    role.bearer[account] = true;
  }

  /**
   * @dev Remove an account's access to this role.
   */
  function remove(Role storage role, address account) internal {
    // require(has(role, account), "Roles: account does not have role");
    role.bearer[account] = false;
  }

  /**
   * @dev Check if an account has this role.
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0), "Roles: account is the zero address");
    return role.bearer[account];
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor() {}

  // solhint-disable-previous-line no-empty-blocks

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

abstract contract SignerRole is Context {
  using Roles for Roles.Role;

  event SignerAdded(address indexed account);
  event SignerRemoved(address indexed account);

  Roles.Role private _signers;

  constructor(address _signer) {
    _addSigner(_signer);
  }

  modifier onlySigner() {
    require(
      isSigner(_msgSender()),
      "SignerRole: caller does not have the Signer role"
    );
    _;
  }

  function isSigner(address account) public view returns (bool) {
    return _signers.has(account);
  }

  function _addSigner(address account) internal {
    _signers.add(account);
    emit SignerAdded(account);
  }

  function _removeSigner(address account) internal {
    _signers.remove(account);
    emit SignerRemoved(account);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

// 2/3 Multi Sig Owner
contract MultiSigOwner {
    address[] public owners;
    mapping(uint256 => bool) public signatureId;
    bool private initialized;
    // events
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SignValidTimeChanged(uint256 newValue);
    modifier validSignOfOwner(
        bytes calldata signData,
        bytes calldata keys,
        string memory functionName
    ) {
        require(isOwner(msg.sender), "on");
        address signer = getSigner(signData, keys);
        require(
            signer != msg.sender && isOwner(signer) && signer != address(0),
            "is"
        );
        (bytes4 method, uint256 id, uint256 validTime, ) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        require(
            signatureId[id] == false &&
                method == bytes4(keccak256(bytes(functionName))),
            "sru"
        );
        require(validTime > block.timestamp, "ep");
        signatureId[id] = true;
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        bool _isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                _isOwner = true;
            }
        }
        return _isOwner;
    }

    constructor() {}

    function initializeOwners(address[3] memory _owners) public {
        require(
            !initialized &&
                _owners[0] != address(0) &&
                _owners[1] != address(0) &&
                _owners[2] != address(0),
            "ai"
        );
        owners = [_owners[0], _owners[1], _owners[2]];
        initialized = true;
    }

    function getSigner(bytes calldata _data, bytes calldata keys)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            keys,
            (uint8, bytes32, bytes32)
        );
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(abi.encodePacked(this, chainId, _data))
                ),
                v,
                r,
                s
            );
    }

    function encodePackedData(bytes calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encodePacked(this, chainId, _data));
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Set functions
    // verified
    function transferOwnership(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "transferOwnership")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address newOwner = abi.decode(params, (address));
        uint256 index;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                index = i;
            }
        }
        address oldOwner = owners[index];
        owners[index] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}