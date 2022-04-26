// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/SimpleReadAccessController.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";

contract CollectAggregator is AggregatorV2V3Interface, SimpleReadAccessController {
    struct Round {
      int256 answer;
      uint64 startedAt;
      uint64 updatedAt;
      uint32 answeredInRound;
    }

    uint32 internal latestRoundId;
    mapping(uint32 => Round) internal rounds;

    uint8 public override decimals;
    string public override description;

    int256 immutable public minSubmissionValue;
    int256 immutable public maxSubmissionValue;

    uint256 constant public override version = 3;

    uint32 constant private ROUND_MAX = 2**32-1;
    // An error specific to the Aggregator V3 Interface, to prevent possible
    // confusion around accidentally reading unset values as reported values.
    string constant private V3_NO_DATA_ERROR = "No data present";
    address private _operator;

    /**
    * @notice set up the aggregator with initial configuration
    * @param _timeout is the number of seconds after the previous round that are
    * allowed to lapse before allowing an oracle to skip an unfinished round
    * @param _minSubmissionValue is an immutable check for a lower bound of what
    * submission values are accepted from an oracle
    * @param _maxSubmissionValue is an immutable check for an upper bound of what
    * submission values are accepted from an oracle
    * @param _decimals represents the number of decimals to offset the answer by
    * @param _description a short description of what is being reported
    */
    constructor(
      uint32 _timeout,
      int256 _minSubmissionValue,
      int256 _maxSubmissionValue,
      uint8 _decimals,
      string memory _description
    ) {
      minSubmissionValue = _minSubmissionValue;
      maxSubmissionValue = _maxSubmissionValue;
      decimals = _decimals;
      description = _description;
      rounds[0].updatedAt = uint64(block.timestamp - (uint256(_timeout)));
    }

    modifier onlyOperator() {
      require(operator() == msg.sender, "caller is not the operator");
      _;
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function operator() public view virtual returns (address) {
        return _operator;
    }

    /**
     * @dev Transfers operational ownership of the contract to a new account (`newOperator`).
     * Can only be called by the current owner.
     */
    function transferOperationalOwnership(address newOperator) public onlyOwner {
        require(newOperator != address(0), "new operator is the zero address");
        _operator = newOperator;
    }

    /**
      * Receive the response in the form of uint256
      */ 
    function submit(int256 _data) public onlyOperator
    {
      require(_data >= minSubmissionValue, "value below minSubmissionValue");
      require(_data <= maxSubmissionValue, "value above maxSubmissionValue");

      updateRoundAnswer(latestRoundId + 1, _data);
    }

    /**
    * @notice get the most recently reported answer
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestAnswer()
      public
      view
      virtual
      override
      returns (int256)
    {
      return rounds[latestRoundId].answer;
    }

    /**
    * @notice get the most recent updated at timestamp
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestTimestamp()
      public
      view
      virtual
      override
      returns (uint256)
    {
      return rounds[latestRoundId].updatedAt;
    }

    /**
    * @notice get the ID of the last updated round
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestRound()
      public
      view
      virtual
      override
      returns (uint256)
    {
      return latestRoundId;
    }

    /**
    * @notice get past rounds answers
    * @param _roundId the round number to retrieve the answer for
    *
    * @dev #[deprecated] Use getRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended getRoundData
    * instead which includes better verification information.
    */
    function getAnswer(uint256 _roundId)
      public
      view
      virtual
      override
      returns (int256)
    {
      if (validRoundId(_roundId)) {
        return rounds[uint32(_roundId)].answer;
      }
      return 0;
    }

    /**
    * @notice get timestamp when an answer was last updated
    * @param _roundId the round number to retrieve the updated timestamp for
    *
    * @dev #[deprecated] Use getRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended getRoundData
    * instead which includes better verification information.
    */
    function getTimestamp(uint256 _roundId)
      public
      view
      virtual
      override
      returns (uint256)
    {
      if (validRoundId(_roundId)) {
        return rounds[uint32(_roundId)].updatedAt;
      }
      return 0;
    }

    /**
    * @notice get data about a round. Consumers are encouraged to check
    * that they're receiving fresh data by inspecting the updatedAt and
    * answeredInRound return values.
    * @param _roundId the round ID to retrieve the round data for
    * @return roundId is the round ID for which data was retrieved
    * @return answer is the answer for the given round
    * @return startedAt is the timestamp when the round was started. This is 0
    * if the round hasn't been started yet.
    * @return updatedAt is the timestamp when the round last was updated (i.e.
    * answer was last computed)
    * @return answeredInRound is the round ID of the round in which the answer
    * was computed. answeredInRound may be smaller than roundId when the round
    * timed out. answeredInRound is equal to roundId when the round didn't time out
    * and was completed regularly.
    * @dev Note that for in-progress rounds (i.e. rounds that haven't yet received
    * maxSubmissions) answer and updatedAt may change between queries.
    */
    function getRoundData(uint80 _roundId)
      public
      view
      virtual
      override
      returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
      )
    {
      Round memory r = rounds[uint32(_roundId)];

      require(r.answeredInRound > 0 && validRoundId(_roundId), V3_NO_DATA_ERROR);

      return (
        _roundId,
        r.answer,
        r.startedAt,
        r.updatedAt,
        r.answeredInRound
      );
    }

    /**
    * @notice get data about the latest round. Consumers are encouraged to check
    * that they're receiving fresh data by inspecting the updatedAt and
    * answeredInRound return values. Consumers are encouraged to
    * use this more fully featured method over the "legacy" latestRound/
    * latestAnswer/latestTimestamp functions. Consumers are encouraged to check
    * that they're receiving fresh data by inspecting the updatedAt and
    * answeredInRound return values.
    * @return roundId is the round ID for which data was retrieved
    * @return answer is the answer for the given round
    * @return startedAt is the timestamp when the round was started. This is 0
    * if the round hasn't been started yet.
    * @return updatedAt is the timestamp when the round last was updated (i.e.
    * answer was last computed)
    * @return answeredInRound is the round ID of the round in which the answer
    * was computed. answeredInRound may be smaller than roundId when the round
    * timed out. answeredInRound is equal to roundId when the round didn't time
    * out and was completed regularly.
    * @dev Note that for in-progress rounds (i.e. rounds that haven't yet
    * received maxSubmissions) answer and updatedAt may change between queries.
    */
    function latestRoundData()
      public
      view
      virtual
      override
      returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
    {
      return getRoundData(latestRoundId);
    }

    function updateRoundAnswer(uint32 _roundId, int256 _newAnswer)
      internal
    {
      rounds[_roundId].answer = _newAnswer;
      rounds[_roundId].updatedAt = uint64(block.timestamp);
      rounds[_roundId].answeredInRound = _roundId;
      latestRoundId = _roundId;

      emit AnswerUpdated(_newAnswer, _roundId, block.timestamp);
    }

    function validRoundId(uint256 _roundId)
      private
      pure
      returns (bool)
    {
      return _roundId <= ROUND_MAX;
    }
}


