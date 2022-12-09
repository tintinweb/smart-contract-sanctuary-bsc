// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC721.sol";
import "./IterableArbiters.sol";

/// @title LPY Dispute Contract
/// @author Leisure Pay
/// @notice Dispute Contract for the Leisure Pay Ecosystem
contract DisputeContract is AccessControlEnumerable, ReentrancyGuard {
    using IterableArbiters for IterableArbiters.Map;
    using ECDSA for bytes32;
    using Strings for uint256;

    enum State {
        Open,
        Closed,
        Canceled
    }

    enum PARTIES {
        NULL,
        A,
        B
    }

    struct NFT {
        address _nft;
        uint256 _id;
    }

    struct Dispute {
        uint256 disputeIndex;
        NFT _nft;
        uint256 usdValue;
        uint256 tokenValue;
        address sideA;
        address sideB;
        bool hasClaim;
        uint256 voteCount;
        uint256 support;
        uint256 against;
        IterableArbiters.Map arbiters;
        bool claimed;
        PARTIES winner;
        State state;
    }

    struct DisputeView {
        uint256 disputeIndex;
        NFT _nft;
        uint256 usdValue;
        uint256 tokenValue;
        address sideA;
        address sideB;
        bool hasClaim;
        uint256 voteCount;
        uint256 support;
        uint256 against;
        IterableArbiters.UserVote[] arbiters;
        bool claimed;
        PARTIES winner;
        State state;
    }

    /// @notice Total number of disputes on chain
    /// @dev This includes cancelled disputes as well
    uint256 public numOfdisputes;

    /// @notice mapping to get dispute by ID where `uint256` key is the dispute ID
    mapping(uint256 => Dispute) private disputes;

    /// @notice Easily get a user's created disputes IDs
    mapping(address => uint256[]) public disputeIndexesAsSideA;

    /// @notice Easily get a user's attached disputes iDs
    mapping(address => uint256[]) public disputeIndexesAsSideB;

    /// @notice Address that points to the LPY contract - used for settling disputes
    IERC20 private lpy;

    // ROLES
    /// @notice SERVER_ROLE LPY Dispute Automation Server
    bytes32 public constant SERVER_ROLE = keccak256("SERVER_ROLE");

    // CONSTRUCTOR

    /// @notice Default initializer for the dispute contract
    /// @param _lpy Address of the LPY contract
    /// @param _server Address of the Server
    constructor(
        IERC20 _lpy,
        address _server
    ) {
        require(address(_lpy) != address(0) && _server != address(0), "Addresses must be set");
        
        lpy = _lpy;
        _grantRole(SERVER_ROLE, _server);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // EVENTS
    /// @notice Event emitted when a dispute is created
    /// @param disputeIndex Created dispute ID
    /// @param _nft A struct containing the NFT address and its ID
    /// @param hasClaim Initial value to determine if dispute is claimable
    /// @param usdValue Dispute's USD at stake (1000000 == 1 USD; 6 decimals)
    /// @param sideA Creator of the dispute
    /// @param sideB Attached user to the dispute
    /// @param arbiters An array of users responsible for voting
    event DisputeCreated(
        uint256 indexed disputeIndex,
        NFT _nft,
        bool hasClaim,
        uint256 usdValue,
        address indexed sideA,
        address indexed sideB,
        address[] arbiters
    );

    /// @notice Event emitted when an arbiter votes on a dispute
    /// @param disputeIndex Dispute ID
    /// @param voter The Voter
    /// @param agree If user votes YES or NO to the dispute
    event DisputeVoted(
        uint256 indexed disputeIndex,
        address indexed voter,
        bool agree
    );

    /// @notice Event emitted when a dispute is closed
    /// @param disputeIndex Dispute ID
    /// @param usdValue Dispute's USD at stake (1000000 == 1 USD; 6 decimals)
    /// @param tokenValue LPY Token worth `usdValue`
    /// @param rate The present lpy rate per usd
    /// @param sideAVotes Total Votes `sideA` received
    /// @param sideBVotes Total Votes `sideB` received
    /// @param winner Winner of the dispute
    event DisputeClosed(
        uint256 indexed disputeIndex,
        uint256 usdValue,
        uint256 tokenValue,
        uint256 rate,
        uint256 sideAVotes,
        uint256 sideBVotes,
        PARTIES winner
    );

    /// @notice Event emitted when a dispute is caqncelled
    /// @param disputeIndex Dispute ID
    event DisputeCanceled(uint256 indexed disputeIndex);

    /// @notice Event emitted when a dispute fund is claimed
    /// @param disputeIndex Dispute ID
    /// @param tokenValue Amount of LPY claimed
    /// @param claimer Receiver of the funds
    event DisputeFundClaimed(
        uint256 indexed disputeIndex,
        uint256 tokenValue,
        address indexed claimer
    );

    /// @notice Event emitted when a sideA is modified
    /// @param disputeIndex Dispute ID
    /// @param oldSideA Previous SideA Address
    /// @param newSideA New SideA Address
    event SideAUpdated(
        uint256 indexed disputeIndex,
        address indexed oldSideA,
        address indexed newSideA
    );

    /// @notice Event emitted when a sideB is modified
    /// @param disputeIndex Dispute ID
    /// @param oldSideB Previous SideB Address
    /// @param newSideB New SideB Address
    event SideBUpdated(
        uint256 indexed disputeIndex,
        address indexed oldSideB,
        address indexed newSideB
    );

    /// @notice Event emitted when an arbiter is added to dispute
    /// @param disputeIndex Dispute ID
    /// @param arbiter Arbiter added
    event ArbiterAdded(
        uint256 indexed disputeIndex,
        address indexed arbiter
    );

    /// @notice Event emitted when an arbiter is removed to dispute
    /// @param disputeIndex Dispute ID
    /// @param arbiter Arbiter removed
    event ArbiterRemoved(
        uint256 indexed disputeIndex,
        address indexed arbiter
    );

    /// @notice Event emitted when hasClaim gets toggled
    /// @param disputeIndex Dispute ID
    /// @param value Value of hasClaim
    event ToggledHasClaim(
        uint256 indexed disputeIndex,
        bool value
    );

    // INTERNAL FUNCTIONS

    /// @notice Internal function that does the actual casting of vote, and emits `DisputeVoted` event
    /// @dev Can only be called by public/external functions that have done necessary checks <br/>1. dispute is opened<br/> 2. user must be an arbiter<br/>3. user should not have already voted
    /// @param disputeIndex ID of the dispute to vote on
    /// @param signer The user that's voting
    /// @param agree The vote's direction where `true==YES and false==NO`
    /// @return UserVote struct containing the vote details
    function _castVote(
        uint256 disputeIndex,
        address signer,
        bool agree
    ) internal returns (IterableArbiters.UserVote memory) {
        IterableArbiters.UserVote memory vote = IterableArbiters.UserVote(signer, agree, true);

        emit DisputeVoted(disputeIndex, signer, agree);

        return vote;
    }

    /// @notice Internal function that gets signer of a vote from a message `(id+msg)` and signature bytes
    /// @dev Concatenate the dispute ID and MSG to get the message to sign, and uses ECDSA to get the signer of the message
    /// @param id ID of the dispute the message was signed on
    /// @param _msg The original message signed
    /// @param _sig The signed message signature
    /// @return signer of the message, if valid, otherwise `0x0`
    /// @return vote direction of the signature, if valid, otherwise `false`
    function _getSignerAddress(uint256 id, string memory _msg, bytes memory _sig)
        internal
        pure
        returns (address, bool)
    {
        bytes32 voteA = keccak256(abi.encodePacked(id.toString(),"A"));
        bytes32 voteB = keccak256(abi.encodePacked(id.toString(),"B"));

        bytes32 hashMsg = keccak256(bytes(_msg));

        if(hashMsg != voteA && hashMsg != voteB) return (address(0), false);

        return (
            hashMsg.toEthSignedMessageHash().recover(_sig),
            hashMsg == voteA
        );


    }

    // PUBLIC AND EXTERNAL FUNCTIONS

    /// @notice Changes the `hasClaim` field of a dispute to the opposite
    /// @dev Function can only be called by a user with the `DEFAULT_ADMIN_ROLE` or `SERVER_ROLE` role
    /// @param disputeIndex the id or disputeIndex of the dispute in memory
    function toggleHasClaim(uint disputeIndex) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SERVER_ROLE, msg.sender), "Only Admin or Server Allowed");

        Dispute storage dispute = disputes[disputeIndex];
        dispute.hasClaim = !dispute.hasClaim;
        emit ToggledHasClaim(dispute.disputeIndex, dispute.hasClaim);
    }

    /// @notice Adds a new dispute
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles, <br/>all fields can be changed post function call except the `_nftAddr` and `txID`
    /// @param _sideA Is the creator of the dispute
    /// @param _sideB Is the user the dispute is against
    /// @param _hasClaim A field to know if settlement occurs on chain
    /// @param _nftAddr The LPY NFT contract address
    /// @param txID The LPY NFT ID to confirm it's a valid transaction
    /// @param usdValue Dispute's USD at stake (1000000 == 1 USD; 6 decimals)
    /// @param _arbiters List of users that can vote on this dispute
    /// @return if creation was successful or not
    function createDisputeByServer(
        address _sideA,
        address _sideB,
        bool _hasClaim,
        address _nftAddr,
        uint256 txID,
        uint256 usdValue,
        address[] memory _arbiters
    ) external onlyRole(SERVER_ROLE) returns (bool) {
        require(_sideA != _sideB, "sideA == sideB");
        require(_sideA != address(0), "sideA has to be set");
        require(_nftAddr != address(0), "NFTAddr has to be set");
        require(usdValue > 0, "usdValue has to be > 0");

        if(_sideB == address(0)){
            _sideB = address(this);
        }

        uint256 disputeIndex = numOfdisputes++;

        Dispute storage dispute = disputes[disputeIndex];

        // Non altering call to confirm tokenID is already minted
        IERC721Extended(_nftAddr).tokenURI(txID);

        dispute.disputeIndex = disputeIndex;
        dispute._nft = NFT(_nftAddr, txID);
        dispute.sideA = _sideA;
        dispute.sideB = _sideB;
        dispute.hasClaim = _hasClaim;

        for (uint256 i = 0; i < _arbiters.length; i++) {
            require(_arbiters[i] != address(0), "Arbiter is not valid");
            require(!dispute.arbiters.contains(_arbiters[i]), "Duplicate Keys");
            dispute.arbiters.set(_arbiters[i], IterableArbiters.UserVote(_arbiters[i], false, false));
        }
        dispute.state = State.Open;
        dispute.usdValue = usdValue;

        disputeIndexesAsSideA[_sideA].push(disputeIndex);
        disputeIndexesAsSideB[_sideB].push(disputeIndex);

        emit DisputeCreated(
            disputeIndex,
            dispute._nft,
            dispute.hasClaim,
            usdValue,
            _sideA,
            _sideB,
            dispute.arbiters.keysAsArray()
        );

        return true;
    }

    /// @notice Function to let a user directly vote on a dispute
    /// @dev  Can only be called if; <br/> 1. dispute state is `OPEN` <br/> 2. the user is an arbiter of that very dispute<br/>3. the user has not already voted on that dispute<br/>This function calls @_castVote
    /// @param disputeIndex ID of the dispute to vote on
    /// @param _agree The vote's direction where `true==support for sideA and false==support for sideB`
    /// @return if vote was successful or not
    function castVote(uint256 disputeIndex, bool _agree) external returns (bool) {
        Dispute storage dispute = disputes[disputeIndex];

        require(dispute.state == State.Open, "dispute is closed");
        require(dispute.arbiters.contains(msg.sender), "Not an arbiter");
        require(!dispute.arbiters.get(msg.sender).voted, "Already Voted");

        // cast vote and emit an event
        IterableArbiters.UserVote memory vote = _castVote(disputeIndex, msg.sender, _agree);

        dispute.voteCount += 1;
        dispute.support += _agree ? 1 : 0;
        dispute.against += _agree ? 0 : 1;

        dispute.arbiters.set(msg.sender, vote); // Save vote casted

        return true;
    }

    /// @notice Function to render a dispute cancelled and not interactable anymore
    /// @dev  Can only be called if dispute state is `OPEN` and the user the `SERVER_ROLE` role and it emits a `DisputeCanceled` event
    /// @param disputeIndex ID of the dispute to cancel
    function cancelDispute(uint256 disputeIndex) external onlyRole(SERVER_ROLE){
        Dispute storage dispute = disputes[disputeIndex];

        require(dispute.state == State.Open, "dispute is closed");
        dispute.state = State.Canceled;

        emit DisputeCanceled(disputeIndex);
    }

    /// @notice Submits signed votes to contract
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles<br/>This function calls @_castVote
    /// @param disputeIndex ID of the dispute
    /// @param _sigs _sigs is an array of signatures`
    /// @param _msgs _msgs is an array of the raw messages that was signed`
    /// @return if vote casting was successful
    function castVotesWithSignatures(
        uint256 disputeIndex,
        bytes[] memory _sigs,
        string[] memory _msgs
    ) external onlyRole(SERVER_ROLE) returns (bool) {
        Dispute storage dispute = disputes[disputeIndex];

        require(_sigs.length == _msgs.length, "sigs and msg != same length");
        require(dispute.state == State.Open, "dispute is closed");
        bool voteCasted;
        for (uint256 i = 0; i < _sigs.length; i++) {
            (address signer, bool agree) = _getSignerAddress(
                disputeIndex,
                _msgs[i],
                _sigs[i]
            );

            if (!dispute.arbiters.contains(signer)) {
                continue;
            }
            require(!dispute.arbiters.get(signer).voted, "Already Voted");

            // cast vote and emit an event
            IterableArbiters.UserVote memory vote = _castVote(disputeIndex, signer, agree);

            dispute.voteCount += 1;
            dispute.support += agree ? 1 : 0;
            dispute.against += agree ? 0 : 1;

            dispute.arbiters.set(signer, vote); // Save vote casted
            if(!voteCasted)
                voteCasted = true;
        }
        require(voteCasted, "No votes to cast");
        return true;
    }

    /// @notice Finalizes and closes dispute
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles<br/>The server has the final say by passing `sideAWins` to `true|false`, and emits a `DisputeClosed` event
    /// @param disputeIndex ID of the dispute
    /// @param sideAWins Final say of the server on the dispute votes
    /// @param ratio This is the rate of LPY per USD
    /// @return if vote finalize was succesful
    function finalizeDispute(
        uint256 disputeIndex,
        bool sideAWins,
        uint256 ratio // tokens per dollar
    ) external onlyRole(SERVER_ROLE) returns (bool) {
        require(ratio > 0, "Ratio has to be > 0");
        
        Dispute storage dispute = disputes[disputeIndex];
        require(dispute.state == State.Open, "dispute is closed");
        require(dispute.voteCount == dispute.arbiters.size(), "Votes not completed");

        dispute.tokenValue = (dispute.usdValue * ratio) / 1e6; // divide by 1e6 (6 decimals)

        dispute.winner = sideAWins ? PARTIES.A : PARTIES.B;

        dispute.state = State.Closed;

        if(!dispute.hasClaim)
            dispute.claimed = true;

        emit DisputeClosed(
            disputeIndex,
            dispute.usdValue,
            dispute.tokenValue,
            ratio,
            dispute.support,
            dispute.against,
            dispute.winner
        );

        return true;
    }

    /// @notice Adds a user as an arbiter to a dispute
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles
    /// @param disputeIndex ID of the dispute
    /// @param _arbiter User to add to list of dispute arbiters
    function addArbiter(uint256 disputeIndex, address _arbiter)
        external
        onlyRole(SERVER_ROLE)
    {
        Dispute storage _dispute = disputes[disputeIndex];

        require(_dispute.state == State.Open, "dispute is closed");
        require(!_dispute.arbiters.contains(_arbiter), "Already an Arbiter");

        _dispute.arbiters.set(_arbiter, IterableArbiters.UserVote(_arbiter, false, false));
        emit ArbiterAdded(_dispute.disputeIndex, _arbiter);
    }

    /// @notice Removes a user as an arbiter to a dispute
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles
    /// @param disputeIndex ID of the dispute
    /// @param _arbiter User to remove from list of dispute arbiters
    function removeArbiter(uint256 disputeIndex, address _arbiter)
        external
        onlyRole(SERVER_ROLE)
    {
        Dispute storage _dispute = disputes[disputeIndex];
        
        require(_dispute.state == State.Open, "dispute is closed");
        require(_dispute.arbiters.contains(_arbiter), "Not an arbiter");


        IterableArbiters.UserVote memory vote = _dispute.arbiters.get(_arbiter);

        if (vote.voted) {
            _dispute.support -= vote.agree ? 1 : 0;
            _dispute.against -= vote.agree ? 0 : 1;
            _dispute.voteCount -= 1;
        }
        _dispute.arbiters.remove(_arbiter);
        emit ArbiterRemoved(_dispute.disputeIndex, _arbiter);
    }

    /// @notice Change sideA address (in the unlikely case of an error)
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles
    /// @param disputeIndex ID of the dispute
    /// @param _sideA The address of the new sideA
    function updateSideA(uint256 disputeIndex, address _sideA)
        external
        onlyRole(SERVER_ROLE)
    {
        // Server would be able to update incase owner loses key
        Dispute storage _dispute = disputes[disputeIndex];
        emit SideAUpdated(disputeIndex, _dispute.sideA, _sideA);
        _dispute.sideA = _sideA;
    }

    /// @notice Change sideB address (in the unlikely case of an error)
    /// @dev Function can only be called by a user with the `SERVER_ROLE` roles
    /// @param disputeIndex ID of the dispute
    /// @param _sideB The address of the new sideB
    function updateSideB(uint256 disputeIndex, address _sideB)
        external
        onlyRole(SERVER_ROLE)
    {
        // Server would be able to update incase owner loses key
        Dispute storage _dispute = disputes[disputeIndex];
        emit SideBUpdated(disputeIndex, _dispute.sideB, _sideB);
        _dispute.sideB = _sideB;
    }

    /// @notice Function for user to claim the tokens
    /// @dev Function can only be called by just a user with the `SERVER_ROLE` and the winner of the dispute, emits a `DisputeFundClaimed` event
    /// @param disputeIndex ID of the dispute
    function claim(uint256 disputeIndex) external nonReentrant returns (bool) {
        Dispute storage _dispute = disputes[disputeIndex];
        require(_dispute.state == State.Closed, "dispute is not closed");
        require(_dispute.claimed != true, "Already Claimed");

        if (_dispute.winner == PARTIES.A) {
            require(
                hasRole(SERVER_ROLE, msg.sender) ||
                    msg.sender == _dispute.sideA,
                "Only SideA or Server can claim"
            );
        } else {
            require(
                hasRole(SERVER_ROLE, msg.sender) ||
                    msg.sender == _dispute.sideB,
                "Only SideB or Server can claim"
            );
        }

        _dispute.claimed = true;

        emit DisputeFundClaimed(_dispute.disputeIndex, _dispute.tokenValue, msg.sender);
        uint cBal = lpy.balanceOf(address(this));
        require(cBal >= _dispute.tokenValue, "transfer failed: insufficient balance");

        lpy.transfer(msg.sender, _dispute.tokenValue);
        return true;
    }

    // READ ONLY FUNCTIONS

    /// @notice Internal function to convert type @Dispute to type @DisputeView
    /// @param disputeIndex ID of the dispute
    /// @return DisputeView object
    function serializeDispute(uint disputeIndex) internal view returns (DisputeView memory) {
        Dispute storage _dispute = disputes[disputeIndex];

        return DisputeView(
            _dispute.disputeIndex,
            _dispute._nft,
            _dispute.usdValue,
            _dispute.tokenValue,
            _dispute.sideA,
            _dispute.sideB,
            _dispute.hasClaim,
            _dispute.voteCount,
            _dispute.support,
            _dispute.against,
            _dispute.arbiters.asArray(),
            _dispute.claimed,
            _dispute.winner,
            _dispute.state
        );
    }

    /// @notice Get all Disputes in the contract
    /// @return Array of DisputeView object
    function getAllDisputes()
        external
        view
        returns (DisputeView[] memory)
    {
        uint256 count = numOfdisputes;
        DisputeView[] memory _disputes = new DisputeView[](count);

        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            _disputes[i] = dispute;
        }

        return _disputes;
    }

    /// @notice Get all Open Dispute
    /// @return Array of DisputeView object
    function getAllOpenDisputes()
        external
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Open) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Open) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Closed Dispute
    /// @return Array of DisputeView object
    function getAllClosedDisputes()
        external
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Closed) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Closed) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Canceled Dispute
    /// @return Array of DisputeView object
    function getAllCanceledDisputes()
        external
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Canceled) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < numOfdisputes; i++) {
            DisputeView memory dispute = serializeDispute(i);
            if (dispute.state == State.Canceled) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }
    /// @notice Get a specific dispute based on `disputeIndex`
    /// @param disputeIndex ID of the dispute
    /// @return _dispute DisputeView object
    function getDisputeByIndex(uint256 disputeIndex)
        external
        view
        returns (DisputeView memory _dispute)
    {
        _dispute = serializeDispute(disputeIndex);
    }

    /// @notice Get all Open Dispute where sideA is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideAOpenDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Open) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Open) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Closed Dispute where sideA is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideAClosedDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Closed) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Closed) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Canceled Dispute where sideA is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideACanceledDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Canceled) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideA[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideA[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Canceled) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Open Dispute where sideB is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideBOpenDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Open) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Open) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Closed Dispute where sideB is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideBClosedDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Closed) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Closed) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Canceled Dispute where sideB is `_user`
    /// @param _user User to get disputes for
    /// @return Array of DisputeView object
    function getSideBCanceledDisputes(address _user)
        public
        view
        returns (DisputeView[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Canceled) {
                count++;
            }
        }

        DisputeView[] memory _disputes = new DisputeView[](count);

        uint256 outterIndex;
        for (uint256 i = 0; i < disputeIndexesAsSideB[_user].length; i++) {
            uint256 disputeIndex = disputeIndexesAsSideB[_user][i];
            DisputeView memory dispute = serializeDispute(disputeIndex);
            if (dispute.state == State.Canceled) {
                _disputes[outterIndex] = dispute;
                outterIndex++;
            }
        }

        return _disputes;
    }

    /// @notice Get all Open Dispute where sideA is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyOpenDisputesAsSideA()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideAOpenDisputes(msg.sender);
    }

    /// @notice Get all Close Dispute where sideA is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyClosedDisputesAsSideA()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideAClosedDisputes(msg.sender);
    }

    /// @notice Get all Canceled Dispute where sideA is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyCanceledDisputesAsSideA()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideAClosedDisputes(msg.sender);
    }

    /// @notice Get all Open Dispute where sideB is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyOpenDisputesAsSideB()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideBOpenDisputes(msg.sender);
    }

    /// @notice Get all Closed Dispute where sideB is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyClosedDisputesAsSideB()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideBClosedDisputes(msg.sender);
    }

    /// @notice Get all Canceled Dispute where sideB is the one calling the function
    /// @return _disputes Array of DisputeView object
    function getMyCanceledDisputesAsSideB()
        external
        view
        returns (DisputeView[] memory _disputes)
    {
        _disputes = getSideBCanceledDisputes(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Extended is IERC721 {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library IterableArbiters {

    struct UserVote {
        address voter;
        bool agree;
        bool voted;
    }

    struct Map {
        address[] keys;
        mapping(address => UserVote) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    /// @notice Check if `key` is in `map`
    /// @param map The storage map
    /// @param key The key to check if it is in `map`
    /// @return if `key` is in `map`
    function contains(Map storage map, address key) public view returns (bool) {
        return map.inserted[key];
    }

    /// @notice Get the `UserVote` object of `key` in `map`
    /// @param map The storage map
    /// @param key The key to fetch the `UserVote` object of
    /// @return `UserVote` of `key`
    function get(Map storage map, address key) public view returns (UserVote memory) {
        return map.values[key];
    }

    /// @notice Get the Index of `key`
    /// @param map The storage map
    /// @param key The key to fetch index of
    /// @return index of `key`
    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        require(map.indexOf[key] < 2**255, "index too large");
        return int(map.indexOf[key]);
    }

    /// @notice Get the `key` at `index`
    /// @param map The storage map
    /// @param index The index of key to fetch
    /// @return `key` at `index`
    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    /// @notice Get total keys in the `map`
    /// @param map The storage map
    /// @return the length of `keys`
    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    /// @notice Sets `key` to `val` and update other fields
    /// @dev This function is used to update the `UserVote` object of `key` in `map`
    /// @param map The storage map
    /// @param key Key to update
    /// @param val Value to set `key` to
    function set(Map storage map, address key, UserVote memory val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    /// @notice Removes `key` from `map`
    /// @dev Resets all `key` fields to default values
    /// @param map The storage map
    /// @param key Key to remove
    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();

    }

    /// @notice Returns all `UserVote` as an array
    /// @dev Used by the consumer to get just the `UserVote` objects of all `keys` in `map`
    /// @param map The storage map
    /// @return array of `UserVote` objects
    function asArray(Map storage map) public view returns (UserVote[] memory) {
        UserVote[] memory result = new UserVote[](map.keys.length);

        for (uint256 index = 0; index < map.keys.length; index++) {
            result[index] = map.values[map.keys[index]];
        }
        return result;
    }

    /// @notice Returns all `keys`
    /// @dev Used by the consumer to get just the `users`  in `map`
    /// @param map The storage map
    /// @return array of `address` objects
    function keysAsArray(Map storage map) public view returns (address[] memory) {
        return map.keys;
    }
}

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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}