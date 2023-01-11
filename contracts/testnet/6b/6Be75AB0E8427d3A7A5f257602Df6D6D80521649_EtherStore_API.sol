//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface ProxyContract {

}

contract EtherStore_API {
    address public implementation;
    address public admin;
    address public owner;
    int256  public sum;
    address public gw;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public results;
    bool public isWaiting;


    constructor (){
        owner = msg.sender;

    }

    modifier onlyGW {
        require(gw == address(this), "Only GW can call");
        _;

    }
    modifier onlyOwner {
        require(msg.sender == owner, "not the owner");
        _;
    }

    function addGW(address _newGW) external onlyOwner {
        gw =_newGW;

    }

    function calc(int256 _num1, int256 _num2) external onlyGW returns (int256)
    {
        sum = _num1 + _num2;
        return int256(sum);
    }


    function get_sum() public view returns (int256){
        return (sum);
    }

       function check_result() public returns(bool) {
        if (results == 13371){
            return true;
        }
        return false;
    }

}