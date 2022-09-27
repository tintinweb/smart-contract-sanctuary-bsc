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
        require(
            token_ != address(0) &&
            staking_ != address(0),
            'Zero Check'
        );
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