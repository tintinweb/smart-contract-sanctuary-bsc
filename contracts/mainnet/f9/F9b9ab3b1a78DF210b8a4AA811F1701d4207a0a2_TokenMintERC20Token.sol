// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract TokenMintERC20Token is ERC20, Ownable {

    uint8 public buyFee;
    uint8 public sellFee;
    uint8 public liquidityFee;

    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;

    address public walletFee = 0x671C07E1dC8539448c7DD6Be246FE606B5BD50cB;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 decimals_,
        uint256 _totalSupply
    ) ERC20(_name, _symbol, decimals_) {

        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());        

        _mint(_msgSender(), _totalSupply);
    }

    function totalFees() public view returns(uint256) {
        return buyFee + sellFee + liquidityFee;
    }

    function setBuyFee(uint8 buyFee_) public onlyOwner {
        buyFee = buyFee_;
    }

    function setSellFee(uint8 sellFee_) public onlyOwner {
        sellFee = sellFee_;
    }

    function setLiquidityFee(uint8 liquidityFee_) public onlyOwner {
        liquidityFee = liquidityFee_;
    }

    function setWalletFee(address walletFee_) public onlyOwner {
        walletFee = walletFee_;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        
        bool isSell = recipient == uniswapV2Pair ? true : false;
        bool isBuy = _msgSender() == uniswapV2Pair ? true : false;
        bool isRole = _msgSender() == owner() || recipient == owner() || _msgSender() == walletFee ? true : false;        
        bool isTransfer = isSell == false && isBuy == false ? true : false;   

        if (isRole || isTransfer) {
            _transfer(_msgSender(), recipient, amount);
        } else {

            (uint256 sendValue, uint256 walletValue) = _getTValues(
                amount, isBuy ? buyFee : sellFee
            );

            _transfer(_msgSender(), recipient, sendValue);

            if(walletValue != 0){
                _transfer(_msgSender(), walletFee, walletValue);
            }

        }

        return true;
    }

    function _getTValues(uint256 tAmount, uint8 taxFee_) public view returns (uint256, uint256) {
        uint256 tBruteValue = tAmount * liquidityFee / 100;
        uint256 walletFeeValue = tAmount * taxFee_ / 100;
        uint256 totalFeeValue = tBruteValue + walletFeeValue;
        return (tAmount - totalFeeValue,walletFeeValue);
    } 


}