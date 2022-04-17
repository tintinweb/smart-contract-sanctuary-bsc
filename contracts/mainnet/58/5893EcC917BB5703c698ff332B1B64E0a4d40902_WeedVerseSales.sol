/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.8.9;



// Part: IERC20

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: WeedverseSales.sol

contract WeedVerseSales {
    
    bool public is_active = true;
    address public token_address;
    address public owner;
    
    uint256 public totalTokensSold = 0;
    //Token price in BNB
    uint256 private _price = 0.0000025 ether;
    // Token price in USD
    uint256 public _usdPrice = 0.001 ether;
    // Price Denominator
    uint256 private _priceDenom = 10000000;
    mapping (address => uint256) public _tokenBought;
    // Token SOld
    uint256 public tokensSOLD = 0;
    uint256 public usdSold = 0;
    uint256 public bnbSold = 0;

    // Tokens to be supported
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    
    
    event TokensReceived(address _sender, uint256 _amount);
    event OwnershipChanged(address _new_owner);

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Allowed");
        _;
    }

    constructor () {
        owner = msg.sender;
        token_address = 0x1dd453cE32141a80978B0a43Dc519a7d4258796D;
    }

    function change_owner(address _owner) onlyOwner public {
        owner = _owner;
        emit OwnershipChanged(_owner);
    }
    
    function setStrainsaddress(address _address) onlyOwner public {
        token_address = _address;
    }

    function change_state() onlyOwner public {
        is_active = !is_active;
    }


    function get_balance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
    function change_price(uint256 newPrice) public onlyOwner {
        _price = newPrice;
    }
    function changUsdPrice(uint256 _newUsdPrice) public onlyOwner {
        _usdPrice = _newUsdPrice;
    }

    function buyWIID(uint256 amount) public payable {
        require(is_active, "This contract is Paused");
        uint256 totalBought = amount * _price;
        require(msg.value >= totalBought, "Insufficient amount");

        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 tokensToSend = amount * decimal_multiplier;
        require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
        token.transfer(msg.sender, tokensToSend);
    }
    function buyWIIDwithTokens(address tokentoBuy, uint256 tokenAmount, uint256 _amount) public {
        require(is_active, "The sales is Paused");
        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());

        if(tokentoBuy == busd) {
            uint256 busdBought = tokenAmount * _usdPrice;
            require(tokenAmount >= busdBought, "PRICE TOO LOW");
            IERC20 _busdToken = IERC20(busd);
            uint256 busdDecimal = (10 ** _busdToken.decimals());
            uint256 tokensToSend = (_amount * decimal_multiplier);
            uint256 tokensToReceive = (tokenAmount * busdDecimal);

            require(_busdToken.balanceOf(msg.sender) >= tokensToReceive, "Insufficient Funds");
            require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
           _busdToken.transferFrom(msg.sender, address(this), tokensToReceive);
            token.transfer(msg.sender, tokensToSend);
            usdSold += tokenAmount;
        }
        if(tokentoBuy == usdt) {
            uint256 usdtBought = tokenAmount * _usdPrice;
            require(tokenAmount >= usdtBought, "PRICE TOO LOW");
            IERC20 _usdToken = IERC20(busd);
            uint256 busdDecimal = (10 ** _usdToken.decimals());
            uint256 tokensToSend = (_amount * decimal_multiplier);
            uint256 tokensToReceive = (tokenAmount * busdDecimal);

            require(_usdToken.balanceOf(msg.sender) >= tokensToReceive, "Insufficient Funds");
            require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
            _usdToken.transferFrom(msg.sender, address(this), tokensToReceive);
            token.transfer(msg.sender, tokensToSend);
            usdSold += tokenAmount;
        }
        if(tokentoBuy == wbnb) {
            uint256 wbnbBought = tokenAmount * _price;
            require(tokenAmount >= wbnbBought, "PRICE TOO LOW");
            IERC20 _wbnb = IERC20(busd);
            uint256 busdDecimal = (10 ** _wbnb.decimals());
            uint256 tokensToSend = (_amount * decimal_multiplier);
            uint256 tokensToReceive = (tokenAmount * busdDecimal);

            require(_wbnb.balanceOf(msg.sender) >= tokensToReceive, "Insufficient Funds");
            require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
            _wbnb.transferFrom(msg.sender, address(this), tokensToReceive);
            token.transfer(msg.sender, tokensToSend);
            bnbSold += tokenAmount;
        }
        
    tokensSOLD += _amount;
    }

    // global receive function
    receive() external payable {
        emit TokensReceived(msg.sender,msg.value);
    }    
    
    function withdraw_token(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer( msg.sender, balance);
        }
    } 
    function sendValueTo(address to_, uint256 value) internal {
        address payable to = payable(to_);
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed.");
    }
    function withdraw_bnb() public onlyOwner {
        sendValueTo(msg.sender, address(this).balance);
    }
    
    fallback () external payable {}
    
}