pragma solidity ^0.8.0;

import "PumpToken.sol";
import "PumpTreasury.sol";
import "OwnableUpgradeable.sol";
import "vPumpToken.sol";

contract ElectionManager is OwnableUpgradeable {
    // View only struct -- used to group data returned by view functions
    struct BuyProposalMetadata {
        address proposer;
        uint256 createdAt;
        uint256 totalVotes;
    }

    // View only struct -- used to group data returned by view functions
    struct SellProposalMetadata {
        bool valid;
        uint256 totalVotes;
        uint256 createdAt;
    }

    struct Election {
        // The first block on which votes for this election can be cast
        uint256 votingStartBlock;
        // The last block on which votes for this election will be accepted, after this calls to vote will revert
        uint256 votingEndBlock;
        // The first block where a winner for the election can be declared. Intentionally different than votingEndBlock
        // in order to prevent flash loan attacks
        uint256 winnerDeclaredBlock;
        // Mapping from proposed taken address to bool indicating if this token has been proposed in this election
        mapping(address => bool) validProposals;
        // Mapping from proposed token address to data about the proposal
        mapping(address => BuyProposal) proposals;
        // Array of proposed token addresses -- useful for iterating over all proposals
        address[] proposedTokens;
        // Bool indicating if the winner has already been declared for this proposal
        bool winnerDeclared;
        // The address of the winning token
        address winner;
        // The amount of the winning token that has been purchased as a result of this election
        uint256 purchasedAmt;
        // The number of buys made for this election. Should never exceed the global maxBuys
        uint8 numBuysMade;
        // The next block on which a buy order can be made for this election
        uint256 nextValidBuyBlock;
        // The number of attempted buys that have failed for this election
        uint8 numFailures;
        // Indicates if sell proposal votes can be cast for this election
        bool sellProposalActive;
        // The total number of sell votes that have been cast for the sell proposal
        uint256 sellProposalTotalVotes;
        // The block number on which this sell proposal was created
        uint256 sellProposalCreatedAt;
        // Mapping from account to the number of sell votes they have cast for this election
        mapping(address => uint256) sellVotes;
    }

    // View only struct -- used to group data returned by view functions
    struct ElectionMetadata {
        uint256 votingStartBlock;
        uint256 votingEndBlock;
        uint256 winnerDeclaredBlock;
        bool winnerDeclared;
        address winner;
        // Buy related Data
        uint8 numBuysMade;
        uint256 nextValidBuyBlock;
        uint8 numFailures;
        // Sell related data
        bool sellProposalActive;
        uint256 sellProposalTotalVotes;
        uint256 sellProposalCreatedAt;
    }

    // Data related to a single buy proposal within an election
    struct BuyProposal {
        // Address of the accounts / contract that proposed the token
        address proposer;
        // The block that the proposal was created
        uint256 createdAt;
        // The total number of votes cast for this proposal
        uint256 totalVotes;
        // Mapping from account to the number of votes they have cast for this proposal
        mapping(address => uint256) votes;
    }

    // The number of blocks between when voting ends and a winner is declared. Prevents flash loan attacks.
    uint256 public winnerDelay;
    // Time between the start of an election and when the winner is declared
    uint256 public electionLength;
    // Address of the token for which a proposal will always be created by default
    address public defaultProposal;
    // The number of buys that will be made for each winning token (assuming the maxBuyFailures is not hit)
    uint256 public maxNumBuys;
    // The number of blocks to wait between each buy is made
    uint256 public buyCooldownBlocks;
    // The number of allowed buy failures after which a sell proposal becomes valid
    uint8 public maxBuyFailures;
    // The number of blocks to wait before the sell proposal quorum requirements begin to decay
    uint256 public sellLockupBlocks;
    // The half life of the sell proposal quorum requirements
    uint256 public sellHalfLifeBlocks;
    // The index of the current election
    uint256 public currElectionIdx;
    // Mapping from election Idx to data about the election
    mapping(uint256 => Election) public elections;
    VPumpToken public vPumpToken;
    // Fee required in order to create a proposal
    uint256 public proposalCreationTax;
    PumpTreasury public treasury;
    // The maximum number of allowed proposals per election.
    uint8 maxProposalsPerElection;
    // bool indicating whether or not the first election has started
    bool electionsStarted;
    // Convenience function to retrieve where a users


    event ProposalCreated(uint16 electionIdx, address tokenAddr);
    event BuyVoteDeposited(uint16 electionIdx, address tokenAddr, uint256 amt);
    event SellVoteDeposited(uint16 electionIdx, address tokenAddr, uint256 amt);
    event BuyVoteWithdrawn(uint16 electionIdx, address tokenAddr, uint256 amt);
    event SellVoteWithdrawn(uint16 electionIdx, address tokenAddr, uint256 amt);
    event WinnerDeclared(uint16 electionIdx, address winner, uint256 numVotes);
    event SellProposalExecuted(uint16 electionIdx);

    // Initialize takes the place of constructor in order to use a proxy pattern to upgrade later
    function initialize(
        VPumpToken _vPumpToken,
        uint256 _winnerDelay,
        uint256 _electionLength,
        address _defaultProposal,
        PumpTreasury _treasury,
        uint256 _maxNumBuys,
        uint256 _buyCooldownBlocks,
        uint256 _sellLockupBlocks,
        uint256 _sellHalfLifeBlocks
    ) public initializer {
        vPumpToken = _vPumpToken;
        winnerDelay = _winnerDelay;
        electionLength = _electionLength;
        defaultProposal = _defaultProposal;
        vPumpToken = _vPumpToken;
        currElectionIdx = 0;
        treasury = _treasury;
        maxNumBuys = _maxNumBuys;
        buyCooldownBlocks = _buyCooldownBlocks;
        sellLockupBlocks = _sellLockupBlocks;
        sellHalfLifeBlocks = _sellHalfLifeBlocks;
        maxBuyFailures = 2;
        proposalCreationTax = 0.25 * 10 ** 18;
        maxProposalsPerElection = 100;

        __Ownable_init();
    }

    function startFirstElection(uint256 _startBlock) public onlyOwner {
        require(!electionsStarted, "Election already started");
        electionsStarted = true;
        // Setup the first election data
        Election storage firstElection = elections[0];
        firstElection.votingStartBlock = _startBlock;
        firstElection.votingEndBlock = _startBlock + electionLength - winnerDelay;
        firstElection.winnerDeclaredBlock = _startBlock + electionLength;

        firstElection.validProposals[defaultProposal] = true;
        firstElection.proposals[defaultProposal].proposer = address(this);
        firstElection.proposals[defaultProposal].createdAt = block.number;
        firstElection.proposedTokens.push(defaultProposal);
    }

    function createProposal(uint16 _electionIdx, address _tokenAddr)
        public
        payable
    {
        require(
            _electionIdx == currElectionIdx,
            "Must use currentElectionIdx"
        );
        Election storage electionMetadata = elections[currElectionIdx];
        require(
            !electionMetadata.validProposals[_tokenAddr],
            "Proposal already created"
        );
        require(
            msg.value >= proposalCreationTax,
            "BuyProposal creation tax not met"
        );
        require(
            electionMetadata.proposedTokens.length <= maxProposalsPerElection,
            "Proposal limit hit"
        );

        electionMetadata.validProposals[_tokenAddr] = true;
        electionMetadata.proposals[_tokenAddr].proposer = msg.sender;
        electionMetadata.proposals[_tokenAddr].createdAt = block.number;
        electionMetadata.proposedTokens.push(_tokenAddr);

        emit ProposalCreated(_electionIdx, _tokenAddr);
    }

    function vote(uint16 _electionIdx, address _tokenAddr, uint256 _amt) public {
        require(
            vPumpToken.allowance(msg.sender, address(this)) >= _amt,
            "vPUMP transfer not approved"
        );
        require(
            _electionIdx == currElectionIdx,
            "Must use currElectionIdx"
        );
        Election storage electionMetadata = elections[currElectionIdx];
        require(
            block.number <= electionMetadata.votingEndBlock,
            "Voting has already ended"
        );
        require(
            electionMetadata.validProposals[_tokenAddr],
            "Must be valid proposal"
        );
        BuyProposal storage proposal = electionMetadata.proposals[_tokenAddr];
        proposal.votes[msg.sender] += _amt;
        proposal.totalVotes += _amt;
        vPumpToken.transferFrom(msg.sender, address(this), _amt);

        emit BuyVoteDeposited(_electionIdx, _tokenAddr, _amt);
    }

    function withdrawVote(uint16 _electionIdx, address _tokenAddr, uint256 _amt) public {
        Election storage electionMetadata = elections[_electionIdx];
        require(
            electionMetadata.validProposals[_tokenAddr],
            "Must be valid proposal"
        );
        BuyProposal storage proposal = electionMetadata.proposals[_tokenAddr];
        require(
            proposal.votes[msg.sender] >= _amt,
            "More votes than cast"
        );
        proposal.votes[msg.sender] -= _amt;
        proposal.totalVotes -= _amt;
        vPumpToken.transfer(msg.sender, _amt);

        emit BuyVoteWithdrawn(_electionIdx, _tokenAddr, _amt);
    }

    function declareWinner(uint16 _electionIdx) public {
        require(
            _electionIdx == currElectionIdx,
            "Must be currElectionIdx"
        );
        Election storage electionMetadata = elections[currElectionIdx];
        require(
            block.number >= electionMetadata.winnerDeclaredBlock,
            "Voting not finished"
        );

        // If no proposals were made, the default proposal wins
        address winningToken = electionMetadata.proposedTokens[0];
        uint256 winningVotes = electionMetadata.proposals[winningToken].totalVotes;
        // election grows too large this for loop could fully exhaust the maximum per tx gas meaning
        // it would be impossible for a call to getWinner to succeed.
        for (uint256 i = 0; i < electionMetadata.proposedTokens.length; i++) {
            address tokenAddr = electionMetadata.proposedTokens[i];
            BuyProposal storage proposal = electionMetadata.proposals[tokenAddr];
            if (proposal.totalVotes > winningVotes) {
                winningToken = tokenAddr;
                winningVotes = proposal.totalVotes;
            }
        }

        electionMetadata.winnerDeclared = true;
        electionMetadata.winner = winningToken;
        currElectionIdx += 1;
        Election storage nextElection = elections[currElectionIdx];
        nextElection.votingStartBlock = electionMetadata.winnerDeclaredBlock + 1;
        nextElection.votingEndBlock = electionMetadata.winnerDeclaredBlock + electionLength - winnerDelay;
        nextElection.winnerDeclaredBlock = electionMetadata.winnerDeclaredBlock + electionLength;
        // Setup the default proposal
        nextElection.validProposals[defaultProposal] = true;
        nextElection.proposals[defaultProposal].proposer = address(this);
        nextElection.proposals[defaultProposal].createdAt = block.number;
        nextElection.proposedTokens.push(defaultProposal);

        emit WinnerDeclared(_electionIdx, winningToken, winningVotes);
    }

    function voteSell(uint16 _electionIdx, uint256 _amt) public {
        require(
            vPumpToken.allowance(msg.sender, address(this)) >= _amt,
            "vPUMP transfer not approved"
        );
        Election storage electionData = elections[_electionIdx];
        require(electionData.sellProposalActive, "SellProposal not active");

        electionData.sellVotes[msg.sender] += _amt;
        electionData.sellProposalTotalVotes += _amt;
        vPumpToken.transferFrom(msg.sender, address(this), _amt);

        emit SellVoteDeposited(_electionIdx, electionData.winner, _amt);
    }

    function withdrawSellVote(uint16 _electionIdx, uint256 _amt) public {
        Election storage electionData = elections[_electionIdx];
        require(
            electionData.sellVotes[msg.sender] >= _amt,
            "More votes than cast"
        );

        electionData.sellVotes[msg.sender] -= _amt;
        electionData.sellProposalTotalVotes -= _amt;
        vPumpToken.transfer(msg.sender, _amt);

        emit SellVoteWithdrawn(_electionIdx, electionData.winner, _amt);
    }

    function executeBuyProposal(uint16 _electionIdx) public returns (bool) {
        Election storage electionData = elections[_electionIdx];
        require(electionData.winnerDeclared, "Winner not declared");
        require(electionData.numBuysMade < maxNumBuys, "Can't exceed maxNumBuys");
        require(electionData.nextValidBuyBlock <= block.number, "Must wait before executing");
        require(electionData.numFailures < maxBuyFailures, "Max fails exceeded");
        require(!electionData.sellProposalActive, "Sell Proposal already active");

        try treasury.buyProposedToken(electionData.winner) returns (uint256 _purchasedAmt) {
            electionData.purchasedAmt += _purchasedAmt;
            electionData.numBuysMade += 1;
            electionData.nextValidBuyBlock = block.number + buyCooldownBlocks;
            // If we've now made the max number of buys, mark the associatedSellProposal
            // as active and mark the amount of accumulated hilding token
            if (electionData.numBuysMade >= maxNumBuys) {
                electionData.sellProposalActive = true;
                electionData.sellProposalCreatedAt = block.number;
            }
            return true;
        } catch Error(string memory) {
            electionData.numFailures += 1;
            // If we've exceeded the number of allowed failures
            if (electionData.numFailures >= maxBuyFailures) {
                electionData.sellProposalActive = true;
                electionData.sellProposalCreatedAt = block.number;
            }
            return false;
        }

        // This return is never hit and is a hack to appease IDE sol static analyzer
        return true;
    }

    function executeSellProposal(uint16 _electionIdx) public {
        Election storage electionData = elections[_electionIdx];
        require(electionData.sellProposalActive, "SellProposal not active");
        uint256 requiredVotes = _getRequiredSellVPump(electionData.sellProposalCreatedAt);
        require(electionData.sellProposalTotalVotes >= requiredVotes, "Not enough votes to execute");

        treasury.sellProposedToken(electionData.winner, electionData.purchasedAmt);
        // After we've sold, mark the sell proposal as inactive so we don't sell again
        electionData.sellProposalActive = false;
        emit SellProposalExecuted(_electionIdx);
    }

    function getActiveProposals() public view returns (address[] memory) {
        return elections[currElectionIdx].proposedTokens;
    }

    function getProposal(
        uint16 _electionIdx,
        address _tokenAddr
    ) public view returns (BuyProposalMetadata memory) {
        require(
            elections[currElectionIdx].validProposals[_tokenAddr],
            "No valid proposal for args"
        );
        BuyProposal storage proposal = elections[_electionIdx].proposals[_tokenAddr];
        return BuyProposalMetadata({
            proposer: proposal.proposer,
            createdAt: proposal.createdAt,
            totalVotes: proposal.totalVotes
        });
    }

    function getElectionMetadata(
        uint16 _electionIdx
    ) public view returns (ElectionMetadata memory) {
        require(_electionIdx <= currElectionIdx, "Can't query future election");
        Election storage election = elections[_electionIdx];
        return ElectionMetadata({
            votingStartBlock: election.votingStartBlock,
            votingEndBlock: election.votingEndBlock,
            winnerDeclaredBlock: election.winnerDeclaredBlock,
            winnerDeclared: election.winnerDeclared,
            winner: election.winner,
            numBuysMade: election.numBuysMade,
            nextValidBuyBlock: election.nextValidBuyBlock,
            numFailures: election.numFailures,
            sellProposalActive: election.sellProposalActive,
            sellProposalTotalVotes: election.sellProposalTotalVotes,
            sellProposalCreatedAt: election.sellProposalCreatedAt
        });
    }

    function getBuyVotes(uint16 _electionIdx, address _proposal) public view returns (uint256) {
        Election storage election = elections[_electionIdx];
        return election.proposals[_proposal].votes[msg.sender];
    }

    function getSellVotes(uint16 _electionIdx) public view returns (uint256) {
        Election storage election = elections[_electionIdx];
        return election.sellVotes[msg.sender];
    }

    function _getRequiredSellVPump(uint256 _startBlock) public view returns (uint256) {
        uint256 outstandingVPump = vPumpToken.totalSupply();
        uint256 elapsedBlocks = block.number - _startBlock;
        if (elapsedBlocks <= sellLockupBlocks) {
            return outstandingVPump;
        }
        uint256 decayPeriodBlocks = elapsedBlocks - sellLockupBlocks;
        return _appxDecay(outstandingVPump, decayPeriodBlocks, sellHalfLifeBlocks);
    }

    function _appxDecay(
        uint256 _startValue,
        uint256 _elapsedTime,
        uint256 _halfLife
    ) internal view returns (uint256) {
        uint256 ret = _startValue >> (_elapsedTime / _halfLife);
        ret -= ret * (_elapsedTime % _halfLife) / _halfLife / 2;
        return ret;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "SafeMath.sol";
import "OwnableUpgradeable.sol";

contract PumpToken is OwnableUpgradeable {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public totalSupply;
    address public cannonAddr;
    address public electionManagerAddr;

    // Stores addresses that are excluded from cannonTax
    // This includes any proposal contract & the 0xDEAD wallet
    mapping(address => bool) private _cannonTaxExcluded;
    // Percent of transaction that goes to cannon
    uint256 public cannonTax = 3;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function initialize() public initializer {
        symbol = "PUMP";
        name = "Pump Token";
        decimals = 18;
        totalSupply = 100 * 10**6 * 10**18;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        __Ownable_init();
    }

    /**
        @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
        @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
             and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
             race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
             https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        @param _spender The address which will spend the funds.
        @param _value The amount of tokens to be spent.
        @return Success boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        @notice Set the address of the PumpCannon
        @param _cannonAddr The PumpCannon's address
     */
    function setCannonAddress(address _cannonAddr) public onlyOwner {
        cannonAddr = _cannonAddr;
    }

    /**
        @notice Exclude a specific address from all future cannon taxes
        @param _addrToExclude The address to exclude
     */
    function excludeAddress(address _addrToExclude) public {
        require(
            msg.sender == owner() || msg.sender == electionManagerAddr,
            "Not approved to exclude"
        );
        _cannonTaxExcluded[_addrToExclude] = true;
    }

    /**
        @notice Set the address of the ElectionManager
        @param _electionManagerAddr the ElectionManager's address
     */
    function setElectionManagerAddr(address _electionManagerAddr)
        public
        onlyOwner
    {
        electionManagerAddr = _electionManagerAddr;
    }

    /**
        @notice Getter to check the current balance of an address
        @param _owner Address to query the balance of
        @return Token balance
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
        @notice Getter to check the amount of tokens that an owner allowed to a spender
        @param _owner The address which owns the funds
        @param _spender The address which will spend the funds
        @return The amount of tokens still available for the spender
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /** shared logic for transfer and transferFrom */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(balances[_from] >= _value, "Insufficient balance");
        (uint256 _valueLessTax, uint256 tax) = _calculateTransactionTax(
            _from,
            _to,
            _value
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_valueLessTax);
        emit Transfer(_from, _to, _valueLessTax);

        if (tax > 0) {
            balances[cannonAddr] = balances[cannonAddr] + tax;
            emit Transfer(_from, cannonAddr, tax);
        }
    }

    function _calculateTransactionTax(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (uint256, uint256) {
        // Excluded addresses are excluded regardless of if they are sending
        // or receiving PUMP. This is to prevent the act of voting from costing
        // the voter PUMP.
        if (_cannonTaxExcluded[_from] || _cannonTaxExcluded[_to]) {
            return (_value, 0);
        }
        uint256 taxAmount = _value.mul(cannonTax).div(10**2);
        return (_value - taxAmount, taxAmount);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "c >= a");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a, "b <= a");
        c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b, "a == 0 || c / a == b");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0, "b > 0");
        c = a / b;
        return c;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "ContextUpgradeable.sol";
