//SPDX-License-Identifier: MIT Licensed
pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SeekPresale {
    IBEP20 public token;

    address payable public owner;

    uint256 public tokensPerBnb;

    uint256 public privatetokesPerBNB;

    uint256 public privatePreSaleTime;

    uint256 public preSaleTime;

    uint256 public soldToken;

    uint256 public privateSoldToken;

    uint256 public publicSoldToken;

    uint256 public maxPrivateSaleCap;

    uint256 public maxPublicSaleCap;

    uint256 public maxPerUser;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public privateBalances;
    mapping(address => bool) public whitelisted;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor() {
        owner = payable(msg.sender);
        token = IBEP20(0x7a975659979EE49EEd9B9BD0c564E7F7C67eeFdD);
        privatetokesPerBNB = 12195;
        tokensPerBnb = 6097;
        privatePreSaleTime = block.timestamp + 30 minutes;
        preSaleTime = block.timestamp + 90 minutes;
        maxPrivateSaleCap = 50_000_000 ether;
        maxPublicSaleCap = 100_000_000 ether;
        maxPerUser = 500_000 ether;
    }

    receive() external payable {}

    // to buy Seek token during preSale time

    function buy() public payable {
        require(
            block.timestamp < preSaleTime,
            "Presale is over, Please wait for the main sale"
        );
        require(msg.value > 0, "Please send some BNB");

        uint256 totalNumOfTokens = (msg.value * tokensPerBnb);

        if (block.timestamp < privatePreSaleTime) {
            require(whitelisted[msg.sender], "only for WhiteListed");
            require(
                privateSoldToken + totalNumOfTokens <= maxPrivateSaleCap,
                "Private Sale Cap Reached"
            );
            require(
                privateBalances[msg.sender] + totalNumOfTokens <= maxPerUser,
                "Private Sale Cap Reached for User"
            );
        } else {
            require(
                publicSoldToken + totalNumOfTokens <= maxPublicSaleCap,
                "Public Sale Cap Reached"
            );
            require(
                balances[msg.sender] +
                    privateBalances[msg.sender] +
                    totalNumOfTokens <=
                    maxPerUser,
                "Public Sale Cap Reached for User"
            );
        }
        token.transferFrom(
            owner,
            msg.sender,
            totalNumOfTokens
        );
        soldToken = soldToken + totalNumOfTokens;
        if (block.timestamp < privatePreSaleTime) {
            privateBalances[msg.sender] =
                privateBalances[msg.sender] +
                totalNumOfTokens;
            privateSoldToken = privateSoldToken + totalNumOfTokens;
        } else {
            balances[msg.sender] = balances[msg.sender] + totalNumOfTokens;
            publicSoldToken = publicSoldToken + totalNumOfTokens;
        }
        payable(owner).transfer(msg.value);
        emit BuyToken(msg.sender, totalNumOfTokens);
    }

    // to check number of token for given BNB
    function bnbToToken(uint256 _amount) external view returns (uint256) {
        if (block.timestamp < privatePreSaleTime) {
            return (_amount * privatetokesPerBNB);
        } else if (block.timestamp < preSaleTime) {
            return (_amount * tokensPerBnb);
        } else {
            return 0;
        }
    }

    // to change Price of the token
    function changePrice(uint256 privatePrice,
    uint256 publicPrice) external onlyOwner {
        privatetokesPerBNB = privatePrice;
        tokensPerBnb = publicPrice;
    }

    function setPresaleTime(uint256 privateTime, uint256 publicTime) external onlyOwner {
        privatePreSaleTime = privateTime;
        preSaleTime = publicTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // to withdraw funds for liquidity
    function withdrawFunds(uint256 _value) external onlyOwner {
        payable(owner).transfer(_value);
    }

    //withdaw Lost Token
    function withdrawToken(address losttoken) external onlyOwner {
        IBEP20(losttoken).transfer(
            owner,
            IBEP20(losttoken).balanceOf(address(this))
        );
    }

    // to add users to whitelist
    function addWhiteList(address[] memory _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelisted[_users[i]] = true;
        }
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function contractBalanceBnb() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() external view returns (uint256) {
        return token.allowance(owner, address(this));
    }
}