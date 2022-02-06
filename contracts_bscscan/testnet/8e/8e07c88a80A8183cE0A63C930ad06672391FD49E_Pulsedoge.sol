// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interfaces/IPulsedoge.sol";

contract Pulsedoge {
    string public constant name = "Pulsedoge";
    string public constant symbol = "Pulsedoge";

    uint256 public totalSupply = 1e9 ; //1B tokens
    uint8 public constant decimals = 0;

    address public owner;

    /// xPulsedoge token address
    IPulsedoge public xPulsedoge;
    /// Dead address
    address private constant DEAD_ADDRESS = address(0xdEaD);
    uint256 private xRewardBalance ;

    mapping(address => uint256) internal balances;
    mapping(address => uint256) private xPulsedogeBalances;

    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed _owner,
        address indexed spender,
        uint256 value
    );

    event UpdatedxPulsedogeAddress(address indexed xPulsedogeToken);

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = address(msg.sender);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /*
     * Transfer Pulsedoge tokens to  'to' address.
     * If tokens are sent to '0' or 'dead' address, user get exqual amount of xPulsedoge
     * tokens as reward 
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        /* 
         * When user sends pulsedoge tokens to 0 or DEAD address, equivalent 
         * amount of xPulsedoge tokens are given as reward 
         */
        if ( (address(xPulsedoge) != address(0)) && ((to == address(0)) || (to == DEAD_ADDRESS)) ) {
            uint256 balance = xPulsedoge.balanceOf(address(this));
            require(balance >= xRewardBalance + amount, "Insufficient xPulsedoge balance");
            xPulsedogeBalances[msg.sender] += amount; 
            xRewardBalance += amount;
            totalSupply -= amount;
        } 

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*
     * Transfer Pulsedoge tokens 'from' address to  'to' address.
     * If tokens are sent to '0' or 'dead' address, user get exqual amount of xPulsedoge
     * tokens as reward 
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] -= amount;

        /* 
         * When user sends pulsedoge tokens to 0 or DEAD address, equivalent 
         * amount of xPulsedoge tokens are given as reward 
         */
        if ( (address(xPulsedoge) != address(0)) && ((to == address(0)) || (to == DEAD_ADDRESS)) ) {
           uint256 balance = xPulsedoge.balanceOf(address(this));
            require(balance >= xRewardBalance + amount, "Insufficient xPulsedoge balance");
            xPulsedogeBalances[from] += amount; 
            xRewardBalance += amount;
            totalSupply -= amount;
        } 

        emit Transfer(from, to, amount);
        
        return true;
    }

    /*
     * Burn Pulsedoge tokens
     */
    function burn(address account, uint256 amount) external {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /*
     * Swap Pulsedoge tokens with xPulsedoge tokens and burn Pulsedoge tokens
     */
    function swap(uint256 amount) external returns (bool) {
        if ( address(xPulsedoge) != address(0)) {
            require(balances[msg.sender] >= amount, "Insufficient caller balance");
            uint256 balance = xPulsedoge.balanceOf(address(this));
            require(balance >= xRewardBalance + amount, "Insufficient xPulsedoge balance");

            // Burning Pulsedoge tokens
            balances[msg.sender] -= amount;
            totalSupply -= amount;
            emit Transfer(msg.sender, address(0), amount);

            // Transfer equal amount of xPulsedoge tokens
            xPulsedoge.transfer(
                address(msg.sender),
                amount
            );
        } 

        return true;
    }

    /*
     * Claim xPulsedoge tokens if any
     */
    function claimxPulsedogeTokens() external {
        uint256 amount = xPulsedogeBalances[msg.sender];
        require(amount > 0, "Amount is zero");
        
        xPulsedogeBalances[msg.sender] -= amount;
        xRewardBalance -= amount;
        
        xPulsedoge.transfer(
            address(msg.sender),
                amount
        );
    }

    /*
     * Get user claimable xPulsedoge tokens if any
     */
    function getClaimablexPulsedogeTokens(address user) view external returns (uint256) {
        require(user != address(0), "Invalid address");    
        return xPulsedogeBalances[user];
    }

    /*
     * set xPulsedoge address
     */
    function setxPulsedogeAddress(address xPulsedogeToken) external {
        require(msg.sender == owner, "Caller must be owner");
        xPulsedoge = IPulsedoge(xPulsedogeToken);
       
        emit UpdatedxPulsedogeAddress(xPulsedogeToken);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPulsedoge {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(address account, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}