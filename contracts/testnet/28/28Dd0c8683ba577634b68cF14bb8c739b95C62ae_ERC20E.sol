/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: CC-BY-ND-4.0

pragma solidity ^0.8.17;

contract protected {
    mapping(address => bool) is_auth;

    function authorized(address addy) public view returns (bool) {
        return is_auth[addy];
    }

    function set_authorized(address addy, bool booly) public onlyAuth {
        is_auth[addy] = booly;
    }

    modifier onlyAuth() {
        require(is_auth[msg.sender] || msg.sender == owner, "not owner");
        _;
    }
    address owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    bool locked;
    modifier safe() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    function change_owner(address new_owner) public onlyAuth {
        owner = new_owner;
    }

    bool exclusiveLock;
    modifier exclusive() {
        require(!exclusiveLock, "reentrant");
        exclusiveLock = true;
        _;
        exclusiveLock = false;
    }

    receive() external payable {}

    fallback() external payable {}
}

interface IERC20E {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract ERC20E is IERC20E, protected {
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name = "TEST"; //fancy name: eg Simon Bucks
    uint8 public decimals = 9; //How many decimals to show.
    string public symbol = "TST"; //An identifier: eg SBX

    constructor(uint256 _initialAmount) {
        balances[msg.sender] = _initialAmount; // Give the creator all initial tokens
        emit Transfer(address(0), msg.sender, _initialAmount);
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)
        public
        override
        exclusive
        returns (bool success)
    {
        require(
            balances[msg.sender] >= _value,
            "token balance is lower than the value requested"
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override exclusive returns (bool success) {
        uint256 _allowance = allowed[_from][msg.sender];
        if(_from==msg.sender) {
            _allowance = MAX_UINT256;
        }
        require(
            balances[_from] >= _value && _allowance >= _value,
            "token balance or allowance is lower than amount requested"
        );
        balances[_to] += _value;
        balances[_from] -= _value;
        if (_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    // SECTION Extended functions to enable liquidity and trading without the need for a DEX

    uint256 native_in_liquidity;
    uint256 token_in_liquidity;

    mapping(address => uint256) native_in;
    mapping(address => uint256) token_in;

    // ANCHOR Liquidity methods
    // REVIEW Look if the formula is correct and if the rounding is correct

    /// @dev Get the amount of native and tokens owned by the liquidity provider
    /// @param _owner The address of the liquidity provider
    function get_owned_tokens(address _owner)
        public
        view
        returns (uint256 token, uint256 native)
    {
        uint256 native_in_user = (native_in_liquidity * native_in[_owner]) /
            100;
        uint256 token_in_user = (token_in_liquidity * token_in[_owner]) / 100;
        return (token_in_user, native_in_user);
    }

    /// @dev Add liquidity to the pool (native as msg.value)
    /// @param token_amount Amount of token to add
    function add_liquidity(uint256 token_amount) public payable safe {
        uint256 native_amount = msg.value;
        // Transfer from user to contract
        bool success = transferFrom(msg.sender, address(this), token_amount);
        require(success, "transferFrom failed");
        // Updating liquidity pool
        native_in_liquidity += native_amount;
        token_in_liquidity += token_amount;
        // Updating user liquidity info
        // Getting the user's share of the pool
        uint256 native_in_user;
        uint256 token_in_user;
        (native_in_user, token_in_user) = get_owned_tokens(msg.sender);
        // Updating user's share of the pool
        native_in_user += native_amount;
        token_in_user += token_amount;
        // Recalculating user's share of the pool in %
        native_in[msg.sender] =
            (native_amount / native_in_liquidity) *
            100;
        token_in[msg.sender] =
            (token_amount / token_in_liquidity) *
            100;
    }

    /// @dev Withdraws the user's share of the liquidity pool
    /// @param token_amount The amount of tokens to withdraw
    /// @param native_amount The amount of native tokens to withdraw
    function remove_liquidity(uint256 token_amount, uint256 native_amount)
        public
        safe
    {
        // Checking if the user has enough liquidity
        uint256 native_in_user;
        uint256 token_in_user;
        (native_in_user, token_in_user) = get_owned_tokens(msg.sender);
        require(
            native_in_user >= native_amount,
            "not enough native in liquidity"
        );
        require(
            token_in_user >= token_amount,
            "not enough token in liquidity"
        );
        // Updating the liquidity pool
        native_in_liquidity -= native_amount;
        token_in_liquidity -= token_amount;
        // Updating user's share of the pool
        native_in_user -= native_amount;
        token_in_user -= token_amount;
        // Recalculating user's share of the pool in %
        native_in[msg.sender] =
            (native_in_user / native_in_liquidity) *
            100;
        token_in[msg.sender] =
            (token_in_user / token_in_liquidity) *
            100;
        // Transferring
        bool success = transfer(msg.sender, token_amount);
        require(success, "transfer failed");
        (bool paid, ) = msg.sender.call{value: native_amount}("");
        require(paid, "transfer failed");
    }

    /// @dev Get the amount of native per token at the current price
    function get_native_per_token() public view returns (uint256) {
        require(native_in_liquidity > 0, "no native liquidity");
        return token_in_liquidity / native_in_liquidity;
    }

    /// @dev Get the amount of token per native at the current price
    function get_token_per_native() public view returns (uint256) {
        require(token_in_liquidity > 0, "no token liquidity");
        return native_in_liquidity / token_in_liquidity;
    }

    /// @dev Calculate an output value based on the reserve provided and the amount of input
    /// @param amount_in The amount of input value
    /// @param reserve_in The amount of reserve input
    /// @param reserve_out The amount of reserve output
    /// @return amount_out The amount of output value
    function get_amount_out(
        uint256 amount_in,
        uint256 reserve_in,
        uint256 reserve_out
    ) public pure returns (uint256 amount_out) {
        require(amount_in > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserve_in > 0 && reserve_out > 0, "INSUFFICIENT_LIQUIDITY");
        uint256 amount_in_with_fee = amount_in * 997;
        uint256 numerator = amount_in_with_fee * reserve_out;
        uint256 denominator = reserve_in * 1000 + amount_in_with_fee;
        amount_out = numerator / denominator;
    }

    // ANCHOR Swap methods

    /// @dev Simulate a buy and return the amount of tokens calculated
    /// @param native_amount The amount of input value
    /// @return token_amount The amount of output value
    function simulate_buy(uint256 native_amount) public view returns (uint256) {
        uint256 token_amount = get_amount_out(
            native_amount,
            native_in_liquidity,
            token_in_liquidity
        );
        return token_amount;
    }

    /// @dev Simulate a sell and return the amount of tokens calculated
    /// @param token_amount The amount of input value
    /// @return native_amount The amount of output value
    function simulate_sell(uint256 token_amount) public view returns (uint256) {
        uint256 native_amount = get_amount_out(
            token_amount,
            token_in_liquidity,
            native_in_liquidity
        );
        return native_amount;
    }

    /// @dev Buy tokens with native
    function buy_with_native() public payable safe {
        uint256 value = msg.value;
        uint256 token_amount = simulate_buy(value);
        require(token_amount > 0, "token amount is 0");
        // Updating liquidity pool
        native_in_liquidity += value;
        // Sending tokens to user
        bool success = transfer(msg.sender, token_amount);
        require(success, "transfer failed");
        token_in_liquidity -= token_amount;
    }

    /// @dev Sell tokens for native
    /// @param amount The amount of tokens to sell
    function sell_to_native(uint256 amount) public returns (uint256) {
        uint256 native_amount = get_amount_out(
            amount,
            token_in_liquidity,
            native_in_liquidity
        );
        require(native_amount > 0, "native amount is 0");
        bool get = transferFrom(msg.sender, address(this), amount);
        require(get, "transferFrom failed");
        // Updating liquidity pool
        token_in_liquidity += amount;
        // Sending native to user
        (bool paid, ) = msg.sender.call{value: native_amount}("");
        require(paid, "transfer failed");
        native_in_liquidity -= native_amount;
        return native_amount;
    }

    function buy_with_token(address token, uint256 amount)
        public
        returns (uint256)
    {
        // TODO Support other tokens
    }

    function sell_to_token(address token, uint256 amount)
        public
        returns (uint256)
    {
        // TODO Support other tokens
    }

    // !SECTION Extended functions to enable liquidity and trading without the need for a DEX
}