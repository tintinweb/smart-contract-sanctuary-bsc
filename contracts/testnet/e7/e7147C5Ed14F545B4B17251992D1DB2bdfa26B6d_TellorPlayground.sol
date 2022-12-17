// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TellorPlayground {
    // Events
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event NewReport(
        bytes32 _queryId,
        uint256 _time,
        bytes _value,
        uint256 _nonce,
        bytes _queryData,
        address _reporter
    );
    event NewStaker(address _staker, uint256 _amount);
    event StakeWithdrawRequested(address _staker, uint256 _amount);
    event StakeWithdrawn(address _staker);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Storage
    mapping(bytes32 => mapping(uint256 => bool)) public isDisputed; //queryId -> timestamp -> value
    mapping(bytes32 => mapping(uint256 => address)) public reporterByTimestamp;
    mapping(address => StakeInfo) stakerDetails; //mapping from a persons address to their staking info
    mapping(bytes32 => uint256[]) public timestamps;
    mapping(bytes32 => uint256) public tips; // mapping of data IDs to the amount of TRB they are tipped
    mapping(bytes32 => mapping(uint256 => bytes)) public values; //queryId -> timestamp -> value
    mapping(bytes32 => uint256[]) public voteRounds; // mapping of vote identifier hashes to an array of dispute IDs
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    uint256 public stakeAmount;
    uint256 public constant timeBasedReward = 5e17; // time based reward for a reporter for successfully submitting a value
    uint256 public tipsInContract; // number of tips within the contract
    uint256 public voteCount;
    address public token;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // Structs
    struct StakeInfo {
        uint256 startDate; //stake start date
        uint256 stakedBalance; // staked balance
        uint256 lockedBalance; // amount locked for withdrawal
        uint256 reporterLastTimestamp; // timestamp of reporter's last reported value
        uint256 reportsSubmitted; // total number of reports submitted by reporter
    }

    // Functions
    /**
     * @dev Initializes playground parameters
     */
    constructor() {
        _name = "TellorPlayground";
        _symbol = "TRBP";
        _decimals = 18;
        token = address(this);
    }

    /**
     * @dev Mock function for adding staking rewards. No rewards actually given to stakers
     * @param _amount Amount of TRB to be added to the contract
     */
    function addStakingRewards(uint256 _amount) external {
        require(_transferFrom(msg.sender, address(this), _amount));
    }

    /**
     * @dev Approves amount that an address is alowed to spend of behalf of another
     * @param _spender The address which is allowed to spend the tokens
     * @param _amount The amount that msg.sender is allowing spender to use
     * @return bool Whether the transaction succeeded
     *
     */
    function approve(address _spender, uint256 _amount) external returns (bool){
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * @dev A mock function to create a dispute
     * @param _queryId The tellorId to be disputed
     * @param _timestamp the timestamp of the value to be disputed
     */
    function beginDispute(bytes32 _queryId, uint256 _timestamp) external {
        values[_queryId][_timestamp] = bytes("");
        isDisputed[_queryId][_timestamp] = true;
        voteCount++;
        voteRounds[keccak256(abi.encodePacked(_queryId, _timestamp))].push(
            voteCount
        );
    }

    /**
     * @dev Allows a reporter to submit stake
     * @param _amount amount of tokens to stake
     */
    function depositStake(uint256 _amount) external {
        StakeInfo storage _staker = stakerDetails[msg.sender];
        if (_staker.lockedBalance > 0) {
            if (_staker.lockedBalance >= _amount) {
                _staker.lockedBalance -= _amount;
            } else {
                require(
                    _transferFrom(
                        msg.sender,
                        address(this),
                        _amount - _staker.lockedBalance
                    )
                );
                _staker.lockedBalance = 0;
            }
        } else {
            require(_transferFrom(msg.sender, address(this), _amount));
        }
        _staker.startDate = block.timestamp; // This resets their stake start date to now
        _staker.stakedBalance += _amount;
        emit NewStaker(msg.sender, _amount);
    }

    /**
     * @dev Public function to mint tokens to the given address
     * @param _user The address which will receive the tokens
     */
    function faucet(address _user) external {
        _mint(_user, 1000 ether);
    }

    /**
     * @dev Allows a reporter to request to withdraw their stake
     * @param _amount amount of staked tokens requesting to withdraw
     */
    function requestStakingWithdraw(uint256 _amount) external {
        StakeInfo storage _staker = stakerDetails[msg.sender];
        require(
            _staker.stakedBalance >= _amount,
            "insufficient staked balance"
        );
        _staker.startDate = block.timestamp;
        _staker.lockedBalance += _amount;
        _staker.stakedBalance -= _amount;
        emit StakeWithdrawRequested(msg.sender, _amount);
    }

    /**
     * @dev A mock function to submit a value to be read without reporter staking needed
     * @param _queryId the ID to associate the value to
     * @param _value the value for the queryId
     * @param _nonce the current value count for the query id
     * @param _queryData the data used by reporters to fulfill the data query
     */
    // slither-disable-next-line timestamp
    function submitValue(
        bytes32 _queryId,
        bytes calldata _value,
        uint256 _nonce,
        bytes memory _queryData
    ) external {
        require(keccak256(_value) != keccak256(""), "value must be submitted");
        require(
            _nonce == timestamps[_queryId].length || _nonce == 0,
            "nonce must match timestamp index"
        );
        require(
            _queryId == keccak256(_queryData) || uint256(_queryId) <= 100,
            "id must be hash of bytes data"
        );
        values[_queryId][block.timestamp] = _value;
        timestamps[_queryId].push(block.timestamp);
        reporterByTimestamp[_queryId][block.timestamp] = msg.sender;
        stakerDetails[msg.sender].reporterLastTimestamp = block.timestamp;
        stakerDetails[msg.sender].reportsSubmitted++;
        emit NewReport(
            _queryId,
            block.timestamp,
            _value,
            _nonce,
            _queryData,
            msg.sender
        );
    }

    /**
     * @dev Transfer tokens from one user to another
     * @param _recipient The destination address
     * @param _amount The amount of tokens, including decimals, to transfer
     * @return bool If the transfer succeeded
     */
    function transfer(address _recipient, uint256 _amount)
        public
        returns (bool)
    {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    /**
     * @dev Transfer tokens from user to another
     * @param _sender The address which owns the tokens
     * @param _recipient The destination address
     * @param _amount The quantity of tokens to transfer
     * @return bool Whether the transfer succeeded
     */
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(
            _sender,
            msg.sender,
            _allowances[_sender][msg.sender] - _amount
        );
        return true;
    }

    /**
     * @dev Withdraws a reporter's stake
     */
    function withdrawStake() external {
        StakeInfo storage _s = stakerDetails[msg.sender];
        // Ensure reporter is locked and that enough time has passed
        require(block.timestamp - _s.startDate >= 7 days, "7 days didn't pass");
        require(_s.lockedBalance > 0, "reporter not locked for withdrawal");
        _transfer(address(this), msg.sender, _s.lockedBalance);
        _s.lockedBalance = 0;
        emit StakeWithdrawn(msg.sender);
    }

    // Getters
    /**
     * @dev Returns the amount that an address is alowed to spend of behalf of another
     * @param _owner The address which owns the tokens
     * @param _spender The address that will use the tokens
     * @return uint256 The amount of allowed tokens
     */
    function allowance(address _owner, address _spender) external view returns (uint256){
        return _allowances[_owner][_spender];
    }

    /**
     * @dev Returns the balance of a given user.
     * @param _account user address
     * @return uint256 user's token balance
     */
    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * @return uint8 the number of decimals; used only for display purposes
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Retrieves the latest value for the queryId before the specified timestamp
     * @param _queryId is the queryId to look up the value for
     * @param _timestamp before which to search for latest value
     * @return _ifRetrieve bool true if able to retrieve a non-zero value
     * @return _value the value retrieved
     * @return _timestampRetrieved the value's timestamp
     */
    function getDataBefore(bytes32 _queryId, uint256 _timestamp)
        external
        view
        returns (
            bool _ifRetrieve,
            bytes memory _value,
            uint256 _timestampRetrieved
        )
    {
        (bool _found, uint256 _index) = getIndexForDataBefore(
            _queryId,
            _timestamp
        );
        if (!_found) return (false, bytes(""), 0);
        _timestampRetrieved = getTimestampbyQueryIdandIndex(_queryId, _index);
        _value = values[_queryId][_timestampRetrieved];
        return (true, _value, _timestampRetrieved);
    }

    /**
     * @dev Retrieves latest array index of data before the specified timestamp for the queryId
     * @param _queryId is the queryId to look up the index for
     * @param _timestamp is the timestamp before which to search for the latest index
     * @return _found whether the index was found
     * @return _index the latest index found before the specified timestamp
     */
    // slither-disable-next-line calls-loop
    function getIndexForDataBefore(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bool _found, uint256 _index)
    {
        uint256 _count = getNewValueCountbyQueryId(_queryId);
        if (_count > 0) {
            uint256 _middle;
            uint256 _start = 0;
            uint256 _end = _count - 1;
            uint256 _time;
            //Checking Boundaries to short-circuit the algorithm
            _time = getTimestampbyQueryIdandIndex(_queryId, _start);
            if (_time >= _timestamp) return (false, 0);
            _time = getTimestampbyQueryIdandIndex(_queryId, _end);
            if (_time < _timestamp) {
                while (isInDispute(_queryId, _time) && _end > 0) {
                    _end--;
                    _time = getTimestampbyQueryIdandIndex(_queryId, _end);
                }
                if (_end == 0 && isInDispute(_queryId, _time)) {
                    return (false, 0);
                }
                return (true, _end);
            }
            //Since the value is within our boundaries, do a binary search
            while (true) {
                _middle = (_end - _start) / 2 + 1 + _start;
                _time = getTimestampbyQueryIdandIndex(_queryId, _middle);
                if (_time < _timestamp) {
                    //get immediate next value
                    uint256 _nextTime = getTimestampbyQueryIdandIndex(
                        _queryId,
                        _middle + 1
                    );
                    if (_nextTime >= _timestamp) {
                        if (!isInDispute(_queryId, _time)) {
                            // _time is correct
                            return (true, _middle);
                        } else {
                            // iterate backwards until we find a non-disputed value
                            while (
                                isInDispute(_queryId, _time) && _middle > 0
                            ) {
                                _middle--;
                                _time = getTimestampbyQueryIdandIndex(
                                    _queryId,
                                    _middle
                                );
                            }
                            if (_middle == 0 && isInDispute(_queryId, _time)) {
                                return (false, 0);
                            }
                            // _time is correct
                            return (true, _middle);
                        }
                    } else {
                        //look from middle + 1(next value) to end
                        _start = _middle + 1;
                    }
                } else {
                    uint256 _prevTime = getTimestampbyQueryIdandIndex(
                        _queryId,
                        _middle - 1
                    );
                    if (_prevTime < _timestamp) {
                        if (!isInDispute(_queryId, _prevTime)) {
                            // _prevTime is correct
                            return (true, _middle - 1);
                        } else {
                            // iterate backwards until we find a non-disputed value
                            _middle--;
                            while (
                                isInDispute(_queryId, _prevTime) && _middle > 0
                            ) {
                                _middle--;
                                _prevTime = getTimestampbyQueryIdandIndex(
                                    _queryId,
                                    _middle
                                );
                            }
                            if (
                                _middle == 0 && isInDispute(_queryId, _prevTime)
                            ) {
                                return (false, 0);
                            }
                            // _prevtime is correct
                            return (true, _middle);
                        }
                    } else {
                        //look from start to middle -1(prev value)
                        _end = _middle - 1;
                    }
                }
            }
        }
        return (false, 0);
    }

    /**
     * @dev Counts the number of values that have been submitted for a given ID
     * @param _queryId the ID to look up
     * @return uint256 count of the number of values received for the queryId
     */
    function getNewValueCountbyQueryId(bytes32 _queryId)
        public
        view
        returns (uint256)
    {
        return timestamps[_queryId].length;
    }

    /**
     * @dev Returns the reporter for a given timestamp and queryId
     * @param _queryId bytes32 version of the queryId
     * @param _timestamp uint256 timestamp of report
     * @return address of data reporter
     */
    function getReporterByTimestamp(bytes32 _queryId, uint256 _timestamp)
        external
        view
        returns (address)
    {
        return reporterByTimestamp[_queryId][_timestamp];
    }

    /**
     * @dev Returns mock stake amount
     * @return uint256 stake amount
     */
    function getStakeAmount() external view returns (uint256) {
        return stakeAmount;
    }

    /**
     * @dev Allows users to retrieve all information about a staker
     * @param _stakerAddress address of staker inquiring about
     * @return uint startDate of staking
     * @return uint current amount staked
     * @return uint current amount locked for withdrawal
     * @return uint reward debt used to calculate staking reward
     * @return uint reporter's last reported timestamp
     * @return uint total number of reports submitted by reporter
     * @return uint governance vote count when first staked
     * @return uint number of votes case by staker when first staked
     * @return uint whether staker is counted in totalStakers
     */
    function getStakerInfo(address _stakerAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        StakeInfo storage _staker = stakerDetails[_stakerAddress];
        return (
            _staker.startDate,
            _staker.stakedBalance,
            _staker.lockedBalance,
            0, // reward debt
            _staker.reporterLastTimestamp,
            _staker.reportsSubmitted,
            0, // start vote count
            0, // start vote tally
            false
        );
    }

    /**
     * @dev Gets the timestamp for the value based on their index
     * @param _queryId is the queryId to look up
     * @param _index is the value index to look up
     * @return uint256 timestamp
     */
    function getTimestampbyQueryIdandIndex(bytes32 _queryId, uint256 _index)
        public
        view
        returns (uint256)
    {
        uint256 _len = timestamps[_queryId].length;
        if (_len == 0 || _len <= _index) return 0;
        return timestamps[_queryId][_index];
    }

    /**
     * @dev Returns an array of voting rounds for a given vote
     * @param _hash is the identifier hash for a vote
     * @return uint256[] memory dispute IDs of the vote rounds
     */
    function getVoteRounds(bytes32 _hash) public view returns (uint256[] memory){
        return voteRounds[_hash];
    }

    /**
     * @dev Returns the governance address of the contract
     * @return address (this address)
     */
    function governance() external view returns (address) {
        return address(this);
    }

    /**
     * @dev Returns whether a given value is disputed
     * @param _queryId unique ID of the data feed
     * @param _timestamp timestamp of the value
     * @return bool whether the value is disputed
     */
    function isInDispute(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bool)
    {
        return isDisputed[_queryId][_timestamp];
    }

    /**
     * @dev Returns the name of the token.
     * @return string name of the token
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Retrieves value from oracle based on queryId/timestamp
     * @param _queryId being requested
     * @param _timestamp to retrieve data/value from
     * @return bytes value for queryId/timestamp submitted
     */
    function retrieveData(bytes32 _queryId, uint256 _timestamp)
        external
        view
        returns (bytes memory)
    {
        return values[_queryId][_timestamp];
    }

    /**
     * @dev Returns the symbol of the token.
     * @return string symbol of the token
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the total supply of the token.
     * @return uint256 total supply of token
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Internal functions
    /**
     * @dev Internal function to approve tokens for the user
     * @param _owner The owner of the tokens
     * @param _spender The address which is allowed to spend the tokens
     * @param _amount The amount that msg.sender is allowing spender to use
     */
    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    /**
     * @dev Internal function to burn tokens for the user
     * @param _account The address whose tokens to burn
     * @param _amount The quantity of tokens to burn
     */
    function _burn(address _account, uint256 _amount) internal{
        require(_account != address(0), "ERC20: burn from the zero address");
        _balances[_account] -= _amount;
        _totalSupply -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    /**
     * @dev Internal function to create new tokens for the user
     * @param _account The address which receives minted tokens
     * @param _amount The quantity of tokens to min
     */
    function _mint(address _account, uint256 _amount) internal{
        require(_account != address(0), "ERC20: mint to the zero address");
        _totalSupply += _amount;
        _balances[_account] += _amount;
        emit Transfer(address(0), _account, _amount);
    }

    /**
     * @dev Internal function to perform token transfer
     * @param _sender The address which owns the tokens
     * @param _recipient The destination address
     * @param _amount The quantity of tokens to transfer
     */
    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal{
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require( _recipient != address(0),"ERC20: transfer to the zero address");
        _balances[_sender] -= _amount;
        _balances[_recipient] += _amount;
        emit Transfer(_sender, _recipient, _amount);
    }

    /**
     * @dev Allows this contract to transfer tokens from one user to another
     * @param _sender The address which owns the tokens
     * @param _recipient The destination address
     * @param _amount The quantity of tokens to transfer
     * @return bool Whether the transfer succeeded
     */
    function _transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(
            _sender,
            msg.sender,
            _allowances[_sender][address(this)] - _amount
        );
        return true;
    }
}