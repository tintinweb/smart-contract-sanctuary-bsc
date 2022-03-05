/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: libraries.sol


pragma solidity ^0.8.0;


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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



// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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
// File: JokerSoftMintFunds.sol


pragma solidity ^0.8.0;



// March 4th, 2022
// https://slamjokers.com
// Made for "Jokers by SLAM" by @Kadabra_SLAM (Telegram) to accept funds in BNB on BSC for soft-minting

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract JokerSoftMintFunds is Ownable, ReentrancyGuard {
    mapping(address => uint256) public totalJokers;

    struct FundConfig {
        uint256 totalSoldJokers;
        uint256 remainingSupply;
        uint256 price_1; 
        uint256 price_3;
        uint256 price_5;
        uint256 price_10;
        bool paused;
    }

    FundConfig public fundConfig;

    constructor() {
        /*
            Presale / Private Mint for Whitelisted Wallets. March 6th, 2022
                1 Joker mint:       0.06 ETH
                3 Jokers bundle:    0.17 ETH (0.056 per)
                5 Jokers bundle:    0.265 ETH (0.053 per)
                10 Jokers bundle:   0.45 ETH (0.045 per)

            Public Sale.  March 8th, 2022
                1 Joker mint:       0.07 ETH
                3 Jokers bundle:    0.2 ETH (0.066 per)
                5 Jokers bundle:    0.3 ETH (0.06 per)
                10 Jokers bundle:   0.5 ETH (0.05 per)
        */
        
        fundConfig.price_1 = 0.5 ether;     //BNB = 0.07 ether; //1 joker
        fundConfig.price_3 = 1.4 ether;     //BNB = 0.2 ether; //3 jokers
        fundConfig.price_5 = 2.1 ether;     //BNB = 0.3 ether; //5 jokers
        fundConfig.price_10 = 3.48 ether;   //BNB = 0.5 ether; //10 jokers
        fundConfig.remainingSupply = 500;
        fundConfig.paused = false;
    }

    receive() external payable {
        fundJoker(); // If sent directly to the contract. Must have enough gas limit
    }

    function fundJoker() public payable nonReentrant{
        require(!fundConfig.paused, "The contract is not accepting any payments");
        require(msg.value >= fundConfig.price_1, "Need to send more BNB.");

        uint256 _howMany = 0;
        uint256 _price = 0;
        if(msg.value >= fundConfig.price_10){
            _howMany = 10;
            _price = fundConfig.price_10;
        } else if(msg.value >= fundConfig.price_5){
            _howMany = 5;
            _price = fundConfig.price_5;
        } else if(msg.value >= fundConfig.price_3){
            _howMany = 3;
            _price = fundConfig.price_3;
        } else if(msg.value >= fundConfig.price_1){
            _howMany = 1;
            _price = fundConfig.price_1;
        }

        if(_howMany > 0){
            require(fundConfig.remainingSupply >= _howMany, "Not any available Joker left");

            totalJokers[msg.sender] += _howMany;
            fundConfig.totalSoldJokers += _howMany;
            fundConfig.remainingSupply -= _howMany;
            emit paidForJoker(msg.sender, _howMany);
        }
        refundIfOver(_price);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more BNB.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
    
    event paidForJoker(address, uint256);

    function setPrices(uint256 _price_1, uint256 _price_3, uint256 _price_5, uint256 _price_10) public onlyOwner{
        fundConfig.price_1 = _price_1;
        fundConfig.price_3 = _price_3;
        fundConfig.price_5 = _price_5;
        fundConfig.price_10 = _price_10;
    }

    function setSupply(uint256 _reservedSupply) public onlyOwner{
        //should be paused first
        fundConfig.remainingSupply = _reservedSupply;
    }
    
    function pause(bool _pause) public onlyOwner{
        fundConfig.paused = _pause;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // To get any tokens out of the contract if needed
    function withdrawToken(address _tokenContract, uint256 _amount, address _to) external onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(_to, _amount);
    }
    function withdrawToken_All(address _tokenContract, address _to) external onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 _amount = tokenContract.balanceOf(address(this));
        tokenContract.transfer(_to, _amount);
    }
}