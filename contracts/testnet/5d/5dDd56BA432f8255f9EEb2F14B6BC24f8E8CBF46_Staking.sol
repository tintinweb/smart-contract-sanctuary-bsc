/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

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

contract Staking {
    modifier onlyOwner() {
        require(msg.sender == _owner, 'Caller is not the owner');
        _;
    }
    modifier onlyManager() {
        require(_managers[msg.sender], 'Caller is not the manager');
        _;
    }

    struct DepositProfile {
        address contractAddress; // Zero address for a native currency
        uint8 depositType; // 1 - BULLPAD, 2 - another ERC20, 3 - LP tokens
        uint16 apr; // apr (% * 100, 2501 means 25.01%)
        uint16 tax; // tax (% * 100, 2501 means 25.01%),
        // for depositType LP_TOKEN tax will be applied before lockTime end
        // when withdraw yield
        uint16 penalty; // penalty for unstake before locktime (% * 100, 2501 means 25.01%)
        // for BULLPAD and ERC20 only
        uint256 rate; // rate in BULLPAD * 100
        uint256 weight; // sorting order at UI (asc from left to right)
        uint256 marketIndex; // market index to treat possible rate changes
        uint256 marketIndexLastTime;
        // timestamp when market index was changed last time
        uint256 tvl;  // total amount of tokens deposited in a pool
        uint256 lockTime;
        // lock period for erc20 or taxed withdraw period for LP tokens in seconds
        string name; // information field
        string currency; // information field
        string link; // information field
        bool bullpadYield; // if yes yield will be paid in BULLPAD tokens
        bool active; // if false stake/unstake functions will be disabled
    }

    mapping (uint256 => DepositProfile) internal _depositProfiles;

    struct Deposit {
        address userAddress;
        uint256 depositProfileIndex;
        uint256 amount; // amount deposited
        uint256 unlock; // unix timestamp of the lock time end
        uint256 lockTime; // lock time in seconds
        uint256 lastMarketIndex; // service index
        uint256 updatedAt; // timestamp, is resettled to block.timestamp when changed
        uint256 accumulatedYield; // used to store reward when changed
    }
    mapping (uint256 => Deposit) internal _deposits;
    mapping (address => mapping(uint256 => uint256)) internal _usersDepositIndexes;
    mapping (address => uint256) internal _totalDeposit;
    mapping (address => bool) internal _managers;

    uint256 internal _depositProfilesNumber; // deposit profiles counter
    uint256 internal _depositsNumber; // deposits counter
    uint256 internal constant _year = 365 * 24 * 3600;
    uint256 internal constant _shift = 1 ether;
    // used for exponent shifting when calculation with decimals
    uint8 internal constant BULLPAD_TOKEN = 1;
    uint8 internal constant ERC20_TOKEN = 2;
    uint8 internal constant LP_TOKEN = 3;
    IERC20 internal _bullpadContract;
    address internal _owner;
    address internal _penaltyReceiver;
    bool internal _safeMode;

    constructor (
        address bullpadAddress,
        address newOwner,
        address penaltyReceiver
    ) {
        require(bullpadAddress != address(0), 'Token address can not be zero');
        require(newOwner != address(0), 'Owner address can not be zero');

        _bullpadContract = IERC20(bullpadAddress);
        _owner = newOwner;
        _managers[newOwner] = true;
        _penaltyReceiver = penaltyReceiver;
    }

    /**
     * @dev Deposit assets to the contract
     */
    function stake (
        uint256 amount, uint256 depositProfileIndex
    ) external returns (bool) {
        require(
            _depositProfiles[depositProfileIndex].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        IERC20 depositTokenContract = IERC20(
            _depositProfiles[depositProfileIndex].contractAddress
        );
        require(
            depositTokenContract.transferFrom(msg.sender, address(this), amount),
            'Transfer does not return true'
        );
        uint256 depositIndex = _usersDepositIndexes[msg.sender][depositProfileIndex];
        if (depositIndex > 0) {
            _updateYield(depositIndex);
            _deposits[depositIndex].amount += amount;
            _deposits[depositIndex].unlock =
                _depositProfiles[depositProfileIndex].lockTime + block.timestamp;
            _deposits[depositIndex].lockTime = _depositProfiles[depositProfileIndex].lockTime;
        } else {
            _depositsNumber ++;
            depositIndex = _depositsNumber;
            _deposits[depositIndex] = Deposit({
                userAddress: msg.sender,
                depositProfileIndex: depositProfileIndex,
                amount: amount,
                unlock: _depositProfiles[depositProfileIndex].lockTime
                    + block.timestamp,
                lockTime: _depositProfiles[depositProfileIndex].lockTime,
                lastMarketIndex: _depositProfiles[depositProfileIndex].marketIndex,
                updatedAt: block.timestamp,
                accumulatedYield: 0
            });
            _usersDepositIndexes[msg.sender][depositProfileIndex] = depositIndex;
        }
        _depositProfiles[depositProfileIndex].tvl += amount;
        _totalDeposit[_depositProfiles[depositProfileIndex].contractAddress] += amount;

        return true;
    }

    /**
     * @dev Withdraw assets deposited to the contract
     */
    function unStake (
        uint256 amount, uint256 depositProfileIndex
    ) external returns (bool) {
        require(
            _depositProfiles[depositProfileIndex].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        uint256 depositIndex = _usersDepositIndexes[msg.sender][depositProfileIndex];
        require(depositIndex > 0, 'Deposit is not found');
        _updateYield(depositIndex);
        require(_deposits[depositIndex].amount >= amount, 'Not enough amount at deposit');
        uint256 penalties;
        if (
            (_depositProfiles[depositProfileIndex].depositType == BULLPAD_TOKEN
            || _depositProfiles[depositProfileIndex].depositType == ERC20_TOKEN)
            && block.timestamp < _deposits[depositIndex].unlock
        ) {
            penalties = amount
                * _depositProfiles[depositProfileIndex].penalty
                * (_deposits[depositIndex].unlock - block.timestamp)
                / 10000
                / _deposits[depositIndex].lockTime;
        }
        _deposits[depositIndex].amount -= amount;
        _depositProfiles[depositProfileIndex].tvl -= amount;
        _totalDeposit[_depositProfiles[depositProfileIndex].contractAddress] -= amount;
        IERC20 depositTokenContract =
            IERC20(_depositProfiles[depositProfileIndex].contractAddress);

        if (penalties > 0) {
            amount -= penalties;
            require(
                depositTokenContract.transfer(_penaltyReceiver, penalties),
                'Transfer does not return true'
            );
        }

        require(
            depositTokenContract.transfer(msg.sender, amount),
            'Transfer does not return true'
        );

        return true;
    }

    /**
     * @dev Deposit accumulated yield to the contract
     */
    function reStake (uint256 depositProfileIndex) external returns (bool) {
        uint256 depositIndex = _usersDepositIndexes[msg.sender][depositProfileIndex];
        require(depositIndex > 0, 'Deposit is not found');
        require(_depositProfiles[depositProfileIndex].depositType
            == BULLPAD_TOKEN, 'Available for BULLPAD deposits only');
        require(
            _depositProfiles[depositProfileIndex].active, 'This deposit profile is disabled'
        );
        _updateYield(depositIndex);
        uint256 yield = _deposits[depositIndex].accumulatedYield;
        _deposits[depositIndex].accumulatedYield = 0;
        _deposits[depositIndex].amount += yield;
        _depositProfiles[depositProfileIndex].tvl += yield;
        _totalDeposit[_depositProfiles[depositProfileIndex].contractAddress] += yield;

        return true;
    }

    /**
     * @dev Withdraw yield
     */
    function withdrawYield (
        uint256 amount, uint256 depositProfileIndex
    ) external returns (bool) {
        uint256 depositIndex = _usersDepositIndexes[msg.sender][depositProfileIndex];
        require(depositIndex > 0, 'Deposit is not found');
        require(
            _depositProfiles[depositProfileIndex].active, 'This deposit profile is disabled'
        );
        require(amount > 0, 'Amount should be greater than zero');
        _updateYield(depositIndex);
        require(
            _deposits[depositIndex].accumulatedYield >= amount, 'Not enough yield at deposit'
        );
        uint256 taxAmount;
        IERC20 tokenContract = _bullpadContract;
        if (
            _depositProfiles[depositProfileIndex].depositType == ERC20_TOKEN
            && !_depositProfiles[depositProfileIndex].bullpadYield
        ) {
            tokenContract = IERC20(_depositProfiles[depositProfileIndex].contractAddress);
        } else if (
            _depositProfiles[depositProfileIndex].depositType == LP_TOKEN
            && block.timestamp < _deposits[depositIndex].unlock
        ) {
            taxAmount = amount * _depositProfiles[depositProfileIndex].tax / 10000;
        }
        _deposits[depositIndex].accumulatedYield -= amount;
        uint256 balance = tokenContract.balanceOf(address(this));
        require(amount <= balance, 'Not enough contract balance');
        if (_safeMode) {
            require(balance - amount >= _totalDeposit[address(tokenContract)],
                'Not enough contract balance (safe mode)');
        }
        if (taxAmount > 0) {
            amount -= taxAmount;
            require(
                _bullpadContract.transfer(_penaltyReceiver, taxAmount),
                'Transfer does not return true'
            );
        }
        require(
            tokenContract.transfer(msg.sender, amount),
            'Transfer does not return true'
        );

        return true;
    }

    // admin functions
    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), 'newOwner should not be zero address');
        _owner = newOwner;
        return true;
    }

    function addToManagers (
        address userAddress
    ) external onlyOwner returns (bool) {
        _managers[userAddress] = true;
        return true;
    }

    function removeFromManagers (
        address userAddress
    ) external onlyOwner returns (bool) {
        _managers[userAddress] = false;
        return true;
    }

    function setPenaltyReceiver (
        address penaltyReceiver
    ) external onlyOwner returns (bool) {
        require(penaltyReceiver != address(0), 'Penalty receiver address can not be zero');
        _penaltyReceiver = penaltyReceiver;
        return true;
    }

    function setSafeMode (
        bool safeMode
    ) external onlyOwner returns (bool) {
        _safeMode = safeMode;
        return true;
    }

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
        require(
            tokenContract.transfer(msg.sender, amount),
            'Transfer does not return true'
        );
        return true;
    }

    function adminWithdrawbullpad (
        uint256 amount
    ) external onlyOwner returns (bool) {
        uint256 balance = _bullpadContract.balanceOf(address(this));
        require(amount <= balance, 'Not enough contract balance');
        if (_safeMode) {
            require(balance - amount >= _totalDeposit[address(_bullpadContract)],
                'Not enough contract balance (safe mode)');
        }
        require(
            _bullpadContract.transfer(msg.sender, amount),
            'Transfer does not return true'
        );
        return true;
    }

    // managers functions
    function addDepositProfile (
        address contractAddress,
        uint8 depositType,
        uint16 apr,
        uint16 tax,
        uint16 penalty,
        uint256 rate,
        uint256 weight,
        uint256 lockTime,
        string calldata name,
        bool bullpadYield,
        bool active
    ) external onlyManager returns (bool) {
        require(depositType > 0 && depositType <= LP_TOKEN, 'Unknown type');
        require(tax <= 9999, 'Not valid withdraw tax');
        require(penalty <= 9999, 'Not valid penalty');

        _depositProfilesNumber ++;

        if (depositType == BULLPAD_TOKEN) {
            contractAddress = address(_bullpadContract);
            rate = 0;
            tax = 0;
            bullpadYield = true;
        } else if (depositType == ERC20_TOKEN) {
            require(rate > 0, 'For ERC20 token rate should be greater than zero');
            tax = 0;
            if (!bullpadYield) rate = 100;
        } else if (depositType == LP_TOKEN) {
            rate = 0;
            penalty = 0;
            bullpadYield = true;
        }
        IERC20 token = IERC20(contractAddress);
        require(token.decimals() == 18, 'Only for tokens with decimals 18');
        _depositProfiles[_depositProfilesNumber] = DepositProfile({
            contractAddress: contractAddress,
            depositType: depositType,
            apr: apr,
            tax: tax,
            penalty: penalty,
            rate: rate,
            weight: weight,
            marketIndex: 1 * _shift,
            marketIndexLastTime: block.timestamp,
            tvl: 0,
            lockTime: lockTime,
            name: name,
            currency: 'BULLPAD',
            link: '',
            bullpadYield: bullpadYield,
            active: active
        });
        return true;
    }

    function setDepositProfileApr (
        uint256 depositProfileIndex,
        uint16 apr
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        uint256 period = block.timestamp - _depositProfiles[depositProfileIndex].marketIndexLastTime;
        uint256 marketFactor = _shift +
        _shift * _depositProfiles[depositProfileIndex].apr * period / 10000 / _year;
        _depositProfiles[depositProfileIndex].marketIndex =
        _depositProfiles[depositProfileIndex].marketIndex * marketFactor / _shift;
        _depositProfiles[depositProfileIndex].apr = apr;
        _depositProfiles[depositProfileIndex].marketIndexLastTime = block.timestamp;

        return true;
    }

    function setDepositProfileTax (
        uint256 depositProfileIndex,
        uint16 tax
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(_depositProfiles[depositProfileIndex].depositType
            == LP_TOKEN, 'Tax can be set for LP tokens only');
        _depositProfiles[depositProfileIndex].tax = tax;

        return true;
    }

    function setDepositProfilePenalty (
        uint256 depositProfileIndex,
        uint16 penalty
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(_depositProfiles[depositProfileIndex].depositType
            != LP_TOKEN, 'Penalty can not be set for LP tokens');
        _depositProfiles[depositProfileIndex].penalty = penalty;

        return true;
    }

    function setDepositProfileRate (
        uint256 depositProfileIndex,
        uint256 rate
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        require(_depositProfiles[depositProfileIndex].depositType
            == ERC20_TOKEN, 'Rate can be set for ERC20 tokens only');
        require(rate > 0, 'For ERC20 token rate should be greater than zero');
        _depositProfiles[depositProfileIndex].rate = rate;

        return true;
    }

    function setDepositProfileWeight (
        uint256 depositProfileIndex,
        uint256 weight
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].weight = weight;

        return true;
    }

    function setDepositProfileLockTime (
        uint256 depositProfileIndex,
        uint256 lockTime
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].lockTime = lockTime;

        return true;
    }

    function setDepositProfileName (
        uint256 depositProfileIndex,
        string calldata name
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].name = name;

        return true;
    }

    function setDepositProfileCurrency (
        uint256 depositProfileIndex,
        string calldata currency
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].currency = currency;

        return true;
    }

    function setDepositProfileLink (
        uint256 depositProfileIndex,
        string calldata link
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].link = link;

        return true;
    }

    function setDepositProfileStatus (
        uint256 depositProfileIndex,
        bool active
    ) external onlyManager returns (bool) {
        require(depositProfileIndex > 0 && depositProfileIndex <= _depositProfilesNumber,
            'Deposit profile is not found');
        _depositProfiles[depositProfileIndex].active = active;

        return true;
    }

    function setBullpadContract (
        address tokenAddress
    ) external onlyManager returns (bool) {
        require(tokenAddress != address(0), 'Token address can not be zero');
        _bullpadContract = IERC20(tokenAddress);
        return true;
    }

    /**
     * @dev Storing yield at the accumulatedYield field of the user's deposit record
     */
    function _updateYield (uint256 depositIndex) internal returns (bool) {
        uint256 yield = calculateYield(depositIndex);
        _deposits[depositIndex].accumulatedYield += yield;
        _deposits[depositIndex].updatedAt = block.timestamp;
        _deposits[depositIndex].lastMarketIndex =
        _depositProfiles[_deposits[depositIndex].depositProfileIndex].marketIndex;

        return true;
    }

    /**
     * @dev Deposit profile record details
     */
    function getDepositProfile (
        uint256 depositProfileIndex
    ) external view returns (
        address contractAddress, uint256 tvl, uint256 lockTime, uint16 apr,
        uint8 depositType, bool active
    ) {
        return (
            _depositProfiles[depositProfileIndex].contractAddress,
            _depositProfiles[depositProfileIndex].tvl,
            _depositProfiles[depositProfileIndex].lockTime,
            _depositProfiles[depositProfileIndex].apr,
            _depositProfiles[depositProfileIndex].depositType,
            _depositProfiles[depositProfileIndex].active
        );
    }

    /**
     * @dev Deposit profile record extra details
     */
    function getDepositProfileExtra (
        uint256 depositProfileIndex
    ) external view returns (
        uint256 weight, uint16 tax, uint256 penalty,
        string memory name, string memory currency, string memory link,
        bool bullpadYield
    ) {
        return (
            _depositProfiles[depositProfileIndex].weight,
            _depositProfiles[depositProfileIndex].tax,
            _depositProfiles[depositProfileIndex].penalty,
            _depositProfiles[depositProfileIndex].name,
            _depositProfiles[depositProfileIndex].currency,
            _depositProfiles[depositProfileIndex].link,
            _depositProfiles[depositProfileIndex].bullpadYield
        );
    }

    /**
     * @dev Deposit profile rate calculation
     */
    function getDepositProfileRate (
        uint256 depositProfileIndex
    ) public view returns (uint256) {
        if (depositProfileIndex == 0 || depositProfileIndex > _depositProfilesNumber) {
            return 0;
        }
        if (_depositProfiles[depositProfileIndex].depositType
            == BULLPAD_TOKEN) {
            return 100;
        }
        if (_depositProfiles[depositProfileIndex].depositType
            == ERC20_TOKEN) {
            return _depositProfiles[depositProfileIndex].rate;
        }
        if (_depositProfiles[depositProfileIndex].depositType
            == LP_TOKEN) {
            IERC20_LP lpToken = IERC20_LP(_depositProfiles[depositProfileIndex].contractAddress);
            (uint112 BULLPAD_Total,,) = lpToken.getReserves();
            uint256 total = lpToken.totalSupply();
            return BULLPAD_Total * 2 * 100 / total;
        }
        return 0;
    }

    /**
     * @dev Deposits counter getter
     */
    function getDepositsNumber () external view returns (uint256) {
        return _depositsNumber;
    }

    /**
     * @dev Deposit profiles counter getter
     */
    function getDepositProfilesNumber () external view returns (uint256) {
        return _depositProfilesNumber;
    }


    /**
     * @dev Deposit record details by deposit index
     */
    function getDeposit (
        uint256 depositIndex
    ) external view returns (
        address userAddress, uint256 depositProfileIndex, uint256 amount,
        uint256 unlock, uint256 lockTime, uint256 updatedAt, uint256 accumulatedYield
    ) {
        return (
            _deposits[depositIndex].userAddress,
            _deposits[depositIndex].depositProfileIndex,
            _deposits[depositIndex].amount,
            _deposits[depositIndex].unlock,
            _deposits[depositIndex].lockTime,
            _deposits[depositIndex].updatedAt,
            _deposits[depositIndex].accumulatedYield
        );
    }

    /**
     * @dev Deposit record details by user address and deposit profile index
     */
    function getUserDeposit (
        address userAddress, uint256 depositProfileIndex
    ) external view returns (
        uint256 depositIndex, uint256 amount,
        uint256 unlock, uint256 lockTime, uint256 updatedAt, uint256 accumulatedYield
    ) {
        uint256 depositIndex_ = _usersDepositIndexes[userAddress][depositProfileIndex];
        return (
            depositIndex_,
            _deposits[depositIndex_].amount,
            _deposits[depositIndex_].unlock,
            _deposits[depositIndex_].lockTime,
            _deposits[depositIndex_].updatedAt,
            _deposits[depositIndex_].accumulatedYield
        );
    }

    /**
     * @dev BULLPAD contract address getter
     */
    function getBullpadContract () external view returns (address) {
        return address(_bullpadContract);
    }

    /**
     * @dev Penalty receiver address getter
     */
    function getPenaltyReceiver () external view returns (address) {
        return _penaltyReceiver;
    }

    /**
     * @dev Yield calculation
     */
    function calculateYield (uint256 depositIndex) public view returns (uint256) {
        uint256 marketIndex =
            _depositProfiles[_deposits[depositIndex].depositProfileIndex].marketIndex;

        uint256 extraPeriodStartTime
            = _depositProfiles[_deposits[depositIndex].depositProfileIndex].marketIndexLastTime;
        if (extraPeriodStartTime < _deposits[depositIndex].updatedAt) {
            extraPeriodStartTime = _deposits[depositIndex].updatedAt;
        }
        uint256 extraPeriod = block.timestamp - extraPeriodStartTime;

        if (extraPeriod > 0) {
            uint256 marketFactor = _shift +
                _shift
                * _depositProfiles[_deposits[depositIndex].depositProfileIndex].apr
                * extraPeriod / 10000 / _year;
            marketIndex = marketIndex * marketFactor / _shift;
        }

        uint256 newAmount = _deposits[depositIndex].amount
            * marketIndex
            / _deposits[depositIndex].lastMarketIndex;

        uint256 yield = (newAmount - _deposits[depositIndex].amount)
            * getDepositProfileRate(_deposits[depositIndex].depositProfileIndex)
            / 100;

        return yield;
    }

    /**
     * @dev Arbitrary token balance of the contract
     */
    function getTokenBalance (address tokenAddress) external view returns (uint256) {
        IERC20 tokenContract = IERC20(tokenAddress);
        return tokenContract.balanceOf(address(this));
    }

    /**
     * @dev BULLPAD token balance of the contract
     */
    function getBullpadBalance () external view returns (uint256) {
        return _bullpadContract.balanceOf(address(this));
    }

    /**
     * @dev Safe mode getter
     */
    function getSafeMode () external view returns (bool) {
        return _safeMode;
    }

    /**
     * @dev Total deposit of the specified token
     */
    function getTotalDeposit (address contractAddress) external view returns (uint256) {
        return _totalDeposit[contractAddress];
    }

    /**
     * @dev Service function for a max allocation calculation in the sale contract
     */
    function getTokenAmountLimit (
        address userAddress,
        bool isWhitelisted,
        uint256 maxTokenAmount,
        uint256 threshold,
        uint16[] calldata factors // multiplied by 100, 20 => 0.2
    ) external view returns (uint256) {
        require(
            factors.length == _depositProfilesNumber + 1,
            'factors length should be equal deposit profiles number + 1'
        );
        uint256 _maxTokenAmount;
        for (uint256 i = 1; i <= _depositProfilesNumber; i ++) {
            uint256 depositIndex = _usersDepositIndexes[userAddress][i];
            if (depositIndex == 0) continue;
            uint256 depositAmount = _deposits[depositIndex].amount
                * getDepositProfileRate(i)
                / 100;
            uint256 amount = depositAmount > threshold
                ? threshold
                : depositAmount;
            _maxTokenAmount += maxTokenAmount
                * amount
                * factors[i]
                / 100
                / threshold;
        }
        if (isWhitelisted) {
            uint256 guestAmount = _bullpadContract.balanceOf(userAddress);
            if (guestAmount > threshold) guestAmount = threshold;
            _maxTokenAmount += maxTokenAmount
                * guestAmount
                * factors[0]
                / threshold
                / 100;
        }
        return _maxTokenAmount;
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
     * @dev Contract timestamp getter
     */
    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Owner address getter
     */
    function owner() external view returns (address) {
        return _owner;
    }
}

//https://bscscan.com/address/0x3a0ec93393775f4429909fb4e079d42afabeea02#code