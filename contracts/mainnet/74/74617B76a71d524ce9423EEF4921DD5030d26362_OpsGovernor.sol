/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

/*
    Copyright 2022 Translucent.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
*/


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File src/interfaces/base/helpers/IOpsGovernor.sol

pragma solidity ^0.8.12;

/**
 * @title IOpsGovernor
 * @author Translucent
 *
 * @notice Interface for managing and governing operations.
 * @notice Governance is solely based on managers that voted.
 *         Non-voting is abstained by default.
 */
interface IOpsGovernor {
    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireManagers(address caller) external view;
    function requireOperators(address caller) external view;
    function requireTokenRegistered(address tokenAddress) external view;
    function requireProtocolRegistered(address protocolAddress) external view;
    function requireUtilRegistered(address utilAddress) external view;

    /*********************************/
    /** Functions to read the states */
    /*********************************/
    function getManagers() external view returns (address[] memory);
    function getOperators() external view returns (address[] memory);
    function getNumRegisteredTokens() external view returns (uint256);
    function getNumRegisteredProtocols() external view returns (uint256);
    function getNumRegisteredUtils() external view returns (uint256);
    function getRegisteredTokens(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);
    function getRegisteredProtocols(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);
    function getRegisteredUtils(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);

    /***********************************/
    /** Functions to modify the states */
    /***********************************/
    function addManager(address managerAddress) external;
    function removeManager(address managerAddress) external;
    function addOperator(address operatorAddress) external;
    function removeOperator(address operatorAddress) external;
    function registerTokens(address[] memory tokensAddresses) external;
    function unregisterTokens(address[] memory tokensAddresses) external;
    function registerProtocols(address[] memory protocolsAddresses) external;
    function unregisterProtocols(address[] memory protocolsAddresses) external;
    function registerUtils(address[] memory utilsAddresses) external;
    function unregisterUtils(address[] memory utilsAddresses) external;

    /*******************************************************/
    /** Function to migrate to a new ops governor contract */
    /*******************************************************/
    function migrate(address newOpsGovernorAddress) external;

    /************************************************/
    /** Structs to facilitate governance and voting */
    /************************************************/
    enum Direction { FOR, AGAINST }
    enum Status { PENDING, REJECTED, APPROVED_AND_EXECUTED, APPROVED_BUT_FAILED }

    struct Proposal {
        address proposer;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        bytes callData;
        uint256 votesFor;
        uint256 votesAgainst;
        Status status;
        uint256 blockExecuted;
    }
    /**************************************************/
    /** Functions to facilitate governance and voting */
    /**************************************************/
    function createProposal(
        string memory description,
        uint256 duration,
        bytes calldata callData
    ) external returns (uint256);
    function vote(uint256 proposalId, Direction direction) external;
    function executeProposal(uint256 proposalId) external returns (Status);

    /********************************************/
    /** Functions to read the governance states */
    /********************************************/
    function getNumProposals() external view returns (uint256);
    function getActiveProposalsIds() external view returns (uint256[] memory);
    function getProposal(uint256 proposalId) external view returns (Proposal memory);
    function getIsProposalExecutable(uint256 proposalId) external view returns (bool);
}


// File src/interfaces/base/IBaseFund.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IBaseFund
 * @author Translucent
 *
 * @notice Interface for the base fund.
 */
interface IBaseFund {    
    /****************************************/
    /** Functions to set the fund's helpers */
    /****************************************/
    function setBaseFundHelpers(address opsGovernorAddress) external;

    /*********************************************/
    /** Structs to facilitate making transactions*/
    /*********************************************/
    enum CallType {
        TOKEN,
        PROTOCOL,
        UTIL
    }
    struct CallInput {
        CallType callType;
        address callAddress;
        bytes callData;
        uint256 value;
    }

    /***********************************/
    /** Functions to make transactions */
    /***********************************/
    function call(CallInput calldata callInput) external;
    function multiCall(CallInput[] calldata callInputs) external;
}


// File src/contracts/base/helpers/BaseFundHelper.sol

pragma solidity ^0.8.12;
/**
 * @title BaseFundHelper
 * @author Translucent
 *
 * @notice Base contract for helpers to inherit from,
 *         providing reference to the fund contract.
 */
