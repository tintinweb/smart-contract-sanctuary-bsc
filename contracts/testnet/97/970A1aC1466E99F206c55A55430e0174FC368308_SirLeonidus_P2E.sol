/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

/*
    Description:
    P2E contract version 0.0.08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) { return payable(msg.sender); }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
        }
    }
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) { return _owner; }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        }
    }

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    }
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    }
interface IERC721Special is IERC721{
    function getAggregateWeight(address _owner) external view returns (uint256);
    function getERC721Indecies(address _owner) external view returns (int[] memory);
    function tokensOfOwner(address _owner) external view returns (uint256[] memory);
    function getNftWeight(address _owner) external view returns(uint256);
}
contract SirLeonidus_P2E is Ownable {
    mapping (address => bool) internal authorizations;
    mapping (uint256 => bool) publicKey;
    mapping (uint256 => bool) tempKey;
    mapping (uint256 => uint256) tempKeyExpiration;

    // uint256 internal EPOCH1 = 600; // test: 10-minutes
    uint256 internal EPOCH1 = 86400;
    uint256 internal EPOCH7 = 604800;
    uint256 private privateKey;

    uint256 public dailyPayout;
    uint256 public weeklyPayout;
    uint256 public dayEndTimestamp;
    uint256 public weekEndTimestamp;

    uint256[10] public dailyPayoutRate;  // payout rates for P2E only
    uint256[10] public weeklyPayoutRate;
    uint256[] private publicKeys;

    uint256 public governanceDecimals = 0;
    address public governanceToken    = 0x000000000000000000000000000000000000dEaD;
    address public nftToken           = 0x000000000000000000000000000000000000dEaD;

    string public version;
// ----------------------------------------------------------------------------
// Possible multiple NFT contracts (all MUST use "getNFTWeight"):
    mapping (address => bool) internal nftContract;                       // NFT > is contract with active rewards
    mapping (address => mapping (address => uint256)) public rewards;     // NFT > user > total rewards
    mapping (address => mapping (address => uint256)) public lastClaim;   // NFT > user > last claim
    mapping (address => score) public playerHighscore;
    mapping (address => uint256[]) public scoreIndex;
    uint256 public totalRewards;                                          // NFT > overall total rewards
    uint256 public stakedPayout = 100;
    
    bool internal locked;
    modifier noreentry() {
        require(!locked, "No re-entrance");
        locked = true;
        _;
        locked = false;
        }
    modifier authorization(uint256 _key) { require(authorizations[_msgSender()] || privateKey == _key, "Only designated user can edit contract"); _; }
    modifier client(uint256 _key) { require(publicKey[_key] || (tempKey[_key] && tempKeyExpiration[_key] > block.timestamp), "Only designated client can edit contract state"); _; }

    struct score { uint256 score; uint256 timestamp; string version; }
    struct highscore { uint256 score; uint256 timestamp; address player; string version; }

    score[] private scores;
    highscore[30] private highscores;          //top 30 all-time
    highscore[30] private highscoresDaily;     //top 30 daily

    constructor(address [] memory _devs, uint256 input) { 
        authorizations[owner()] = true;
        for(uint256 i=0; i<_devs.length; i++)
            authorizations[_devs[i]] = true;

        dailyPayoutRate  = [40, 30, 15, 9, 1, 1, 1, 1, 1, 1];
        weeklyPayoutRate = [40, 30, 15, 9, 1, 1, 1, 1, 1, 1];

        dailyPayout  = 100000;
        weeklyPayout = 500000;
        totalRewards = 0;

        privateKey = uint256(keccak256(abi.encodePacked(block.timestamp, rand(), input)));

        uint256 current  = block.timestamp;
        dayEndTimestamp  = current - current % EPOCH1 + EPOCH1;
        weekEndTimestamp = current - current % EPOCH7 + EPOCH7;

        // TEST
        governanceToken = 0x65F672644E8C2C86502734A36Be94BBA598D0418;
        governanceDecimals = 18;
        }
    receive() external payable {}

    function updateAuthorization(bool state, address target) external onlyOwner { 
        require(authorizations[target] != state);
        authorizations[target] = state;
        }
    function getPrivateKey() external view onlyOwner returns(uint256) { return privateKey; }
    function getPublicKey(uint256 _privateKey, uint256 _index) external view authorization(_privateKey) returns(uint256) { return publicKeys[_index]; }
    function getPublicKeySize() external view returns(uint256) { return publicKeys.length; }
    function generateKey(uint256 _privateKey, bool temp) external authorization(_privateKey) noreentry {
        uint256 key = uint256(keccak256(abi.encodePacked(block.timestamp, rand(), privateKey)));
        if(temp) {
            tempKey[key] = true;
            tempKeyExpiration[key] = block.timestamp + EPOCH7;
        } else { publicKey[key] = true; }
        publicKeys.push(key);
        }
    function updateKey(uint256 _privateKey, uint256 key, bool state, bool temp, uint256 _days) external authorization(_privateKey) noreentry {
        if(temp) {
            require(_days > 0 && _days < 15);
            require(tempKey[key], "tempKey[key] is false, you must request a new key");
            tempKey[key] = state;
            tempKeyExpiration[key] = tempKeyExpiration[key] + EPOCH1 * _days;
        } else { 
            require(publicKey[key] == state, "publicKey[key] is already has that state");
            publicKey[key] = state;
        }
    }

    function updateData(string memory _version, address _governanceToken, uint256 _governanceDecimals, address _nftToken) external onlyOwner {
        version = _version;
        governanceToken = _governanceToken;
        governanceDecimals = _governanceDecimals;
        nftContract[nftToken] = false;
        nftToken = _nftToken;
        nftContract[_nftToken] = true;
        }
    function rand() public view returns(uint256) {
        uint256 seed = uint256(keccak256(
            abi.encodePacked(
                block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / 
                (block.timestamp)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / 
                (block.timestamp)) + block.number)
                )
            );
        return (seed - ((seed / 100) * 100)) + 1;
        }
    function firstIndex(uint256[] memory _scores, uint256 _score) internal pure returns (uint256) {
        for(uint256 i=0; i<_scores.length; i++) { if(_score > _scores[i]) return i; }
        return 999;
        }
    function checkNewTime(uint256 oldTime, uint256 newTime, uint256 period) public pure returns(bool) {
        return (newTime - oldTime > period); // unix overflow ignored
    }

    function resetDailyHighscores() internal {
        for(uint256 i=0; i<30; i++) {
            highscoresDaily[i].score = 0;
            highscoresDaily[i].timestamp = block.timestamp;
            highscoresDaily[i].player = address(0);
            highscoresDaily[i].version = version;
        }
        }
    function addPlayerHighscore(uint256 _score, address _player, uint256 _timestamp) internal{
        // change personal best highscore
        if(playerHighscore[_player].score == 0) {
            playerHighscore[_player].score = _score;
            playerHighscore[_player].timestamp = _timestamp;
            playerHighscore[_player].version = version;
            emit AddPlayerHighscore(_score, _player, _timestamp, version);
        } else if(_score > playerHighscore[_player].score) { //scores[scoreIndex[_player][scoreIndex[_player].length-1]].score) {
            playerHighscore[_player].score = _score;
            playerHighscore[_player].timestamp = _timestamp;
            playerHighscore[_player].version = version;
            emit AddPlayerHighscore(_score, _player, _timestamp, version);
        }
        }
    function addHighscoreDaily(uint256 _score, address _player, uint256 _timestamp) internal returns (bool) {
        (uint256[] memory _scores,,,) = getHighscores(true);
        uint256 _new = firstIndex(_scores, _score);
        
        if(_new == 999) { return false; }
        if(_new == 29 || highscoresDaily[_new].score == 0) {
            highscoresDaily[_new].score = _score;
            highscoresDaily[_new].timestamp = _timestamp;
            highscoresDaily[_new].player = _player;
            highscoresDaily[_new].version = version;
            emit AddHighscoreDaily(_score, _player, _timestamp, version);
            return true;
        } else {
            for(uint256 i=_new; i<30; i++) {
                highscoresDaily[i] = highscore(highscoresDaily[i-1].score, highscoresDaily[i-1].timestamp, highscoresDaily[i-1].player, highscoresDaily[i-1].version);
            }
            highscoresDaily[_new].score = _score;
            highscoresDaily[_new].timestamp = _timestamp;
            highscoresDaily[_new].player = _player;
            highscoresDaily[_new].version = version;
            //highscoresDaily[_new] = highscore(_score, _timestamp, _player, version);
            emit AddHighscoreDaily(_score, _player, _timestamp, version);
            return true;
        }
        }
    function addHighscore(uint256 _score, address _player, uint256 _timestamp) internal returns (bool) {
        (uint256[] memory _scores,,,) = getHighscores(false);
        uint256 _new = firstIndex(_scores, _score);

        if(_new == 999) { return false; }
        else if(_new == 29 || highscores[0].score == 0) {
            highscores[_new].score = _score;
            highscores[_new].timestamp = _timestamp;
            highscores[_new].player = _player;
            highscores[_new].version = version;
            emit AddHighscore(_score, _player, _timestamp, version);
            return true;
        } else {
            for(uint256 i=_new; i<30; i++) {
                highscores[i] = highscore(highscores[i-1].score, highscores[i-1].timestamp, highscores[i-1].player, highscores[i-1].version);
            }
            highscores[_new].score = _score;
            highscores[_new].timestamp = _timestamp;
            highscores[_new].player = _player;
            highscores[_new].version = version;
            emit AddHighscore(_score, _player, _timestamp, version);
            return true;
        }
        }
    function addScore(uint256 _score, address _player, uint256 key) external client(key) { // insuffient gas?
        // add fee to contract or governance LP
        // add score
        uint256 newTime = block.timestamp;
        scores.push(score(_score, newTime, version));
        scoreIndex[_player].push(scores.length-1);

        //payout
        mintForHighscoreDaily();
        //mintForHighscore();

        // check highscore status
        addPlayerHighscore(_score, _player, newTime);
        if(addHighscoreDaily(_score, _player, newTime))
            addHighscore(_score, _player, newTime);

        // payout NFTs
        //uint256 lastScoreTime = scores[scoreIndex[_player][scoreIndex[_player].length-1]].timestamp;
        //uint256 _lastClaim = lastClaim[nftToken][_player];
            
        //if(((_lastClaim - (_lastClaim % EPOCH1)) / EPOCH1) < ((newTime - (newTime % EPOCH1)) / EPOCH1)) {
        //    if(mintForNFT(nftToken, _player))
        //        lastClaim[nftToken][_player] = newTime;
        //}
        emit AddScore(_score, _player, newTime, version);
    }

    function getHighscores(bool daily) public view returns (uint256[] memory, address[] memory, uint256[] memory, string[] memory) {
        uint256[] memory _scores = new uint256[](30);
        address[] memory _players = new address[](30);
        uint256[] memory _timestamps = new uint256[](30);
        string[] memory _version = new string[](30);
        if(daily) {
            for(uint256 i=0; i<30; i++) {
            _scores[i] = highscoresDaily[i].score;
            _players[i] = highscoresDaily[i].player;
            _timestamps[i] = highscoresDaily[i].timestamp;
            _version[i] = highscoresDaily[i].version;
            }
        } else {
            for(uint256 i=0; i<30; i++) {
                _scores[i] = highscores[i].score;
                _players[i] = highscores[i].player;
                _timestamps[i] = highscores[i].timestamp;
                _version[i] = highscores[i].version;
            }
        }
        return (_scores, _players, _timestamps, _version);
        }
    function getScores(address _player) external view returns (uint256[] memory, uint256[] memory, string[] memory) {
        require(scores.length > 0, "Empty database");
        uint256 _size = scoreIndex[_player].length;
        require(_size != 0, "No player scores available");

        uint256[] memory _scores = new uint256[](_size);
        uint256[] memory _timestamps = new uint256[](_size);
        string[] memory _version = new string[](_size);
        for(uint256 i=0; i<_size; i++) {
            _scores[i] = scores[scoreIndex[_player][i]].score;
            _timestamps[i] = scores[scoreIndex[_player][i]].timestamp;
            _version[i] = scores[scoreIndex[_player][i]].version;
        }

        return ( _scores, _timestamps, _version );
    }

    event MintForGamify(bool success, uint256 amount, address minter, address to);
    event AddPlayerHighscore(uint256 _score, address _player, uint256 _timestamp, string version);
    event AddHighscoreDaily(uint256 _score, address _player, uint256 _timestamp, string version);
    event AddHighscore(uint256 _score, address _player, uint256 _timestamp, string version);
    event AddScore(uint256 _score, address _player, uint256 _timestamp, string version);
    function getWeight(address _owner, address _token) public noreentry returns(uint256) {
        address token;
        if(_token == address(0)) { token = nftToken; }
        else { token = _token; }

        //bytes memory payload = abi.encodeWithSignature("getNftWeight(address)", _owner);
        //(bool success, bytes memory encodedData) = token.call(payload);
        return IERC721Special(token).getNftWeight(_owner); // might possibly have enough gas (do NOT use this with transfer/mint)
        }
    function mintForNFT(address _contract, address _to) internal returns (bool) {
        //require(block.timestamp - lastClaim[_to] > EPOCH1, "Reward already claimed today.");
        address token;
        if(_contract == address(0)) { token = nftToken; }
        else { token = _contract; }

        if(!nftContract[token]) return false;
        uint256 _amount = getWeight(_to, token) * stakedPayout;
        bool success = mintReward(_amount, _to);
        if(success) totalRewards = totalRewards + _amount;

        emit MintForGamify(success, getWeight(_to, token) * stakedPayout, address(this), _to);
        return success;
        }
    function mintForHighscoreDaily() internal {
        uint256 current = block.timestamp;
        uint256 _amount = dailyPayout * 10**governanceDecimals;
        if(checkNewTime(dayEndTimestamp, current, EPOCH1)) {
            mintReward(_amount, address(this));
            for(uint256 i=0; i<10; i++) {
                if(highscoresDaily[i].player != address(0) && _amount * dailyPayoutRate[i] != 0) {
                    sendReward(highscoresDaily[i].player, (_amount * dailyPayoutRate[i] - 10**17) / 100);
                }
            }
            dayEndTimestamp = current - current % EPOCH1 + EPOCH1;
            resetDailyHighscores();
        }
        }
    function mintForHighscore() internal {
        uint256 current = block.timestamp;
        uint256 _amount = weeklyPayout * 10**governanceDecimals;
        if(checkNewTime(weekEndTimestamp, current, EPOCH1)) {
            mintReward(_amount, address(this));
            for(uint256 i=0; i<10; i++) {
                if(highscores[i].player != address(0) && _amount * weeklyPayoutRate[i] != 0) {
                    sendReward(highscores[i].player, (_amount * weeklyPayoutRate[i] - 10**17) / 100);
                }
            }
            dayEndTimestamp = current - current % EPOCH1 + EPOCH1;
            resetDailyHighscores();
        }
        }
    function mintReward(uint256 _amount, address _to) internal noreentry returns(bool) {
        bytes memory payload = abi.encodeWithSignature("mintFromGamify(uint256,address)", _amount, _to);
        (bool success, ) = governanceToken.call(payload);
        return success;
        }
    function sendReward(address _to, uint256 _amount) internal { IERC20(governanceToken).transfer(_to, _amount); }
    function burnRdnmTkn(address _token, address _to, uint256 _amount) external { 
        require(authorizations[_to]);
        IERC20(_token).transfer(_to, _amount); 
        }
}