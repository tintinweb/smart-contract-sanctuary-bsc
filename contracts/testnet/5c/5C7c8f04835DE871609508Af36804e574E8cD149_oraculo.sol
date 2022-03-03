/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract oraculo {

    IERC20 private iBase;
    IERC20 private iToken;

    address baseToken;
    address token;
    address payable par;
   
    constructor(address _baseToken, address _token, address payable _par){
        baseToken = _baseToken;
        token = _token;
        par = _par;

        iBase = IERC20(_baseToken);
        iToken = IERC20(_token);
    }

    function get_price() public view returns(uint256) {
        return ((iBase.balanceOf(par) / iToken.balanceOf(par)) * 1e9);
    }
    
    function get_address() public view returns(address _base, address _token, address _par) {
        return(baseToken, token, par);
    }

    function set_address(address _baseToken, address _token, address payable _par) external {
        baseToken = _baseToken;
        token = _token;
        par = _par;
    }
}

interface IERC20 {
   
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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}