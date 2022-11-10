/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Partial interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

contract Invest {
    event Log(
        uint8 programIndex,
        uint256 pointer,
        uint256 nextIndex,
        uint256 nextIndexAdjusted
    );
    struct Program {
        uint256 amount;
        uint256 startDelay;
    }
    mapping (uint8 => Program) internal _programs;
    struct User {
        address referrerAddress;
        mapping (uint8 => uint256) queueIndex;
        mapping (uint8 => uint256) investmentsNumber;
        mapping (uint8 => uint256) programCompleteNumber;
        uint256[] referralsNumber;
        bool active;
    }
    mapping (address => User) internal _users;
    IERC20 public immutable USDT;
    uint8 public constant YIELD_PERCENT = 75;
    uint8[] public REFERRER_PERCENTS = [7, 5, 3];
    address internal _genesisAddress;
    struct QueuePoint {
        address userAddress;
        uint256 chainIndex; // excluded from queue chain id
        uint8 paymentsReceived; // number of payments that were received for this queue point
    }
    mapping (uint8 => mapping(uint256 => QueuePoint)) internal _queue;
    mapping (uint8 => uint256) internal _queueLength;
    mapping (uint8 => uint256) internal _queuePointer;
    struct Chain {
        uint256 chainEnd; // excluded from queue chain last element index
    }
    mapping (uint8 => mapping(uint256 => Chain)) internal _chains; // excluded from queue chains
    mapping (uint8 => uint256) internal _chainsNumber; // number of chains for program
    uint256 internal _startTime;
    uint256 public totalIncome;

    constructor (
        address genesisAddress,
        address paymentToken // USDT bsc '0x55d398326f99059fF775485246999027B3197955'
    ) {
        require(genesisAddress != address(0), 'Genesis address can not be zero');
        _genesisAddress = genesisAddress;
        require(paymentToken != address(0), 'Payment address can not be zero');
        USDT =  IERC20(paymentToken);
        _programs[1].amount = 25 ether;
        for (uint8 i = 2; i <= 10; i ++) {
           _programs[i].amount = _programs[i - 1].amount * 2;
        }
        _programs[1].startDelay = 0;
        _programs[2].startDelay = 10 days;
        _programs[3].startDelay = _programs[2].startDelay + 9 days;
        _programs[4].startDelay = _programs[3].startDelay + 8 days;
        _programs[5].startDelay = _programs[4].startDelay + 7 days;
        _programs[6].startDelay = _programs[5].startDelay + 6 days;
        _programs[7].startDelay = _programs[6].startDelay + 5 days;
        _programs[8].startDelay = _programs[7].startDelay + 4 days;
        _programs[9].startDelay = _programs[8].startDelay + 3 days;
        _programs[10].startDelay = _programs[9].startDelay + 2 days;
        _startTime = block.timestamp;
    }

    /**
     * Function for investing into program with specified index
     */
    function invest (
        address referrerAddress, uint8 programIndex
    ) external returns (bool) {
        require(_programs[programIndex].amount > 0, 'Program not found');
        require(isProgramActive(programIndex), 'Program is not active yet');
        require (
            _users[msg.sender].queueIndex[programIndex] == 0,
                'You have active investment in this program'
        );
        _queueLength[programIndex] ++;
        _users[msg.sender].queueIndex[programIndex] = _queueLength[programIndex];
        if (_users[msg.sender].referralsNumber.length == 0) {
            _users[msg.sender].referralsNumber = new uint256[](3);
        }

        QueuePoint storage queuePoint = _queue[programIndex][
            _users[msg.sender].queueIndex[programIndex]
        ];
        if (programIndex > 1) {
            require(
                _users[msg.sender].investmentsNumber[programIndex - 1] >
                    _users[msg.sender].investmentsNumber[programIndex],
                        'Investments number in previous program can not be less than in specified program'
            );
        }
        require(
            USDT.transferFrom(msg.sender, address(this), _programs[programIndex].amount),
                'Payment failed, check allowance and balance'
        );
        queuePoint.userAddress = msg.sender;
        _users[msg.sender].investmentsNumber[programIndex] ++;
        if (
            _users[msg.sender].referrerAddress == address(0) &&
            _users[referrerAddress].active && msg.sender != referrerAddress
        ) {
            _users[msg.sender].referrerAddress = referrerAddress;
            _users[referrerAddress].referralsNumber[0] ++;
            referrerAddress = _users[referrerAddress].referrerAddress;
            if (referrerAddress != address(0)) {
                _users[referrerAddress].referralsNumber[1] ++;
                referrerAddress = _users[referrerAddress].referrerAddress;
                if (referrerAddress != address(0)) {
                    _users[referrerAddress].referralsNumber[2] ++;
                }
            }
        }
        _proceedPayments(msg.sender, programIndex);
        if (!_users[msg.sender].active) _users[msg.sender].active = true;
        return true;
    }

    /**
     * Internal function for payments proceeding
     */
    function _proceedPayments (
        address userAddress, uint8 programIndex
    ) internal returns (bool) {
        uint256 income;
        uint256 amount = _programs[programIndex].amount;
        uint256 payment = _programs[programIndex].amount * YIELD_PERCENT / 100;
        address receiver = _proceedQueue(userAddress, programIndex);
        require(USDT.transfer(receiver, payment), 'Payment failed');
        if (receiver != _genesisAddress) income += payment;
        amount -= payment;
        address referral = userAddress;
        for (uint8 i = 0; i < 3; i ++) {
            address referrer = _users[referral].referrerAddress;
            payment = _programs[programIndex].amount * REFERRER_PERCENTS[i] / 100;
            if (referrer == address(0)) referrer = _genesisAddress;
            require(USDT.transfer(referrer, payment), 'Payment failed');
            if (referrer != _genesisAddress) income += payment;
            amount -= payment;
            referral = referrer;
        }
        totalIncome += income;
        payment = amount;
        require(USDT.transfer(_genesisAddress, payment), 'Payment failed');
        return true;
    }

    /**
     * Internal function for queue indexes proceeding
     */
    function _proceedQueue (
        address userAddress, uint8 programIndex
    ) internal returns (address) {
        address receiver;
        address referrer = _users[userAddress].referrerAddress;
        if (
            referrer != address(0) && _users[referrer].queueIndex[programIndex] > 0
        ) {
            receiver = referrer;
        } else {
            _queuePointer[programIndex] ++;
            receiver = getNextReceiver(programIndex);
        }
        if (receiver != _genesisAddress) {
            QueuePoint storage receiverQueuePoint = _queue[programIndex][
                _users[receiver].queueIndex[programIndex]
            ];
            receiverQueuePoint.paymentsReceived ++;
            if (receiverQueuePoint.paymentsReceived >= 2) {
                _setChain(_users[receiver].queueIndex[programIndex], programIndex);
                _users[receiver].queueIndex[programIndex] = 0;
                _users[receiver].programCompleteNumber[programIndex] ++;
            }
        }
        return receiver;
    }

    /**
     * Internal function for excluded chain setting
     */
    function _setChain (
        uint256 queueIndex, uint8 programIndex
    ) internal returns (bool) {
        uint256 chainIndex;
        if (queueIndex > 1 && _queue[programIndex][queueIndex - 1].chainIndex > 0) {
            chainIndex = _queue[programIndex][queueIndex - 1].chainIndex;
        } else {
            _chainsNumber[programIndex] ++;
            chainIndex = _chainsNumber[programIndex];
        }
        _queue[programIndex][queueIndex].chainIndex = chainIndex;
        _chains[programIndex][chainIndex].chainEnd = queueIndex;

        if (_queue[programIndex][queueIndex + 1].chainIndex > 0) {
            _chains[programIndex][chainIndex].chainEnd = _chains[programIndex][
                _queue[programIndex][queueIndex + 1].chainIndex
            ].chainEnd;
        }
        return true;
    }

    /**
     * User data getter
     */
    function getUserData (
        address userAddress, uint8 programIndex
    ) external view returns (
        address referrerAddress,
        uint256 queueIndex,
        uint256 investmentsNumber,
        uint256 programCompleteNumber,
        uint256[] memory referralsNumber
    ) {
        return (
            _users[userAddress].referrerAddress,
            _users[userAddress].queueIndex[programIndex],
            _users[userAddress].investmentsNumber[programIndex],
            _users[userAddress].programCompleteNumber[programIndex],
            _users[userAddress].referralsNumber
        );
    }

    /**
     * Queue length getter
     */
    function getQueueLength (
        uint8 programIndex
    ) external view returns (uint256) {
        return _queueLength[programIndex];
    }

    /**
     * Queue pointer (special index for queue active point detecting) getter
     */
    function getQueuePointer (
        uint8 programIndex
    ) external view returns (uint256) {
        return _queuePointer[programIndex];
    }

    /**
     * Queue active point getter
     */
    function getQueuePoint (
        uint256 queueIndex,
        uint8 programIndex
    ) external view returns (
        address userAddress,
        uint256 chainIndex,
        uint8 paymentsReceived
    ) {
        return (
            _queue[programIndex][queueIndex].userAddress,
            _queue[programIndex][queueIndex].chainIndex,
            _queue[programIndex][queueIndex].paymentsReceived
        );
    }

    /**
     * Chain data for specified queue point getter
     */
    function getChainData (
        uint256 chainIndex,
        uint8 programIndex
    ) external view returns (
        uint256 chainEnd
    ) {
        return (
            _chains[programIndex][chainIndex].chainEnd
        );
    }

    /**
     * Next receiver queue point getter
     */
    function getNextReceiver (
        uint8 programIndex
    ) public returns (address) {
        uint256 pointer = _queuePointer[programIndex];
        if (pointer <= 2) return _genesisAddress;
        uint256 nextIndex;
        if (pointer <= 4) {
            nextIndex = pointer - 2;
        } else {
            nextIndex = pointer - (((pointer - 5) / 4) * 2 + 4);
        }
        uint256 nextIndexAdjusted;
        if (_queue[programIndex][nextIndex].chainIndex > 0) {
            nextIndexAdjusted = _chains[programIndex][
                _queue[programIndex][nextIndex].chainIndex
            ].chainEnd + 1;
        } else {
            nextIndexAdjusted = nextIndex;
        }
        emit Log(programIndex, pointer, nextIndex, nextIndexAdjusted);
        if (_queue[programIndex][nextIndexAdjusted].paymentsReceived >= 2) return _genesisAddress;
        address receiver = _queue[programIndex][nextIndexAdjusted].userAddress;
        if (receiver == address(0)) return _genesisAddress;
        return receiver;
    }

    /**
     * Admin payments receiver getter
     */
    function getGenesisAddress () external view returns (address) {
        return _genesisAddress;
    }


    /**
     * Program data getter
     */
    function getProgram (uint8 programIndex) external view returns (
        uint256 amount, uint256 startDelay
    ) {
        return (
            _programs[programIndex].amount,
            _programs[programIndex].startDelay
        );
    }

    /**
     * Contract start time getter
     */
    function getStartTime () external view returns (uint256) {
        return _startTime;
    }

    /**
     * Check if program is active
     */
    function isProgramActive (uint8 programIndex) public view returns (bool) {
        return _startTime + _programs[programIndex].startDelay <= block.timestamp;
    }
}