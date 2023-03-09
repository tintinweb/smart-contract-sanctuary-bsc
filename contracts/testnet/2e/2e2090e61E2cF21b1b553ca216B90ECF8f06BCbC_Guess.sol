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
pragma solidity ^0.8.7;
// import "./mathlib.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IguessNft.sol";

contract Guess {
    // using SafeMath for uint256;
    // football and basketball guess struct
    struct UserGuessDataInput {
        bytes32 guessId;
        uint32 rate;
        // uint256 guessTime;
    }
    //user  order data
    struct UserGuessDataAndTimeForOrder {
        bytes32 guessId;
        uint32 rate;
        uint256 guessTime;
        bytes32 nftTypeId;
        uint256 baseCoin;
        bool isCheck;
        bytes32 matchId;
    }
    struct MatchGuessData {
        uint256 matchTime;
        uint256 updateTime;
        uint256 times;
        bool islocked;
        UserGuessDataInput[] guessDataInput;
    }
    //---------------------------------------------------------------------------
    /**data */
    //bytes32 is matchid
    mapping(bytes32 => MatchGuessData) matchData;
    mapping(bytes32 => mapping(uint256 => mapping(uint256 => UserGuessDataAndTimeForOrder))) userGuessData; //matchid =>tokenid=>guessTime(orderid)
    // mapping(bytes32 => uint256[]) private userGuessDataNFTTokenIds;
    mapping(uint256 => UserGuessDataAndTimeForOrder[]) userGuessDataForOrder;
    mapping(bytes32 => bool) isSetMatchResult;
    mapping(bytes32 => bytes32[]) matchResult;
    mapping(bytes32 => mapping(uint256 => mapping(uint256 => bool))) isMatchIncludeTokenId;
    mapping(address => uint256) public balanceAgent;

    mapping(uint256 => bool) isNFTlocked;
    mapping(uint256 => uint256) NFTorderTime;
    mapping(uint256 => bool) isNFTUsing;
    mapping(uint256 => uint256) NFTuseTime;
    mapping(uint256 => uint256) NFTFirstuseTime; //public
    mapping(uint256 => uint256) matchBeginTime;
    // uint256 agentRate = 2; //2

    IguessNft iGuessNft;
    struct TokenMeta {
        uint256 baseCoin; //eg:1000
        uint256 lockTime_h; //eg:72hour
        uint256 unlockRate; //eg:0.75
        uint256 depreciateCycle_d; //eg:30
        uint256 depreciateCycleRate; // eg: 0.1
        uint256 restoreRate; //eg:2
    }
    mapping(bytes32 => TokenMeta) public _tokenMetas;
    mapping(bytes32 => bool) _tokenTypesExist;
    bytes32[] public _tokenTypes;
    IERC20 guessToken;
    IERC20 openToken;
    bool isStopGame = false;

    // end——————————————————————————————————————————————————————————————————————————————

    constructor(
        address _nftAddress,
        bytes32[] memory typeIDs,
        TokenMeta[] memory tokenMetas
    ) {
        owner = msg.sender;
        iGuessNft = IguessNft(_nftAddress);
        setTokeMetaList(typeIDs, tokenMetas);
    }

    function setStopGame(bool value) external onlyOwner {
        isStopGame = value;
    }

    function setTokeMeta(bytes32 typeID, TokenMeta memory tokenMeta)
        public
        onlyOwner
    {
        _tokenMetas[typeID] = tokenMeta;
        if (!_tokenTypesExist[typeID]) {
            _tokenTypesExist[typeID] = true;
            _tokenTypes.push(typeID);
        }
    }

    function setTokeMetaList(
        bytes32[] memory typeIDs,
        TokenMeta[] memory tokenMetas
    ) public onlyOwner {
        for (uint256 index = 0; index < typeIDs.length; index++) {
            setTokeMeta(typeIDs[index], tokenMetas[index]);
        }
    }

    /////Ower
    function setMatchData(
        bytes32 matchId,
        uint256 matchTime,
        UserGuessDataInput[] calldata guessDatas
    ) external onlyOwner {
        require(!matchData[matchId].islocked, "match locked");
        require(!isSetMatchResult[matchId], "match locked2");
        require(
            matchData[matchId].matchTime == 0 ||
                matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "time less than 10 minutes"
        );

        uint256 length = matchData[matchId].guessDataInput.length;
        matchData[matchId].times++;
        for (uint256 i = 0; i < length; i++) {
            matchData[matchId].guessDataInput.pop();
        }

        for (uint256 i = 0; i < guessDatas.length; i++) {
            matchData[matchId].guessDataInput.push(guessDatas[i]);
        }

        //matchData[matchId].guessDataInput = guessDatas;
        matchData[matchId].updateTime = block.timestamp;
        if (matchData[matchId].matchTime == 0) {
            matchData[matchId].matchTime = matchTime;
        }
    }

    ///Ower
    function setMatchLocked(bytes32 matchId) external onlyOwner {
        require(!matchData[matchId].islocked, "match locked");
        matchData[matchId].islocked = true;
    }

    function getMatchData(bytes32 matchId)
        external
        view
        onlyOwner
        returns (
            bool islocked,
            uint256 times,
            uint256 matchTime,
            uint256 updateTime,
            uint256 blockTime,
            UserGuessDataInput[] memory guessData
        )
    {
        //matchData[matchId].guessDataInput = guessDatas;
        uint256 length = matchData[matchId].guessDataInput.length;
        UserGuessDataInput[] memory guessDatas = new UserGuessDataInput[](
            length
        );
        for (uint256 i = 0; i < length; i++) {
            guessDatas[i] = matchData[matchId].guessDataInput[i];
        }
        return (
            matchData[matchId].islocked,
            matchData[matchId].times,
            matchData[matchId].matchTime,
            matchData[matchId].updateTime,
            block.timestamp,
            guessDatas
        );
    }

    function setUserGuessData(
        bytes32 matchId,
        UserGuessDataInput calldata _userGuessData
    ) external {
        require(!isStopGame, "code0:game stop");
        require(!isSetMatchResult[matchId], "code401:result had set");
        require(!isContract(msg.sender), "code000:address is invalid");
        (
            bool isExist,
            uint256 tokenId,
            bytes32 nftTypeId, // address agentAddress

        ) = getNftInfo(msg.sender);
        require(isExist, "code001:not have NFT");
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        require(
            !isNFTlocked[tokenId] ||
                block.timestamp - NFTorderTime[tokenId] >
                _tokenMeta.lockTime_h * 3600,
            "code002:NFT status locked"
        );
        require(_userGuessData.rate < 100001, "code003:max rate is 1000x");
        require(
            !matchData[matchId].islocked && matchData[matchId].matchTime > 0,
            "code004:match locked"
        );
        require(
            matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "code005:time  less than 10 minutes"
        );
        require(
            isRateEqual(matchData[matchId].guessDataInput, _userGuessData),
            "code006:rate wrong"
        );
        uint256 guessTime = block.timestamp;
        UserGuessDataAndTimeForOrder memory _userOrder;
        _userOrder.guessTime = guessTime;
        _userOrder.matchId = matchId;
        _userOrder.guessId = _userGuessData.guessId;
        _userOrder.rate = _userGuessData.rate;
        _userOrder.nftTypeId = nftTypeId;
        _userOrder.baseCoin = _tokenMeta.baseCoin;
        //-----------------------------------------------------------
        if (!isMatchIncludeTokenId[matchId][tokenId][guessTime]) {
            //userGuessDataNFTTokenIds[matchId].push(tokenId);
            isMatchIncludeTokenId[matchId][tokenId][guessTime] = true;
        }
        userGuessData[matchId][tokenId][guessTime] = _userOrder;
        userGuessDataForOrder[tokenId].push(_userOrder);
        NFTorderTime[tokenId] = block.timestamp;
        isNFTlocked[tokenId] = true;
        matchBeginTime[tokenId] = matchData[matchId].matchTime;
        if (!isNFTUsing[tokenId]) {
            isNFTUsing[tokenId] = true;
            NFTuseTime[tokenId] = block.timestamp;
            NFTFirstuseTime[tokenId] = block.timestamp;
        }
    }

    function forceUnLockNFT() external {
        (
            bool isExist,
            uint256 tokenId,
            bytes32 nftTypeId, // address agentAddress

        ) = getNftInfo(msg.sender);
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        require(isExist, "code001:not have NFT");
        require(
            isNFTlocked[tokenId] &&
                block.timestamp - NFTorderTime[tokenId] <
                _tokenMeta.lockTime_h * 3600,
            "code009:NFT unlocked"
        );
        require(
            block.timestamp - matchBeginTime[tokenId] > 0,
            "code010:time of force unlock not reach"
        );
        uint256 forceMount = _tokenMeta.baseCoin *
            _tokenMeta.unlockRate *
            10**16;
        require(
            guessToken.balanceOf(msg.sender) >= forceMount,
            "code101: GUESS TOKEN Not enough"
        );

        uint256 allowance = guessToken.allowance(msg.sender, address(this));
        require(allowance >= forceMount, "code102:Check allowance");
        guessToken.transferFrom(msg.sender, address(this), forceMount);
        //isNFTlocked[tokenId] = false;
        _forceUnLockNFT(tokenId);
    }

    function _forceUnLockNFT(uint256 tokenId) private {
        isNFTlocked[tokenId] = false;
    }

    function reStore() external {
        (
            uint256 availableRate,
            bytes32 nftTypeId,
            uint256 tokenId
        ) = getAvailableRate();
        require(availableRate < 100, "code301:NFT not need to reStore");
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        uint256 restoreToken = _tokenMeta.baseCoin *
            _tokenMeta.restoreRate *
            (100 - availableRate) *
            (10**14);
        require(
            guessToken.balanceOf(msg.sender) >= restoreToken,
            "code101:GUESS TOKEN Not enough"
        );
        uint256 allowance = guessToken.allowance(msg.sender, address(this));
        require(allowance >= restoreToken, "code102:Check allowance");
        guessToken.transferFrom(msg.sender, address(this), restoreToken);
        NFTuseTime[tokenId] = block.timestamp;
    }

    function getAvailableRate()
        public
        view
        returns (
            uint256,
            bytes32,
            uint256
        )
    {
        (
            bool isExist,
            uint256 tokenId,
            bytes32 nftTypeId, // address agentAddress

        ) = getNftInfo(msg.sender);
        require(isExist, "code001:not have nft");
        if (NFTuseTime[tokenId] == 0) {
            return (100, nftTypeId, tokenId);
        }
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        uint256 difftime = block.timestamp - NFTuseTime[tokenId];
        uint256 times = difftime /
            (_tokenMeta.depreciateCycle_d * 24 * 60 * 60);
        uint256 diffnumber = times * _tokenMeta.depreciateCycleRate;
        uint256 availableRate = 100 - (diffnumber > 100 ? 100 : diffnumber);
        return (availableRate, nftTypeId, tokenId);
    }

    address public gTa;
    address public oTa;

    function setGuessToken(address _gTa, address _oTa) external onlyOwner {
        gTa = _gTa;
        oTa = _oTa;
        guessToken = IERC20(_gTa);
        openToken = IERC20(_oTa);
    }

    //returns (UserGuessDataAndTimeForOrder[] memory
    function getUserGuessDataForOrder(uint256 page, uint256 count)
        external
        view
        returns (UserGuessDataAndTimeForOrder[] memory orders, uint256 length)
    {
        require(page > 0, "page 0");
        (bool isExist, uint256 tokenId, , ) = getNftInfo(msg.sender);
        require(isExist, "not have NFT");
        //return userGuessDataForOrder[msg.sender];
        UserGuessDataAndTimeForOrder[] memory _os = userGuessDataForOrder[
            tokenId
        ];

        if (_os.length == 0) return (_os, 0);
        require(_os.length > (page - 1) * count, "page out");
        uint256 arr_length = _os.length > page * count
            ? count
            : _os.length - (page - 1) * count;
        //uint256 startIndex = (page - 1) * count;
        uint256 endIndex = _os.length - (page - 1) * count - 1;
        UserGuessDataAndTimeForOrder[]
            memory temp = new UserGuessDataAndTimeForOrder[](arr_length);
        uint256 times = 0;
        for (uint256 i = endIndex; i >= 0; i--) {
            //  temp[times] = _os[i];
            temp[times] = userGuessData[_os[i].matchId][tokenId][
                _os[i].guessTime
            ];
            times++;
            if (times == arr_length) break;
        }
        return (temp, _os.length);
    }

    // function getuserGuessDataNFTTokenIds(bytes32 matchId)
    //     external
    //     view
    //     onlyOwner
    //     returns (uint256[] memory)
    // {
    //     return userGuessDataNFTTokenIds[matchId];
    // }

    function getBalanceAgent() external view returns (uint256) {
        return balanceAgent[msg.sender];
    }

    // --------------------------------------------------------------------------------------

    address[6] public admins;
    mapping(address => bool) public isAdmin;

    function setAdmin(uint256 i, address _a) external onlyOwner {
        require(i < 6, "index range out");
        require(_a != address(0), "address invaild");
        if (admins[i] != address(0)) {
            isAdmin[_a] = false;
        }
        admins[i] = _a;
        isAdmin[_a] = true;
    }

    //---------------------------------------------------------------------------------------
    function userCheckResult(bytes32 matchId, uint256 orderid) external {
        require(isSetMatchResult[matchId], "code410:result uping to block");
        (
            bool isExist,
            uint256 tokenId,
            bytes32 nftTypeId,
            address agentAddress
        ) = getNftInfo(msg.sender);
        require(isExist, "code001:not has NFT");
        require(
            isMatchIncludeTokenId[matchId][tokenId][orderid],
            "code411:no guess this match"
        );
        require(!isContract(msg.sender), "code000:address invaild");
        (uint256 availableRate, , ) = getAvailableRate();
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        UserGuessDataAndTimeForOrder memory _userGuessData = userGuessData[
            matchId
        ][tokenId][orderid];
        uint256 canMintCount = 0;
        require(!_userGuessData.isCheck, "code444:why mint it");
        userGuessData[matchId][tokenId][orderid].isCheck = true;
        bytes32 guessId = _userGuessData.guessId;

        if (matchResult[matchId].length == 0) {
            uint256 winCount = _tokenMeta.baseCoin * 25 * availableRate;
            canMintCount += (winCount * 10**14);
        } else if (checkOrder(matchResult[matchId], guessId)) {
            uint256 rate = _userGuessData.rate;
            uint256 winCount = _tokenMeta.baseCoin * rate * availableRate;
            canMintCount += (winCount * 10**14);

            balanceAgent[agentAddress] += (winCount * 2 * 10**12);
        }

        require(canMintCount > 0, "code444:why mint it");
        mintGuessToken(canMintCount);
        _forceUnLockNFT(tokenId);
    }

    function mintGuessToken(uint256 amount) private {
        (bool success, ) = gTa.call(
            abi.encodeWithSignature("mint(address,uint256)", msg.sender, amount)
        );
        require(success, "code414:mint fail");
    }

    function setMatchResult(bytes32 matchId, bytes32[] calldata results)
        external
        onlyAdmins
    {
        require(!isSetMatchResult[matchId], "code401:result had set");
        require(matchData[matchId].times > 0, "code404:matchData null");
        // require(
        //     matchData[matchId].matchTime < block.timestamp,
        //     "code408:time not reach"
        // );
        matchResult[matchId] = results;
        isSetMatchResult[matchId] = true;
    }

    function checkOrder(bytes32[] memory results, bytes32 guessId)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < results.length; i++) {
            if (
                keccak256(abi.encodePacked(results[i])) ==
                keccak256(abi.encodePacked(guessId))
            ) {
                return true;
            }
        }
        return false;
    }

    // help----------------------------------------------------
    function isRateEqual(
        UserGuessDataInput[] memory guessDataInput,
        UserGuessDataInput calldata _userGuessData
    ) private pure returns (bool) {
        for (uint256 i = 0; i < guessDataInput.length; i++) {
            if (
                keccak256(abi.encodePacked(guessDataInput[i].guessId)) ==
                keccak256(abi.encodePacked(_userGuessData.guessId))
            ) {
                if (guessDataInput[i].rate == _userGuessData.rate) {
                    return true;
                } else {
                    return false;
                }
            }
        }
        return false;
    }

    //unitity
    function isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }

    //nft
    function getNftInfo(address from)
        public
        view
        returns (
            bool,
            uint256,
            bytes32,
            address
        )
    {
        return iGuessNft.forGuess(from);
    }

    function getUserInfo() external view returns (HtmlUserinfo memory) {
        (
            bool _isHasNFT,
            uint256 _tokenId,
            bytes32 _nftId,
            address _agent
        ) = iGuessNft.forGuess(msg.sender);
        HtmlUserinfo memory _user;
        if (_isHasNFT) {
            _user.isHasNFT = _isHasNFT;
            _user.tokenId = _tokenId;
            _user.nftId = _nftId;
            _user.agent = _agent;
            _user.NFTuseTime = NFTuseTime[_tokenId];
            _user.isNFTUsing = isNFTUsing[_tokenId];

            _user.isNFTlocked = isNFTlocked[_tokenId];
            _user.NFTorderTime = NFTorderTime[_tokenId];
            _user.matchBeginTime = matchBeginTime[_tokenId];
        }
        _user.balance = balanceAgent[msg.sender];
        return _user;
    }

    struct HtmlUserinfo {
        bool isHasNFT;
        uint256 tokenId;
        bytes32 nftId;
        address agent;
        uint256 NFTuseTime;
        bool isNFTUsing;
        uint256 balance;
        bool isNFTlocked;
        uint256 NFTorderTime;
        uint256 matchBeginTime;
    }
    // temp copy ---------------------------------------------------------------------------------

    // ower---------------------------------------------------------------------------------------

    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "not Owner");
        _;
    }
    modifier onlyAdmins() {
        require(msg.sender == owner || isAdmin[msg.sender], "not Admins");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "address invaild");
        owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IguessNft {
    function forGuess(address from)
        external
        view
        returns (
            bool,
            uint256,
            bytes32,
            address
        );
}