contract VinciCollectAggregator is CollectAggregator {
    /**
    * @notice set up the aggregator with initial configuration
    * @param _timeout is the number of seconds after the previous round that are
    * allowed to lapse before allowing an oracle to skip an unfinished round
    * @param _minSubmissionValue is an immutable check for a lower bound of what
    * submission values are accepted from an oracle
    * @param _maxSubmissionValue is an immutable check for an upper bound of what
    * submission values are accepted from an oracle
    * @param _decimals represents the number of decimals to offset the answer by
    * @param _description a short description of what is being reported
    */
    constructor(
      uint32 _timeout,
      int256 _minSubmissionValue,
      int256 _maxSubmissionValue,
      uint8 _decimals,
      string memory _description
    ) CollectAggregator(
      _timeout,
      _minSubmissionValue,
      _maxSubmissionValue,
      _decimals,
      _description
    ){}

    /**
    * @notice get data about a round. Consumers are encouraged to check
    * that they're receiving fresh data by inspecting the updatedAt and
    * answeredInRound return values.
    * @param _roundId the round ID to retrieve the round data for
    * @return roundId is the round ID for which data was retrieved
    * @return answer is the answer for the given round
    * @return startedAt is the timestamp when the round was started. This is 0
    * if the round hasn't been started yet.
    * @return updatedAt is the timestamp when the round last was updated (i.e.
    * answer was last computed)
    * @return answeredInRound is the round ID of the round in which the answer
    * was computed. answeredInRound may be smaller than roundId when the round
    * timed out. answerInRound is equal to roundId when the round didn't time out
    * and was completed regularly.
    * @dev overridden funcion to add the checkAccess() modifier
    * @dev Note that for in-progress rounds (i.e. rounds that haven't yet
    * received maxSubmissions) answer and updatedAt may change between queries.
    */
    function getRoundData(uint80 _roundId)
      public
      view
      override
      checkAccess()
      returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
      )
    {
      return super.getRoundData(_roundId);
    }

    /**
    * @notice get data about the latest round. Consumers are encouraged to check
    * that they're receiving fresh data by inspecting the updatedAt and
    * answeredInRound return values. Consumers are encouraged to
    * use this more fully featured method over the "legacy" latestAnswer
    * functions. Consumers are encouraged to check that they're receiving fresh
    * data by inspecting the updatedAt and answeredInRound return values.
    * @return roundId is the round ID for which data was retrieved
    * @return answer is the answer for the given round
    * @return startedAt is the timestamp when the round was started. This is 0
    * if the round hasn't been started yet.
    * @return updatedAt is the timestamp when the round last was updated (i.e.
    * answer was last computed)
    * @return answeredInRound is the round ID of the round in which the answer
    * was computed. answeredInRound may be smaller than roundId when the round
    * timed out. answerInRound is equal to roundId when the round didn't time out
    * and was completed regularly.
    * @dev overridden funcion to add the checkAccess() modifier
    * @dev Note that for in-progress rounds (i.e. rounds that haven't yet
    * received maxSubmissions) answer and updatedAt may change between queries.
    */
    function latestRoundData()
      public
      view
      override
      checkAccess()
      returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
      )
    {
      return super.latestRoundData();
    }

    /**
    * @notice get the most recently reported answer
    * @dev overridden funcion to add the checkAccess() modifier
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestAnswer()
      public
      view
      override
      checkAccess()
      returns (int256)
    {
      return super.latestAnswer();
    }

    /**
    * @notice get the most recently reported round ID
    * @dev overridden funcion to add the checkAccess() modifier
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestRound()
      public
      view
      override
      checkAccess()
      returns (uint256)
    {
      return super.latestRound();
    }

    /**
    * @notice get the most recent updated at timestamp
    * @dev overridden funcion to add the checkAccess() modifier
    *
    * @dev #[deprecated] Use latestRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended latestRoundData
    * instead which includes better verification information.
    */
    function latestTimestamp()
      public
      view
      override
      checkAccess()
      returns (uint256)
    {

      return super.latestTimestamp();
    }

    /**
    * @notice get past rounds answers
    * @dev overridden funcion to add the checkAccess() modifier
    * @param _roundId the round number to retrieve the answer for
    *
    * @dev #[deprecated] Use getRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended getRoundData
    * instead which includes better verification information.
    */
    function getAnswer(uint256 _roundId)
      public
      view
      override
      checkAccess()
      returns (int256)
    {
      return super.getAnswer(_roundId);
    }

    /**
    * @notice get timestamp when an answer was last updated
    * @dev overridden funcion to add the checkAccess() modifier
    * @param _roundId the round number to retrieve the updated timestamp for
    *
    * @dev #[deprecated] Use getRoundData instead. This does not error if no
    * answer has been reached, it will simply return 0. Either wait to point to
    * an already answered Aggregator or use the recommended getRoundData
    * instead which includes better verification information.
    */
    function getTimestamp(uint256 _roundId)
      public
      view
      override
      checkAccess()
      returns (uint256)
    {
      return super.getTimestamp(_roundId);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleWriteAccessController.sol";

/**
 * @title SimpleReadAccessController
 * @notice Gives access to:
 * - any externally owned account (note that off-chain actors can always read
 * any contract storage regardless of on-chain access control measures, so this
 * does not weaken the access control while improving usability)
 * - accounts explicitly added to an access list
 * @dev SimpleReadAccessController is not suitable for access controlling writes
 * since it grants any externally owned account access! See
 * SimpleWriteAccessController for that.
 */
contract SimpleReadAccessController is SimpleWriteAccessController {
  /**
   * @notice Returns the access of an address
   * @param _user The address to query
   */
  function hasAccess(address _user, bytes memory _calldata) public view virtual override returns (bool) {
    return super.hasAccess(_user, _calldata) || _user == tx.origin;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwner.sol";
import "./interfaces/AccessControllerInterface.sol";

/**
 * @title SimpleWriteAccessController
 * @notice Gives access to accounts explicitly added to an access list by the
 * controller's owner.
 * @dev does not make any special permissions for externally, see
 * SimpleReadAccessController for that.
 */
contract SimpleWriteAccessController is AccessControllerInterface, ConfirmedOwner {
  bool public checkEnabled;
  mapping(address => bool) internal accessList;

  event AddedAccess(address user);
  event RemovedAccess(address user);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  constructor() ConfirmedOwner(msg.sender) {
    checkEnabled = true;
  }

  /**
   * @notice Returns the access of an address
   * @param _user The address to query
   */
  function hasAccess(address _user, bytes memory) public view virtual override returns (bool) {
    return accessList[_user] || !checkEnabled;
  }

  /**
   * @notice Adds an address to the access list
   * @param _user The address to add
   */
  function addAccess(address _user) external onlyOwner {
    if (!accessList[_user]) {
      accessList[_user] = true;

      emit AddedAccess(_user);
    }
  }

  /**
   * @notice Removes an address from the access list
   * @param _user The address to remove
   */
  function removeAccess(address _user) external onlyOwner {
    if (accessList[_user]) {
      accessList[_user] = false;

      emit RemovedAccess(_user);
    }
  }

  /**
   * @notice makes the access check enforced
   */
  function enableAccessCheck() external onlyOwner {
    if (!checkEnabled) {
      checkEnabled = true;

      emit CheckAccessEnabled();
    }
  }

  /**
   * @notice makes the access check unenforced
   */
  function disableAccessCheck() external onlyOwner {
    if (checkEnabled) {
      checkEnabled = false;

      emit CheckAccessDisabled();
    }
  }

  /**
   * @dev reverts if the caller does not have access
   */
  modifier checkAccess() {
    require(hasAccess(msg.sender, msg.data), "No access");
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AccessControllerInterface {
  function hasAccess(address user, bytes calldata data) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}