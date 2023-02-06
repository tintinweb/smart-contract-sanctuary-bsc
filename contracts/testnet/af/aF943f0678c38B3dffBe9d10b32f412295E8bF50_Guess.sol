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
library SafeMath {
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
pragma solidity ^0.8.7;

// import "./mathlib.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IguessNft.sol";

contract Guess {
    using SafeMath for uint256;

    // football and basketball guess struct
    struct UserGuessDataInput {
        string guessId;
        uint32 rate;
        // uint256 guessTime;
    }
    //user  order data

    struct UserGuessDataAndTimeForOrder {
        string guessId;
        uint32 rate;
        uint256 guessTime;
        string nftTypeId;
        uint256 baseCoin;
        bool isCheck;
        string matchId;
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
    //string is matchid
    mapping(string => MatchGuessData) private matchData;
    mapping(string => mapping(uint256 => UserGuessDataAndTimeForOrder[]))
        private userGuessData;
    mapping(string => uint256[]) private userGuessDataNFTTokenIds;
    mapping(uint256 => UserGuessDataAndTimeForOrder[])
        private userGuessDataForOrder;
    mapping(string => bool) public checkMatch;
    mapping(string => string[]) public matchResult;
    mapping(string => mapping(uint256 => bool)) public isMatchIncludeTokenId;
    mapping(address => uint256) public balance;
    mapping(address => bool) public isKolAgent;
    mapping(uint256 => bool) public isNFTlokced;
    mapping(uint256 => uint256) public NFTorderTime;
    mapping(uint256 => bool) public isLogRefreshTime;
    mapping(uint256 => uint256) public NFTuseingTime;
    uint256 agentRate = 2; //2
    // address public nftAddress;
    IguessNft iGuessNft;
    struct TokenMeta {
        uint256 baseCoin; //eg:1000
        uint256 lockTime_h; //eg:72hour
        uint256 unlockRate; //eg:0.75
        uint256 depreciateCycle_d; //eg:30
        uint256 depreciateCycleRate; // eg: 0.1
        uint256 restoreRate; //eg:2
        uint256 end_depreciate; //eg: 0.3
    }
    mapping(string => TokenMeta) public _tokenMetas;
    mapping(string => bool) public _tokenTypesExist;
    string[] public _tokenTypes;

    // end——————————————————————————————————————————————————————————————————————————————

    constructor(
        address _nftAddress,
        string[] memory typeIDs,
        TokenMeta[] memory tokenMetas
    ) {
        owner = msg.sender;
        iGuessNft = IguessNft(_nftAddress);
        setTokeMetaList(typeIDs, tokenMetas);
    }

    function setTokeMeta(string memory typeID, TokenMeta memory tokenMeta)
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
        string[] memory typeIDs,
        TokenMeta[] memory tokenMetas
    ) public onlyOwner {
        for (uint256 index = 0; index < typeIDs.length; index++) {
            setTokeMeta(typeIDs[index], tokenMetas[index]);
        }
    }

    function setKolAgent(address _address) external onlyOwner {
        require(
            _address != address(0) && !isKolAgent[_address],
            "the address is exist"
        );
        isKolAgent[_address] = true;
    }

    function setAgentRate(uint256 rate) external onlyOwner {
        require(rate >= 1 && rate <= 3, "the rate must [1,3]");
        agentRate = rate;
    }

    /////Ower
    function setMatchData(
        string calldata matchId,
        uint256 matchTime,
        UserGuessDataInput[] calldata guessDatas
    ) external onlyOwner {
        require(!matchData[matchId].islocked, "this match is locked");
        require(
            matchData[matchId].matchTime == 0 ||
                matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "begintime is less than 10 minutes, no more submissions will be accepted"
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
    function setMatchLocked(string calldata matchId) external onlyOwner {
        // require(
        //     matchData[matchId].guessDataInput.length > 0,
        //     "no data no locked"
        // );
        require(!matchData[matchId].islocked, "this match is locked");
        matchData[matchId].islocked = true;
    }

    function getMatchData(string calldata matchId)
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
        string calldata matchId,
        UserGuessDataInput calldata _userGuessData
    ) external {
        require(!isContract(msg.sender), "code000:address is invalid");
        (
            bool isExist,
            uint256 tokenId,
            string memory nftTypeId, // address agentAddress

        ) = getNftInfo(msg.sender);
        require(isExist, "code001:you don't have GuessGlasses");
        TokenMeta memory _tokenMeta = _tokenMetas[nftTypeId];
        //block.timestamp - NFTorderTime[tokenId] > _tokenMeta.lockTime_h * 6; //*60*60;
        require(
            !isNFTlokced[tokenId] ||
                block.timestamp - NFTorderTime[tokenId] >
                _tokenMeta.lockTime_h * 6,
            "code002:your NFT status is locked"
        );
        require(_userGuessData.rate < 100001, "code003:max rate is 1000x");
        require(
            !matchData[matchId].islocked && matchData[matchId].matchTime > 0,
            "code004:this match is locked"
        );
        require(
            matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "code005:begintime is less than 10 minutes, no more submissions will be accepted"
        );
        require(
            isRateEqual(matchData[matchId].guessDataInput, _userGuessData),
            "code006:the rate is wrong"
        );
        UserGuessDataAndTimeForOrder memory _userGuessDataForOrder;
        _userGuessDataForOrder.guessTime = block.timestamp;
        _userGuessDataForOrder.matchId = matchId;
        _userGuessDataForOrder.guessId = _userGuessData.guessId;
        _userGuessDataForOrder.rate = _userGuessData.rate;
        _userGuessDataForOrder.nftTypeId = nftTypeId;

        _userGuessDataForOrder.baseCoin = _tokenMeta.baseCoin;

        //-----------------------------------------------------------
        if (
            // !containGuessDataAdress(msg.sender, userGuessDataNFTTokenIds[matchId])
            !isMatchIncludeTokenId[matchId][tokenId]
        ) {
            userGuessDataNFTTokenIds[matchId].push(tokenId);
            isMatchIncludeTokenId[matchId][tokenId] = true;
        }

        userGuessData[matchId][tokenId].push(_userGuessDataForOrder);
        userGuessDataForOrder[tokenId].push(_userGuessDataForOrder);
        NFTorderTime[tokenId] = block.timestamp;
        isNFTlokced[tokenId] = true;
        if (!isLogRefreshTime[tokenId]) {
            isLogRefreshTime[tokenId] = true;
            NFTuseingTime[tokenId] = block.timestamp;
        }
    }

    function containGuessDataAdress(
        address sender,
        address[] memory addressList
    ) private pure returns (bool) {
        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] == sender) {
                return true;
            }
        }
        return false;
    }

    //returns (UserGuessDataAndTimeForOrder[] memory
    function getUserGuessDataForOrder(uint256 page, uint256 count)
        external
        view
        returns (UserGuessDataAndTimeForOrder[] memory orders, uint256 length)
    {
        require(page > 0, "page must more than 0");
        (bool isExist, uint256 tokenId, , ) = getNftInfo(msg.sender);
        require(isExist, "you don't have GuessGlass NFT");
        //return userGuessDataForOrder[msg.sender];
        UserGuessDataAndTimeForOrder[] memory _orders = userGuessDataForOrder[
            tokenId
        ];

        if (_orders.length == 0) return (_orders, 0);
        require(_orders.length > (page - 1) * count, "pages out");
        uint256 arr_length = _orders.length > page * count
            ? count
            : _orders.length - (page - 1) * count;
        uint256 startIndex = (page - 1) * count;
        uint256 endIndex = startIndex + arr_length - 1;
        UserGuessDataAndTimeForOrder[]
            memory temp = new UserGuessDataAndTimeForOrder[](arr_length);
        uint256 times = 0;
        for (uint256 i = endIndex; i >= startIndex; i--) {
            temp[times] = _orders[i];
            times++;
            if (times == arr_length) break;
        }
        return (temp, _orders.length);
    }

    function getUserGuessData(string calldata matchId)
        external
        view
        returns (UserGuessDataAndTimeForOrder[] memory)
    {
        (bool isExist, uint256 tokenId, , ) = getNftInfo(msg.sender);
        require(isExist, "you don't have GuessGlass NFT");
        return userGuessData[matchId][tokenId];
    }

    /**ower function */
    function getUserGuessDataFrom(string calldata matchId, address from)
        external
        view
        onlyOwner
        returns (UserGuessDataAndTimeForOrder[] memory)
    {
        (bool isExist, uint256 tokenId, , ) = getNftInfo(from);
        require(isExist, "you don't have GuessGlass NFT");
        return userGuessData[matchId][tokenId];
    }

    function getuserGuessDataNFTTokenIds(string calldata matchId)
        external
        view
        onlyOwner
        returns (uint256[] memory)
    {
        return userGuessDataNFTTokenIds[matchId];
    }

    function getBalanceFrom(address _from)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return balance[_from];
    }

    function getBalance() external view returns (uint256) {
        return balance[msg.sender];
    }

    // --------------------------------------------------------------------------------------
    // function setMatchResult(string calldata matchId, string[] calldata results)
    //     external
    //     onlyOwner
    //     returns (uint256 count)
    // {
    //     require(!checkMatch[matchId], "the match is check");
    //     require(matchData[matchId].times > 0, "the match data is null");
    //     matchResult[matchId] = results;
    //     uint256 winCount = 0;

    //     // UserGuessDataAndTime
    //     address[] memory _addresses = userGuessDataNFTTokenIds[matchId];
    //     mapping(address => UserGuessDataAndTime[])
    //         storage matchOrders = userGuessData[matchId];
    //     for (uint256 i = 0; i < _addresses.length; i++) {
    //         UserGuessDataAndTime[] storage userOrders = matchOrders[
    //             _addresses[i]
    //         ];
    //         for (uint256 j = 0; j < userOrders.length; j++) {
    //             if (userOrders[j].isCheck) continue;
    //             if (checkOrder(results, userOrders[j].guessId)) {
    //                 balance[_addresses[i]] = balance[_addresses[i]].add(
    //                     10000 * userOrders[j].rate
    //                 );
    //                 winCount += 1;
    //             }
    //             userOrders[j].isCheck = true;
    //         }
    //     }
    //     checkMatch[matchId] = true;
    //     return winCount;
    // }

    function checkOrder(string[] calldata results, string memory guessId)
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
        if (bytes(_userGuessData.guessId).length > 128) return false;
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
            string memory,
            address
        )
    {
        return iGuessNft.forGuess(from);
    }

    // temp copy ---------------------------------------------------------------------------------

    // ower---------------------------------------------------------------------------------------

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not Owner");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "new owner must be a really address");
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
            string memory,
            address
        );
}