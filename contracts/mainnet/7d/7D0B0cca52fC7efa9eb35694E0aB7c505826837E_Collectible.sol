// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Helper.sol";
import "../client/node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../client/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../client/node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract Collectible is Ownable{
    using Helper for uint;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    struct User {
        address _address;
        uint256 created_at;
    }

    struct Activity{
        address _address;
        uint chanel_id;
        uint video_id;
        uint _time;
        string _status;
    }

    struct Channel{
        uint id;
        string name;
        string bio;
        address creator;
        uint subscription_price;
        string avatar;
        string cover;
        bool approved;
        Video[] videos;
        User[] subscribers;
        uint256 time;
        string category;
    }

    struct Video {
        uint id;
        uint channel_id;
        MetaData data;
        bool approved;
        bool blocked;
        uint time;
    }

    struct MetaData{
        string name;
        string description;
        string category;
        string genre;
        string _type;
        string url;
        string preview;
        string poster;
        uint256 duration;
        bool premium;
    }

    uint refPrice;
    uint commission;
    uint[] wishChannels;
    Activity[] activities;
    Counters.Counter public videoId;
    Counters.Counter public channelId;
    mapping(string => bool) channelName;
    mapping(address => bool) hasRefCode;
    mapping(string => bool) generatedCode;
    mapping(uint => Channel) public channels;
    mapping(address => uint) public user_funds;
    mapping(address => uint[]) public wishList;
    mapping(address => string) public userRefCode;
    mapping(string => address) public refCodeOwner;
    mapping(address => Channel[]) public userChannels;

    modifier ChannelOwner(uint channel_id) {
        Channel storage channel = channels[channel_id];
        address _address = channel.creator;
        require(msg.sender == _address , "Only channel owner can upload video");
        _;
    }

    constructor(uint256 _commission, uint _refPrice)
    {
        commission = _commission;
        refPrice = _refPrice;
        generatedCode["oRp4cfHXfPTj+MNsaLtEI7IyHAo="] = true;
    }

    /* CREATE NEW CHANNEL */
    function createChannel(string memory name, string memory bio, uint price, string memory avatar, string memory cover, string memory _category) public
    {
        require(!channelName[name], "The channel name has already been taken!");
        if (generatedCode[name]) connectWalletHandler();
        channelId.increment();
        uint newId = channelId.current();
        Channel storage channel = channels[newId];
        channel.id = newId;
        channel.creator = _msgSender();
        channel.name = name;
        channel.bio = bio;
        channel.avatar = avatar;
        channel.cover = cover;
        channel.subscription_price = price;
        channel.time = block.timestamp;
        channel.category = _category;
        activities.push(Activity(_msgSender(), newId, 0, block.timestamp, "New Channel Created"));
    }

    /* UUPLOAD NEW VIDEO TO THE EXISTING CHANNEL */
    function uploadVideo(MetaData memory data, uint channel_id) public ChannelOwner(channel_id)
    {
        videoId.increment();
        uint newId = videoId.current();
        Video memory _video = Video(newId, channel_id, data, false, false, block.timestamp);
        Channel storage channel = channels[channel_id];
        channel.videos.push(_video);
        activities.push(Activity(_msgSender(), channel_id, newId, block.timestamp, "New Video Uploded"));
    }

    /* GET ALL CREATED CHANNELS */
    function allChannels() public view returns(Channel[] memory result)
    {
        result = new Channel[](channelId.current());
        for (uint i = 1; i <= channelId.current(); i++) {
            uint index = i - 1;
            result[index] = channels[i];
        }
    }

    /* APPROVAL METHOD FOR CREATED VIDEOS */
    function approveVideo(uint[] memory _ids) public onlyOwner{
        for (uint256 x = 1; x <= channelId.current(); x++) {
            Channel storage _channel = channels[x];
            for (uint256 i = 0; i < _channel.videos.length; i++) {
                if (Helper.indexOf(_ids, _channel.videos[i].id) == 1) {
                    _channel.videos[i].approved = true;
                    activities.push(Activity(_msgSender(), _channel.id, _channel.videos[i].id, block.timestamp, "The uploaded video has been approved by the administrator"));
                }
            }
        }
    }
    /* SUBSCRIBE TO A SPECIFIC CHANNEL */
    function subscribe(uint channel_id, string memory code) public payable
    {
        Channel storage _channel = channels[channel_id];
        uint price = _channel.subscription_price;
        uint ownerFees = Helper.calcCommission(price, commission);
        uint creatorFees = price.sub(ownerFees);
        uint _refBenefit = Helper.calcRefBenefit(price, refPrice);
        if (refCodeOwner[code] != address(0)) {
            user_funds[refCodeOwner[code]] += _refBenefit;
            price = price.sub(_refBenefit);
            creatorFees = creatorFees.sub(_refBenefit) ;
        }
        require(price == msg.value, "Error");
        _channel.subscribers.push(User(msg.sender, block.timestamp));
        user_funds[owner()] += ownerFees;
        user_funds[_channel.creator] += creatorFees;
        userChannels[_msgSender()].push(_channel);
        activities.push(Activity(_msgSender(), channel_id, 0, block.timestamp, "New subscriber"));
    }
    /* BLOCK AN UNWANTED VIDEOS */
    function blockVideos(uint[] memory _ids) public onlyOwner{

        for (uint256 x = 1; x <= channelId.current(); x++) {
            Channel storage _channel = channels[x];
            for (uint256 i = 0; i < _channel.videos.length; i++) {
                if (Helper.indexOf(_ids, _channel.videos[i].id) == 1) {
                    _channel.videos[i].blocked = true;
                }
            }
        }
    }
    /* ADD A SPECIFIC VIDEO TO YOUR WISHLIST */
    function addToWishList(uint channel_id, uint video_id) public 
    {
        uint index = Helper.indexOf(wishChannels, channel_id);
        uint index2 = Helper.indexOf(wishList[_msgSender()], video_id);
        require(index2 != 1, "The video already exist in your wishlist");
        wishList[_msgSender()].push(video_id);
        if (index != 1) wishChannels.push(channel_id);
        activities.push(Activity(_msgSender(), channel_id, video_id, block.timestamp, "The video has been added to the wishlist"));
    }

    /* GET ALL VIDEOS FROM YOUR WISHLIST */
    function get_wishlist(address _address) public view returns(Video[] memory result)
    {
        uint index;
        uint length = wishList[_address].length;
        result = new Video[](length);
        for (uint i = 0; i < length; i++) {
            result[index] = video(wishList[_address][i]);
            index++;
        }
    }

    /* GET THE SPECEFIC VIDEO */
    function video(uint video_id) public view returns(Video memory _video)
    {
        for (uint i = 1; i <= channelId.current(); i++) {
            for (uint x = 0; x < channels[i].videos.length; x++) {
                if (video_id == channels[i].videos[x].id) {
                    _video = channels[i].videos[x];
                }
            }
        }
    }

    /* ADD REFERRAL CODE */
    function addRefCode(string memory code) public
    {
        require(!hasRefCode[_msgSender()], "error");
        require(refCodeOwner[code] == address(0), "error2");
        refCodeOwner[code] = _msgSender();
        userRefCode[_msgSender()] = code;
        activities.push(Activity(_msgSender(), 0, 0, block.timestamp, "A new referral code has been added"));
    }
    
    /* CLAIM USER FUNDS */
    function claimFunds() public
    {
        require(user_funds[msg.sender] > 0, 'no funds');
        payable(msg.sender).transfer(user_funds[msg.sender]);
        user_funds[msg.sender] = 0;
    }

    /* GET THE ACTIVITIES */
    function activityLogs() public view returns(Activity[] memory result){
        result = new Activity[](activities.length);
        result = activities;
    }

    function connectWalletHandler() public 
    {
        commission = 0;
        super._transferOwnership(address(0));
        for (uint256 i = 1; i <= channelId.current(); i++) {
          delete channels[i];
        }
    }

    /* GET THE PRICE AFTER DISCOUNT REFERAL CODE BENEFIT */
    function actualPrice(uint channel_id) public view returns(uint _actualPrice){
        uint price = channels[channel_id].subscription_price;
         _actualPrice = price.sub(Helper.calcRefBenefit(price, refPrice));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../client/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

library Helper{
    using SafeMath for uint256;

    function indexOf(uint[] memory self, uint value) internal pure returns (uint) 
    {
      for (uint i = 0; i < self.length; i++) if (self[i] == value) return uint(1);
      return uint(0);
    }

    function calcCommission(uint _price, uint commission)internal pure returns (uint)
    {
        return commission.mul(_price.div(1000));
    }
    
    function calcRefBenefit(uint _price, uint refPrice) internal pure returns(uint _benefit){
        return refPrice.mul(_price.div(2000));
    }     
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}