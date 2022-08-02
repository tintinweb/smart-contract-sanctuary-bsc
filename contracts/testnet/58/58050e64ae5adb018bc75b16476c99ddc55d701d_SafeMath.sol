/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
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

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }

}

contract Ownership {
    address public _owner;
    modifier justOwner() {
        require(msg.sender == _owner, "Dare you");
        _;
    }
}

contract BurnItAllowance is Ownership {
    mapping(address => address) internal _allowance;

    function addAllowance(address tAddr, address initiatorAddress)
        public
        virtual
        justOwner
    {
        require(tAddr != address(0), "Allowance can't be set for burn address");

        require(_allowance[tAddr] == address(0), "Already existing");
        _allowance[tAddr] = initiatorAddress;
    }

    function hasAllowance(address tAddr) public view returns (address) {
        return _allowance[tAddr];
    }

    function updateAllowance(address tAddr, address initiatorAddress)
        public
        justOwner
    {
        require(_allowance[tAddr] != address(0), "Allowance does not exist");

        require(tAddr != address(0), "Allowance can't be set for burn address");
        _allowance[tAddr] = initiatorAddress;
    }

    function withdrawAllowance(address tAddr) public justOwner {
        delete _allowance[tAddr];
    }
}



contract BurnItBaseline is BurnItAllowance {
    using SafeMath for uint256;
    uint256 private multiplier = 10**18;

    bool private _rentrenceLock = true;
    IERC20 public immutable masterToken;
    IERC20 public immutable burnedToken;

    constructor(address _masterToken, address _burnedToken) {
        _owner = msg.sender;
        masterToken = IERC20(_masterToken);
        burnedToken = IERC20(_burnedToken);
    }
    modifier reentrancyLock() {
        require(_rentrenceLock, "Reentrency protection hit");
        _rentrenceLock = false;
        _;
        _rentrenceLock = true;
    }

    function BurnForBacking(uint256 amountToBurn)
        public
        reentrancyLock
    {
        require(hasAllowance(address(IERC20(burnedToken))) == address(msg.sender),"Not allowed");
        require(amountToBurn > 0);
        require(IERC20(burnedToken).balanceOf(msg.sender) >= amountToBurn); // Check if the sender has enough

        // transfer to dead wallet
        IERC20(burnedToken).transferFrom(address(msg.sender),address(0), amountToBurn);

        
        // transfer from this to message sender
        uint256 sendershare = ((amountToBurn * 10 ** IERC20(burnedToken).decimals()) / (IERC20(burnedToken).totalSupply() - IERC20(burnedToken).balanceOf(address(0)))) * multiplier;
        uint256 payoutAmount = (IERC20(masterToken).balanceOf(address(this)) * sendershare) / multiplier;

        if (payoutAmount > 0 ) {
            IERC20(masterToken).transfer(address(msg.sender) , payoutAmount); 
        }
    }
}