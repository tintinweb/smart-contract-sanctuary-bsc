/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

pragma solidity =0.8.0;

// ----------------------------------------------------------------------------
// GNIMB token main contract (2022)
//
// Symbol       : GNIMB
// Name         : Nimbus Governance Token
// Total supply : 100.000.000 (burnable)
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract GNIMB is Ownable, Pausable {
    string public constant name = "Nimbus Governance Token";
    string public constant symbol = "GNIMB";
    uint8 public constant decimals = 18;
    uint96 public totalSupply = 100_000_000e18; // 100 million GNIMB
    mapping (address => mapping (address => uint96)) internal allowances;

    mapping (address => uint96) private _unfrozenBalances;
    mapping (address => uint32) private _vestingNonces;
    mapping (address => mapping (uint32 => uint96)) private _vestingAmounts;
    mapping (address => mapping (uint32 => uint96)) private _unvestedAmounts;
    mapping (address => mapping (uint32 => uint)) private _vestingReleaseStartDates;
    mapping (address => bool) public vesters;

    uint96 private vestingFirstPeriod = 60 days;
    uint96 private vestingSecondPeriod = 152 days;

    address[] public supportUnits;
    uint public supportUnitsCnt;

    mapping (address => address) public delegates;
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping (address => uint) public nonces;
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Unvest(address indexed user, uint amount);

    constructor() {
        _unfrozenBalances[owner] = uint96(totalSupply);
        emit Transfer(address(0), owner, totalSupply);
    }

    receive() payable external {
        revert();
    }

    /**
     * @notice View method to get amount of funds in circulation
     * @dev freeCirculation is calculated as the total amount minus the balance on the owner's wallet and the Support Unit
     */
    function freeCirculation() external view returns (uint) {
        uint96 systemAmount = _unfrozenBalances[owner];
        for (uint i; i < supportUnits.length; i++) {
            systemAmount = add96(systemAmount, _unfrozenBalances[supportUnits[i]], "GNIMB::freeCirculation: adding overflow");
        }
        return sub96(totalSupply, systemAmount, "GNIMB::freeCirculation: amount exceed totalSupply");
    }
    
     /**
     * @dev Returns the remaining number of tokens that spender will be
     * allowed to spend on behalf of owner through {transferFrom}. 
     * This is zero by default.
     * This value changes when {approve} or {transferFrom} are called
     * @param account - address of token owner
     * @param spender - address of token spender
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    /**
     * @dev Sets amount as the allowance of spender over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param spender - address of token spender
     * @param rawAmount - the number of tokens that are allowed to spend
     * Emits an {Approval} event
     */
    function approve(address spender, uint rawAmount) external whenNotPaused returns (bool) {
        require(spender != address(0), "GNIMB::approve: approve to the zero address");

        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "GNIMB::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
     /**
     * @notice This method can be used to change an account's ERC20 allowance by
     * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
     * need to send a transaction, and thus is not required to hold Ether at all. 
     * @dev Sets value as the allowance of spender over owner's tokens,
     * given owner's signed approval
     * @param owner - address of token owner
     * @param spender - address of token spender
     * @param rawAmount -the number of tokens that are allowed to spend
     * @param deadline - the expiration date of the permit
     * @param v - the recovery id
     * @param r - outputs of an ECDSA signature
     * @param s - outputs of an ECDSA signature
     */
    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external whenNotPaused {
        uint96 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint96).max;
        } else {
            amount = safe96(rawAmount, "GNIMB::permit: amount exceeds 96 bits");
        }

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GNIMB::permit: invalid signature");
        require(signatory == owner, "GNIMB::permit: unauthorized");
        require(block.timestamp <= deadline, "GNIMB::permit: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

     /**
     * @dev View method that returns the number of tokens owned by account
     * and vesting balance
     * @param account - address of user
     */
    function balanceOf(address account) public view returns (uint) {
        uint96 amount = _unfrozenBalances[account];
        if (_vestingNonces[account] == 0) return amount;
        for (uint32 i = 1; i <= _vestingNonces[account]; i++) {
            uint96 unvested = sub96(_vestingAmounts[account][i], _unvestedAmounts[account][i], "GNIMB::balanceOf: unvested exceed vested amount");
            amount = add96(amount, unvested, "GNIMB::balanceOf: overflow");
        }
        return amount;
    }

    /**
     * @notice View method to get available for unvesting volume
     * @param user - address of user
     */
    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        if (_vestingNonces[user] == 0) return 0;
        for (uint32 i = 1; i <= _vestingNonces[user]; i++) {
            if (_vestingAmounts[user][i] == _unvestedAmounts[user][i]) continue;
            if (_vestingReleaseStartDates[user][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[user][i]) * _vestingAmounts[user][i] / vestingSecondPeriod;
            if (toUnvest > _vestingAmounts[user][i]) {
                toUnvest = _vestingAmounts[user][i];
            } 
            toUnvest -= _unvestedAmounts[user][i];
            unvestAmount += toUnvest;
        }
    }

    /**
     * @notice View method to get available for transfer amount
     * @param account - address of user
     */
    function availableForTransfer(address account) external view returns (uint) {
        return _unfrozenBalances[account];
    }

    /**
     * @notice View method to get vesting Information
     * @param user - address of user
     * @param nonce - nonce of current lock
     */
    function vestingInfo(address user, uint32 nonce) external view returns (uint vestingAmount, uint unvestedAmount, uint vestingReleaseStartDate) {
        vestingAmount = _vestingAmounts[user][nonce];
        unvestedAmount = _unvestedAmounts[user][nonce];
        vestingReleaseStartDate = _vestingReleaseStartDates[user][nonce];
    }

    /**
     * @notice View method to get last vesting nonce for user 
     * @param user - address of user
     */
    function vestingNonces(address user) external view returns (uint lastNonce) {
        return _vestingNonces[user];
    }

     /**
     * @dev Moves amount tokens from the caller's account to dst.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param dst - address of user
     * @param rawAmount - amount of token that you want to send
     */
    function transfer(address dst, uint rawAmount) external whenNotPaused returns (bool) {
        uint96 amount = safe96(rawAmount, "GNIMB::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

     /**
     * @dev Moves amount tokens from src to dst using the
     * allowance mechanism
     * amount is then deducted from the caller's allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param src - address from
     * @param dst - address of user
     * @param rawAmount - amount of token that you want to send
     */
    function transferFrom(address src, address dst, uint rawAmount) external whenNotPaused returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "GNIMB::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint96).max) {
            uint96 newAllowance = sub96(spenderAllowance, amount, "GNIMB::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

     /**
     * @notice Changes delegatee
     * @param delegatee - address of user
     * @dev delegate your votes to another user
     */
    function delegate(address delegatee) public whenNotPaused {
        return _delegate(msg.sender, delegatee);
    }

      /**
     * @notice Changes delegatee
     * @param delegatee - address of user
     * @param nonce - signature nonce
     * @param expiry - the expiration date of the permit
     * @param v - the recovery id
     * @param r - outputs of an ECDSA signature
     * @param s - outputs of an ECDSA signature
     * @dev delegate your votes to another user with signature
     */
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public whenNotPaused {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GNIMB::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "GNIMB::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "GNIMB::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

     /**
     * @dev This method is used to withdraw tokens from vesting
     * Emits a {Unvest} event.
     */
    function unvest() external whenNotPaused returns (uint unvested) {
        require (_vestingNonces[msg.sender] > 0, "GNIMB::unvest:No vested amount");
        for (uint32 i = 1; i <= _vestingNonces[msg.sender]; i++) {
            if (_vestingAmounts[msg.sender][i] == _unvestedAmounts[msg.sender][i]) continue;
            if (_vestingReleaseStartDates[msg.sender][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[msg.sender][i]) * _vestingAmounts[msg.sender][i] / vestingSecondPeriod;
            if (toUnvest > _vestingAmounts[msg.sender][i]) {
                toUnvest = _vestingAmounts[msg.sender][i];
            } 
            uint totalUnvestedForNonce = toUnvest;
            require(toUnvest >= _unvestedAmounts[msg.sender][i], "GNIMB::unvest: already unvested amount exceeds toUnvest");
            toUnvest -= _unvestedAmounts[msg.sender][i];
            unvested += toUnvest;
            _unvestedAmounts[msg.sender][i] = safe96(totalUnvestedForNonce, "GNIMB::unvest: amount exceeds 96 bits");
        }
        _unfrozenBalances[msg.sender] = add96(_unfrozenBalances[msg.sender], safe96(unvested, "GNIMB::unvest: amount exceeds 96 bits"), "GNIMB::unvest: adding overflow");
        uint96 votes = safe96(unvested, "GNIMB::unvest: votes amount exceeds 96 bits");
        _moveDelegates(address(0), delegates[msg.sender], votes);
        emit Unvest(msg.sender, unvested);
    }

    /**
     * @notice View method to get total number of delegated votes for user
     * @param account - address of user
     */
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     /**
     * @notice View method to get total number of delegated votes for the user at a particular moment (block number)
     * @param account - address of user
     * @param blockNumber - particular block number
     */
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "GNIMB::getPriorVotes: not yet determined");

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
    
    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = _unfrozenBalances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "GNIMB::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "GNIMB::_transferTokens: cannot transfer to the zero address");

        _unfrozenBalances[src] = sub96(_unfrozenBalances[src], amount, "GNIMB::_transferTokens: transfer amount exceeds balance");
        _unfrozenBalances[dst] = add96(_unfrozenBalances[dst], amount, "GNIMB::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }
    
    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "GNIMB::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "GNIMB::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }
    
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
      uint32 blockNumber = safe32(block.number, "GNIMB::_writeCheckpoint: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function _vest(address user, uint96 amount) private {
        require(user != address(0), "GNIMB::_vest: vest to the zero address");
        uint32 nonce = ++_vestingNonces[user];
        _vestingAmounts[user][nonce] = amount;
        _vestingReleaseStartDates[user][nonce] = block.timestamp + vestingFirstPeriod;
        _unfrozenBalances[owner] = sub96(_unfrozenBalances[owner], amount, "GNIMB::_vest: exceeds owner balance");
        emit Transfer(owner, user, amount);
    }

    /**
     * @dev Destroys the number of tokens from the owner account, reducing the total supply.
     * can be called only from the owner account
     * @param rawAmount - the number of tokens that will be burned
     * Emits a {Transfer} event.
     * @param rawAmount -  amount of token that you want to burn
     */
    function burnTokens(uint rawAmount) public onlyOwner returns (bool success) {
        uint96 amount = safe96(rawAmount, "GNIMB::burnTokens: amount exceeds 96 bits");
        require(amount <= _unfrozenBalances[owner]);
        _unfrozenBalances[owner] = sub96(_unfrozenBalances[owner], amount, "GNIMB::burnTokens: transfer amount exceeds balance");
        totalSupply = sub96(totalSupply, amount, "GNIMB::burnTokens: transfer amount exceeds total supply");
        emit Transfer(owner, address(0), amount);
        return true;
    }

    /**
     * @dev Transfer frozen funds to user
     * @param user - address of user
     * @param rawAmount - GNIMB amount 
     * Emits a {Transfer} event.
     */
    function vest(address user, uint rawAmount) external {
        require (vesters[msg.sender], "GNIMB::vest: not vester");
        uint96 amount = safe96(rawAmount, "GNIMB::vest: amount exceeds 96 bits");
        _vest(user, amount);
    }

    /**
     * @dev This method is used to send funds to several users in single transaction (up to 99 users)
     * can be called only from the owner account
     * @param to - an array of  the user's adresses
     * @param values - an array of GNIMB amounts
     * Emits a {Transfer} event.
     */
    function multisend(address[] memory to, uint[] memory values) public onlyOwner returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        uint96 _sum = safe96(sum, "GNIMB::transfer: amount exceeds 96 bits");
        _unfrozenBalances[owner] = sub96(_unfrozenBalances[owner], _sum, "GNIMB::_transferTokens: transfer amount exceeds balance");
        for (uint i; i < to.length; i++) {
            _unfrozenBalances[to[i]] = add96(_unfrozenBalances[to[i]], uint96(values[i]), "GNIMB::_transferTokens: transfer amount exceeds balance");
            uint96 votes = safe96(values[i], "GNIMB::unvest: votes amount exceeds 96 bits");
            _moveDelegates(delegates[msg.sender], delegates[to[i]], votes);
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

    /**
     * @dev This method is used to accrue frozen funds to several users at the same time (up to 99 users)
     * can be called only from the owner account
     * @param to - an array of  the user's adresses
     * @param values - an array of GNIMB amounts
     * Emits a {Transfer} event.
     */
    function multivest(address[] memory to, uint[] memory values) external onlyOwner returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        uint96 _sum = safe96(sum, "GNIMB::multivest: amount exceeds 96 bits");
        _unfrozenBalances[owner] = sub96(_unfrozenBalances[owner], _sum, "GNIMB::multivest: transfer amount exceeds balance");
        for (uint i; i < to.length; i++) {
            uint32 nonce = ++_vestingNonces[to[i]];
            _vestingAmounts[to[i]][nonce] = uint96(values[i]);
            _vestingReleaseStartDates[to[i]][nonce] = block.timestamp + vestingFirstPeriod;
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

     /**
     * @dev This method is used to withdraw any ERC20 tokens from the contract
     * can be called only from the owner account
     * @param tokenAddress - token address
     * @param tokens - token amount
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    /**
     * @dev This method is used to add new vesters
     * can be called only from the owner account
     * @param vester - new vester 
     * @param isActive - boolean condition
     */
    function updateVesters(address vester, bool isActive) external onlyOwner { 
        vesters[vester] = isActive;
    }

    function acceptOwnership() public override {
        require(msg.sender == newOwner);
        uint96 amount = _unfrozenBalances[owner];
        _transferTokens(owner, newOwner, amount);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

     /**
     * @dev This method is used to add addresses that were excluded from circulation 
     * can be called only from the owner account
     * @param newSupportUnit - new SupportUnit address
     */
    function updateSupportUnitAdd(address newSupportUnit) external onlyOwner {
        for (uint i; i < supportUnits.length; i++) {
            require (supportUnits[i] != newSupportUnit, "GNIMB::updateSupportUnitAdd: support unit exists");
        }
        supportUnits.push(newSupportUnit);
        supportUnitsCnt++;
    }

    /**
     * @dev This method is used to  remove address from SuportUnit
     * can be called only from the owner account
     * @param supportUnitIndex - index of SuportUnit
     */
    function updateSupportUnitRemove(uint supportUnitIndex) external onlyOwner {
        supportUnits[supportUnitIndex] = supportUnits[supportUnits.length - 1];
        supportUnits.pop();
        supportUnitsCnt--;
    }
    

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint) {
        return block.chainid;
    }

        
    function mul96(uint96 a, uint96 b) internal pure returns (uint96) {
        if (a == 0) {
            return 0;
        }
        uint96 c = a * b;
        require(c / a == b, "GNIMB:mul96: multiplication overflow");
        return c;
    }

    function mul96(uint256 a, uint96 b) internal pure returns (uint96) {
        uint96 _a = safe96(a, "GNIMB:mul96: amount exceeds uint96");
        if (_a == 0) {
            return 0;
        }
        uint96 c = _a * b;
        require(c / _a == b, "GNIMB:mul96: multiplication overflow");
        return c;
    }
}