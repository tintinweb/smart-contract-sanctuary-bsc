// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.8.17;

import "./mixins/MixinInitializer.sol";
import "./mixins/MixinState.sol";
import "./mixins/MixinStorage.sol";
import "./mixins/MixinUpgrade.sol";
import "./mixins/MixinVoting.sol";
import "./IRigoblockGovernance.sol";

contract RigoblockGovernance is
    IRigoblockGovernance,
    MixinStorage,
    MixinInitializer,
    MixinUpgrade,
    MixinVoting,
    MixinState
{
    /// @notice Constructor has no inputs to guarantee same deterministic address across chains.
    /// @dev Setting high proposal threshold locks propose action, which also lock vote actions.
    constructor() MixinImmutables() MixinStorage() {
        _paramsWrapper().governanceParameters = GovernanceParameters({
            strategy: address(0),
            proposalThreshold: type(uint256).max,
            quorumThreshold: 0,
            timeType: TimeType.Timestamp
        });
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IGovernanceStrategy.sol";
import "../interfaces/IRigoblockGovernanceFactory.sol";
import "./MixinStorage.sol";

abstract contract MixinInitializer is MixinStorage {
    modifier onlyUninitialized() {
        // proxy is always initialized in the constructor, therefore
        // empty extcodesize means the governance has not been initialized
        require(address(this).code.length == 0, "ALREADY_INITIALIZED_ERROR");
        _;
    }

    /// @inheritdoc IGovernanceInitializer
    function initializeGovernance() external override onlyUninitialized {
        IRigoblockGovernanceFactory.Parameters memory params = IRigoblockGovernanceFactory(msg.sender).parameters();
        IGovernanceStrategy(params.governanceStrategy).assertValidInitParams(params);
        _name().value = params.name;
        _paramsWrapper().governanceParameters = GovernanceParameters({
            strategy: params.governanceStrategy,
            proposalThreshold: params.proposalThreshold,
            quorumThreshold: params.quorumThreshold,
            timeType: params.timeType
        });
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./MixinAbstract.sol";
import "./MixinStorage.sol";
import "../interfaces/IGovernanceStrategy.sol";

abstract contract MixinState is MixinStorage, MixinAbstract {
    /// @inheritdoc IGovernanceState
    function getActions(uint256 proposalId) external view override returns (ProposedAction[] memory proposedActions) {
        Proposal memory proposal = _proposal().proposalById[proposalId];
        uint256 actionsLength = proposal.actionsLength;
        proposedActions = new ProposedAction[](actionsLength);
        for (uint256 i = 0; i < actionsLength; i++) {
            proposedActions[i] = _proposedAction().proposedActionbyIndex[proposalId][i];
        }
    }

    /// @inheritdoc IGovernanceState
    function getProposalState(uint256 proposalId) external view override returns (ProposalState) {
        return _getProposalState(proposalId);
    }

    /// @inheritdoc IGovernanceState
    function getReceipt(uint256 proposalId, address voter) external view override returns (Receipt memory) {
        return _receipt().userReceiptByProposal[proposalId][voter];
    }

    /// @inheritdoc IGovernanceState
    function getVotingPower(address account) external view override returns (uint256) {
        return _getVotingPower(account);
    }

    /// @inheritdoc IGovernanceState
    function governanceParameters() external view override returns (EnhancedParams memory) {
        return EnhancedParams({params: _paramsWrapper().governanceParameters, name: _name().value, version: VERSION});
    }

    /// @inheritdoc IGovernanceState
    function name() external view override returns (string memory) {
        return _name().value;
    }

    /// @inheritdoc IGovernanceState
    function proposalCount() external view override returns (uint256 count) {
        return _getProposalCount();
    }

    /// @inheritdoc IGovernanceState
    function proposals() external view override returns (ProposalWrapper[] memory proposalWrapper) {
        uint256 length = _getProposalCount();
        proposalWrapper = new ProposalWrapper[](length);
        for (uint256 i = 0; i < length; i++) {
            // proposal count starts at proposalId = 1
            proposalWrapper[i] = getProposalById(i + 1);
        }
    }

    /// @inheritdoc IGovernanceState
    function votingPeriod() external view override returns (uint256) {
        return IGovernanceStrategy(_governanceParameters().strategy).votingPeriod();
    }

    /// @inheritdoc IGovernanceState
    function getProposalById(uint256 proposalId) public view override returns (ProposalWrapper memory proposalWrapper) {
        proposalWrapper.proposal = _proposal().proposalById[proposalId];
        uint256 actionsLength = proposalWrapper.proposal.actionsLength;
        ProposedAction[] memory proposedAction = new ProposedAction[](actionsLength);
        for (uint256 i = 0; i < actionsLength; i++) {
            proposedAction[i] = _proposedAction().proposedActionbyIndex[proposalId][i];
        }
        proposalWrapper.proposedAction = proposedAction;
    }

    function _getProposalCount() internal view override returns (uint256 count) {
        return _proposalCount().value;
    }

    function _getProposalState(uint256 proposalId) internal view override returns (ProposalState) {
        require(_proposalCount().value >= proposalId && proposalId > 0, "VOTING_PROPOSAL_ID_ERROR");
        Proposal memory proposal = _proposal().proposalById[proposalId];
        return
            IGovernanceStrategy(_governanceParameters().strategy).getProposalState(
                proposal,
                _governanceParameters().quorumThreshold
            );
    }

    function _getVotingPower(address account) internal view override returns (uint256) {
        return IGovernanceStrategy(_governanceParameters().strategy).getVotingPower(account);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./MixinImmutables.sol";

abstract contract MixinStorage is MixinImmutables {
    // we use the constructor to assert that we are not using occupied storage slots
    constructor() {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        assert(_GOVERNANCE_PARAMS_SLOT == bytes32(uint256(keccak256("governance.proxy.governanceparams")) - 1));
        assert(_NAME_SLOT == bytes32(uint256(keccak256("governance.proxy.name")) - 1));
        assert(_RECEIPT_SLOT == bytes32(uint256(keccak256("governance.proxy.user.receipt")) - 1));
        assert(_PROPOSAL_SLOT == bytes32(uint256(keccak256("governance.proxy.proposal")) - 1));
        assert(_PROPOSAL_COUNT_SLOT == bytes32(uint256(keccak256("governance.proxy.proposalcount")) - 1));
        assert(_PROPOSED_ACTION_SLOT == bytes32(uint256(keccak256("governance.proxy.proposedaction")) - 1));
    }

    function _governanceParameters() internal pure returns (GovernanceParameters storage s) {
        assembly {
            s.slot := _GOVERNANCE_PARAMS_SLOT
        }
    }

    struct AddressSlot {
        address value;
    }

    function _implementation() internal pure returns (AddressSlot storage s) {
        assembly {
            s.slot := _IMPLEMENTATION_SLOT
        }
    }

    struct StringSlot {
        string value;
    }

    function _name() internal pure returns (StringSlot storage s) {
        assembly {
            s.slot := _NAME_SLOT
        }
    }

    struct ParamsWrapper {
        GovernanceParameters governanceParameters;
    }

    function _paramsWrapper() internal pure returns (ParamsWrapper storage s) {
        assembly {
            s.slot := _GOVERNANCE_PARAMS_SLOT
        }
    }

    struct UintSlot {
        uint256 value;
    }

    function _proposalCount() internal pure returns (UintSlot storage s) {
        assembly {
            s.slot := _PROPOSAL_COUNT_SLOT
        }
    }

    struct ProposalByIndex {
        mapping(uint256 => Proposal) proposalById;
    }

    function _proposal() internal pure returns (ProposalByIndex storage s) {
        assembly {
            s.slot := _PROPOSAL_SLOT
        }
    }

    struct ActionByIndex {
        mapping(uint256 => mapping(uint256 => ProposedAction)) proposedActionbyIndex;
    }

    function _proposedAction() internal pure returns (ActionByIndex storage s) {
        assembly {
            s.slot := _PROPOSED_ACTION_SLOT
        }
    }

    struct UserReceipt {
        mapping(uint256 => mapping(address => Receipt)) userReceiptByProposal;
    }

    function _receipt() internal pure returns (UserReceipt storage s) {
        assembly {
            s.slot := _RECEIPT_SLOT
        }
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IGovernanceStrategy.sol";
import "./MixinStorage.sol"; // storage inherits from interface which declares events

abstract contract MixinUpgrade is MixinStorage {
    // upgrades must go through voting, i.e. execute method, which cannot be invoked directly in the implementation
    modifier onlyGovernance() {
        require(msg.sender == address(this), "GOV_UPGRADE_APPROVAL_ERROR");
        _;
    }

    /// @inheritdoc IGovernanceUpgrade
    function updateThresholds(uint256 newProposalThreshold, uint256 newQuorumThreshold)
        external
        override
        onlyGovernance
    {
        GovernanceParameters storage params = _governanceParameters();
        require(
            newProposalThreshold != params.proposalThreshold && newQuorumThreshold != params.quorumThreshold,
            "UPGRADE_SAME_AS_CURRENT_ERROR"
        );
        IGovernanceStrategy(params.strategy).assertValidThresholds(newProposalThreshold, newQuorumThreshold);
        params.proposalThreshold = newProposalThreshold;
        params.quorumThreshold = newQuorumThreshold;
        emit ThresholdsUpdated(newProposalThreshold, newQuorumThreshold);
    }

    /// @inheritdoc IGovernanceUpgrade
    function upgradeImplementation(address newImplementation) external override onlyGovernance {
        // we read the current implementation address from the governance proxy storage
        address currentImplementation = _implementation().value;

        // transaction reverted if implementation is same as current
        require(newImplementation != currentImplementation, "UPGRADE_SAME_AS_CURRENT_ERROR");

        // prevent accidental setting implementation to EOA
        require(_isContract(newImplementation), "UPGRADE_NOT_CONTRACT_ERROR");

        // we write new address to storage at implementation slot location and emit eip1967 log
        _implementation().value = newImplementation;
        emit Upgraded(newImplementation);
    }

    /// @inheritdoc IGovernanceUpgrade
    function upgradeStrategy(address newStrategy) external override onlyGovernance {
        address oldStrategy = _governanceParameters().strategy;
        require(newStrategy != oldStrategy, "UPGRADE_SAME_AS_CURRENT_ERROR");
        require(_isContract(newStrategy), "UPGRADE_NOT_CONTRACT_ERROR");

        // we write the new address in the strategy storage slot
        _governanceParameters().strategy = newStrategy;
        emit StrategyUpgraded(newStrategy);
    }

    /// @dev Returns whether an address is a contract.
    /// @return Bool target address has code.
    function _isContract(address target) private view returns (bool) {
        return target.code.length > 0;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./MixinAbstract.sol";
import "./MixinStorage.sol";
import "../interfaces/IGovernanceStrategy.sol";

abstract contract MixinVoting is MixinStorage, MixinAbstract {
    /// @inheritdoc IGovernanceVoting
    function propose(ProposedAction[] memory actions, string memory description)
        external
        override
        returns (uint256 proposalId)
    {
        uint256 length = actions.length;
        require(_getVotingPower(msg.sender) >= _governanceParameters().proposalThreshold, "GOV_LOW_VOTING_POWER");
        require(length > 0, "GOV_NO_ACTIONS_ERROR");
        require(length <= PROPOSAL_MAX_OPERATIONS, "GOV_TOO_MANY_ACTIONS_ERROR");
        (uint256 startBlockOrTime, uint256 endBlockOrTime) = IGovernanceStrategy(_governanceParameters().strategy)
            .votingTimestamps();

        // proposals start from id = 1
        _proposalCount().value++;
        proposalId = _getProposalCount();
        Proposal memory newProposal = Proposal({
            actionsLength: length,
            startBlockOrTime: startBlockOrTime,
            endBlockOrTime: endBlockOrTime,
            votesFor: 0,
            votesAgainst: 0,
            votesAbstain: 0,
            executed: false
        });

        for (uint256 i = 0; i < length; i++) {
            _proposedAction().proposedActionbyIndex[proposalId][i] = actions[i];
        }

        _proposal().proposalById[proposalId] = newProposal;

        emit ProposalCreated(msg.sender, proposalId, actions, startBlockOrTime, endBlockOrTime, description);
    }

    /// @inheritdoc IGovernanceVoting
    function castVote(uint256 proposalId, VoteType voteType) external override {
        _castVote(msg.sender, proposalId, voteType);
    }

    /// @inheritdoc IGovernanceVoting
    function castVoteBySignature(
        uint256 proposalId,
        VoteType voteType,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name().value)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );
        bytes32 structHash = keccak256(abi.encode(VOTE_TYPEHASH, proposalId, voteType));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        // following assertion is always bypassed by producing a valid EIP712 signature on diff. domain, therefore we do not return an error
        assert(
            signatory != address(0) && uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        );
        _castVote(signatory, proposalId, voteType);
    }

    /// @inheritdoc IGovernanceVoting
    function execute(uint256 proposalId) external payable override {
        require(_getProposalState(proposalId) == ProposalState.Succeeded, "VOTING_EXECUTION_STATE_ERROR");
        Proposal storage proposal = _proposal().proposalById[proposalId];
        proposal.executed = true;

        for (uint256 i = 0; i < proposal.actionsLength; i++) {
            ProposedAction memory action = _proposedAction().proposedActionbyIndex[proposalId][i];
            address target = action.target;
            uint256 value = action.value;
            bytes memory data = action.data;

            // we revert with error returned from the target
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let didSucceed := call(gas(), target, value, add(data, 0x20), mload(data), 0, 0)
                returndatacopy(0, 0, returndatasize())
                if eq(didSucceed, 0) {
                    revert(0, returndatasize())
                }
            }
        }

        emit ProposalExecuted(proposalId);
    }

    /// @notice Casts a vote for the given proposal.
    /// @dev Only callable during the voting period for that proposal.
    function _castVote(
        address voter,
        uint256 proposalId,
        VoteType voteType
    ) private {
        require(_getProposalState(proposalId) == ProposalState.Active, "VOTING_CLOSED_ERROR");
        Receipt memory receipt = _receipt().userReceiptByProposal[proposalId][voter];
        require(!receipt.hasVoted, "VOTING_ALREADY_VOTED_ERROR");
        uint256 votingPower = _getVotingPower(voter);
        require(votingPower != 0, "VOTING_NO_VOTES_ERROR");
        Proposal storage proposal = _proposal().proposalById[proposalId];

        if (voteType == VoteType.For) {
            proposal.votesFor += votingPower;
        } else if (voteType == VoteType.Against) {
            proposal.votesAgainst += votingPower;
        } else {
            proposal.votesAbstain += votingPower;
        }

        _receipt().userReceiptByProposal[proposalId][voter] = Receipt({
            hasVoted: true,
            votes: uint96(votingPower),
            voteType: voteType
        });

        // if vote reaches qualified majority we prepare execution at next block
        if (_getProposalState(proposalId) == ProposalState.Qualified) {
            proposal.endBlockOrTime = _paramsWrapper().governanceParameters.timeType == TimeType.Timestamp
                ? block.timestamp
                : block.number;
        }

        emit VoteCast(voter, proposalId, voteType, votingPower);
    }
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/governance/IGovernanceEvents.sol";
import "./interfaces/governance/IGovernanceInitializer.sol";
import "./interfaces/governance/IGovernanceState.sol";
import "./interfaces/governance/IGovernanceUpgrade.sol";
import "./interfaces/governance/IGovernanceVoting.sol";

interface IRigoblockGovernance is
    IGovernanceEvents,
    IGovernanceInitializer,
    IGovernanceUpgrade,
    IGovernanceVoting,
    IGovernanceState
{}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../IRigoblockGovernance.sol";
import "./IRigoblockGovernanceFactory.sol";

interface IGovernanceStrategy {
    /// @notice Reverts if initialization paramters are incorrect.
    /// @dev Only used at initialization, as params deleted from factory storage after setup.
    /// @param params Tuple of factory parameters.
    function assertValidInitParams(IRigoblockGovernanceFactory.Parameters calldata params) external view;

    /// @notice Reverts if thresholds are incorrect.
    /// @param proposalThreshold Number of votes required to make a proposal.
    /// @param quorumThreshold Number of votes required for a proposal to succeed.
    function assertValidThresholds(uint256 proposalThreshold, uint256 quorumThreshold) external view;

    /// @notice Returns the state of a proposal for a required quorum.
    /// @param proposal Tuple of the proposal.
    /// @param minimumQuorum Number of votes required for a proposal to pass.
    /// @return Tuple of the proposal state.
    function getProposalState(IRigoblockGovernance.Proposal calldata proposal, uint256 minimumQuorum)
        external
        view
        returns (IRigoblockGovernance.ProposalState);

    /// @notice Return the voting period.
    /// @return Number of seconds of period duration.
    function votingPeriod() external view returns (uint256);

    /// @notice Returns the voting timestamps.
    /// @return startBlockOrTime Timestamp when proposal starts.
    /// @return endBlockOrTime Timestamp when voting ends.
    function votingTimestamps() external view returns (uint256 startBlockOrTime, uint256 endBlockOrTime);

    /// @notice Return a user's voting power.
    /// @param account Address to check votes for.
    function getVotingPower(address account) external view returns (uint256);
}

// SPDX-License-Identifier: Apache-2.0-or-later
/*

 Copyright 2017-2022 RigoBlock, Rigo Investment Sagl, Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../IRigoblockGovernance.sol";

// solhint-disable-next-line
interface IRigoblockGovernanceFactory {
    /// @notice Emitted when a governance is created.
    /// @param governance Address of the governance proxy.
    event GovernanceCreated(address governance);

    /// @notice Creates a new governance proxy.
    /// @param implementation Address of the governance implementation contract.
    /// @param governanceStrategy Address of the voting strategy.
    /// @param proposalThreshold Number of votes required for creating a new proposal.
    /// @param quorumThreshold Number of votes required for execution.
    /// @param timeType Enum of time type (block number or timestamp).
    /// @param name Human readable string of the name.
    /// @return governance Address of the new governance.
    function createGovernance(
        address implementation,
        address governanceStrategy,
        uint256 proposalThreshold,
        uint256 quorumThreshold,
        IRigoblockGovernance.TimeType timeType,
        string calldata name
    ) external returns (address governance);

    struct Parameters {
        /// @notice Address of the governance implementation contract.
        address implementation;
        /// @notice Address of the voting strategy.
        address governanceStrategy;
        /// @notice Number of votes required for creating a new proposal.
        uint256 proposalThreshold;
        /// @notice Number of votes required for execution.
        uint256 quorumThreshold;
        /// @notice Type of time chosed, block number of timestamp.
        IRigoblockGovernance.TimeType timeType;
        /// @notice String of the name of the application.
        string name;
    }

    /// @notice Returns the governance initialization parameters at proxy deploy.
    /// @return Tuple of the governance parameters.
    function parameters() external view returns (Parameters memory);
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./IGovernanceVoting.sol";

interface IGovernanceEvents {
    /// @notice Emitted when a new proposal is created.
    /// @param proposer Address of the proposer.
    /// @param proposalId Number of the proposal.
    /// @param actions Struct array of actions (targets, datas, values).
    /// @param startBlockOrTime Timestamp in seconds after which proposal can be voted on.
    /// @param endBlockOrTime Timestamp in seconds after which proposal can be executed.
    /// @param description String description of proposal.
    event ProposalCreated(
        address proposer,
        uint256 proposalId,
        IGovernanceVoting.ProposedAction[] actions,
        uint256 startBlockOrTime,
        uint256 endBlockOrTime,
        string description
    );

    /// @notice Emitted when a proposal is executed.
    /// @param proposalId Number of the proposal.
    event ProposalExecuted(uint256 proposalId);

    /// @notice Emmited when the governance strategy is upgraded.
    /// @param newStrategy Address of the new strategy contract.
    event StrategyUpgraded(address newStrategy);

    /// @notice Emitted when voting thresholds get updated.
    /// @dev Only governance can update thresholds.
    /// @param proposalThreshold Number of votes required to add a proposal.
    /// @param quorumThreshold Number of votes required to execute a proposal.
    event ThresholdsUpdated(uint256 proposalThreshold, uint256 quorumThreshold);

    /// @notice Emitted when implementation written to proxy storage.
    /// @dev Emitted also at first variable initialization.
    /// @param newImplementation Address of the new implementation.
    event Upgraded(address indexed newImplementation);

    /// @notice Emitted when a voter votes.
    /// @param voter Address of the voter.
    /// @param proposalId Number of the proposal.
    /// @param voteType Number of vote type.
    /// @param votingPower Number of votes.
    event VoteCast(address voter, uint256 proposalId, IGovernanceVoting.VoteType voteType, uint256 votingPower);
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IGovernanceInitializer {
    /// @notice Initializes the Rigoblock Governance.
    /// @dev Params are stored in factory and read from there.
    function initializeGovernance() external;
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./IGovernanceVoting.sol";

interface IGovernanceState {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Qualified,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    enum TimeType {
        Blocknumber,
        Timestamp
    }

    struct Proposal {
        uint256 actionsLength;
        uint256 startBlockOrTime;
        uint256 endBlockOrTime;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        bool executed;
    }

    struct ProposalWrapper {
        Proposal proposal;
        IGovernanceVoting.ProposedAction[] proposedAction;
    }

    /// @notice Returns the actions proposed for a given proposal.
    /// @param proposalId Number of the proposal.
    /// @return proposedActions Array of tuple of proposed actions.
    function getActions(uint256 proposalId)
        external
        view
        returns (IGovernanceVoting.ProposedAction[] memory proposedActions);

    /// @notice Returns a proposal for a given id.
    /// @param proposalId The number of the proposal.
    /// @return proposalWrapper Tuple wrapper of the proposal and proposed actions tuples.
    function getProposalById(uint256 proposalId) external view returns (ProposalWrapper memory proposalWrapper);

    /// @notice Returns the state of a proposal.
    /// @param proposalId Number of the proposal.
    /// @return Number of proposal state.
    function getProposalState(uint256 proposalId) external view returns (ProposalState);

    struct Receipt {
        bool hasVoted;
        uint96 votes;
        IGovernanceVoting.VoteType voteType;
    }

    /// @notice Returns the receipt of a voter for a given proposal.
    /// @param proposalId Number of the proposal.
    /// @param voter Address of the voter.
    /// @return Tuple of voter receipt.
    function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);

    /// @notice Computes the current voting power of the given account.
    /// @param account The address of the account.
    /// @return votingPower The current voting power of the given account.
    function getVotingPower(address account) external view returns (uint256 votingPower);

    struct GovernanceParameters {
        address strategy;
        uint256 proposalThreshold;
        uint256 quorumThreshold;
        TimeType timeType;
    }

    struct EnhancedParams {
        GovernanceParameters params;
        string name;
        string version;
    }

    /// @notice Returns the governance parameters.
    /// @return Tuple of the governance parameters.
    function governanceParameters() external view returns (EnhancedParams memory);

    /// @notice Returns the name of the governace.
    /// @return Human readable string of the name.
    function name() external view returns (string memory);

    /// @notice Returns the total number of proposals.
    /// @return count The number of proposals.
    function proposalCount() external view returns (uint256 count);

    /// @notice Returns all proposals ever made to the governance.
    /// @return proposalWrapper Tuple array of all governance proposals.
    function proposals() external view returns (ProposalWrapper[] memory proposalWrapper);

    /// @notice Returns the voting period.
    /// @return Number of blocks or seconds.
    function votingPeriod() external view returns (uint256);
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IGovernanceUpgrade {
    /// @notice Updates the proposal and quorum thresholds to the given values.
    /// @dev Only callable by the governance contract itself.
    /// @dev Thresholds can only be updated via a successful governance proposal.
    /// @param newProposalThreshold The new value for the proposal threshold.
    /// @param newQuorumThreshold The new value for the quorum threshold.
    function updateThresholds(uint256 newProposalThreshold, uint256 newQuorumThreshold) external;

    /// @notice Updates the governance implementation address.
    /// @dev Only callable after successful voting.
    /// @param newImplementation Address of the new governance implementation contract.
    function upgradeImplementation(address newImplementation) external;

    /// @notice Updates the governance strategy plugin.
    /// @dev Only callable by the governance contract itself.
    /// @param newStrategy Address of the new strategy contract.
    function upgradeStrategy(address newStrategy) external;
}

// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2023 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./IGovernanceEvents.sol";

interface IGovernanceVoting {
    enum VoteType {
        For,
        Against,
        Abstain
    }

    /// @notice Casts a vote for the given proposal.
    /// @dev Only callable during the voting period for that proposal. One address can only vote once.
    /// @param proposalId The ID of the proposal to vote on.
    /// @param voteType Whether to support, not support or abstain.
    function castVote(uint256 proposalId, VoteType voteType) external;

    /// @notice Casts a vote for the given proposal, by signature.
    /// @dev Only callable during the voting period for that proposal. One voter can only vote once.
    /// @param proposalId The ID of the proposal to vote on.
    /// @param voteType Whether to support, not support or abstain.
    /// @param v the v field of the signature.
    /// @param r the r field of the signature.
    /// @param s the s field of the signature.
    function castVoteBySignature(
        uint256 proposalId,
        VoteType voteType,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// @notice Executes a proposal that has passed and is currently executable.
    /// @param proposalId The ID of the proposal to execute.
    function execute(uint256 proposalId) external payable;

    struct ProposedAction {
        address target;
        bytes data;
        uint256 value;
    }

    /// @notice Creates a proposal on the the given actions. Must have at least `proposalThreshold`.
    /// @dev Must have at least `proposalThreshold` of voting power to call this function.
    /// @param actions The proposed actions. An action specifies a contract call.
    /// @param description A text description for the proposal.
    /// @return proposalId The ID of the newly created proposal.
    function propose(ProposedAction[] calldata actions, string calldata description)
        external
        returns (uint256 proposalId);
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./MixinConstants.sol";

/// @notice Immutables are copied in the bytecode and not assigned a storage slot
/// @dev New immutables can safely be added to this contract without ordering.
abstract contract MixinImmutables is MixinConstants {
    constructor() {}
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../IRigoblockGovernance.sol";

/// @notice Constants are copied in the bytecode and not assigned a storage slot, can safely be added to this contract.
abstract contract MixinConstants is IRigoblockGovernance {
    /// @notice Contract version
    string internal constant VERSION = "1.0.0";

    /// @notice Maximum operations per proposal
    uint256 internal constant PROPOSAL_MAX_OPERATIONS = 10;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the vote struct
    bytes32 internal constant VOTE_TYPEHASH = keccak256("Vote(uint256 proposalId,uint8 voteType)");

    bytes32 internal constant _GOVERNANCE_PARAMS_SLOT =
        0x0116feaee435dceaf94f40403a5223724fba6d709cb4ce4aea5becab48feb141;

    // implementation slot is same as declared in proxy
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    bytes32 internal constant _NAME_SLOT = 0x553222b140782d4f4112160b374e6b1dc38e2837c7dcbf3ef473031724ed3bd4;

    bytes32 internal constant _PROPOSAL_SLOT = 0x52dbe777b6bf9bbaf43befe2c8e8af61027e6a0a8901def318a34b207514b5bc;

    bytes32 internal constant _PROPOSAL_COUNT_SLOT = 0x7d19d505a441201fb38442238c5f65c45e6231c74b35aed1c92ad842019eab9f;

    bytes32 internal constant _PROPOSED_ACTION_SLOT =
        0xe4ff3d203d0a873fb9ffd3a1bbd07943574a73114c5affe6aa0217c743adeb06;

    bytes32 internal constant _RECEIPT_SLOT = 0x5a7421539532aa5504e4251551519aa0a06f7c2a3b40bbade5235843e09ad5fe;
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2023 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../IRigoblockGovernance.sol";

abstract contract MixinAbstract {
    function _getProposalCount() internal view virtual returns (uint256);

    function _getProposalState(uint256 proposalId) internal view virtual returns (IRigoblockGovernance.ProposalState);

    function _getVotingPower(address account) internal view virtual returns (uint256);
}