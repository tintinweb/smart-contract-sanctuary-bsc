// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IERC20.sol";

/**
 * @title HENToken
 */
contract HENToken is IERC20 {
    /**
     * The struct of one minter.
     */
    struct Minter {
        // enabled/disabled flag
        bool enabled;
        // the number of minters that request a ban on this account
        uint numBanRequests;
    }

    /**
     * The struct of one minting request.
     */
    struct MintingRequest {
        // recipient of tokens
        address recipient;
        // amount of tokens
        uint amount;
        // the number of minter approvals for this request
        uint numApprovals;
        // executed/not executed flag
        bool executed;
    }

    /**
     * The struct of one minting period.
     */
    struct MintingPeriod {
        // duration of minting period in seconds
        uint duration;
        // the number of tokens to be minted after the end of the period
        uint amount;
    }

    // minting start time in seconds
    uint private _mintingStartAt;
    // array of minting periods
    MintingPeriod[] private _mintingPeriods;

    // list of all wallets (address -> number of tokens)
    mapping(address => uint) private _balances;
    // list of all allowances (owner => [spender => number of tokens])
    mapping(address => mapping(address => uint)) private _allowances;
    // total number of tokens
    uint private _totalSupply;

    // list of all mining requests
    MintingRequest[] private _mintingRequests;
    // list of all addresses that have voted for approval a request (rIdx => (address => isApproved))
    mapping(uint => mapping(address => bool)) private _mintingRequestApprovals;

    // list of all minters (address => Minter struct)
    mapping(address => Minter) private _minters;
    // list of all addresses that request for minter ban (account for ban => (requester account => isRequested))
    mapping(address => mapping(address => bool)) private _minterBanRequests;
    // total number of minters
    uint private _totalMinters;
    // how many minters must approve a mint/ban request
    uint private _minApprovalsRequired;

    event BanRequest(address indexed requester, address indexed account);
    event BanRevocation(address indexed requester, address indexed account);
    event Ban(address indexed requester, address indexed account);

    event MintingRequestCreation(address indexed minter, uint indexed rIdx, address indexed recipient, uint amount);
    event MintingRequestApproval(address indexed minter, uint indexed rIdx);
    event MintingRequestRevocation(address indexed minter, uint indexed rIdx);
    event Minting(address indexed minter, uint indexed rIdx, address indexed recipient, uint amount);


    constructor(
        uint mintingStartAt,
        MintingPeriod[] memory mintingPeriods,
        address[] memory minters,
        uint minApprovalsRequired
    ) {
        require(minters.length > 0, "HENToken: Minters are required.");
        require(
            minApprovalsRequired > 0 &&
            minApprovalsRequired <= minters.length,
            "HENToken: Invalid number of minimum votes."
        );

        for (uint i=0; i<minters.length; i++) {
            require(minters[i] != address(0), "HENToken: Zero address.");
            require(!_minters[minters[i]].enabled, "HENToken: Minters are not unique.");

            Minter storage minter = _minters[minters[i]];
            minter.enabled = true;
        }

        _totalMinters = minters.length;
        _minApprovalsRequired = minApprovalsRequired;

        _mintingStartAt = mintingStartAt;
        for (uint i=0; i<mintingPeriods.length; i++) {
            _mintingPeriods.push(mintingPeriods[i]);
        }
    }


    // ---------------------------------------------------------------------------------------------------------------
    // ERC20 Meta implementation
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Returns the name of the token.
     */
    function name() external pure returns (string memory) {
        return "Rich Hens";
    }

    /**
     * Returns the symbol of the token.
     */
    function symbol() external pure returns (string memory) {
        return "HEN";
    }

    /**
     * Returns the decimals places of the token.
     */
    function decimals() external pure returns (uint8) {
        return 8;
    }


    // ---------------------------------------------------------------------------------------------------------------
    // ERC20 implementation
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    /**
     * See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    /**
     * Mints tokens to the account
     */
    function _mint(address account, uint amount) internal {
        require(account != address(0), "HENToken: Zero address.");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /**
     * See {IERC20-transfer}.
     */
    function transfer(address to, uint amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * See {IERC20-transferFrom}.
     */
    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(_allowances[from][to] >= amount, "HENToken: Insufficient allowance.");

        _allowances[from][to] -= amount;
        _transfer(from, to, amount);

        return true;
    }

    /**
     * See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    /**
     * See {IERC20-approve}.
     */
    function approve(address spender, uint amount) public returns (bool) {
        require(spender != address(0), "HENToken: Zero address.");

        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     */
    function _transfer(address from, address to, uint amount) internal {
        require(from != address(0), "HENToken: Zero address.");
        require(to != address(0), "HENToken: Zero address.");

        require(_balances[from] >= amount, "HENToken: Transfer amount exceeds balance.");
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Functions for mint
    // ---------------------------------------------------------------------------------------------------------------
    modifier onlyMinter() {
        require(_minters[msg.sender].enabled, "HENToken: You are not a minter.");
        _;
    }
    /**
     * Mints tokens specified in the minting request with the index rIdx.
     *
     * - the request must be approved by _minApprovalsRequired minters.
     * - the requested amount of tokens must be less than or equal to the minting schedule.
     */
    function mint(uint rIdx) external onlyMinter {
        require(rIdx < _mintingRequests.length, "HENToken: Request does not exist.");
        require(!_mintingRequests[rIdx].executed, "HENToken: Request is already executed.");
        require(_mintingRequests[rIdx].numApprovals >= _minApprovalsRequired, "HENToken: Not enough approves.");
        require(_mintingRequests[rIdx].amount <= (totalAvailable() - totalSupply()), "HENToken: Too many tokens to mint.");

        _mint(_mintingRequests[rIdx].recipient, _mintingRequests[rIdx].amount);

        _mintingRequests[rIdx].executed = true;

        emit Minting(msg.sender, rIdx, _mintingRequests[rIdx].recipient, _mintingRequests[rIdx].amount);
    }

    /**
     * Creates and approves a minting request. Each request gets an index "rIdx".
     *
     * @param recipient - address for transferring tokens
     * @param amount    - number of tokens
     * @return          - index of request (rIdx)
     */
    function requestMinting(address recipient, uint amount) external onlyMinter returns (uint) {
        uint rIdx = _mintingRequests.length;

        _mintingRequests.push(
            MintingRequest({
                recipient: recipient,
                amount: amount,
                numApprovals: 1,
                executed: false
            })
        );

        _mintingRequestApprovals[rIdx][msg.sender] = true;

        emit MintingRequestCreation(msg.sender, rIdx, recipient, amount);

        return rIdx;
    }

    /**
     * Approves the minting request that was created by the requestMinting function.
     */
    function approveMintingRequest(uint rIdx) external onlyMinter returns (uint) {
        require(rIdx < _mintingRequests.length, "HENToken: Request does not exist.");
        require(!_mintingRequests[rIdx].executed, "HENToken: Request is already executed.");
        require(!_mintingRequestApprovals[rIdx][msg.sender], "HENToken: Request is already approved.");

        _mintingRequestApprovals[rIdx][msg.sender] = true;
        _mintingRequests[rIdx].numApprovals++;

        emit MintingRequestApproval(msg.sender, rIdx);

        return _mintingRequests[rIdx].numApprovals;
    }

    /**
     * Revokes the already approved request.
     */
    function revokeMintingRequest(uint rIdx) external onlyMinter {
        require(rIdx < _mintingRequests.length, "HENToken: Request does not exist.");
        require(!_mintingRequests[rIdx].executed, "HENToken: Request is already executed.");
        require(_mintingRequestApprovals[rIdx][msg.sender], "HENToken: Request is not approved.");

        _mintingRequestApprovals[rIdx][msg.sender] = false;
        _mintingRequests[rIdx].numApprovals--;

        emit MintingRequestRevocation(msg.sender, rIdx);
    }

    /**
     * Returns the total number of mint requests, which is also the index for the next mint request.
     */
    function getTotalMintingRequests() external view returns (uint) {
        return _mintingRequests.length;
    }

    /**
     * Returns data about the minting request
     */
    function getMintingRequest(uint rIdx) external view returns (MintingRequest memory) {
        return _mintingRequests[rIdx];
    }

    /**
     * Returns data about all minting requests
     */
    function getAllMintingRequests() external view returns (MintingRequest[] memory) {
        return _mintingRequests;
    }

    /**
     * Returns the limit of tokens that can be minted for all time.
     */
    function limitSupply() public view returns (uint) {
        uint limitAmount;

        for (uint i=0; i<_mintingPeriods.length; i++) {
            limitAmount += _mintingPeriods[i].amount;
        }

        return limitAmount;
    }

    /**
     * Returns the amount of tokens that can be minted so far.
     */
    function totalAvailable() public view returns (uint) {
        if (getCurrentTime() < _mintingStartAt) {
            return 0;
        }

        uint availableAmount;
        uint elapsedPeriodsTime;
        uint elapsedTime = getCurrentTime() - _mintingStartAt;

        for (uint i=0; i<_mintingPeriods.length; i++) {
            elapsedPeriodsTime += _mintingPeriods[i].duration;
            if (elapsedPeriodsTime > elapsedTime) {
                break;
            }

            availableAmount += _mintingPeriods[i].amount;
        }

        return availableAmount;
    }

    /**
     * Returns minting start time in seconds.
     */
    function getMintingStartAt() public view returns (uint) {
        return _mintingStartAt;
    }

    /**
     * Returns minting period by an index.
     */
    function getMintingPeriod(uint index) public view returns (MintingPeriod memory) {
        return _mintingPeriods[index];
    }

    /**
     * Returns minting periods
     */
    function getMintingPeriods() public view returns (MintingPeriod[] memory) {
        return _mintingPeriods;
    }

    /**
     * Returns all minting periods.
     */
    function getTotalMintingPeriods() public view returns (uint) {
        return _mintingPeriods.length;
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Work with minters
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Requests the ban for the minter.
     * It's needed _minApprovalsRequired confirms to allow the ban.
     */
    function requestMinterBan(address account) external onlyMinter {
        require(_minters[account].enabled, "HENToken: The account is not a minter.");
        require(account != msg.sender, "HENToken: It is forbidden to ban yourself.");
        require(!_minterBanRequests[account][msg.sender], "HENToken: The request already exists.");

        _minterBanRequests[account][msg.sender] = true;
        _minters[account].numBanRequests++;

        emit BanRequest(msg.sender, account);
    }

    /**
     * Revokes a previous ban request
     */
    function revokeMinterBanRequest(address account) external onlyMinter {
        require(_minterBanRequests[account][msg.sender], "HENToken: The request does not exists.");

        _minterBanRequests[account][msg.sender] = false;
        _minters[account].numBanRequests--;

        emit BanRevocation(msg.sender, account);
    }

    /**
     * Bans the minter
     * It's needed _minApprovalsRequired confirms to allow the ban.
     */
    function banMinter(address account) external onlyMinter {
        require(_minters[account].enabled, "HENToken: The account is not a minter.");
        require(account != msg.sender, "HENToken: It is forbidden to ban yourself.");
        require(_minters[account].numBanRequests >= _minApprovalsRequired, "HENToken: Not enough requests.");
        
        _minters[account].enabled = false;
        _totalMinters--;

        emit Ban(msg.sender, account);
    }

    /**
     * Returns the total number of minters
     */
    function getTotalMinters() external view returns (uint) {
        return _totalMinters;
    }

    /**
     * Check if the account is a minter
     */
    function isMinter(address account) external view returns (bool) {
        return _minters[account].enabled;
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * @dev Returns time of the current block. (for using in mock)
     */
    function getCurrentTime() public virtual view returns(uint) {
        return block.timestamp;
    }
}