/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

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
/**
 * @dev Provides stakingInformation about the current execution context, including the
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

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract WineStaking is Ownable, ReentrancyGuard {

    // ---------------------------------------------------------------------------------------------
    // INIZIALIZATION
    // ---------------------------------------------------------------------------------------------

    constructor() {
        _options[0].range = 100 seconds;
        _options[1].range = 200 seconds;
        _options[2].range = 300 seconds;
        _options[3].range = 400 seconds;
        _options[4].range = 500 seconds;
        _options[0].apy = 8;
        _options[1].apy = 12;
        _options[2].apy = 20;
        _options[3].apy = 27;
        _options[4].apy = 50;
        optionCounter = 5;
    }

    // ---------------------------------------------------------------------------------------------
    // MODIFIERS
    // ---------------------------------------------------------------------------------------------

    modifier onlyEOA {
        require(tx.origin == msg.sender, "NO_CONTRACTS!");
        _;
    }

    // ---------------------------------------------------------------------------------------------
    // EVENTS
    // ---------------------------------------------------------------------------------------------

    event FirstStakeWithNFT (address wallet, address partner, uint tokenId, uint amount, uint option);
    event SecondaryStakeWithNFT (address wallet, address partner, uint tokenId, uint amount);
    event FirstStakeWithoutNFT (address wallet, uint amount, uint option);
    event SecondaryStakeWithoutNFT (address wallet, uint amount);
    event UnstakeWithNFT (address wallet, address partner, uint tokenId, uint amount, uint option);
    event UnstakeWithoutNFT (address wallet, uint amount, uint option);

    // ---------------------------------------------------------------------------------------------
    // STRUCTS
    // ---------------------------------------------------------------------------------------------

    struct PoolInfo {
        uint coins;        
        uint partecipants;
    } 

    struct OptionInfo {
        uint apy;
        uint range;        
    }

    struct LeaderboardInfo  {
        uint amount;
        address wallet;        
    }   

    struct StakingInfo {
        uint id;        
        uint end;
        uint apy;
        uint unit;
        uint option;
        uint amount;
        uint accumulated;        
        address partner;           
    }

    // ---------------------------------------------------------------------------------------------
    // CONSTANTS
    // ---------------------------------------------------------------------------------------------

    uint private constant LEADERBOARD_LIMIT = 10;
    address private constant WINE = 0xB703F733Bf2108a0C9D244528E239e8584068DE1;

    // ---------------------------------------------------------------------------------------------
    // VARIABLES
    // ---------------------------------------------------------------------------------------------

    PoolInfo public poolInfo; 
    LeaderboardInfo[] private topTen;
    uint public optionCounter;    
    uint public partnerCounter;     
    uint public leaderboardCounter;        
    uint public maxInStakingPerWallet = 25000000000000000000000000;  


    // ---------------------------------------------------------------------------------------------
    // MAPPINGS
    // ---------------------------------------------------------------------------------------------

    mapping(uint => address) public _partners;
    mapping(uint => OptionInfo) public _options;
    mapping(address => StakingInfo) public _stakingInfos;    
    mapping(uint => LeaderboardInfo) public _leaderboard;    
    mapping(address => mapping(uint => uint)) public _multipliers;

    // ---------------------------------------------------------------------------------------------
    // OWNER SETTERS
    // ---------------------------------------------------------------------------------------------  

    function addPartner(address partner) external onlyOwner {
        _partners[partnerCounter++] = partner;
    }

    function setMaxPerStaking(uint _maxPerStaking) external onlyOwner {
        maxInStakingPerWallet = _maxPerStaking;
    }

    function withdrawToken(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }    

    function setOptions(uint[] calldata ranges, uint[] calldata apys) external onlyOwner {
        require(ranges.length == apys.length, "NOT_SAME_LENGTH!");
        delete optionCounter;
        for(uint i; i < ranges.length; i++) {
            uint range = ranges[i];
            uint apy = apys[i];
            fillOptionstakingInfo(range, apy);
        }
    }    

    function addMultipliers(address partner, uint[] calldata multipliers, uint[] calldata tokenIds) external onlyOwner {
        require(multipliers.length == tokenIds.length, "NOT_SAME_LENGTH!");
        for(uint i; i < multipliers.length; i++) {
            uint tokenId = tokenIds[i];
            uint multiplier = multipliers[i];
            _multipliers[partner][tokenId] = multiplier;
        }
    }

    // ---------------------------------------------------------------------------------------------
    // PUBLIC SETTERS
    // ---------------------------------------------------------------------------------------------

    /* FIRST STAKE FUNCTIONS */

    function firstStakeWithoutNFT(uint option, uint amount) external nonReentrant onlyEOA {
        require(option < optionCounter, "EXCEEDS_OPTIONS_AVAILABLE!");  
        require(IERC20(WINE).balanceOf(msg.sender) >= amount, "NOT_ENOUGH_BALANCE!");
        fillFirstStakingInfoWithoutNFT(option, amount);
        syncLeaderboard(amount);
        emit FirstStakeWithoutNFT(msg.sender, amount, option);
    }

    function firstStakeWithNFT(uint option, uint amount, address partner, uint tokenId) external nonReentrant onlyEOA {
        require(option < optionCounter, "EXCEEDS_OPTIONS_AVAILABLE!");  
        require(IERC20(WINE).balanceOf(msg.sender) >= amount, "NOT_ENOUGH_BALANCE!");
        require(checkPartner(partner), "COLLECTION_NOT_PARTNER!");
        require(IERC721(partner).ownerOf(tokenId) == msg.sender, "NOT_THE_OWNER!");
        fillFirstStakingInfoWithNFT(option, amount, partner, tokenId);
        syncLeaderboard(amount);
        emit FirstStakeWithNFT(msg.sender, partner, option, amount, tokenId);
    }

    /* SECONDARY STAKE FUNCTIONS */

    function secondaryStakeWithoutNFT(uint amount) external nonReentrant onlyEOA {
        require(IERC20(WINE).balanceOf(msg.sender) >= amount, "NOT_ENOUGH_BALANCE!");
        fillSecondaryStakingInfoWithoutNFT(amount);
        syncLeaderboard(amount);
        emit SecondaryStakeWithoutNFT(msg.sender, amount);
    }    

    function secondaryStakeWithNFT(uint amount, address partner, uint tokenId) external nonReentrant onlyEOA {   
        require(IERC20(WINE).balanceOf(msg.sender) >= amount, "NOT_ENOUGH_BALANCE!");  
        require(checkPartner(partner), "COLLECTION_NOT_PARTNER!");
        require(IERC721(partner).ownerOf(tokenId) == msg.sender, "NOT_THE_OWNER!");
        fillSecondaryStakingInfoWithNFT(partner, tokenId, amount);
        syncLeaderboard(amount);
        emit SecondaryStakeWithNFT(msg.sender, partner, tokenId, amount);
    }

    /* UNSTAKE FUNCTION */

    function unstake() external nonReentrant onlyEOA {
        require(tx.origin == msg.sender, "NO_CONTRACTS!");
        StakingInfo memory stakingInfo = _stakingInfos[msg.sender];
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        if(block.timestamp > stakingInfo.end){
            if(stakingInfo.partner == address(0)){
                unstake(stakingInfo, false, false);
            }else{
                unstake(stakingInfo, false, true);
            }
        }else{
            if(stakingInfo.partner == address(0)){
                unstake(stakingInfo, true, false);
            }else{
                unstake(stakingInfo, true, true);
            }
        }
    }

    // ---------------------------------------------------------------------------------------------
    // HELPERS
    // ---------------------------------------------------------------------------------------------

    /* SECONDARY STAKE HELPERS */

    function fillSecondaryStakingInfoWithoutNFT(uint amount) private {
        StakingInfo storage stakingInfo = _stakingInfos[msg.sender];
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        require(stakingInfo.amount + amount <= maxInStakingPerWallet, "EXCEEDS_MAX_IN_STAKING!");
        if(block.timestamp > stakingInfo.end) {
            fillAccumulatedRewards(stakingInfo, true);
        }else{
            fillAccumulatedRewards(stakingInfo, false);
        }
        uint option = stakingInfo.option;
        uint revenue = amount * stakingInfo.apy / 100;
        stakingInfo.unit = revenue / _options[option].range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + _options[option].range;
        poolInfo.coins += amount;
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
    }     

    function fillSecondaryStakingInfoWithNFT(address partner, uint tokenId, uint amount) private {
        StakingInfo storage stakingInfo = _stakingInfos[msg.sender];
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        if(block.timestamp < stakingInfo.end) {
            fillAccumulatedRewards(stakingInfo, true);
        }else{
            fillAccumulatedRewards(stakingInfo, false);
        }
        uint option = stakingInfo.option;
        uint multiplier = _multipliers[partner][tokenId];
        uint apy = _options[option].apy;
        uint total = apy + ((apy * multiplier) / 100);
        uint revenue = amount * total / 100;
        stakingInfo.unit = revenue / _options[option].range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + _options[option].range; 
        stakingInfo.partner = partner;
        stakingInfo.id = tokenId; 
        stakingInfo.apy = total;
        stakingInfo.option = option;
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
        IERC721(partner).transferFrom(msg.sender, address(this), tokenId);
        poolInfo.coins += amount;
    } 

    /* FIRST STAKE HELPERS */

    function fillFirstStakingInfoWithoutNFT(uint option, uint amount) private {
        StakingInfo storage stakingInfo = _stakingInfos[msg.sender];
        require(stakingInfo.amount == 0, "ALREADY_IN_STAKING!");
        poolInfo.coins += amount;
        require(amount <= maxInStakingPerWallet, "EXCEEDS_MAX_IN_STAKING!");
        OptionInfo memory optionInfo = _options[option];
        uint revenue = amount * optionInfo.apy / 100;
        stakingInfo.unit = revenue / optionInfo.range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + optionInfo.range; 
        stakingInfo.apy = optionInfo.apy;
        stakingInfo.option = option;
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
        poolInfo.partecipants++;
    }

    function fillFirstStakingInfoWithNFT(uint option, uint amount, address partner, uint tokenId) private {
        StakingInfo storage stakingInfo = _stakingInfos[msg.sender];
        require(stakingInfo.amount == 0, "ALREADY_IN_STAKING!");
        require(stakingInfo.partner == address(0), "TOKEN_ALREADY_STAKED!");
        require(stakingInfo.amount + amount <= maxInStakingPerWallet, "EXCEEDS_MAX_IN_STAKING!");
        uint multiplier = _multipliers[partner][tokenId];
        uint apy = _options[option].apy;
        uint total = apy + ((apy * multiplier) / 100);
        uint revenue = amount * total / 100;
        stakingInfo.unit = revenue / _options[option].range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + _options[option].range; 
        stakingInfo.partner = partner;
        stakingInfo.id = tokenId; 
        stakingInfo.apy = total;
        stakingInfo.option = option;
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
        IERC721(partner).transferFrom(msg.sender, address(this), tokenId);
        poolInfo.coins += amount;
        poolInfo.partecipants++;
    }

    /* UNSTAKE HELPER */

    function calculateReward(uint revenue, uint option) private pure returns(uint){
        if(option == 1){
            revenue *= 3;
        }else if(option == 2){
            revenue *= 6;
        }else if(option == 3){
            revenue *= 12;
        }else if(option == 4){
            revenue *= 60;
        }
        return revenue;
    }

    function unstake(StakingInfo memory stakingInfo, bool tax, bool NFT) private {
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        delete _stakingInfos[msg.sender];
        uint amount;
        if(tax){
            amount = (stakingInfo.amount * 80) / 100;
        }else{
            uint revenue = ((stakingInfo.amount * stakingInfo.apy) / 100) / 12;
            uint reward = calculateReward(revenue, stakingInfo.option);
            amount = stakingInfo.amount + reward + stakingInfo.accumulated;
        }
        poolInfo.coins -= stakingInfo.amount;
        poolInfo.partecipants--;
        if(NFT){
            IERC20(WINE).transfer(msg.sender, amount);
            IERC721(stakingInfo.partner).transferFrom(address(this), msg.sender, stakingInfo.id);    
            emit UnstakeWithNFT(msg.sender, stakingInfo.partner, stakingInfo.id, amount, stakingInfo.option);           
        }else{
            IERC20(WINE).transfer(msg.sender, amount);
            emit UnstakeWithoutNFT(msg.sender, amount, stakingInfo.option);
        }
    }

    /* OTHER HELPERS */

    function fillOptionstakingInfo(uint range, uint apy) private {
        _options[optionCounter].range = range;
        _options[optionCounter].apy = apy;
        optionCounter++;
    }

    function fillAccumulatedRewards(StakingInfo storage stakingInfo, bool finished) private {
        uint accumulated;
        if(finished){
            accumulated = ((stakingInfo.amount * stakingInfo.apy) / 100) / 12;
            uint reward = calculateReward(accumulated, stakingInfo.option);
            stakingInfo.accumulated += reward;
        }else{
            uint range = (stakingInfo.end - block.timestamp);
            accumulated = (stakingInfo.unit * range) / 12;
            uint reward = calculateReward(accumulated, stakingInfo.option);
            stakingInfo.accumulated += reward;
        } 
    }    
    
    function checkPartner(address _partner) private view returns(bool) {
        for(uint i; i < partnerCounter; i++) {
            address partner = _partners[i];
            if(partner == _partner) {
                return true;
            }
        }
        return false;
    }

    function syncLeaderboard(uint amount) private {
        if(leaderboardCounter < LEADERBOARD_LIMIT) {
            LeaderboardInfo storage leaderboardInfo = _leaderboard[leaderboardCounter++];
            leaderboardInfo.wallet = msg.sender;
            leaderboardInfo.amount = amount;
        }else{
            checkLeaderboardAmounts(amount);
        }
    }

    function checkLeaderboardAmounts(uint amount) private {
        uint compare;
        bool first;
        for(uint i; i < LEADERBOARD_LIMIT; i++){
            if(!first){
                if(amount > _leaderboard[i].amount){
                    compare = i;
                    first = true;
                }
            }else{
                if(_leaderboard[compare].amount > _leaderboard[i].amount){
                    compare = i;
                }
            }
        }
        if(first){
            _leaderboard[compare].amount = amount;
            _leaderboard[compare].wallet = msg.sender; 
        }
    }
}