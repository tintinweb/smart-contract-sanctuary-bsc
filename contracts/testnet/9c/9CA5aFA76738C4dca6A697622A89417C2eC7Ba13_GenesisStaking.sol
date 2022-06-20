/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// File: contracts/CyberTiger/Staking/Context.sol


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
// File: contracts/CyberTiger/Staking/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
// File: contracts/CyberTiger/Staking/IERC20.sol



pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// File: contracts/CyberTiger/Staking/SafeMath.sol


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
// File: contracts/CyberTiger/Staking/IGenenisNFT.sol

//V2

pragma solidity ^0.8.2;

interface IGenenisNFT {  

    enum nftRarity {
         Common,
         Rare,
         SuperRare
    }


    struct GenesisNFTStruct {
        nftRarity rarity;
        uint8 status;
    }
    

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function safeMint(address to, string memory tokenUri) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function tokenOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tigerDna(uint256 tokenId) view external returns (GenesisNFTStruct memory);


    

}
// File: contracts/CyberTiger/Staking/StakingGenenisNFT.sol



pragma solidity ^0.8.2;





contract GenesisStaking is Ownable {
    using SafeMath for uint256;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    IERC20 public rewardsToken;
    IGenenisNFT public genesisNFT;

    /// @notice total ethereum staked currently in the gensesis staking contract
    uint256 public lastUpdateTime;


    uint256 public tokenPrice;

    /**
    @notice Struct to track what user is staking which tokens
    @dev tokenIds are all the tokens staked by the staker
    @dev balance is the current ether balance of the staker
    @dev rewardsEarned is the total reward for the staker till now
    @dev rewardsReleased is how much reward has been paid to the staker
    */

    struct nftsStaked { 
        uint256 tokenId;
        uint256 stakeTime;
        uint256 startStake;
        uint256 rewards;
        address owner;
    }

    struct Staker {
        uint256[] tokenIds;
        mapping (uint256 => uint256) tokenIndex;
        uint256 totalRewardsRelease;
    }

    /// Mapping from rarity to rewards

    mapping (uint256 => uint256 ) public percentRewards;
    mapping (uint256 => uint256 ) public priceByRarity;

    /// Mapping token stake one times;
    
    mapping (uint256 => bool) public isStaked;

    /// @notice mapping of a staker to its current properties
    mapping (address => Staker) public stakers;
    mapping (uint256 => nftsStaked) public nftStaked;
    mapping (address => mapping(uint256 => nftsStaked ) ) public stakedNftByOwner;

    // Mapping from token ID to owner address
    mapping (uint256 => address) public tokenOwner;

    /// @notice tokenId => amount contributed
    mapping (uint256 => uint256) public contribution;

    /// @notice sets the token to be claimable or not, cannot claim if it set to false
    bool public tokensClaimable;
    bool initialised;

    /// @notice event emitted when a user has staked a token
    event Staked(address owner, uint256 amount);

    /// @notice event emitted when a user has unstaked a token
    event Unstaked(address owner, uint256 amount);

    /// @notice event emitted when a user claims reward
    event RewardPaid(address indexed user, uint256 reward);
    
    /// @notice Allows reward tokens to be claimed
    event ClaimableStatusUpdated(bool status);

    /// @notice Emergency unstake tokens without rewards
    event EmergencyUnstake(address indexed user, uint256 tokenId);

    // @notice event emitted when a contributors amount is increased
    event ContributionIncreased(
        uint256 indexed tokenId,
        uint256 contribution
    );

    constructor(address _mainToken, address _mainNFT) public {
        rewardsToken = IERC20(_mainToken);
        genesisNFT = IGenenisNFT(_mainNFT);
        
    }

    function setTokenPrice(uint256 price) public onlyOwner { 
        require(price > 0, "Price isn't valid ");

        tokenPrice = price;

    }

     /**`
     * @dev Single gateway to intialize the staking contract after deploying
     * @dev Sets the contract with the MONA genesis NFT and MONA reward token 
     */
    function initGenesisStaking(
        address payable _fundsMultisig,
        IERC20 _rewardsToken,
        IGenenisNFT _genesisNFT
    )
        public
    {
        require(!initialised, "Already initialised");
        rewardsToken = _rewardsToken;
        genesisNFT = _genesisNFT;
        lastUpdateTime = block.timestamp;
        initialised = true;
    }


    function setTokensClaimable(
        bool _enabled
    )
        external
    {
        tokensClaimable = _enabled;
        emit ClaimableStatusUpdated(_enabled);
    }

    /// @dev Getter functions for Staking contract
    /// @dev Get the tokens staked by a user
    function getStakedTokens(
        address _user
    )
        external
        view
        returns (uint256[] memory tokenIds)
    {
        return stakers[_user].tokenIds;
    }


    /// @dev Get the amount a staked nft is valued at ie bought at

    function getTigerRarity(uint256 tokenId) public view returns (IGenenisNFT.nftRarity) { 
        IGenenisNFT.GenesisNFTStruct memory _tigerDna = genesisNFT.tigerDna(tokenId);
        return _tigerDna.rarity;
    }


    function setPercentEarnByRarity(uint256 rarity,uint256 percent) public onlyOwner{
        require(rarity <= 2, "Undefined Rarity");
        require(percent > 0, "inValid Percent" );
        percentRewards[rarity] = percent;
    }

    ///@dev calculator amount can get when stake nfts by Rarity ( price ) 
    function setPriceByRarity(
        uint256 rarity,
        uint256 price 
    ) public onlyOwner { 
        require(rarity <= 2, "Undefined Rarity");
        require(price > 0, "inValid price" );
        priceByRarity[rarity] = price * 10 ** 18;
    }

    function getRewardsByRarity( 
        uint256 rarity
    )
        public 
        view
        returns (uint256 amount) { 

        require(rarity <= 2, "Undefined Rarity");

        uint256 rewardsByRarity = (priceByRarity[rarity].mul(percentRewards[rarity]).div(100)).div(tokenPrice);

        return rewardsByRarity;
        
    }

    function getStakedNFTInfo(address _user, uint256 _tokenId) public view returns (uint256 stakeMonth,uint256 blockStake ,uint256 rewards) { 
        nftsStaked storage x = stakedNftByOwner[_user][_tokenId];
        return (
            x.stakeTime,
            x.startStake,
            x.rewards
        );
    }


    /// @notice Stake Genesis MONA NFT and earn reward tokens. 

    function stake(
        uint256 tokenId,
        uint256 time
    )
        external
    {
        require(isStaked[tokenId] == false, "staked NFTs");
        require(genesisNFT.ownerOf(tokenId) == msg.sender, "Only NFT's owner can stake !");
        _stake(msg.sender, tokenId,time);
    }

    /// @notice Stake all your MONA NFTs and earn reward tokens. 
    function stakeAll(uint256 time)
        external
    {
        uint256 balance = genesisNFT.balanceOf(msg.sender);
        for (uint i = 0; i < balance; i++) {
            _stake(msg.sender, genesisNFT.tokenOwnerByIndex(msg.sender,i),time);
        }
    }

    /**
     * @dev All the staking goes through this function
     * @dev Rewards to be given out is calculated
     * @dev Balance of stakers are updated as they stake the nfts based on ether price
    */
    function _stake(
        address _user,
        uint256 _tokenId,
        uint256 time
    )
        internal
    {
        Staker storage staker = stakers[_user];
        nftsStaked storage nftStake = nftStaked[_tokenId];

    // Get NFTs stake info.

    uint8 _tigerRarity = uint8(getTigerRarity(_tokenId));

    uint256 rewards = getRewardsByRarity(_tigerRarity);


    /// update stake nft info

        nftStake.tokenId = _tokenId;
        nftStake.stakeTime = time;
        nftStake.startStake = block.timestamp;
        nftStake.rewards = rewards;
        nftStake.owner = _user;

    // Update staker info

        staker.tokenIds.push(_tokenId);
        staker.tokenIndex[staker.tokenIds.length - 1];
        tokenOwner[_tokenId] = _user;
        stakedNftByOwner[_user][_tokenId] = nftStake;
        isStaked[_tokenId] = true;

        genesisNFT.safeTransferFrom(
            _user,
            address(this),
            _tokenId
        );


        emit Staked(_user, _tokenId);
    }

    /// @notice Unstake Genesis MONA NFTs. 
    function unstake(
        uint256 _tokenId
    ) 
        external 
    {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "GenesisStaking._unstake: Sender must have staked tokenID"
        );
        _unstake(msg.sender, _tokenId);
    }

    /// @notice Stake multiple Genesis NFTs and claim reward tokens. 

     /**
     * @dev All the unstaking goes through this function
     * @dev Rewards to be given out is calculated
     * @dev Balance of stakers are updated as they unstake the nfts based on ether price
    */

    function _unstake(
        address _user,
        uint256 _tokenId
    ) 
        internal 
    {

        Staker storage staker = stakers[_user];
        uint256 lastIndex = staker.tokenIds.length - 1;
        uint256 lastIndexKey = staker.tokenIds[lastIndex];
        staker.tokenIds[staker.tokenIndex[_tokenId]] = lastIndexKey;
        staker.tokenIndex[lastIndexKey] = staker.tokenIndex[_tokenId];
        if (staker.tokenIds.length > 0) {
            staker.tokenIds.pop();
            delete staker.tokenIndex[_tokenId];
        }

        if (staker.tokenIds.length == 0) {
            delete stakers[_user];
        }

        delete nftStaked[_tokenId];
        delete tokenOwner[_tokenId];
        delete stakedNftByOwner[_user][_tokenId];

        genesisNFT.safeTransferFrom(
            address(this),
            _user,
            _tokenId
        );

        emit Unstaked(_user, _tokenId);

    }


    // Unstake without caring about rewards. EMERGENCY ONLY.
    
    function emergencyUnstake(uint256 _tokenId) external {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "GenesisStaking._unstake: Sender must have staked tokenID"
        );
        _unstake(msg.sender, _tokenId);
        emit EmergencyUnstake(msg.sender, _tokenId);

    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata data
    )
        public pure returns(bytes4)
    {
        return _ERC721_RECEIVED;
    }



}