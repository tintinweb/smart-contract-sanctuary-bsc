// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.12;

import "./mdtERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract mdtLogic is Initializable, ReentrancyGuard, Context {
    using SafeERC20 for mdtERC20;
    using SafeERC20 for IERC20;
    using Address for address;
    using Counters for Counters.Counter;

    uint256 internal RATE;
    address internal GNOSIS;
    address internal DOLLAR;
    address internal ROYALTY;
    mdtERC20 internal CREDIT;
    IUniswapV2Router02 internal ROUTER;

    ShareStruct internal SHARE;
    struct ShareStruct {
        uint256 GNOSIS;
        uint256 ROYALTY;
    }

    GovernanceStruct internal GOVERNANCE;
    struct GovernanceStruct {
        uint256 DOLLAR_PEGGED_PER_CREDIT;
        uint256 CREDIT_PER_LOYALTY_POINT;
        uint256 CREDIT_PER_MARKSMAN_DAILY;
        uint256 CREDIT_PER_MARKSMAN_WEEKLY;
        uint256 CREDIT_PER_MARKSMAN_MONTHLY;
        uint256 CREDIT_PER_MARKSMAN_INDEFINITE;
        uint256 CREDIT_PER_SNIPER_WALLETS_COUNT;
    }

    DiscountsStruct internal DISCOUNTS;
    struct DiscountsStruct {
        uint256 SPECIAL_CLI;
        uint256 SPECIAL_UI;
        uint256 DIAMOND_CLI;
        uint256 DIAMOND_UI;
        uint256 GOLD_CLI;
        uint256 GOLD_UI;
        uint256 SILVER_CLI;
        uint256 SILVER_UI;
        uint256 BRONZE_CLI;
        uint256 BRONZE_UI;
    }

    LoyaltyStruct internal LOYALTY;
    struct LoyaltyStruct {
        uint256 BURN;
        uint256 MINT;
        uint256 SPEND;
    }

    mapping(address => bool) internal RELAYER_ROLE;
    mapping(address => bool) internal BLACKLIST_ROLE;

    mapping(address => bool) internal SPECIAL_ROLE;
    mapping(address => bool) internal DIAMOND_ROLE;
    mapping(address => bool) internal GOLD_ROLE;
    mapping(address => bool) internal SILVER_ROLE;
    mapping(address => bool) internal BRONZE_ROLE;

    Counters.Counter internal SNIPE;
    Counters.Counter internal SNIPER;
    mapping(address => bool) internal SNIPER_REGISTERED;
    mapping(address => uint256) internal SNIPER_LOYALTY_POINT;
    mapping(address => uint256) internal SNIPER_MARKSMAN_STATUS;
    mapping(address => Counters.Counter) internal SNIPER_WALLETS_COUNT;

    mapping(uint256 => uint256) internal BLOCKCHAIN_MULTIPLIER;

    event RoleGranted(
        address indexed account,
        address indexed sender,
        string role
    );

    event RoleRevoked(
        address indexed account,
        address indexed sender,
        string role
    );

    event LoyaltyUpdated(
        address indexed account,
        uint256 beforePoint,
        uint256 afterPoint
    );

    event MarksmanUpdated(
        address indexed account,
        uint256 startTime,
        uint256 endTime
    );

    event WalletsUpdated(
        address indexed account,
        uint256 beforeCount,
        uint256 afterCount
    );

    modifier onlyGnosis() {
        require(_msgSender() == GNOSIS, "Not Gnosis");
        _;
    }

    modifier onlyRelayer() {
        require(RELAYER_ROLE[_msgSender()], "Not Relayer");
        _;
    }

    modifier registerSnipe() {
        SNIPE.increment();
        _;
    }

    modifier registerSniper() {
        if (!SNIPER_REGISTERED[_msgSender()]) {
            SNIPER_REGISTERED[_msgSender()] = true;
            SNIPER.increment();
        }
        _;
    }

    constructor() initializer {}

    function initialize(
        uint256 _rate,
        address _gnosis,
        address _dollar,
        address _royalty,
        address _router
    ) external initializer {
        require(
            _gnosis.isContract() &&
                _dollar.isContract() &&
                _royalty.isContract() &&
                _router.isContract(),
            "Invalid Initialization"
        );

        RATE = _rate;
        GNOSIS = _gnosis;
        DOLLAR = _dollar;
        ROYALTY = _royalty;
        CREDIT = new mdtERC20();
        ROUTER = IUniswapV2Router02(_router);
        _setShareDefault();
        _setGovernanceDefault();
        _setDiscountsDefault();
        _setLoyaltyDefault();
    }

    receive() external payable {}

    function recoverEth() external onlyGnosis {
        payable(GNOSIS).transfer(address(this).balance);
    }

    function recoverToken(IERC20 _token) external onlyGnosis {
        _token.safeTransfer(GNOSIS, _token.balanceOf(address(this)));
    }

    function rate() external view returns (uint256) {
        return RATE;
    }

    function setRate(uint256 _rate) external onlyGnosis {
        RATE = _rate;
    }

    function gnosis() external view returns (address) {
        return GNOSIS;
    }

    function dollar() external view returns (address) {
        return DOLLAR;
    }

    function royalty() external view returns (address) {
        return ROYALTY;
    }

    function credit() external view returns (address) {
        return address(CREDIT);
    }

    function router() external view returns (address) {
        return address(ROUTER);
    }

    function share() external view returns (ShareStruct memory) {
        return SHARE;
    }

    function setShare(uint256 _gnosis, uint256 _royalty) external onlyGnosis {
        if (_gnosis == 0 && _royalty == 0) {
            _setShareDefault();
        } else {
            require(_gnosis + _royalty == 100, "Invalid Share");

            SHARE = ShareStruct({GNOSIS: _gnosis, ROYALTY: _royalty});
        }
    }

    function _setShareDefault() internal {
        SHARE = ShareStruct({GNOSIS: 80, ROYALTY: 20});
    }

    function governance() external view returns (GovernanceStruct memory) {
        return GOVERNANCE;
    }

    function setGovernance(
        uint256 _dollar_pegged_per_credit,
        uint256 _credit_per_loyalty_point,
        uint256 _credit_per_marksman_daily,
        uint256 _credit_per_marksman_weekly,
        uint256 _credit_per_marksman_monthly,
        uint256 _credit_per_marksman_indefinite,
        uint256 _credit_per_sniper_wallets_count
    ) external onlyGnosis {
        if (
            _dollar_pegged_per_credit == 0 &&
            _credit_per_loyalty_point == 0 &&
            _credit_per_marksman_daily == 0 &&
            _credit_per_marksman_weekly == 0 &&
            _credit_per_marksman_monthly == 0 &&
            _credit_per_marksman_indefinite == 0 &&
            _credit_per_sniper_wallets_count == 0
        ) {
            _setGovernanceDefault();
        } else {
            require(_dollar_pegged_per_credit != 0, "Math Overflow");

            GOVERNANCE = GovernanceStruct({
                DOLLAR_PEGGED_PER_CREDIT: _dollar_pegged_per_credit,
                CREDIT_PER_LOYALTY_POINT: _credit_per_loyalty_point,
                CREDIT_PER_MARKSMAN_DAILY: _credit_per_marksman_daily,
                CREDIT_PER_MARKSMAN_WEEKLY: _credit_per_marksman_weekly,
                CREDIT_PER_MARKSMAN_MONTHLY: _credit_per_marksman_monthly,
                CREDIT_PER_MARKSMAN_INDEFINITE: _credit_per_marksman_indefinite,
                CREDIT_PER_SNIPER_WALLETS_COUNT: _credit_per_sniper_wallets_count
            });
        }
    }

    function _setGovernanceDefault() internal {
        GOVERNANCE = GovernanceStruct({
            DOLLAR_PEGGED_PER_CREDIT: 100,
            CREDIT_PER_LOYALTY_POINT: 5,
            CREDIT_PER_MARKSMAN_DAILY: 15000,
            CREDIT_PER_MARKSMAN_WEEKLY: 52500,
            CREDIT_PER_MARKSMAN_MONTHLY: 105000,
            CREDIT_PER_MARKSMAN_INDEFINITE: 157500,
            CREDIT_PER_SNIPER_WALLETS_COUNT: 25000
        });
    }

    function discounts() external view returns (DiscountsStruct memory) {
        return DISCOUNTS;
    }

    function setDiscounts(
        uint256 _special_cli,
        uint256 _special_ui,
        uint256 _diamond_cli,
        uint256 _diamond_ui,
        uint256 _gold_cli,
        uint256 _gold_ui,
        uint256 _silver_cli,
        uint256 _silver_ui,
        uint256 _bronze_cli,
        uint256 _bronze_ui
    ) external onlyGnosis {
        if (
            _special_cli == 0 &&
            _special_ui == 0 &&
            _diamond_cli == 0 &&
            _diamond_ui == 0 &&
            _gold_cli == 0 &&
            _gold_ui == 0 &&
            _silver_cli == 0 &&
            _silver_ui == 0 &&
            _bronze_cli == 0 &&
            _bronze_ui == 0
        ) {
            _setDiscountsDefault();
        } else {
            DISCOUNTS = DiscountsStruct({
                SPECIAL_CLI: _special_cli,
                SPECIAL_UI: _special_ui,
                DIAMOND_CLI: _diamond_cli,
                DIAMOND_UI: _diamond_ui,
                GOLD_CLI: _gold_cli,
                GOLD_UI: _gold_ui,
                SILVER_CLI: _silver_cli,
                SILVER_UI: _silver_ui,
                BRONZE_CLI: _bronze_cli,
                BRONZE_UI: _bronze_ui
            });
        }
    }

    function _setDiscountsDefault() internal {
        DISCOUNTS = DiscountsStruct({
            SPECIAL_CLI: 100,
            SPECIAL_UI: 100,
            DIAMOND_CLI: 100,
            DIAMOND_UI: 75,
            GOLD_CLI: 75,
            GOLD_UI: 75,
            SILVER_CLI: 50,
            SILVER_UI: 50,
            BRONZE_CLI: 25,
            BRONZE_UI: 25
        });
    }

    function loyalty() external view returns (LoyaltyStruct memory) {
        return LOYALTY;
    }

    function setLoyalty(
        uint256 _burn,
        uint256 _mint,
        uint256 _spend
    ) external onlyGnosis {
        if (_burn == 0 && _mint == 0 && _spend == 0) {
            _setLoyaltyDefault();
        } else {
            LOYALTY = LoyaltyStruct({BURN: _burn, MINT: _mint, SPEND: _spend});
        }
    }

    function _setLoyaltyDefault() internal {
        LOYALTY = LoyaltyStruct({BURN: 50, MINT: 100, SPEND: 50});
    }

    function relayer(address _account) external view returns (bool) {
        return RELAYER_ROLE[_account];
    }

    function addRelayer(address _account) external onlyGnosis {
        if (!RELAYER_ROLE[_account]) {
            RELAYER_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "RELAYER_ROLE");
        }
    }

    function removeRelayer(address _account) external onlyGnosis {
        if (RELAYER_ROLE[_account]) {
            RELAYER_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "RELAYER_ROLE");
        }
    }

    function blacklist(address _account) external view returns (bool) {
        return BLACKLIST_ROLE[_account];
    }

    function addBlacklist(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            if (!BLACKLIST_ROLE[_accounts[i]]) {
                BLACKLIST_ROLE[_accounts[i]] = true;
                emit RoleGranted(_accounts[i], _msgSender(), "BLACKLIST_ROLE");
            }
        }
    }

    function removeBlacklist(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            if (BLACKLIST_ROLE[_accounts[i]]) {
                BLACKLIST_ROLE[_accounts[i]] = false;
                emit RoleRevoked(_accounts[i], _msgSender(), "BLACKLIST_ROLE");
            }
        }
    }

    function special(address _account) external view returns (bool) {
        return SPECIAL_ROLE[_account];
    }

    function _addSpecial(address _account) internal {
        if (!SPECIAL_ROLE[_account]) {
            SPECIAL_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "SPECIAL_ROLE");
        }
    }

    function _removeSpecial(address _account) internal {
        if (SPECIAL_ROLE[_account]) {
            SPECIAL_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "SPECIAL_ROLE");
        }
    }

    function upgradeSpecial(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _addSpecial(_accounts[i]);
            _removeDiamond(_accounts[i]);
            _removeGold(_accounts[i]);
            _removeSilver(_accounts[i]);
            _removeBronze(_accounts[i]);
        }
    }

    function diamond(address _account) external view returns (bool) {
        return DIAMOND_ROLE[_account];
    }

    function _addDiamond(address _account) internal {
        if (!DIAMOND_ROLE[_account]) {
            DIAMOND_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "DIAMOND_ROLE");
        }
    }

    function _removeDiamond(address _account) internal {
        if (DIAMOND_ROLE[_account]) {
            DIAMOND_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "DIAMOND_ROLE");
        }
    }

    function upgradeDiamond(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSpecial(_accounts[i]);
            _addDiamond(_accounts[i]);
            _removeGold(_accounts[i]);
            _removeSilver(_accounts[i]);
            _removeBronze(_accounts[i]);
        }
    }

    function gold(address _account) external view returns (bool) {
        return GOLD_ROLE[_account];
    }

    function _addGold(address _account) internal {
        if (!GOLD_ROLE[_account]) {
            GOLD_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "GOLD_ROLE");
        }
    }

    function _removeGold(address _account) internal {
        if (GOLD_ROLE[_account]) {
            GOLD_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "GOLD_ROLE");
        }
    }

    function upgradeGold(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSpecial(_accounts[i]);
            _removeDiamond(_accounts[i]);
            _addGold(_accounts[i]);
            _removeSilver(_accounts[i]);
            _removeBronze(_accounts[i]);
        }
    }

    function silver(address _account) external view returns (bool) {
        return SILVER_ROLE[_account];
    }

    function _addSilver(address _account) internal {
        if (!SILVER_ROLE[_account]) {
            SILVER_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "SILVER_ROLE");
        }
    }

    function _removeSilver(address _account) internal {
        if (SILVER_ROLE[_account]) {
            SILVER_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "SILVER_ROLE");
        }
    }

    function upgradeSilver(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSpecial(_accounts[i]);
            _removeDiamond(_accounts[i]);
            _removeGold(_accounts[i]);
            _addSilver(_accounts[i]);
            _removeBronze(_accounts[i]);
        }
    }

    function bronze(address _account) external view returns (bool) {
        return BRONZE_ROLE[_account];
    }

    function _addBronze(address _account) internal {
        if (!BRONZE_ROLE[_account]) {
            BRONZE_ROLE[_account] = true;
            emit RoleGranted(_account, _msgSender(), "BRONZE_ROLE");
        }
    }

    function _removeBronze(address _account) internal {
        if (BRONZE_ROLE[_account]) {
            BRONZE_ROLE[_account] = false;
            emit RoleRevoked(_account, _msgSender(), "BRONZE_ROLE");
        }
    }

    function upgradeBronze(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSpecial(_accounts[i]);
            _removeDiamond(_accounts[i]);
            _removeGold(_accounts[i]);
            _removeSilver(_accounts[i]);
            _addBronze(_accounts[i]);
        }
    }

    function revokeRoles(address[] memory _accounts) external onlyRelayer {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSpecial(_accounts[i]);
            _removeDiamond(_accounts[i]);
            _removeGold(_accounts[i]);
            _removeSilver(_accounts[i]);
            _removeBronze(_accounts[i]);
        }
    }

    function snipe() external view returns (uint256) {
        return SNIPE.current();
    }

    function sniper() external view returns (uint256) {
        return SNIPER.current();
    }

    function sniperLoyaltyPoint(address _account)
        external
        view
        returns (uint256)
    {
        return SNIPER_LOYALTY_POINT[_account];
    }

    function _addSniperLoyaltyPoint(address _account, uint256 _point) internal {
        uint256 beforePoint = SNIPER_LOYALTY_POINT[_account];
        SNIPER_LOYALTY_POINT[_account] = beforePoint + _point;
        uint256 afterPoint = SNIPER_LOYALTY_POINT[_account];
        emit LoyaltyUpdated(_account, beforePoint, afterPoint);
    }

    function GnosisAddSniperLoyaltyPoint(
        address[] memory _accounts,
        uint256 _point
    ) external onlyGnosis {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _addSniperLoyaltyPoint(_accounts[i], _point);
        }
    }

    function _removeSniperLoyaltyPoint(address _account, uint256 _point)
        internal
    {
        uint256 beforePoint = SNIPER_LOYALTY_POINT[_account];
        SNIPER_LOYALTY_POINT[_account] = beforePoint - _point;
        uint256 afterPoint = SNIPER_LOYALTY_POINT[_account];
        emit LoyaltyUpdated(_account, beforePoint, afterPoint);
    }

    function GnosisRemoveSniperLoyaltyPoint(
        address[] memory _accounts,
        uint256 _point
    ) external onlyGnosis {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _removeSniperLoyaltyPoint(_accounts[i], _point);
        }
    }

    function sniperMarksmanStatus(address _account)
        external
        view
        returns (uint256)
    {
        return SNIPER_MARKSMAN_STATUS[_account];
    }

    function _updateSniperMarksmanStatus(address _account, uint256 _time)
        internal
    {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _time;
        SNIPER_MARKSMAN_STATUS[_account] = endTime;
        emit MarksmanUpdated(_account, startTime, endTime);
    }

    function GnosisUpdateSniperMarksmanStatus(
        address[] memory _accounts,
        uint256 _time
    ) external onlyGnosis {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _updateSniperMarksmanStatus(_accounts[i], _time);
        }
    }

    function sniperWalletsCount(address _account)
        external
        view
        returns (uint256)
    {
        return SNIPER_WALLETS_COUNT[_account].current();
    }

    function _increaseSniperWalletsCount(address _account) internal {
        uint256 beforeCount = SNIPER_WALLETS_COUNT[_account].current();
        SNIPER_WALLETS_COUNT[_account].increment();
        uint256 afterCount = SNIPER_WALLETS_COUNT[_account].current();
        emit WalletsUpdated(_account, beforeCount, afterCount);
    }

    function GnosisIncreaseSniperWalletsCount(address[] memory _accounts)
        external
        onlyGnosis
    {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _increaseSniperWalletsCount(_accounts[i]);
        }
    }

    function _decreaseSniperWalletsCount(address _account) internal {
        uint256 beforeCount = SNIPER_WALLETS_COUNT[_account].current();
        SNIPER_WALLETS_COUNT[_account].decrement();
        uint256 afterCount = SNIPER_WALLETS_COUNT[_account].current();
        emit WalletsUpdated(_account, beforeCount, afterCount);
    }

    function GnosisDecreaseSniperWalletsCount(address[] memory _accounts)
        external
        onlyGnosis
    {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _decreaseSniperWalletsCount(_accounts[i]);
        }
    }

    function _resetSniperWalletsCount(address _account) internal {
        uint256 beforeCount = SNIPER_WALLETS_COUNT[_account].current();
        SNIPER_WALLETS_COUNT[_account].reset();
        uint256 afterCount = SNIPER_WALLETS_COUNT[_account].current();
        emit WalletsUpdated(_account, beforeCount, afterCount);
    }

    function GnosisResetSniperWalletsCount(address[] memory _accounts)
        external
        onlyGnosis
    {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _resetSniperWalletsCount(_accounts[i]);
        }
    }

    function blockchainMultiplier(uint256 _blockchain)
        external
        view
        returns (uint256)
    {
        return BLOCKCHAIN_MULTIPLIER[_blockchain];
    }

    function setBlockchainMultiplier(uint256 _blockchain, uint256 _multiplier)
        external
        onlyGnosis
    {
        BLOCKCHAIN_MULTIPLIER[_blockchain] = _multiplier;
    }

    function sniperRate(
        uint256 _blockchain,
        address _account,
        uint256 _version
    ) public view returns (uint256) {
        uint256 multiplierPerSnipe = 100;
        if (BLOCKCHAIN_MULTIPLIER[_blockchain] != 0) {
            multiplierPerSnipe = BLOCKCHAIN_MULTIPLIER[_blockchain];
        }

        uint256 tierDiscountPercent = 0;
        if (SPECIAL_ROLE[_account]) {
            if (_version == 0) {
                tierDiscountPercent = DISCOUNTS.SPECIAL_CLI;
            } else {
                tierDiscountPercent = DISCOUNTS.SPECIAL_UI;
            }
        } else if (DIAMOND_ROLE[_account]) {
            if (_version == 0) {
                tierDiscountPercent = DISCOUNTS.DIAMOND_CLI;
            } else {
                tierDiscountPercent = DISCOUNTS.DIAMOND_UI;
            }
        } else if (GOLD_ROLE[_account]) {
            if (_version == 0) {
                tierDiscountPercent = DISCOUNTS.GOLD_CLI;
            } else {
                tierDiscountPercent = DISCOUNTS.GOLD_UI;
            }
        } else if (SILVER_ROLE[_account]) {
            if (_version == 0) {
                tierDiscountPercent = DISCOUNTS.SILVER_CLI;
            } else {
                tierDiscountPercent = DISCOUNTS.SILVER_UI;
            }
        } else if (BRONZE_ROLE[_account]) {
            if (_version == 0) {
                tierDiscountPercent = DISCOUNTS.BRONZE_CLI;
            } else {
                tierDiscountPercent = DISCOUNTS.BRONZE_UI;
            }
        }

        uint256 rateAfterDiscount = RATE - ((RATE * tierDiscountPercent) / 100);
        uint256 rateAfterMultiplier = rateAfterDiscount * multiplierPerSnipe;
        if (_version == 0) {
            return rateAfterMultiplier / 2;
        } else {
            return rateAfterMultiplier;
        }
    }

    function mintCredit(
        IERC20 _token,
        uint256 _amount,
        address _recipient
    ) external nonReentrant registerSniper {
        uint256 amountIn = _amount;
        if (address(_token) != DOLLAR) {
            address[] memory path = new address[](2);
            path[0] = address(_token);
            path[1] = DOLLAR;

            uint256[] memory amounts = ROUTER.getAmountsOut(_amount, path);
            amountIn = amounts[1];
        }

        uint256 creditFormula = amountIn * 100;
        uint256 amountOut = creditFormula / GOVERNANCE.DOLLAR_PEGGED_PER_CREDIT;
        uint256 amountOutMin = (1 ether * RATE) / 100;

        if (amountOut >= amountOutMin) {
            _token.safeTransferFrom(_msgSender(), address(this), amountIn);
            _token.safeTransfer(GNOSIS, (amountIn * SHARE.GNOSIS) / 100);
            _token.safeTransfer(ROYALTY, (amountIn * SHARE.ROYALTY) / 100);

            CREDIT.mint(_recipient, amountIn);
            _addSniperLoyaltyPoint(
                _msgSender(),
                (amountIn * LOYALTY.MINT) / 100
            );
        } else {
            revert("Too Little");
        }
    }

    function redeemLoyaltyPoint(uint256 _amount, address _recipient)
        external
        nonReentrant
        registerSniper
    {
        require(
            SNIPER_LOYALTY_POINT[_msgSender()] >= _amount,
            "Insufficient Point"
        );

        uint256 creditFormula = _amount * GOVERNANCE.CREDIT_PER_LOYALTY_POINT;
        uint256 amountOut = creditFormula / 100;
        uint256 amountOutMin = (1 ether * RATE) / 100;

        if (amountOut >= amountOutMin) {
            _removeSniperLoyaltyPoint(_msgSender(), _amount);
            CREDIT.mint(_recipient, amountOut);
        } else {
            revert("Too Little");
        }
    }

    function frontendMarksman(address _account) public view returns (bool) {
        return SNIPER_MARKSMAN_STATUS[_account] >= block.timestamp;
    }

    function activateMarksman(uint256 _duration)
        external
        nonReentrant
        registerSniper
    {
        require(!frontendMarksman(_msgSender()), "Marksman Active");
        require(_sniperRoleId(_msgSender()) >= 2, "No Permission");

        uint256 creditFormula;
        uint256 marksmanTime;
        if (_duration == 1) {
            creditFormula = 1 ether * GOVERNANCE.CREDIT_PER_MARKSMAN_DAILY;
            marksmanTime = 1 days;
        } else if (_duration == 7) {
            creditFormula = 1 ether * GOVERNANCE.CREDIT_PER_MARKSMAN_WEEKLY;
            marksmanTime = 7 days;
        } else if (_duration == 28) {
            creditFormula = 1 ether * GOVERNANCE.CREDIT_PER_MARKSMAN_MONTHLY;
            marksmanTime = 28 days;
        } else if (_duration == 99) {
            require(_sniperRoleId(_msgSender()) >= 3, "No Permission");

            creditFormula = 1 ether * GOVERNANCE.CREDIT_PER_MARKSMAN_INDEFINITE;
            marksmanTime = 365 days * 99;
        } else {
            revert("Invalid Duration");
        }

        if (_sniperRoleId(_msgSender()) >= 4) {
            creditFormula = creditFormula / 2;
        }

        uint256 amountIn = creditFormula / 100;
        CREDIT.safeTransferFrom(_msgSender(), GNOSIS, amountIn);
        _addSniperLoyaltyPoint(_msgSender(), (amountIn * LOYALTY.SPEND) / 100);
        _updateSniperMarksmanStatus(_msgSender(), marksmanTime);
    }

    function frontendWalletsCount(address _account)
        external
        view
        returns (uint256)
    {
        uint256 totalWalletsCount = SNIPER_WALLETS_COUNT[_account].current();
        if (SPECIAL_ROLE[_account] || DIAMOND_ROLE[_account]) {
            totalWalletsCount = totalWalletsCount + 5;
        } else if (GOLD_ROLE[_account]) {
            totalWalletsCount = totalWalletsCount + 1;
        }

        return totalWalletsCount + 1;
    }

    function upgradeWalletsCount() external nonReentrant registerSniper {
        require(_sniperRoleId(_msgSender()) >= 3, "No Permission");

        uint256 amountIn = (1 ether *
            GOVERNANCE.CREDIT_PER_SNIPER_WALLETS_COUNT) / 100;

        CREDIT.safeTransferFrom(_msgSender(), GNOSIS, amountIn);
        _addSniperLoyaltyPoint(_msgSender(), (amountIn * LOYALTY.SPEND) / 100);
        _increaseSniperWalletsCount(_msgSender());
    }

    function executeSnipe(
        uint256 _blockchain,
        uint256 _version,
        uint256 _multiplier
    ) external nonReentrant registerSnipe registerSniper returns (bool) {
        require(_multiplier > 0, "Math Overflow");

        uint256 costPerSnipe = sniperRate(_blockchain, _msgSender(), _version);
        costPerSnipe = costPerSnipe * _multiplier;
        CREDIT.burn(_msgSender(), costPerSnipe);
        _addSniperLoyaltyPoint(
            _msgSender(),
            (costPerSnipe * LOYALTY.BURN) / 100
        );

        return true;
    }

    function _sniperRoleId(address _account) internal view returns (uint256) {
        if (DIAMOND_ROLE[_account]) {
            return 4;
        } else if (GOLD_ROLE[_account]) {
            return 3;
        } else if (SILVER_ROLE[_account]) {
            return 2;
        } else if (BRONZE_ROLE[_account]) {
            return 1;
        } else {
            return 0;
        }
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.12;

import "./ImdtLogic.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mdtERC20 is Ownable, ERC20 {
    ImdtLogic internal mdtLogic;

    constructor() ERC20("mdtProtocol Credit", "mdtC") {
        mdtLogic = ImdtLogic(owner());
    }

    function mint(address _account, uint256 _amount) external onlyOwner {
        super._mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external onlyOwner {
        super._burn(_account, _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal override {
        require(_spender == owner(), "Not mdtLogic");

        super._approve(_owner, _spender, _amount);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        bool allowedFrom = _from == address(0) || _from == mdtLogic.gnosis();
        bool allowedTo = _to == address(0) || _to == mdtLogic.gnosis();
        require(allowedFrom || allowedTo, "Burnable/Mintable Only");

        super._beforeTokenTransfer(_from, _to, _amount);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.12;

interface ImdtLogic {
    function gnosis() external view returns (address);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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