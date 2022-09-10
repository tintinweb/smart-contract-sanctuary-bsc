// SPDX-License-Identifier: MIT
pragma solidity  ^0.6.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './Context.sol';
import './Ownable.sol';

contract SCTToken is ERC20("SCT", "SCT"), Ownable{

    using SafeMath for uint256;
    uint256 public constant maxSupply =  10**18 *100000000000;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnRate =  30;

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