/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {
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

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 {

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

/*
         __       __  ______  __    __  ________        _______   _______    ______  ________   ______    ______    ______   __       
        |  \  _  |  \|      \|  \  |  \|        \      |       \ |       \  /      \|        \ /      \  /      \  /      \ |  \      
        | $$ / \ | $$ \$$$$$$| $$\ | $$| $$$$$$$$      | $$$$$$$\| $$$$$$$\|  $$$$$$\\$$$$$$$$|  $$$$$$\|  $$$$$$\|  $$$$$$\| $$      
        | $$/  $\| $$  | $$  | $$$\| $$| $$__          | $$__/ $$| $$__| $$| $$  | $$  | $$   | $$  | $$| $$   \$$| $$  | $$| $$      
        | $$  $$$\ $$  | $$  | $$$$\ $$| $$  \         | $$    $$| $$    $$| $$  | $$  | $$   | $$  | $$| $$      | $$  | $$| $$      
        | $$ $$\$$\$$  | $$  | $$\$$ $$| $$$$$         | $$$$$$$ | $$$$$$$\| $$  | $$  | $$   | $$  | $$| $$   __ | $$  | $$| $$      
        | $$$$  \$$$$ _| $$_ | $$ \$$$$| $$_____       | $$      | $$  | $$| $$__/ $$  | $$   | $$__/ $$| $$__/  \| $$__/ $$| $$_____ 
        | $$$    \$$$|   $$ \| $$  \$$$| $$     \      | $$      | $$  | $$ \$$    $$  | $$    \$$    $$ \$$    $$ \$$    $$| $$     \
         \$$      \$$ \$$$$$$ \$$   \$$ \$$$$$$$$       \$$       \$$   \$$  \$$$$$$    \$$     \$$$$$$   \$$$$$$   \$$$$$$  \$$$$$$$$                                                                                                                                                                                                                                                                 
                                                                                                                                    
                                     ______  ________   ______   __    __  ______  __    __   ______                               
                                    /      \|        \ /      \ |  \  /  \|      \|  \  |  \ /      \                              
                                    |  $$$$$$\\$$$$$$$$|  $$$$$$\| $$ /  $$ \$$$$$$| $$\ | $$|  $$$$$$\                             
                                    | $$___\$$  | $$   | $$__| $$| $$/  $$   | $$  | $$$\| $$| $$ __\$$                             
                                     \$$    \   | $$   | $$    $$| $$  $$    | $$  | $$$$\ $$| $$|    \                             
                                     _\$$$$$$\  | $$   | $$$$$$$$| $$$$$\    | $$  | $$\$$ $$| $$ \$$$$                             
                                    |  \__| $$  | $$   | $$  | $$| $$ \$$\  _| $$_ | $$ \$$$$| $$__| $$                             
                                     \$$    $$  | $$   | $$  | $$| $$  \$$\|   $$ \| $$  \$$$ \$$    $$                             
                                      \$$$$$$    \$$    \$$   \$$ \$$   \$$ \$$$$$$ \$$   \$$  \$$$$$$                              
                                                                                                                              
*/                                                                                                                           
                                                                                                                              
contract WineProtocolStaking is Ownable, ReentrancyGuard {

    // ---------------------------------------------------------------------------------------------
    // INIZIALIZATION
    // ---------------------------------------------------------------------------------------------

    constructor() {
        options[0].range = 30 days;
        options[1].range = 90 days;
        options[2].range = 180 days;
        options[3].range = 360 days;
        options[4].range = 1800 days;
        options[0].apy = 8;
        options[1].apy = 12;
        options[2].apy = 20;
        options[3].apy = 27;
        options[4].apy = 50;
        optionLimit = 5;
    }

    // ---------------------------------------------------------------------------------------------
    // MODIFIERS
    // ---------------------------------------------------------------------------------------------

    modifier onlyEOA()  {
        require(msg.sender.code.length == 0, "NO_CONTRACTS!");
        _;
    }

    modifier checkBalance(uint amount) {
        require(IERC20(WINE).balanceOf(msg.sender) >= amount, "NOT_ENOUGH_BALANCE!");
        _;
    }

    modifier checkAmount(uint amount) {
        require(amount >= minPerStaking, "AMOUNT_TOO_LOW!");
        _;
    }

    // ---------------------------------------------------------------------------------------------
    // EVENTS
    // ---------------------------------------------------------------------------------------------

    event PartnerAdded (address partner);   
    event MultipliersSet (address partner);
    event OptionsUpdate (uint previousQty, uint newQty);
    event MinPerStakingUpdate (uint previous, uint next);
    event MaxPerStakingUpdate (uint previous, uint next);
    event FirstStakeWithoutNFT (address wallet, uint amount, uint option);
    event SecondaryStakeWithoutNFT (address wallet, uint amount);    
    event FirstStakeWithNFT (address wallet, address partner, uint tokenId, uint amount, uint option);
    event SecondaryStakeWithNFT (address wallet, address partner, uint tokenId, uint amount);
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
        uint revenue;
        uint accumulated;        
        address partner;           
    }

    // ---------------------------------------------------------------------------------------------
    // CONSTANTS
    // ---------------------------------------------------------------------------------------------

    address private constant WINE = 0xfAa3B1CaD63Acfd446b8bD0Fe6A157e4dC5b8A1a;

    // ---------------------------------------------------------------------------------------------
    // VARIABLES
    // ---------------------------------------------------------------------------------------------

    PoolInfo public poolInfo; 
    uint public optionLimit;        
    uint public leaderboardCounter;   
    uint private leaderboardLimit = 10;   
    uint public minPerStaking = 1 ether;      
    uint public maxPerStaking = 2500000 ether;  

    // ---------------------------------------------------------------------------------------------
    // MAPPINGS
    // ---------------------------------------------------------------------------------------------

    mapping(uint => OptionInfo) public options;
    mapping(address => StakingInfo) public stakingInfos;    
    mapping(uint => LeaderboardInfo) public leaderboard;    
    mapping(address => bool) public partners;    
    mapping(address => mapping(uint => uint)) public multipliers;

    // ---------------------------------------------------------------------------------------------
    // OWNER SETTERS
    // ---------------------------------------------------------------------------------------------  

    function addPartner(address partner) external onlyOwner {
        partners[partner] = true;
        emit PartnerAdded(partner);
    }

    function setMaxPerStaking(uint _maxPerStaking) external onlyOwner {
        uint previous = maxPerStaking;
        maxPerStaking = _maxPerStaking;
        emit MaxPerStakingUpdate(previous, maxPerStaking);
    }

    function setMinPerStaking(uint _minPerStaking) external onlyOwner {
        uint previous = minPerStaking;
        minPerStaking = _minPerStaking;
        emit MinPerStakingUpdate(previous, minPerStaking);
    }

    function withdrawERC20(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }    

    function withdrawERC721(address token, uint tokenId) external onlyOwner {
        IERC721(token).transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawERC1155(address token, uint tokenId, uint amount) external onlyOwner {
        IERC1155(token).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
    }

    function setOptions(uint[] calldata ranges, uint[] calldata apys) external onlyOwner {
        require(ranges.length == apys.length, "NOT_SAME_LENGTH!");
        uint oldQty = optionLimit;
        optionLimit = ranges.length;
        for(uint i; i < optionLimit; i++) {
            uint range = ranges[i];
            uint apy = apys[i];
            fillOptionstakingInfo(range, apy);
        }
        emit OptionsUpdate(oldQty, optionLimit);
        
    }    

    function addMultipliers(address partner, uint[] calldata _multipliers, uint[] calldata tokenIds) external onlyOwner {
        require(_multipliers.length == tokenIds.length, "NOT_SAME_LENGTH!");
        for(uint i; i < _multipliers.length; i++) {
            uint tokenId = tokenIds[i];
            uint multiplier = _multipliers[i];
            multipliers[partner][tokenId] = multiplier;
        }
        emit MultipliersSet(partner);
    }

    // ---------------------------------------------------------------------------------------------
    // PUBLIC SETTERS
    // ---------------------------------------------------------------------------------------------

    /* FIRST STAKE FUNCTIONS */

    function firstStakeWithoutNFT(uint option, uint amount) external nonReentrant onlyEOA checkBalance(amount) checkAmount(amount) {
        require(option < optionLimit, "EXCEEDS_OPTIONS_AVAILABLE!");  
        fillFirstStakingInfoWithoutNFT(option, amount);
        syncLeaderboard(amount);
        emit FirstStakeWithoutNFT(msg.sender, amount, option);
    }

    function firstStakeWithNFT(uint option, uint amount, address partner, uint tokenId) external nonReentrant onlyEOA checkBalance(amount) checkAmount(amount) {
        require(option < optionLimit, "EXCEEDS_OPTIONS_AVAILABLE!");  
        require(partners[partner], "COLLECTION_NOT_PARTNER!");
        require(IERC721(partner).ownerOf(tokenId) == msg.sender, "NOT_THE_OWNER!");
        fillFirstStakingInfoWithNFT(option, amount, partner, tokenId);
        syncLeaderboard(amount);
        emit FirstStakeWithNFT(msg.sender, partner, tokenId, amount, option);
    }

    /* SECONDARY STAKE FUNCTIONS */

    function secondaryStakeWithoutNFT(uint amount) external nonReentrant onlyEOA checkBalance(amount) checkAmount(amount) {
        fillSecondaryStakingInfoWithoutNFT(amount);
        syncLeaderboard(amount);
        emit SecondaryStakeWithoutNFT(msg.sender, amount);
    }    

    function secondaryStakeWithNFT(uint amount, address partner, uint tokenId) external nonReentrant onlyEOA checkBalance(amount) checkAmount(amount) {  
        require(partners[partner], "COLLECTION_NOT_PARTNER!");         
        require(IERC721(partner).ownerOf(tokenId) == msg.sender, "NOT_THE_OWNER!");        
        fillSecondaryStakingInfoWithNFT(partner, tokenId, amount);
        syncLeaderboard(amount);
        emit SecondaryStakeWithNFT(msg.sender, partner, tokenId, amount);
    }

    /* UNSTAKE FUNCTION */

    function unstake() external nonReentrant onlyEOA {
        StakingInfo memory stakingInfo = stakingInfos[msg.sender];
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

    /* FIRST STAKE HELPERS */

    function fillFirstStakingInfoWithoutNFT(uint option, uint amount) private {
        StakingInfo storage stakingInfo = stakingInfos[msg.sender];
        OptionInfo memory optionInfo = options[option];        
        require(stakingInfo.amount == 0, "ALREADY_IN_STAKING!");
        require(amount <= maxPerStaking, "EXCEEDS_MAX_IN_STAKING!");
        stakingInfo.revenue = (((amount * optionInfo.apy) / 100) / 12) * (optionInfo.range / 30 days);      
        stakingInfo.unit = stakingInfo.revenue / optionInfo.range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + optionInfo.range; 
        stakingInfo.apy = optionInfo.apy;
        stakingInfo.option = option;
        poolInfo.coins += amount;
        poolInfo.partecipants++;         
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
    }

    function fillFirstStakingInfoWithNFT(uint option, uint amount, address partner, uint tokenId) private {
        StakingInfo storage stakingInfo = stakingInfos[msg.sender];
        OptionInfo memory optionInfo = options[option];  
        require(stakingInfo.amount == 0, "ALREADY_IN_STAKING!");
        require(stakingInfo.partner == address(0), "TOKEN_ALREADY_STAKED!");
        require(amount <= maxPerStaking, "EXCEEDS_MAX_IN_STAKING!");
        uint multiplier = multipliers[partner][tokenId];
        uint apy = optionInfo.apy;
        uint total = apy + ((apy * multiplier) / 100);
        stakingInfo.revenue = (((amount * total) / 100) / 12) * (optionInfo.range / 30 days);
        stakingInfo.unit = stakingInfo.revenue / optionInfo.range;
        stakingInfo.amount += amount;
        stakingInfo.end = block.timestamp + optionInfo.range; 
        stakingInfo.partner = partner;
        stakingInfo.id = tokenId; 
        stakingInfo.apy = total;
        stakingInfo.option = option;
        poolInfo.coins += amount;
        poolInfo.partecipants++;        
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
        IERC721(partner).transferFrom(msg.sender, address(this), tokenId);
    }

    /* SECONDARY STAKE HELPERS */

    function fillSecondaryStakingInfoWithoutNFT(uint amount) private {
        StakingInfo storage stakingInfo = stakingInfos[msg.sender];
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        require(stakingInfo.amount + amount <= maxPerStaking, "EXCEEDS_MAX_IN_STAKING!");
        if(block.timestamp > stakingInfo.end) {
            fillAccumulatedRewards(stakingInfo, true);
        }else{
            fillAccumulatedRewards(stakingInfo, false);
        }
        stakingInfo.amount += amount;        
        stakingInfo.revenue = ((stakingInfo.amount * stakingInfo.apy / 100) / 12) * (options[stakingInfo.option].range / 30 days);
        stakingInfo.unit = stakingInfo.revenue / options[stakingInfo.option].range;
        stakingInfo.end = block.timestamp + options[stakingInfo.option].range;
        poolInfo.coins += amount;
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
    }     

    function fillSecondaryStakingInfoWithNFT(address partner, uint tokenId, uint amount) private {
        StakingInfo storage stakingInfo = stakingInfos[msg.sender];
        require(stakingInfo.partner == address(0), "TOKEN_ALREADY_STAKED!");
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        require(stakingInfo.amount + amount <= maxPerStaking, "EXCEEDS_MAX_IN_STAKING!");
        if(block.timestamp > stakingInfo.end) {
            fillAccumulatedRewards(stakingInfo, true);
        }else{
            fillAccumulatedRewards(stakingInfo, false);
        }
        stakingInfo.amount += amount;        
        uint multiplier = multipliers[partner][tokenId];
        uint apy = stakingInfo.apy;
        uint total = apy + ((apy * multiplier) / 100);
        stakingInfo.revenue = (((stakingInfo.amount * total) / 100) / 12) * (options[stakingInfo.option].range / 30 days);
        stakingInfo.unit = stakingInfo.revenue / options[stakingInfo.option].range;
        stakingInfo.end = block.timestamp + options[stakingInfo.option].range; 
        stakingInfo.partner = partner;
        stakingInfo.id = tokenId; 
        stakingInfo.apy = total;
        poolInfo.coins += amount;        
        IERC20(WINE).transferFrom(msg.sender, address(this), amount);
        IERC721(partner).transferFrom(msg.sender, address(this), tokenId);
    } 

    /* UNSTAKE HELPERS */

    function unstake(StakingInfo memory stakingInfo, bool tax, bool nft) private {
        require(stakingInfo.amount > 0, "NOTHING_IN_STAKING!");
        uint amount;
        if(tax){
            amount = (stakingInfo.amount * 80) / 100;
        }else{
            amount = stakingInfo.amount + stakingInfo.revenue + stakingInfo.accumulated;
        }
        poolInfo.coins -= stakingInfo.amount;
        poolInfo.partecipants--;
        delete stakingInfos[msg.sender];
        if(nft){
            IERC20(WINE).transfer(msg.sender, amount);
            IERC721(stakingInfo.partner).transferFrom(address(this), msg.sender, stakingInfo.id);    
            emit UnstakeWithNFT(msg.sender, stakingInfo.partner, stakingInfo.id, amount, stakingInfo.option);           
        }else{
            IERC20(WINE).transfer(msg.sender, amount);
            emit UnstakeWithoutNFT(msg.sender, amount, stakingInfo.option);
        }
    }

    /* OTHER HELPERS */

    function fillOptionstakingInfo(uint months, uint apy) private  {
        options[optionLimit].range = months * 30 days;
        options[optionLimit].apy = apy;
    }    

    function syncLeaderboard(uint amount) private {
        if(leaderboardCounter < leaderboardLimit) {
            LeaderboardInfo storage leaderboardInfo = leaderboard[leaderboardCounter++];
            leaderboardInfo.wallet = msg.sender;
            leaderboardInfo.amount = amount;
        }else{
            checkLeaderboardAmounts(amount);
        }
    }

    function checkLeaderboardAmounts(uint amount) private {
        uint compare;
        bool first;
        for(uint i; i < leaderboardLimit; i++){
            if(!first){
                if(amount > leaderboard[i].amount){
                    compare = i;
                    first = true;
                }
            }else{
                if(leaderboard[compare].amount > leaderboard[i].amount){
                    compare = i;
                }
            }
        }
        if(first){
            leaderboard[compare].amount = amount;
            leaderboard[compare].wallet = msg.sender; 
        }
    }

    function fillAccumulatedRewards(StakingInfo storage stakingInfo, bool finished) private {
        if(finished){
            stakingInfo.accumulated += stakingInfo.revenue;
        }else{
            uint range = options[stakingInfo.option].range - (stakingInfo.end - block.timestamp);
            uint accumulated = (stakingInfo.unit * range);
            stakingInfo.accumulated += accumulated;
        } 
    }    
}