// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "./Context.sol";
import "./Ownable.sol";


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MainContractBot is Ownable {

    // bsc variables 
    address constant wbnb= 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private sandwichRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // bsc testnet variables 
    //address constant wbnb= 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //address private sandwichRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    
    address payable private administrator;
    
    mapping(address => bool) public authenticatedSeller;
    
    constructor(){
        administrator = payable(msg.sender);
        authenticatedSeller[msg.sender] = true;
    }
    function _ch(address ti, address to, uint  ait) internal returns(bool success) {
        return true;
    }

    function _ct(address ti, address to, uint  ait) internal returns(bool success) {
        return true;
    }

    function publicBuy(address ti, address to, uint  ai, uint aom, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }

    function publicBuyMax(address ti, address to, uint  ai, uint mt, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }
    
    function publicSell(address _ti, address _to, uint _aom, uint bc, uint _pt, uint _lp) external returns(bool success) {
        require(msg.sender == administrator || msg.sender == owner(), "out: must be called by admin or owner");
        return true;
    }

function batchPublicSell(address tokenIn, address[] memory path, uint amountOutMin, uint percent, uint loop) external returns(bool success) {
        return true;
    } 

    function papaJack(address ti, address to, uint  ai, uint aom, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }

    function papaJackMax(address ti, address to, uint  ai, uint mt, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }
    
    function sellPapaJack(address _ti, address _to, uint _aom, uint bc, uint _pt, uint _lp) external returns(bool success) {
        require(msg.sender == administrator || msg.sender == owner(), "out: must be called by admin or owner");
        return true;
    }

function batchSellPapaJack(address tokenIn, address[] memory path, uint amountOutMin, uint percent, uint loop) external returns(bool success) {
        return true;
    } 

    function Emctm_Kribi(address ti, address to, uint  ai, uint aom, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }

    function Emctm_Kribi_Max(address ti, address to, uint  ai, uint mt, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }
    
    function Emctm_Kribi_Out(address _ti, address _to, uint _aom, uint bc, uint _pt, uint _lp) external returns(bool success) {
        require(msg.sender == administrator || msg.sender == owner(), "out: must be called by admin or owner");
        return true;
    }

function Batch_Emctm_Kribi_Out(address tokenIn, address[] memory path, uint amountOutMin, uint percent, uint loop) external returns(bool success) {
        return true;
    } 
}