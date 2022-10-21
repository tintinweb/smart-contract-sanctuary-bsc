//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IVault.sol";
import "./interfaces/IDepositVault.sol";
import "./interfaces/IMintVault.sol";
import "./interfaces/IController.sol";
import "./interfaces/IStrategy.sol";
import "./Constants.sol";

contract AppController is Constants, IController, OwnableUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    uint256 constant JOINED_VAULT_LIMIT = 20;

    // underlying => dToken
    mapping(address => address) public override dyTokens;
    // underlying => IStratege
    mapping(address => address) public strategies;

    struct ValueConf {
        address oracle;
        uint16 dr; // discount rate
        uint16 pr; // premium rate
    }

    // underlying => orcale
    mapping(address => ValueConf) internal valueConfs;

    //  dyToken => vault
    mapping(address => address) public override dyTokenVaults;

    // user => vaults
    mapping(address => EnumerableSet.AddressSet) internal userJoinedDepositVaults;

    mapping(address => EnumerableSet.AddressSet) internal userJoinedBorrowVaults;

    // manage Vault state for risk control
    struct VaultState {
        bool enabled;
        bool enableDeposit;
        bool enableWithdraw;
        bool enableBorrow;
        bool enableRepay;
        bool enableLiquidate;
    }

    // Vault => VaultStatus
    mapping(address => VaultState) public vaultStates;

    // depost value / borrow value >= liquidateRate
    uint256 public liquidateRate;
    uint256 public collateralRate;

    // is anyone can call Liquidate.
    bool public isOpenLiquidate;

    mapping(address => bool) public allowedLiquidator;

    // vault => ValidVault
    // Initialize once
    mapping(address => ValidVault) public override validVaults;

    // vault => user => ValidVault
    // set by user
    mapping(address => mapping(address => ValidVault)) public override validVaultsOfUser;

    // vault => quota
    mapping(address => uint256) public vaultsBorrowQuota;
    // EVENT
    event UnderlyingDTokenChanged(address indexed underlying, address oldDToken, address newDToken);
    event UnderlyingStrategyChanged(address indexed underlying, address oldStrage, address newDToken, uint256 stype);
    event DTokenVaultChanged(address indexed dToken, address oldVault, address newVault, uint256 vtype);

    event ValueConfChanged(address indexed underlying, address oracle, uint256 discount, uint256 premium);

    event LiquidateRateChanged(uint256 liquidateRate);
    event CollateralRateChanged(uint256 collateralRate);

    event OpenLiquidateChanged(bool open);
    event AllowedLiquidatorChanged(address liquidator, bool allowed);

    event SetVaultStates(address vault, VaultState state);

    event InitValidVault(address vault, ValidVault state);
    event SetValidVault(address vault, address user, ValidVault state);

    event MintVaultReleased(address indexed user, address vault, uint256 amount, uint256 usdValue);
    event DepositVaultReleased(address indexed user, address vault, uint256 amount, uint256 usdValue);
    event VaultsReleased(address indexed user, uint256 expectedUsdValue, uint256 releasedUsdValue);
    event DepositVaultSwapped(
        address indexed user,
        address sourceVault,
        uint256 sourceAmount,
        address targetVault,
        uint256 targetAmount
    );
    event BorrowQuotaChanged(address vault, address operator, uint256 prevQuota, uint256 newQuota);

    constructor() initializer {}

    function initialize() external initializer {
        OwnableUpgradeable.__Ownable_init();
        liquidateRate = 11000;
        // PercentBase * 1.1;
        collateralRate = 13000;
        // PercentBase * 1.3;
        isOpenLiquidate = true;
    }

    // ======  yield =======
    function setDYToken(address _underlying, address _dToken) external onlyOwner {
        require(_dToken != address(0), "INVALID_DTOKEN");
        address oldDToken = dyTokens[_underlying];
        dyTokens[_underlying] = _dToken;
        emit UnderlyingDTokenChanged(_underlying, oldDToken, _dToken);
    }

    // set or update strategy
    // stype: 1: pancakeswap
    function setStrategy(
        address _underlying,
        address _strategy,
        uint256 stype
    ) external onlyOwner {
        require(_strategy != address(0), "Strategies Disabled");

        address _current = strategies[_underlying];
        if (_current != address(0)) {
            IStrategy(_current).withdrawAll();
        }
        strategies[_underlying] = _strategy;

        emit UnderlyingStrategyChanged(_underlying, _current, _strategy, stype);
    }

    function emergencyWithdrawAll(address _underlying) public onlyOwner {
        IStrategy(strategies[_underlying]).withdrawAll();
    }

    // ======  vault  =======
    function setVaultBorrowQuota(address vault_, uint256 quota_) external onlyOwner {
        emit BorrowQuotaChanged(vault_, msg.sender, vaultsBorrowQuota[vault_], quota_);
        vaultsBorrowQuota[vault_] = quota_;
    }

    function setOpenLiquidate(bool _open) external onlyOwner {
        isOpenLiquidate = _open;
        emit OpenLiquidateChanged(_open);
    }

    function updateAllowedLiquidator(address liquidator, bool allowed) external onlyOwner {
        allowedLiquidator[liquidator] = allowed;
        emit AllowedLiquidatorChanged(liquidator, allowed);
    }

    function setLiquidateRate(uint256 _liquidateRate) external onlyOwner {
        liquidateRate = _liquidateRate;
        emit LiquidateRateChanged(liquidateRate);
    }

    function setCollateralRate(uint256 _collateralRate) external onlyOwner {
        collateralRate = _collateralRate;
        emit CollateralRateChanged(collateralRate);
    }

    // @dev set different oracle、 discount rate and premium rate for each underlying asset
    function setOracles(
        address _underlying,
        address _oracle,
        uint16 _discount,
        uint16 _premium
    ) external onlyOwner {
        require(_oracle != address(0), "INVALID_ORACLE");
        require(_discount <= PercentBase, "DISCOUT_TOO_BIG");
        require(_premium >= PercentBase, "PREMIUM_TOO_SMALL");

        ValueConf storage conf = valueConfs[_underlying];
        conf.oracle = _oracle;
        conf.dr = _discount;
        conf.pr = _premium;

        emit ValueConfChanged(_underlying, _oracle, _discount, _premium);
    }

    function getValueConfs(address token0, address token1)
        external
        view
        returns (
            address oracle0,
            uint16 dr0,
            uint16 pr0,
            address oracle1,
            uint16 dr1,
            uint16 pr1
        )
    {
        (oracle0, dr0, pr0) = getValueConf(token0);
        (oracle1, dr1, pr1) = getValueConf(token1);
    }

    // get DiscountRate and PremiumRate
    function getValueConf(address _underlying)
        public
        view
        returns (
            address oracle,
            uint16 dr,
            uint16 pr
        )
    {
        ValueConf memory conf = valueConfs[_underlying];
        oracle = conf.oracle;
        dr = conf.dr;
        pr = conf.pr;
    }

    // vtype 1 : for deposit vault 2: for mint vault
    function setVault(
        address _dyToken,
        address _vault,
        uint256 vtype
    ) external onlyOwner {
        require(IVault(_vault).isDuetVault(), "INVALIE_VALUT");
        address old = dyTokenVaults[_dyToken];
        dyTokenVaults[_dyToken] = _vault;
        emit DTokenVaultChanged(_dyToken, old, _vault, vtype);
    }

    function joinVault(address _user, bool isDepositVault) external {
        address vault = msg.sender;
        require(vaultStates[vault].enabled || vaultStates[vault].enableLiquidate, "INVALID_CALLER");

        EnumerableSet.AddressSet storage set = isDepositVault
            ? userJoinedDepositVaults[_user]
            : userJoinedBorrowVaults[_user];
        require(set.length() < JOINED_VAULT_LIMIT, "JOIN_TOO_MUCH");
        set.add(vault);
    }

    function exitVault(address _user, bool isDepositVault) external {
        address vault = msg.sender;
        require(vaultStates[vault].enabled || vaultStates[vault].enableLiquidate, "INVALID_CALLER");

        EnumerableSet.AddressSet storage set = isDepositVault
            ? userJoinedDepositVaults[_user]
            : userJoinedBorrowVaults[_user];
        set.remove(vault);
    }

    function setVaultStates(address _vault, VaultState memory _state) external onlyOwner {
        vaultStates[_vault] = _state;
        emit SetVaultStates(_vault, _state);
    }

    function initValidVault(address[] memory _vault, ValidVault[] memory _state) external onlyOwner {
        uint256 len1 = _vault.length;
        uint256 len2 = _state.length;
        require(len1 == len2 && len1 != 0, "INVALID_PARAM");
        for (uint256 i = 0; i < len1; i++) {
            require(validVaults[_vault[i]] == ValidVault.UnInit, "SET_ONLY_ONCE");
            require(_state[i] == ValidVault.Yes || _state[i] == ValidVault.No, "INVALID_VALUE");
            validVaults[_vault[i]] = _state[i];
            emit InitValidVault(_vault[i], _state[i]);
        }
    }

    function setValidVault(address[] memory _vault, ValidVault[] memory _state) external {
        address user = msg.sender;
        uint256 len1 = _vault.length;
        uint256 len2 = _state.length;
        require(len1 == len2 && len1 != 0, "INVALID_PARAM");
        for (uint256 i = 0; i < len1; i++) {
            require(_state[i] == ValidVault.Yes || _state[i] == ValidVault.No, "INVALID_VALUE");
            validVaultsOfUser[_vault[i]][user] = _state[i];
            emit SetValidVault(_vault[i], user, _state[i]);
        }

        uint256 totalDepositValue = accValidVaultVaule(user, true);
        uint256 totalBorrowValue = accVaultVaule(user, userJoinedBorrowVaults[user], true);
        uint256 validValue = (totalDepositValue * PercentBase) / collateralRate;
        require(totalDepositValue * PercentBase >= totalBorrowValue * collateralRate, "SETVALIDVAULT: LOW_COLLATERAL");
    }

    function userJoinedVaultInfoAt(
        address _user,
        bool isDepositVault,
        uint256 index
    ) external view returns (address vault, VaultState memory state) {
        EnumerableSet.AddressSet storage set = isDepositVault
            ? userJoinedDepositVaults[_user]
            : userJoinedBorrowVaults[_user];
        vault = set.at(index);
        state = vaultStates[vault];
    }

    function userJoinedVaultCount(address _user, bool isDepositVault) external view returns (uint256) {
        return isDepositVault ? userJoinedDepositVaults[_user].length() : userJoinedBorrowVaults[_user].length();
    }

    /**
     * @notice  maximum that a user can borrow from a Vault
     */
    function maxBorrow(address _user, address vault) public view returns (uint256) {
        uint256 totalDepositValue = accValidVaultVaule(_user, true);
        uint256 totalBorrowValue = accVaultVaule(_user, userJoinedBorrowVaults[_user], true);

        uint256 validValue = (totalDepositValue * PercentBase) / collateralRate;
        if (validValue > totalBorrowValue) {
            uint256 canBorrowValue = validValue - totalBorrowValue;
            return IMintVault(vault).valueToAmount(canBorrowValue, true);
        } else {
            return 0;
        }
    }

    /**
     * @notice Get user total valid Vault value (i.e., Vault of deposit only counts collateral)
     * @param  _user depositors
     * @param _dp  discount or premium
     */
    function userValues(address _user, bool _dp)
        public
        view
        override
        returns (uint256 totalDepositValue, uint256 totalBorrowValue)
    {
        totalDepositValue = accValidVaultVaule(_user, _dp);
        totalBorrowValue = accVaultVaule(_user, userJoinedBorrowVaults[_user], _dp);
    }

    /**
     * @notice  Get user total Vault value
     * @param  _user depositors
     * @param _dp  discount or premium
     */
    function userTotalValues(address _user, bool _dp)
        public
        view
        returns (uint256 totalDepositValue, uint256 totalBorrowValue)
    {
        totalDepositValue = accVaultVaule(_user, userJoinedDepositVaults[_user], _dp);
        totalBorrowValue = accVaultVaule(_user, userJoinedBorrowVaults[_user], _dp);
    }

    /**
     * @notice predict total valid vault value after the user operating vault (i.e., Vault of deposit only counts collateral)
     * @param  _user depositors
     * @param  _vault target vault
     * @param  _amount the amount of deposits or withdrawals
     * @param _dp  discount or premium
     */
    function userPendingValues(
        address _user,
        IVault _vault,
        int256 _amount,
        bool _dp
    ) public view returns (uint256 pendingDepositValue, uint256 pendingBrorowValue) {
        pendingDepositValue = accValidPendingValue(_user, _vault, _amount, _dp);
        pendingBrorowValue = accPendingValue(_user, userJoinedBorrowVaults[_user], _vault, _amount, _dp);
    }

    /**
     * @notice  predict total vault value after the user operating Vault
     * @param  _user depositors
     * @param  _vault target vault
     * @param  _amount the amount of deposits or withdrawals
     * @param _dp  discount or premium
     */
    function userTotalPendingValues(
        address _user,
        IVault _vault,
        int256 _amount,
        bool _dp
    ) public view returns (uint256 pendingDepositValue, uint256 pendingBrorowValue) {
        pendingDepositValue = accPendingValue(_user, userJoinedDepositVaults[_user], _vault, _amount, _dp);
        pendingBrorowValue = accPendingValue(_user, userJoinedBorrowVaults[_user], _vault, _amount, _dp);
    }

    /**
     * @notice  determine whether the borrower needs to be liquidated
     */
    function isNeedLiquidate(address _borrower) public view returns (bool) {
        (uint256 totalDepositValue, uint256 totalBorrowValue) = userValues(_borrower, true);
        return totalDepositValue * PercentBase < totalBorrowValue * liquidateRate;
    }

    /**
     * @dev return total value of vault
     *
     * @param _user address of user
     * @param set all address of vault
     * @param _dp Discount or Premium
     */
    function accVaultVaule(
        address _user,
        EnumerableSet.AddressSet storage set,
        bool _dp
    ) internal view returns (uint256 totalValue) {
        uint256 len = set.length();
        for (uint256 i = 0; i < len; i++) {
            address vault = set.at(i);
            totalValue += IVault(vault).userValue(_user, _dp);
        }
    }

    /**
     * @dev return total deposit collateral's value of vault
     *
     * @param _user address of user
     * @param _dp Discount or Premium
     */
    function accValidVaultVaule(address _user, bool _dp) internal view returns (uint256 totalValue) {
        EnumerableSet.AddressSet storage set = userJoinedDepositVaults[_user];
        uint256 len = set.length();
        for (uint256 i = 0; i < len; i++) {
            address vault = set.at(i);
            if (isCollateralizedVault(vault, _user)) {
                totalValue += IVault(vault).userValue(_user, _dp);
            }
        }
    }

    function accPendingValue(
        address _user,
        EnumerableSet.AddressSet storage set,
        IVault vault,
        int256 amount,
        bool _dp
    ) internal view returns (uint256 totalValue) {
        uint256 len = set.length();
        bool existVault = false;

        for (uint256 i = 0; i < len; i++) {
            IVault _vault = IVault(set.at(i));

            if (vault == _vault) {
                totalValue += _vault.pendingValue(_user, amount);
                existVault = true;
            } else {
                totalValue += _vault.userValue(_user, _dp);
            }
        }

        if (!existVault) {
            totalValue += vault.pendingValue(_user, amount);
        }
    }

    function accValidPendingValue(
        address _user,
        IVault vault,
        int256 amount,
        bool _dp
    ) internal view returns (uint256 totalValue) {
        EnumerableSet.AddressSet storage set = userJoinedDepositVaults[_user];
        uint256 len = set.length();
        bool existVault = false;

        for (uint256 i = 0; i < len; i++) {
            IVault _vault = IVault(set.at(i));

            if (isCollateralizedVault(address(_vault), _user)) {
                if (vault == _vault) {
                    totalValue += _vault.pendingValue(_user, amount);
                    existVault = true;
                } else {
                    totalValue += _vault.userValue(_user, _dp);
                }
            }
        }

        if (!existVault && isCollateralizedVault(address(vault), _user)) {
            totalValue += vault.pendingValue(_user, amount);
        }
    }

    /**
     * @notice return bool, true means the vault is as collateral to user, false is opposite
     * @param  _vault address of vault
     * @param _user   address of user
     */
    function isCollateralizedVault(address _vault, address _user) internal view returns (bool) {
        ValidVault _state = validVaultsOfUser[_vault][_user];
        ValidVault state = _state == ValidVault.UnInit ? validVaults[_vault] : _state;
        require(state != ValidVault.UnInit, "VALIDVAULT_UNINIT");

        if (state == ValidVault.Yes) return true;
        // vault can be collateralized
        return false;
    }

    /**
     * @notice Risk control check before deposit
     * param _user depositors
     * @param _vault address of deposit market
     * param  _amount deposit amount
     */
    function beforeDeposit(
        address,
        address _vault,
        uint256
    ) external view {
        VaultState memory state = vaultStates[_vault];
        require(state.enabled && state.enableDeposit, "DEPOSITE_DISABLE");
    }

    /**
     * @notice Risk control check before borrowing
     * @param  _user borrower
     * @param _vault address of loan market
     * @param  _amount loan amount
     */
    function beforeBorrow(
        address _user,
        address _vault,
        uint256 _amount
    ) external view {
        VaultState memory state = vaultStates[_vault];
        require(state.enabled && state.enableBorrow, "BORROW_DISABLED");
        uint256 borrowQuota = vaultsBorrowQuota[_vault];
        uint256 borrowedAmount = IERC20(IVault(_vault).underlying()).totalSupply();
        require(
            borrowQuota == 0 || borrowedAmount + _amount <= borrowQuota,
            "AppController: amount to borrow exceeds quota"
        );

        uint256 totalDepositValue = accValidVaultVaule(_user, true);
        uint256 pendingBrorowValue = accPendingValue(
            _user,
            userJoinedBorrowVaults[_user],
            IVault(_vault),
            int256(_amount),
            true
        );
        require(totalDepositValue * PercentBase >= pendingBrorowValue * collateralRate, "LOW_COLLATERAL");
    }

    function beforeWithdraw(
        address _user,
        address _vault,
        uint256 _amount
    ) external view {
        VaultState memory state = vaultStates[_vault];
        require(state.enabled && state.enableWithdraw, "WITHDRAW_DISABLED");

        if (isCollateralizedVault(_vault, _user)) {
            uint256 pendingDepositValidValue = accValidPendingValue(
                _user,
                IVault(_vault),
                int256(0) - int256(_amount),
                true
            );
            uint256 totalBorrowValue = accVaultVaule(_user, userJoinedBorrowVaults[_user], true);
            require(pendingDepositValidValue * PercentBase >= totalBorrowValue * collateralRate, "LOW_COLLATERAL");
        }
    }

    function beforeRepay(
        address _repayer,
        address _vault,
        uint256 _amount
    ) external view {
        VaultState memory state = vaultStates[_vault];
        require(state.enabled && state.enableRepay, "REPAY_DISABLED");
    }

    function liquidate(address _borrower, bytes calldata data) external {
        address liquidator = msg.sender;

        require(isOpenLiquidate || allowedLiquidator[liquidator], "INVALID_LIQUIDATOR");
        require(isNeedLiquidate(_borrower), "COLLATERAL_ENOUGH");

        EnumerableSet.AddressSet storage set = userJoinedDepositVaults[_borrower];
        uint256 len = set.length();

        for (uint256 i = len; i > 0; i--) {
            IVault v = IVault(set.at(i - 1));
            // liquidate valid vault
            if (isCollateralizedVault(address(v), _borrower)) {
                beforeLiquidate(_borrower, address(v));
                v.liquidate(liquidator, _borrower, data);
            }
        }

        EnumerableSet.AddressSet storage set2 = userJoinedBorrowVaults[_borrower];
        uint256 len2 = set2.length();

        for (uint256 i = len2; i > 0; i--) {
            IVault v = IVault(set2.at(i - 1));
            beforeLiquidate(_borrower, address(v));
            v.liquidate(liquidator, _borrower, data);
        }
    }

    function releaseMintVaults(
        address user_,
        address liquidator_,
        IVault[] calldata mintVaults_
    ) external onlyOwner {
        require(allowedLiquidator[liquidator_], "Invalid liquidator");

        EnumerableSet.AddressSet storage depositedVaults = userJoinedDepositVaults[user_];

        uint256 usdValueToRelease = 0;
        bytes memory liquidateData = abi.encodePacked(uint256(0x1));
        // release mint vaults
        for (uint256 i = 0; i < mintVaults_.length; i++) {
            IVault v = mintVaults_[i];
            uint256 currentVaultUsdValue = v.userValue(user_, false);
            uint256 currentVaultAmount = IMintVault(address(v)).borrows(user_);
            usdValueToRelease += currentVaultUsdValue;
            v.liquidate(liquidator_, user_, liquidateData);
            emit MintVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
        }

        // No release required
        if (usdValueToRelease <= 0) {
            return;
        }
        uint256 releasedUsdValue = 0;

        // release deposit vaults
        for (uint256 i = depositedVaults.length(); i > 0; i--) {
            IVault v = IVault(depositedVaults.at(i - 1));

            // invalid vault
            if (!isCollateralizedVault(address(v), user_) || !vaultStates[address(v)].enableLiquidate) {
                continue;
            }
            uint256 currentVaultUsdValue = v.userValue(user_, false);
            releasedUsdValue += currentVaultUsdValue;
            uint256 currentVaultAmount = IDepositVault(address(v)).deposits(user_);
            v.liquidate(liquidator_, user_, liquidateData);
            if (releasedUsdValue == usdValueToRelease) {
                emit DepositVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
                // release done
                break;
            }
            if (releasedUsdValue < usdValueToRelease) {
                emit DepositVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
                continue;
            }
            // over released, returning
            uint256 usdDelta = releasedUsdValue - usdValueToRelease;
            // The minimum usd value to return is $1
            if (usdDelta < 1e8) {
                emit DepositVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
                break;
            }
            uint256 amountToReturn = (currentVaultAmount * usdDelta * 1e12) / currentVaultUsdValue / 1e12;
            // possible precision issues
            if (amountToReturn > currentVaultAmount) {
                amountToReturn = currentVaultAmount;
            }
            // return over released tokens
            IERC20(v.underlying()).safeTransferFrom(liquidator_, address(this), amountToReturn);
            IERC20(v.underlying()).safeApprove(address(v), amountToReturn);
            _depositForUser(v, user_, amountToReturn);
            emit DepositVaultReleased(
                user_,
                address(v),
                currentVaultAmount - amountToReturn,
                currentVaultUsdValue - usdDelta
            );
            releasedUsdValue -= usdDelta;
            break;
        }

        emit VaultsReleased(user_, usdValueToRelease, releasedUsdValue);
    }

    function releaseZeroValueVaults(address user_, address liquidator_) external onlyOwner {
        require(allowedLiquidator[liquidator_], "Invalid liquidator");

        bytes memory liquidateData = abi.encodePacked(uint256(0x1));

        EnumerableSet.AddressSet storage mintVaults = userJoinedBorrowVaults[user_];
        // release mint vaults with zero usd value
        for (uint256 i = 0; i < mintVaults.length(); i++) {
            IVault v = IVault(mintVaults.at(i));
            uint256 currentVaultUsdValue = v.userValue(user_, false);
            if (currentVaultUsdValue > 0) {
                continue;
            }
            uint256 currentVaultAmount = IMintVault(address(v)).borrows(user_);
            v.liquidate(liquidator_, user_, liquidateData);
            emit MintVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
        }

        EnumerableSet.AddressSet storage depositedVaults = userJoinedDepositVaults[user_];
        // release deposit vaults with zero usd value
        for (uint256 i = 0; i < depositedVaults.length(); i++) {
            IVault v = IVault(depositedVaults.at(i));
            uint256 currentVaultUsdValue = v.userValue(user_, false);
            // 0x1E3174C5757cf5457f8A3A8c3E4a35Ed2d138322 is vault of Smart BUSD, force close.
            if (currentVaultUsdValue > 0 && address(v) != 0x1E3174C5757cf5457f8A3A8c3E4a35Ed2d138322) {
                continue;
            }
            uint256 currentVaultAmount = IDepositVault(address(v)).deposits(user_);
            v.liquidate(liquidator_, user_, liquidateData);
            emit DepositVaultReleased(user_, address(v), currentVaultAmount, currentVaultUsdValue);
        }
    }

    function swapUserDepositVaults(
        address user_,
        address liquidator_,
        IVault[] calldata sourceVaults_,
        IVault[] calldata targetVaults_
    ) external onlyOwner {
        require(allowedLiquidator[liquidator_], "Invalid liquidator");

        require(sourceVaults_.length > 0, "nothing to swap");
        require(
            sourceVaults_.length == targetVaults_.length,
            "length of sourceVaults_ should be equal to targetVaults_'s"
        );

        bytes memory liquidateData = abi.encodePacked(uint256(0x1));

        for (uint256 i = 0; i < sourceVaults_.length; i++) {
            IVault sourceVault = sourceVaults_[i];
            IVault targetVault = targetVaults_[i];
            uint256 sourceVaultUsdValue = sourceVault.userValue(user_, false);
            uint256 sourceVaultAmount = IDepositVault(address(sourceVault)).deposits(user_);
            sourceVault.liquidate(liquidator_, user_, liquidateData);
            // set dUSD-DUET LP Price to 0.306
            if (address(sourceVault) == 0x4527Ba20F16F86525b6D174b6314502ca6D5256E) {
                // 306e5 = 0.306$
                sourceVaultUsdValue = sourceVaultAmount * 306e5;
                // set dUSD-BUSD LP Price to 2.02
            } else if (address(sourceVault) == 0xC703Fdad6cA5DF56bd729fef24157e196A4810f8) {
                // 202e6 = 2.02$
                sourceVaultUsdValue = sourceVaultAmount * 202e6;
            }
            if (sourceVaultUsdValue <= 0) {
                continue;
            }
            uint256 targetPrice = targetVault.underlyingAmountValue(1e18, false);
            uint256 targetVaultAmount = (sourceVaultUsdValue * 1e12) / targetPrice / 1e12;
            IERC20(targetVault.underlying()).safeTransferFrom(msg.sender, address(this), targetVaultAmount);
            IERC20(targetVault.underlying()).safeApprove(address(targetVault), targetVaultAmount);
            _depositForUser(targetVault, user_, targetVaultAmount);
            emit DepositVaultSwapped(
                user_,
                address(sourceVault),
                sourceVaultAmount,
                address(targetVault),
                targetVaultAmount
            );
        }
    }

    function _depositForUser(
        IVault depositVault_,
        address user_,
        uint256 amount_
    ) internal {
        IDepositVault(address(depositVault_)).depositTo(depositVault_.underlying(), user_, amount_);
    }

    function beforeLiquidate(address _borrower, address _vault) internal view {
        VaultState memory state = vaultStates[_vault];
        require(state.enabled && state.enableLiquidate, "LIQ_DISABLED");
    }
    //  ======   vault end =======
}

