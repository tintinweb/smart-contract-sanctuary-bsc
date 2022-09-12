/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0; //versao


library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }


    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }


    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}



interface IPancakePair {
    event Transfer(address indexed from, address indexed to, uint256 value);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

library PancakeLibrary {
    using SafeMath for uint256;


    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "Library Sort: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Library Sort: ZERO_ADDRESS");
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = PancakeLibrary.sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            )))));
    }



    // fetches and sorts the reserves for a pair

    function getReserves(
        address pairAddress,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pairAddress)
            .getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
     uint amountIn,
     uint reserveIn,
     uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(
            reserveIn > 0 && reserveOut > 0, 
            'PancakeLibrary: INSUFFICIENT_LIQUIDITY'
        );
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }


    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint amountIn,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
            require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
            amounts = new uint[](path.length);
            amounts[0] = amountIn;
            for (uint i; i < path.length - 1; i++) {
                (uint reserveIn, uint reserveOut) = getReserves(
                    factory,
                    path[i],
                    path[i + 1]
                );
                amounts[i + 1] = getAmountOut(
                    amounts[i],
                    reserveIn,
                    reserveOut);
            }
        }
}


contract DrimBotContract {
    address private owner;

    
    address private constant router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant factory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17; 
    address private constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    //address busd testnet = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7


    modifier onlyOwner() {
        require(msg.sender == owner, "DrimBot: not authorised: ");
        _;
    }


    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "DrimBot: EXPIRED");
        _;
    }


    constructor() {
        owner = msg.sender;
    }



    function _swap(
       uint[] memory amounts,
       address[] memory path,
       address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PancakeLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 
                ? (uint(0), amountOut) 
                : (amountOut, uint(0));
            address to = i < path.length - 2 ? PancakeLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IPancakePair(PancakeLibrary.pairFor(factory, input, output)).swap(
                amount0Out, 
                amount1Out, 
                to, 
                new bytes(0)
            );
        }
    }



    function vSwap(

        uint256 amountIn,
        uint256 amountOutMin,
        //address[] calldata path,
        address token0,
        address token1,
        address to,
        uint256 deadline
    ) external payable virtual ensure(deadline) onlyOwner returns (bool success) {
        address[] memory path;
        path[0] = token0;
        path[1] = token1;

        uint256[] memory amounts = PancakeLibrary.getAmountsOut(
            factory,
            amountIn,
            path
        );
        success = true;
        require(amounts[amounts.length - 1] >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    

    
    //retorna o par do token -------------------FUNCIONANDO
    function testePar(address _token0, address _token1) external pure returns (address){
        return PancakeLibrary.pairFor(factory, _token0, _token1);
    }
    
    




     function deposit() external payable returns(bool){ //deposita no contrato
        return true;
    }

    function balance() external view returns(uint256){ //mostra o saldo do contrato
        return address(this).balance;
    }

    function withdrawSend(uint256 _amount) external returns(bool) { //sacando do contrato
        //send retorna dentro de condicoes
        if (payable(msg.sender).send(_amount)){
            return true;
        } else{
            return false;
        }
    }

    function withdrawTransfer(uint256 _amount, address payable _endereco) external{ //sacando do contrato 
        //transfer retorna somente bool
        _endereco.transfer(_amount);
    }
}