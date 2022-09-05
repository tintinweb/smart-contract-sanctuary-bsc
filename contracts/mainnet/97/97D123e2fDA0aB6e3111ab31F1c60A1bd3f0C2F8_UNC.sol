// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


contract UNC is ERC20, Ownable  {
    uint256 public constant MAX = ~uint256(0);
    
    uint256 private constant maxSupply = 130 * 10000 * 1e18;     // the total supply

    using SafeMath for uint256;
    
    uint256 public _destroyFee = 25;
    uint256 public _nftFee = 50;
    uint256 public _auctionFee = 25; 

    address public _swapAddress = 0xD432Bff3f322F37601486F1F513fE9c46690CA25;
    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public usdt;
    uint256 public currentPrice;
    address public uniswapV2Pair;
    
    constructor( ) ERC20("Unicorn Token", "UNC") public {
        _mint(msg.sender, maxSupply);
    }

   
    uint256[4] priceStage = [0, 300 * 1e18, 1000 * 1e18, 3000 * 1e18 ];
    uint256[4] buyFees = [8, 6, 4, 2 ];
    uint256[4] sellFees = [10, 8, 6, 4 ];
    

    uint256 buyFee = buyFees[0];
    uint256 sellFee = sellFees[0];
    uint256 transferFee = 0;
    uint256 extraBuyFee = 0;
    uint256 extraSellFee = 0;

    
    uint256 public INTERVAL = 20 * 60 * 24;     // blocks per day
    uint256 public protectionB;     

    uint256 public lastPrice=100;
    bool public isProtection = false;

    function setProtectionB(uint256 _protectionB) public onlyOwner {
        protectionB = _protectionB;
    }
    function setUsdt(address _usdt) public onlyOwner {
        usdt = _usdt;
    }
    function setProtection(bool _isProtection) public onlyOwner {
        isProtection = _isProtection;
    }
    function setSwapAddress(address swapAddress) public onlyOwner {
        _swapAddress = swapAddress;
    }
    function setUniswapV2Pair(address _uniswapV2Pair) public onlyOwner {
        uniswapV2Pair = _uniswapV2Pair;
    }


    function feeInfo() public view returns (uint256, uint256, uint256, uint256, uint256, uint256 ) {
        return (buyFee, sellFee, transferFee, extraBuyFee, extraSellFee, getPrice());
    }


    function getPrice() public view returns( uint256 ) {
        return IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(IERC20(address(this)).balanceOf(uniswapV2Pair));
    }

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {

        uint256 tax =0;
        if (sender == uniswapV2Pair) {      // buy
            _resetProtection();
            _updateFee();
            tax = amount.mul(buyFee).div(100);
            super._transfer(sender, recipient, amount);
            super._transfer(recipient, _swapAddress, tax);
        } else if (recipient == uniswapV2Pair) {        // sell
            _resetProtection();
            _updateFee();
            tax = amount.mul(sellFee.add(extraSellFee)).div(100);
            super._transfer(sender, recipient, amount );
            super._transfer(sender, _swapAddress, tax );
        } else {        // transfer
                super._transfer(sender,recipient,amount);    
        }
        
    }


    // private function
    function _resetProtection() private {
    
        if ( block.number <= protectionB.add(INTERVAL)) {   // today
            if (  currentPrice < lastPrice.mul(90).div(100) ) {
                extraSellFee = 10;
            }
            if (  currentPrice < lastPrice.mul(80).div(100) ) {
                extraSellFee = 20;
            }
            if (  currentPrice < lastPrice.mul(70).div(100) ) {
                extraSellFee = 30;
            }
        } else {
            protectionB = protectionB.add(INTERVAL);
            lastPrice = currentPrice;
            extraSellFee = 0;
        }
        
    }
    function _updateFee() private {
        currentPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(IERC20(address(this)).balanceOf(uniswapV2Pair));
        for (uint256 i = priceStage.length - 1; i >= 0; i--) {
            if (currentPrice > priceStage[i]) {
                buyFee = SafeMath.min(buyFee, buyFees[i]);
                sellFee = SafeMath.min(sellFee, sellFees[i]);
                break;
            }
            if (i == 0) {
                break;
            }
        }
    }

}