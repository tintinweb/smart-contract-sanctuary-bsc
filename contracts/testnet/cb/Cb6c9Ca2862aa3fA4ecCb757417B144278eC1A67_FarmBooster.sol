// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IWayaVault.sol";
import "./IChiefFarmer.sol";
import "./IterateMapping.sol";

contract FarmBooster is Ownable {
    using IterableMapping for ItMap;

    /// @notice waya token.
    address public immutable WAYA;
    /// @notice waya pool.
    address public immutable WAYA_VAULT;
    /// @notice ChiefFarmer contract.
    address public immutable CHIEF_FARMER;
    /// @notice boost proxy factory.
    address public BOOSTER_FACTORY;

    /// @notice Maximum allowed boosted pool numbers
    uint256 public MAX_BOOST_FARM_QTD;
    /// @notice limit max boost
    uint256 public lMaxBoost;
    /// @notice include 1e4
    uint256 public constant MIN_LMB= 1e4;
    /// @notice include 1e5
    uint256 public constant MAX_LMB= 1e5;
    /// @notice lMaxBoost precision
    uint256 public constant LMB_PRECISION = 1e5;
    /// @notice controls difficulties
    uint256 public controlsDifficulties;
    /// @notice not include 0
    uint256 public constant MIN_CD = 0;
    /// @notice include 50
    uint256 public constant MAX_CD = 50;
    /// @notice ChieFarmer basic boost factor, none boosted user's boost factor
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    /// @notice ChieFarmer Hard limit for maxmium boost factor
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    /// @notice Average boost ratio precion
    uint256 public constant BOOST_RATIO_PRECISION = 1e5;
    /// @notice Waya pool BOOST_WEIGHT precision
    uint256 public constant BOOST_WEIGHT_PRECISION = 100 * 1e10; // 100%

    /// @notice The whitelist of pools allowed for farm boosting.
    mapping(uint256 => bool) public whiteList;
    /// @notice The boost proxy contract mapping(user => proxy).
    mapping(address => address) public proxyContract;
    /// @notice Info of each pool user.
    mapping(address => ItMap) public userInfo;

    event UpdateMaxBoostPool(uint256 factory);
    event UpdateBoostFactory(address factory);
    event UpdateCA(uint256 oldCA, uint256 newCA);
    event UpdateCB(uint256 oldCB, uint256 newCB);
    event Refresh(address indexed user, address proxy, uint256 pid);
    event UpdateBoostFarms(uint256 pid, bool status);
    event ActiveFarmPool(address indexed user, address proxy, uint256 pid);
    event DeactiveFarmPool(address indexed user, address proxy, uint256 pid);
    event UpdateBoostProxy(address indexed user, address proxy);
    event UpdatePoolBoostMultiplier(address indexed user, uint256 pid, uint256 oldMultiplier, uint256 newMultiplier);
    event UpdateWayaVault(
        address indexed user,
        uint256 lockedAmount,
        uint256 lockedDuration,
        uint256 totalLockedAmount,
        uint256 maxLockDuration
    );

    /// @param _waya WAYA token contract address.
    /// @param _wayaVault Waya Vault contract address.
    /// @param _ChiefFarmer ChiefFarmer contract address.
    /// @param _maxBoostedFarm Maximum allowed boosted farm  quantity
    /// @param _lMaxBoost Limit max boost
    /// @param _ControlD Controls difficulties
    constructor(
        address _waya,
        address _wayaVault,
        address _ChiefFarmer,
        uint256 _maxBoostedFarm,
        uint256 _lMaxBoost,
        uint256 _ControlD
    ) {
        require(
            _maxBoostedFarm > 0 && _lMaxBoost >= MIN_LMB&& _lMaxBoost <= MAX_LMB&& _ControlD > MIN_CD && _ControlD <= MAX_CD,
            "constructor: Invalid parameter"
        );
        WAYA = _waya;
        WAYA_VAULT = _wayaVault;
        CHIEF_FARMER = _ChiefFarmer;
        MAX_BOOST_FARM_QTD = _maxBoostedFarm;
        lMaxBoost = _lMaxBoost;
        controlsDifficulties = _ControlD;
    }

    /// @notice Checks if the msg.sender is a contract or a proxy
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /// @notice Checks if the msg.sender is the FarmBooster Factory.
    modifier onlyFactory() {
        require(msg.sender == BOOSTER_FACTORY, "onlyFactory: Not factory");
        _;
    }

    /// @notice Checks if the msg.sender is the FarmBooster Proxy.
    modifier onlyProxy(address _user) {
        require(msg.sender == proxyContract[_user], "onlyProxy: Not proxy");
        _;
    }

    /// @notice Checks if the msg.sender is the waya pool.
    modifier onlyWayaVault() {
        require(msg.sender == WAYA_VAULT, "onlyWayaVault: Not waya pool");
        _;
    }

    /// @notice set maximum allowed boosted pool numbers.
    function setMaxBoostPool(uint256 _max) external onlyOwner {
        require(_max > 0, "setMaxBoostPool: Maximum boost pool should greater than 0");
        MAX_BOOST_FARM_QTD = _max;
        emit UpdateMaxBoostPool(_max);
    }

    /// @notice set boost factory contract.
    function setBoostFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "setBoostFactory: Invalid factory");
        BOOSTER_FACTORY = _factory;

        emit UpdateBoostFactory(_factory);
    }

    /// @notice Set user boost proxy contract, can only invoked by boost contract.
    /// @param _user boost user address.
    /// @param _proxy boost proxy contract.
    function setProxy(address _user, address _proxy) external onlyFactory {
        require(_proxy != address(0), "setProxy: Invalid proxy address");
        require(proxyContract[_user] == address(0), "setProxy: User has already set proxy");

        proxyContract[_user] = _proxy;

        emit UpdateBoostProxy(_user, _proxy);
    }

    /// @notice Only allow whitelisted pids for farm boosting
    /// @param _pid pool id(Chieffarmer pool).
    /// @param _status farm pool allowed boosted or not
    function setBoosterFarms(uint256 _pid, bool _status) external onlyOwner {
        whiteList[_pid] = _status;
        emit UpdateBoostFarms(_pid, _status);
    }

    /// @notice limit max boost
    /// @param _lMaxBoost max boost
    function set_lMaxBoost(uint256 _lMaxBoost) external onlyOwner {
        require(_lMaxBoost >= MIN_LMB&& _lMaxBoost <= MAX_LMB, "setLMB: Invalid lMaxBoost");
        uint256 temp = lMaxBoost;
        lMaxBoost = _lMaxBoost;
        emit UpdateCA(temp, lMaxBoost);
    }

    /// @notice controls difficulties
    /// @param _ControlD difficulties
    function set_ControlD(uint256 _ControlD) external onlyOwner {
        require(_ControlD > MIN_CD && _ControlD <= MAX_CD, "setCD: Invalid controlsDifficulties");
        uint256 temp = controlsDifficulties;
        controlsDifficulties = _ControlD;
        emit UpdateCB(temp, controlsDifficulties);
    }

    /// @notice Wayapool operation(deposit/withdraw) automatically call this function.
    /// @param _user user address.
    /// @param _lockedAmount user locked amount in waya pool.
    /// @param _lockedDuration user locked duration in waya pool.
    /// @param _totalLockedAmount Total locked waya amount in waya pool.
    /// @param _maxLockDuration maximum locked duration in waya pool.
    function onWayaVaultUpdate(
        address _user,
        uint256 _lockedAmount,
        uint256 _lockedDuration,
        uint256 _totalLockedAmount,
        uint256 _maxLockDuration
    ) external onlyWayaVault {
        address proxy = proxyContract[_user];
        ItMap storage itmap = userInfo[proxy];
        uint256 avgDuration;
        bool flag;
        for (uint256 i = 0; i < itmap.keys.length; i++) {
            uint256 pid = itmap.keys[i];
            if (!flag) {
                avgDuration = avgLockDuration();
                flag = true;
            }
            _updateBoostMultiplier(_user, proxy, pid, avgDuration);
        }

        emit UpdateWayaVault(_user, _lockedAmount, _lockedDuration, _totalLockedAmount, _maxLockDuration);
    }

    /// @notice Update user boost multiplier in pool,only for proxy.
    /// @param _user user address.
    /// @param _pid pool id in Chieffarmer pool.
    function updatePoolBoostMultiplier(address _user, uint256 _pid) public onlyProxy(_user) {
        // if user not actived this farm, just return.
        if (!userInfo[msg.sender].contains(_pid)) return;
        _updateBoostMultiplier(_user, msg.sender, _pid, avgLockDuration());
    }

    /// @notice Active user farm pool.
    /// @param _pid pool id(Chieffarmer pool).
    function activate(uint256 _pid) external {
        address proxy = proxyContract[msg.sender];
        require(whiteList[_pid] && proxy != address(0), "activate: Not boosted farm pool");

        ItMap storage itmap = userInfo[proxy];
        require(itmap.keys.length < MAX_BOOST_FARM_QTD, "activate: Boosted farms reach to MAX");

        _updateBoostMultiplier(msg.sender, proxy, _pid, avgLockDuration());

        emit ActiveFarmPool(msg.sender, proxy, _pid);
    }

    /// @notice Deactive user farm pool.
    /// @param _pid pool id(Chieffarmer pool).
    function deactive(uint256 _pid) external {
        address proxy = proxyContract[msg.sender];
        ItMap storage itmap = userInfo[proxy];
        require(itmap.contains(_pid), "deactive: None boost user");

        if (itmap.data[_pid] > BOOST_PRECISION) {
            IChiefFarmer(CHIEF_FARMER).updateBoostMultiplier(proxy, _pid, BOOST_PRECISION);
        }
        itmap.remove(_pid);

        emit DeactiveFarmPool(msg.sender, proxy, _pid);
    }

    /// @notice Anyone can refesh sepecific user boost multiplier
    /// @param _user user address.
    /// @param _pid pool id(Chieffarmer pool).
    function refresh(address _user, uint256 _pid) external notContract {
        address proxy = proxyContract[_user];
        ItMap storage itmap = userInfo[proxy];
        require(itmap.contains(_pid), "refresh: None boost user");

        _updateBoostMultiplier(_user, proxy, _pid, avgLockDuration());

        emit Refresh(_user, proxy, _pid);
    }

    /// @notice Whether user boosted specific farm pool.
    /// @param _user user address.
    /// @param _pid pool id(Chieffarmer pool).
    function isBoostedPool(address _user, uint256 _pid) external view returns (bool) {
        return userInfo[proxyContract[_user]].contains(_pid);
    }

    /// @notice Actived farm pool list.
    /// @param _user user address.
    function activedPools(address _user) external view returns (uint256[] memory pools) {
        ItMap storage itmap = userInfo[proxyContract[_user]];
        if (itmap.keys.length == 0) return pools;

        pools = new uint256[](itmap.keys.length);
        // solidity for-loop not support multiple variables initializae by ',' separate.
        uint256 i;
        for (uint256 index = 0; index < itmap.keys.length; index++) {
            uint256 pid = itmap.keys[index];
            pools[i] = pid;
            i++;
        }
    }

    /// @notice Anyone can call this function, if you find some guys effectived multiplier is not fair
    /// for other users, just call 'refresh' function.
    /// @param _user user address.
    /// @param _pid pool id(Chieffarmer pool).
    /// @dev If return value not in range [BOOST_PRECISION, MAX_BOOST_PRECISION]
    /// the actual effectived multiplier will be the close to side boundry value.
    function getUserMultiplier(address _user, uint256 _pid) external view returns (uint256) {
        return _boostCalculate(_user, proxyContract[_user], _pid, avgLockDuration());
    }

    /// @notice waya pool average locked duration calculator.
    function avgLockDuration() public view returns (uint256) {
        uint256 totalStakedAmount = IERC20(WAYA).balanceOf(WAYA_VAULT);

        uint256 totalLockedAmount = IWayaVault(WAYA_VAULT).totalLockedAmount();

        uint256 pricePerFullShare = IWayaVault(WAYA_VAULT).getPricePerFullShare();

        uint256 flexibleShares = ((totalStakedAmount - totalLockedAmount) * 1e18) / pricePerFullShare;
        if (flexibleShares == 0) return 0;

        uint256 originalShares = (totalLockedAmount * 1e18) / pricePerFullShare;
        if (originalShares == 0) return 0;

        uint256 boostedRatio = ((IWayaVault(WAYA_VAULT).totalShares() - flexibleShares) * BOOST_RATIO_PRECISION) /
            originalShares;
        if (boostedRatio <= BOOST_RATIO_PRECISION) return 0;

        uint256 boostWeight = IWayaVault(WAYA_VAULT).BOOST_WEIGHT();
        uint256 maxLockDuration = IWayaVault(WAYA_VAULT).MAX_LOCK_DURATION() * BOOST_RATIO_PRECISION;

        uint256 duration = ((boostedRatio - BOOST_RATIO_PRECISION) * 365 * BOOST_WEIGHT_PRECISION) / boostWeight;
        return duration <= maxLockDuration ? duration : maxLockDuration;
    }

    /// @param _user user address.
    /// @param _proxy proxy address corresponding to the user.
    /// @param _pid pool id.
    /// @param _duration waya pool average locked duration.
    function _updateBoostMultiplier(
        address _user,
        address _proxy,
        uint256 _pid,
        uint256 _duration
    ) internal {
        ItMap storage itmap = userInfo[_proxy];

        // Used to be boost farm pool and current is not, remove from mapping
        if (!whiteList[_pid]) {
            if (itmap.data[_pid] > BOOST_PRECISION) {
                // reset to BOOST_PRECISION
                IChiefFarmer(CHIEF_FARMER).updateBoostMultiplier(_proxy, _pid, BOOST_PRECISION);
            }
            itmap.remove(_pid);
            return;
        }

        uint256 prevMultiplier = IChiefFarmer(CHIEF_FARMER).getBoostMultiplier(_proxy, _pid);
        uint256 multiplier = _boostCalculate(_user, _proxy, _pid, _duration);

        if (multiplier < BOOST_PRECISION) {
            multiplier = BOOST_PRECISION;
        } else if (multiplier > MAX_BOOST_PRECISION) {
            multiplier = MAX_BOOST_PRECISION;
        }

        // Update multiplier to ChieFarmer
        if (multiplier != prevMultiplier) {
            IChiefFarmer(CHIEF_FARMER).updateBoostMultiplier(_proxy, _pid, multiplier);
        }
        itmap.insert(_pid, multiplier);

        emit UpdatePoolBoostMultiplier(_user, _pid, prevMultiplier, multiplier);
    }

    /// @param _user user address.
    /// @param _proxy proxy address corresponding to the user.
    /// @param _pid pool id(Chieffarmer pool).
    /// @param _duration waya pool average locked duration.
    function _boostCalculate(
        address _user,
        address _proxy,
        uint256 _pid,
        uint256 _duration
    ) internal view returns (uint256) {
        if (_duration == 0) return BOOST_PRECISION;

        (uint256 lpBalance, , ) = IChiefFarmer(CHIEF_FARMER).userInfo(_pid, _proxy);
        uint256 dB = (lMaxBoost * lpBalance) / LMB_PRECISION;
        // dB == 0 means lpBalance close to 0
        if (lpBalance == 0 || dB == 0) return BOOST_PRECISION;

        (, , , , uint256 lockStartTime, uint256 lockEndTime, , , uint256 userLockedAmount) = IWayaVault(WAYA_VAULT)
            .userInfo(_user);
        if (userLockedAmount == 0 || block.timestamp >= lockEndTime) return BOOST_PRECISION;

        // userLockedAmount > 0 means totalLockedAmount > 0
        uint256 totalLockedAmount = IWayaVault(WAYA_VAULT).totalLockedAmount();

        IERC20 lp = IERC20(IChiefFarmer(CHIEF_FARMER).lpToken(_pid));
        uint256 userLockedDuration = (lockEndTime - lockStartTime) / (3600 * 24); // days

        uint256 aB = (((lp.balanceOf(CHIEF_FARMER) * userLockedAmount * userLockedDuration) * BOOST_RATIO_PRECISION) /
            controlsDifficulties) / (totalLockedAmount * _duration);

        // should '*' BOOST_PRECISION
        return ((lpBalance < (dB + aB) ? lpBalance : (dB + aB)) * BOOST_PRECISION) / dB;
    }

    /// @notice Checks if address is a contract
    /// @dev It prevents contract from being targetted
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}