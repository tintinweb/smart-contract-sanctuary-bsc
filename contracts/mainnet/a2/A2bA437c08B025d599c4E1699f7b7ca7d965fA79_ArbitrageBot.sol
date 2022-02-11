/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 < 0.9.0;


contract ArbitrageBot {

    address public owner;
    address public managedToken;
    mapping(address => uint) public pairFee;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor(address _owner, address _managedToken, address _pair1, uint _fee1, address _pair2, uint _fee2) {
        owner = _owner;
        managedToken = _managedToken;
        pairFee[_pair1] = _fee1;
        pairFee[_pair2] = _fee2;
    }

    function changeOwner(address newOwner) public isOwner {
        owner = newOwner;
    }

    function setManagedToken(address _managedToken) public isOwner {
        managedToken = _managedToken;
    }

    function setFee(address _pair, uint _fee) public isOwner {
        pairFee[_pair] = _fee;
    }

    function arbitrate(address[] memory pairPath, uint amountIn) public {
        address token0 = Pair(pairPath[0]).token0();
        address token1 = Pair(pairPath[0]).token1();
        bool kodaIsFirst = (token0 == managedToken);

        (uint reserve1_0, uint reserve1_1, ) = Pair(pairPath[0]).getReserves();
        (uint reserve2_0, uint reserve2_1, ) = Pair(pairPath[1]).getReserves();

        address pair1 = pairPath[0];
        address pair2 = pairPath[1];
        uint amountOut1 = getOutputAmount(amountIn, kodaIsFirst ? reserve1_0 : reserve1_1, !kodaIsFirst ? reserve1_0 : reserve1_1, pairFee[pair1]);
        uint amountOut2 = getOutputAmount(amountOut1, !kodaIsFirst ? reserve2_0 : reserve2_1, kodaIsFirst ? reserve2_0 : reserve2_1, pairFee[pair2]);
        require(amountOut2 > amountIn, "!Profit");

        Token(managedToken).transfer(pairPath[0], amountIn);
        Pair(pairPath[0]).swap(!kodaIsFirst ? amountOut1 : 0, kodaIsFirst ? amountOut1 : 0, address(this), new bytes(0));
        
        Token(kodaIsFirst ? token1 : token0).transfer(pairPath[1] ,amountOut1);
        Pair(pairPath[1]).swap(kodaIsFirst ? amountOut2 : 0, !kodaIsFirst ? amountOut2 : 0, address(this), new bytes(0));
    }


    function withdrawKoda(uint _amount) public isOwner{
        require(_amount <= Token(managedToken).balanceOf(address(this)), "amount exceeds balance");
        Token(managedToken).transfer(owner,_amount);
    }

    function getOutputAmount(uint fIn, uint inPoolReserves, uint targetReserves, uint feeMultipliedBy100) public pure returns (uint){
        uint amountInWithFee = fIn*(1000 - feeMultipliedBy100);
        uint numerator = amountInWithFee * targetReserves;
        uint denominator = (inPoolReserves * 1000) + (amountInWithFee);
        return numerator / denominator;
    }

    function kodaBalance() public view returns(uint){
        return Token(managedToken).balanceOf(address(this));
    }


    function arbitrateTest(address[] memory pairPath, uint amountIn) public view returns(uint amountOut1, uint amountOut2, uint profit){
        address token0 = Pair(pairPath[0]).token0();
        bool kodaIsFirst = (token0 == managedToken);

        (uint reserve1_0, uint reserve1_1, ) = Pair(pairPath[0]).getReserves();
        (uint reserve2_0, uint reserve2_1, ) = Pair(pairPath[1]).getReserves();
        address pair1 = pairPath[0];
        address pair2 = pairPath[1];
        amountOut1 = getOutputAmount(amountIn, kodaIsFirst ? reserve1_0 : reserve1_1, !kodaIsFirst ? reserve1_0 : reserve1_1, pairFee[pair1]);
        amountOut2 = getOutputAmount(amountOut1, !kodaIsFirst ? reserve2_0 : reserve2_1, kodaIsFirst ? reserve2_0 : reserve2_1, pairFee[pair2]);

         profit = amountOut2 - amountIn;

    }
}

interface Pair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external view returns(address);
    function token1() external view returns(address);
}

interface Token {
    function transfer(address recipient, uint amount) external;
    function balanceOf(address account) external view returns(uint);
}