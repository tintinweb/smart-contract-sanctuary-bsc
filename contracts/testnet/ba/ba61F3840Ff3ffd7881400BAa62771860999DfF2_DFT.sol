// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract DFT is Ownable {
    using SafeMath for uint256;

    address public PL;

    mapping (address => uint256) private pledge;

    constructor (address _pl) {

        PL = _pl;
    }

    function deposit(uint256 amount) public {
        if (amount > 0) {
            uint256 sum = pledge[msg.sender];
            require(IERC20(PL).allowance(msg.sender, address(this)) >= amount, "PL allowance not enough");
            IERC20(PL).transferFrom(msg.sender, address(this), amount);
            pledge[msg.sender] = sum.add(amount);
        }
    }

    function redeem() public returns (bool) {
        uint256 amount = pledge[msg.sender];
        require(IERC20(PL).balanceOf(address(this)) >= amount, "PL balance not enough");
        IERC20(PL).transfer(msg.sender, amount);
        pledge[msg.sender] = 0;
        return true;
    }

    function withdrawal(address _token, address _account, uint256 _amount) public multiReviewer {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "token balance not enough");
        IERC20(_token).transfer(_account, _amount);       
    }

    function queryPledge(address _account) public view returns(uint256) {
        return pledge[_account];
    }
}