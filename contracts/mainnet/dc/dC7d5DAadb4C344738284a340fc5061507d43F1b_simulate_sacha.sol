/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface param{
    struct swap_info{
        uint fees_rate;
        address factory;
    }
}

interface flashSwapRouter is param{

    function tryFlashSwap(uint amountIn, uint amountOutMin, address[] calldata path, swap_info[] calldata infos) external;

}

interface IERC20 {
    
    function balanceOf(address account) external view returns (uint256);
}

contract simulate_sacha is param{

    address payable public  owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function simulate_transaction_on_router(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        swap_info[] calldata infos, 
        address router
    ) external returns(bool IsProfitable, string memory erreur, uint BalanceFinale){
        require(msg.sender == owner,"Coquinou tu essaierais donc de me voler ? C'est pas tres charlie !");
        uint previousBalance = IERC20(path[0]).balanceOf(router);

        try flashSwapRouter(router).tryFlashSwap(amountIn,amountOutMin,path,infos){
            if(IERC20(path[0]).balanceOf(router)>previousBalance){
                IsProfitable=true;
                erreur = "Parfait ca regale";
            }
            else{
                IsProfitable=false;
                erreur = "La balance n'est pas en meilleur etat";
            }
        }
        catch Error(string memory reason){
            IsProfitable=false;
            erreur = reason;
        }

        BalanceFinale = IERC20(path[0]).balanceOf(router);
        return (IsProfitable,erreur,BalanceFinale);

        
    }
}