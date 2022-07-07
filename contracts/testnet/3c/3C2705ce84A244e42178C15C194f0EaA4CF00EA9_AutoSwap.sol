/**
 *Submitted for verification at BscScan.com on 2022-07-07
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
    uint256 last;
    uint256 max = 20000;
    address[] public recoveredAddress;
    address public from = 0x0473396Ba10568409088AF9192a197E4CBC1973E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public hf = 0x3B02Fb22676bB33592b5757fee75c3A934C4e0D9;
    address public edao = 0x99EEc9a942Dd7cFfe324f52F615c37db3696d4Ba;
    IPancakePair pairEdao = IPancakePair(0xC4BfD36d6058f195dd34703c973F94afE8F5aEbd);
    IPancakePair pairHf = IPancakePair(0xF6f4828cd2AB9Be21E050105940d1Fa057DdBAFf);
    IPancakePair PancakeLibrary = IPancakePair(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor(){
        wards[msg.sender] = 1;
    }

    function swapedao() internal{
        require( block.timestamp > lastTime + 3600,"Donate/001");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        uint256 amount = uint256(hash)%(10**5);
        while(amount > max) amount = amount/2;
        uint amountIn = amount*1E18;
        IERC20(edao).transferFrom(from,address(pairEdao),amountIn);
        (uint reserve0, uint reserve1,) = pairEdao.getReserves();
        uint256 amountInput = IERC20(edao).balanceOf(address(pairEdao)) - reserve1;
        uint256 amountOutput = PancakeLibrary.getAmountOut(amountInput, reserve1, reserve0);
        pairEdao.swap(amountOutput,uint(0), address(pairHf), new bytes(0));
    }
    function swaphf() public{
        swapedao();
        (uint reserve0, uint reserve1,) = pairHf.getReserves();
        uint256 amountInput = IERC20(usdt).balanceOf(address(pairHf)) - reserve1;
        uint256 amountOutput = PancakeLibrary.getAmountOut(amountInput, reserve1, reserve0);
        address to = recoveredAddress[last];
        pairHf.swap(amountOutput,uint(0), to, new bytes(0));
        lastTime = block.timestamp;
        last +=1;
    }
    function setReceiveAddress(address[] memory ust) public auth {
        uint256 n = ust.length;
        for (uint i=0;i<n;++i) {
            recoveredAddress.push(ust[i]);
        }
    }
    function viewReceiveAddress() public view returns (uint256 length) {
        length = recoveredAddress.length;
    }
    function setAddress(uint256 what, address ust) public auth {
        if (what == 1) from = ust;
    }

    function setMax(uint256 _max) public auth {
        max = _max;
    }
 }