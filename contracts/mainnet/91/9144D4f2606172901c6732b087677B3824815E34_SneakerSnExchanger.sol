/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC20Full {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external returns (bool);
}

interface IERC20Transfer {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipisent, uint256 amount) external returns (bool);
}

interface ISneakerSnUsers
{
    function isUserExists(address user) external view returns (bool);
    function isUserBotsExists(address user) external view returns (bool);
    function getUser(address user) external view returns (uint,address,uint,uint8,bool);
    function getUserSneakerConditions(address user, uint16 sneaker) external view returns (bool);
    function addUserSneaker(address user, uint8 sneaker, bool activate, bool ignoreConditions) external;
    function getUserSneaker(address user, uint8 sneaker) external view returns (bool,bool,bool,bool,uint16,uint);
    function updateUserSneakerFlag(address user, uint8 sneaker, uint8 flag, bool value) external;
    function updateUserSneakerRCount(address user, uint8 sneaker, uint16 count, bool add) external;
    function getUserReferrer(address user) external view returns (address);
    function getUserReferrer(address user, uint8 sneaker) external view returns (address, bool);
    function getUserAddress(uint user) external view returns (address);
    function isUserSneakerExists(address user, uint8 sneaker) external view returns (bool);
    function setUserSneakerActiveWaiter(address user, uint8 sneaker, uint waiter, bool active) external;
    function getUserSneakerActiveWaiter(address user, uint8 sneaker) external view returns (uint);
    function setUserSneakerConditions(address user, uint8 sneaker) external;
}

