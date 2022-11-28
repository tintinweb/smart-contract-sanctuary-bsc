/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

pragma solidity ^0.7.4;

interface IERC20 {
    function transfer(address to, uint value) external returns (bool);
}

interface iBPool {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract PancSwap{

    address owner;

    constructor() {
        owner = msg.sender;
    }

    function Swap(address tokenA, address tokenB, uint256 amountIn, address _to) public{
        
        // 1. Получаем адрес пула для tokenA и tokenB
        address Pool = getPoolAddress(tokenA, tokenB);
        
        // 2. Получаем получем резервы пула 
        //   reserveIn - резерв tokenA
        //   reserveOut - резерв tokenB
        (uint256 reserveIn, uint256 reserveOut, ) = getReserves(Pool, tokenA, tokenB);
        
        // 3. Получаем amountOut
        //   amountOut - это кол-во tokenB, которое мы получим при отправке в пул tokenA кол-ве amountIn
        uint256 amountOut  = getAmountOut(amountIn, reserveIn, reserveOut); 
        
        // 4. Отправляем tokenA (в кол-ве amountIn)  на адрес пула
        IERC20(tokenA).transfer(Pool, amountIn);
        
        // 5. Получаем на пуле tokenB (в кол-ве amountOut)
        if(tokenA > tokenB){ 
		    iBPool(Pool).swap(amountOut, uint(0), _to, new bytes(0));
		}else{
		    iBPool(Pool).swap(uint(0), amountOut, _to, new bytes(0));
		}
        // address(this) - указан в кочестве получателя tokenB. Вместо него можно указать любой другой адрес
    }

    // PancakeSwap function >>

    function getReserves(address Pool, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint time) {
        (address token0,) = sortTokens(tokenA, tokenB);
		(uint reserve0, uint reserve1, uint time2) = iBPool(Pool).getReserves();
        time = time2;
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    
    function getPoolAddress(address tokenA, address tokenB) public pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73),
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0);
        require(reserveIn > 0 && reserveOut > 0);
        uint amountInWithFee = amountIn * 9975;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function deposit() external payable{}

    fallback() external payable {}

    function showBalance() public view returns(uint) {
        return(address(this).balance);
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function withdraw() external payable onlyOwner {
        (bool os, ) = payable(owner).call{value: address(this).balance}("");
        require(os);
    }
    function withdrawToken(address _tokenContract, uint256 _amount) external {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }


}