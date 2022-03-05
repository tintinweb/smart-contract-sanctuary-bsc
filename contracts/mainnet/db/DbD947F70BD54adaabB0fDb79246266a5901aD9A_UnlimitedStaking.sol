// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./Uniswap.sol";

contract UnlimitedStaking is Ownable {
    using SafeERC20 for IERC20;

    uint256 private constant FLOAT_SCALAR = 2**64;

    // 0.1% burn on deposit, i.e., 10/10000
    uint256 public constant BURN_PERCENTAGE = 10;

    uint256 public pendingDivs;
    address public uniswapRouter;

    struct User {
        uint256 balance;
        int256 scaledPayout;
    }

    IERC20 public token;
    IERC20 public WBNB;
    uint256 public divPerShare;

    mapping(address => User) public users;

    event OnDeposit(address indexed from, uint256 amount);
    event OnWithdraw(address indexed from, uint256 amount);
    event OnClaim(address indexed from, uint256 amount);
    event OnTransfer(address indexed from, address indexed to, uint256 amount);
    
    constructor(address _uniswapRouter, address _wbnb) public {
        require(_uniswapRouter != address(0) && _wbnb != address(0), "ZERO_ADDRESS");
        WBNB = IERC20(_wbnb);
        uniswapRouter = _uniswapRouter;
    }

    function setToken(address _token) external onlyOwner {
        require(address(token) == address(0));
        token = IERC20(_token);
    }
 
    function totalSupply() private view returns (uint256) {
        return token.balanceOf(address(this));
    }

    //@dev deposit dust token upon deployment to prevent division by zero 
    function distribute(uint256 _amount) external returns(bool) {
        WBNB.safeTransferFrom(address(msg.sender), address(this), _amount);
        pendingDivs = pendingDivs + _amount; //lazy divs distribution for gas savings on trades
        return true;
    }

    function updatePendingDivs() public {
        if(pendingDivs > 0) {
            divPerShare = divPerShare + (pendingDivs * FLOAT_SCALAR / totalSupply());
            pendingDivs = 0;
        }
    }

    function burn(uint256 _amount) internal returns (uint256) {
        uint256 burnAmount = _amount * BURN_PERCENTAGE / 10000;
        uint256 remainder = _amount - burnAmount;
        token.safeTransfer(address(0x000000000000000000000000000000000000dEaD), burnAmount);
        return remainder;
    }

    function deposit(uint256 _amount) external {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 remainder = burn(_amount);
        depositFrom(remainder);
    }
    
    function depositFrom(uint256 _amount) private {
        updatePendingDivs();
        users[msg.sender].balance = users[msg.sender].balance + _amount;
        users[msg.sender].scaledPayout = users[msg.sender].scaledPayout + 
            int256(_amount * divPerShare);
        emit OnDeposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        updatePendingDivs();
        require(balanceOf(msg.sender) >= _amount);
        users[msg.sender].balance = users[msg.sender].balance - _amount;
        users[msg.sender].scaledPayout = users[msg.sender].scaledPayout - 
            int256(_amount * divPerShare);
        token.safeTransfer(msg.sender, _amount);
        emit OnWithdraw(msg.sender, _amount);
    }

    function claim() external {
        updatePendingDivs();
        uint256 _dividends = dividendsOf(msg.sender);
        require(_dividends > 0);
        users[msg.sender].scaledPayout = users[msg.sender].scaledPayout +
            int256(_dividends * FLOAT_SCALAR);
        WBNB.safeTransfer(address(msg.sender), _dividends);
        emit OnClaim(msg.sender, _dividends);
    }

    function reinvestWithMinimalAmountOut(uint256 delay, uint256 minimalAmountOut) public {
        updatePendingDivs();
        uint256 dividends = dividendsOf(msg.sender);
        require(dividends > 0);
        users[msg.sender].scaledPayout = users[msg.sender].scaledPayout + 
            int256(dividends * FLOAT_SCALAR);
        WBNB.approve(address(uniswapRouter), dividends);

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(token);

        IUniswapV2Router02(uniswapRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                dividends,
                minimalAmountOut,
                path,
                address(this),
                block.timestamp + delay
            );
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        uint convertedTokens = balanceAfter - balanceBefore;
        require(convertedTokens > 0, "ZERO_CONVERT");
        uint256 remainder = burn(convertedTokens);
        depositFrom(remainder);
    }

    function reinvest(uint256 delay) external {
        reinvestWithMinimalAmountOut(delay, 0);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        return _transfer(msg.sender, _to, _amount);
    }

    function balanceOf(address _user) public view returns (uint256) {
        return users[_user].balance;
    }

    function dividendsOf(address _user) public view returns (uint256) {
        return
            uint256(
                int256(divPerShare * balanceOf(_user)) -
                    users[_user].scaledPayout
            )
                / FLOAT_SCALAR;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        require(users[_from].balance >= _amount);
        users[_from].balance = users[_from].balance - _amount;
        users[_from].scaledPayout = users[_from].scaledPayout - 
            int256(_amount * divPerShare);
        users[_to].balance = users[_to].balance + _amount;
        users[_to].scaledPayout = users[_to].scaledPayout +
            int256(_amount * divPerShare);
        emit OnTransfer(msg.sender, _to, _amount);
        return true;
    }
}