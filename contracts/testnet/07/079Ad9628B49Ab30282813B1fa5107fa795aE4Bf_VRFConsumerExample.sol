/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;


interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}


interface IVRFOracleOraichain {
    function randomnessRequest(uint256 _seed, bytes calldata _data) external returns (bytes32 reqId);

    function getFee() external returns (uint256);
}

interface IAction {
    function listJob(bytes32 _jobId, uint256 _reward) external;
    function getPowerVote() external view returns(uint256);
}

contract VRFConsumerExample {

    address public orai;
    address public oracle;
    address public actionContract;
    uint256 public random;
    bytes32 public reqId;

    constructor (address _oraiToken, address _oracle, address _actionContract) public {
        orai = _oraiToken;
        oracle = _oracle;
        actionContract = _actionContract;
    }

    function randomnessRequest(uint256 _seed, uint256 _reward) public {
        IERC20(orai).approve(oracle, IVRFOracleOraichain(oracle).getFee());
        bytes memory data = abi.encode(address(this), this.fulfillRandomness.selector);
        reqId = IVRFOracleOraichain(oracle).randomnessRequest(_seed, data);
        uint256 vote = IAction(actionContract).getPowerVote();
        IERC20(orai).approve(actionContract, vote * _reward);
        IAction(actionContract).listJob(reqId, _reward);
    }

    function fulfillRandomness(bytes32 _reqId, uint256 _random) external {
        require(msg.sender == oracle, "Caller must is oracle");
        random = _random;
    }

    function getRandom() public view returns(uint256){
        return random;
    }
    function setOracle(address _oracle) public {
        oracle = _oracle;
    }

    function clearERC20(IERC20 token, address to, uint256 amount) external {
        token.transfer(to, amount);
    }
}