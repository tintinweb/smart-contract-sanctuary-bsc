// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

interface IDao {
    function setRelationship(
        address form,
        address to,
        uint256 amount
    ) external;
}

contract RelationToken is ERC20, Ownable {
    mapping(address => bool) public access;

    address public dao_addr;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) ERC20(name, symbol, decimals) {}

    function setAccess(address _user, bool _access) public onlyOwner {
        access[_user] = _access;
    }

    function setDao(address _dao) public onlyOwner {
        dao_addr = _dao;
        access[_dao] = true;
    }

    function mint(address to, uint256 amount) public returns (bool) {
        require(access[msg.sender], "mint :: deny");

        _mint(to, amount);

        return true;
    }

    function burn(address to, uint256 amount) public returns (bool) {
        require(access[msg.sender], "burn :: deny");

        _burn(to, amount);

        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        IDao(dao_addr).setRelationship(from, to, amount);
    }
}