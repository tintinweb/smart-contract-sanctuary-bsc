// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";

contract MetaOneToken is Ownable, ERC20 {

    using SafeMath for uint256;

    uint256 constant E18 = 10**18;
    uint256 public constant MAX_TOTAL_TOKEN_SUPPLY = 1000000000*E18;

    mapping(address => bool) private _minters;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    modifier onlyMinter() {
        require(isMinter(msg.sender), "Only minter can call");
        _;
    }

    constructor() ERC20("MetaOne", "MT1") {
        // The owner is the default minter
        _addMinter(msg.sender);
    }

    /**
     * @dev Add a new minter.
     * @param _account Address of the minter
     */
    function addMinter(address _account) public onlyOwner {
        _addMinter(_account);
    }

    /**
     * @dev Remove a minter.
     * @param _account Address of the minter
     */
    function removeMinter(address _account) public onlyOwner {
        _removeMinter(_account);
    }

    /**
     * @dev Renounce to be a minter.
     */
    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _beforeTokenTransfer (
        address from,
        address to,
        uint256 amount
    )internal virtual override{
        super._beforeTokenTransfer(from, to, amount);
        require(to != address(this));
    }

    /**
     * @dev Mint new tokens.
     * @param _to Address to send the newly minted tokens
     * @param _amount Amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) public onlyMinter {
        require(totalSupply().add(_amount) <= MAX_TOTAL_TOKEN_SUPPLY, "Exceed max total supply");
        _mint(_to, _amount);
    }

    /**
     * @dev Destroys tokens.
     * @param _value Amount of tokens to burn
     */
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    /**
     * @dev Return if the `_account` is a minter or not.
     * @param _account Address to check
     * @return True if the `_account` is minter
     */
    function isMinter(address _account) public view returns (bool) {
        return _minters[_account];
    }

    /**
     * @dev Add a new minter.
     * @param _account Address of the minter
     */
    function _addMinter(address _account) private {
        _minters[_account] = true;
        emit MinterAdded(_account);
    }

    /**
     * @dev Remove a minter.
     * @param _account Address of the minter
     */
    function _removeMinter(address _account) private {
        _minters[_account] = false;
        emit MinterRemoved(_account);
    }
}