contract SneakerSnExchanger {
    using SafeMath for uint;

    address public owner;
    address public snkAddress;
    address public sntAddress;
    address public usersContract;

    bool public paused;
    bool public onlyUsers;
    bool public burnActive;
    bool public mintActive;
    uint public tokenPrice;
    uint public minTokensAmount;
    uint public nextExchangeId;

    ExchangeTransfer[] public exchangeTransfers;

    mapping (address => bool) public dapps;
    mapping(uint => Exchange) public exchanges;

    enum Token { NONE, SNK, SNT}
    enum Action { NONE, MINED, BURNED, TRANSFERRED}

    struct Exchange {
        address wallet;
        Token token;
        uint tokensAmount;
        uint bnbAmount;
        Action action;
    }

    struct ExchangeTransfer {
        address wallet;
        uint percentage;
    }

    event ExchangeDetails(address indexed wallet, uint indexed exchageId, Token token, uint tokensAmount, uint bnbAmount, uint liquidityAmount, uint marketingAmount, uint contractBalance, uint tokenPrice, Action action);
    event ExchangeTransfers(address indexed wallet, uint indexed exchageId, uint indexed exchangeTransferId, uint percentage, uint amount);

    modifier onlyContractOwner() { 
        require(msg.sender == owner, "onlyOwner"); 
        _; 
    }

    modifier onlyDapp() { 
        require(dapps[msg.sender] == true || msg.sender == owner, "onlyDapp"); 
        _; 
    }

    modifier onlyUnpaused() { 
        require(!paused || msg.sender == owner, "paused"); 
        _; 
    }

    function changeSetting(uint8 setting, uint value) external onlyContractOwner() {
        if (setting == 1) {
            paused = !paused;
        } else if (setting == 2) {
            onlyUsers = !onlyUsers;
        } else if (setting == 3) {
            burnActive = !burnActive;
        } else if (setting == 4) {
            mintActive = !mintActive;
        } else if (setting == 5) {
            tokenPrice = value;
        } else if (setting == 6) {
           nextExchangeId = value;
        } else if (setting == 7) {
            minTokensAmount = value;
        }
    }

    function authDapp(address dapp) public onlyContractOwner {
        require(dapp != address(0), "bad dapp address");

        bool dappValue = dapps[dapp];
        dapps[dapp] = !dappValue;
    }

    function changeAddress(uint8 setting, address valueAddress) public onlyContractOwner() {
        if (setting == 1) {
            snkAddress = valueAddress;
        } else if (setting == 2) {
            sntAddress = valueAddress;
        } else if (setting == 3) {
            usersContract = valueAddress;
        }
    }

    function getExchangeTransfer(uint exchangeTransferId) public view returns(address,uint) {
        return (exchangeTransfers[exchangeTransferId].wallet,
                exchangeTransfers[exchangeTransferId].percentage);
    }

    function updateExchangeTransfer(uint exchangeTransferId, address wallet, uint percentage, bool add) public onlyContractOwner() {
        if (add) {
            require(wallet != address(0), "invalid wallet");

            ExchangeTransfer memory exchangeTransfer = ExchangeTransfer({
                wallet: wallet,
                percentage: percentage
            });
            exchangeTransfers.push(exchangeTransfer);
        } else if (exchangeTransferId < exchangeTransfers.length) {
            exchangeTransfers[exchangeTransferId].wallet = wallet;
            exchangeTransfers[exchangeTransferId].percentage = percentage;
        }
    }

    function getExchange(uint exchangeId) public view returns(address,Token,uint,uint,Action) {
        return (exchanges[exchangeId].wallet,
                exchanges[exchangeId].token,
                exchanges[exchangeId].tokensAmount,
                exchanges[exchangeId].bnbAmount,
                exchanges[exchangeId].action);
    }

    function updateExchange(uint exchangeId, address wallet, Token token, uint tokensAmount, uint bnbAmount, Action action) public  onlyDapp() {
        exchanges[exchangeId].wallet = wallet;
        exchanges[exchangeId].token = token;
        exchanges[exchangeId].tokensAmount = tokensAmount;
        exchanges[exchangeId].bnbAmount = bnbAmount;
        exchanges[exchangeId].action = action;
    }

    constructor() public {
        owner = msg.sender;
        paused = false;
        onlyUsers = true;
        tokenPrice = 1e15;
        minTokensAmount = 1e8;
        nextExchangeId = 1;
        burnActive = true;
        mintActive = false;

        snkAddress = address(0xB250E9B5565BE5B5AD63486f65aB922C5Bd0bF86);
        sntAddress = address(0x40d112aFea2F46d766BBec2b98a590Be52EcC75c);
        usersContract = address(0x2F3c2b0EAD7D2157bcE4930f7c7f59cDea889D76);
    }

    fallback() external payable onlyUnpaused() {
        if (msg.sender != owner) {
            _buySnk(msg.sender, msg.value);
        }
    }

    receive() external payable onlyUnpaused() {
        if (msg.sender != owner) {
            _buySnk(msg.sender, msg.value);
        }
    }

    function buySnk() public payable onlyUnpaused() {
        _buySnk(msg.sender, msg.value);
    }

    function _buySnk(address wallet, uint value) private onlyUnpaused() {
        require(wallet != address(0), "invalid wallet");
        require(value >= tokenPrice, "invalid value");

        if (onlyUsers) {
            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(!users.isUserBotsExists(wallet), "user ban");
            require(users.isUserExists(wallet), "user exists");
        }

        uint tokensAmount = value.mul(1e8).div(tokenPrice);
        require(tokensAmount > 0, "invalid tokens amount");

        Exchange memory exchange = Exchange({
            wallet: wallet,
            token: Token.SNK,
            tokensAmount: tokensAmount,
            bnbAmount: value,
            action: Action.NONE 
        });

        exchanges[nextExchangeId] = exchange;

        if (mintActive) {
            require(IERC20Full(snkAddress).mint(wallet, tokensAmount), "error mint SNK Tokens");
            exchanges[nextExchangeId].action = Action.MINED;
        } else {
            if (IERC20Transfer(snkAddress).balanceOf(address(this)) >= tokensAmount) {
                require(IERC20Full(snkAddress).transfer(wallet, tokensAmount), "error transfer SNK Tokens");
                exchanges[nextExchangeId].action = Action.TRANSFERRED;
            } else {
                require(IERC20Full(snkAddress).mint(wallet, tokensAmount), "error mint SNK Tokens");
                exchanges[nextExchangeId].action = Action.MINED;
            }
        }

        uint exchangeTransfersAmount = 0;
        for (uint i = 0; i < exchangeTransfers.length; i++) {
            if (exchangeTransfers[i].wallet == address(0) || exchangeTransfers[i].percentage == 0) {
                continue;
            }
            
            uint amount = value.div(1000).mul(exchangeTransfers[i].percentage); // 10% = 100
            if (amount > 0 && value.sub(exchangeTransfersAmount.add(amount)) >= 0) {
                payable(exchangeTransfers[i].wallet).transfer(amount);
                exchangeTransfersAmount += amount;

                emit ExchangeTransfers(exchangeTransfers[i].wallet, nextExchangeId, i, exchangeTransfers[i].percentage, amount);
            }
        }

        emit ExchangeDetails(wallet, nextExchangeId, Token.SNK, tokensAmount, value, value.sub(exchangeTransfersAmount), exchangeTransfersAmount, address(this).balance, getTokenPrice(), exchanges[nextExchangeId].action);
       
        nextExchangeId++;
    }   

    function receiveApproval(address spender, uint256 value, address tokenAddress, bytes memory extraData)
    public 
    onlyUnpaused()
    {
        require(value > 0, "bad value");
        require(spender != address(0), "bad spender");
        //require(extraData.length == 0, "bad extraData");
        require(address(this).balance > 0, "balance not enough");

        if (tokenAddress == sntAddress) {
            _exchangeSnt(spender, value);
        } else {
            IERC20 token = IERC20(tokenAddress);
            require(token.transferFrom(spender, address(this), value));
        }
    }

    function _exchangeSnt(address wallet, uint value) private {
        if (onlyUsers) {
            ISneakerSnUsers users = ISneakerSnUsers(usersContract);
            require(!users.isUserBotsExists(wallet), "user ban");
            require(users.isUserExists(wallet), "user exists");
        }

        require(value >= minTokensAmount, "invalid tokens amount");
        //check balance wallet
        IERC20Full token = IERC20Full(sntAddress);
        require(token.balanceOf(wallet) >= value, "tokens not enough");
        //try transfer tokens
        require(token.transferFrom(wallet, address(this), value), "error transfer tokens");

        uint liquidity = address(this).balance.div(2);
        uint tokensTotalSupply = token.totalSupply();
        uint amountBnb = liquidity.div(tokensTotalSupply).mul(value);
        require(amountBnb > 0, "error calc bnb");

        //try burn tokens
        Action action = Action.TRANSFERRED;
        if (burnActive) {
            require(token.burn(value), "error burn tokens");
            action = Action.BURNED;
        }

        Exchange memory exchange = Exchange({
            wallet: wallet,
            token: Token.SNT,
            tokensAmount: value,
            bnbAmount: amountBnb,
            action: action
        });

        exchanges[nextExchangeId] = exchange;
        payable(wallet).transfer(amountBnb);

        emit ExchangeDetails(wallet, nextExchangeId, Token.SNT, value, amountBnb, 0, 0, address(this).balance, getTokenPrice(), action);
        
        nextExchangeId++;
    }

    function getTokenPrice() public view onlyUnpaused() returns (uint) {
        IERC20Full token = IERC20Full(sntAddress);

        uint liquidity = address(this).balance.div(2);
        uint tokensTotalSupply = token.totalSupply();
        uint price = liquidity.div(tokensTotalSupply).mul(1e8);

        return price;
    }

    function balanceTokens(Token token) public view onlyUnpaused() returns (uint) {
        //require(token != Token.NONE, "tokens exists");

        if (token == Token.SNK) {
            return IERC20Transfer(snkAddress).balanceOf(address(this));
        } else if (token == Token.SNT) {
            return IERC20Transfer(sntAddress).balanceOf(address(this));
        } else {
            return address(this).balance;
        }
    }

    function withdraw(address token, uint value) public onlyContractOwner {
        if (token == address(0)) {
            address payable ownerPayable = payable(owner);
            if (value == 0) {
                ownerPayable.transfer(address(this).balance);
            } else {
                ownerPayable.transfer(value);
            }
        } else {
            if (value == 0) {
                IERC20Transfer(token).transfer(owner, IERC20Transfer(token).balanceOf(address(this)));
            } else {
                IERC20Transfer(token).transfer(owner, value);
            }
        }
    }
}