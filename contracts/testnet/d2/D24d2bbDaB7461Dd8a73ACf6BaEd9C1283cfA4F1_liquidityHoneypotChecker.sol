/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);

    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
   
    function owner() public view virtual returns (address) {
        return _owner;
    }
  
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
   
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}


contract liquidityHoneypotChecker is Ownable {
    // Déclaration des variables
    address swapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address wTokenGas = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function setVariables(address _swapRouter, address _wTokenGas) external onlyOwner {
        swapRouter = _swapRouter;
        wTokenGas = _wTokenGas;
    }

    // Test du honeypot en construisant une transaction d'achat, l'approval et la vente
    function honeypotChecker(address _tokenToTest) external returns (uint[] memory amounts) {
        // Déclaration des tableaux d'adresses pour le swap d'achat et le swap de vente
        address[] memory pathIn;
        pathIn = new address[](2);
        pathIn[0] = wTokenGas;
        pathIn[1] = _tokenToTest; 

        address[] memory pathOut;
        pathOut = new address[](2);
        pathOut[0] = _tokenToTest;
        pathOut[1] = wTokenGas; 

        IERC20(wTokenGas).transferFrom(msg.sender, address(this), 300000000000000);

        // On approve le token pour le montant à dépenser
        IERC20(wTokenGas).approve(swapRouter, 300000000000000);

        // Appelle la fonction swapExactTokensForTokens
        // On utilise le timestamp du block en cours pour la limite de validité du trade
        uint[] memory amountTokensSwapped = IUniswapV2Router(swapRouter).swapExactTokensForTokens(300000000000000, 0, pathIn, address(this), block.timestamp);

        // On approve le token pour le montant à dépenser
        IERC20(_tokenToTest).approve(swapRouter, 115792089237316195423570985008687907853269984665640564039457584007913129639930);
        
        // Appelle la fonction swapExactTokensForTokens
        // On utilise le timestamp du block en cours pour la limite de validité du trade
        return IUniswapV2Router(swapRouter).swapExactTokensForTokens(amountTokensSwapped[pathIn.length - 1], 0, pathOut, msg.sender, block.timestamp);
    }
}