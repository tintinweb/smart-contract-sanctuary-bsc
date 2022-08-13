/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

contract UpGradePlan is Context {
    mapping(address => bool) public isregister;
    address public owner;
    uint256 public buyprice = 1 * 10**18;
    uint256 public sellprice = 1 * 10**18;
    uint256 public fix = 10 ** 18;
    bool public isactivate;
    address public BUSDaddress = 0xC88887bCa276Af4D577a54f4F5376875d628c4a7 ; // -- testnet
    address public mrktoken = 0xC88887bCa276Af4D577a54f4F5376875d628c4a7 ; //-- testnet
    // address public BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 ;
    // address public mrktoken = 0xC88887bCa276Af4D577a54f4F5376875d628c4a7 ;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor() {
        owner = _msgSender();
    }

    // public
    function howtoPay(uint256 _amount) public view returns(uint256){
        return _amount * buyprice;
    }
    function howtoGiven(uint256 _amount) public view returns(uint256){
        return (_amount * fix)  / sellprice;
    }
    // user
    function BUY(uint256 amount)public returns(bool){
        require(!isactivate,"is end time to buy token");
        uint256 buyPrice = amount * buyprice;
        require(buyPrice >= 10**18,"is buy morethen 1 token");
        require(IERC20(BUSDaddress).transferFrom(_msgSender(),address(this),buyPrice),"user is not approve price");
        require(IERC20(mrktoken).balanceOf(address(this)) >= amount,"no balnce in contract");
        IERC20(mrktoken).transfer(_msgSender(),amount);
        return true;
    }
    function SELL(uint256 amount)public returns(bool){
        require(!isactivate,"is end time to sell token");
        require(amount >= 10**18,"is not morethen 1 token");
        uint256 sendprice = (amount * fix) / sellprice;
        require(IERC20(mrktoken).transferFrom(_msgSender(),address(this),amount),"user is not approve price");
        require(IERC20(BUSDaddress).balanceOf(address(this)) >= sendprice,"no balnce in contract");
        IERC20(BUSDaddress).transfer(_msgSender(),sendprice);
        return true;
    }
    // owner only
    function getTokenBack(uint256 amount,address _tokenaddress)public onlyOwner returns(bool){
        require(IERC20(_tokenaddress).balanceOf(address(this)) >= amount,"no balnce in contract");
        IERC20(_tokenaddress).transfer(_msgSender(),amount);
        return true;
    }
    function changeOwner(address _owner) public onlyOwner returns(bool){
        owner = _owner;
        return true;
    }
    function changeBUYprice(uint256 _price) public onlyOwner returns(bool){
        buyprice = _price;
        return true;
    }
    function changeSELLprice(uint256 _price) public onlyOwner returns(bool){
        sellprice = _price;
        return true;
    }
    function changestatus(bool _isactivate) public onlyOwner returns(bool){
        isactivate = _isactivate;
        return true;
    }
    receive() external payable {
    }
}