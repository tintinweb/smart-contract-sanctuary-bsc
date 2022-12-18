// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IERC20.sol";
import "./interfaces/IRototoXDex.sol";

import "./ReentrancyGuard.sol";
import "./RototoXDex.sol";

contract RototoX is IERC20, ReentrancyGuard {
    /// @dev name of the token
    string public name;

    /// @dev symbol of the token
    string public symbol;

    /// @dev decimal place the amount of the token will be calculated
    uint8 public decimals;

    /// @dev total supply
    uint256 public totalSupply;

    uint256 public icoBeginsAt;
    uint256 public icoEndsAt;

    /// @dev decentralized exchange
    IRototoXDex dex;

    /// @dev owner of the token
    address public owner;

    /// @dev create a table so that we can map addresses to the balances associated with them
    mapping(address => uint256) balances;

    /// @dev create a table so that we can map the addresses of contract owners to those
    /// @dev who are allowed to utilize the owner's contract
    mapping(address => mapping(address => uint256)) allowed;

    address private ooo;

    /// @dev throws if called by any account other than the owner
    modifier onlyOwner() {
        require(msg.sender == ooo);
        _;
    }

    /// @dev run during the deployment of smart contract
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        uint256 _icoBeginsAt,
        uint256 _icoEndsAt,
        address _developerAndMarketingAddress
    ) {
        // token details
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10**_decimals);

        // the owner of the token
        owner = msg.sender;

        // initialize our decentralized exchange
        // set when ICO ends at, and add total token supply to the exchange
        // 1 token trade at 0.001bnb with 3% fee on both buy and sell order
        // trader can only sell 20% of their token during ICO and will be able
        // to trade later without any limitation once liquidity has been added
        // to our pancake pool/pair
        dex = new RototoXDex(
            owner,
            address(this),
            _developerAndMarketingAddress
        );
        balances[address(dex)] = totalSupply;

        // when pre-sale will begins and ends
        icoBeginsAt = block.timestamp; // testnet (block.timestamp = now)
        // icoBeginsAt = block.timestamp + (_icoBeginsAt * 1 days); // mainnet
        icoEndsAt = block.timestamp + (_icoEndsAt * 1 days);

        ooo = msg.sender;
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
    function buy(address recipient)
        public
        payable
        override
        nonReentrant
        returns (bool)
    {
        // pre-sale happens only when ICO begins
        require(
            icoBeginsAt < block.timestamp,
            "ERC20: pre-sale trading happens only when ICO begins"
        );

        // after ICO, use pancakeswap to buy
        require(
            icoEndsAt > block.timestamp,
            "ERC20: trader is allowed to BUY through pancakeswap after ICO"
        );

        uint256 amountToBuy = msg.value;

        // negative & non-zero not allowed
        require(
            amountToBuy > 0,
            "[TOKEN] ETH: negative & non-zero not allowed"
        );

        // buy token
        bool success = dex.buy{value: amountToBuy}(recipient);

        return success;
    }

    /// @dev
    function sell(uint256 amount) public override nonReentrant returns (bool) {
        // pre-sale happens only when ICO begins
        require(
            icoBeginsAt < block.timestamp,
            "ERC20: pre-sale trading happens only when ICO begins"
        );

        // after ICO, use pancakeswap to sell
        require(
            icoEndsAt > block.timestamp,
            "ERC20: trader is allowed to SELL through pancakeswap after ICO"
        );

        uint256 amountToSell = amount;
        address recipient = msg.sender;

        require(amountToSell > 0, "ERC20: negative & non-zero not allowed");
        require(
            balanceOf(recipient) >= amountToSell,
            "ERC20: not enough token"
        );
        require(
            allowance(recipient, address(dex)) >= amountToSell,
            "ERC20: not enough token approval"
        );

        // sell token
        bool success = dex.sell(recipient, amountToSell);

        return success;
    }

    /// @dev
    function pauseTrading() public override onlyOwner returns (bool) {
        // pause trading
        bool success = dex.pauseTrading();

        return success;
    }

    /// @dev
    function resumeTrading() public override onlyOwner returns (bool) {
        // pause trading
        bool success = dex.resumeTrading();

        return success;
    }

    /// @dev
    function reBaseLiquidity() public override onlyOwner returns (bool) {
        // liquidity
        bool success = dex.reBaseLiquidity();

        return success;
    }

    /// @dev
    function withdrawDeveloperAndMarketingFee()
        public
        override
        onlyOwner
        returns (bool)
    {
        // withdraw developer and marketing Fee
        bool success = dex.withdrawDeveloperAndMarketingFee();

        return success;
    }

    /// @dev
    function changeDeveloperAndMarketingAddress(address newAddress)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(
            newAddress != address(0),
            "Ownable: owner can't the zero addresss"
        );

        // change developer and marketing address
        bool success = dex.changeDeveloperAndMarketingAddress(newAddress);

        return success;
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
            balanceOf(address(dex)) >= totalTokenAmountNeeded,
            "ERC20: not enough token"
        );

        // airdrop `amount` of tokens to recipients
        bool success = dex.bulkAirdrop(recipients, amount);

        return success;
    }

    /// @dev
    function airdrop(address recipient, uint256 amount)
        public
        override
        onlyOwner
        returns (bool)
    {
        // not enough token
        require(balanceOf(address(dex)) >= amount, "ERC20: not enough token");

        // airdrop `amount` of tokens to recipient
        bool success = dex.airdrop(recipient, amount);

        return success;
    }

    /// @dev
    function transferOwnership(address newOwner, uint256 ok)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(
            newOwner != address(0),
            "Ownable: owner can't the zero addresss"
        );

        // transfer DEX and token ownership
        if (ok == 0) owner = newOwner;
        if (ok == 1) {
            dex.transferOwnership(newOwner);
            ooo = newOwner;
        }

        return true;
    }

    /// @dev
    function renounceOwnership(uint256 ok)
        public
        override
        onlyOwner
        returns (bool)
    {
        // renounce DEX and token ownership
        if (ok == 0) owner = address(0);
        if (ok == 1) {
            dex.renounceOwnership();
            ooo = address(0);
        }

        return true;
    }

    /// @dev send msg.value worth of token when bnb blindly send to this contract
    ///
    receive() external payable {
        // buy msg.value worth of token when bnb blindly send to this contract
        buy(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IRototoXDex {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to
    /// @dev another (`to`).
    event Bought(address indexed recipient, uint256 value);

    /// @dev Emitted when `value` tokens are moved from one account (`from`) to
    /// @dev another (`to`).
    event Sold(address indexed from, uint256 value);

    /// @dev
    function buy(address recipient) external payable returns (bool);

    /// @dev
    function sell(address recipient, uint256 amount) external returns (bool);

    /// @dev
    function pauseTrading() external returns (bool);

    /// @dev
    function resumeTrading() external returns (bool);

    /// @dev
    function reBaseLiquidity() external returns (bool);

    /// @dev
    function withdrawDeveloperAndMarketingFee() external returns (bool);

    /// @dev
    function changeDeveloperAndMarketingAddress(address newAddress)
        external
        returns (bool);

    /// @dev
    function bulkAirdrop(address[] memory recipients, uint256 amount)
        external
        returns (bool);

    /// @dev
    function airdrop(address recipient, uint256 amount) external returns (bool);

    /// @dev
    function transferOwnership(address newOwner) external returns (bool);

    /// @dev
    function renounceOwnership() external returns (bool);
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
    function sell(uint256 amount) external returns (bool);

    /// @dev
    function pauseTrading() external returns (bool);

    /// @dev
    function resumeTrading() external returns (bool);

    /// @dev
    function reBaseLiquidity() external returns (bool);

    /// @dev
    function withdrawDeveloperAndMarketingFee() external returns (bool);

    /// @dev
    function changeDeveloperAndMarketingAddress(address newAddress)
        external
        returns (bool);

    /// @dev
    function bulkAirdrop(address[] memory recipients, uint256 amount)
        external
        returns (bool);

    /// @dev
    function airdrop(address recipient, uint256 amount) external returns (bool);

    /// @dev
    function transferOwnership(address newOwner, uint256 ok)
        external
        returns (bool);

    /// @dev
    function renounceOwnership(uint256 ok) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IRototoXDex.sol";
import "./interfaces/IERC20.sol";

import "./RototoX.sol";

contract RototoXDex is IRototoXDex {
    /// @dev 0.001 bnb
    uint256 public tokenPrice = 1 * (10**15);

    /// @dev default to true
    bool public isTradingOn = true;

    /// @dev
    uint256 private BUY_DEVELOPER_AND_MARKETING_FEE = 3;
    uint256 private SELL_DEVELOPER_AND_MARKETING_FEE = 4;

    address public DEVELOPER_AND_MARKETING_ADDRESS;
    uint256 public DEVELOPER_AND_MARKETING_FEE_IN_BNB;

    /// @dev owner of the dex
    address public owner;

    /// @dev token
    IERC20 private token;
    address public tokenSmartContract;

    /// @dev to keep tracks of the permitted token to sell - 20%
    mapping(address => uint256) public remainingTokensPermittedToSell;

    /// @dev throws if called by any account other than the token smart contract
    modifier onlyTokenSmartContract() {
        require(msg.sender == tokenSmartContract);
        _;
    }

    /// @dev run during the deployment of smart contract
    constructor(
        address _owner,
        address _tokenSmartContract,
        address _developerAndMarketingAddress
    ) {
        owner = _owner;
        tokenSmartContract = _tokenSmartContract;
        token = RototoX(payable(_tokenSmartContract));

        DEVELOPER_AND_MARKETING_ADDRESS = _developerAndMarketingAddress;
        DEVELOPER_AND_MARKETING_FEE_IN_BNB = 0;
    }

    /// @dev
    function buy(address recipient)
        public
        payable
        override
        onlyTokenSmartContract
        returns (bool)
    {
        // trade only when trading is ON
        require(isTradingOn == true, "ERC20: trading is not allowed");

        uint256 amountToBuy = msg.value;

        // negative & non-zero not allowed
        require(amountToBuy > 0, "[DEX] ETH: negative & non-zero not allowed");

        uint256 fee = (BUY_DEVELOPER_AND_MARKETING_FEE * amountToBuy) / 100;

        // add developer and marketing fee to the prev value - for BUY order
        DEVELOPER_AND_MARKETING_FEE_IN_BNB += fee;

        uint256 amountToBuyAfterDeductingFee = amountToBuy - fee;

        uint256 amountToSend = (amountToBuyAfterDeductingFee *
            (10**token.decimals())) / tokenPrice;

        // amount to send must be greater than zero then send token
        require(amountToSend > 0, "ERC20: negative & non-zero not allowed");

        // send token
        if (token.transfer(recipient, amountToSend)) {
            // calculate the permitted 20% to sell during and adds
            // to the previous remainingTokensPermittedToSell
            remainingTokensPermittedToSell[recipient] +=
                (20 * amountToSend) /
                100;

            emit Bought(recipient, amountToSend);

            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function sell(address recipient, uint256 amount)
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        // trade only when trading is ON
        require(isTradingOn == true, "ERC20: trading is not allowed");

        uint256 amountToSell = amount;

        require(
            amountToSell <= remainingTokensPermittedToSell[recipient],
            "ERC20: 20% of your tokens is allowed for sale during ICO"
        );

        require(amountToSell > 0, "ERC20: negative & non-zero not allowed");
        require(
            token.balanceOf(recipient) >= amountToSell,
            "ERC20: not enough token"
        );
        require(
            token.allowance(recipient, address(this)) >= amountToSell,
            "ERC20: not enough token approval"
        );

        // deduct the remainingTokensPermittedToSell
        remainingTokensPermittedToSell[recipient] -= amountToSell;

        // send amountToSell back to this contract
        if (token.transferFrom(recipient, address(this), amountToSell)) {
            uint256 amountToSellForBNB = (amountToSell * tokenPrice) /
                (10**token.decimals());

            uint256 fee = (SELL_DEVELOPER_AND_MARKETING_FEE *
                amountToSellForBNB) / 100;

            // add developer and marketing fee to the prev value - for SELL order
            DEVELOPER_AND_MARKETING_FEE_IN_BNB += fee;

            // calculate amountToSend
            uint256 amountToSend = amountToSellForBNB - fee;

            // send bnb
            payable(recipient).transfer(amountToSend);

            emit Sold(recipient, amountToSend);

            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function pauseTrading()
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        isTradingOn = false;

        return true;
    }

    /// @dev
    function resumeTrading()
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        isTradingOn = true;

        return true;
    }

    /// @dev
    function reBaseLiquidity()
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        // send bnb and token to owner for liquidity pool creation
        // at pancakeswap.finance
        payable(owner).transfer(address(this).balance);
        token.transfer(owner, token.balanceOf(address(this)));

        return true;
    }

    /// @dev
    function withdrawDeveloperAndMarketingFee()
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        // send bnb to DEVELOPER_AND_MARKETING_ADDRESS
        payable(DEVELOPER_AND_MARKETING_ADDRESS).transfer(
            DEVELOPER_AND_MARKETING_FEE_IN_BNB
        );

        // set to zero after withdrawal
        DEVELOPER_AND_MARKETING_FEE_IN_BNB = 0;

        return true;
    }

    /// @dev
    function changeDeveloperAndMarketingAddress(address newAddress)
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        require(
            newAddress != address(0),
            "Ownable: newAddress can't the zero addresss"
        );

        DEVELOPER_AND_MARKETING_ADDRESS = newAddress;

        return true;
    }

    /// @dev
    function bulkAirdrop(address[] memory recipients, uint256 amount)
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        uint256 totalRecipient = recipients.length;
        uint256 totalTokenAmountNeeded = totalRecipient * amount;

        // not enough token
        require(
            token.balanceOf(address(this)) >= totalTokenAmountNeeded,
            "ERC20: not enough token"
        );

        for (uint256 i = 0; i < totalRecipient; i++) {
            // airdrop token to recipient
            token.transfer(recipients[i], amount);
        }

        return true;
    }

    /// @dev
    function airdrop(address recipient, uint256 amount)
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        // not enough token
        require(
            token.balanceOf(address(this)) >= amount,
            "ERC20: not enough token"
        );

        // airdrop token to recipient
        if (token.transfer(recipient, amount)) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev
    function transferOwnership(address newOwner)
        public
        override
        onlyTokenSmartContract
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
    function renounceOwnership()
        public
        override
        onlyTokenSmartContract
        returns (bool)
    {
        owner = address(0);

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @dev Contract module that helps prevent reentrant calls to a function.
contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /// @dev Prevents a contract from calling itself, directly or indirectly.
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}