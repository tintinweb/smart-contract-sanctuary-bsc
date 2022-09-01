/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MITS

pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     constructor() {
        _transferOwnership(_msgSender());
    }
 
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Kswap is Ownable {
    /// @notice EIP-20 token name for this token
    string public constant name = "KSWAP";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "KTT";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Percent amount of tax for the token trade on dex
    uint8 public devFundTax = 6;

    /// @notice Percent amount of tax for the token sell on dex
    uint8 public taxOnSell = 4;

    /// @notice Percent amount of tax for the token purchase on dex
    uint8 public taxOnPurchase = 1;

    /// @notice Max gas price allowed for KTT transaction
    uint256 public gasPriceLimit = 20000000000;

    /// @notice Period of 50% sell of limit (by default 24 hours)
    uint256 public limitPeriod = 86400;

    /// @notice Total number of tokens in circulation
    uint96 public constant MAX_SUPPLY = 20000000000 ether;
    uint96 public totalSupply;
    uint96 public minted;

    /// @notice Percent of how much out of supply can be held by one address
    uint96 public constant MAX_PER_HOLDER_PERCENT = 3;

    /// @notice Address of KTT Treasury
    address public managementAddress;
    address public sellTaxAddress;
    address public purchaseTaxAddress;
    address public routerAddress;

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
        keccak256("EIP712Domain(string name,uint256 chainId,address Contract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expirye)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /**
     * @notice Construct a new KTT token
     */
    constructor() {
        sellLimitActive = true;
        isTradingPaused = true;

        managementAddress = 0x4F5Ba5d239301CAc0c908c23548EdC434018Fe4D;
        sellTaxAddress = 0xCD4f332288866199f784c7255aC2438A65BfFf0d;
        purchaseTaxAddress = 0xE3789d04421b1a86BaA990010DbE6FB4531415c9;
        routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        _dexTaxExcempt[address(this)] = true;
        _dexTaxExcempt[routerAddress] = true;
        _isLimitExcempt[owner()] = true;
        _isSellLimited[owner()] = false;
    }

   
    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    
    function approve(address spender, uint256 rawAmount) public returns (bool) {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "KTTToken::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    
    function transfer(address dst, uint256 rawAmount) external returns (bool) {
        uint96 amount = safe96(rawAmount, "KTTToken::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

  
    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "KTTToken::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(
                spenderAllowance,
                amount,
                "KTTToken::transferFrom: transfer amount exceeds spender allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

  
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

   
    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "KTTToken::getPriorVotes: not yet determined");

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
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
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

    
    function burn(uint256 rawAmount) public {
        uint96 amount = safe96(rawAmount, "KTTToken::approve: amount exceeds 96 bits");
        _burn(msg.sender, amount);
    }

    
    function burnFrom(address account, uint256 rawAmount) public {
        uint96 amount = safe96(rawAmount, "KTTToken::approve: amount exceeds 96 bits");
        uint96 currentAllowance = allowances[account][msg.sender];
        require(currentAllowance >= amount, "KTTToken: burn amount exceeds allowance");
        allowances[account][msg.sender] = currentAllowance - amount;
        _burn(account, amount);
    }

    
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

   
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expirye,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
        );
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expirye));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "KTTToken::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "KTTToken::delegateBySig: invalid nonce");
        require(block.timestamp <= expirye, "KTTToken::delegateBySig: signature expired");
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
        require(account != address(0), "KTTToken: burn from the zero address");
        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal {
        require(src != address(0), "KTTToken::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "KTTToken::_transferTokens: cannot transfer to the zero address");
        require(
            !_isBlackListed[src] && !_isBlackListed[dst],
            "KTTToken::_transferTokens: cannot transfer to/from blacklisted account"
        );
        require(tx.gasprice < gasPriceLimit, "KTTToken::_transferTokens: gasprice limit");

        if (sellLimitActive && _isSellLimited[src]) {
            uint96 withdrawnAmount = _withdrawnLastPeriod(src);
            uint96 totalBalance = add96(
                balances[src],
                withdrawnAmount,
                "KTTToken::_transferTokens: error with total balance"
            );
            uint96 totalAmountToWithdraw = add96(
                amount,
                withdrawnAmount,
                "KTTToken::_transferTokens: error with total balance"
            );
            require(
                totalAmountToWithdraw < totalBalance / 2,
                "KTTToken::_transferTokens: withdraw more than 50% of balance"
            );

            _withdrawals[src].withdrawalTimestamps.push(block.timestamp);
            _withdrawals[src].withdrawalAmounts.push(amount);
        }

        uint96 maxPerHolder = (totalSupply * MAX_PER_HOLDER_PERCENT) / 100;

        if ((!isDex[dst] && !isDex[src]) || (_dexTaxExcempt[dst] || _dexTaxExcempt[src])) {
            if (!_isLimitExcempt[dst]) {
                require(
                    add96(
                        balances[dst], amount, 
                        "KTTToken::_transferTokens: exceds max per holder amount"
                    ) <= maxPerHolder,
                    "KTTToken::_transferTokens: final balance exceeds balance limit"
                );
            }
            balances[src] = sub96(balances[src], amount, "KTTToken::_transferTokens: transfer amount exceeds balance");
            balances[dst] = add96(balances[dst], amount, "KTTToken::_transferTokens: transfer amount overflows");
            emit Transfer(src, dst, amount);

            _moveDelegates(delegates[src], delegates[dst], amount);
        } else {
            require(!isTradingPaused, "KTTToken::_transferTokens: only liq transfer allowed");
            uint8 taxValue = isDex[src] ? taxOnPurchase : taxOnSell;
            address taxTarget = isDex[src] ? purchaseTaxAddress : sellTaxAddress;
            uint96 tax = (amount * taxValue) / 100;
            uint96 teamTax = (amount * devFundTax) / 100;
            
            if (!_isLimitExcempt[dst]) {
                require(
                    add96(
                        balances[dst], (amount - tax - teamTax),
                        "KTTToken::_transferTokens: final balance exceeds balance limit"
                    ) <= maxPerHolder,
                    "KTTToken::_transferTokens: final balance exceeds balance limit"
                );
            }

            balances[src] = sub96(balances[src], amount, "KTTToken::_transferTokens: transfer amount exceeds balance");

            balances[taxTarget] = add96(
                balances[taxTarget], tax, "KTTToken::_transferTokens: transfer amount overflows"
            );
            balances[managementAddress] = add96(
                balances[managementAddress], teamTax, "KTTToken::_transferTokens: transfer amount overflows"
            );
            balances[dst] = add96(
                balances[dst],
                (amount - tax - teamTax),
                "KTTToken::_transferTokens: transfer amount overflows"
            );

            emit Transfer(src, taxTarget, tax);
            emit Transfer(src, managementAddress, teamTax);
            emit Transfer(src, dst, (amount - tax - teamTax));

            _moveDelegates(delegates[src], delegates[taxTarget], tax);
            _moveDelegates(delegates[src], delegates[managementAddress], teamTax);
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
                uint96 srcRepNew = sub96(srcRepOld, amount, "KTTToken::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "KTTToken::_moveVotes: vote amount overflows");
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
        uint32 blockNumber = safe32(block.number, "KTTToken::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

   
    function _withdrawnLastPeriod(address user) internal view returns (uint96) {
        uint256 numberOfWithdrawals = _withdrawals[user].withdrawalTimestamps.length;
        uint96 withdrawnAmount;
        if (numberOfWithdrawals == 0) return withdrawnAmount;

        while (true) {
            if (numberOfWithdrawals == 0) break;

            numberOfWithdrawals--;
            uint256 withdrawalTimestamp = _withdrawals[user].withdrawalTimestamps[numberOfWithdrawals];
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
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function updateTaxOnSell(uint8 _newTaxValue) public onlyOwner {
        require(_newTaxValue <= 80, "KTTToken::_adminFunctions: Tax cannot be greater than 80");
        taxOnSell = _newTaxValue;
    }

    function updateTaxOnPurchase(uint8 _newTaxValue) public onlyOwner {
        require(_newTaxValue <= 80, "KTTToken::_adminFunctions: Tax cannot be greater than 80");
        taxOnPurchase = _newTaxValue;
    }

    function updateDevTax(uint8 _newTaxValue) public onlyOwner {
        require(_newTaxValue <= 80, "KTTToken::_adminFunctions: Tax cannot be greater than 80");
        devFundTax = _newTaxValue;
    }

    function updateLimitPeriod(uint256 _newlimit) public onlyOwner {
        limitPeriod = _newlimit;
    }

    function updateDexAddress(address _dex, bool _isDex) public onlyOwner {
        isDex[_dex] = _isDex;
        _isLimitExcempt[_dex] = true;
    }

    function updateTaxExcemptAddress(address _addr, bool _isExcempt) public onlyOwner {
        _dexTaxExcempt[_addr] = _isExcempt;
    }

    function manageLimitExcempt(address[] memory users, bool[] memory _isUnlimited) public onlyOwner {
        require(users.length == _isUnlimited.length, "KTTToken::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isLimitExcempt[users[i]] = _isUnlimited[i];
        }
    }

    function manageBlacklist(address[] memory users, bool[] memory _toBlackList) public onlyOwner {
        require(users.length == _toBlackList.length, "KTTToken::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isBlackListed[users[i]] = _toBlackList[i];
        }
    }

    function manageSellLimitExcempt(address[] memory users, bool[] memory _toLimit) public onlyOwner {
        require(users.length == _toLimit.length, "KTTToken::_adminFunctions: Array mismatch");

        for (uint256 i; i < users.length; i++) {
            _isSellLimited[users[i]] = _toLimit[i];
        }
    }

    function mintFor(address account, uint96 amount) public onlyOwner {
        require(minted + amount <= MAX_SUPPLY, "KTTToken::_adminFunctions: Mint more tokens than allowed");

        totalSupply += amount;
        minted += amount;
        
        balances[account] = uint96(amount);
        emit Transfer(address(0), account, amount);
    }

    function setSellLimitActive(bool _isActive) public onlyOwner {
        sellLimitActive = _isActive;
    }

    function updateGasPriceLimit(uint256 _gasPrice) public onlyOwner {
        gasPriceLimit = _gasPrice;
    }

    function pauseTrading(bool _isPaused) public onlyOwner {
        isTradingPaused = _isPaused;
    }

    function updateRouterAddress(address _router) public onlyOwner {
        routerAddress = _router;
    }

    function updateManagementAddress(address _address) public onlyOwner {
        managementAddress = _address;
    }

    function updatePurchaseTaxAddress(address _address) public onlyOwner {
        purchaseTaxAddress = _address;
    }

    function updateSellTaxAddress(address _address) public onlyOwner {
        sellTaxAddress = _address;
    }
}