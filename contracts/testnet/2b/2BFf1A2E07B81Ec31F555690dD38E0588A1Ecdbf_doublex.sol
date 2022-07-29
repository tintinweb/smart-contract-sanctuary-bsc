/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT


/************
*
*  DOUBLEX
*
************/


contract doublex {
    uint public launchTime;
    uint public currentRound;
    address public creator;
    uint public activationFee;
    uint public devFee;
    uint public ticketPrice;
    // The value that triggers the prize pool to count down
    uint public amountToStartCountDown;
    // Count down timer cannot exceed this value
    uint public maxCountDown;
    // The timestamp added to the count down every time an user buys a ticket
    uint public extraTime;
    uint public newRoundStartTime;

    // Every 3 times an user recieve commission, the fourth time goes to his/ her referrer. 
    // After that, his/ her rotation is set to 0 again.
    mapping( address => uint ) public commissionRotation;

    uint public userCount;

    mapping( address => address ) public userReferrer;
    mapping( uint => address ) public referrerIdToAddress;
    mapping( address => uint ) public addressToReferrerID;
    mapping( address => uint ) public helpEarned;
    mapping( address => uint ) public directCommission;
    mapping( address => uint ) public indirectCommission;
    mapping( address => uint ) public missedCommission;
    mapping( address => uint ) public prizePoolEarned;


    // Time joined
    mapping( address => uint ) public userTimeJoined;
    // Friends count
    mapping( address => uint ) public friendsCount;
    // Partner can enjoy the benefit of receiving commission without any ticket
    mapping( address => bool ) public isPartner;
    // The number of friends invited to become a partner
    uint public partnerRequirement;

    uint defaultHelpLimitTimes = 2;

    struct Ticket {
        // ticket id starts from 0
        uint id;
        address buyer;
        uint helpEarned;
        // Either the help goal or the commission goal is reached,
        // this ticket becomes used.
        uint helpGoal;
        uint timePurchased;
    }

    struct Round {
        // round id starts from 1
        uint roundId;
        uint prizePool;
        bool prizePaid;
        uint startTime;
        uint endingTime;
    }


    Round[] public rounds;

    // RoundId => tickets;
    mapping( uint => Ticket[] ) public purchasedTickets;


    // unusedTicketCount[ roundId ][ user ]
    mapping( uint => mapping (address => uint) ) public unusedTicketCount;

    // beneficiaryTicketIndex
    // roundId => beneficiaryTicketIndex
    mapping( uint => uint ) public beneficiaryTicketIndex;

    // userTicketsCount
    // roundId, address => count 
    mapping( uint => mapping ( address => uint ) ) public userTicketsCount;

    constructor() {
        creator = msg.sender;
        isPartner[creator] = true;
        userCount += 1;
        currentRound = 1;
        userReferrer[ creator ] = creator;
        referrerIdToAddress[ 1 ] = creator;
        addressToReferrerID[ creator ] = 1;
        userTimeJoined[ creator ] = block.timestamp;

        rounds.push(Round({
            roundId: currentRound,
            prizePool: 0,
            prizePaid: false,
            startTime: launchTime,
            endingTime: 0
        }));

        purchasedTickets[ currentRound ].push(Ticket({
            id: 0,
            buyer: creator,
            helpEarned: 0,
            helpGoal: ticketPrice * defaultHelpLimitTimes,
            timePurchased: launchTime
        }));

        unusedTicketCount[ currentRound ][ creator ] += 1;
        userTicketsCount[ currentRound ][ creator ] += 1;
    }


    function accountActivation( address _user, uint _referrerId ) public payable returns( uint referrerID ) {
        require( !isActivated( _user ), "You are already activated." );
        address referrer = referrerIdToAddress[ _referrerId ];
        require( referrer != address(0x0), "Referrer doesn't exist." );
        require( msg.value == activationFee, "Wrong value." );
        
        if ( activationFee > 0 ) {
            // send dev fee to the creator
            payable( creator ).transfer( msg.value );
        }
        
        userCount += 1;
        userReferrer[ _user ] = referrer;
        friendsCount[ referrer ] += 1;
        referrerIdToAddress[ userCount ] = _user;
        addressToReferrerID[ _user ] = userCount;
        userTimeJoined[_user] = block.timestamp;

        if ( isPartner[ referrer ] == false && friendsCount[ referrer ] >= partnerRequirement ) {
            isPartner[ referrer ] = true;
        }

        return addressToReferrerID[_user];
    }

 
    function buyTicket() public payable returns( Ticket memory ) {
        require( msg.sender != creator, "Creator can't play this game." );
        // Check whether this user is activated
        require( isActivated( msg.sender ), "You are not activated." );
        // Check whether the value is correct
        require( msg.value == ticketPrice, "Wrong value" );
        // check whether this round is ended
        require( roundIsEnded( currentRound ) == false, "This round is ended. Waiting for a new round to start." );
        // Check whether a round is started
        require( roundIsStarted( currentRound ) == true, "This round is not started yet." );

        uint helpAmount = ticketPrice / 3 * 2;
        uint commissionAmount = ticketPrice / 3 / 2;
        uint amountGoesToPrizePool = ticketPrice - helpAmount - commissionAmount;
        
        commissionAmount = commissionAmount - devFee;

        // ↓ ---------------- Record purchasing ------------------ ↓
        // Check whether this buyer has 3x opportunity
        // If yes, 3x the helpGoal
        uint _goal = defaultHelpLimitTimes * ticketPrice;
        if ( threeXOpportunity( msg.sender ) > 0 ) {
            _goal = ticketPrice * 3;
        }

        Ticket memory _ticket = Ticket({
            id: purchasedTickets[currentRound].length,
            buyer: msg.sender,
            helpEarned: 0,
            helpGoal: _goal,
            timePurchased: block.timestamp
        });
        purchasedTickets[ currentRound ].push(_ticket);

        unusedTicketCount[ currentRound ][ msg.sender ] += 1;
        userTicketsCount[ currentRound ][ msg.sender ] += 1;
        // ↑ ---------------- Record purchasing ------------------ ↑


        // ↓ ---------------- Beneficiary ------------------ ↓
        uint _beneficiaryTicketIndex = beneficiaryTicketIndex[ currentRound ];
        address beneficiary = purchasedTickets[ currentRound ][_beneficiaryTicketIndex].buyer;
        uint _helpGoal = purchasedTickets[currentRound][_beneficiaryTicketIndex].helpGoal;
        uint _helpEarned = purchasedTickets[currentRound][_beneficiaryTicketIndex].helpEarned;

        // Add the extra help to prize pool
        if ( (_helpEarned + helpAmount) > _helpGoal ) {
            uint difference = (_helpEarned + helpAmount) - _helpGoal;
            helpAmount -= difference;
            amountGoesToPrizePool += difference;
        }

        helpEarned[ beneficiary ] += helpAmount;
        purchasedTickets[currentRound][_beneficiaryTicketIndex].helpEarned += helpAmount;

        // Check whether the beneficiary has reached the goal
        if( reachedHelpGoal( currentRound,  _beneficiaryTicketIndex )) {
            beneficiaryTicketIndex[ currentRound ] += 1;
            unusedTicketCount[ currentRound ][ beneficiary ] -= 1;
        }
        // ↑ ---------------- Beneficiary ------------------ ↑

        // ↓ ---------------- Prize Pool ------------------ ↓
        // Add to the prize pool
        rounds[ currentRound - 1 ].prizePool += amountGoesToPrizePool;

        // Check if the prize pool reaches the required amount for starting the countdown
        uint _endingTime = rounds[ currentRound - 1 ].endingTime;
        uint _prizePool = rounds[ currentRound -1 ].prizePool;
        // If the ending time is 0, the countdown is not started yet
        if ( _endingTime == 0 && _prizePool >= amountToStartCountDown ) {
            rounds[ currentRound - 1 ].endingTime = block.timestamp + maxCountDown;
        }
        // If the ending time is greater than 0, the count down is started already,
        if ( _endingTime > 0 ) {
            uint newEndingTime = _endingTime + extraTime;
            // New ending time cannot exceed the max count down
            uint _max = block.timestamp + maxCountDown;
            if ( newEndingTime > _max ) {
                newEndingTime = _max;
            }
            rounds[ currentRound - 1 ].endingTime = newEndingTime;

        }
        // ↑ ---------------- Prize Pool ------------------ ↑


        // ↓ ---------------- Referrer ------------------ ↓
        address referrer = userReferrer[ msg.sender ];
        bool isDirectCommission = true;

        while( true ) {
            if ( referrer == creator ) {
                break;
            }
            // is partner?
            if ( isPartner[ referrer ] ) {
                // If the referrer is a partner, 
                // check whether he/she has recieved commission for 3 times
                if( commissionRotation[ referrer ] >= 3 ) {
                    commissionRotation[ referrer ] = 0;
                    referrer = userReferrer[ referrer ];
                    isDirectCommission = false;
                } else {
                    break;
                }
            } else {
                // If the referrer is not a partner, 
                // check whether he/she has available tickets
                if ( unusedTicketCount[ currentRound ][ referrer ] > 0 ) {
                    // check commission rotation
                    if( commissionRotation[ referrer ] >= 3 ) {
                        commissionRotation[ referrer ] = 0;
                        referrer = userReferrer[ referrer ];
                        isDirectCommission = false;
                    } else {
                        break;
                    }
                } else {
                    missedCommission[ referrer ] += commissionAmount;
                    referrer = userReferrer[ referrer ];
                    isDirectCommission = false;
                }
            }
        }
        

        if ( referrer != creator ) {
            commissionRotation[ referrer ] += 1;
        }

        if( isDirectCommission ) {
            directCommission[ referrer ] += commissionAmount;
        } else {
            indirectCommission[ referrer ] += commissionAmount;
        }
        // ↑ ---------------- Referrer ------------------ ↑

        payable( beneficiary ).transfer( helpAmount );
        payable( referrer ).transfer( commissionAmount );
        payable( creator ).transfer( devFee );

        return _ticket;
    }


    function threeXOpportunity( address _user ) public view returns (uint) {
        uint _previousUnusedTickets = unusedTicketCount[ currentRound - 1 ][ _user ];
        uint _purchasedTicketsCount = userTicketsCount[ currentRound ][ _user ];

        if ( _previousUnusedTickets > _purchasedTicketsCount ) {
            return _previousUnusedTickets - _purchasedTicketsCount;
        } else {
            return 0;
        }
    }


    // check whether help goal is reached
    function reachedHelpGoal( uint _roundId, uint _ticketIndex ) view public returns( bool ) {
        bool reached = false;
        if( purchasedTickets[ _roundId ][_ticketIndex].helpGoal <= purchasedTickets[ _roundId ][_ticketIndex].helpEarned ){
            reached = true;
        }
        return reached;
    }


    // get user's first available ticket index
    function getUserFirstAvailableTicketIndex( address _user ) view public returns( uint ) {
        require( unusedTicketCount[ currentRound ][ _user ] > 0, "No available ticket." );

        uint index = 0;
        for( uint i = 0; i < purchasedTickets[ currentRound ].length; i ++ ) { 
            if( reachedHelpGoal( currentRound, i) == false && purchasedTickets[currentRound][i].buyer == _user ) {
                index = i;
                break;
            }
        }
        return index;
    }


    // Check whether an user is activated
    function isActivated( address _user ) public view returns( bool ) {
        bool activated = false;
        if( userReferrer[ _user ] != address(0x0) ) {
            activated = true;
        }

        return activated;
    }


    function getTotalEarnings(address _user) public view returns (uint) {
        uint help = helpEarned[ _user ];
        uint direct = directCommission[ _user];
        uint indirect = indirectCommission[ _user ];
        uint prize = prizePoolEarned[ _user ];
        uint total = help + direct + indirect + prize;

        return total;
    }


    // Check whether a round is ended
    function roundIsEnded( uint _roundId ) view public returns( bool ) {
        require( _roundId > 0, "Invalid value." );
        require( _roundId <= rounds.length, "Not started yet." );
        uint timeEnded = rounds[ _roundId - 1 ].endingTime;
        bool isEnded = false;
        if( timeEnded != 0 && timeEnded <= block.timestamp ) {
            isEnded = true;
        } 

        return isEnded;
    }


    // Check whether a round is started
    function roundIsStarted( uint _roundId ) view public returns( bool ) {
        require( _roundId > 0, "Invalid value." );
        require( _roundId <= rounds.length, "Not started yet." );
        uint timeStarted = rounds[ _roundId - 1 ].startTime;
        bool isStarted = false;
        if ( timeStarted <= block.timestamp ) {
            isStarted = true;
        }
        return isStarted;
    }


    // Start a new round
    function startANewRound() public payable returns(Round memory) {
        require( roundIsEnded( currentRound ) == true, "The current round is not over yet." );
        require( isActivated( msg.sender ), "You are not activated." );
        uint endingRound = currentRound;
        currentRound += 1;

        // Push a new round
        uint _startTime = block.timestamp + newRoundStartTime;
        Round memory _round = Round({
            roundId: currentRound,
            prizePool: 0,
            prizePaid: false,
            startTime: _startTime,
            endingTime: 0
        });
        rounds.push(_round);

        // Pay out the prize
        if( rounds[ endingRound - 1 ].prizePaid == false ) {
            uint prize = rounds[ endingRound-1 ].prizePool;
            address _lastTicketBuyer = getLastTicketBuyer(endingRound);
            prizePoolEarned[ _lastTicketBuyer ] += prize;
            rounds[ endingRound - 1 ].prizePaid = true;
            payable( _lastTicketBuyer ).transfer( prize );
        }


        // Free ticket for whomever starts this round
        purchasedTickets[currentRound].push(Ticket({
            id: soldTicketsCount(currentRound),
            buyer: msg.sender,
            helpEarned: 0,
            helpGoal: ticketPrice * defaultHelpLimitTimes,
            timePurchased: _startTime
        }));

        unusedTicketCount[currentRound][ msg.sender ] += 1;
        userTicketsCount[currentRound][ msg.sender ] += 1;
        
        return _round;
    }

    function getLastTicketBuyer( uint _roundID ) public view returns ( address ) {
        address lastTikectBuyer = purchasedTickets[ _roundID ][ purchasedTickets[ _roundID ].length - 1 ].buyer;
        return lastTikectBuyer;
    }


    // Get user's purchased tickets
    function getUserTickets( address _user, uint _roundId ) view public returns ( Ticket[] memory ) {
        require( _roundId > 0 && _roundId <= rounds.length, "Round does not exist." );
        uint _count = userTicketsCount[ _roundId ][ _user ];

        Ticket[] memory userTickets = new Ticket[]( _count );
        if ( _count > 0 ) {
            uint _index = 0;
            for ( uint a = 0; a < purchasedTickets[ _roundId ].length; a ++ ) {
                if ( purchasedTickets[ _roundId ][a].buyer == _user ) {
                    userTickets[_index] = purchasedTickets[ _roundId ][a];
                    _index += 1;
                    if ( _index == _count ) {
                        break;
                    }
                }
            }
        }
        return userTickets;
    }


    function beneficiaryAddress() public view returns( address ) {
        return purchasedTickets[ currentRound ][ beneficiaryTicketIndex[ currentRound ] ].buyer;
    }


    function getTimeLeft() public view returns( uint ) {
        require( rounds[ currentRound - 1 ].endingTime > 0, "Count down not started." );
        uint timeLeft = 0;

        if ( rounds[ currentRound - 1 ].endingTime > block.timestamp ) {
            timeLeft = rounds[ currentRound - 1 ].endingTime - block.timestamp;
        } 
        return timeLeft;
    }


    function getPrizePoolAmount( uint _roundId ) view public returns( uint ) {
        require( _roundId > 0 && _roundId <= rounds.length, "Round not exists." );
        return rounds[ _roundId - 1 ].prizePool;
    }


    function getRoundStartTime( uint _roundId ) view public returns (uint) {
        require( _roundId > 0 && _roundId <= rounds.length, "Round not exists." );
        return rounds[ _roundId - 1 ].startTime;
    }


    function getRoundEndingTime( uint _roundId ) view public returns (uint) {
        require( _roundId > 0 && _roundId <= rounds.length, "Round not exists." );
        return rounds[ _roundId - 1 ].endingTime;
    }


    function setActivationFee( uint _fee ) public {
        require( msg.sender == creator, "Only creator can set the fee." );
        activationFee = _fee;
    }


    // Get rounds list 
    function getAllRounds() public view returns( Round[] memory ) {
        return rounds;
    }


    function soldTicketsCount( uint _roundId ) view public returns( uint ) {
        return purchasedTickets[ _roundId ].length;
    }


    function getLastTicketPurchasedTime( uint _roundId ) view public returns ( uint ) {
        require( _roundId > 0 && _roundId <= currentRound, "Round not exists." );
        uint _ticketCount = soldTicketsCount( _roundId );
        return purchasedTickets[ _roundId ][ _ticketCount - 1 ].timePurchased;
    }

    // set ticket price
    function setTicketPrice( uint _price ) public {
        require( msg.sender == creator, "Only the creator can set it." );
        purchasedTickets[1][0].helpGoal = defaultHelpLimitTimes * _price;
        ticketPrice = _price;
    }


    // Change Ownership
    function changeCreator( address _user ) public {
        require( msg.sender == creator, "Only the creator can change it." );
        creator = _user;
    }


    function setLaunchTime(uint _time) public {
        require( msg.sender == creator, "Only the creator can set it." );
        launchTime = _time;
        // the start time of the first round should also be changed
        rounds[0].startTime = _time;
        // the purchased time of the first ticket should also be changed
        purchasedTickets[currentRound][0].timePurchased = _time;
    }


     struct UserInfo {
        address user;
        uint timeJoined;
        uint friends;
    }

    // Get invited firends
    function getInvitedFriends( address _user ) view public returns( UserInfo[] memory ) {
        uint _firendsCount = friendsCount[ _user ];
        UserInfo[] memory  _firends = new UserInfo[]( _firendsCount );
        uint _index = 0;
        for ( uint i = 1; i < userCount + 1; i ++ ) {
            address _u = referrerIdToAddress[i];
            if ( userReferrer[ _u ] == _user && _u != _user ) {
                _firends[_index] = UserInfo({
                    user: _u,
                    timeJoined: userTimeJoined[_u],
                    friends: friendsCount[_u]
                });
                _index += 1;
                if ( _index >= _firends.length ) {
                    break;
                }
            }
            if (_firendsCount <= 0) {
                break;
            }
        }
        return _firends;
    }

    function setMaxCountdown( uint _max ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        maxCountDown = _max;
    } 
    

    function setAmountToStartCountdown( uint _amount ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        amountToStartCountDown = _amount;
    }

    function setExtraTime ( uint _extra ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        extraTime = _extra;
    }

    function setPartnerRequirement ( uint _requirement ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        partnerRequirement = _requirement;
    }

    function addPartner ( address _user ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        isPartner[ _user ] = true;
    }


    function setNewRoundStartTime ( uint _time ) public {
        require( msg.sender == creator, "You are not allowed to do it." );
        newRoundStartTime = _time;
    }



    function getExpectedTimeNeeded( uint _ticketId ) view public returns (uint) {
        uint ticketsSoldCount = soldTicketsCount(currentRound);
        require( _ticketId <= ticketsSoldCount - 1, "Ticket not exists." );
        uint currentIndex = beneficiaryTicketIndex[ currentRound ];
        uint pendingAmount = 0;
        
        for ( uint i = currentIndex; i < _ticketId; i ++ ) {
            pendingAmount += (purchasedTickets[currentRound][i].helpGoal - purchasedTickets[currentRound][i].helpEarned);
        }

        uint ticketNeeded = pendingAmount / (ticketPrice / 3 * 2);

        uint _startTime = getRoundStartTime(currentRound);
        uint timePassed = block.timestamp - _startTime;
        uint averageTime = timePassed / ticketsSoldCount;
        
        return averageTime * ticketNeeded;
    }


    function setDevFee( uint _fee ) public {
        require( msg.sender == creator, 'Only creator can set it.' );
        devFee = _fee;
    }

}