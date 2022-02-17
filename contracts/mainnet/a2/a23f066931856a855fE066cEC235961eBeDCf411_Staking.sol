/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Access control contract,
 * functions names are self explanatory
 */
abstract contract AccessControl {
    modifier onlyOwner() {
        require(msg.sender == _owner, 'Caller is not the owner');
        _;
    }
    modifier onlyManager() {
        require(_managers[msg.sender], 'Caller is not the manager');
        _;
    }

    mapping (address => bool) private _managers;
    address private _owner;

    constructor () {
        _owner = msg.sender;
        _managers[_owner] = true;
    }

    // admin functions
    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), 'newOwner should not be zero address');
        _owner = newOwner;
        return true;
    }

    function addToManagers (
        address userAddress
    ) public onlyOwner returns (bool) {
        _managers[userAddress] = true;
        return true;
    }

    function removeFromManagers (
        address userAddress
    ) public onlyOwner returns (bool) {
        _managers[userAddress] = false;
        return true;
    }

    /**
     * @dev If true - user has manager role
     */
    function isManager (
        address userAddress
    ) external view returns (bool) {
        return _managers[userAddress];
    }

    /**
     * @dev Owner address getter
     */
    function owner() public view returns (address) {
        return _owner;
    }
}

/**
 * @dev Partial interface of the ERC20 standard according to the needs of the e2p contract.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient, uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender, address recipient, uint256 amount
    ) external returns (bool);
    function allowance(
        address owner, address spender
    ) external view returns (uint256);
    function decimals() external view returns (uint8);
}

/**
 * @dev Partial interface of the ERC20 standard according to the needs of the e2p contract.
 */
interface IERC20_LP {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract Staking is AccessControl {
    struct DepositProfile {
        address depositContractAddress;
        address yieldContractAddress;
        uint8 depositRateType; // 1 ETNA, 2 MTB, 3 LP_ETNA, 4 LP_MTB, 5 ERC20
        uint8 yieldRateType; // 1 ETNA, 2 MTB, 5 ERC20
        uint16 apr; // apr (% * 100, 2501 means 25.01%)
        uint16 withdrawYieldTax; // tax (% * 100, 2501 means 25.01%),
        // for depositRateType LP_ETNA and LP_MTB tax will be applied before lockTime end
        // when withdraw yield
        uint16 downgradeTax; // tax (% * 100, 2501 means 25.01%)
        uint256 depositUsdRate; // deposit currency rate in USD * 10000
        uint256 yieldUsdRate; // yield currency rate in USD * 10000
        uint256 weight; // sorting order at UI (asc from left to right)
        uint256 marketIndex; // market index to treat possible APR changes
        uint256 marketIndexLastTime;
        // timestamp when market index was changed last time
        uint256 tvl;  // total amount of tokens deposited in a pool
        uint256 lockTime;
        // lock period for erc20 or taxed withdraw period for LP tokens in seconds
        uint256 upgradeProfileId;
        uint256 downgradeProfileId;
        uint256 stakers;
        uint256 yieldPaid;
        string name;
        string depositCurrency;
        string yieldCurrency;
        string link;
        bool active;
    }

    mapping (uint256 => DepositProfile) internal _depositProfiles;

    struct Deposit {
        address userAddress;
        uint256 depositProfileId;
        uint256 amount;
        uint256 unlock;
        uint256 lastMarketIndex;
        uint256 updatedAt; // timestamp, is resettled to block.timestamp when changed
        uint256 accumulatedYield; // used to store reward when changed
    }
    mapping (uint256 => Deposit) internal _deposits;
    mapping (address => mapping(uint256 => uint256)) internal _usersDepositIndexes;
    mapping (address => bool) _managers;
    mapping (address => bool) _rateManagers;

    address internal _taxReceiverAddress; // address for sending tax tokens
    uint256 internal _etnaUsdRate;
    uint256 internal _mtbUsdRate;
    uint256 internal _depositProfilesNumber;
    uint256 internal _depositsNumber;
    uint256 internal constant YEAR = 365 * 24 * 3600;
    uint256 internal constant SHIFT = 1 ether;
    // used for exponent shifting when calculation market index
    uint256 internal constant DECIMALS = 10000;
    // used for exponent shifting when calculation with decimals
    uint8 internal constant ETNA = 1;
    uint8 internal constant MTB = 2;
    uint8 internal constant LP_ETNA = 3;
    uint8 internal constant LP_MTB = 4;
    uint8 internal constant ERC20 = 5;
    mapping (address => uint256) internal _totalDeposit;
    bool internal _safeMode;
    bool internal _editMode = true;

