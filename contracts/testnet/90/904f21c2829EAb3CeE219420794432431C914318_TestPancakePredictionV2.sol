/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity ^0.8.0;

contract TestPancakePredictionV2 {
    event Pause(uint256 indexed epoch);
    event Unpause(uint256 indexed epoch);
    event NewOperatorAddress(address operator);
    event NewAdminAddress(address admin);
    event NewOracle(address oracle);
    event NewTreasuryFee(uint256 indexed epoch, uint256 treasuryFee);

    bool paused; 
    address operatorAddress;
    address adminAddress;
    address oracleAddress;
    uint256 treasuryFee; 


    constructor(
        address _operatorAddress,
        address _adminAddress,
        address _oracleAddress,
        uint256 _treasuryFee
    ) {
        paused = false; 
        operatorAddress = _operatorAddress;
        adminAddress = _adminAddress;
        oracleAddress = _oracleAddress;
        treasuryFee = _treasuryFee; 
    }

    function pause() public {
        paused = true; 
        emit Pause(block.timestamp); 
    }

    function unpause() public {
        paused = false; 
        emit Unpause(block.timestamp); 
    }

    function setOperator(address _operatorAddress) public {
        operatorAddress = _operatorAddress;
        emit NewOperatorAddress(_operatorAddress);
    }

    function setAdminAddress(address _adminAddress) public {
        adminAddress = _adminAddress;
        emit NewAdminAddress(_adminAddress);
    }

    function setOracle(address _oracleAddress) public {
        oracleAddress = _oracleAddress; 
        emit NewOracle(_oracleAddress);
    }

    function setTreasuryFee(uint256 _newFee) public {
        treasuryFee = _newFee; 
        emit NewTreasuryFee(block.timestamp, _newFee);
    }

}