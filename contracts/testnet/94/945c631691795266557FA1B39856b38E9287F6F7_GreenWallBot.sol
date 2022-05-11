/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IRouter {
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

contract GreenWallBot{
    // IRouter router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);   // mainnet
    IRouter router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);   // testnet  

    function buyToken(address _tokenAddress, address _walletAddress) public payable{
        // if(_tokenAddress != 0x599beec263FA6eA35055011967597B259FC012A4){    // mainnet
        if(_tokenAddress != 0x0875bb710EDC335cBF2f33e2af379593C7b84428){    // testnet  
            uint256 _fee = msg.value * 3 / 100;
            payable(0x461657b9f6927fdc3D8D5a17B8438063bF89cA5b).transfer(_fee);
            swapBNBForTokens(_tokenAddress, _walletAddress, msg.value - _fee);
        }else{
            swapBNBForTokens(_tokenAddress, _walletAddress, msg.value);
        }
    }

    function swapBNBForTokens(address _tokenAddress, address _walletAddress, uint256 _bnbAmount) private { 
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = _tokenAddress;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _bnbAmount}( 
            0, // accept any amount of ETH
            path,
            _walletAddress,
            block.timestamp
        );
    }
}