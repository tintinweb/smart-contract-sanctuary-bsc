/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

interface IChainhashRouter {


    struct FormattedOffer {
        uint[] amounts;
        address[] adapters;
        address[] path;
        uint gasEstimate;
    }
    
    function findBestPath(
        uint256 _amountIn, 
        address _tokenIn, 
        address _tokenOut, 
        uint _maxSteps
    ) external view returns (IChainhashRouter.FormattedOffer memory);

}

contract path {

    IChainhashRouter public router;

    constructor(address _router){
        router = IChainhashRouter(_router);
    }

    function fetchPath(uint256 amountIn, 
        address tokenIn, 
        address tokenOut, 
        uint maxSteps ) public view returns(IChainhashRouter.FormattedOffer memory quote) {

           quote = router.findBestPath(amountIn,tokenIn,tokenOut,maxSteps);
        }

}