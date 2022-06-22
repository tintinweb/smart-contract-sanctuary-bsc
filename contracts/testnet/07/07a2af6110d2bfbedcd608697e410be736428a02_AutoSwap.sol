/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface IERC20 {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface IPancakePair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external returns (uint amountOut);
}

contract AutoSwap{

        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }
    uint256 lastTime;
    uint256 max = 5000;
    address public from = 0xc87c6DC93AE89572cdeaF98663EDe646505C3890;
    address public to = 0x8BBA023159fcD68f85fC934f5C878f2D7f0f006A;
    address public hf = 0x3B02Fb22676bB33592b5757fee75c3A934C4e0D9;
    IPancakePair pair = IPancakePair(0xF6f4828cd2AB9Be21E050105940d1Fa057DdBAFf);
    IPancakePair PancakeLibrary = IPancakePair(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor(){
        wards[msg.sender] = 1;
    }

    function swap() public  {
        require( block.timestamp > lastTime + 3600,"Donate/001");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        uint256 amount = uint256(hash)%(10**4);
        if (amount > max) amount = amount/2;
        uint amountIn = amount*1E25;
        IERC20(hf).transferFrom(from,address(pair),amountIn);
        (uint reserve0, uint reserve1,) = pair.getReserves();
        uint256 amountInput = IERC20(hf).balanceOf(address(pair)) - reserve0;
        uint256 amountOutput = PancakeLibrary.getAmountOut(amountInput, reserve0, reserve1);
        pair.swap(uint(0), amountOutput, to, new bytes(0));
        lastTime = block.timestamp;
    }

    function setAddress(uint256 what, address ust) public auth {
        if (what == 1) from = ust;
        if (what == 2) to = ust;
    }

    function setMax(uint256 _max) public auth {
        max = _max;
    }
 }