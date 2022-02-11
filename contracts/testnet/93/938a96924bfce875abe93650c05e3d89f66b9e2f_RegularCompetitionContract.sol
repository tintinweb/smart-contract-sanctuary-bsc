/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// File: contracts/library/String.sol


pragma solidity ^0.8.0;

library String {
    function append(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function compare(string memory a, string memory b) internal pure returns(bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function toBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}

// File: contracts/interface/ICompetitionPool.sol



pragma solidity ^0.8.0;

interface ICompetitionPool {
    function checkRefund(address _betting) external view returns (bool);

    function checkMinEntrants(address _betting) external view returns (bool);

    function checkBettingContractExist(address _pool) external returns (bool);
}

// File: contracts/metadata/Metadata.sol


pragma solidity ^0.8.0;

interface Metadata {
    // uint256 public constant OHP = 1e4; // one hundred percent - 100%

    struct RewardRate {
        uint256 creator;
        uint256 owner;
        uint256 winner;
    }
    enum SportType {
        LOL,
        CSGO,
        DOTA2
    }
    enum Status {
        Lock,
        Open,
        End,
        Refund,
        Non_Eligible
    }
    enum Player {
        NoPlayer,
        Player1,
        Player2
    }

    enum Attribute {
        WinTeam,
        Kill,
        Death,
        Assist,
        TowersDestroyed
    }
}

// File: contracts/interface/ICompetitionContract.sol


pragma solidity ^0.8.0;


interface ICompetitionContract is Metadata {
    event Ready(
        uint256 timestamp,
        uint256 startTimestamp,
        uint256 endTimestamp
    );
    event Close(uint256 timestamp, uint256 winerReward);
    event SetRewardRate(
        uint256 rateCreator,
        uint256 rateOwner,
        uint256 rateWinner
    );

    function getEntryFee() external view returns (uint256);

    function getFee() external view returns (uint256);

    function placeBet(
        address user,
        uint256[] memory betIndexs
    ) external;

    function distributedReward() external;

    function setRewardRate(RewardRate memory _rewardRate) external;
}

// File: contracts/interface/IRegularCompetitionContract.sol


pragma solidity ^0.8.0;



interface IRegularCompetitionContract is Metadata {
    struct Competition {
        string competitionId;
        string player1;
        string player2;
        SportType sportTypeAlias;
        uint256 winnerReward;
    }

    struct BetOption {
        Attribute attribute;
        string player;
        uint256[] brackets;
    }

    event PlaceBet(address indexed buyer, uint256[] brackets, uint256 fee);

    function setBasic(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _entryFee,
        uint256 _minEntrant,
        uint256 _guaranteeFee
    ) external returns (bool);

    function start() external;

    function setOracle(address _oracle) external;

    function setCompetition(
        string memory _competitionId,
        string memory _player1,
        string memory _player2,
        SportType _sportTypeAlias
    ) external;

    function getDataToCheckRefund() external view returns (bytes32, uint256);

    function getTicketSell(uint256[] memory _brackets)
        external
        view
        returns (address[] memory);

    function setBetOptions(BetOption[] memory _betOptions) external;

    function getTeam() external view returns (string memory, string memory);

    function getRequestId() external view returns (bytes32);
}

// File: contracts/interface/IChainLinkOracleSportData.sol


pragma solidity ^0.8.0;

interface IChainLinkOracleSportData {
    function getPayment() external returns (uint256);

    function requestData(string memory _matchId, string memory _teamId)
        external
        returns (bytes32);

    function requestData(
        string memory _matchId,
        string memory _teamId1,
        string memory _teamId2
    ) external returns (bytes32);

    function getData(bytes32 _id) external view returns (uint256[] memory);

    function checkFulfill(bytes32 _requestId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/Address.sol



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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol



pragma solidity ^0.8.0;



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

// File: contracts/CompetitionContract.sol


pragma solidity ^0.8.0;



abstract contract CompetitionContract is ICompetitionContract {    
    using SafeERC20 for IERC20;

    uint256 internal constant OHP = 1e4;

    address public immutable owner;
    address public immutable creator;
    address public immutable tokenAddress;

    uint256 public totalFee;
    uint256 public minEntrant;
    uint256 public guaranteeFee;
    uint256 public entryFee;
    uint256 public fee;

    uint256 public startBetTime;
    uint256 public endBetTime;

    RewardRate public rewardRate;
    bool public stopBet;
    Status public status = Status.Lock;

    mapping(address => bool) public betOrNotYet;
    address[] public listBuyer;

    constructor(
        address _owner,
        address _creator,
        address _tokenAddress,
        uint256 _fee
    ) {
        owner = _owner;
        creator = _creator;
        tokenAddress = _tokenAddress;
        fee = _fee;
    }

    modifier betable(address user) {
        require(user != creator, "CC: Creator cannot bet");
        require(!betOrNotYet[user], "CC: No betable");
        require(!stopBet, "CC: No betable");
        require(
            block.timestamp >= startBetTime &&
                block.timestamp <= endBetTime,
            "CC: No betable"
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "CC: Only owner");
        _;
    }

    modifier onlyCreator() {
        require(creator == msg.sender, "CC: Only creator");
        _;
    }

    modifier onlyOwnerOrCreator() {
        require(
            owner == msg.sender || creator == msg.sender,
            "CC: Only owner or creator"
        );
        _;
    }

    modifier onlyLock() {
        require(status == Status.Lock, "CC: Required NOT start");
        _;
    }

    modifier onlyOpen() {
        require(status == Status.Open, "CC: Required Open");
        _;
    }

    function getEntryFee() external view override returns (uint256) {
        return entryFee;
    }

    function getFee() external view override returns (uint256) {
        return fee;
    }

    function setRewardRate(RewardRate memory _rewardRate)
        external
        override
        onlyOwner
    {
        rewardRate = _rewardRate;
        emit SetRewardRate(
            rewardRate.creator,
            rewardRate.owner,
            rewardRate.winner
        );
    }

    function toggleStopBet() external onlyCreator {
        stopBet = !stopBet;
    }

    function getTotalToken(address _token) public view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function _checkEntrantCodition() internal view returns (bool) {
        if (listBuyer.length >= minEntrant) {
            return true;
        } else {
            return false;
        }
    }

    function _sendRewardToWinner(address[] memory winners, uint256 winnerReward) internal {
        if (winners.length == 0 || winnerReward == 0) return;

        uint256 reward = winnerReward / winners.length;
        for (uint256 i = 0; i < winners.length - 1; i++) {
            IERC20(tokenAddress).safeTransfer(winners[i], reward);
        }

        uint256 remaining = winnerReward - (winners.length - 1) * reward;
        IERC20(tokenAddress).safeTransfer(
            winners[winners.length - 1],
            remaining
        );
    }
}

// File: contracts/RegularCompetitionContract.sol


pragma solidity ^0.8.0;







contract RegularCompetitionContract is
    CompetitionContract,
    IRegularCompetitionContract
{
    using SafeERC20 for IERC20;
    using String for string;
    Competition public competition;
    uint256 public gapValidateTime = 300;

    address public oracle;

    mapping(bytes32 => address[]) public ticketSell;
    BetOption[] public betOptions;

    mapping(SportType => mapping(Attribute => bool)) notSupportAtribute;

    bytes32 private requestID;

    constructor(
        address _owner,
        address _creator,
        address _tokenAddress,
        uint256 _fee
    ) CompetitionContract(_owner, _creator, _tokenAddress, _fee) {
        notSupportAtribute[SportType.CSGO][Attribute.TowersDestroyed] = true;
    }

    function setOracle(address _oracle) external override onlyOwner {
        require(_oracle != address(0));
        oracle = _oracle;
    }

    function getDataToCheckRefund()
        external
        view
        override
        returns (bytes32, uint256)
    {
        return (requestID, endBetTime);
    }

    function getRequestId() external view override returns (bytes32) {
        return requestID;
    }

    function getTicketSell(uint256[] memory _brackets)
        external
        view
        override
        returns (address[] memory)
    {
        bytes32 _key = _generateKey(_brackets);
        return ticketSell[_key];
    }

    function getBetOptions() external view returns (BetOption[] memory) {
        return (betOptions);
    }

    function getTeam()
        external
        view
        override
        returns (string memory, string memory)
    {
        return (competition.player1, competition.player2);
    }

    function setBasic(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _entryFee,
        uint256 _minEntrant,
        uint256 _guaranteeFee
    ) external override onlyOwner onlyLock returns (bool) {
        require(block.timestamp <= _startTimestamp, "RCC: Time is illegal");
        require(_startTimestamp < _endTimestamp, "RCC: endTime < startTime");
        startBetTime = _startTimestamp;
        endBetTime = _endTimestamp;
        entryFee = _entryFee;
        minEntrant = _minEntrant;
        guaranteeFee = _guaranteeFee;
        return true;
    }

    function setCompetition(
        string memory _competitionId,
        string memory _player1,
        string memory _player2,
        SportType _sportTypeAlias
    ) external override onlyOwner onlyLock {
        competition = Competition(
            _competitionId,
            _player1,
            _player2,
            _sportTypeAlias,
            0
        );
    }

    function setBetOptions(BetOption[] memory _betOptions)
        external
        override
        onlyOwner
        onlyLock
    {
        for (uint256 i = 0; i < _betOptions.length; i++) {
            require(
                !notSupportAtribute[competition.sportTypeAlias][
                    _betOptions[i].attribute
                ],
                "RCC: Attribute is not supported"
            );

            require(
                _checkBetOption(i, _betOptions),
                "RCC: _betOptions invalid"
            );
            if (_betOptions[i].attribute == Attribute.WinTeam) {
                uint256[] memory brackets = new uint256[](2);
                brackets[0] = 0;
                brackets[1] = 1;
                betOptions.push(
                    BetOption({
                        attribute: Attribute.WinTeam,
                        player: "",
                        brackets: brackets
                    })
                );
            } else {
                require(
                    _betOptions[i].player.compare(competition.player1) ||
                        _betOptions[i].player.compare(competition.player2),
                    "RCC: Player invalid"
                );
                betOptions.push(_betOptions[i]);
            }
        }
    }

    function start() external override onlyOwner onlyLock {
        require(endBetTime >= block.timestamp, "RCC: expired");
        require(getTotalToken(tokenAddress) >= fee + guaranteeFee);
        totalFee = fee;
        status = Status.Open;
        emit Ready(block.timestamp, startBetTime, endBetTime);
    }

    function placeBet(address user, uint256[] memory betIndexs)
        external
        override
        onlyOpen
        betable(user)
        onlyOwner
    {
        require(betIndexs.length == betOptions.length, "RCC: Invalid length");
        for (uint256 i = 0; i < betIndexs.length; i++) {
            require(
                betIndexs[i] < betOptions[i].brackets.length,
                "RCC: Invalid bracket"
            );
        }
        uint256 totalToken = getTotalToken(tokenAddress);
        uint256 totalEntryFee = listBuyer.length * entryFee;
        require(
            totalToken >=
                totalEntryFee + totalFee + guaranteeFee + fee + entryFee
        );
        totalFee += fee;
        betOrNotYet[user] = true;
        listBuyer.push(user);
        bytes32 key = _generateKey(betIndexs);
        ticketSell[key].push(user);
        emit PlaceBet(user, betIndexs, entryFee + fee);
    }

    function _generateKey(uint256[] memory array)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(array));
    }

    function requestData() external {
        require(block.timestamp > endBetTime);
        bool enoughEntrant = _checkEntrantCodition();
        if (enoughEntrant) {
            requestID = IChainLinkOracleSportData(oracle).requestData(
                competition.competitionId,
                competition.player1,
                competition.player2
            );
        }
    }

    function distributedReward() external override onlyOpen {
        require(
            block.timestamp > endBetTime + gapValidateTime,
            "RCC: Please waiting for end time and request data"
        );

        bool enoughEntrant = _checkEntrantCodition();
        address[] memory winners;
        uint256 creatorReward;
        uint256 ownerReward;
        uint256 winnerReward;
        uint256 totalEntryFee = listBuyer.length * entryFee;
        if (!enoughEntrant) {
            status = Status.Non_Eligible;
            winners = listBuyer;
            winnerReward = totalEntryFee;
            ownerReward = totalFee;
            creatorReward = guaranteeFee;
        } else {
            (bytes32 key, bool success) = _getResult();
            if (!success) {
                status = Status.Refund;
                winners = listBuyer;
                winnerReward = totalEntryFee + totalFee - fee;
                ownerReward = 0;
                creatorReward = fee + guaranteeFee;
            } else {
                uint256 totalReward;
                status = Status.End;

                if (guaranteeFee > 0) {
                    totalReward = guaranteeFee;
                    creatorReward = totalEntryFee;
                } else {
                    totalReward = totalEntryFee;
                }

                if (key != bytes32(0)) {
                    winners = ticketSell[key];
                } else {
                    winners = listBuyer;
                }
                winnerReward = (totalReward * rewardRate.winner) / OHP;
                creatorReward += (totalReward * rewardRate.creator) / OHP;
                ownerReward = (totalReward * rewardRate.owner) / OHP + totalFee;
            }
        }

        competition.winnerReward = winnerReward;

        if (ownerReward > 0) {
            IERC20(tokenAddress).safeTransfer(owner, ownerReward);
        }
        if (creatorReward > 0) {
            IERC20(tokenAddress).safeTransfer(creator, creatorReward);
        }
        if (winnerReward > 0 && winners.length > 0) {
            _sendRewardToWinner(winners, winnerReward);
        }

        uint256 remaining = getTotalToken(tokenAddress);
        if (remaining > 0) {
            IERC20(tokenAddress).safeTransfer(creator, remaining);
        }

        emit Close(block.timestamp, competition.winnerReward);
    }

    function _getResult() private view returns (bytes32 _key, bool _success) {
        if (ICompetitionPool(owner).checkRefund(address(this))) {
            return (bytes32(0), false);
        }
        uint256[] memory result = IChainLinkOracleSportData(oracle).getData(
            requestID
        );
        require(result.length != 0, "RCC: Not result");

        uint256[] memory betWin = new uint256[](betOptions.length);

        for (uint256 i = 0; i < betOptions.length; i++) {
            BetOption memory betOption = betOptions[i];
            if (betOption.attribute == Attribute.WinTeam) {
                if (String.toString(result[0]).compare(competition.player1)) {
                    betWin[i] = 0;
                } else {
                    betWin[i] = 1;
                }
            } else {
                uint256 index = _getOracleResultIndex(
                    betOption.attribute,
                    betOption.player
                );
                uint256 winIndex = _getBracketIndex(
                    betOption.brackets,
                    result[index]
                );
                betWin[i] = winIndex;
            }
        }

        return (_generateKey(betWin), true);
    }

    function _getOracleResultIndex(Attribute attribute, string memory playerId)
        private
        view
        returns (uint256 index)
    {
        if (Attribute.WinTeam == attribute) return 0;
        if (playerId.compare(competition.player1)) {
            if (Attribute.Kill == attribute) return 1;
            if (Attribute.Death == attribute) return 2;
            if (Attribute.Assist == attribute) return 3;
            if (Attribute.TowersDestroyed == attribute) return 4;
        }
        if (playerId.compare(competition.player2)) {
            if (Attribute.Kill == attribute) return 5;
            if (Attribute.Death == attribute) return 6;
            if (Attribute.Assist == attribute) return 7;
            if (Attribute.TowersDestroyed == attribute) return 8;
        }
    }

    function _getBracketIndex(uint256[] memory brackets, uint256 value)
        internal
        pure
        returns (uint256 index)
    {
        if (value < brackets[0]) {
            return 0;
        }
        if (value >= brackets[brackets.length - 1]) {
            return brackets.length;
        }
        for (uint256 i = 0; i < brackets.length - 1; i++) {
            if (value < brackets[i + 1]) {
                return i + 1;
            }
        }
    }

    function _checkBetOption(uint256 _index, BetOption[] memory _betOptions)
        private
        pure
        returns (bool)
    {
        for (uint256 j = _index + 1; j < _betOptions.length; j++) {
            if (
                _betOptions[_index].attribute == _betOptions[j].attribute &&
                _betOptions[_index].player.compare(_betOptions[j].player)
            ) {
                return false;
            }
        }

        return true;
    }
}