// SPDX-License-Identifier: MIT
pragma solidity =0.8.11;

import "./Gauge.sol";
import "./IBaseV1BribeFactory.sol";
import "./ProtocolGovernance.sol";
import "./IStableMiner.sol";

contract GaugeProxy is ProtocolGovernance, ReentrancyGuard {
     using SafeERC20 for IERC20;

    IERC20 public veSTABLE;
    IERC20 public STABLE;

    address public admin; //Admin address to manage gauges like add/deprecate/resurrect
    address public stableMiner;

    // Address for bribeFactory
    address public bribeFactory;

    uint256 public totalWeight;

    // Time delays
    uint256 public voteDelay = 604800;
    uint256 public distributeDelay = 604800;
    uint256 public lastDistribute;
    mapping(address => uint256) public lastVote; // msg.sender => time of users last vote

    // V2 added variables for pre-distribute
    uint256 public lockedTotalWeight;
    uint256 public lockedBalance;
    uint256 public locktime;
    mapping(address => uint256) public lockedWeights; // token => weight
    mapping(address => bool) public hasDistributed; // LPtoken => bool

    // Variables verified tokens
    mapping(address => bool) public verifiedTokens; // verified tokens
    mapping(address => bool) public baseTokens; // Base tokens 
    address public pairFactory;

    // VE bool
    bool public ve = false;

    address[] internal _tokens;
    mapping(address => address) public gauges; // token => gauge
    mapping(address => bool) public gaugeStatus; // token => bool : false = deprecated

    // Add Guage to Bribe Mapping
    mapping(address => address) public bribes; // gauge => bribes
    mapping(address => uint256) public weights; // token => weight
    mapping(address => mapping(address => uint256)) public votes; // msg.sender => votes
    mapping(address => address[]) public tokenVote; // msg.sender => token
    mapping(address => uint256) public usedWeights; // msg.sender => total voting weight of user

    // Base fee variables
    address public baseReferralsContract;
    uint256 public baseReferralFee;

    // Modifiers
    modifier hasVoted(address voter) {
        uint256 time = block.timestamp - lastVote[voter];
        require(time > voteDelay, "You voted in the last 7 days");
        _;
    }

    modifier hasDistribute() {
        uint256 time = block.timestamp - lastDistribute;
        require(
            time > distributeDelay,
            "this has been distributed in the last 7 days"
        );
        _;
    }

    constructor(
        address _stable,
        address _veStable,
        address _bribeFactory, 
        address _pairFactory
    ) public {
        STABLE = IERC20(_stable);
        veSTABLE = IERC20(_veStable);
        governance = msg.sender;
        admin = msg.sender;
        bribeFactory = _bribeFactory;
        pairFactory = _pairFactory;
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

    function setBaseToken(address _tokenLP, bool _flag) external {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        baseTokens[_tokenLP] = _flag;
    }

    function setVerifiedToken(address _tokenLP, bool _flag) external {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        verifiedTokens[_tokenLP] = _flag;
    }

    // Reset votes to 0
    function reset() external {
        _reset(msg.sender);
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
        address[] memory _tokenVote = tokenVote[_owner];
        uint256 _tokenCnt = _tokenVote.length;
        uint256[] memory _weights = new uint256[](_tokenCnt);
        uint256 _prevUsedWeight = usedWeights[_owner];
        uint256 _weight = veSTABLE.balanceOf(_owner);

        for (uint256 i = 0; i < _tokenCnt; i++) {
            // Need to make this reflect the value deposited into bribes, anyone should be able to call this on
            // other addresses to stop them from gaming the system with outdated votes that dont lose voting power
            uint256 _prevWeight = votes[_owner][_tokenVote[i]];
            _weights[i] = _prevWeight * _weight / _prevUsedWeight;
        }

        _vote(_owner, _tokenVote, _weights);
    }

    function _vote(
        address _owner,
        address[] memory _tokenVote,
        uint256[] memory _weights
    ) internal {
        // _weights[i] = percentage * 100
        _reset(_owner);
        uint256 _tokenCnt = _tokenVote.length;
        uint256 _weight = veSTABLE.balanceOf(_owner);
        uint256 _totalVoteWeight = 0;
        uint256 _usedWeight = 0;

        for (uint256 i = 0; i < _tokenCnt; i++) {
            _totalVoteWeight = _totalVoteWeight + _weights[i];
        }

        for (uint256 i = 0; i < _tokenCnt; i++) {
            address _token = _tokenVote[i];
            address _gauge = gauges[_token];
            uint256 _tokenWeight = _weights[i] * _weight / _totalVoteWeight;

            if (_gauge != address(0x0) && gaugeStatus[_token]) {
                _usedWeight = _usedWeight + _tokenWeight;
                totalWeight = totalWeight + _tokenWeight;
                weights[_token] = weights[_token] + _tokenWeight;
                tokenVote[_owner].push(_token);
                votes[_owner][_token] = _tokenWeight;
                // Bribe vote deposit
                IBribe(bribes[_gauge])._deposit(uint256(_tokenWeight), _owner);
            }
        }

        usedWeights[_owner] = _usedWeight;
    }

    // Vote with veSTABLE on a gauge
    function vote(address[] calldata _tokenVote, uint256[] calldata _weights)
        external
        hasVoted(msg.sender)
    {
        require(_tokenVote.length == _weights.length);
        lastVote[msg.sender] = block.timestamp;
        _vote(msg.sender, _tokenVote, _weights);
    }

    function setAdmin(address _admin) external {
        require(msg.sender == governance, "!gov");
        admin = _admin;
    }

    // Add new token gauge
    function addGaugeForOwner(address _tokenLP, address _token0, address _token1)
        external
        returns (address)
    {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        require(gauges[_tokenLP] == address(0x0), "exists");

        // Deploy Gauge 
        gauges[_tokenLP] = address(
            new Gauge(address(STABLE), address(veSTABLE), _tokenLP, address(this))
        );
        _tokens.push(_tokenLP);
        gaugeStatus[_tokenLP] = true;

        // Deploy Bribe
        address _bribe = IBaseV1BribeFactory(bribeFactory).createBribe(
            governance,
            _token0,
            _token1
        );
        bribes[gauges[_tokenLP]] = _bribe;
        emit GaugeAddedByOwner(_tokenLP, _token0, _token1);
        return gauges[_tokenLP];
    }

    // Add new token gauge
    function addGauge(address _tokenLP)
        external
        returns (address)
    {
        require(gauges[_tokenLP] == address(0x0), "exists");
        require(IBaseV1Factory(pairFactory).isPair(_tokenLP), "!_tokenLP");
        (address _token0, address _token1) = IBaseV1Pair(_tokenLP).tokens();
        require(baseTokens[_token0] && verifiedTokens[_token1] || 
                baseTokens[_token1] && verifiedTokens[_token0], "!verified");
        require(msg.sender == governance || msg.sender == admin, "!gov or !admin");
        // Deploy Gauge 
        gauges[_tokenLP] = address(
            new Gauge(address(STABLE), address(veSTABLE), _tokenLP, address(this))
        );
        _tokens.push(_tokenLP);
        gaugeStatus[_tokenLP] = true;

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

    // Sets Stable-miner
    function setStableMiner(address _stableMiner) external {
        require(msg.sender == governance, "!gov");
        stableMiner = _stableMiner;
    }

    // Fetches STABLE
    // Change from public to internal, ONLY preDistribute should be able to call
    function collect() internal {
        IStableMiner(stableMiner).createNewSTABLE();
    }


    function length() external view returns (uint256) {
        return _tokens.length;
    }

    function preDistribute() external nonReentrant hasDistribute {
        lockedTotalWeight = totalWeight;
        for (uint256 i = 0; i < _tokens.length; i++) {
            lockedWeights[_tokens[i]] = weights[_tokens[i]];
            hasDistributed[_tokens[i]] = false;
        }
        collect();
        lastDistribute = block.timestamp;
        uint256 _balance = STABLE.balanceOf(address(this));
        lockedBalance = _balance;
        locktime = block.timestamp;
    }

    function distribute(uint256 _start, uint256 _end) external nonReentrant {
        require(_start < _end, "bad _start");
        require(_end <= _tokens.length, "bad _end");

        if (lockedBalance > 0 && lockedTotalWeight > 0) {
            for (uint256 i = _start; i < _end; i++) {
                address _token = _tokens[i];
                if (!hasDistributed[_token] && gaugeStatus[_token]) {
                    address _gauge = gauges[_token];
                    uint256 _reward = lockedBalance * lockedWeights[_token] / lockedTotalWeight;
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

    // Add claim function for bribes
    function claimBribes(address[] memory _bribes, address _user) external {
        for (uint256 i = 0; i < _bribes.length; i++) {
            IBribe(_bribes[i]).getRewardForOwner(_user);
        }
    }

    function toggleVE() external {
        require(
            (msg.sender == governance || msg.sender == admin),
            "turnVeOn: permission is denied!"
        );
        ve = !ve;
    }

    // set the base referral contract
    function setBaseReferralsContract(address _referralsContract) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
            baseReferralsContract = _referralsContract;
    }

    // set the base referral fee
    function setBaseReferralsFee(uint256 _baseReferralFee) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        require(
            (_baseReferralFee < 1000),
            "must be lower 10%"
        );
            baseReferralFee = _baseReferralFee;
    }

    // update the referral contract
    function updateReferralsContract(address _gauge, address _referralsContract) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
         Gauge(_gauge).updateReferralsContract(_referralsContract);
    }

    // update the referral fee
    function updateReferralsFee(address _gauge, uint256 _referralFee) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        require(
            (_referralFee < 1000),
            "must be lower 10%"
        );
          Gauge(_gauge).updateReferralsFee(_referralFee);
    }

    // update the ref level reward
    function updateRefLevelReward(address _gauge, uint256[] memory _refLevelPercent) public {
        require(
            (msg.sender == governance || msg.sender == admin),
            "!gov or !admin"
        );
        uint256 i = 0;
        uint256 requestedRefLevelReward = 0;
        while (i < _refLevelPercent.length) {
            requestedRefLevelReward = requestedRefLevelReward + _refLevelPercent[i];
            i++;
        }
        require(requestedRefLevelReward == 100000, "must be 100000 = 100%");

        Gauge(_gauge).updateRefLevelReward(_refLevelPercent);
    }

    event GaugeAdded(address tokenLP);
    event GaugeAddedByOwner(address tokenLP, address token0, address token1);
    event GaugeDeprecated(address tokenLP);
    event GaugeResurrected(address tokenLP);
}