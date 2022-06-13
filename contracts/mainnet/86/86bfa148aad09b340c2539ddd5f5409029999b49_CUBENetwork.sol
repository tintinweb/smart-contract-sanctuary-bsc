// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './Context.sol';
import './Ownable.sol';


contract CUBENetwork is ERC20("CUBE Network", "CUBE"), Ownable{
    using SafeMath for uint256;
    uint256 public constant maxSupply =  10**18 *1000000000000000000000;





    function mint(address _to, uint256 _amount) external  onlyOwner returns (bool) {

        if (_amount.add(totalSupply()) > maxSupply) {
            return false;
        }
        _mint(_to, _amount);
        return true;

    }




}