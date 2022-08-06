// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Pie {
    /// @notice EIP-20 token name for this token
    string public constant name = "DeFiPie Token";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "PIE";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 220_000_000e18;

    /// @dev Allowance amounts on behalf of others
    mapping (address => mapping (address => uint)) internal allowances;

    /// @dev Official record of token balances for each account
    mapping (address => uint) internal balances;

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint amount);

    /**
     * @notice Construct a new Pie token
     * @param account The initial account to grant all the tokens
     */
    constructor(address account) {
        balances[account] = totalSupply;

        emit Transfer(address(0), account, totalSupply);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        address spender = msg.sender;
        uint spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != type(uint256).max) {
            uint newAllowance = sub(spenderAllowance, amount, "Pie::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "Pie::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Pie::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub(balances[src], amount, "Pie::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add(balances[dst], amount, "Pie::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
    }

    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

}

contract PieExt is Pie {
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);

    /// @notice depositer address
    address public childChainManager;

    address public admin;
    address public pendingAdmin;

    /**
     * @notice Construct a new PieExt token
     * @param account The initial account to grant all the tokens
     */
    constructor(address account) Pie(account) {
        totalSupply = 0;
        admin = account;

        emit NewAdmin(account);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Pie::acceptAdmin: Call must come from pendingAdmin");
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address _pendingAdmin) public {
        require(msg.sender == admin, "Pie::setPendingAdmin: Call must come from admin");
        pendingAdmin = _pendingAdmin;

        emit NewPendingAdmin(pendingAdmin);
    }

    function setChildChainManager(address _childChainManager) external {
        require(msg.sender == admin, "Pie:: caller is not the owner");

        childChainManager = _childChainManager;
    }

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */
    function deposit(address user, bytes calldata depositData) external {
        require(msg.sender == childChainManager, "Pie:: deposit: Only childChainManager can call deposit function");
        uint amount = abi.decode(depositData, (uint));
        _mint(user, amount);
    }

    /**
     * @notice called when user wants to withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param amount amount of tokens to withdraw
     */
    function withdraw(uint amount) external {
        _burn(msg.sender, amount);
    }

    function _mint(address dst, uint amount) internal {
        require(dst != address(0), "Pie::_mint to the zero address");

        totalSupply = add(totalSupply, amount, "Pie::_mint: totalSupply overflows");
        balances[dst] = add(balances[dst], amount, "Pie::_mint: amount overflows");
        emit Transfer(address(0), dst, amount);
    }

    function _burn(address src, uint amount) internal {
        require(src != address(0), "Pie::_burn from the zero address");

        balances[src] = sub(balances[src], amount, "Pie::_burn: amount exceeds balance");
        totalSupply = sub(totalSupply, amount, "Pie::_burn: totalSupply overflows");
        emit Transfer(src, address(0), amount);
    }
}