/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: OpenZeppelin/[email protected]/Context

/*
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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// Part: OpenZeppelin/[email protected]/Ownable

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: DepositAndWithdraw.sol

contract DepositAndWithdraw is Ownable {
    struct User {
        address userAddress;
        mapping(address => uint256) uniqueTokensDeposited;
        mapping(address => mapping(address => uint256)) tokenBalances;
    }
    User[] public users;
    address[] public allowedTokensAddresses;
    mapping(address => uint256) public contractTokenBalances;
    mapping(address => bool) public alreadyUser;

    event tokenAdded(address indexed userAddress, uint256 numberOfTokens);
    event tokenBalanceOf(
        address indexed userAddress,
        address indexed tokenAddress,
        uint256 tokenBalance
    );
    event userAdded(address indexed userAddress);
    event contractTokenBalanceAdjusted(
        address indexed tokenAddress,
        uint256 tokenBalance
    );

    function balanceOfToken(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(msg.sender);
    }

    function deposit(address _token, uint256 _amount) public payable {
        require(_amount > 0, "Deposit an amount greater than 0");
        require(
            balanceOfToken(_token) >= _amount,
            "insufficient tokens available in your wallet"
        );
        require(tokenIsAllowed(_token), "token is not allowed to be deposited");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        uint256 contractTokenBalance = contractTokenBalances[_token] += _amount;
        emit contractTokenBalanceAdjusted(_token, contractTokenBalance);
        if (alreadyUser[msg.sender]) {
            for (uint256 i = 0; i < users.length; i++) {
                if (users[i].userAddress == msg.sender) {
                    if (users[i].tokenBalances[_token][msg.sender] <= 0) {
                        uint256 numberOfTokens = users[i].uniqueTokensDeposited[
                            _token
                        ] += 1;
                        emit tokenAdded(msg.sender, numberOfTokens);
                        uint256 tokenBalance = users[i].tokenBalances[_token][
                            msg.sender
                        ] += _amount;

                        emit tokenBalanceOf(msg.sender, _token, tokenBalance);
                        break;
                    }
                    users[i].uniqueTokensDeposited[_token] += 1;
                    users[i].tokenBalances[_token][msg.sender] += _amount;
                    break;
                }
            }
        }
        User storage u = users.push();
        u.userAddress = msg.sender;
        u.uniqueTokensDeposited[_token] += 1;
        u.tokenBalances[_token][msg.sender] += _amount;
        alreadyUser[msg.sender] = true;
        emit tokenAdded(msg.sender, 1);
        emit tokenBalanceOf(msg.sender, _token, _amount);
        emit userAdded(msg.sender);
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokensAddresses.push(_token);
    }

    function tokenIsAllowed(address _token) public view returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokensAddresses.length;
            allowedTokensIndex++
        ) {
            if (allowedTokensAddresses[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function withdraw(
        address _withdrawAddress,
        address _token,
        uint256 _amount
    ) public onlyOwner {
        require(_amount > 0, "Withdraw an amount greater than 0");
        require(
            balanceOfToken(_token) >= _amount,
            "insufficient tokens available in the contract"
        );
        require(tokenIsAllowed(_token), "token is not allowed to be withdrawn");
        IERC20(_token).transfer(_withdrawAddress, _amount);
        uint256 contractTokenBalance = contractTokenBalances[_token] -= _amount;
        emit contractTokenBalanceAdjusted(_token, contractTokenBalance);
    }
}