// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";

interface ISMPLNFT {
    struct Stakeholder {
        uint256 amount;
        uint256 profit;
        uint256 startDate;
        uint256 endDate;
        uint256 lastClaimDate;
        bool unstaked;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function stakeholders(uint256 id) external returns (Stakeholder memory);

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract Governance is Ownable {
    struct Vote {
        uint256 declines;
        uint256 accepts;
        uint256 abstains;
        mapping(address => bool) isVoted;
    }

    struct Question {
        string question;
        string answer;
    }

    struct Proposal {
        uint256 startDate;
        uint256 endDate;
        Question[] questions;
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => Vote) public votes;

    ISMPLNFT public nft;

    uint256 public constant VOTING_DELAY = 3600; // 3600 = 1 hour

    bytes32[] public proposalIds;

    constructor(ISMPLNFT _nft) {
        nft = _nft;
    }

    function propose(
        string[] calldata _questions,
        string[] calldata _answers,
        string calldata _description,
        uint256 _duration
    ) external onlyOwner {
        bytes32 proposalId = keccak256(
            abi.encode(
                _questions,
                _answers,
                keccak256(bytes(_description)),
                _duration
            )
        );

        require(
            proposals[proposalId].startDate == 0,
            "Governance: Proposal exist!"
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.startDate = block.timestamp + VOTING_DELAY;
        proposal.endDate = block.timestamp + VOTING_DELAY + _duration;

        for (uint8 index = 0; index < _questions.length; index++) {
            proposal.questions.push(
                Question({question: _questions[index], answer: _answers[index]})
            );
        }

        proposalIds.push(proposalId);
    }

    function vote(
        bytes32 _proposalId,
        uint8 _voteType,
        string[] calldata _answers
    ) external {
        uint256 tokenCount = nft.balanceOf(_msgSender());

        require(tokenCount > 0, "Governance: Not enough tokens!");

        Proposal storage proposal = proposals[_proposalId];

        require(
            proposal.startDate < block.timestamp &&
                proposal.endDate > block.timestamp,
            "Governance: Voting is ended!"
        );

        for (uint8 index = 0; index < proposal.questions.length; index++) {
            require(
                keccak256(abi.encodePacked(_answers[index])) ==
                    keccak256(
                        abi.encodePacked(proposal.questions[index].answer)
                    ),
                "Governance: Wrong answer!"
            );
        }

        uint256 votingPower = 0;

        for (uint256 index = 0; index < tokenCount; index++) {
            uint256 nftId = nft.tokenOfOwnerByIndex(_msgSender(), index);

            votingPower += nft.stakeholders(nftId).amount;
        }

        Vote storage pVote = votes[_proposalId];

        require(
            pVote.isVoted[_msgSender()] == false,
            "Governance: Already voted!"
        );

        if (_voteType == 0) {
            pVote.accepts += votingPower;
        } else if (_voteType == 1) {
            pVote.declines += votingPower;
        } else {
            pVote.abstains += votingPower;
        }

        pVote.isVoted[_msgSender()] = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
}