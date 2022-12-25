/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


interface IPair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


contract ME{
    address public adm = 0x601E5dc33Cb656B1A934eBFF3D13A23a331b0afC;
    address public bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    bytes dat = new bytes(0);

    function xiugaiadmin(address A)public{
        require(msg.sender == adm);
        adm  = A;
    }
    function tifee(address token, uint value)public{
        require(msg.sender == adm);
        IERC20(token).transfer(adm, value);
    }

    function MYswap(address[] memory pair,address[] memory tokens,uint[] memory values) external {
        uint b0;
        uint b1;
        b0 = IERC20(bnb).balanceOf(address(this));
        for(uint i=0;i<pair.length; i++){
            IERC20(tokens[i]).transfer(pair[i], values[i]);
            if (tokens[i] == IPair(pair[i]).token0()){
                IPair(pair[i]).swap(0, values[i+1],address(this),dat);
            }else{
                IPair(pair[i]).swap(values[i+1], 0,address(this),dat);
            }
        }
        b1 = IERC20(bnb).balanceOf(address(this));
        require(b1 > b0,'xiaoyu');
    }
}