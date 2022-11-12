// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "./BLBIOAdministration.sol";


contract BLBIO is BLBIOAdministration {

    AggregatorInterface immutable AGGREGATOR_BUSD_BNB;

    bool public soldOut;
    
    struct UserClaim {
        uint256 total;
        uint256 claimed;
        bool freeToClaim;
    }
    mapping(address => UserClaim) userClaims;


    constructor(
        address _BLBAddr,
        address _BUSDAddr,
        address _AGGREGATORAddr
    ) {
        BLB = IERC20(_BLBAddr); 
        BUSD = IERC20(_BUSDAddr);
        AGGREGATOR_BUSD_BNB = AggregatorInterface(_AGGREGATORAddr);

        setPriceInUSD(
            0.30 * 10 ** 18, //equals 0.3 USD
            0.28 * 10 ** 18  //equals 0.28 USD
        ); 
        setRetailLimit(
            500 * 10 ** 18 //equals 500 blb
        ); 
    }

    event BuyInBNB(
        address indexed buyer,
        uint256 amountBLB, 
        uint256 amountBNB
    );
    event BuyInBUSD(
        address indexed buyer,
        uint256 amountBLB, 
        uint256 amountBUSD
    );
    event Claim(
        address indexed claimant,
        uint256 amountBLB
    );


// get -------------------------------------------------------------------------

    function priceInUSD(uint256 amount) public view returns(uint256) {
        require(!soldOut, "BLBIO: sold out!");
        return amount > retailLimit ? privatePriceInUSD : publicPriceInUSD
            * amount / 10 ** 18;
    }

    function priceInBNB(uint256 amount) public view returns(uint256) {
        require(!soldOut, "BLBIO: sold out!");
        return uint256(AGGREGATOR_BUSD_BNB.latestAnswer())
            * priceInUSD(amount) / 10 ** 18;
    }

    function totalClaimable(address claimant) public view returns(uint256) {
        UserClaim storage uc = userClaims[claimant];
        return uc.total - uc.claimed;
    }

    function claimable(address claimant) public view returns(uint256) {
        UserClaim storage uc = userClaims[claimant];
        
        if(uc.freeToClaim) {
            return totalClaimable(claimant);
        } else {
            return uc.total * claimableFraction/1000000  - uc.claimed;
        }
    }


// set -------------------------------------------------------------------------

    function buyInBNB(uint256 amount) public payable {
        address buyer = msg.sender;
        require(msg.value >= priceInBNB(amount) * 98/100, "insufficient fee");
        userClaims[buyer].total += amount;
        TotalClaimable += amount;
        emit BuyInBNB(buyer, amount, msg.value);
    }

    function buyInBUSD(uint256 amount) public {
        address buyer = msg.sender;
        require(BLB.balanceOf(address(this)) >= amount, "insufficient BLB in the contract");
        uint256 payableBUSD = priceInUSD(amount);
        BUSD.transferFrom(buyer, address(this), payableBUSD); 
        userClaims[buyer].total += amount;       
        TotalClaimable += amount;
        emit BuyInBUSD(buyer, amount, payableBUSD);
    }

    function claim() public {
        address claimant = msg.sender; 
        UserClaim storage uc = userClaims[claimant];
        uint256 _claimable = claimable(claimant);

        require(_claimable != 0, "BLBIO: there is no BLB to claim");
        require(BLB.balanceOf(address(this)) >= _claimable, "insufficient BLB in the contract");

        uc.claimed += _claimable;

        BLB.transfer(claimant, _claimable); 

        emit Claim(claimant, _claimable);      
    }

    
    function setSoldOut() public onlyOwner {
        soldOut = soldOut ? false : true;
    }
    
    function giftBLB(
        address addr, 
        uint256 amount, 
        bool freeToClaim
    ) public onlyOwner {
        userClaims[addr].total += amount; 
        userClaims[addr].freeToClaim = freeToClaim; 
        TotalClaimable += amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BLBIOAdministration is Ownable {

    uint256 public privatePriceInUSD;
    uint256 public publicPriceInUSD;
    uint256 public retailLimit;
    uint256 public claimableFraction;
    uint256 public TotalClaimable;

    IERC20 public BLB;
    IERC20 public BUSD;


    event SetPriceInUSD(uint256 indexed publicPrice, uint256 indexed privatePrice);
    event SetRetailLimit(uint256 indexed _retailLimit);
    event Withdraw(string indexed tokenName, uint256 amount);


    function blbBalance() public view returns(uint256) {
        return BLB.balanceOf(address(this));
    }

    function busdBalance() public view returns(uint256) {
        return BUSD.balanceOf(address(this));
    }

    function bnbBalance() public view returns(uint256) {
        return address(this).balance;
    }


//------------------------------------------------------------------------------------

    function increaseClaimableFraction(uint256 fraction) public onlyOwner {
        claimableFraction += fraction;

        require(claimableFraction <= 1000000, "BLBIO: fraction exceeds 10^6");
    }

    function setRetailLimit(uint256 _retailLimit) public onlyOwner {
        retailLimit = _retailLimit;
        emit SetRetailLimit(_retailLimit);
    }

    function setPriceInUSD(
        uint256 _publicPrice,
        uint256 _privatePrice
    ) public onlyOwner {
        publicPriceInUSD = _publicPrice;
        privatePriceInUSD = _privatePrice;
        emit SetPriceInUSD(_publicPrice, _privatePrice);
    }

//------------------------------------------------------------------------------------

    function withdrawBLB(uint256 amount) public onlyOwner {
        BLB.transfer(owner(), amount);
        emit Withdraw("BLB", amount);
    }

    function withdrawBUSD(uint256 amount) public onlyOwner {
        BUSD.transfer(owner(), amount);
        emit Withdraw("BUSD", amount);
    }

    function withdrawBNB(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
        emit Withdraw("BNB", amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
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