// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "./BLBIOAdministration.sol";

/**
 * @title BLB Initial Offering
 *
 * @dev BLB Token is offered in BNB and BUSD(USDT).
 * @dev the prices are set in USD and calculated to corresponding BNB in 
 *   every purchase transaction via chainlink price feed aggregator.
 * @dev the purchased blbs are locked in the contract until the Initial offering
 *   ends. then the owner can unlock proper fraction to be claimed. 
 * @dev there are two sale plan; public sale price for small amounts and private sale
 *  price for large amounts of blb.
 * @dev since solidity does not support floating variables, all prices are
 *   multiplied by 10^18 to embrace decimals.
 */
contract BLBIO is BLBIOAdministration {

    //price feed aggregator
    AggregatorInterface immutable AGGREGATOR_BNB_USD;

    bool public soldOut; //false means users can purchase, true means blb sold out
    
    struct UserClaim {
        uint256 total;
        uint256 claimed;
        bool freeToClaim;
    }
    mapping(address => UserClaim) userClaims;


    constructor(
        address _BLBAddr,
        address _BUSDAddr,
        address _AGGREGATORAddr,
        uint256 _publicBLBsPerUSD,
        uint256 _privateBLBsPerUSD,
        uint256 _retailLimitUSD,
        uint256 _minUSDLimit
    ) {
        BLB = IERC20(_BLBAddr); 
        BUSD = IERC20(_BUSDAddr);
        AGGREGATOR_BNB_USD = AggregatorInterface(_AGGREGATORAddr);

        setBLBsPerUSD(_publicBLBsPerUSD, _privateBLBsPerUSD); 
        setRetailLimit(_retailLimitUSD); 
        setMinUSDLimit(_minUSDLimit); 
    }

    /**
     * @dev emits when a user purchases BLB.
     */
    event Purchase(
        address indexed purchaser,
        string indexed tokenPaid,
        uint256 amountPaid,
        uint256 amountBLB 
    );

    /**
     * @dev emits when a user claims their unlocked BLB.
     */
    event Claim(
        address indexed claimant,
        uint256 amountBLB
    );

    /**
     * @dev emits when SoldOut situation switches.
     */
    event SoldOut(bool situation);


// get -------------------------------------------------------------------------

    /**
     * @return price BNB/USD. (8 digits decimals)
     */
    function priceBNB() public view returns(uint256) {
        return uint256(AGGREGATOR_BNB_USD.latestAnswer());
    }

    /**
     * @return amount BLBs is earned for USD.
     *
     * @notice the private and public amount are calculated automatically.
     */
    function BLBsForUSD(uint256 amountBUSD) public view returns(uint256) {
        require(!soldOut, "BLBIO: sold out!");
        uint256 amountPerUSD = amountBUSD >= retailLimit ? privateBLBsPerUSD : publicBLBsPerUSD;
        return amountPerUSD * amountBUSD / 10 ** 18;
    }

    /**
     * @return amount BLBs is earned for BNB.
     *
     * @notice the private and public amount are calculated automatically.
     */
    function BLBsForBNB(uint256 amountBNB) public view returns(uint256) {
        require(!soldOut, "BLBIO: sold out!");
        return amountBNB * priceBNB() / 10 ** 8;
        // uint256 amountUSD = amountBNB * priceBNB() / 10 ** 8;
        // uint256 amountPerBNB = BLBsForUSD(amountUSD) * priceBNB() / 10 ** 8;
        // return amountPerBNB * amountBNB / 10 ** 18;
    }

    /**
     * @return amount of the BLB token the user can claim.
     */
    function totalClaimable(address claimant) public view returns(uint256) {
        UserClaim storage uc = userClaims[claimant];
        return uc.total - uc.claimed;
    }

    /**
     * @return amount of the BLB token the user can claim just now.
     */
    function claimable(address claimant) public view returns(uint256) {
        UserClaim storage uc = userClaims[claimant];
        
        if(uc.freeToClaim) {
            return totalClaimable(claimant);
        } else {
            return uc.total * claimableFraction/1000000  - uc.claimed;
        }
    }


// set -------------------------------------------------------------------------

    /**
     * @dev purchase BLB Token paying in BNB.
     *
     * @notice requirement:
     *   - required amount must be paid in BNB.
     *
     * @notice emits a Purchase event
     */
    function purchaseInBNB() public payable {
        address purchaser = msg.sender;
        uint256 amountBNB = msg.value;
        uint256 amountBLB = BLBsForBNB(amountBNB);
        require(
            amountBNB * priceBNB() / 10 ** 8 >= minUSDLimit, 
            "BLBIO: less than minimum amount BNB"
        );
        userClaims[purchaser].total += amountBLB;
        TotalClaimable += amountBLB;
        emit Purchase(purchaser, "BNB", amountBNB, amountBLB);
    }

    /**
     * @dev purchase BLB Token paying in BUSD.
     *
     * @notice requirement:
     *   - Purchaser must approve the ICO to spend required BUSD.
     *
     * @notice emits a Purchase event
     */
    function purchaseInBUSD(uint256 amountBUSD) public {
        require(
            amountBUSD >= minUSDLimit, 
            "BLBIO: less than minimum amount BUSD"
        );
        address purchaser = msg.sender;
        uint256 amountBLB = BLBsForUSD(amountBUSD);
        BUSD.transferFrom(purchaser, address(this), amountBUSD); 
        userClaims[purchaser].total += amountBLB;       
        TotalClaimable += amountBLB;
        emit Purchase(purchaser, "BUSD", amountBUSD, amountBLB);
    }

    /**
     * @dev transfer unlocked BLBs to the claimant.
     *
     * @notice requirement:
     *   - claimable amount should not be zero.
     *   - there must be sufficient BLB token in this contract.
     *
     * @notice emits a Claim event
     */
    function claim() public {
        address claimant = msg.sender; 
        UserClaim storage uc = userClaims[claimant];
        uint256 _claimable = claimable(claimant);

        require(_claimable != 0, "BLBIO: there is no BLB to claim");
        require(BLB.balanceOf(address(this)) >= _claimable, "BLBIO: insufficient BLB in the contract");

        uc.claimed += _claimable;

        BLB.transfer(claimant, _claimable); 

        emit Claim(claimant, _claimable);      
    }

    /**
     * @dev turns the contract's offering on or off.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     * 
     * @notice emits a SoldOut event
     */
    function setSoldOut() public onlyOwner {
        soldOut = soldOut ? false : true;

        emit SoldOut(soldOut);
    }
    
    /**
     * @dev gift some BLBs to desired user.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     * 
     * @notice the user who earned BLB may be able to claim or may has to wait just 
     *   like other users. 
     * 
     * @notice emits a Purchase event
     */
    function giftBLB(
        address addr, 
        uint256 amount, 
        bool freeToClaim
    ) public onlyOwner {
        userClaims[addr].total += amount; 
        userClaims[addr].freeToClaim = freeToClaim; 
        TotalClaimable += amount;
        emit Purchase(addr, "gift", 0, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BLBIOAdministration is Ownable {

    uint256 public privateBLBsPerUSD; //how much BLBs is earned for 1 USD in bulk purchase.
    uint256 public publicBLBsPerUSD;  //how much BLBs is earned for 1 USD in retail purchase.
    uint256 public retailLimit;       //amount of USD paid in which the token amount increases from retail to bulk.
    uint256 public minUSDLimit;       //amount of USD paid in which the token amount increases from retail to bulk.
    uint256 public claimableFraction; //fraction of purchased token that users can claim for now.
    uint256 public TotalClaimable;    //amount of token that users purchased in total and sould be awailable in contract to be claimed.

    IERC20 public BLB;  // the contract address of blb token.
    IERC20 public BUSD; // the contract address of BUSD token.

    /**
     * @dev emits when the owner sets new prices for private and public blb sale.
     */
    event SetBLBsPerUSD(uint256 indexed publicBLBsAmount, uint256 indexed privateBLBsAmount);

    /**
     * @dev emits when the owner sets a new retail limit.
     */
    event SetRetailLimit(uint256 indexed _retailLimit);

    /**
     * @dev emits when the owner sets a new min USD limit.
     */
    event SetMinUSDLimit(uint256 indexed _minAmountUSD);

    /**
     * @dev emits when the owner withdraws any amount of BNB or ERC20 token.
     */
    event Withdraw(string indexed tokenName, uint256 amount);

    /**
     * @return balance BLB in this contract.
     */
    function blbBalance() public view returns(uint256) {
        return BLB.balanceOf(address(this));
    }

    /**
     * @return balance BUSD in this contract.
     */
    function busdBalance() public view returns(uint256) {
        return BUSD.balanceOf(address(this));
    }

    /**
     * @return balance BNB in this contract.
     */
    function bnbBalance() public view returns(uint256) {
        return address(this).balance;
    }


//------------------------------------------------------------------------------------

    /**
     * @dev increase the fraction of BLB tokens which users can claim now;
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *   - the maximum fraction can be 1,000,000 which means 100% of the tokens 
     *      user puchased.
     */
    function increaseClaimableFraction(uint256 fraction) public onlyOwner {
        claimableFraction += fraction;

        require(
            claimableFraction <= 1000000, 
            "BLBIOAdministration: fraction exceeds 10^6"
        );
    }

    /**
     * @dev set minimum USD limit;
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a SetMinUSDLimit event
     */
    function setMinUSDLimit(uint256 amountUSD) public onlyOwner {
        minUSDLimit = amountUSD;
        emit SetMinUSDLimit(amountUSD);
    }

    /**
     * @dev set retail limit;
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a SetRetailLimit event
     */
    function setRetailLimit(uint256 amountUSD) public onlyOwner {
        retailLimit = amountUSD;
        emit SetRetailLimit(amountUSD);
    }

    /**
     * @dev set ticket price in USD for public sale and private sale;
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a SetBLBsPerUSD event
     */
    function setBLBsPerUSD(
        uint256 publiceBLBsAmount,
        uint256 privateBLBsAmount
    ) public onlyOwner {
        require(
            publiceBLBsAmount <= privateBLBsAmount, 
            "BLBIOAdministration: private amount must be greater than or equal to public amount"
        );
        publicBLBsPerUSD = publiceBLBsAmount;
        privateBLBsPerUSD = privateBLBsAmount;
        emit SetBLBsPerUSD(publiceBLBsAmount, privateBLBsAmount);
    }

//------------------------------------------------------------------------------------

    /**
     * @dev withdraw BLB tokens from the contract.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a Withdraw event
     */
    function withdrawBLB(uint256 amount) public onlyOwner {
        BLB.transfer(owner(), amount);
        emit Withdraw("BLB", amount);
    }

    /**
     * @dev withdraw BUSD tokens from the contract.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a Withdraw event
     */
    function withdrawBUSD(uint256 amount) public onlyOwner {
        BUSD.transfer(owner(), amount);
        emit Withdraw("BUSD", amount);
    }

    /**
     * @dev withdraw BNB from the contract.
     *
     * @notice requirement:
     *   - only owner of the contract can call this function.
     *
     * @notice emits a Withdraw event
     */
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