/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-25
*/

pragma solidity = 0.8.6;

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
interface IPancakePair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
interface WBNB{
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
}
contract flashloan is IPancakeCallee{
    uint256 fee=0;
    uint256 amount=0;
    WBNB wbnb = WBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IPancakePair LP = IPancakePair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
    
    function loan() public payable{
        fee = msg.value;
        amount = fee*9975/25;
        LP.swap(amount,0,address(this),new bytes(1));//vay tiền
    }   
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) override external{
        //
        wbnb.deposit{value:fee}();
        wbnb.transfer(address(0xAc998B86FC603F5563Ab5561fB36b6125f437E2f),amount+fee);//tra tien
        //
        wbnb.deposit{value:fee}();
        wbnb.transfer(address(LP),amount+fee);//tra tien
    }
    
}