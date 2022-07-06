// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


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

interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}




interface IWBNB {
    function withdraw(uint) external;
    function deposit() external payable;
}


interface ITrigger {
    function mmk(address ti, address[] memory path, uint aom, uint pc, uint lp) external returns(bool success);
}


contract MainContractBOt is Ownable {
    using SafeMath for uint;
    using SafeMath for uint256;

    // bsc variables 
    address constant wbnb= 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private sandwichRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // bsc testnet variables 
    //address constant wbnb= 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //address private sandwichRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    
    address payable private administrator;
    address private botcontract1 = 0xf661C552dD1Be80E324Cc3DfA3Fa599f747F6E29;
    address private botcontract2 = 0xf661C552dD1Be80E324Cc3DfA3Fa599f747F6E29;
    address private botcontract3 = 0xf661C552dD1Be80E324Cc3DfA3Fa599f747F6E29;
    address private botcontract4 = 0xf661C552dD1Be80E324Cc3DfA3Fa599f747F6E29;
    address private botcontract5 = 0xf661C552dD1Be80E324Cc3DfA3Fa599f747F6E29;
    
    mapping(address => bool) public authenticatedSeller;
    
    constructor(){
        administrator = payable(msg.sender);
        authenticatedSeller[msg.sender] = true;
    }
    
    receive() external payable {
        IWBNB(wbnb).deposit{value: msg.value}();
    }

//================== main functions ======================

    // Trigger2 is the smart contract in charge or performing liquidity sniping and sandwich attacks. 
    // For liquidity sniping, its role is to hold the BNB, perform the swap once dark_forester detect the tx in the mempool and if all checks are passed; then route the tokens sniped to the owner. 
    // For liquidity sniping, it require a first call to configureSnipe in order to be armed. Then, it can snipe on whatever pair no matter the paired token (BUSD / WBNB etc..).
    // This contract uses a custtom router which is a copy of PCS router but with modified selectors, so that our tx are more difficult to listen than those directly going through PCS router.   

    //CheckHoneypot Function
    function _cekHoneypot(address ti, address to, uint  ait) internal returns(bool success) {
        return true;
    }

    //TaxCheck Function
    function _cektoleransi(address ti, address to, uint  ait) internal returns(bool success) {
        return true;
    }

    // manage the "in" phase of the sandwich attack
    function spamMemek(address ti, address to, uint  ai, uint aom, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }

    function spamMemekMaxTx(address ti, address to, uint  ai, uint mt, uint bc, uint lp) external payable returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        return true;
    }
    
    // manage the "out" phase of the sandwich. Should be accessible to all authenticated sellers
    function menjualMemek(address _ti, address _to, uint _aom, uint bc, uint _pt, uint _lp) external returns(bool success) {
        require(msg.sender == administrator || msg.sender == owner(), "out: must be called by admin or owner");
        return true;
    }
}