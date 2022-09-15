pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./draft-ERC20Permit.sol";
import "./ERC20Votes.sol";
import "./Ownable.sol";
import "./AccessControl.sol";
contract MegaToken is ERC20, Ownable, ERC20Permit, AccessControl, ERC20Votes {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    event minterRole(bytes32);

    constructor () ERC20("MegaToken", "HPW") ERC20Permit("MegaToken"){
        emit minterRole(MINTER_ROLE);
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    function mint (address to , uint256 amount) public  onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    function burn (address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    function _mint(address to, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

}