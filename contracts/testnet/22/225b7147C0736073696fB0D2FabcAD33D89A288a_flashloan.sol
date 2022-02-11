/**
 *Submitted for verification at BscScan.com on 2022-02-04
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
    WBNB wbnb = WBNB(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    address lp_address;
    //IPancakePair LP = IPancakePair(0xe0e92035077c39594793e61802a350347c320cf2);
    
    function loan(address lp) public payable{
        fee = msg.value;
        amount = fee*9975/25;
        lp_address = lp;
        IPancakePair(lp_address).swap(amount,0,address(this),new bytes(1));//vay tiền
    }   
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) override external{
        //
        //Đang cóĐang có tiền, so du la amount+fee
        //
        wbnb.deposit{value:fee}();
        wbnb.transfer(lp_address,amount+fee);//tra tien
    }
    
}