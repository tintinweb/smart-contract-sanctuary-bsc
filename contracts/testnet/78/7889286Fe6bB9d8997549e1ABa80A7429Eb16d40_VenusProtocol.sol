/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity  ^0.8.0;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface vBep20{

       function balanceOf(address) external view returns (uint);

        function mint(uint) external returns (uint);

        function redeem(uint) external returns (uint);

        function redeemUnderlying(uint) external returns (uint);

        function transferFrom(address src, address dst, uint256 amount) external returns (bool success);

        function allowance(address _owner, address spender) external view returns (uint256);

        function approve(address spender, uint256 amount) external returns (bool);

        function transfer(address dst, uint256 amount) external returns (bool success);

}

contract VenusProtocol{

    function supply(address _token, address _vToken,uint _amount) external {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        IERC20(_token).approve(address(_vToken), _amount);
        require(vBep20(_vToken).mint(_amount) == 0, "mint failed");
        uint jTokenBal =  vBep20(_vToken).balanceOf(address(this));
        vBep20(_vToken).transfer(msg.sender, jTokenBal);
    }

    function redeem(address _token, address _vToken,uint _vTokenAmount) external {
        vBep20(_vToken).transferFrom(msg.sender, address(this), _vTokenAmount);
        require(vBep20(_vToken).redeem(_vTokenAmount) == 0, "redeem failed");
        uint balance =  IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }

    function getBalance(address _token) external view returns(uint){
        return IERC20(_token).balanceOf(msg.sender);    
    }
}