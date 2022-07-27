/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

// File: Nazasales.sol

contract NazaSales {
    
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
    

    function buyNAZA(address refer1, address refer2, uint256 amount) public payable {
        address referline1 = refer1;
        //address referline2 = refer2;
       
        require(is_active, "This contract is Paused");
        uint256 totalBought = amount * _price;
        require(msg.value >= totalBought, "Insufficient amount");

        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 tokensToSend = amount * decimal_multiplier;
        require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
        //token.transfer(msg.sender, tokensToSend);

         if(referline1 == address(0)) {
            token.transfer(msg.sender, tokensToSend);
        } else {
            token.transfer(msg.sender, tokensToSend);
            token.transfer(referline1, tokensToSend / 20);
            sendValueTo(referline1, msg.value / 20);
        }
        if(refer2 == address(0)) {
            return;
        } else {
            sendValueTo(refer2, msg.value / 50);
            //token.transfer(refer2, tokensToSend / 5);
        }
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