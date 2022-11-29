// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";

contract CCSToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ccs/not-authorized");
        _;
    }
    address public nftaddress = 0x7e62B2354D96237Df1595a855Bcf2C96edb51B9B;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public LPAddress = 0x3d88b4b081B0dF9b7d4107343D3F1Bc83F596210;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
  
    constructor() public ERC20("Cosmic Stars", "CCS") {
        wards[msg.sender] = 1;
        address _uniswapV2Pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), usdt);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(LPAddress, true);
        excludeFromFees(nftaddress, true);
        _mint(LPAddress, 1690000 * 1e18);
    }
	function setOperation(address ust) external auth{
        LPAddress = ust;
	}
	function setNftaddress(address ust) external auth{
        nftaddress = ust;
	}
    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "ccs: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "ccs: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount <= 1E15) {
            super._transfer(from, to, amount);
            return;
        }

        if(automatedMarketMakerPairs[to] && balanceOf(to) ==0) require(_isExcludedFromFees[from], "ccs: 1");
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
        	uint256 fees1 = amount.mul(3).div(100);
            uint256 fees2 = amount.mul(2).div(100);
            super._transfer(from, nftaddress, fees1);
            super._transfer(from, LPAddress, fees2);
            amount = amount.sub(fees1 + fees2);
        }
        super._transfer(from, to, amount);       
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }

}