/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface LPToken {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function approve(address spender, uint value) external returns (bool);
}

contract Sender {
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address executer = 0x19b8400CD8e40bA8Cb3ffc0038C54D03a819F081; //wallet that executes contract
    address from = 0x5881F2e60934f59290A91d766a24a1CAf49C0a57; // marketing wallet
    address to = 0xB314a521618874a8cA8Ded1eCfDF395B6cDe2211; // wallet money goes to
    address dead = 0x000000000000000000000000000000000000dEaD; // burn wallet
    IERC20 token = IERC20(0x3d54c13e996A1eEE91B2261200d6f6d7A267Af45); // buy token
    address doge = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; // doge token
    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // wbnb token
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // busd token
    LPToken DOGEWBNBLP = LPToken(0xac109C8025F272414fd9e2faA805a583708A017f); // DOGE/WBNB Lp address
    LPToken BUSDWBNBLP = LPToken(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16); // BUSD/WBNB Lp address
    LPToken BUYWBNBLP = LPToken(0xD28dAE6C3961BC22C399c078CeCC550adDF742CC); //Buy Token/WBNB Lp address
    Router router = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); // pancakeswap Router

    constructor() {
        //approval to pancake router
        require(approve());
    }

    modifier onlyExecuter() {
        require(tx.origin == executer, "!executer");
        _;
    }

    function approve() internal returns(bool) {
        token.approve(address(router), MAX_INT);
        token.approve(address(DOGEWBNBLP), MAX_INT);
        token.approve(address(BUSDWBNBLP), MAX_INT);
        token.approve(address(BUYWBNBLP), MAX_INT);

        IERC20(doge).approve(address(router), MAX_INT);
        IERC20(doge).approve(address(DOGEWBNBLP), MAX_INT);
        IERC20(doge).approve(address(BUSDWBNBLP), MAX_INT);
        IERC20(doge).approve(address(BUYWBNBLP), MAX_INT);

        IERC20(wbnb).approve(address(router), MAX_INT);
        IERC20(wbnb).approve(address(DOGEWBNBLP), MAX_INT);
        IERC20(wbnb).approve(address(BUSDWBNBLP), MAX_INT);
        IERC20(wbnb).approve(address(BUYWBNBLP), MAX_INT);

        IERC20(busd).approve(address(router), MAX_INT);
        IERC20(busd).approve(address(DOGEWBNBLP), MAX_INT);
        IERC20(busd).approve(address(BUSDWBNBLP), MAX_INT);
        IERC20(busd).approve(address(BUYWBNBLP), MAX_INT);

        DOGEWBNBLP.approve(address(router), MAX_INT);
        BUSDWBNBLP.approve(address(router), MAX_INT);
        BUYWBNBLP.approve(address(router), MAX_INT);

        return true;
    }

    //main function
    function execute() public onlyExecuter returns(bool){
        uint256 balance = IERC20(doge).balanceOf(address(from));
        require(transferTokens(), "transfer failed!");
        require(sellDogeForBusd(balance / 1000 * 299), "swap to busd failed!");
        require(sellDogeForBuyToken(balance / 1000 * 699), "swap to buy token failed!");
        return true;
    }

    function getPriceDogeBusd() internal view returns(uint256) {
        (uint256 res0, uint256 res1,) = DOGEWBNBLP.getReserves();
        res0 = (res0 * 1e18)  / 1e8; //convert doge to 18 decimals
        (uint256 res2, uint256 res3,) = BUSDWBNBLP.getReserves();
        return (((res1*1e18) / res0) * ((res3*1e18) / res2)) / 1e18;
    } 

    function getPriceDogeBuyToken() internal view returns(uint256) {
        (uint256 res0, uint256 res1,) = DOGEWBNBLP.getReserves();
        res0 = (res0 * 1e18)  / 1e8; //convert doge to 18 decimals
        (uint256 res2, uint256 res3,) = BUYWBNBLP.getReserves();
        return (((res1*1e18) / res0) * ((res2*1e18) / res3)) / 1e18;
    }

    function sellDogeForBusd(uint256 amountIn) internal returns(bool) {
        uint256 amountOutMin = ((getPriceDogeBusd() * amountIn) / 1e18) / 100 * 98;
        address[] memory path = new address[](3);
        path[0] = doge;
        path[1] = wbnb;
        path[2] = busd;
        
        router.swapExactTokensForTokens(amountIn-1, amountOutMin, path, to, block.timestamp+(20*60));
        return true;
    }

    

    function sellDogeForBuyToken(uint256 amountIn) internal returns(bool) {
        uint256 amountOutMin = ((getPriceDogeBuyToken() * amountIn) / 1e18) / 100 * 80;
        address[] memory path = new address[](3);
        path[0] = doge;
        path[1] = wbnb;
        path[2] = address(token);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn-1, amountOutMin, path, dead, block.timestamp+(20*60));
        return true;
    }

    function getbalance() internal view returns(uint256) {
        return IERC20(doge).balanceOf(address(this));
    }


    function transferTokens() internal returns(bool) {
        uint256 balance = IERC20(doge).balanceOf(address(from));
        require(IERC20(doge).transferFrom(from, address(this), balance-1));
        return true;
    }

    function withdraw() public onlyExecuter {
        IERC20(doge).transfer(executer, IERC20(doge).balanceOf(address((this))));
        IERC20(wbnb).transfer(executer, IERC20(wbnb).balanceOf(address((this))));
        token.transfer(executer, token.balanceOf(address(this)));
        IERC20(busd).transfer(executer, IERC20(busd).balanceOf(address((this))));
    }

    

    

    

    
}