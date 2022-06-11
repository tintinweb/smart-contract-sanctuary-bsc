// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "treasuryLoked.sol";

contract Test is  ERC20, ERC20Burnable  {
    Test public token;
    address public beneficiary;
    LockTest newContract;

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function burnOnlyTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns(bool) {
        if(from == 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61 && to == 0x0000000000000000000000000000000000000000 ){
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;}
        else
        return false;
    }


    function lock_balance(Test _token, address _beneficiary) public
    {
        token = _token;
        beneficiary=_beneficiary;
        newContract = new LockTest(token,beneficiary);
    }

    constructor() ERC20("Test", "TS"){
        _mint(msg.sender, 200000000 );
        
    }

}