// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ContestBase.sol";
/**
*****************
TEMPLATE CONTRACT
*****************

Although this code is available for viewing on GitHub and here, the general public is NOT given a license to freely deploy smart contracts based on this code, on any blockchains.

To prevent confusion and increase trust in the audited code bases of smart contracts we produce, we intend for there to be only ONE official Factory address on the blockchain producing the corresponding smart contracts, and we are going to point a blockchain domain name at it.

Copyright (c) Intercoin Inc. All rights reserved.

ALLOWED USAGE.

Provided they agree to all the conditions of this Agreement listed below, anyone is welcome to interact with the official Factory Contract at the this address to produce smart contract instances, or to interact with instances produced in this manner by others.

Any user of software powered by this code MUST agree to the following, in order to use it. If you do not agree, refrain from using the software:

DISCLAIMERS AND DISCLOSURES.

Customer expressly recognizes that nearly any software may contain unforeseen bugs or other defects, due to the nature of software development. Moreover, because of the immutable nature of smart contracts, any such defects will persist in the software once it is deployed onto the blockchain. Customer therefore expressly acknowledges that any responsibility to obtain outside audits and analysis of any software produced by Developer rests solely with Customer.

Customer understands and acknowledges that the Software is being delivered as-is, and may contain potential defects. While Developer and its staff and partners have exercised care and best efforts in an attempt to produce solid, working software products, Developer EXPRESSLY DISCLAIMS MAKING ANY GUARANTEES, REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, ABOUT THE FITNESS OF THE SOFTWARE, INCLUDING LACK OF DEFECTS, MERCHANTABILITY OR SUITABILITY FOR A PARTICULAR PURPOSE.

Customer agrees that neither Developer nor any other party has made any representations or warranties, nor has the Customer relied on any representations or warranties, express or implied, including any implied warranty of merchantability or fitness for any particular purpose with respect to the Software. Customer acknowledges that no affirmation of fact or statement (whether written or oral) made by Developer, its representatives, or any other party outside of this Agreement with respect to the Software shall be deemed to create any express or implied warranty on the part of Developer or its representatives.

INDEMNIFICATION.

Customer agrees to indemnify, defend and hold Developer and its officers, directors, employees, agents and contractors harmless from any loss, cost, expense (including attorney’s fees and expenses), associated with or related to any demand, claim, liability, damages or cause of action of any kind or character (collectively referred to as “claim”), in any manner arising out of or relating to any third party demand, dispute, mediation, arbitration, litigation, or any violation or breach of any provision of this Agreement by Customer.

NO WARRANTY.

THE SOFTWARE IS PROVIDED “AS IS” WITHOUT WARRANTY. DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES FOR BREACH OF THE LIMITED WARRANTY. TO THE MAXIMUM EXTENT PERMITTED BY LAW, DEVELOPER EXPRESSLY DISCLAIMS, AND CUSTOMER EXPRESSLY WAIVES, ALL OTHER WARRANTIES, WHETHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR USE, OR ANY WARRANTY ARISING OUT OF ANY PROPOSAL, SPECIFICATION, OR SAMPLE, AS WELL AS ANY WARRANTIES THAT THE SOFTWARE (OR ANY ELEMENTS THEREOF) WILL ACHIEVE A PARTICULAR RESULT, OR WILL BE UNINTERRUPTED OR ERROR-FREE. THE TERM OF ANY IMPLIED WARRANTIES THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW SHALL BE LIMITED TO THE DURATION OF THE FOREGOING EXPRESS WARRANTY PERIOD. SOME STATES DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES AND/OR DO NOT ALLOW LIMITATIONS ON THE AMOUNT OF TIME AN IMPLIED WARRANTY LASTS, SO THE ABOVE LIMITATIONS MAY NOT APPLY TO CUSTOMER. THIS LIMITED WARRANTY GIVES CUSTOMER SPECIFIC LEGAL RIGHTS. CUSTOMER MAY HAVE OTHER RIGHTS WHICH VARY FROM STATE TO STATE. 

LIMITATION OF LIABILITY. 

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL DEVELOPER BE LIABLE UNDER ANY THEORY OF LIABILITY FOR ANY CONSEQUENTIAL, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR EXEMPLARY DAMAGES OF ANY KIND, INCLUDING, WITHOUT LIMITATION, DAMAGES ARISING FROM LOSS OF PROFITS, REVENUE, DATA OR USE, OR FROM INTERRUPTED COMMUNICATIONS OR DAMAGED DATA, OR FROM ANY DEFECT OR ERROR OR IN CONNECTION WITH CUSTOMER'S ACQUISITION OF SUBSTITUTE GOODS OR SERVICES OR MALFUNCTION OF THE SOFTWARE, OR ANY SUCH DAMAGES ARISING FROM BREACH OF CONTRACT OR WARRANTY OR FROM NEGLIGENCE OR STRICT LIABILITY, EVEN IF DEVELOPER OR ANY OTHER PERSON HAS BEEN ADVISED OR SHOULD KNOW OF THE POSSIBILITY OF SUCH DAMAGES, AND NOTWITHSTANDING THE FAILURE OF ANY REMEDY TO ACHIEVE ITS INTENDED PURPOSE. WITHOUT LIMITING THE FOREGOING OR ANY OTHER LIMITATION OF LIABILITY HEREIN, REGARDLESS OF THE FORM OF ACTION, WHETHER FOR BREACH OF CONTRACT, WARRANTY, NEGLIGENCE, STRICT LIABILITY IN TORT OR OTHERWISE, CUSTOMER'S EXCLUSIVE REMEDY AND THE TOTAL LIABILITY OF DEVELOPER OR ANY SUPPLIER OF SERVICES TO DEVELOPER FOR ANY CLAIMS ARISING IN ANY WAY IN CONNECTION WITH OR RELATED TO THIS AGREEMENT, THE SOFTWARE, FOR ANY CAUSE WHATSOEVER, SHALL NOT EXCEED 1,000 USD.

TRADEMARKS.

This Agreement does not grant you any right in any trademark or logo of Developer or its affiliates.

LINK REQUIREMENTS.

Operators of any Websites and Apps which make use of smart contracts based on this code must conspicuously include the following phrase in their website, featuring a clickable link that takes users to intercoin.app:

"Visit https://intercoin.app to launch your own NFTs, DAOs and other Web3 solutions."

STAKING OR SPENDING REQUIREMENTS.

In the future, Developer may begin requiring staking or spending of Intercoin tokens in order to take further actions (such as producing series and minting tokens). Any staking or spending requirements will first be announced on Developer's website (intercoin.org) four weeks in advance. Staking requirements will not apply to any actions already taken before they are put in place.

CUSTOM ARRANGEMENTS.

Reach out to us at intercoin.org if you are looking to obtain Intercoin tokens in bulk, remove link requirements forever, remove staking requirements forever, or get custom work done with your Web3 projects.

ENTIRE AGREEMENT

This Agreement contains the entire agreement and understanding among the parties hereto with respect to the subject matter hereof, and supersedes all prior and contemporaneous agreements, understandings, inducements and conditions, express or implied, oral or written, of any nature whatsoever with respect to the subject matter hereof. The express terms hereof control and supersede any course of performance and/or usage of the trade inconsistent with any of the terms hereof. Provisions from previous Agreements executed between Customer and Developer., which are not expressly dealt with in this Agreement, will remain in effect.

SUCCESSORS AND ASSIGNS

This Agreement shall continue to apply to any successors or assigns of either party, or any corporation or other entity acquiring all or substantially all the assets and business of either party whether by operation of law or otherwise.

ARBITRATION

All disputes related to this agreement shall be governed by and interpreted in accordance with the laws of New York, without regard to principles of conflict of laws. The parties to this agreement will submit all disputes arising under this agreement to arbitration in New York City, New York before a single arbitrator of the American Arbitration Association (“AAA”). The arbitrator shall be selected by application of the rules of the AAA, or by mutual agreement of the parties, except that such arbitrator shall be an attorney admitted to practice law New York. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section.
**/
contract ContestETHOnly is ContestBase {

    error SentEthDoesNotEqualWithAmount();
    /**
     * Recieved ether and transfer token to sender
     */
    receive() external payable {
        revert MethodDoesNotSupported(); // "Method does not support. Send ETH with pledgeETH() method"
    }
    
    /**
     * @param stagesCount count of stages for first Contest
     * @param stagesMinAmount array of minimum amount that need to reach at each stage
     * @param contestPeriodInSeconds duration in seconds  for contest period(exclude before reach minimum amount)
     * @param votePeriodInSeconds duration in seconds  for voting period
     * @param revokePeriodInSeconds duration in seconds  for revoking period
     * @param percentForWinners array of values in percentages of overall amount that will gain winners 
     * @param judges array of judges' addresses. if empty than everyone can vote
     * @param costManager address of costManager
     * @param producedBy who produсed contract address
     */
    function init(
        uint256 stagesCount,
        uint256[] memory stagesMinAmount,
        uint256 contestPeriodInSeconds,
        uint256 votePeriodInSeconds,
        uint256 revokePeriodInSeconds,
        uint256[] memory percentForWinners,
        address[] memory judges,
        address costManager,
        address producedBy
    ) 
        public 
        initializer 
    {
        __ContestBase__init(
            stagesCount,
            stagesMinAmount,
            contestPeriodInSeconds,
            votePeriodInSeconds,
            revokePeriodInSeconds,
            percentForWinners,
            judges,
            costManager
        );
        _accountForOperation(
            OPERATION_INITIALIZE_ETH_ONLY << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy)),
            0
        );
    }
    
    /**
     * pledge(amount) can be used to send external token into the contract, and issue internal token balance
     * @param amount amount
     * @param stageID Stage number
     */
    function pledgeETH(uint256 amount, uint256 stageID) public payable nonReentrant() {
        if (msg.value != amount) {
            revert SentEthDoesNotEqualWithAmount(); // "Sent ETH does not equal with amount"
        }
        
        _pledge(msg.value, stageID);
    }
    
    /**
     * @param amount amount
     */
    function revokeAfter(uint256 amount) internal virtual override nonReentrant() {
        // parameter "revokeFee" have already applied 
        address payable addr1 = payable(_msgSender()); // correct since Solidity >= 0.6.0
        bool success = addr1.send(amount);
        require(success == true, 'Transfer ether was failed'); 
    }
    
    /**
     * @param amount amount
     */
    function _claimAfter(uint256 amount) internal virtual override nonReentrant() {
        address payable addr1 = payable(_msgSender()); // correct since Solidity >= 0.6.0
        bool success = addr1.send(amount);
        require(success == true, 'Transfer ether was failed'); 
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@artman325/releasemanager/contracts/CostManagerHelperERC2771Support.sol";

contract ContestBase is Initializable, ReentrancyGuardUpgradeable, CostManagerHelperERC2771Support, OwnableUpgradeable {
    
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using SafeMathUpgradeable for uint256;

    // ** deprecated 
    // delegateFee (some constant in contract) which is percent of amount. They can delegate their entire amount of vote to the judge, or some.
    // uint256 delegateFee = 5e4; // 5% mul at 1e6
    
    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;
    uint8 internal constant OPERATION_INITIALIZE_ETH_ONLY = 0x1;
    uint8 internal constant OPERATION_CLAIM = 0x2;
    uint8 internal constant OPERATION_COMPLETE = 0x3;
    uint8 internal constant OPERATION_DELEGATE = 0x4;
    uint8 internal constant OPERATION_ENTER = 0x5;
    uint8 internal constant OPERATION_LEAVE = 0x6;
    uint8 internal constant OPERATION_VOTE = 0x7;
    uint8 internal constant OPERATION_PLEDGE = 0x8;
    uint8 internal constant OPERATION_REVOKE = 0x9;
    

    // penalty for revoke tokens
    uint256 public revokeFee; // 10% mul at 1e6
    
    EnumerableSetUpgradeable.AddressSet private _judgesWhitelist;
    EnumerableSetUpgradeable.AddressSet private _personsList;
    
    mapping (address => uint256) private _balances;
    
    Contest _contest;
    
    struct Contest {
        uint256 stage;
        uint256 stagesCount;
        mapping (uint256 => Stage) _stages;

    }
	
    struct Stage {
        uint256 winnerWeight;

        mapping (uint256 => address[]) winners;
        bool winnersLock;

        uint256 amount;     // acummulated all pledged 
        uint256 minAmount;
        
        bool active;    // stage will be active after riched minAmount
        bool completed; // true if stage already processed
        uint256 startTimestampUtc;
        uint256 contestPeriod; // in seconds
        uint256 votePeriod; // in seconds
        uint256 revokePeriod; // in seconds
        uint256 endTimestampUtc;
        EnumerableSetUpgradeable.AddressSet contestsList;
        EnumerableSetUpgradeable.AddressSet pledgesList;
        EnumerableSetUpgradeable.AddressSet judgesList;
        EnumerableSetUpgradeable.UintSet percentForWinners;
        mapping (address => Participant) participants;
    }
   
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single participant at single stage
    struct Participant {
        uint256 weight; // user weight
        uint256 balance; // user balance
        uint256 balanceAfter; // balance after calculate
        bool voted;  // if true, that person already voted
        address voteTo; // person voted to
        bool delegated;  // if true, that person delegated to some1
        address delegateTo; // person delegated to
        EnumerableSetUpgradeable.AddressSet delegatedBy; // participant who delegated own weight
        EnumerableSetUpgradeable.AddressSet votedBy; // participant who delegated own weight
        bool won;  // if true, that person won round. setup after EndOfStage
        bool claimed; // if true, that person claimed them prise if won ofc
        bool revoked; // if true, that person revoked from current stage
        //bool left; // if true, that person left from current stage and contestant list
        bool active; // always true

    }

	event ContestStart();
    event ContestComplete();
    event ContestWinnerAnnounced(address[] indexed winners);
    event StageStartAnnounced(uint256 indexed stageID);
    event StageCompleted(uint256 indexed stageID);
    
    error PersonMustHaveNotVotedOrDelegatedBefore(address account, uint256 stageID);
    error JudgeHaveBeenAlreadyDelegated(address account, uint256 stageID);
    error StageHaveStillInGatheringMode(uint256 stageID);
    error StageHaveNotCompletedYet(uint256 stageID);
    error StageIsOutOfContestPeriod(uint256 stageID);
    error StageIsOutOfVotingPeriod(uint256 stageID);
    error StageIsOutOfRevokeOrVotePeriod(uint256 stageID);
    error StageHaveNotCompletedOrSenderHasAlreadyClaimedOrRevoked(uint256 stageID);
    error MustBeInContestantList(uint256 stageID, address account);
    error MustNotBeInContestantList(uint256 stageID, address account);
    error MustBeInPledgesList(uint256 stageID, address account);
    error MustNotBeInPledgesList(uint256 stageID, address account);
    error MustBeInJudgesList(uint256 stageID, address account);
    error MustNotBeInJudgesList(uint256 stageID, address account);
    error MustBeInPledgesOrJudgesList(uint256 stageID, address account);
    error StageHaveNotEndedYet(uint256 stageID);
    error MethodDoesNotSupported();
    
	////
	// modifiers section
	////
// not (A or B) = (not A) and (not B)
// not (A and B) = (not A) or (not B)
    /**
     * @param account address
     * @param stageID Stage number
     */
    modifier onlyNotVotedNotDelegated(address account, uint256 stageID) {
        Participant storage participant = _contest._stages[stageID].participants[account];
        if (participant.voted || participant.delegated) {
            revert PersonMustHaveNotVotedOrDelegatedBefore(account, stageID);
        }
        _;
    }
    
    /**
     * @param account address
     * @param stageID Stage number
     */
    modifier judgeNotDelegatedBefore(address account, uint256 stageID) {
        Participant storage participant = _contest._stages[stageID].participants[account];
        if (participant.delegated) {
            revert JudgeHaveBeenAlreadyDelegated(account, stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier stageActive(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        if (stage.active) {
            revert StageHaveStillInGatheringMode(stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier stageNotCompleted(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        if (stage.completed) {
            revert StageHaveNotCompletedYet(stageID);
        }
        _;
    }

    /**
     * @param stageID Stage number
     */
    modifier canPledge(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        uint256 endContestTimestamp = (stage.startTimestampUtc).add(stage.contestPeriod);
        if ((stage.active == true) && (endContestTimestamp <= block.timestamp)) {
            revert StageIsOutOfContestPeriod(stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier canDelegateAndVote(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        uint256 endContestTimestamp = (stage.startTimestampUtc).add(stage.contestPeriod);
        uint256 endVoteTimestamp = endContestTimestamp.add(stage.votePeriod);
        if (
            (stage.active == false) ||
            (endVoteTimestamp <= block.timestamp) ||
            (block.timestamp < endContestTimestamp)
        ) {
            revert StageIsOutOfVotingPeriod(stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier canRevoke(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];

        uint256 endContestTimestamp = (stage.startTimestampUtc).add(stage.contestPeriod);
        uint256 endVoteTimestamp = (stage.startTimestampUtc).add(stage.contestPeriod).add(stage.votePeriod);
        uint256 endRevokeTimestamp = stage.endTimestampUtc;
        
        if (
            (stage.active == false) || 
            (endRevokeTimestamp <= block.timestamp) || 
            (block.timestamp < endContestTimestamp)
        ) {
            revert StageIsOutOfRevokeOrVotePeriod(stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier canClaim(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        address sender = _msgSender();
        uint256 endTimestampUtc = stage.endTimestampUtc;
        
        if (
            (stage.participants[_msgSender()].revoked) ||
            (stage.participants[_msgSender()].claimed) ||
            (stage.completed == false) && 
            (stage.active == false) && 
            (block.timestamp <= endTimestampUtc)
        ) {
            revert StageHaveNotCompletedOrSenderHasAlreadyClaimedOrRevoked(stageID);
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier inContestsList(uint256 stageID) {
        if (_contest._stages[stageID].contestsList.contains(_msgSender()) == false) {
            revert MustBeInContestantList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier notInContestsList(uint256 stageID) {
        if (_contest._stages[stageID].contestsList.contains(_msgSender())) {
            revert MustNotBeInContestantList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier inPledgesList(uint256 stageID) {
        if (_contest._stages[stageID].pledgesList.contains(_msgSender()) == false) {
            revert MustBeInPledgesList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier notInPledgesList(uint256 stageID) {
        if (_contest._stages[stageID].pledgesList.contains(_msgSender())) {
            revert MustNotBeInPledgesList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier inJudgesList(uint256 stageID) {
        if (_contest._stages[stageID].judgesList.contains(_msgSender()) == false) {
            revert MustBeInJudgesList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */
    modifier notInJudgesList(uint256 stageID) {
        if (_contest._stages[stageID].judgesList.contains(_msgSender())) {
            revert MustNotBeInJudgesList(stageID, _msgSender());
        }
        _;
    }
    
    /**
     * @param stageID Stage number
     */        
    modifier inPledgesOrJudgesList(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];

        if (
            stage.pledgesList.contains(_msgSender()) == false &&
            stage.judgesList.contains(_msgSender()) == false
        ) {
            revert MustBeInPledgesOrJudgesList(stageID, _msgSender());
        }
        _;
    }  
    
    /**
     * @param stageID Stage number
     */
    modifier canCompleted(uint256 stageID) {
        Stage storage stage = _contest._stages[stageID];
        if (
            (stage.completed == true) ||
            (stage.active == false) ||
            (stage.endTimestampUtc >= block.timestamp)
        ) {
            revert StageHaveNotEndedYet(stageID);
        }
        _;
    }
    ////
	// END of modifiers section 
	////
        
    //constructor() public {}
    
	/**
     * @param stagesCount count of stages for first Contest
     * @param stagesMinAmount array of minimum amount that need to reach at each stage
     * @param contestPeriodInSeconds duration in seconds  for contest period(exclude before reach minimum amount)
     * @param votePeriodInSeconds duration in seconds  for voting period
     * @param revokePeriodInSeconds duration in seconds  for revoking period
     * @param percentForWinners array of values in percentages of overall amount that will gain winners 
     * @param judges array of judges' addresses. if empty than everyone can vote
     * @param costManager address of costManager
     
     */
    function __ContestBase__init(
        uint256 stagesCount,
        uint256[] memory stagesMinAmount,
        uint256 contestPeriodInSeconds,
        uint256 votePeriodInSeconds,
        uint256 revokePeriodInSeconds,
        uint256[] memory percentForWinners,
        address[] memory judges,
        address costManager
    ) 
        internal 
        onlyInitializing 
    {
        __CostManagerHelper_init(_msgSender());
        _setCostManager(costManager);

        __Ownable_init();
        __ReentrancyGuard_init();
    
        revokeFee = 10e4;
        
        uint256 stage = 0;
        
        _contest.stage = 0;            
        for (stage = 0; stage < stagesCount; stage++) {
            _contest._stages[stage].minAmount = stagesMinAmount[stage];
            _contest._stages[stage].winnersLock = false;
            _contest._stages[stage].active = false;
            _contest._stages[stage].contestPeriod = contestPeriodInSeconds;
            _contest._stages[stage].votePeriod = votePeriodInSeconds;
            _contest._stages[stage].revokePeriod = revokePeriodInSeconds;
            
            for (uint256 i = 0; i < judges.length; i++) {
                _contest._stages[stage].judgesList.add(judges[i]);
            }
            
            for (uint256 i = 0; i < percentForWinners.length; i++) {
                _contest._stages[stage].percentForWinners.add(percentForWinners[i]);
            }
        }
        
        emit ContestStart();
        
        
    }

    ////
	// public section
	////
	/**
	 * @dev show contest state
	 * @param stageID Stage number
	 */
    function isContestOnline(uint256 stageID) public view returns (bool res){

        if (
            (_contest._stages[stageID].winnersLock == false) &&
            (
                (_contest._stages[stageID].active == false) ||
                ((_contest._stages[stageID].active == true) && (_contest._stages[stageID].endTimestampUtc > block.timestamp))
            ) && 
            (_contest._stages[stageID].completed == false)
        ) {
            res = true;
        } else {
            res = false;
        }
    }
    
    function getStageAmount( uint256 stageID) public view returns (uint256) {
        return _contest._stages[stageID].amount;
    }
    
    function getStageNumber() public view returns (uint256) {
        return _contest.stage;
    }

    /**
     * @param amount amount to pledge
	 * @param stageID Stage number
     */
    function pledge(uint256 amount, uint256 stageID) public virtual {
        _pledge(amount, stageID);
    }
    
    /**
     * @param judge address of judge which user want to delegate own vote
	 * @param stageID Stage number
     */
    function delegate(
        address judge, 
        uint256 stageID
    ) 
        public
        notInContestsList(stageID)
        stageNotCompleted(stageID)
        onlyNotVotedNotDelegated(_msgSender(), stageID)
        judgeNotDelegatedBefore(judge, stageID)
    {
        _delegate(judge, stageID);

        _accountForOperation(
            (OPERATION_DELEGATE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            uint256(uint160(judge))
        );
    }
    
    /** 
     * @param contestantAddress address of contestant which user want to vote
	 * @param stageID Stage number
     */     
    function vote(
        address contestantAddress,
        uint256 stageID
    ) 
        public 
        notInContestsList(stageID)
        onlyNotVotedNotDelegated(_msgSender(), stageID)  
        stageNotCompleted(stageID)
        canDelegateAndVote(stageID)
    {
        _vote(contestantAddress, stageID);
        
        _accountForOperation(
            (OPERATION_VOTE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            uint256(uint160(contestantAddress))
        );
    }
    
    /**
     * @param stageID Stage number
     */
    function claim(
        uint256 stageID
    )
        public
        inContestsList(stageID)
        canClaim(stageID)
    {
        _contest._stages[stageID].participants[_msgSender()].claimed = true;
        uint prizeAmount = _contest._stages[stageID].participants[_msgSender()].balanceAfter;
        _claimAfter(prizeAmount);

        
        _accountForOperation(
            (OPERATION_CLAIM << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
     */
    function enter(
        uint256 stageID
    ) 
        notInContestsList(stageID) 
        notInPledgesList(stageID) 
        notInJudgesList(stageID) 

        public 
    {
        _enter(stageID);
        
        _accountForOperation(
            (OPERATION_ENTER << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
     */   
    function leave(
        uint256 stageID
    ) 
        public 
    {
        _leave(stageID);

        _accountForOperation(
            (OPERATION_LEAVE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
     */
    function revoke(
        uint256 stageID
    ) 
        public
        notInContestsList(stageID)
        stageNotCompleted(stageID)
        canRevoke(stageID)
    {
        
        _revoke(stageID);
        
        _contest._stages[stageID].participants[_msgSender()].revoked == true;
            
        uint revokedBalance = _contest._stages[stageID].participants[_msgSender()].balance;
        _contest._stages[stageID].amount = _contest._stages[stageID].amount.sub(revokedBalance);
        revokeAfter(revokedBalance.sub(revokedBalance.mul(_calculateRevokeFee(stageID)).div(1e6)));
        
        _accountForOperation(
            (OPERATION_REVOKE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    } 

    ////
	// internal section
	////
	
	/**
	 * calculation revokeFee penalty.  it gradually increased if revoke happens in voting period
	 * @param stageID Stage number
	 */
	function _calculateRevokeFee(
	    uint256 stageID
    )
        internal 
        view
        returns(uint256)
    {
        uint256 endContestTimestamp = (_contest._stages[stageID].startTimestampUtc).add(_contest._stages[stageID].contestPeriod);
        uint256 endVoteTimestamp = (_contest._stages[stageID].startTimestampUtc).add(_contest._stages[stageID].contestPeriod).add(_contest._stages[stageID].votePeriod);
        
        if ((endVoteTimestamp > block.timestamp) && (block.timestamp >= endContestTimestamp)) {
            uint256 revokeFeePerSecond = (revokeFee).div(endVoteTimestamp.sub(endContestTimestamp));
            return revokeFeePerSecond.mul(block.timestamp.sub(endContestTimestamp));
            
        } else {
            return revokeFee;
        }
        
    }
	
	/**
     * @param judge address of judge which user want to delegate own vote
     * @param stageID Stage number
     */
    function _delegate(
        address judge, 
        uint256 stageID
    ) 
        internal 
        canDelegateAndVote(stageID)
    {
        Stage storage stage = _contest._stages[stageID];
        // code left for possibility re-delegate
        // if (_contests[contestID]._stages[stageID].participants[_msgSender()].delegated == true) {
        //     _revoke(stageID);
        // }
        stage.participants[_msgSender()].delegated = true;
        stage.participants[_msgSender()].delegateTo = judge;
        stage.participants[judge].delegatedBy.add(_msgSender());
    }
    
    /** 
     * @param contestantAddress address of contestant which user want to vote
	 * @param stageID Stage number
     */ 
    function _vote(
        address contestantAddress,
        uint256 stageID
    ) 
        internal
    {
        Stage storage stage = _contest._stages[stageID];
        if (stage.contestsList.contains(contestantAddress) == false) {
            revert MustBeInContestantList(stageID, contestantAddress);
        }
     
        // code left for possibility re-vote
        // if (_contests[contestID]._stages[stageID].participants[_msgSender()].voted == true) {
        //     _revoke(stageID);
        // }
        //----
        
        stage.participants[_msgSender()].voted = true;
        stage.participants[_msgSender()].voteTo = contestantAddress;
        stage.participants[contestantAddress].votedBy.add(_msgSender());
    }
    
    /**
     * @param amount amount 
     */
    function _claimAfter(uint256 amount) internal virtual { }
    
    /**
     * @param amount amount 
     */
    function revokeAfter(uint256 amount) internal virtual {}
    
    /** 
	 * @param stageID Stage number
     */ 
    function _revoke(
        uint256 stageID
    ) 
        private
    {
        address addr;
        if (_contest._stages[stageID].participants[_msgSender()].voted == true) {
            addr = _contest._stages[stageID].participants[_msgSender()].voteTo;
            _contest._stages[stageID].participants[addr].votedBy.remove(_msgSender());
        } else if (_contest._stages[stageID].participants[_msgSender()].delegated == true) {
            addr = _contest._stages[stageID].participants[_msgSender()].delegateTo;
            _contest._stages[stageID].participants[addr].delegatedBy.remove(_msgSender());
        } else {
            
        }
    }
    
    /**
     * @dev This method triggers the complete(stage), if it hasn't successfully been triggered yet in the contract. 
     * The complete(stage) method works like this: if stageBlockNumber[N] has not passed yet then reject. Otherwise it wraps up the stage as follows, and then increments 'stage':
     * @param stageID Stage number
     */
    function complete(uint256 stageID) public onlyOwner canCompleted(stageID) {
       _complete(stageID);
    }
  
	/**
	 * @dev need to be used after each pledge/enter
     * @param stageID Stage number
	 */
	function _turnStageToActive(uint256 stageID) internal {
	    
        if (
            (_contest._stages[stageID].active == false) && 
            (_contest._stages[stageID].amount >= _contest._stages[stageID].minAmount)
        ) {
            _contest._stages[stageID].active = true;
            // fill time
            _contest._stages[stageID].startTimestampUtc = block.timestamp;
            _contest._stages[stageID].endTimestampUtc = (block.timestamp)
                .add(_contest._stages[stageID].contestPeriod)
                .add(_contest._stages[stageID].votePeriod)
                .add(_contest._stages[stageID].revokePeriod);
            emit StageStartAnnounced(stageID);
        } else if (
            (_contest._stages[stageID].active == true) && 
            (_contest._stages[stageID].endTimestampUtc < block.timestamp)
        ) {
            // run complete
	        _complete(stageID);
	    } else {
            
        }
        
	}
	
	/**
	 * @dev logic for ending stage (calculate weights, pick winners, reward losers, turn to next stage)
     * @param stageID Stage number
	 */
	function _complete(uint256 stageID) internal  {
	    emit StageCompleted(stageID);

	    _calculateWeights(stageID);
	    uint256 percentWinnersLeft = _rewardWinners(stageID);
	    _rewardLosers(stageID, percentWinnersLeft);
	 
	    //mark stage completed
	    _contest._stages[stageID].completed = true;
	    
	    // switch to next stage
	    if (_contest.stagesCount == stageID.add(1)) {
            // just complete if last stage 
            
            emit ContestComplete();
        } else {
            // increment stage
            _contest.stage = (_contest.stage).add(1);
        }
        _accountForOperation(
            (OPERATION_COMPLETE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
	}
	
	/**
	 * @param amount amount
     * @param stageID Stage number
	 */
    function _pledge(
        uint256 amount, 
        uint256 stageID
    ) 
        internal 
        canPledge(stageID) 
        notInContestsList(stageID) 
    {
        _createParticipant(stageID);
        
        _contest._stages[stageID].pledgesList.add(_msgSender());
        
        // accumalate balance in current stage
        _contest._stages[stageID].participants[_msgSender()].balance = (
            _contest._stages[stageID].participants[_msgSender()].balance
            ).add(amount);
            
        // accumalate overall stage balance
        _contest._stages[stageID].amount = (
            _contest._stages[stageID].amount
            ).add(amount);
        
        _turnStageToActive(stageID);

        _accountForOperation(
            (OPERATION_PLEDGE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
	 */
    function _enter(
        uint256 stageID
    ) 
        internal 
        notInContestsList(stageID) 
        notInPledgesList(stageID) 
        notInJudgesList(stageID) 
    {
        _turnStageToActive(stageID);
        _createParticipant(stageID);
        _contest._stages[stageID].contestsList.add(_msgSender());

        _accountForOperation(
            (OPERATION_ENTER << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
	 */
    function _leave(
        uint256 stageID
    ) 
        internal 
        inContestsList(stageID) 
    {
        _contest._stages[stageID].contestsList.remove(_msgSender());
        _contest._stages[stageID].participants[msg.sender].active = false;

        _accountForOperation(
            (OPERATION_LEAVE << OPERATION_SHIFT_BITS) | stageID,
            uint256(uint160(_msgSender())),
            0
        );
    }
    
    /**
     * @param stageID Stage number
	 */     
    function _createParticipant(uint256 stageID) internal {
        if (_contest._stages[stageID].participants[_msgSender()].active) {
             // ---
        } else {
            //Participant memory p;
            //_contest._stages[stageID].participants[_msgSender()] = p;
            _contest._stages[stageID].participants[_msgSender()].active = true;
        }
    }

    function _msgSender(
    ) 
        internal 
        view 
        virtual
        override(TrustedForwarder, ContextUpgradeable)
        returns (address signer) 
    {
        return TrustedForwarder._msgSender();
        
    }
error ForwarderCanNotBeOwner();
error DeniedForForwarder();
    function setTrustedForwarder(
        address forwarder
    ) 
        public 
        virtual
        override
        onlyOwner 
    {
        if (owner() == forwarder) {
            revert ForwarderCanNotBeOwner();
        }
        _setTrustedForwarder(forwarder);
    }

    function transferOwnership(
        address newOwner
    ) public 
        virtual 
        override 
        onlyOwner 
    {
        if (_isTrustedForwarder(msg.sender)) {
            revert DeniedForForwarder();
        }
        if (_isTrustedForwarder(newOwner)) {
            _setTrustedForwarder(address(0));
        }
        super.transferOwnership(newOwner);
        
    }

    
	////
	// private section
	////
	
	/**
     * @param stageID Stage number
	 */
	function _calculateWeights(uint256 stageID) private {
	       
        // loop via contestsList 
        // find it in participant 
        //     loop via votedBy
        //         in each calculate weight
        //             if delegatedBy empty  -- sum him balance only
        //             if delegatedBy not empty -- sum weight inside all who delegated
        // make array of winners
        // set balanceAfter
	    
	    address addrContestant;
	    address addrVotestant;
	    address addrWhoDelegated;
	    
	    for (uint256 i = 0; i < _contest._stages[stageID].contestsList.length(); i++) {
	        addrContestant = _contest._stages[stageID].contestsList.at(i);
	        for (uint256 j = 0; j < _contest._stages[stageID].participants[addrContestant].votedBy.length(); j++) {
	            addrVotestant = _contest._stages[stageID].participants[addrContestant].votedBy.at(j);
	            
                // sum votes
                _contest._stages[stageID].participants[addrContestant].weight = 
                _contest._stages[stageID].participants[addrContestant].weight.add(
                    _contest._stages[stageID].participants[addrVotestant].balance
                );
                
                // sum all delegated if exists
                for (uint256 k = 0; k < _contest._stages[stageID].participants[addrVotestant].delegatedBy.length(); k++) {
                    addrWhoDelegated = _contest._stages[stageID].participants[addrVotestant].delegatedBy.at(k);
                    _contest._stages[stageID].participants[addrContestant].weight = 
	                _contest._stages[stageID].participants[addrContestant].weight.add(
	                    _contest._stages[stageID].participants[addrWhoDelegated].balance
	                );
                }
	             
	        }
	        
	    }
	}
	
	/**
     * @param stageID Stage number
	 * @return percentLeft percents left if count of winners more that prizes. in that cases left percent distributed to losers
	 */
	function _rewardWinners(uint256 stageID) private returns(uint256 percentLeft)  {
	    
        uint256 indexPrize = 0;
	    address addrContestant;
	    
	    uint256 lenContestList = _contest._stages[stageID].contestsList.length();
	    if (lenContestList>0)  {
	    
    	    uint256[] memory weight = new uint256[](lenContestList);
    
    	    for (uint256 i = 0; i < lenContestList; i++) {
    	        addrContestant = _contest._stages[stageID].contestsList.at(i);
                weight[i] = _contest._stages[stageID].participants[addrContestant].weight;
    	    }
    	    weight = sortAsc(weight);
    
            // dev Note: 
            // the original implementation is an infinite loop. When. i is 0 the loop decrements it again, 
            // but since it's an unsigned integer it undeflows and loops back to the maximum uint 
            // so use  "for (uint i = a.length; i > 0; i--)" and in code "a[i-1]" 
    	    for (uint256 i = weight.length; i > 0; i--) {
    	       for (uint256 j = 0; j < lenContestList; j++) {
    	            addrContestant = _contest._stages[stageID].contestsList.at(j);
    	            if (
    	                (weight[i-1] > 0) &&
    	                (_contest._stages[stageID].participants[addrContestant].weight == weight[i-1]) &&
    	                (_contest._stages[stageID].participants[addrContestant].won == false) &&
    	                (_contest._stages[stageID].participants[addrContestant].active == true) &&
    	                (_contest._stages[stageID].participants[addrContestant].revoked == false)
    	            ) {
    	                 
    	                _contest._stages[stageID].participants[addrContestant].balanceAfter = (_contest._stages[stageID].amount)
    	                    .mul(_contest._stages[stageID].percentForWinners.at(indexPrize))
    	                    .div(100);
                    
                        _contest._stages[stageID].participants[addrContestant].won = true;
                        
                        indexPrize++;
                        break;
    	            }
    	        }
    	        if (indexPrize >= _contest._stages[stageID].percentForWinners.length()) {
    	            break;
    	        }
    	    }
	    }
	    
	    percentLeft = 0;
	    if (indexPrize < _contest._stages[stageID].percentForWinners.length()) {
	       for (uint256 i = indexPrize; i < _contest._stages[stageID].percentForWinners.length(); i++) {
	           percentLeft = percentLeft.add(_contest._stages[stageID].percentForWinners.at(i));
	       }
	    }
	    return percentLeft;
	}
	
    /**
     * @param stageID Stage number
	 * @param prizeWinLeftPercent percents left if count of winners more that prizes. in that cases left percent distributed to losers
	 */
	function _rewardLosers(uint256 stageID, uint256 prizeWinLeftPercent) private {
	    // calculate left percent
	    // calculate howmuch participant loose
	    // calculate and apply left weight
	    address addrContestant;
	    uint256 leftPercent = 100;
	    
	    uint256 prizecount = _contest._stages[stageID].percentForWinners.length();
	    for (uint256 i = 0; i < prizecount; i++) {
	        leftPercent = leftPercent.sub(_contest._stages[stageID].percentForWinners.at(i));
	    }

	    leftPercent = leftPercent.add(prizeWinLeftPercent); 
	    
	    uint256 loserParticipants = 0;
	    if (leftPercent > 0) {
	        for (uint256 j = 0; j < _contest._stages[stageID].contestsList.length(); j++) {
	            addrContestant = _contest._stages[stageID].contestsList.at(j);
	            
	            if (
	                (_contest._stages[stageID].participants[addrContestant].won == false) &&
	                (_contest._stages[stageID].participants[addrContestant].active == true) &&
	                (_contest._stages[stageID].participants[addrContestant].revoked == false)
	            ) {
	                loserParticipants++;
	            }
	        }

	        if (loserParticipants > 0) {
	            uint256 rewardLoser = (_contest._stages[stageID].amount).mul(leftPercent).div(100).div(loserParticipants);
	            
	            for (uint256 j = 0; j < _contest._stages[stageID].contestsList.length(); j++) {
    	            addrContestant = _contest._stages[stageID].contestsList.at(j);
    	            
    	            if (
    	                (_contest._stages[stageID].participants[addrContestant].won == false) &&
    	                (_contest._stages[stageID].participants[addrContestant].active == true) &&
    	                (_contest._stages[stageID].participants[addrContestant].revoked == false)
    	            ) {
    	                _contest._stages[stageID].participants[addrContestant].balanceAfter = rewardLoser;
    	            }
    	        }
	        }
	    }
	}
    
    // useful method to sort native memory array 
    function sortAsc(uint256[] memory data) private returns(uint[] memory) {
       quickSortAsc(data, int(0), int(data.length - 1));
       return data;
    }
    
    function quickSortAsc(uint[] memory arr, int left, int right) private {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortAsc(arr, left, j);
        if (i < right)
            quickSortAsc(arr, i, right);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICostManager.sol";
import "./interfaces/ICostManagerFactoryHelper.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "@artman325/trustedforwarder/contracts/TrustedForwarder.sol";

/**
* used for instances that have created(cloned) by factory.
*/
abstract contract CostManagerHelperERC2771Support is TrustedForwarder {
    using AddressUpgradeable for address;

    address public costManager;
    address internal factory;

    /** 
    * @dev sets the costmanager token
    * @param costManager_ new address of costmanager token, or 0
    */
    function overrideCostManager(address costManager_) external {
        // require factory owner or operator
        // otherwise needed deployer(!!not contract owner) in cases if was deployed manually
        require (
            (factory.isContract()) 
                ?
                    ICostManagerFactoryHelper(factory).canOverrideCostManager(_msgSender(), address(this))
                :
                    factory == _msgSender()
            ,
            "cannot override"
        );
        
        _setCostManager(costManager_);
    }

    function __CostManagerHelper_init(address factory_) internal onlyInitializing
    {
        factory = factory_;
    }

     /**
     * @dev Private function that tells contract to account for an operation
     * @param info uint256 The operation ID (first 8 bits). in other bits any else info
     * @param param1 uint256 Some more information, if any
     * @param param2 uint256 Some more information, if any
     */
    function _accountForOperation(uint256 info, uint256 param1, uint256 param2) internal {
        if (costManager != address(0)) {
            try ICostManager(costManager).accountForOperation(
                msg.sender, info, param1, param2
            )
            returns (uint256 /*spent*/, uint256 /*remaining*/) {
                // if error is not thrown, we are fine
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
                revert(reason);
            } catch {
                revert("unknown error");
            }
        }
    }
    
    function _setCostManager(address costManager_) internal {
        costManager = costManager_;
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract TrustedForwarder is Initializable {

    address private _trustedForwarder;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __TrustedForwarder_init() internal onlyInitializing {
        _trustedForwarder = address(0);
    }


    /**
    * @dev setup trusted forwarder address
    * @param forwarder trustedforwarder's address to set
    * @custom:shortd setup trusted forwarder
    * @custom:calledby owner
    */
    function _setTrustedForwarder(
        address forwarder
    ) 
        internal 
      //  onlyOwner 
        //excludeTrustedForwarder 
    {
        //require(owner() != forwarder, "FORWARDER_CAN_NOT_BE_OWNER");
        _trustedForwarder = forwarder;
    }
    function setTrustedForwarder(address forwarder) public virtual;
    /**
    * @dev checking if forwarder is trusted
    * @param forwarder trustedforwarder's address to check
    * @custom:shortd checking if forwarder is trusted
    */
    function isTrustedForwarder(
        address forwarder
    ) 
        external
        view 
        returns(bool) 
    {
        return _isTrustedForwarder(forwarder);
    }

    /**
    * @dev implemented EIP-2771
    */
    function _msgSender(
    ) 
        internal 
        view 
        virtual
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length>=20 && _isTrustedForwarder(signer)) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }

    // function transferOwnership(
    //     address newOwner
    // ) public 
    //     virtual 
    //     override 
    //     onlyOwner 
    // {
    //     require(msg.sender != _trustedForwarder, "DENIED_FOR_FORWARDER");
    //     if (newOwner == _trustedForwarder) {
    //         _trustedForwarder = address(0);
    //     }
    //     super.transferOwnership(newOwner);
        
    // }

    function _isTrustedForwarder(
        address forwarder
    ) 
        internal
        view 
        returns(bool) 
    {
        return forwarder == _trustedForwarder;
    }


  

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ICostManager/* is IERC165Upgradeable*/ {
    function accountForOperation(
        address sender, 
        uint256 info, 
        uint256 param1, 
        uint256 param2
    ) 
        external 
        returns(uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICostManagerFactoryHelper {
    
    function canOverrideCostManager(address account, address instance) external view returns (bool);
}