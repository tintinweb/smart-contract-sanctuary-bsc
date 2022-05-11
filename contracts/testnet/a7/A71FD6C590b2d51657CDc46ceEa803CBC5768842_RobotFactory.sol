// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMedabotsGarage.sol";
import "./Ownable.sol";

contract RobotFactory is Ownable {
    
    IMedabotsGarage public RobotGarage;

    //le metemos el address del contrato RobotGarage
    constructor (address _robotGarage){ 
        RobotGarage = IMedabotsGarage(_robotGarage);
    }

    //Creamos una funcion para cambiar el owner del contrato Robot Garage  
    
    function transferMedapartOwnership(address newOwner) public virtual onlyOwner{
        RobotGarage.transferOwnership(newOwner);
    }

    //funciones de minteo
    function mint(uint8 _familyId, uint256[4] memory _tokenParts)public {
        RobotGarage.assemble(_familyId, _tokenParts);
    }

    function ownerMint(uint8 _familyId, uint256[4] memory _tokenParts)public {
        RobotGarage.assemble(_familyId, _tokenParts);
    }

    function disassemble(uint256 robotId)public {
        RobotGarage.disassemble(robotId);
    }

}