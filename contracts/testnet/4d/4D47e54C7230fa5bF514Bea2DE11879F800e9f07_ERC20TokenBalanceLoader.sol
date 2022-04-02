/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC20 {
   
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

contract ERC20TokenBalanceLoader {
    address private _owner;
    address private _pendingOwner;

    mapping(address => uint256) public tokenToIndex;
    address[] public tokens;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipAccepted(
        address indexed previousOwner,
        address indexed newOwner
    );
    event TokenAdded(address indexed tokenAddress);
    event TokenDeleted(address indexed tokenAddress);

    constructor(address[] memory tokens_) {
        tokens = tokens_;
        for (uint256 i = 0; i < tokens_.length; i++) {
            tokenToIndex[tokens_[i]] = i + 1;
        }
        _owner = msg.sender;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "ERC20TokenBalanceLoader: caller is not the owner"
        );
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "ERC20TokenBalanceLoader: new owner is the zero address"
        );
        require(
            newOwner != _owner,
            "ERC20TokenBalanceLoader: new owner is the same as the current owner"
        );

        emit OwnershipTransferred(_owner, newOwner);
        _pendingOwner = newOwner;
    }

    function acceptOwnership() external {
        require(
            msg.sender == _pendingOwner,
            "ERC20TokenBalanceLoader: invalid new owner"
        );
        emit OwnershipAccepted(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }

    function loadBalance(address addr)
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        uint256[] memory balances = new uint256[](tokens.length);
        uint8[] memory decimals = new uint8[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == address(0)) {
                balances[i] = addr.balance;
                decimals[i] = 18;
            } else {
                balances[i] = IERC20(tokens[i]).balanceOf(addr);
                decimals[i] = IERC20Metadata(tokens[i]).decimals();
            }
        }
        return (tokens, balances, decimals);
    }

    function loadBalanceForTokens(address addr, address[] calldata tokens_)
        public
        view
        returns (uint256[] memory, uint8[] memory)
    {
        uint256[] memory balances = new uint256[](tokens_.length);
        uint8[] memory decimals = new uint8[](tokens_.length);
        for (uint256 i = 0; i < tokens_.length; i++) {
            if (tokens_[i] == address(0)) {
                balances[i] = addr.balance;
                decimals[i] = 18;
            } else {
                balances[i] = IERC20(tokens_[i]).balanceOf(addr);
                decimals[i] = IERC20Metadata(tokens_[i]).decimals();
            }
        }
        return (balances, decimals);
    }

    function tokensLength() public view returns (uint256) {
        return tokens.length;
    }

    function addTokens(address[] memory tokensToAdd) external onlyOwner {
        for (uint256 i = 0; i < tokensToAdd.length; i++) {
            address newToken = tokensToAdd[i];
            require(
                tokenToIndex[newToken] == 0,
                "ERC20TokenBalanceLoader: new token already exists"
            );
            tokens.push(newToken);
            tokenToIndex[newToken] = tokens.length;
            emit TokenAdded(newToken);
        }
    }

    function deleteTokens(address[] memory tokensToDelete) external onlyOwner {
        for (uint256 i = 0; i < tokensToDelete.length; i++) {
            address tokenDelete = tokensToDelete[i];
            uint256 index = tokenToIndex[tokenDelete];
            require(index > 0, "ERC20TokenBalanceLoader: token does not exist");
            if (index != tokens.length) {
                tokens[index - 1] = tokens[tokens.length - 1];
                tokenToIndex[tokens[index - 1]] = index;
            }
            tokens.pop();
            delete (tokenToIndex[tokenDelete]);
            emit TokenDeleted(tokenDelete);
        }
    }
}