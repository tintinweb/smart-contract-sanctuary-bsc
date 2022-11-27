/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: COMMERCIAL

pragma solidity ^0.8.0;


// 
interface IAuthCenter {
    event UpdateOwner(address indexed _address);
    event AddAdmin(address indexed _address);
    event DiscardAdmin(address indexed _address);
    event FreezeAddress(address indexed _address);
    event UnFreezeAddress(address indexed _address);
    event AddClient(address indexed _address);
    event RemoveClient(address indexed _address);
    event ContractPausedState(bool value);

    function addAdmin(address _address) external returns (bool);
    function discarddAdmin(address _address) external returns (bool);
    function freezeAddress(address _address) external returns (bool);
    function unfreezeAddress(address _address) external returns (bool);
    function addClient(address _address) external returns (bool);
    function removeClient(address _address) external returns (bool);
    function isClient(address _address) external view returns (bool);
    function isAdmin(address _address) external view returns (bool);
    function isUnfrozen(address _address) external view returns (bool);
    function setContractPaused() external returns (bool);
    function setContractUnpaused() external returns (bool);
    function isContractPaused() external view returns (bool);
}

// 
interface ITokenStorage {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function getTokenDecimals() external view returns (uint8);
    function setTokenDecimals(uint8 _decimals) external returns (bool);
    function getTokenName() external view returns (string memory);
    function getTokenSymbol() external view returns (string memory);
    function setTokenInfo(string memory name, string memory symbol) external returns (bool);
    function getTokenTotalSupply() external view returns (uint256);
    function setTokenTotalSupply(uint256 totalSupply) external returns (bool);

    // @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     * Emits a {Transfer} event.
     * Requirements:
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function transfer(address from, address to, uint256 amount) external returns (bool);

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     * Emits a {Transfer} event with `from` set to the zero address.
     * Requirements:
     * - `account` cannot be the zero address.
     */
    function mint(address account, uint256 amount) external returns (bool);

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * Emits a {Transfer} event with `to` set to the zero address.
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 amount) external returns (bool);
}

// 
contract TokenStorage is ITokenStorage {
    address private owner;
    IAuthCenter private authCenter;
    address private contractAddress;

    mapping(address => uint256) private balances;

    uint256 private totalSupply = 0;
    uint8 private decimals = 18;
    string private tokenName = "Autentic Capital Blank";
    string private tokenSymbol = "AUT-0";

    constructor() { owner = msg.sender; }

    function updateOwner(address _address) external returns (bool) {
        require(msg.sender == owner, "TokenStorage: You are not contract owner");
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(_address), "TokenStorage: new contract owner is not our admin");
        owner = _address;
        return true;
    }

    // @dev Link AuthCenter to contract
    function setAuthCenter(address _address) external returns (bool) {
        require(msg.sender == owner, "TokenStorage: You are not contract owner");
        require(_address != address(0), "TokenStorage: AuthCenter is the zero address");
        authCenter = IAuthCenter(_address);
        return true;
    }

    // @dev set trusted contract address
    function setContractAddress(address _address) external returns (bool) {
        require(msg.sender == owner, "TokenStorage: You are not contract owner");
        require(_address != address(0), "TokenStorage: trusted contract is the zero address");
        contractAddress = _address;
        return true;
    }

    function getTokenDecimals() external view override returns (uint8) {
        return decimals;
    }

    function setTokenDecimals(uint8 _decimals) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(msg.sender), "TokenStorage: You are not admin");
        decimals = _decimals;
        return true;
    }

    function getTokenName() external view override returns (string memory) {
        return tokenName;
    }

    function getTokenSymbol() external view override returns (string memory) {
        return tokenSymbol;
    }

    function getTokenTotalSupply() external view override returns (uint256) {
        return totalSupply;
    }

    // TODO Удалить опасный метод!
    function setTokenTotalSupply(uint256 _totalSupply) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(msg.sender), "TokenStorage: You are not admin");
        totalSupply = _totalSupply;
        return true;
    }

    function setTokenInfo(string memory name, string memory symbol) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(msg.sender), "TokenStorage: You are not admin");
        tokenName = name;
        tokenSymbol = symbol;
        return true;
    }

    function balanceOf(address account) external view override returns (uint256) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isClient(msg.sender) || authCenter.isAdmin(msg.sender),
                "TokenStorage: Access denied");
        return balances[account];
    }

    function transfer(address from, address to, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(!authCenter.isContractPaused() || authCenter.isAdmin(msg.sender),
                "TokenStorage: contract paused");
        require(contractAddress != address(0) || authCenter.isAdmin(msg.sender),
                "TokenStorage: trusted contract is the zero address");
        require(contractAddress == msg.sender || authCenter.isAdmin(msg.sender),
                "TokenStorage: wrong trusted contract");
        require(authCenter.isClient(from),  "TokenStorage: 'from' not our client");
        require(authCenter.isClient(to),  "TokenStorage: 'to' not our client");
        require((authCenter.isUnfrozen(from) && authCenter.isUnfrozen(to)) ||
                authCenter.isAdmin(msg.sender), "TokenStorage: sorry, accounts was frozen");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "TokenStorage: transfer amount exceeds balance");
        balances[from] = fromBalance - amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
        return true;
    }

    function mint(address account, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(msg.sender), "TokenStorage: You are not admin");
        require(account != address(0), "TokenStorage: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
        return true;
    }

    function burn(address account, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "TokenStorage: AuthCenter is the zero address");
        require(authCenter.isAdmin(msg.sender), "TokenStorage: You are not admin");
        require(account != address(0), "TokenStorage: burn from the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "TokenStorage: burn amount exceeds balance");
        balances[account] = accountBalance - amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(address(0), account, amount);
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal {}

    //some gas ethers need for a normal work of this contract.
    //Only owner can put ethers to contract.
    receive() external payable {
        require(msg.sender == owner, "TokenStorage: You are not contract owner");
    }

    //Only owner can return to himself gas ethers before closing contract
    function withDrawAll() external {
        require(msg.sender == owner, "TokenStorage: You are not contract owner");
        payable(owner).transfer(address(this).balance);
    }
}