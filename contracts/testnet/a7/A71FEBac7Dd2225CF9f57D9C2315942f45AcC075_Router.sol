pragma solidity ^0.8.9;
interface Factory {
    function GetTokenReward(address tokenerc, address tokennft, uint256 id) external view returns(address);
    function createTokenReward(address tokenerc, address tokennft, uint256 id) external returns (address tokenReward);
}
contract Router {
    Factory public factory;
    constructor(address _factory){
        factory = Factory(_factory);
    }
    function addLiquidity(address tokenerc, address tokennft, uint256 id) external {
        // mint token reward
        address tokenReward = factory.GetTokenReward(tokenerc, tokennft,id);
        if(tokenReward == address(0)){
            factory.createTokenReward(tokenerc, tokennft, id);
        }
    }
    // function removeLiquidity() external {
    //     // burn token reward
    // }

    // function buy() external {
    //     // update reward
    // }

    // function sell() external {
    //     // update reward
    // }

    /*
        function execute() external {

        }
    */
}