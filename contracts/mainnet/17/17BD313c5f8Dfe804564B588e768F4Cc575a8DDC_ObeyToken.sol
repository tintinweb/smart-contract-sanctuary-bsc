/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MITS

pragma solidity 0.8.4;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ObeyToken {
    /// @notice EIP-20 token name for this token
    string public constant name = "OBEY Token";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "OBEY";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint256 public totalSupply = 220000000 * 10**18;

    /// @dev Allowance amounts on behalf of others
    mapping(address => mapping(address => uint256)) internal allowances;

    /// @dev Official record of token balances for each account
    mapping(address => uint256) internal balances;

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );



    /// @notice blacklist address
    mapping(address => bool) isBlacklisted;

    /// @notice admin address
    address admin;


    /// @notice admin role
    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    /**
     * @notice Construct a new Gym token
     * @param account The initial account to grant all the tokens
     */

    constructor(address account) {
        admin = msg.sender;
        balances[account] = uint256(totalSupply);
        emit Transfer(address(0), account, totalSupply);
    }

    

    /**
     * @notice blacklist address
     * @param _addr address to blackist
     */
    function blackList(address _addr) public onlyAdmin {
        require(!isBlacklisted[_addr], "address already blacklisted");
        isBlacklisted[_addr] = true;
    }

    /**
     * @notice bulk blacklist address
     * @param _addresses addresses to blackist
     */
    function bulkBlacklist(address[] memory _addresses) public onlyAdmin {
        for (uint256 i = 0; i < _addresses.length; i++) {
            isBlacklisted[_addresses[i]] = true;
        }
    }

    /**
     * @notice remove address from blacklist
     * @param _addr address to remove
     */
    function removeFromBlacklist(address _addr) public onlyAdmin {
        require(isBlacklisted[_addr], "address already whitelisted");
        isBlacklisted[_addr] = false;
    }

  

    // function mint(uint256 rawAmount) private {
    //     _mint(msg.sender, rawAmount);
    // }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 rawAmount)
        external
        returns (bool)
    {
        uint256 amount;
        if (rawAmount == type(uint256).max) {
            amount = type(uint256).max;
        } else {
            amount = safe96(
                rawAmount,
                "Token::approve: amount exceeds 96 bits"
            );
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint256 rawAmount) public returns (bool) {
        

        // @notice antiwhale check, check if address is blacklisted
        require(!isBlacklisted[dst], "address is backlisted");
 
        // update sender balance
        balances[msg.sender] = balances[msg.sender] - rawAmount;

        // update receiver balance
        balances[dst] = balances[dst] + rawAmount;

        _transferTokens(msg.sender, dst, rawAmount);

        return true;
    }

    

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) public returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];
        uint256 amount =
            safe96(rawAmount, "Token::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != type(uint256).max) {
            uint256 newAllowance =
                sub96(
                    spenderAllowance,
                    amount,
                    "Token::transferFrom: transfer amount exceeds spender allowance"
                );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

      
        // @notice anti-sniper check, check if address is blacklisted
        require(!isBlacklisted[dst], "address is backlisted");


        // update sender balance
        balances[msg.sender] = balances[msg.sender] - rawAmount;

        // update receiver balance
        balances[dst] = balances[dst] + rawAmount;

        _transferTokens(src, dst, rawAmount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function burn(uint256 rawAmount) public {
        uint256 amount =
            safe96(rawAmount, "Token::approve: amount exceeds 96 bits");
        _burn(msg.sender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     */
    function burnFrom(address account, uint256 rawAmount) public {
        uint256 amount =
            safe96(rawAmount, "Token::approve: amount exceeds 96 bits");
        uint256 currentAllowance = allowances[account][msg.sender];
        require(
            currentAllowance >= amount,
            "Token: burn amount exceeds allowance"
        );
        allowances[account][msg.sender] = currentAllowance - amount;
        _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Token: burn from the zero address");
        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {
        require(
            src != address(0),
            "Token::_transferTokens: cannot transfer from the zero address"
        );
        require(
            dst != address(0),
            "Token::_transferTokens: cannot transfer to the zero address"
        );

        // balances[src] = sub96(balances[src], amount, "Token::_transferTokens: transfer amount exceeds balance");
        // balances[dst] = add96(balances[dst], amount, "Token::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {
        require(n < 2**96, errorMessage);
        return uint256(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}