/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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
     * Available since v3.4.
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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Stake is Ownable {   
    IERC20 stakingToken;
    using SafeMath for uint256;
    address _contract;
    uint256 public total_coins;

    uint256 public basedivider = 10000;

    struct plans{
        uint256 market;
        uint256 blockchain;
        uint256 diamond;
        uint256 ecosystem;
        uint256 misc;
        uint256 ico;
    }

    mapping(uint256 => plans) public start;
    mapping(uint256 => plans) public totalPer;
    
    

     struct wallet{
        uint256 market;
        uint256 blockchain;
        uint256 diamond;
        uint256 ecosystem;
        uint256 misc;
        uint256 ico;
        uint256 balance;
        uint256 claimed;
    }

    mapping(address => wallet) public myWallet;

    uint256 public market_total;
    uint256 public blockchain_total;
    uint256 public diamond_total;
    uint256 public ecosystem_total;
    uint256 public misc_total;
    uint256 public ico_total;
     

    constructor (uint256 ttl_cns) payable {
        _contract = msg.sender;
        total_coins = ttl_cns;

        totalPer[0].market = 3000;
        totalPer[0].blockchain = 4000;
        totalPer[0].diamond = 1000;
        totalPer[0].ecosystem = 1500;
        totalPer[0].misc = 300;
        totalPer[0].ico = 200;
        
        totalPer[1].market = 100;
        totalPer[1].blockchain = 200;
        totalPer[1].diamond = 10000;
        totalPer[1].ecosystem = 500;
        totalPer[1].misc = 2500;
        totalPer[1].ico = 2500;

        start[0].market=uint256(block.timestamp);
        start[0].blockchain=uint256(block.timestamp);
        start[0].diamond=uint256(block.timestamp);
        start[0].ecosystem=uint256(block.timestamp);
        start[0].misc=uint256(block.timestamp);
        start[0].ico=uint256(block.timestamp);

        market_total = total_coins.mul(totalPer[0].market).div(basedivider);
        blockchain_total = total_coins.mul(totalPer[0].blockchain).div(basedivider);
        diamond_total = total_coins.mul(totalPer[0].diamond).div(basedivider);
        ecosystem_total = total_coins.mul(totalPer[0].ecosystem).div(basedivider);
        misc_total = total_coins.mul(totalPer[0].misc).div(basedivider);
        ico_total = total_coins.mul(totalPer[0].ico).div(basedivider);
    }

    

    // uint256 market_freq = 2 minutes; 
    // uint256 blockchain_freq = 3 minutes;
    // uint256 diamond_freq = 3 minutes;
    // uint256 ecosystem_freq = 3 minutes;
    // uint256 misc_freq = 3 minutes;
    // uint256 ico_freq = 3 minutes;
    
    uint256 market_freq = 30 days; 
    uint256 blockchain_freq = 365 days;
    uint256 diamond_freq = 365 days;
    uint256 ecosystem_freq = 365 days;
    uint256 misc_freq = 365 days;
    uint256 ico_freq = 365 days;

   function claim_market() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].market);
        uint256 ban_bsnb  = (timdif.div(market_freq)).add(1);
        uint256 per_distribution = market_total.mul(totalPer[1].market).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].market);
        if(pending>0){
            if((myWallet[msg.sender].market).add(pending) < market_total){
                myWallet[msg.sender].market =  (myWallet[msg.sender].market).add(pending);
                myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pending);
            }else{
                if(myWallet[msg.sender].market < market_total){
                    uint256 pndg = market_total.sub(myWallet[msg.sender].market);
                    myWallet[msg.sender].market = myWallet[msg.sender].market.add(pndg);
                    myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pndg);
                }
            }
        }
        return true;
   }

    function claim_ico() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].ico);
        uint256 ban_bsnb  = (timdif.div(ico_freq)).add(1);
        uint256 per_distribution = ico_total.mul(totalPer[1].ico).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].ico);
        if(pending>0){
            if((myWallet[msg.sender].ico).add(pending) < ico_total){
                myWallet[msg.sender].ico =  (myWallet[msg.sender].ico).add(pending);
                myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pending);
            }else{
                if(myWallet[msg.sender].ico < ico_total){
                    uint256 pndg = ico_total.sub(myWallet[msg.sender].ico);
                    myWallet[msg.sender].ico = myWallet[msg.sender].ico.add(pndg);
                    myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pndg);
                }
            }
        }
        return true;
   }
   function claim_misc() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].misc);
        uint256 ban_bsnb  = (timdif.div(misc_freq)).add(1);
        uint256 per_distribution = misc_total.mul(totalPer[1].misc).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].misc);
        if(pending>0){
            if((myWallet[msg.sender].misc).add(pending) < misc_total){
                myWallet[msg.sender].misc =  (myWallet[msg.sender].misc).add(pending);
                myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pending);
            }else{
                if(myWallet[msg.sender].misc < misc_total){
                    uint256 pndg = misc_total.sub(myWallet[msg.sender].misc);
                    myWallet[msg.sender].misc = myWallet[msg.sender].misc.add(pndg);
                    myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pndg);
                }
            }
        }
        return true;
   }

   function claim_ecosystem() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].ecosystem);
        uint256 ban_bsnb  = (timdif.div(ecosystem_freq)).add(1);
        uint256 per_distribution = ecosystem_total.mul(totalPer[1].ecosystem).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].ecosystem);
        if(pending>0){
            if((myWallet[msg.sender].ecosystem).add(pending) < ecosystem_total){
                myWallet[msg.sender].ecosystem =  (myWallet[msg.sender].ecosystem).add(pending);
                myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pending);
            }else{
                if(myWallet[msg.sender].ecosystem < ecosystem_total){
                    uint256 pndg = ecosystem_total.sub(myWallet[msg.sender].ecosystem);
                    myWallet[msg.sender].ecosystem = myWallet[msg.sender].ecosystem.add(pndg);
                    myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pndg);
                }
            }
        }
        return true;
   }

    function claim_diamond() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].diamond);
        uint256 ban_bsnb  = (timdif.div(diamond_freq)).add(1);
        uint256 per_distribution = diamond_total.mul(totalPer[1].diamond).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].diamond);
        if(pending>0){
            if((myWallet[msg.sender].diamond).add(pending) < diamond_total){
                myWallet[msg.sender].diamond =  (myWallet[msg.sender].diamond).add(pending);
                myWallet[msg.sender].claimed =  (myWallet[msg.sender].claimed).add(pending);
            }else{
                if(myWallet[msg.sender].diamond < diamond_total){
                    uint256 pndg = diamond_total.sub(myWallet[msg.sender].diamond);
                    myWallet[msg.sender].diamond = myWallet[msg.sender].diamond.add(pndg);
                    myWallet[msg.sender].claimed =  (myWallet[msg.sender].claimed).add(pndg);
                }
            }
        }
        return true;
   }

   function claim_blockchain() public returns(bool){
        uint256 timdif = uint256(block.timestamp).sub(start[0].blockchain);
        uint256 ban_bsnb  = (timdif.div(blockchain_freq)).add(1);
        uint256 per_distribution = blockchain_total.mul(totalPer[1].blockchain).div(basedivider);
        uint256 totalTillNow = per_distribution.mul(ban_bsnb);
        uint256 pending = totalTillNow.sub(myWallet[msg.sender].blockchain);
        if(pending>0){
            if((myWallet[msg.sender].blockchain).add(pending) < blockchain_total){
                myWallet[msg.sender].blockchain =  (myWallet[msg.sender].blockchain).add(pending);
                myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pending);
            }else{
                if(myWallet[msg.sender].blockchain < blockchain_total){
                    uint256 pndg = blockchain_total.sub(myWallet[msg.sender].blockchain);
                    myWallet[msg.sender].blockchain = myWallet[msg.sender].blockchain.add(pndg);
                    myWallet[msg.sender].balance =  (myWallet[msg.sender].balance).add(pndg);
                }
            }
        }
        return true;
   }

    function withdraw(IERC20 tkn, address rcv, uint256 amount) public onlyOwner returns(bool){
        require(myWallet[msg.sender].balance < amount,"Insufficient Fund");
        myWallet[msg.sender].claimed = myWallet[msg.sender].claimed.add(amount);
        myWallet[msg.sender].balance = myWallet[msg.sender].balance.sub(amount);
        tkn.transfer(rcv,amount.mul(uint256(10).mul(1e8)));
        return true;
    }

    function lockedMarket() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].market);
        uint256 ban_bsnb  = (timdif.div(market_freq)).add(1);
        uint256 nxtime = uint256(start[0].market).add(ban_bsnb.mul(market_freq));
        uint256 per_distribution = market_total.mul(totalPer[1].market).div(basedivider);
        return (market_total.sub(myWallet[_contract].market),per_distribution,nxtime);
    }

    function lockedBlockchain() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].blockchain);
        uint256 ban_bsnb  = (timdif.div(blockchain_freq)).add(1);
        uint256 nxtime = uint256(start[0].blockchain).add(ban_bsnb.mul(blockchain_freq));
        uint256 per_distribution = blockchain_total.mul(totalPer[1].blockchain).div(basedivider);
        return (blockchain_total.sub(myWallet[_contract].blockchain),per_distribution,nxtime);
    }

    function lockedDiamond() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].diamond);
        uint256 ban_bsnb  = (timdif.div(diamond_freq)).add(1);
        uint256 nxtime = uint256(start[0].diamond).add(ban_bsnb.mul(diamond_freq));
        uint256 per_distribution = diamond_total.mul(totalPer[1].diamond).div(basedivider);
        return (diamond_total.sub(myWallet[_contract].diamond),per_distribution,nxtime);
    }
    
    function lockedEcosystem() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].ecosystem);
        uint256 ban_bsnb  = (timdif.div(ecosystem_freq)).add(1);
        uint256 nxtime = uint256(start[0].ecosystem).add(ban_bsnb.mul(ecosystem_freq));
        uint256 per_distribution = ecosystem_total.mul(totalPer[1].ecosystem).div(basedivider);
        return (ecosystem_total.sub(myWallet[_contract].ecosystem),per_distribution,nxtime);
    }
    
    function lockedMisc() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].misc);
        uint256 ban_bsnb  = (timdif.div(misc_freq)).add(1);
        uint256 nxtime = uint256(start[0].misc).add(ban_bsnb.mul(misc_freq));
        uint256 per_distribution = misc_total.mul(totalPer[1].misc).div(basedivider);
        return (misc_total.sub(myWallet[_contract].misc),per_distribution,nxtime);
    }
    function lockedIco() public view returns(uint256,uint256,uint256){
        uint256 timdif = uint256(block.timestamp).sub(start[0].ico);
        uint256 ban_bsnb  = (timdif.div(ico_freq)).add(1);
        uint256 nxtime = uint256(start[0].ico).add(ban_bsnb.mul(ico_freq));
        uint256 per_distribution = ico_total.mul(totalPer[1].ico).div(basedivider);
        return (ico_total.sub(myWallet[_contract].ico),per_distribution,nxtime);
    }
    
    
}