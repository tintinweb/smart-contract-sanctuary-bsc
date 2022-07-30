//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IPriceOracle {
    function priceOf(address token) external view returns (uint256);
}

/**
    Price Token Created by DeFi Mark
    No Functionality, Just Shows Price As Wallet Balance
 */
contract PriceToken is IERC20 {

    IPriceOracle public constant oracle = IPriceOracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);

    address public immutable token;
    address public immutable staking;

    string private _name;
    string private constant _symbol = 'USD';
    uint8 private immutable tokenDecimals;

    constructor(
        address token_,
        address staking_
    ) {
        token = token_;
        staking = staking_;

        _name = string.concat(IERC20(token_).symbol(), ' Price');
        tokenDecimals = IERC20(token_).decimals();
    }

    function totalSupply() external view override returns (uint256) { 
        return _valueOf(IERC20(token).totalSupply()); 
    }
    function balanceOf(address account) public view override returns (uint256) { 
        return _valueOf(_getBalance(account));
    }
    
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function approve(address, uint256) public override returns (bool) {
        emit Approval(address(0), address(0), 0);
        return true;
    }

    /** Transfer Function */
    function transfer(address, uint256) external override returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return true;
    }

    /** Transfer Function */
    function transferFrom(address, address, uint256) external override returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return true;
    }

    function allowance(address, address) external pure override returns (uint256) { 
        return 0; 
    }

    function _getBalance(address user) internal view returns (uint256) {
        return IERC20(token).balanceOf(user) + IERC20(staking).balanceOf(user);
    }

    function _valueOf(uint256 amount) internal view returns (uint256) {
        uint256 price = oracle.priceOf(token);
        return ( price * amount ) / 10**tokenDecimals;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}