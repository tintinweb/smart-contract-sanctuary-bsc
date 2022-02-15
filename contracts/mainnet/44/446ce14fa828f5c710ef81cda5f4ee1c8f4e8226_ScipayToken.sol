pragma solidity 0.5.8;

import "./PermissionService.sol";

contract ScipayToken is PermissionService {
    string public name = "SCIPAY Token";
    string public symbol = "SCIPAY";
    uint8 public decimals = 18;

    event TokensRecovered(address _from, address _to, uint _amount);

    constructor() public {
        _totalSupply = 0;
    }

    function changeSymbol(string memory _newSymbol) public onlyAttributesPermission {
        symbol = _newSymbol;
    }

    function changename(string memory _newName) public onlyAttributesPermission {
        name = _newName;
    }

    function transfer(address _to, uint _amount) public returns(bool) {
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _amount) public returns(bool) {
        return super.transferFrom(_from, _to, _amount);
    }

    function mint(address _for, uint _amount) public onlyMintablePermission {
        _mint(_for, _amount);
    }

    function burn(address _from, uint _amount) public onlyBurnPermission {
        _burn(_from, _amount);
    }

    function recoveryTokens(address _from, address _to) public onlyRecoveryTokensPermission {
        uint balance = balanceOf(_from);

        _burn(_from, balance);
        mint(_to, balance);

        emit TokensRecovered(_from, _to, balance);
    }

}