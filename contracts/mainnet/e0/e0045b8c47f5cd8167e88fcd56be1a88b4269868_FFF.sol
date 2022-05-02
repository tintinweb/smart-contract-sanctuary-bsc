// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './Context.sol';
import './Ownable.sol';


contract FFF is ERC20("FFF-token", "FFF"), Ownable{
    using SafeMath for uint256;
    uint256 public constant maxSupply =  10**18 *21000000;
    uint256 public burnRate =  400;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;


    function mint(address _to, uint256 _amount) external  onlyOwner returns (bool) {

        if (_amount.add(totalSupply()) > maxSupply) {
            return false;
        }
        _mint(_to, _amount);
        return true;

    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        uint256  burnAmt = amount.mul(burnRate).div(10000);
        amount = amount.sub(burnAmt);
        super._transfer(sender, recipient, amount);
        if(burnAmt>0)
        {
            super._transfer(sender, burnAddress, burnAmt);
        }

    }

}