/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.6;

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

    function _transfer(address _from, address _to, uint256 _value) external ;
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


contract Swap {

    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public BUSD;

    address public contractOwner;

    uint256 public totalBUSDSale;
    uint256 public multipler;
    uint256 hundred = 100;
    uint256 public tokensPerBUSD = hundred.mul(10**18);

    mapping(address => bool) public registeredUser;
    mapping(address => uint256) public tokensAlloted;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call this function");
        _;
    }

    constructor(address tokenAddress, address busdAddress) {
        token = IERC20(tokenAddress);
        BUSD = IERC20(busdAddress);
        contractOwner = msg.sender;
    }

    function buyTokens(uint256 _busdAmount) public {

        uint256 busdAmount = _busdAmount;

        while(multipler.add(1).mul(1000) <= busdAmount.add(totalBUSDSale)) {
            token.transfer(msg.sender, (multipler.add(1).mul(1000).sub(totalBUSDSale)).mul(tokensPerBUSD));
            busdAmount = busdAmount.add(totalBUSDSale).sub(multipler.add(1).mul(1000));
            totalBUSDSale = totalBUSDSale.add(multipler.add(1).mul(1000).sub(totalBUSDSale));
            multipler = totalBUSDSale.div(1000);
            // decreament tokensPerBUSD
            tokensPerBUSD = tokensPerBUSD.sub(tokensPerBUSD.mul(1).div(1000));
        }
        token.transfer(msg.sender, busdAmount.mul(tokensPerBUSD));
        totalBUSDSale = totalBUSDSale.add(busdAmount);
        multipler = totalBUSDSale.div(1000);

        // Transfer BUSD to contract
        BUSD.transferFrom(msg.sender, address(this), _busdAmount.mul(10**18));
    }
    
    // _tokenAmount in 10**18
    function ultaSell(uint256 _tokenAmount) public {

        uint256 busdAmount = _tokenAmount.div(tokensPerBUSD);
        uint256 tokenAmount = _tokenAmount;

        if(totalBUSDSale.sub(multipler.mul(1000)) < busdAmount) {
            uint256 prevMultiplerRequirement = totalBUSDSale.sub(multipler.mul(1000));
            token.transferFrom(msg.sender, address(this), prevMultiplerRequirement.mul(tokensPerBUSD));
            BUSD.transfer(msg.sender, prevMultiplerRequirement * (10**18));
            tokenAmount = _tokenAmount.sub(prevMultiplerRequirement.mul(tokensPerBUSD));
            //Change Price
            totalBUSDSale =  totalBUSDSale.sub(prevMultiplerRequirement);
            multipler = totalBUSDSale.div(1000);
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));
        }

        while(tokenAmount.div(tokensPerBUSD) > 1000) {
            uint256 tokenWorthThousand = 1000 * tokensPerBUSD;
            token.transferFrom(msg.sender, address(this), tokenWorthThousand);
            BUSD.transfer(msg.sender, 1000 * (10**18));
            busdAmount = busdAmount.sub(1000);
            totalBUSDSale =  totalBUSDSale.sub(1000);
            
            // Change Price
            multipler = totalBUSDSale.div(1000);
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));
            tokenAmount = tokenAmount.sub(tokenWorthThousand);
        }

        token.transferFrom(msg.sender, address(this), tokenAmount);
        BUSD.transfer(msg.sender, tokenAmount.div(tokensPerBUSD).mul(10**18));
        totalBUSDSale =  totalBUSDSale.sub(tokenAmount.div(tokensPerBUSD));

        uint256 prevMultiplier = multipler;
        multipler = totalBUSDSale.div(1000);
        if (prevMultiplier != multipler) {
            // Change Price
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));
        }

    }
    function sellTokens(uint256 _busdAmount) public {
        uint256 busdAmount = _busdAmount;
        
        if(totalBUSDSale.sub(multipler.mul(1000)) < busdAmount) {
            uint256 prevMultiplerRequirement = totalBUSDSale.sub(multipler.mul(1000));
            token.transferFrom(msg.sender, address(this), prevMultiplerRequirement.mul(tokensPerBUSD));
            BUSD.transfer(msg.sender, prevMultiplerRequirement * (10**18));
            busdAmount = busdAmount.sub(prevMultiplerRequirement);
            //Change Price
            totalBUSDSale =  totalBUSDSale.sub(prevMultiplerRequirement);
            multipler = totalBUSDSale.div(1000);
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));

        }


        while(busdAmount > 1000) {
            uint256 tokenWorthThousand = 1000 * tokensPerBUSD;
            token.transferFrom(msg.sender, address(this), tokenWorthThousand);
            BUSD.transfer(msg.sender, 1000 * (10**18));
            busdAmount = busdAmount.sub(1000);
            totalBUSDSale =  totalBUSDSale.sub(1000);
            
            // Change Price
            multipler = totalBUSDSale.div(1000);
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));
        }

        uint256 tokenWorthRemainingBUSD = busdAmount.mul(tokensPerBUSD);
        token.transferFrom(msg.sender, address(this), tokenWorthRemainingBUSD);
        BUSD.transfer(msg.sender, busdAmount * (10**18));
        totalBUSDSale =  totalBUSDSale.sub(busdAmount);

        uint256 prevMultiplier = multipler;
        multipler = totalBUSDSale.div(1000);
        if (prevMultiplier != multipler) {
            // Change Price
            tokensPerBUSD = tokensPerBUSD.add(tokensPerBUSD.mul(1).div(1000));
        }
    }

}