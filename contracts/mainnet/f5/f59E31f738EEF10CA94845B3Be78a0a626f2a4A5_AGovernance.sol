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

// solhint-disable-next-line
pragma solidity =0.8.17;

import "./interfaces/IAGovernance.sol";

/// @title Governance adapter - A helper contract for interacting with governance.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
contract AGovernance is IAGovernance {
    address private immutable _governance;

    constructor(address governance) {
        _governance = governance;
    }

    /// @inheritdoc IAGovernance
    function propose(IRigoblockGovernance.ProposedAction[] memory actions, string memory description)
        external
        override
    {
        IRigoblockGovernance(_getGovernance()).propose(actions, description);
    }

    /// @inheritdoc IAGovernance
    function castVote(uint256 proposalId, IRigoblockGovernance.VoteType voteType) external override {
        IRigoblockGovernance(_getGovernance()).castVote(proposalId, voteType);
    }

    /// @inheritdoc IAGovernance
    function execute(uint256 proposalId) external override {
        IRigoblockGovernance(_getGovernance()).execute(proposalId);
    }

    function _getGovernance() private view returns (address) {
        return _governance;
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

import "../../../../governance/IRigoblockGovernance.sol";

interface IAGovernance {
    /// @notice Allows to make a proposal to the Rigoblock governance.
    /// @param actions Array of tuples of proposed actions.
    /// @param description A human-readable description.
    function propose(IRigoblockGovernance.ProposedAction[] memory actions, string memory description) external;

    /// @notice Allows a pool to vote on a proposal.
    /// @param proposalId Number of the proposal.
    /// @param voteType Enum of the vote type.
    function castVote(uint256 proposalId, IRigoblockGovernance.VoteType voteType) external;

    /// @notice Allows a pool to execute a proposal.
    /// @param proposalId Number of the proposal.
    function execute(uint256 proposalId) external;
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