// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./Address.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
contract GUTSINUTOKEN is ERC20 ,Ownable{
    using SafeMath for uint256;
    using Address for address;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public _isInit = false;
    uint256 public _taxfee;
    address public _marketingwallet;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 1000 * (10**6) * _DECIMALFACTOR;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }
    function initSupply(address _preSale,
                address _marketingAddr,
                address _team,
                address _burn,
                address _lsfee) external onlyOwner {
          require(!_isInit, "inited");
          _isInit = true;
          _mint(_preSale, TOTAL_SUPPLY.mul(82).div(100));
          _mint(_marketingAddr, TOTAL_SUPPLY.mul(1).div(100));
          _mint(_team, TOTAL_SUPPLY.mul(6).div(100));
          _mint(_burn, TOTAL_SUPPLY.mul(10).div(100));
          _mint(_lsfee, TOTAL_SUPPLY.mul(1).div(100));
    }
    
    /**
    * @dev Set marketing adress wallet
    */

    function setFeeMarketingWallet(address walletAddress) public onlyOwner {
        _marketingwallet = walletAddress;
    }
    /**
    * @dev Set fee for transactions
    */

    function setTransactionFee(uint256 fee) public onlyOwner {
        _taxfee = fee;
    }
 
    function _transfer( address sender, address recipient, uint256 amount ) internal virtual override {
        if (
            _taxfee > 0 &&
            recipient != address(0) &&
            _marketingwallet != address(0) ) {
            uint256 _mfee = amount.div(100).mul(_taxfee);
            super._transfer(sender, _marketingwallet, _mfee);
            amount = amount.sub(_mfee);
        }

        super._transfer(sender, recipient, amount);
    }
}