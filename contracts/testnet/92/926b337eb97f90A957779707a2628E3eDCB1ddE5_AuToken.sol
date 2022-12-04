/**
 *Submitted for verification at BscScan.com on 2022-12-03
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
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // @dev Returns the name of the token.
    function name() external view returns (string memory);

    // @dev Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view returns (uint8);

    // @dev Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    // @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address _account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * Requirements:
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the allowance mechanism.
     `amount` is then deducted from the caller's allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * Emits an {Approval} event indicating the updated allowance. This is not
     *   required by the EIP. See the note at the beginning of {ERC20}.
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     * Requirements:
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // @dev check contract paused
    function isPaused() external view returns (bool);
}

// 
contract AuToken is IERC20 {
    address private owner;
    IAuthCenter private authCenter;

    ITokenStorage private tokenStorage;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor() { owner = msg.sender; }

    function updateAdmin(address _address) external returns (bool) {
        require(msg.sender == owner, "ERC20: You are not contract owner");
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(authCenter.isAdmin(_address), "ERC20: new contract owner is not our admin");
        owner = _address;
        return true;
    }

    // @dev Link TokenStorage to contract
    function setTokenStorage(address _address) external returns (bool) {
        require(msg.sender == owner, "ERC20: You are not contract owner");
        require(_address != address(0), "ERC20: tokenStorage is the zero address");
        tokenStorage = ITokenStorage(_address);
        return true;
    }

    // @dev Link AuthCenter to contract
    function setAuthCenter(address _address) external returns (bool) {
        require(msg.sender == owner, "ERC20: You are not contract owner");
        require(_address != address(0), "ERC20: authCenter is the zero address");
        authCenter = IAuthCenter(_address);
        return true;
    }

    // @dev set tokens name and symbol
    function setTokenInfo(string memory tokenName, string memory tokenSymbol) external returns (bool) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        tokenStorage.setTokenInfo(tokenName, tokenSymbol);
        return true;
    }

    // @dev Returns the name of the token.
    function name() external view override returns (string memory) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        return tokenStorage.getTokenName();
    }

    // @dev Returns the symbol of the token, usually a shorter version of the name.
    function symbol() external view override returns (string memory) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        return tokenStorage.getTokenSymbol();
    }

    // @dev Returns the number of decimals used to get its user representation.
    function decimals() external view override returns (uint8) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        return tokenStorage.getTokenDecimals();
    }

    // @dev Returns the amount of tokens in existence.
    function totalSupply() external view override returns (uint256) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        return tokenStorage.getTokenTotalSupply();
    }

    // @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view override returns (uint256) {
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        return tokenStorage.balanceOf(account);
    }

    // @dev Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        require(!authCenter.isContractPaused(),  "ERC20: contract paused");
        require(authCenter.isClient(to) && authCenter.isClient(msg.sender), "ERC20: not our clients");
        if (tokenStorage.transfer(msg.sender, to, amount)) {
            emit Transfer(msg.sender, to, amount);
            return true;
        }
        return false;
    }

    // Mint
    function mint(address account, uint256 amount) external returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        require(!authCenter.isContractPaused(),  "ERC20: contract paused");
        if (tokenStorage.mint(account, amount)) {
            emit Transfer(address(0), account, amount);
            return true;
        }
        return false;
    }

    // Burn
    function burn(address account, uint256 amount) external returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        require(!authCenter.isContractPaused(),  "ERC20: contract paused");
        if (tokenStorage.burn(account, amount)) {
            emit Transfer(account, address(0), amount);
            return true;
        }
        return false;
    }

    // @dev Returns the remaining number of tokens that `spender` will be
    // allowed to spend on behalf of `owner` through {transferFrom}.
    function allowance(address daddy, address spender) external view override returns (uint256) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(!authCenter.isContractPaused(),  "ERC20: contract paused");
        require(authCenter.isClient(daddy) && authCenter.isClient(spender), "ERC20: not our clients");
        return allowances[daddy][spender];
    }

    // @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(!authCenter.isContractPaused(),  "ERC20: contract paused");
        require(authCenter.isClient(msg.sender) && authCenter.isClient(spender),
                "ERC20: not our clients");
        _approve(msg.sender, spender, amount);
        return true;
    }

    // @dev Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        require(!authCenter.isContractPaused(), "ERC20: contract paused");
        require(address(tokenStorage) != address(0), "ERC20: tokenStorage is the zero address");
        require(authCenter.isClient(from) &&
                authCenter.isClient(to) &&
                authCenter.isClient(msg.sender),
                "ERC20: not our clients");
        if (!authCenter.isAdmin(msg.sender)) {
            _spendAllowance(from, msg.sender, amount);
        }
        tokenStorage.transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    // @dev check contract paused
    function isPaused() external view override returns (bool) {
        require(address(authCenter) != address(0), "ERC20: AuthCenter is the zero address");
        return authCenter.isContractPaused();
    }

    //----------------------------------------------------
    // internal functions
    //----------------------------------------------------
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     * Emits an {Approval} event.
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address daddy, address spender, uint256 amount) internal {
        require(daddy != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowances[daddy][spender] = amount;
        emit Approval(daddy, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address daddy, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowances[daddy][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(daddy, spender, currentAllowance - amount);
        }
    }

    //some gas ethers need for a normal work of this contract.
    //Only owner can put ethers to contract.
    receive() external payable {
        require(msg.sender == owner, "ERC20: You are not contract owner");
    }

    //Only owner can return to himself gas ethers before closing contract
    function withDrawAll() external {
        require(msg.sender == owner, "ERC20: You are not contract owner");
        payable(owner).transfer(address(this).balance);
    }
}