    constructor (
        address newOwner,
        address taxReceiverAddress,
        uint256 etnaUsdRate,
        uint256 mtbUsdRate
    ) {
        _taxReceiverAddress = taxReceiverAddress;
        require(newOwner != address(0), 'Owner address can not be zero');
        require(etnaUsdRate > 0, 'Rate should be greater than zero');
        require(mtbUsdRate > 0, 'Rate should be greater than zero');
        _etnaUsdRate = etnaUsdRate;
        _mtbUsdRate = mtbUsdRate;
        addToManagers(newOwner);
        transferOwnership(newOwner);
    }

    function stake (
        uint256 amount, uint256 depositProfileId
    ) external returns (bool) {
        require(
            _depositProfiles[depositProfileId].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        IERC20 depositTokenContract = IERC20(
            _depositProfiles[depositProfileId].depositContractAddress
        );
        depositTokenContract.transferFrom(msg.sender, address(this), amount);
        _addToDeposit(
            msg.sender,
            depositProfileId,
            amount
        );
        _depositProfiles[depositProfileId].tvl += amount;
        _totalDeposit[_depositProfiles[depositProfileId].depositContractAddress] += amount;

        return true;
    }

    function unStake (
        uint256 amount, uint256 depositProfileId
    ) external returns (bool) {
        require(
            _depositProfiles[depositProfileId].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        if (
            _depositProfiles[depositProfileId].depositRateType != LP_ETNA
                && _depositProfiles[depositProfileId].depositRateType != LP_MTB
        ) {
            require(
                block.timestamp >= _deposits[depositId].unlock, 'Deposit is locked'
            );
        }
        _updateYield(depositId);
        require(_deposits[depositId].amount >= amount, 'Not enough amount at deposit');
        _deposits[depositId].amount -= amount;
        _depositProfiles[depositProfileId].tvl -= amount;
        _totalDeposit[_depositProfiles[depositProfileId].depositContractAddress] -= amount;
        IERC20 depositTokenContract =
            IERC20(_depositProfiles[depositProfileId].depositContractAddress);
        depositTokenContract.transfer(msg.sender, amount);

        return true;
    }

    function reStake (uint256 depositProfileId) external returns (bool) {
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        require(
            _depositProfiles[depositProfileId].active, 'This deposit profile is disabled'
        );
        require(
            restakeAvailable(depositProfileId),
            'Restaking is not available for this type of deposit'
        );
        _updateYield(depositId);
        uint256 yield = _deposits[depositId].accumulatedYield;
        _deposits[depositId].accumulatedYield = 0;
        _deposits[depositId].amount += yield;
        _depositProfiles[depositProfileId].tvl += yield;
        _totalDeposit[_depositProfiles[depositProfileId].depositContractAddress] += yield;
        return true;
    }

    function restakeAvailable (
        uint256 depositProfileId
    ) public view returns (bool) {
        return _depositProfiles[depositProfileId].depositContractAddress
            == _depositProfiles[depositProfileId].yieldContractAddress;
    }

    function upgrade (
        uint256 depositProfileId
    ) external returns (bool) {
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        uint256 upgradeProfileId =
            _depositProfiles[depositProfileId].upgradeProfileId;
        require(
            upgradeProfileId > 0,
            'Upgrade for this deposit profile is not possible'
        );
        uint256 amount = _deposits[depositId].amount;
        require(
            amount > 0,
            'Deposit amount should be greater than zero for upgrade'
        );
        _updateYield(depositId);
        _deposits[depositId].amount = 0;
        _depositProfiles[depositProfileId].tvl -= amount;
        _depositProfiles[upgradeProfileId].tvl += amount;
        _addToDeposit(
            msg.sender,
            upgradeProfileId,
            amount
        );
        return true;
    }

    function downgrade (
        uint256 depositProfileId
    ) external returns (bool) {
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        uint256 downgradeProfileId =
            _depositProfiles[depositProfileId].downgradeProfileId;
        require(
            downgradeProfileId > 0,
            'Upgrade for this deposit profile is not possible'
        );
        uint256 amount = _deposits[depositId].amount;
        uint256 taxAmount;
        if (_depositProfiles[depositProfileId].downgradeTax > 0) {
            taxAmount = amount
                * _depositProfiles[depositProfileId].downgradeTax / DECIMALS;
        }
        if (taxAmount > 0){
            amount -= taxAmount;
            IERC20 tokenContract =
                IERC20(_depositProfiles[depositProfileId].depositContractAddress);
            tokenContract.transfer(_taxReceiverAddress, taxAmount);
        }

        require(
            amount > 0,
            'Deposit amount should be greater than zero for downgrade'
        );
        _updateYield(depositId);
        _deposits[depositId].amount = 0;
        _depositProfiles[depositProfileId].tvl -= amount;
        _depositProfiles[downgradeProfileId].tvl += amount;
        _addToDeposit(
            msg.sender,
            downgradeProfileId,
            amount
        );
        return true;
    }

    function withdrawYield (
        uint256 amount, uint256 depositProfileId
    ) external returns (bool) {
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        require(
            _depositProfiles[depositProfileId].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        _updateYield(depositId);
        require(
            _deposits[depositId].accumulatedYield >= amount, 'Not enough yield at deposit'
        );
        _deposits[depositId].accumulatedYield -= amount;
        uint256 amountWithRate = amount * getDepositProfileRate(depositProfileId) / SHIFT;
        uint256 taxAmount;
        if (
            (_depositProfiles[depositProfileId].depositRateType == LP_ETNA
                || _depositProfiles[depositProfileId].depositRateType == LP_MTB)
                && block.timestamp < _deposits[depositId].unlock
        ) {
            taxAmount = amountWithRate * _depositProfiles[depositProfileId].withdrawYieldTax / DECIMALS;
        }
        IERC20 tokenContract = IERC20(_depositProfiles[depositProfileId].yieldContractAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(amountWithRate <= balance, 'Not enough contract balance');
        if (_safeMode) {
            require(balance - amountWithRate >= _totalDeposit[address(tokenContract)],
                'Not enough contract balance (safe mode)');
        }
        if (taxAmount > 0) {
            amountWithRate -= taxAmount;
            tokenContract.transfer(_taxReceiverAddress, taxAmount);
        }
        _depositProfiles[depositProfileId].yieldPaid += amountWithRate;
        tokenContract.transfer(msg.sender, amountWithRate);
        return true;
    }

    function withdrawYieldAll (
        uint256 depositProfileId
    ) external returns (bool) {
        uint256 depositId = _usersDepositIndexes[msg.sender][depositProfileId];
        require(depositId > 0, 'Deposit is not found');
        require(
            _depositProfiles[depositProfileId].active, 'This deposit profile is disabled'
        );
        _updateYield(depositId);
        uint256 amount = _deposits[depositId].accumulatedYield;
        require(amount > 0, 'Nothing to withdraw');
        _deposits[depositId].accumulatedYield = 0;
        uint256 amountWithRate = amount * getDepositProfileRate(depositProfileId) / SHIFT;
        uint256 taxAmount;
        if (
            (_depositProfiles[depositProfileId].depositRateType == LP_ETNA
                || _depositProfiles[depositProfileId].depositRateType == LP_MTB)
                && block.timestamp < _deposits[depositId].unlock
        ) {
            taxAmount = amountWithRate * _depositProfiles[depositProfileId].withdrawYieldTax / DECIMALS;
        }
        IERC20 tokenContract = IERC20(_depositProfiles[depositProfileId].yieldContractAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(amountWithRate <= balance, 'Not enough contract balance');
        if (_safeMode) {
            require(balance - amountWithRate >= _totalDeposit[address(tokenContract)],
                'Not enough contract balance (safe mode)');
        }
        if (taxAmount > 0) {
            amountWithRate -= taxAmount;
            tokenContract.transfer(_taxReceiverAddress, taxAmount);
        }
        _depositProfiles[depositProfileId].yieldPaid += amountWithRate;
        tokenContract.transfer(msg.sender, amountWithRate);
        return true;
    }

    // manager functions
    function addDepositProfile (
        address depositContractAddress,
        address yieldContractAddress,
        uint8 depositRateType,
        uint8 yieldRateType,
        uint16 apr,
        uint16 withdrawYieldTax,
        uint16 downgradeTax,
        uint256 depositUsdRate,
        uint256 yieldUsdRate,
        uint256 weight,
        uint256 lockTime
    ) external onlyManager returns (bool) {
        require(
            depositRateType > 0 && depositRateType <= ERC20,
            'Rate type is not valid'
        );
        require(
            yieldRateType > 0 && yieldRateType <= ERC20
                && yieldRateType != LP_ETNA
                && yieldRateType != LP_MTB,
            'Rate type is not valid'
        );
        require(withdrawYieldTax <= 9999, 'Not valid withdraw yield tax');
        require(downgradeTax <= 9999, 'Not valid downgrade tax');

        _depositProfilesNumber ++;
        if (depositRateType == ERC20) {
            require(depositUsdRate > 0, 'Usd rate should be greater than zero');
        }
        if (yieldRateType == ERC20) {
            require(yieldUsdRate > 0, 'Usd rate should be greater than zero');
        }
        if (
            depositRateType != LP_ETNA
                && depositRateType != LP_MTB
        ) {
            withdrawYieldTax = 0;
        }
        IERC20 token = IERC20(depositContractAddress);
        require(token.decimals() == 18, 'Only for tokens with decimals 18');
        token = IERC20(yieldContractAddress);
        require(token.decimals() == 18, 'Only for tokens with decimals 18');
        _depositProfiles[_depositProfilesNumber].depositContractAddress =
            depositContractAddress;
        _depositProfiles[_depositProfilesNumber].yieldContractAddress =
            yieldContractAddress;
        _depositProfiles[_depositProfilesNumber].depositRateType = depositRateType;
        _depositProfiles[_depositProfilesNumber].yieldRateType = yieldRateType;
        _depositProfiles[_depositProfilesNumber].apr = apr;
        _depositProfiles[_depositProfilesNumber].withdrawYieldTax =
            withdrawYieldTax;
        _depositProfiles[_depositProfilesNumber].downgradeTax = downgradeTax;
        _depositProfiles[_depositProfilesNumber].depositUsdRate = depositUsdRate;
        _depositProfiles[_depositProfilesNumber].yieldUsdRate = yieldUsdRate;
        _depositProfiles[_depositProfilesNumber].weight = weight;
        _depositProfiles[_depositProfilesNumber].marketIndex = SHIFT;
        _depositProfiles[_depositProfilesNumber].marketIndexLastTime =
            block.timestamp;
        _depositProfiles[_depositProfilesNumber].lockTime = lockTime;
        return true;
    }

    function setDepositProfileData (
        uint256 depositProfileId,
        string calldata name,
        string calldata depositCurrency,
        string calldata yieldCurrency,
        string calldata link,
        bool active
    ) external onlyManager returns (bool) {
        require(
            depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found'
        );
        _depositProfiles[depositProfileId].name = name;
        _depositProfiles[depositProfileId].depositCurrency = depositCurrency;
        _depositProfiles[depositProfileId].yieldCurrency = yieldCurrency;
        _depositProfiles[depositProfileId].link = link;
        _depositProfiles[depositProfileId].active = active;
        return true;
    }

    function setDepositProfileApr (
        uint256 depositProfileId,
        uint16 apr
    ) external onlyManager returns (bool) {
        require(
            depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found'
        );
        _updateMarketIndexes(depositProfileId);
        _depositProfiles[depositProfileId].apr = apr;
        return true;
    }

    function setDepositProfileWithdrawYieldTax (
        uint256 depositProfileId,
        uint16 withdrawYieldTax
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(
            _depositProfiles[depositProfileId].depositRateType == LP_ETNA
                || _depositProfiles[depositProfileId].depositRateType == LP_MTB,
            'Tax for yield withdrawal can be set for LP vaults only'
        );
        require(withdrawYieldTax <= 9999, 'Not valid withdraw yield tax');
        _depositProfiles[depositProfileId].withdrawYieldTax = withdrawYieldTax;
        return true;
    }

    function setDepositProfileDowngradeTax (
        uint256 depositProfileId,
        uint16 downgradeTax
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(downgradeTax <= 9999, 'Not valid downgrade tax');
        _depositProfiles[depositProfileId].downgradeTax = downgradeTax;
        return true;
    }

    function setDepositProfileDepositUsdRate (
        uint256 depositProfileId,
        uint256 depositUsdRate
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(depositUsdRate > 0, 'Deposit usd rate should be greater than zero');
        _depositProfiles[depositProfileId].depositUsdRate = depositUsdRate;
        return true;
    }

    function setDepositProfileYieldUsdRate (
        uint256 depositProfileId,
        uint256 yieldUsdRate
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(yieldUsdRate > 0, 'Yield usd rate should be greater than zero');
        _depositProfiles[depositProfileId].yieldUsdRate = yieldUsdRate;
        return true;
    }

    function setDepositProfileWeight (
        uint256 depositProfileId,
        uint256 weight
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].weight = weight;
        return true;
    }

    function setDepositProfileLockTime (
        uint256 depositProfileId,
        uint256 lockTime
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].lockTime = lockTime;
        return true;
    }

    function setDepositProfileName (
        uint256 depositProfileId,
        string calldata name
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].name = name;
        return true;
    }

    function setDepositProfileDepositCurrency (
        uint256 depositProfileId,
        string calldata depositCurrency
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].depositCurrency = depositCurrency;
        return true;
    }

    function setDepositProfileYieldCurrency (
        uint256 depositProfileId,
        string calldata yieldCurrency
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].yieldCurrency = yieldCurrency;
        return true;
    }