abstract contract BaseFundHelper is Context {
    address private _fundAddress;

    /**
     * Sets the fund
     */
    constructor(address fundAddress) {
        _fundAddress = fundAddress;
    }

    /**
     * @dev Returns the address of the fund.
     */
    function getFundAddress() public view returns (address) {
        return _fundAddress;
    }

    /**
     * @dev Returns the address of the fund.
     */
    function getFund() public view returns (IBaseFund) {
        return IBaseFund(_fundAddress);
    }

    /**
     * @dev Throws if called by any account other than the fund.
     */
    modifier onlyFund() {
        require(_fundAddress == _msgSender(), "BaseFundHelper: caller is not the fund");
        _;
    }
}


// File src/contracts/base/helpers/OpsGovernor.sol

pragma solidity ^0.8.12;

// External Libraries
// Code
/**
 * @title OpsGovernor
 * @author Translucent
 *
 * @notice Contract for managing and simple governing operations.
 * @notice Voting is based on equal voting-rights of all managers,
 *         where a proposal can be executed if
 *         either the deadline is up or >50% of managers are in favour
 *         The success of the execution will then depend on if there
 *         are more votes FOR the proposal or more votes AGAINST it.
 */
contract OpsGovernor is BaseFundHelper, IOpsGovernor {
    /** Libraries */
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /** States */
    EnumerableSet.AddressSet private _managers;
    EnumerableSet.AddressSet private _operators;
    EnumerableSet.AddressSet private _tokens;
    EnumerableSet.AddressSet private _protocols;
    EnumerableSet.AddressSet private _utils;

    /** Governance states */
    Proposal[] private _proposals;
    EnumerableSet.UintSet private _activeProposalsIds;
    mapping(uint256 => EnumerableSet.AddressSet) private _voters;

    /** Governance events */
    event ProposalCreated(uint256 indexed proposalId, address proposer, string description);
    event Vote(uint256 indexed proposalId, address voter, Direction direction);
    event ProposalExecuted(uint256 indexed proposalId);

    /** Constructor */
    constructor(
        address fundAddress,
        address[] memory initialManagers,
        address[] memory initialOperators
    ) BaseFundHelper(fundAddress) {
        // Record the initial managers and operators
        for (uint i = 0; i < initialManagers.length; i++)
            _managers.add(initialManagers[i]);
        for (uint i = 0; i < initialOperators.length; i++)
            _operators.add(initialOperators[i]);
    }

    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireManagers(address caller) public view override {
        require(
            _managers.contains(caller),
            "OpsGovernor: caller is not a manager"
        );
    }
    function requireOperators(address caller) external view override {
        require(
            _operators.contains(caller),
            "OpsGovernor: caller is not an operator"
        );
    }
    function requireTokenRegistered(address tokenAddress) external view override {
        require(
            _tokens.contains(tokenAddress),
            "OpsGovernor: token is not registered"
        );
    }
    function requireProtocolRegistered(address protocolAddress) external view override {
        require(
            _protocols.contains(protocolAddress),
            "OpsGovernor: protocol is not registered"
        );
    }
    function requireUtilRegistered(address utilAddress) external view override {
        require(
            _utils.contains(utilAddress),
            "OpsGovernor: util is not registered"
        );
    }

    /*********************************/
    /** Functions to read the states */
    /*********************************/
    function getManagers() external view override returns (address[] memory) {
        return _managers.values();
    }
    function getOperators() external view override returns (address[] memory) {
        return _operators.values();
    }
    function getNumRegisteredTokens() external view override returns (uint256) {
        return _tokens.length();
    }
    function getNumRegisteredProtocols() external view override returns (uint256) {
        return _protocols.length();
    }
    function getNumRegisteredUtils() external view override returns (uint256) {
        return _utils.length();
    }
    // TODO: Batch these getters since we might have alot of entries
    function getRegisteredTokens(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory) {
        address[] memory tokensAddresses = _tokens.values();
        return _batchAddresses(tokensAddresses, offset, limit);
    }
    function getRegisteredProtocols(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory) {
        address[] memory protocolsAddresses = _protocols.values();
        return _batchAddresses(protocolsAddresses, offset, limit);
    }
    function getRegisteredUtils(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory) {
        address[] memory utilsAddresses = _utils.values();
        return _batchAddresses(utilsAddresses, offset, limit);
    }
    function _batchAddresses(
        address[] memory addresses,
        uint256 offset,
        uint256 limit
    ) internal pure returns (address[] memory) {
        uint256 numOutput = _min(addresses.length - offset, limit);
        address[] memory output = new address[](numOutput);
        for (uint256 i = 0; i < numOutput; i++) {
            output[i] = addresses[offset + i];
        }
        return output;
    }
    function _min(uint256 val1, uint256 val2) internal pure returns (uint256) {
        return val1 < val2 ? val1 : val2;
    }

    /***********************************/
    /** Functions to modify the states */
    /***********************************/
    modifier onlyGovernance() {
        require(
            _msgSender() == address(this),
            "OpsGovernor: can only be called through governance process"
        );
        _;
    }
    function addManager(address managerAddress) external onlyGovernance override {
        _managers.add(managerAddress);
    }
    function removeManager(address managerAddress) external onlyGovernance override {
        require(_managers.length() > 1, "Ops Governor: Cannot remove the last manager");
        _managers.remove(managerAddress);
    }
    function addOperator(address operatorAddress) external onlyGovernance override {
        _operators.add(operatorAddress);
    }
    function removeOperator(address operatorAddress) external override {
        requireManagers(_msgSender());
        _operators.remove(operatorAddress);
    }
    function registerTokens(address[] calldata addresses) external onlyGovernance override {
        for (uint i = 0; i < addresses.length; i++)
            _tokens.add(addresses[i]);
    }
    function unregisterTokens(address[] calldata addresses) external override {
        requireManagers(_msgSender());
        for (uint i = 0; i < addresses.length; i++)
            _tokens.remove(addresses[i]);
    }
    function registerProtocols(address[] calldata addresses) external onlyGovernance override {
        for (uint i = 0; i < addresses.length; i++)
            _protocols.add(addresses[i]);
    }
    function unregisterProtocols(address[] calldata addresses) external override {
        requireManagers(_msgSender());
        for (uint i = 0; i < addresses.length; i++)
            _protocols.remove(addresses[i]);
    }
    function registerUtils(address[] calldata addresses) external onlyGovernance override {
        for (uint i = 0; i < addresses.length; i++)
            _utils.add(addresses[i]);
    }
    function unregisterUtils(address[] calldata addresses) external override {
        requireManagers(_msgSender());
        for (uint i = 0; i < addresses.length; i++)
            _utils.remove(addresses[i]);
    }

    /*******************************************************/
    /** Function to migrate to a new ops governor contract */
    /*******************************************************/
    function migrate(address newOpsGovernorAddress) external onlyGovernance {
        getFund().setBaseFundHelpers(newOpsGovernorAddress);
    }

    /**************************************************/
    /** Functions to facilitate governance and voting */
    /**************************************************/
    /**
     * Function for managers to create a proposal.
     *
     * @param description - Description about what the proposal is for/about.
     * @param duration - How long the voting should last.
     * @param callData - The calldata to be executed upon approval.
     * @return - The id of proposal for voting/execution. 
     */
    function createProposal(
        string memory description,
        uint256 duration,
        bytes calldata callData
    ) external override returns (uint256) {
        // Only managers can create proposals
        requireManagers(_msgSender());
        
        // Get the proposal ID as the index of the array
        uint256 proposalId = _proposals.length;

        // Track this as an active proposal
        _activeProposalsIds.add(proposalId);

        // Create the proposal struct
        _proposals.push(
            Proposal({
                proposer: _msgSender(),
                description: description,
                startBlock: block.number,
                endBlock: block.number + duration,
                callData: callData,
                votesFor: 1, // Proposer is by default in favour
                votesAgainst: 0,
                status: Status.PENDING,
                blockExecuted: 0
            })
        );

        // Record the proposer as having voted
        _voters[proposalId].add(_msgSender());

        // Emit the event of a proposal being created
        emit ProposalCreated(proposalId, _msgSender(), description);

        // Emit the event of the proposer voting FOR
        emit Vote(proposalId, _msgSender(), Direction.FOR);

        return proposalId;
    }

    /**
     * Function for managers to cast their votes on a proposal.
     *
     * @param proposalId - The id of the proposal to vote on.
     * @param direction - The vote direction of FOR or AGAINST.
     */
    function vote(uint256 proposalId, Direction direction) external override {
        // Only managers can vote
        requireManagers(_msgSender());

        // Require that voting is still active
        require(
            _proposals[proposalId].endBlock >= block.number,
            "OpsGovernor: voting for the proposal has ended"
        );

        // Require that the voter has not voted
        require(
            !_voters[proposalId].contains(_msgSender()),
            "OpsGovernor: caller has already voted"
        );

        // Record the vote
        if (direction == Direction.FOR)
            _proposals[proposalId].votesFor++;
        else
            _proposals[proposalId].votesAgainst++;

        _voters[proposalId].add(_msgSender());

        // Emit the event of the vote
        emit Vote(proposalId, _msgSender(), direction);
    }

    /**
     * Function for managers to execute the proposal's stored calldata upon approval.
     *
     * @param proposalId - The id of the proposal to execute.
     * @return - The status of the proposal, rejected/failed/succeeded.
     */
    function executeProposal(uint256 proposalId) external override returns (Status) {
        // Only managers can execute proposals
        requireManagers(_msgSender());

        // Retrieve proposal into memory
        Proposal memory proposal = _proposals[proposalId];

        // Require that proposal is executable (still pending)
        require(
            proposal.status == Status.PENDING,
            "OpsGovernor: proposal is not pending execution"
        );

        // Require that the proposal is executable (still pending)
        // Require either the deadline is up or more than half have voted in favour
        uint256 numManagers = _managers.length();
        uint256 minVotes = numManagers / 2 + (numManagers % 2 == 0 ? 0 : 1);
        require(
            block.number > proposal.endBlock
            || proposal.votesFor >= minVotes,
            "OpsGovernor: voting is still in progress"
        );

        // Reject if more than or equal AGAINST votes vs FOR votes
        if (proposal.votesFor <= proposal.votesAgainst) {
            _activeProposalsIds.remove(proposalId);
            _proposals[proposalId].status = Status.REJECTED;

            emit ProposalExecuted(proposalId);
            return Status.REJECTED;
        }

        // Perform the call
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = address(this).call(proposal.callData);

        // Update the status and return it
        if (success) {
            _activeProposalsIds.remove(proposalId);
            _proposals[proposalId].status = Status.APPROVED_AND_EXECUTED;

            emit ProposalExecuted(proposalId);
            return Status.APPROVED_AND_EXECUTED;
        }

        _activeProposalsIds.remove(proposalId);
        _proposals[proposalId].status = Status.APPROVED_BUT_FAILED;

        emit ProposalExecuted(proposalId);
        return Status.APPROVED_BUT_FAILED;
    }

    /**
     * Function to retrieve the total number of proposals in the array.
     *
     * @return - The number of proposals in the array.
     */
    function getNumProposals() external view override returns (uint256) {
        return _proposals.length;
    }

    /**
     * Function to show the proposals that are active for voting.
     *
     * @return proposalIds - The ids of the active proposals.
     */
    function getActiveProposalsIds() external view override returns (uint256[] memory) {
        return _activeProposalsIds.values();
    }

    /**
     * Function to retrieve a proposal based on the input id.
     *
     * @param proposalId - The id of the proposal to fetch.
     * @return - The proposal struct.
     */
    function getProposal(uint256 proposalId) external view override returns (Proposal memory) {
        return _proposals[proposalId];
    }

    /**
     * Function to check whether a proposal is executable now.
     *
     * @param proposalId - The id of the proposal to check.
     * @return - Whether the proposal is executable now.
     */
    function getIsProposalExecutable(
        uint256 proposalId
    ) external override view returns (bool) {
        Proposal memory proposal = _proposals[proposalId];

        // Require that the proposal is executable (still pending)
        // Require either the deadline is up or at least half have voted in favour
        uint256 numManagers = _managers.length();
        uint256 minVotes = numManagers / 2 + (numManagers % 2 == 0 ? 0 : 1);
        return proposal.status == Status.PENDING
            && (
                block.number > proposal.endBlock
                || proposal.votesFor >= minVotes
                || proposal.votesAgainst >= minVotes
            );
    }
}