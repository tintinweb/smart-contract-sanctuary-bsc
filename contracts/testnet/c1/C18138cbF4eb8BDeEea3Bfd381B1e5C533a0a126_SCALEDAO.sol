// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITOKEN {
    function balanceOf(address) external view returns (uint256);
}

contract SCALEDAO is Ownable {

    uint256 private GOLD_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    address payable private devWallet;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private myBeans;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketGold;
    IERC20 private miningToken = IERC20(0xc21223249CA28397B4B6541dfFaEcC539BfF0c59);
        
    constructor(address _token) {
        devWallet = payable(msg.sender);
        miningToken = IERC20(_token);
    }
    
    function reGrill(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 eggsUsed = getMyReward(msg.sender);
        uint256 newMiners = eggsUsed / GOLD_TO_HATCH_1MINERS;
        hatcheryMiners[msg.sender] = hatcheryMiners[msg.sender] + newMiners;
        myBeans[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral eggs
        myBeans[referrals[msg.sender]] = myBeans[referrals[msg.sender]] + eggsUsed/12;
        
        //boost market to nerf miners hoarding
        marketGold=marketGold + eggsUsed / 5;
    }
    
    function withdrawReward() public {
        require(initialized);
        uint256 hasMiners = getMyReward(msg.sender);
        uint256 eggValue = calculateGoldSell(hasMiners);
        uint256 fee = devFee(eggValue);
        myBeans[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketGold = marketGold + hasMiners;
        miningToken.transfer(devWallet, fee);
        miningToken.transfer(msg.sender, eggValue-fee);
    }
    
    function beanRewards(address adr) public view returns(uint256) {
        uint256 hasMiners = getMyReward(adr);
        uint256 minerValue = calculateGoldSell(hasMiners);
        return minerValue;
    }
    
    function buyMiners(address ref, uint256 amount) public {
        require(initialized);
        uint256 contractBalance = miningToken.balanceOf(address(this));
        miningToken.transferFrom(msg.sender, address(this), amount);
        uint256 minersBought = calculateGoldBuy(amount, contractBalance);
        minersBought = minersBought - devFee(minersBought);
        uint256 fee = devFee(amount);
        miningToken.transfer(devWallet, fee);
        myBeans[msg.sender] = myBeans[msg.sender] + minersBought;
        reGrill(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN * bs) / (PSNH + (((PSN*rs) + (PSNH*rt)) / rt));
    }
    
    function calculateGoldSell(uint256 miners) public view returns(uint256) {
        return calculateTrade(miners,marketGold,miningToken.balanceOf(address(this)));
    }
    
    function calculateGoldBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketGold);
    }
    
    function calculateGoldBuySimple(uint256 eth) public view returns(uint256) {
        return calculateGoldBuy(eth,miningToken.balanceOf(address(this)));
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
         return amount*devFeeVal/100;
    }

    function seedMarket(uint256 amount) public onlyOwner {
        require(marketGold == 0);
        if (amount > 0) {
            miningToken.transferFrom(msg.sender, address(this), amount);
        }
        initialized = true;
        marketGold = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return miningToken.balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    function getMyReward(address adr) public view returns(uint256) {
        return myBeans[adr] + getRewardSinceLastHatch(adr);
    }
    
    function getRewardSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(GOLD_TO_HATCH_1MINERS, block.timestamp - lastHatch[adr]);
        return secondsPassed * hatcheryMiners[adr];
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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