    function setDepositProfileLink (
        uint256 depositProfileId,
        string calldata link
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].link = link;
        return true;
    }

    function setDepositProfileStatus (
        uint256 depositProfileId,
        bool active
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileId].active = active;
        return true;
    }

    function setDepositProfileDowngradeProfileId (
        uint256 depositProfileId,
        uint256 downgradeProfileId
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(downgradeProfileId > 0 && downgradeProfileId <= _depositProfilesNumber,
            'Downgrade deposit profile is not found');
        require(
            _depositProfiles[depositProfileId].depositContractAddress ==
                _depositProfiles[downgradeProfileId].depositContractAddress,
            'Deposit contract addresses are different'
        );
        require(
            _depositProfiles[depositProfileId].yieldContractAddress ==
                _depositProfiles[downgradeProfileId].yieldContractAddress,
            'Yield contract addresses are different'
        );
        _depositProfiles[depositProfileId].downgradeProfileId = downgradeProfileId;
        return true;
    }

    function setDepositProfileUpgradeProfileId (
        uint256 depositProfileId,
        uint256 upgradeProfileId
    ) external onlyManager returns (bool) {
        require(depositProfileId > 0 && depositProfileId <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(upgradeProfileId > 0 && upgradeProfileId <= _depositProfilesNumber,
            'Downgrade deposit profile is not found');
        require(
            _depositProfiles[depositProfileId].depositContractAddress ==
                _depositProfiles[upgradeProfileId].depositContractAddress,
            'Deposit contract addresses are different'
        );
        require(
            _depositProfiles[depositProfileId].yieldContractAddress ==
                _depositProfiles[upgradeProfileId].yieldContractAddress,
            'Yield contract addresses are different'
        );
        _depositProfiles[depositProfileId].upgradeProfileId = upgradeProfileId;
        return true;
    }

    function setSafeMode (bool safeMode) external onlyManager returns (bool) {
        _safeMode = safeMode;
        return true;
    }

    function setEtnaUsdRate(
        uint256 etnaUsdRate
    ) external onlyManager returns (bool) {
        _etnaUsdRate = etnaUsdRate;
        return true;
    }

    function setMtbUsdRate(
        uint256 mtbUsdRate
    ) external onlyManager returns (bool) {
        _mtbUsdRate = mtbUsdRate;
        return true;
    }

    function setTaxReceiverAddress (
        address taxReceiverAddress
    ) external onlyManager returns (bool) {
        _taxReceiverAddress = taxReceiverAddress;
        return true;
    }

    function setUserDeposit (
        address userAddress,
        uint256 depositProfileId,
        uint256 amount,
        uint256 yieldAmount,
        uint256 unlock
    ) external onlyManager returns (bool) {
        require(
            _editMode, 'This function is available only in edit mode'
        );
        uint256 depositId = _usersDepositIndexes[userAddress][depositProfileId];
        if (depositId == 0) {
            _depositsNumber ++;
            _depositProfiles[depositProfileId].stakers ++;
            depositId = _depositsNumber;
            _deposits[depositId].userAddress = userAddress;
            _deposits[depositId].depositProfileId = depositProfileId;
            _usersDepositIndexes[userAddress][depositProfileId] = depositId;
        } else {
            _depositProfiles[depositProfileId].tvl -= _deposits[depositId].amount;
            _totalDeposit[_depositProfiles[depositProfileId]
                .depositContractAddress] -= _deposits[depositId].amount;
        }

        _deposits[depositId].amount = amount;
        _deposits[depositId].accumulatedYield = yieldAmount;
        _deposits[depositId].lastMarketIndex =
            _depositProfiles[depositProfileId].marketIndex;
        _deposits[depositId].updatedAt = block.timestamp;
        _deposits[depositId].unlock = unlock;
        _depositProfiles[depositProfileId].tvl += amount;
        _totalDeposit[_depositProfiles[depositProfileId].depositContractAddress] += amount;
        return true;
    }

    function setUserDepositMultiple (
        address[] calldata userAddresses,
        uint256[] calldata depositProfileIds,
        uint256[] calldata amounts,
        uint256[] calldata yieldAmounts,
        uint256[] calldata unlocks
    ) external onlyManager returns (bool) {
        require(
            _editMode, 'This function is available only in edit mode'
        );
        for (uint256 i; i < userAddresses.length; i ++) {
            if (
                i > 100
                    || depositProfileIds.length < i + 1
                    || amounts.length < i + 1
                    || yieldAmounts.length < i + 1
                    || unlocks.length < i + 1
            ) break;

            uint256 depositId = _usersDepositIndexes[userAddresses[i]][depositProfileIds[i]];
            if (depositId > 0) continue;
            _depositsNumber ++;
            _depositProfiles[depositProfileIds[i]].stakers ++;
            depositId = _depositsNumber;
            _deposits[depositId].userAddress = userAddresses[i];
            _deposits[depositId].depositProfileId = depositProfileIds[i];
            _usersDepositIndexes[userAddresses[i]][depositProfileIds[i]] = depositId;
            _deposits[depositId].amount = amounts[i];
            _deposits[depositId].accumulatedYield = yieldAmounts[i];
            _deposits[depositId].lastMarketIndex =
                _depositProfiles[depositProfileIds[i]].marketIndex;
            _deposits[depositId].updatedAt = block.timestamp;
            _deposits[depositId].unlock = unlocks[i];
            _depositProfiles[depositProfileIds[i]].tvl += amounts[i];
            _totalDeposit[_depositProfiles[depositProfileIds[i]].depositContractAddress] += amounts[i];
        }
        return true;
    }

    // admin functions
    function adminWithdrawToken (
        uint256 amount, address tokenAddress
    ) external onlyOwner returns (bool) {
        require(tokenAddress != address(0), 'Token address can not be zero');
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(amount <= balance, 'Not enough contract balance');
        if (_safeMode) {
            require(balance - amount >= _totalDeposit[tokenAddress],
                'Not enough contract balance (safe mode)');
        }
        tokenContract.transfer(msg.sender, amount);
        return true;
    }

    function setEditMode (bool editMode) external onlyOwner returns (bool) {
        _editMode = editMode;
        return true;
    }

    // internal functions
    function _addToDeposit (
        address userAddress,
        uint256 depositProfileId,
        uint256 amount
    ) internal returns (bool) {
        uint256 depositId = _usersDepositIndexes[userAddress][depositProfileId];
        if (depositId > 0) {
            _updateYield(depositId);
            _deposits[depositId].amount += amount;
            _deposits[depositId].unlock =
                _depositProfiles[depositProfileId].lockTime + block.timestamp;
        } else {
            _depositsNumber ++;
            _depositProfiles[depositProfileId].stakers ++;
            depositId = _depositsNumber;
            _deposits[depositId].userAddress = userAddress;
            _deposits[depositId].depositProfileId = depositProfileId;
            _deposits[depositId].amount = amount;
            _deposits[depositId].unlock = _depositProfiles[depositProfileId].lockTime
                + block.timestamp;
            _deposits[depositId].lastMarketIndex =
                _depositProfiles[depositProfileId].marketIndex;
            _deposits[depositId].updatedAt = block.timestamp;
            _usersDepositIndexes[userAddress][depositProfileId] = depositId;
        }
        return true;
    }

    function _updateMarketIndexes (
        uint256 depositProfileId
    ) internal returns (bool) {
        uint256 period = block.timestamp - _depositProfiles[depositProfileId].marketIndexLastTime;
        uint256 marketFactor = SHIFT + SHIFT
            * _depositProfiles[depositProfileId].apr
            * period
            / DECIMALS
            / YEAR;

        _depositProfiles[depositProfileId].marketIndex =
            _depositProfiles[depositProfileId].marketIndex * marketFactor / SHIFT;

        _depositProfiles[depositProfileId].marketIndexLastTime = block.timestamp;
        return true;
    }

    function _updateYield (uint256 depositId) internal returns (bool) {
        uint256 yield = calculateYield(depositId);
        uint256 depositProfileId = _deposits[depositId].depositProfileId;
        _deposits[depositId].accumulatedYield += yield;
        _deposits[depositId].updatedAt = block.timestamp;
        _deposits[depositId].lastMarketIndex =
            _depositProfiles[depositProfileId].marketIndex;
        return true;
    }

    // view functions
    function getDepositProfilesNumber () external view returns (uint256) {
        return _depositProfilesNumber;
    }

    function getDepositProfile (
        uint256 depositProfileId
    ) external view returns (
        address depositContractAddress,
        address yieldContractAddress,
        uint256 lockTime,
        uint256 tvl,
        bool active
    ) {
        return (
            _depositProfiles[depositProfileId].depositContractAddress,
            _depositProfiles[depositProfileId].yieldContractAddress,
            _depositProfiles[depositProfileId].lockTime,
            _depositProfiles[depositProfileId].tvl,
            _depositProfiles[depositProfileId].active
        );
    }

    // view functions
    function getDepositProfileExtra (
        uint256 depositProfileId
    ) external view returns (
        uint256 stakers,
        uint256 yieldPaid,
        uint256 weight,
        string memory name,
        string memory depositCurrency,
        string memory yieldCurrency,
        string memory link
    ) {
        return (
            _depositProfiles[depositProfileId].stakers,
            _depositProfiles[depositProfileId].yieldPaid,
            _depositProfiles[depositProfileId].weight,
            _depositProfiles[depositProfileId].name,
            _depositProfiles[depositProfileId].depositCurrency,
            _depositProfiles[depositProfileId].yieldCurrency,
            _depositProfiles[depositProfileId].link
        );
    }

    function getDepositProfileRateData (
        uint256 depositProfileId
    ) external view returns (
        uint8 depositRateType,
        uint8 yieldRateType,
        uint16 apr,
        uint16 withdrawYieldTax,
        uint16 downgradeTax,
        uint256 depositUsdRate,
        uint256 yieldUsdRate
    ) {
        return (
            _depositProfiles[depositProfileId].depositRateType,
            _depositProfiles[depositProfileId].yieldRateType,
            _depositProfiles[depositProfileId].apr,
            _depositProfiles[depositProfileId].withdrawYieldTax,
            _depositProfiles[depositProfileId].downgradeTax,
            getDepositProfileDepositUsdRate(depositProfileId),
            getDepositProfileYieldUsdRate(depositProfileId)
        );
    }

    function getDepositProfileMarketData (
        uint256 depositProfileId
    ) external view returns (
        uint256 marketIndex,
        uint256 marketIndexLastTime
    ) {
        return (
            _depositProfiles[depositProfileId].marketIndex,
            _depositProfiles[depositProfileId].marketIndexLastTime
        );
    }

    function getDepositProfileDowngradeProfileId (
        uint256 depositProfileId
    ) external view returns (uint256) {
        return _depositProfiles[depositProfileId].downgradeProfileId;
    }

    function getDepositProfileUpgradeProfileId (
        uint256 depositProfileId
    ) external view returns (uint256) {
        return _depositProfiles[depositProfileId].upgradeProfileId;
    }

    function getDepositsNumber () external view returns (uint256) {
        return _depositsNumber;
    }

    function getDeposit (
        uint256 depositId
    ) external view returns (
        address userAddress, uint256 depositProfileId, uint256 amount,
        uint256 unlock, uint256 updatedAt, uint256 accumulatedYield,
        uint256 lastMarketIndex
    ) {
        return (
            _deposits[depositId].userAddress,
            _deposits[depositId].depositProfileId,
            _deposits[depositId].amount,
            _deposits[depositId].unlock,
            _deposits[depositId].updatedAt,
            _deposits[depositId].accumulatedYield,
            _deposits[depositId].lastMarketIndex
        );
    }

    function getUserDeposit (
        address userAddress, uint256 depositProfileId
    ) external view returns (
        uint256 depositIndex, uint256 amount, uint256 unlock,
        uint256 updatedAt, uint256 accumulatedYield,
        uint256 lastMarketIndex
    ) {
        uint256 depositId = _usersDepositIndexes[userAddress][depositProfileId];
        return (
            depositId,
            _deposits[depositId].amount,
            _deposits[depositId].unlock,
            _deposits[depositId].updatedAt,
            _deposits[depositId].accumulatedYield,
            _deposits[depositId].lastMarketIndex
        );
    }

    function getTokenBalance (
        address tokenAddress
    ) external view returns (uint256) {
        IERC20 tokenContract = IERC20(tokenAddress);
        return tokenContract.balanceOf(address(this));
    }

    function getSafeMode () external view returns (bool) {
        return _safeMode;
    }

    function getEditMode () external view returns (bool) {
        return _editMode;
    }

    function getTaxReceiverAddress () external view returns (address) {
        return _taxReceiverAddress;
    }

    function getTotalDeposit (
        address depositContractAddress
    ) external view returns (uint256) {
        return _totalDeposit[depositContractAddress];
    }

    function calculateYield (
        uint256 depositId
    ) public view returns (uint256) {
        uint256 depositProfileId = _deposits[depositId].depositProfileId;
        if (depositProfileId == 0) return 0;
        uint256 marketIndex =
            _depositProfiles[depositProfileId].marketIndex;
        uint256 extraPeriodStartTime
            = _depositProfiles[depositProfileId].marketIndexLastTime;
        if (extraPeriodStartTime < _deposits[depositId].updatedAt) {
            extraPeriodStartTime = _deposits[depositId].updatedAt;
        }
        uint256 extraPeriod = block.timestamp - extraPeriodStartTime;

        if (extraPeriod > 0) {
            uint256 marketFactor = SHIFT + SHIFT
                * _depositProfiles[depositProfileId].apr
                * extraPeriod
                / DECIMALS
                / YEAR;
            marketIndex = marketIndex * marketFactor / SHIFT;
        }

        uint256 newAmount = _deposits[depositId].amount
            * marketIndex
            / _deposits[depositId].lastMarketIndex;

        uint256 yield = (newAmount - _deposits[depositId].amount);

        return yield;
    }

    function getDepositYield (
        uint256 depositId,
        bool withRates
    ) external view returns (uint256) {
        if (_deposits[depositId].depositProfileId == 0) return 0;
        uint256 yield = calculateYield(depositId) + _deposits[depositId].accumulatedYield;
        if (withRates) {
            uint256 depositProfileId = _deposits[depositId].depositProfileId;
            yield = yield * getDepositProfileRate(depositProfileId) / SHIFT;
        }
        return yield;
    }

    function getEtnaUsdRate() external view returns (uint256) {
        return _etnaUsdRate;
    }

    function getMtbUsdRate() external view returns (uint256) {
        return _mtbUsdRate;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function getDepositProfileDepositUsdRate (
        uint256 depositProfileId
    ) public view returns (uint256) {
        if (
            depositProfileId == 0 || depositProfileId > _depositProfilesNumber
        ) {
            return 0;
        }
        if (_depositProfiles[depositProfileId].depositRateType == ETNA) {
            return _etnaUsdRate;
        } else if (_depositProfiles[depositProfileId].depositRateType == MTB) {
            return _mtbUsdRate;
        } else {
            return _depositProfiles[depositProfileId].depositUsdRate;
        }
    }

    function getDepositProfileYieldUsdRate (
        uint256 depositProfileId
    ) public view returns (uint256) {
        if (
            depositProfileId == 0 || depositProfileId > _depositProfilesNumber
        ) {
            return 0;
        }
        if (_depositProfiles[depositProfileId].yieldRateType == ETNA) {
            return _etnaUsdRate;
        } else if (_depositProfiles[depositProfileId].yieldRateType == MTB) {
            return _mtbUsdRate;
        } else {
            return _depositProfiles[depositProfileId].yieldUsdRate;
        }
    }

    function getDepositProfileRate (
        uint256 depositProfileId
    ) public view returns (uint256) {
        if (
            depositProfileId == 0 || depositProfileId > _depositProfilesNumber
        ) {
            return 0;
        }
        if (
            _depositProfiles[depositProfileId].depositRateType == LP_ETNA
                || _depositProfiles[depositProfileId].depositRateType == LP_MTB
        ) {
            IERC20_LP lpToken = IERC20_LP(
                _depositProfiles[depositProfileId].depositContractAddress
            );
            (uint112 tokenTotal,,) = lpToken.getReserves();
            uint256 totalSupply = lpToken.totalSupply();
            uint256 lpBaseRate;
            if (_depositProfiles[depositProfileId].depositRateType == LP_ETNA) {
                lpBaseRate = _etnaUsdRate;
            } else {
                lpBaseRate = _mtbUsdRate;
            }
            return SHIFT * tokenTotal * 2 / totalSupply
                * lpBaseRate
                / getDepositProfileYieldUsdRate(depositProfileId);
        } else {
            return SHIFT
                * getDepositProfileDepositUsdRate(depositProfileId)
                / getDepositProfileYieldUsdRate(depositProfileId);
        }
    }
}