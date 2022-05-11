// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Pausable.sol";
import "./Counters.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./IMedabotsGarage.sol";
import "./IMedapart.sol";


//TODO: 
contract MedabotsGarage is ERC721Pausable, Ownable {
    struct Robot {
        uint8 familyId;
        uint256 tokenPartOne;
        uint256 tokenPartTwo;
        uint256 tokenPartThree;
        uint256 tokenPartFour;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    IMedapart public medapart;

    mapping(uint256 => Robot) public robots;

    constructor(IMedapart _medabots) ERC721("Medabots Robots", "MERBT") {
        medapart = _medabots;
    }

    event Assemble(
        uint256 robotId,
        uint8 familyId,
        address owner,
        uint256 tokenPartOne,
        uint256 tokenPartTwo,
        uint256 tokenPartThree,
        uint256 tokenPartFour
    );

    event Disassemble(
        uint256 robotId,
        uint8 familyId,
        address owner,
        uint256 tokenPartOne,
        uint256 tokenPartTwo,
        uint256 tokenPartThree,
        uint256 tokenPartFour
    );

    event TransferRobot(address from, address to, uint256 tokenId);

    /// @dev Mint a new robot and transfer all token parts to this contract.
    /// @param _familyId - Familsy for new robot.
    /// @param _tokenParts - Must be in this order [Core, rightArm, leftArm, Head].
    function assemble(uint8 _familyId, uint256[4] memory _tokenParts) external whenNotPaused onlyOwner{
        _validateAllRobotParts(msg.sender, _familyId, _tokenParts);
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        //Me quedo con las partes.
        _transferRobotParts(msg.sender, address(this), itemId);
        
        //mintea un erc721 
        _mint(msg.sender, itemId);

        Robot memory robot = Robot({
            familyId: _familyId,
            tokenPartOne: _tokenParts[0],
            tokenPartTwo: _tokenParts[1],
            tokenPartThree: _tokenParts[2],
            tokenPartFour: _tokenParts[3]
        });
        robots[itemId] = robot;


        emit Assemble(itemId, _familyId, msg.sender, _tokenParts[0], _tokenParts[1], _tokenParts[2], _tokenParts[3]);
    }

    function disassemble(uint256 _robotId) external whenNotPaused onlyOwner{
        require(msg.sender == ownerOf(_robotId), "GARAGE: You must be the owner of the robot");

        _transferRobotParts(address(this), msg.sender, _robotId);

        delete robots[_robotId];
        _burn(_robotId);

        emit Disassemble(
            _robotId,
            robots[_robotId].familyId,
            msg.sender,
            robots[_robotId].tokenPartOne,
            robots[_robotId].tokenPartTwo,
            robots[_robotId].tokenPartThree,
            robots[_robotId].tokenPartFour
        );
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override whenNotPaused {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
        emit TransferRobot(from, to, tokenId);
    }

    function _transferRobotParts(
        address _from,
        address _to,
        uint256 _robotId
    ) private {
        medapart.transferFrom(_from, _to, robots[_robotId].tokenPartOne);
        medapart.transferFrom(_from, _to, robots[_robotId].tokenPartTwo);
        medapart.transferFrom(_from, _to, robots[_robotId].tokenPartThree);
        medapart.transferFrom(_from, _to, robots[_robotId].tokenPartFour);
    }
    
    //Importan tokenParts debe tener el orden [Core,RightArm,LeftArm,Legs] o fallara
    function _validateAllRobotParts(
        address _owner,
        uint8 _familyId,
        uint256[4] memory _tokenParts
    ) private view {
        for (uint256 index = 0; index < _tokenParts.length - 1; index++) {
            _validateRobotPart(_owner, _tokenParts[index], _familyId, index);
        }
    }

    function _validateRobotPart(
        address _owner,
        uint256 _tokenId,
        uint8 _familyId,
        uint256 _partId
    ) private view {
        require(medapart.ownerOf(_tokenId) == _owner, "GARAGE: You must be the owner of the token part");
        require(medapart.familyOf(_tokenId) == _familyId, "GARAGE: All tokens must have the same family");
        require(medapart.partOf(_tokenId) == MedapartMetadata.Part(_partId), "GARAGE: Wrong Part setted");
    }

}