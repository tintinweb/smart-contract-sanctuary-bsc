/**
 * @title Gauge Factory
 * @dev GaugeFactory.sol contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity =0.8.17;

import "./Gauge.sol";
import "./IBaseBribeFactory.sol";
import "./ProtocolGovernance.sol";
import "./IStableMiner.sol";

contract GaugeFactory is ProtocolGovernance, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public veProxy;
    IERC20 public STABLE;

    address public bribeFactory; // Address for bribeFactory
    uint256 public totalWeight;

    // Time delays
    uint256 public delay = 7 days;
    uint256 public lastDistribute;
    mapping(address => uint256) public lastVote; // msg.sender => time of users last vote
    mapping(address => uint256) public nextPoke; // msg.sender => time of users next poke

    // V2 added variables for pre-distribute
    uint256 public lockedTotalWeight;
    uint256 public lockedBalance;
    uint256 public locktime;
    uint256 public epoch;
    mapping(address => uint256) public lockedWeights; // token => weight
    mapping(address => uint256) public maxVotesToken; // token => max weight
    mapping(address => bool) public hasDistributed; // LPtoken => bool

    address[] public _tokens;
    mapping(address => address) public gauges; // token => gauge
    mapping(address => bool) public gaugeStatus; // token => bool : false = deprecated
    mapping(address => bool) public gaugeExists; // token => bool : ture = exists
    uint256 public pokeDelay = 30 days; // next auto poke in 30 days if you dont vote only farm

    // Add Gauge to Bribe Mapping
    mapping(address => address) public bribes; // gauge => bribes
    mapping(address => uint256) public weights; // token => weight
    mapping(address => mapping(address => uint256)) public votes; // msg.sender => votes
    mapping(address => address[]) public tokenVote; // msg.sender => token
    mapping(address => uint256) public usedWeights; // msg.sender => total voting weight of user

    // Modifiers
    modifier hasVoted(address voter) {
        uint256 time = epoch - lastVote[voter];
        require(time > 0, "You voted this epoch");
        _;
    }

    modifier hasDistribute() {
        uint256 time = block.timestamp - lastDistribute;

        require(time > delay, "this has been distributed in the last 7 days");
        _;
    }

    constructor(
        address _stable,
        address _veProxy,
        address _bribeFactory,
        address _stableMiner,
        uint256 _startTimestamp
    ) public {
        STABLE = IERC20(_stable);
        veProxy = IERC20(_veProxy);
        bribeFactory = _bribeFactory;
        stableMiner = _stableMiner;
        lastDistribute = _startTimestamp;
        governance = msg.sender;
        admin = msg.sender;
    }

    function tokens() external view returns (address[] memory) {
        return _tokens;
    }

    function getGauge(address _token) external view returns (address) {
        return gauges[_token];
    }

    function getBribes(address _gauge) external view returns (address) {
        return bribes[_gauge];
    }

    // Reset votes to 0
    function reset(address _user) external {
        require(
            (msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );
        _reset(_user);
    }

    // Reset votes to 0
    function _reset(address _owner) internal {
        address[] storage _tokenVote = tokenVote[_owner];
        uint256 _tokenVoteCnt = _tokenVote.length;

        for (uint256 i = 0; i < _tokenVoteCnt; i++) {
            address _token = _tokenVote[i];
            uint256 _votes = votes[_owner][_token];

            if (_votes > 0) {
                totalWeight = totalWeight - _votes;
                weights[_token] = weights[_token] - _votes;
                // Bribe vote withdrawal
                IBribe(bribes[gauges[_token]])._withdraw(
                    uint256(_votes),
                    _owner
                );
                votes[_owner][_token] = 0;
            }
        }

        delete tokenVote[_owner];
    }

    // Adjusts _owner's votes according to latest _owner's veSTABLE balance
    function poke(address _owner) public {
        require(
            (gaugeExists[msg.sender] == true ||
                msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );

        address[] memory _tokenVote = tokenVote[_owner];
        uint256 _tokenCnt = _tokenVote.length;
        uint256[] memory _weights = new uint256[](_tokenCnt);
        uint256 _prevUsedWeight = usedWeights[_owner];
        uint256 _weight = veProxy.balanceOf(_owner);

        for (uint256 i = 0; i < _tokenCnt; i++) {
            // Need to make this reflect the value deposited into bribes, anyone should be able to call this on
            // other addresses to stop them from gaming the system with outdated votes that dont lose voting power
            uint256 _prevWeight = votes[_owner][_tokenVote[i]];
            _weights[i] = (_prevWeight * _weight) / _prevUsedWeight;
        }
        nextPoke[_owner] = block.timestamp + pokeDelay;
        _vote(_owner, _tokenVote, _weights);
    }

    function _vote(
        address _owner,
        address[] memory _tokenVote,
        uint256[] memory _weights
    ) internal {
        _reset(_owner);
        uint256 _tokenCnt = _tokenVote.length;
        uint256 _weight = veProxy.balanceOf(_owner);
        uint256 _totalVoteWeight = 0;
        uint256 _usedWeight = 0;

        for (uint256 i = 0; i < _tokenCnt; i++) {
            _totalVoteWeight = _totalVoteWeight + _weights[i];
        }

        for (uint256 i = 0; i < _tokenCnt; i++) {
            address _token = _tokenVote[i];
            address _gauge = gauges[_token];
            uint256 _tokenWeight = (_weights[i] * _weight) / _totalVoteWeight;

            if (_gauge != address(0x0) && gaugeStatus[_token]) {
                _usedWeight = _usedWeight + _tokenWeight;
                totalWeight = totalWeight + _tokenWeight;
                weights[_token] = weights[_token] + _tokenWeight;
                tokenVote[_owner].push(_token);
                votes[_owner][_token] = _tokenWeight;
                // Bribe vote deposit
                IBribe(bribes[_gauge])._deposit(_tokenWeight, _owner);
            }
        }

        usedWeights[_owner] = _usedWeight;
    }

    // Vote with veSTABLE on a gauge
    function vote(
        address _user,
        address[] calldata _tokenVote,
        uint256[] calldata _weights
    ) external hasVoted(_user) {
        require(
            (msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );
        require(_tokenVote.length == _weights.length);
        lastVote[_user] = epoch;
        nextPoke[_user] = block.timestamp + pokeDelay;
        _vote(_user, _tokenVote, _weights);
    }

    // Add new token gauge
    function addGauge(address _tokenLP, uint256 _maxVotesToken)
        external
        returns (address)
    {
        require(gauges[_tokenLP] == address(0x0), "exists");
        require(_maxVotesToken <= 100000, "more then 100%");
        require(
            msg.sender == governance || msg.sender == admin,
            "!gov or !admin"
        );
        (address _token0, address _token1) = IBasePair(_tokenLP).tokens();

        // Deploy Gauge
        gauges[_tokenLP] = address(
            new Gauge(address(STABLE), _tokenLP, address(this))
        );
        _tokens.push(_tokenLP);
        maxVotesToken[_tokens[_tokens.length - 1]] = _maxVotesToken;
        gaugeStatus[_tokenLP] = true; // set gauge to active
        gaugeExists[gauges[_tokenLP]] = true; // Check if the gauge ever existed

        // Deploy Bribe
        address _bribe = IBaseV1BribeFactory(bribeFactory).createBribe(
            governance,
            _token0,
            _token1
        );
        bribes[gauges[_tokenLP]] = _bribe;
        emit GaugeAdded(_tokenLP);
        return gauges[_tokenLP];
    }

    // Deprecate existing gauge
    function deprecateGauge(address _token) external {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        require(gauges[_token] != address(0x0), "does not exist");
        require(gaugeStatus[_token], "gauge is not active");
        gaugeStatus[_token] = false;
        emit GaugeDeprecated(_token);
    }

    // Bring Deprecated gauge back into use
    function resurrectGauge(address _token) external {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        require(gauges[_token] != address(0x0), "does not exist");
        require(!gaugeStatus[_token], "gauge is active");
        gaugeStatus[_token] = true;
        emit GaugeResurrected(_token);
    }

    function length() external view returns (uint256) {
        return _tokens.length;
    }

    function preDistribute() external nonReentrant hasDistribute {
        uint256 _lockedTotalWeight = totalWeight;
        for (uint256 i = 0; i < _tokens.length; i++) {
            lockedWeights[_tokens[i]] = weights[_tokens[i]];

            uint256 maxVotes = (_lockedTotalWeight *
                maxVotesToken[_tokens[i]]) / 100000;

            if (lockedWeights[_tokens[i]] >= maxVotes) {
                uint256 divOldNewVotes = lockedWeights[_tokens[i]] - maxVotes;

                lockedWeights[_tokens[i]] = maxVotes;

                _lockedTotalWeight = _lockedTotalWeight - divOldNewVotes;
            }
            hasDistributed[_tokens[i]] = false;
        }
        lockedTotalWeight = _lockedTotalWeight;
        IStableMiner(stableMiner).createNewSTABLE();
        lockedBalance = STABLE.balanceOf(address(this));
        lastDistribute = lastDistribute + delay; // compensates for slight delays by the trigger
        epoch++;
    }

    function distribute(uint256 _start, uint256 _end) public nonReentrant {
        require(_start < _end, "bad _start");
        require(_end <= _tokens.length, "bad _end");

        if (lockedBalance > 0 && lockedTotalWeight > 0) {
            for (uint256 i = _start; i < _end; i++) {
                address _token = _tokens[i];
                if (!hasDistributed[_token] && gaugeStatus[_token]) {
                    address _gauge = gauges[_token];
                    uint256 _reward = (lockedBalance * lockedWeights[_token]) /
                        lockedTotalWeight;
                    if (_reward > 0) {
                        STABLE.safeApprove(_gauge, 0);
                        STABLE.safeApprove(_gauge, _reward);
                        Gauge(_gauge).notifyRewardAmount(_reward);
                    }
                    hasDistributed[_token] = true;
                }
            }
        }
    }

    // Update the veProxy contract
    function updateVeProxy(address _veProxy) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        veProxy = IERC20(_veProxy);
    }

    // Update the poke delay
    function updatePokeDelay(uint256 _pokeDelay) public {
        require(
            (msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );
        pokeDelay = _pokeDelay;
    }

    // Update the max votes peer token
    function updateMaxVotesToken(uint256 i, uint256 _maxVotesToken) public {
        require(
            (msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );
        require(_maxVotesToken <= 100000, "more then 100%");
        maxVotesToken[_tokens[i]] = _maxVotesToken;
    }

    // Update the referral details in gauge / bribe
    function updateReferrals(
        address _gauge,
        address _referralsContract,
        uint256 _referralFee,
        uint256[] memory _refLevelPercent
    ) public {
        require(
            (msg.sender == governance ||
                msg.sender == admin ||
                msg.sender == voter),
            "!gov or !admin"
        );

        uint256 i = 0;
        uint256 requestedRefLevelReward = 0;
        while (i < _refLevelPercent.length) {
            requestedRefLevelReward =
                requestedRefLevelReward +
                _refLevelPercent[i];
            i++;
        }
        require(requestedRefLevelReward == 10000, "must be 10000 = 100%");

        Gauge(_gauge).updateReferral(
            _referralsContract,
            _referralFee,
            _refLevelPercent
        );
    }

    event GaugeAdded(address tokenLP);
    event GaugeDeprecated(address tokenLP);
    event GaugeResurrected(address tokenLP);
}