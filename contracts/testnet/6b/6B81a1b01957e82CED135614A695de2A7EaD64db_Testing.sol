/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity >=0.6.0;


contract Testing {
    // ORG 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address public immutable WETH = 0x1b82A0e0Dd7dacFdFFeBa28942809F3C5C5E2E6d;

    function userBalance() public view returns (uint256) {
       return IERC20(WETH).balanceOf(address(this));
    }
    function getAddress() public view returns (address) {
       return address(this);
    }

    function withdrawTest() external virtual {
       // IWETH(WETH).withdrawTEST{gas:2500000}(amount);
       IWETH weth = IWETH(WETH);
       weth.withdrawTEST(50000000000);
    }

    function depositMoney() payable external {

       IWETH(WETH).deposit{value: msg.value / 2}();
       

      // assert(IWETH(WETH).transfer(address(this), IERC20(WETH).balanceOf(address(this)) ));
    }

}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function withdrawTEST(uint wad) external;
    function sendOwner() external returns(address);
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