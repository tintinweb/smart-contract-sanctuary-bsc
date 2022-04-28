// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./IBEP20.sol";
import "./Ownable.sol";

contract Staking is Ownable {
    mapping(address => mapping(address => uint256)) _balances;
    mapping(address => uint256) _balancesOfBud;

    function deposit(address tokenAddress, uint256 amount) external payable {
        if(tokenAddress == address(0)) {
            require(msg.value > 0, "Staking: BNB value is zero");
            _balances[msg.sender][address(0)] += msg.value;
        } else {
            require(IBEP20(tokenAddress).allowance(msg.sender, address(this)) >= amount, "Staking: BEP20 token deposit is not approved");
            require(IBEP20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Staking: failed to deposit BEP20 token");
            _balances[msg.sender][tokenAddress] += amount;
        }
    }

    function withdraw(address tokenAddress, address to, uint256 amount) external onlyOwner {
        if(tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Staking: insufficient BNB for withdraw");
            payable(to).transfer(amount);
            // _balances[to][address(0)] -= amount;
        } else {
            require(IBEP20(tokenAddress).transfer(to, amount), "Staking: failed to withdraw BEP20 token");
            // _balances[to][tokenAddress] -= amount;
        }
    }

    function balanceOfStaking(address tokenAddress, address account) external view returns (uint256) {
        return _balances[account][tokenAddress];
    }

    function addBuds(address account, uint256 amount) external onlyOwner {
        _balancesOfBud[account] += amount;
    }

    function subtractBuds(address account, uint256 amount) external onlyOwner {
        _balancesOfBud[account] -= amount;
    }

    function balanceOfBuds(address account) external view returns (uint256) {
        return _balancesOfBud[account];
    }
}