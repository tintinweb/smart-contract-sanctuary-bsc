// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Snapshot.sol";
import "./AccessControl.sol";
import "./Pausable.sol";
import "./draft-ERC20Permit.sol";


contract TatalPaymentNetworkToken is ERC20, ERC20Burnable, ERC20Snapshot, AccessControl, Pausable, ERC20Permit {
    
    address public constant MARKETING = 0x5F5d0045e09BB66B298773d83d76471158CEFDaC;
    address public constant RESEARCH_AND_DEVELOPMENT = 0x4678AeCE9e75a663Ca7f4f46B97ED3a8e8630964;

    uint public marketing_fee = 3;
    uint public research_and_development_fee = 2;
    

    uint public constant MAX_SUPPLY = 10000000000000;
   
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => bool) isRestricted;
    address[] restricted;

    modifier supplyChecker(uint256 amount) {
        require((totalSupply() + amount) <= MAX_SUPPLY, "AMOUNT NOT MATCH WITH MAX_SUPPLY");
        _;
    } 

    constructor() ERC20("TatalPaymentNetworkToken", "TNT") ERC20Permit("TatalPaymentNetworkToken"){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SNAPSHOT_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function decimals() public view virtual override returns (uint8) {
        return 4;
    }

    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setMarketingFee(uint _fee) public onlyRole(MINTER_ROLE) {
        marketing_fee = _fee;
    }

    function setResearchAndDevelopmentFee(uint _fee) public onlyRole(MINTER_ROLE) {
        research_and_development_fee = _fee;
    }

    function addRestricted(address account) public onlyRole(MINTER_ROLE) {
        require(isRestricted[account] != true, "ACCOUNT IS RESTRICTED");
        isRestricted[account] = true; 
        restricted.push(account);
    }

    function removeRestricted(uint _index) public onlyRole(MINTER_ROLE) {
        require(_index < restricted.length, "index out of bound");
        isRestricted[restricted[_index]] = false; 
        for (uint i = _index; i < restricted.length - 1; i++) {
            restricted[i] = restricted[i + 1];
        }
        restricted.pop();
    }

    function getRestricted() public view returns (address[] memory) {
        return restricted;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) supplyChecker(amount){
        _mint(to, amount);
    }

    function ownerTransfer(address to, uint256 amount) public onlyRole(MINTER_ROLE) virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        uint256 finalAmount = amount - ((amount * (marketing_fee + research_and_development_fee)) / 100);

        _transfer(owner, MARKETING, ((amount * marketing_fee) / 100));
        _transfer(owner, RESEARCH_AND_DEVELOPMENT, ((amount * research_and_development_fee) / 100));
        _transfer(owner, to, finalAmount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        uint256 finalAmount = amount - ((amount * (marketing_fee + research_and_development_fee)) / 100);

        _spendAllowance(from, spender, amount);
        _transfer(from, MARKETING, ((amount * marketing_fee) / 100));
        _transfer(from, RESEARCH_AND_DEVELOPMENT, ((amount * research_and_development_fee) / 100));
        _transfer(from, to, finalAmount);
        return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
        require(isRestricted[from] != true, "ACCOUNT IS Restricted");
    }
}