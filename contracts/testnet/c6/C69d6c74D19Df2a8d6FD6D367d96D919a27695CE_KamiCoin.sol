// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


import "./ERC1155.sol";
import "./ERC20.sol";

contract KamiCoin is ERC1155 {
     
     uint256 public constant NON_FUNGIBLE = 1;
     uint256 private _totalSupply;
     uint8   private _decimals;
     string  public  _symbol;
     string  public  _name;
     uint256 public  _taxFee = 20;
     uint256 private _previousTaxFee = _taxFee;
     uint256 public  _developmentFee = 10;
     uint256 private _previousDevelopmentFee = _developmentFee;
     uint256 public  _liquidityFee = 50;
     uint256 private _previousLiquidityFee = _liquidityFee;
     address private _developmentWalletAddress = 0xE69Ac38Cd6DA0EA9a540B47399C430131216Ced7;
     uint256 private constant MAX = ~uint256(0);
     uint256 public  _tTotal = 1000000000000 * 10**18;
     uint256 private _rTotal = (MAX - (MAX % _tTotal));
     uint256 private _tFeeTotal;


    constructor() ERC1155("JSON_URI") {
    _name = "KamiCoin";
    _symbol = "Kami";
    _decimals = 18; 
    _totalSupply = 1000000000000 * 10**18;
     _mint(msg.sender, NON_FUNGIBLE, 1, "");
    
}
}