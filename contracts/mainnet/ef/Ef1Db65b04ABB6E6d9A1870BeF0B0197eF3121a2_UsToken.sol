pragma solidity =0.6.12;

import "./ERC20.sol";
import "./Ownable.sol";


contract UsToken is ERC20, Ownable {


    // uint256 private _totalSupply;
    constructor(string memory name_, string memory symbol_, uint256 _total)
    public ERC20(name_, symbol_) {
        //1e26
        _mint(msg.sender, _total);

    }
}