// SPDX-License-Identifier: MIT

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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
pragma solidity >=0.8.0;

interface IVault {
    // call from controller must impl.
    function underlying() external view returns (address);

    function isDuetVault() external view returns (bool);

    function liquidate(
        address liquidator,
        address borrower,
        bytes calldata data
    ) external;

    function userValue(address user, bool dp) external view returns (uint256);

    function pendingValue(address user, int256 pending) external view returns (uint256);

    function underlyingAmountValue(uint256 amount, bool dp) external view returns (uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IDepositVault {
    function deposits(address user) external view returns (uint256 amount);

    function deposit(address dtoken, uint256 amount) external;

    function depositTo(
        address dtoken,
        address to,
        uint256 amount
    ) external;

    function syncDeposit(
        address dtoken,
        uint256 amount,
        address user
    ) external;

    function withdraw(uint256 amount, bool unpack) external;

    function withdrawTo(
        address to,
        uint256 amount,
        bool unpack
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMintVault {
    function borrows(address user) external view returns (uint256 amount);

    function borrow(uint256 amount) external;

    function repay(uint256 amount) external;

    function repayTo(address to, uint256 amount) external;

    function valueToAmount(uint256 value, bool dp) external view returns (uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IController {
    function dyTokens(address) external view returns (address);

    function getValueConf(address _underlying)
        external
        view
        returns (
            address oracle,
            uint16 dr,
            uint16 pr
        );

    function getValueConfs(address token0, address token1)
        external
        view
        returns (
            address oracle0,
            uint16 dr0,
            uint16 pr0,
            address oracle1,
            uint16 dr1,
            uint16 pr1
        );

    function strategies(address) external view returns (address);

    function dyTokenVaults(address) external view returns (address);

    function beforeDeposit(
        address,
        address _vault,
        uint256
    ) external view;

    function beforeBorrow(
        address _borrower,
        address _vault,
        uint256 _amount
    ) external view;

    function beforeWithdraw(
        address _redeemer,
        address _vault,
        uint256 _amount
    ) external view;

    function beforeRepay(
        address _repayer,
        address _vault,
        uint256 _amount
    ) external view;

    function joinVault(address _user, bool isDeposit) external;

    function exitVault(address _user, bool isDeposit) external;

    function userValues(address _user, bool _dp)
        external
        view
        returns (uint256 totalDepositValue, uint256 totalBorrowValue);

    function userTotalValues(address _user, bool _dp)
        external
        view
        returns (uint256 totalDepositValue, uint256 totalBorrowValue);

    function liquidate(address _borrower, bytes calldata data) external;

    // ValidVault 0: uninitialized, default value
    // ValidVault 1: No, vault can not be collateralized
    // ValidVault 2: Yes, vault can be collateralized
    enum ValidVault {
        UnInit,
        No,
        Yes
    }

    function validVaults(address _vault) external view returns (ValidVault);

    function validVaultsOfUser(address _vault, address _user) external view returns (ValidVault);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IStrategy {
    function controller() external view returns (address);

    function getWant() external view returns (address);

    function deposit() external;

    function harvest() external;

    function withdraw(uint256) external;

    function withdrawAll() external returns (uint256);

    function balanceOf() external view returns (uint256);

    function pendingOutput() external view returns (uint256);

    function minHarvestAmount() external view returns (uint256);

    function output() external view returns (address);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Constants {
    uint256 internal constant PercentBase = 10000;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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