import "Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

pragma solidity ^0.8.0;
pragma abicoder v2;

// SPDX-License-Identifier: MIT

import "ElectionManager.sol";
import "PumpToken.sol";
import "SafeBEP20.sol";
import "IBEP20.sol";
import "IPancakeRouter02.sol";
import "OwnableUpgradeable.sol";

contract PumpTreasury is OwnableUpgradeable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    PumpToken public pumpToken;
    IPancakeRouter02 public pancakeRouter;
    IBEP20 public wBNB;
    address public electionMangerAddr;

    event TreasurySwap(address _caller, uint256 _amount);
    event BuyProposedToken(address _tokenAddress, uint256 _wBNBAmt);
    event SellAndStake(address _tokenSold, uint256 _pumpStaked, uint256 _bnbStaked);

    modifier onlyElectionManager() {
        require(electionMangerAddr == msg.sender, "Caller is not ElectionManager");
        _;
    }

    function initialize(
        PumpToken _pumpToken,
        address _wBNBAddr,
        address _pancakeRouterAddr
    ) public initializer {
        pumpToken = _pumpToken;
        pancakeRouter = IPancakeRouter02(_pancakeRouterAddr);
        wBNB = IBEP20(_wBNBAddr);
        __Ownable_init();
    }

    function setElectionManagerAddress(address _addr) public onlyOwner {
        electionMangerAddr = _addr;
    }

    function swapPumpForBNB(uint256 _amount) public {
        emit TreasurySwap(msg.sender, _amount);
        _performSwap(address(pumpToken), address(wBNB), _amount);
    }

    function buyProposedToken(address _tokenAddr) public onlyElectionManager returns (uint256) {
        // Each buy uses 1% of the available treasury
        uint256 buySize = wBNB.balanceOf(address(this)) / 100;

        uint256 startingAmt = IBEP20(_tokenAddr).balanceOf(address(this));
        _performSwap(address(wBNB), _tokenAddr, buySize);
        uint256 endingAmt = IBEP20(_tokenAddr).balanceOf(address(this));
        emit BuyProposedToken(_tokenAddr, buySize);

        return endingAmt - startingAmt;
    }

    function sellProposedToken(address _tokenAddr, uint256 _amt) public onlyElectionManager {
        // First sell the position and record how much BNB we receive for it
        uint256 initialBalance = address(this).balance;
        _performSwap(_tokenAddr, address(wBNB), _amt);
        uint256 newBalance = address(this).balance;
        uint256 receivedBNB = newBalance - initialBalance;

        // Now, use half the BNB to buy PUMP -- also recording how much PUMP we receive
        uint256 initialPump = pumpToken.balanceOf(address(this));
        _performSwap(address(wBNB), address(pumpToken), receivedBNB / 2);
        uint256 newPump = pumpToken.balanceOf(address(this));
        uint256 receivedPump = newPump - initialPump;

        // Now stake the received PUMP against the remaining BNB
        _addPumpLiquidity(receivedPump, receivedBNB / 2);
        emit SellAndStake(_tokenAddr, receivedPump, receivedBNB / 2);
    }

    function _addPumpLiquidity(uint256 _pumpAmount, uint256 _bnbAmount) internal {
        // add the liquidity
        pancakeRouter.addLiquidityETH{value: _bnbAmount}(
            address(pumpToken),
            _pumpAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }


    function _performSwap(
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) internal {
        IBEP20(tokenIn).approve(address(pancakeRouter), amount);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount, // amountIn
            0, // amountOutMin -- slippage here is unavoidable, no use adding min
            path, // path
            address(this), // to
            block.timestamp // deadline
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "AddressUpgradeable.sol";
import "IBEP20.sol";


/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using AddressUpgradeable for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity >=0.6.2;

import "IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "SafeMath.sol";
import "OwnableUpgradeable.sol";


contract VPumpToken is OwnableUpgradeable {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public totalSupply;
    address public canMintBurn;
    address public electionManager;


    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyCanMintBurn {
      require(msg.sender == canMintBurn, "Must have mintBurn role");
      _;
    }

    function initialize() public initializer {
       symbol = "vPUMP";
       name = "Voting Pump";
       decimals = 18;
       totalSupply = 0;
       canMintBurn = msg.sender;
       balances[msg.sender] = totalSupply;
       emit Transfer(address(0), msg.sender, totalSupply);
       __Ownable_init();
    }

    function setCanMintBurn(address _canMintBurn) public onlyOwner {
        canMintBurn = _canMintBurn;
    }

    function setElectionManagerAddress(address _electionManager) public onlyOwner {
        electionManager = _electionManager;
    }

    /**
        @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
        @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
             and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
             race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
             https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        @param _spender The address which will spend the funds.
        @param _value The amount of tokens to be spent.
        @return Success boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyCanMintBurn returns (bool) {
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public onlyCanMintBurn returns(bool) {
        require(balances[_from] >= _value, "Insufficient balance");
        totalSupply = totalSupply.sub(_value);
        balances[_from] = balances[_from].sub(_value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    /**
        @notice Getter to check the current balance of an address
        @param _owner Address to query the balance of
        @return Token balance
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
        @notice Getter to check the amount of tokens that an owner allowed to a spender
        @param _owner The address which owns the funds
        @param _spender The address which will spend the funds
        @return The amount of tokens still available for the spender
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /** shared logic for transfer and transferFrom */
    // Note: _vPump is deliberately non-transferable unless it is to or from the electionManager contract
    // this is to avoid secondary markets from popping up
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value, "Insufficient balance");
        require(_from == electionManager || _to == electionManager, "Only transfer electionManager");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
}