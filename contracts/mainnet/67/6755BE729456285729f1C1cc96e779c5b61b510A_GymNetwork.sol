// SPDX-License-Identifier: MITS

pragma solidity 0.8.15;
// pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/IPancakeRouter02.sol";

interface ITaxCollector {
    function swapTokensForBNB() external returns (bool);

    function updateTaxationAmount(bool, uint96) external;
    function updateManagementTaxationAmount(uint96) external;
}

contract GymNetwork is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /// @notice EIP-20 token name for this token
    string public constant name = "GYM NETWORK V2";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "GYMNET";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Percent amount of tax for the token trade on dex
    uint8 public constant devFundTax = 6;

    /// @notice Percent amount of tax for the token sell on dex
    uint8 public constant taxOnSell = 4;

    /// @notice Percent amount of tax for the token purchase on dex
    uint8 public constant taxOnPurchase = 1;

    /// @notice Max gas price allowed for GYM transaction
    uint256 public gasPriceLimit;

    /// @notice Period of 50% sell of limit (by default 24 hours)
    uint256 public limitPeriod;

    /// @notice Total number of tokens in circulation
    uint96 public constant MAX_SUPPLY = 600000000 ether;
    uint96 public totalSupply;
    uint96 public minted;

    /// @notice Percent of how much out of supply can be held by one address
    uint96 public constant MAX_PER_HOLDER_PERCENT = 3;

    /// @notice Address of GYM Treasury
    address public managementAddress;
    address public routerAddress;
    address public taxCollector;
    /// @dev Allowance amounts on behalf of others
    mapping(address => mapping(address => uint96)) internal allowances;

    /// @dev Official record of token balances for each account
    mapping(address => uint96) internal balances;

    /// @notice A record of each accounts delegate
    mapping(address => address) public delegates;

    /// @notice A record of each DEX account
    mapping(address => bool) public isDex;

    /// @notice A record of whitelisted addresses allowed to hold more than maxPerHolder
    mapping(address => bool) private _isLimitExcempt;

    /// @notice A record of addresses disallowed to withdraw more than 50% within period
    mapping(address => bool) private _isSellLimited;

    /// @notice A record of addresses that are not taxed during trades
    mapping(address => bool) private _dexTaxExcempt;

    /// @notice A record of blacklisted addresses
    mapping(address => bool) private _isBlackListed;

    /// @notice A switch which activates or deactivates sellLimit
    bool public sellLimitActive;
    bool public isTradingPaused;
    bool public autoSwapTax;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    /// @notice A checkpoint for outgoing transaction
    struct User {
        uint96[] withdrawalAmounts;
        uint256[] withdrawalTimestamps;
    }

    /// @notice A record of account withdrawals
    mapping(address => User) private _withdrawals;

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;
    /// WBNB and BUSD Token Pair address, element 0 = Address of WBNB Token, element 1= Address of GYMNET
    address[] public wbnbAndUSDTTokenArray;
    /// GYMNET and WBNB Token Pair address, element 0 = Address of GYMNET, element 1 = Address of WBNB Token,
    address[] public GymWBNBPair;
    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event SetLimitPeriod(uint256 limit);
    event SetDexAddress(address indexed _address, bool isDex);
    event SetTaxExcemptAddress(address indexed _address, bool isExcempt);
    event SetAutoSwapTax(bool _swap);
    event SetTaxCollectorAddress(address indexed _address);

    event SetSellLimitActive(bool _isActive);
    event SetGasPriceLimit(uint256 gasPrice);
    event SetPauseTrading(bool _isPaused);
    event SetPancakeRouterAddress(address indexed _address);
    event SetManagementAddress(address indexed _address);

    event WalletBlacklist(address indexed _address, bool _blacklist);
    event WalletSellLimitExcempt(address indexed _address, bool isExcempt);
    event WalleHoldLimitExcempt(address indexed _address, bool isExcempt);

    /**
     * @notice Construct a new Gym Network
     */

    function initialize(
        address _managementAddress,
        address _routerAddress,
        address _taxCollectorAddress,
        address[] memory _wbnbAndUSDTTokenArray
    ) external initializer {
        sellLimitActive = false;
        isTradingPaused = true;
        autoSwapTax = false;
        managementAddress = _managementAddress;
        routerAddress = _routerAddress;
        taxCollector = _taxCollectorAddress;
        gasPriceLimit = 50000000000;
        limitPeriod = 86400;
        wbnbAndUSDTTokenArray = _wbnbAndUSDTTokenArray; // WBNB And USDT Token Addresses [WBNB,BUSD]
        GymWBNBPair = [address(this), _wbnbAndUSDTTokenArray[0]]; // GYMNET And WBNB Token Addresses [GYMNET,WBNB]
        _dexTaxExcempt[address(this)] = true;
        _dexTaxExcempt[routerAddress] = true;
        _dexTaxExcempt[taxCollector] = true;
        _isLimitExcempt[owner()] = true;
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 rawAmount) public returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "GymNet::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint256 rawAmount) external returns (bool) {
        uint96 amount = safe96(rawAmount, "GymNet::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "GymNet::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(
                spenderAllowance,
                amount,
                "GymNet::transferFrom: transfer amount exceeds spender allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "GymNet::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;
            // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function burn(uint256 rawAmount) public {
        uint96 amount = safe96(rawAmount, "GymNet::approve: amount exceeds 96 bits");
        _burn(msg.sender, amount);
        _moveDelegates(delegates[msg.sender],address(0),amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     */
    function burnFrom(address account, uint256 rawAmount) public {
        uint96 amount = safe96(rawAmount, "GymNet::approve: amount exceeds 96 bits");
        uint96 currentAllowance = allowances[account][msg.sender];
        require(currentAllowance >= amount, "GymToken: burn amount exceeds allowance");
        allowances[account][msg.sender] = currentAllowance - amount;
        _burn(account, amount);
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
        );
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GymNet::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "GymNet::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "GymNet::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _burn(address account, uint96 amount) internal {
        require(account != address(0), "GymToken: burn from the zero address");
        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal {
        require(
            src != address(0),
            "GymNet::_transferTokens: cannot transfer from the zero address"
        );
        require(dst != address(0), "GymNet::_transferTokens: cannot transfer to the zero address");
        require(
            !_isBlackListed[src] && !_isBlackListed[dst],
            "GymNet::_transferTokens: cannot transfer to/from blacklisted account"
        );
        require(tx.gasprice < gasPriceLimit, "GymNet::_transferTokens: gasprice limit");

        if (sellLimitActive && _isSellLimited[src]) {
            uint96 withdrawnAmount = _withdrawnLastPeriod(src);
            uint96 totalBalance = add96(
                balances[src],
                withdrawnAmount,
                "GymNet::_transferTokens: error with total balance"
            );
            uint96 totalAmountToWithdraw = add96(
                amount,
                withdrawnAmount,
                "GymNet::_transferTokens: error with total balance"
            );
            require(
                totalAmountToWithdraw < totalBalance / 2,
                "GymNet::_transferTokens: withdraw more than 50% of balance"
            );

            _withdrawals[src].withdrawalTimestamps.push(block.timestamp);
            _withdrawals[src].withdrawalAmounts.push(amount);
        }

        uint96 maxPerHolder = (totalSupply * MAX_PER_HOLDER_PERCENT) / 100;
        // if (!_dexTaxExcempt[src]) {
        //     require(!isTradingPaused, "GYMNET::_transferTokens: only liq transfer allowed");
        // }

        if (
            (!isDex[dst] && !isDex[src]) ||
            (_dexTaxExcempt[dst] || _dexTaxExcempt[src]) ||
            src == taxCollector ||
            dst == taxCollector
        ) {
            // if (!_isLimitExcempt[dst]) {
            //     require(
            //         add96(
            //             balances[dst],
            //             amount,
            //             "GymNet::_transferTokens: exceds max per holder amount"
            //         ) <= maxPerHolder,
            //         "GymNet::_transferTokens: final balance exceeds balance limit"
            //     );
            // }
            balances[src] = sub96(
                balances[src],
                amount,
                "GymNet::_transferTokens: transfer amount exceeds balance"
            );
            balances[dst] = add96(
                balances[dst],
                amount,
                "GymNet::_transferTokens: transfer amount overflows"
            );
            emit Transfer(src, dst, amount);

            _moveDelegates(delegates[src], delegates[dst], amount);
        } else {
            require(!isTradingPaused, "GymNet::_transferTokens: only liq transfer allowed");
            uint8 taxValue = isDex[src] ? taxOnPurchase : taxOnSell;
            uint96 tax = (amount * taxValue) / 100;
            uint96 teamTax = (amount * devFundTax) / 100;
            bool isBuyAction = isDex[src] ? true : false;

            // if (!_isLimitExcempt[dst]) {
            //     require(
            //         add96(
            //             balances[dst],
            //             (amount - tax - teamTax),
            //             "GymNet::_transferTokens: final balance exceeds balance limit"
            //         ) <= maxPerHolder,
            //         "GymNet::_transferTokens: final balance exceeds balance limit"
            //     );
            // }

            balances[src] = sub96(
                balances[src],
                amount,
                "GymNet::_transferTokens: transfer amount exceeds balance"
            );

            balances[taxCollector] = add96(
                balances[taxCollector],
                tax,
                "GymNet::_transferTokens: transfer amount overflows"
            );


            balances[taxCollector] = add96(
                balances[taxCollector],
                teamTax,
                "GymNet::_transferTokens: transfer amount overflows"
            );
            ITaxCollector(taxCollector).updateManagementTaxationAmount(teamTax);

            if (balances[taxCollector] > 0 && !isBuyAction) {
                ITaxCollector(taxCollector).updateTaxationAmount(false, tax);
                if (autoSwapTax) {
                    ITaxCollector(taxCollector).swapTokensForBNB();
                }
            } else {
                ITaxCollector(taxCollector).updateTaxationAmount(true, tax);
            }
           
        
            balances[dst] = add96(
                balances[dst],
                (amount - tax - teamTax),
                "GymNet::_transferTokens: transfer amount overflows"
            );

            emit Transfer(src, taxCollector, tax);
            // emit Transfer(src, managementAddress, teamTax);
            emit Transfer(src, dst, (amount - tax - teamTax));

            _moveDelegates(delegates[src], delegates[taxCollector], tax);
            // _moveDelegates(delegates[src], delegates[managementAddress], teamTax);
            _moveDelegates(delegates[src], delegates[dst], (amount - tax - teamTax));
        }
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(
                    srcRepOld,
                    amount,
                    "GymNet::_moveVotes: vote amount underflows"
                );
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(
                    dstRepOld,
                    amount,
                    "GymNet::_moveVotes: vote amount overflows"
                );
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "GymNet::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    /**
     * @dev Internal function which returns amount user withdrawn within last period.
     */
    function _withdrawnLastPeriod(address user) internal view returns (uint96) {
        uint256 numberOfWithdrawals = _withdrawals[user].withdrawalTimestamps.length;
        uint96 withdrawnAmount;
        if (numberOfWithdrawals == 0) return withdrawnAmount;

        while (true) {
            if (numberOfWithdrawals == 0) break;

            numberOfWithdrawals--;
            uint256 withdrawalTimestamp = _withdrawals[user].withdrawalTimestamps[
                numberOfWithdrawals
            ];
            if (block.timestamp - withdrawalTimestamp < limitPeriod) {
                withdrawnAmount += _withdrawals[user].withdrawalAmounts[numberOfWithdrawals];
                continue;
            }

            break;
        }

        return withdrawnAmount;
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint256) {
        return block.chainid;
    }

    function updateLimitPeriod(uint256 _newlimit) public onlyOwner {
        limitPeriod = _newlimit;

        emit SetLimitPeriod(_newlimit);
    }

    function updateDexAddress(address _dex, bool _isDex) public onlyOwner {
        isDex[_dex] = _isDex;
        _isLimitExcempt[_dex] = true;

        emit SetDexAddress(_dex, _isDex);
    }

    function updateTaxExcemptAddress(address _addr, bool _isExcempt) public onlyOwner {
        _dexTaxExcempt[_addr] = _isExcempt;

        emit SetTaxExcemptAddress(_addr, _isExcempt);
    }

    function updateAutoSwapTax(bool _autoSwapTax) public onlyOwner {
        autoSwapTax = _autoSwapTax;

        emit SetAutoSwapTax(_autoSwapTax);
    }

    function manageLimitExcempt(address[] memory users, bool[] memory _isUnlimited)
        public
        onlyOwner
    {
        require(users.length == _isUnlimited.length, "GymNet::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isLimitExcempt[users[i]] = _isUnlimited[i];

            emit WalleHoldLimitExcempt(users[i], _isUnlimited[i]);
        }
    }

    function updateTaxCollector(address _taxCollector) public onlyOwner {
        taxCollector = _taxCollector;

        emit SetTaxCollectorAddress(_taxCollector);
    }

    function manageBlacklist(address[] memory users, bool[] memory _toBlackList) public onlyOwner {
        require(users.length == _toBlackList.length, "GymNet::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isBlackListed[users[i]] = _toBlackList[i];

            emit WalletBlacklist(users[i], _toBlackList[i]);
        }
    }

    function manageSellLimitExcempt(address[] memory users, bool[] memory _toLimit)
        public
        onlyOwner
    {
        require(users.length == _toLimit.length, "GymNet::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isSellLimited[users[i]] = _toLimit[i];

            emit WalletSellLimitExcempt(users[i], _toLimit[i]);
        }
    }

    function mintFor(address account, uint96 amount) public onlyOwner {
        require(
            minted + amount <= MAX_SUPPLY,
            "GymNet::_adminFunctions: Mint more tokens than allowed"
        );

        totalSupply += amount;
        minted += amount;

        balances[account] += uint96(amount);
        emit Transfer(address(0), account, amount);
    }

    function setSellLimitActive(bool _isActive) public onlyOwner {
        sellLimitActive = _isActive;

        emit SetSellLimitActive(_isActive);
    }

    function updateGasPriceLimit(uint256 _gasPrice) public onlyOwner {
        gasPriceLimit = _gasPrice;

        emit SetGasPriceLimit(_gasPrice);
    }

    function pauseTrading(bool _isPaused) public onlyOwner {
        isTradingPaused = _isPaused;

        emit SetPauseTrading(_isPaused);
    }

    function updateRouterAddress(address _router) public onlyOwner {
        routerAddress = _router;

        emit SetPancakeRouterAddress(_router);
    }

    function updateManagementAddress(address _address) public onlyOwner {
        managementAddress = _address;

        emit SetManagementAddress(_address);
    }

    function withdrawBnb() public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }

    function setWbnbAndUSDTTokenArray(address[] memory _wbnbAndUSDTTokenArray) external onlyOwner {
        wbnbAndUSDTTokenArray = _wbnbAndUSDTTokenArray;
    }

    function setGymWBNBPair(address[] memory _GymWBNBPair) external onlyOwner {
        GymWBNBPair = _GymWBNBPair;
    }

    /**
     * Returns the latest price
     */
    function getGYMNETPrice() public view returns (uint256) {
        uint256[] memory gymPriceInUSD = IPancakeRouter02(routerAddress).getAmountsOut(
            1000000000000000000,
            GymWBNBPair
        );
        uint256[] memory BNBPriceInUSD = IPancakeRouter02(routerAddress).getAmountsOut(
            1,
            wbnbAndUSDTTokenArray
        );
        return gymPriceInUSD[1] * BNBPriceInUSD[1];
    }

    /**
     * Returns the latest price BNB
     */
    function getBNBPrice() public view returns (uint256) {
        uint256[] memory BNBPriceInUSD = IPancakeRouter02(routerAddress).getAmountsOut(
            1,
            wbnbAndUSDTTokenArray
        );
        return BNBPriceInUSD[1];
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

pragma solidity 0.8.15;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}