//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../PancakeSwapRouter.sol";
import "../PancakeSwapFactory.sol";
import "../IERC20.sol";

contract Born2Retail {
    PancakeSwapRouter public router;
    IERC20 public token;
    PancakeSwapFactory factory;
    address payable public Owner;
    address private USDT_ADDRESS = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address private ROUTER_PANCAKESWAP = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    event Withdraw(uint256 _amount);
    event WithdrawToken(uint256 _amount);
    event Buy(address _to, uint256 _amount);

    constructor() { 
        Owner = payable(msg.sender);
        router = PancakeSwapRouter(ROUTER_PANCAKESWAP);
        token = IERC20(USDT_ADDRESS);
        factory = PancakeSwapFactory(router.factory());
    }

    function deposit() public payable onlyOwner {}

    modifier onlyOwner() {
        require(msg.sender == Owner, 'Not owner'); 
        _;
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    function withdraw(uint256 _amount) external onlyOwner { 
        Owner.transfer(_amount);
        emit Withdraw(_amount);
    }

    function balanceToken() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function withdrawToken(uint256 _amount) external onlyOwner returns(bool){
        token.transfer(Owner, _amount);
        emit WithdrawToken(_amount);

        return true;
    }

    function approve() public onlyOwner{
       address pair = factory.getPair(router.WETH(), USDT_ADDRESS);
       
       token.approve(pair, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
       token.approve(ROUTER_PANCAKESWAP, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function buy(address _to, uint256 _amount) public onlyOwner{
        uint deadline = block.timestamp + 1200;

        address[] memory path = new address[](2);
        path[0] = USDT_ADDRESS;
        path[1] = router.WETH();

        router.swapExactTokensForETH(_amount, 0, path, _to, deadline);

        emit Buy(_to, _amount);
    }
}