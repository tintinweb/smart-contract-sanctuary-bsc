// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./SklMint.sol";

contract SkyLandsNFT is SklMint {

    using SafeMath for uint256;

    event PositionCreated(uint id, uint price);
    event PositionRemoved(uint id);
    event PositionBought(uint id);

    bool public marketPlaceActive = false;
    address public skyLandsTokenAddress = 0xfD2150C67Fe2c754Ba63920aDdE3B1CA5CC536E8;
    uint private activePositions = 0;

    mapping(uint => uint) private positions;

    modifier onlyActive() {
        require(marketPlaceActive);
        _;
    }

    function toggleMarketPlace() external onlyOwner {
        marketPlaceActive = !marketPlaceActive;
    }

    function changeSkyLandsTokenAddress(address _address) external onlyOwner {
        skyLandsTokenAddress = _address;
    }

    function removeFromSell(uint _id) private {
        positions[_id] = 0;
        activePositions = activePositions.sub(1);
    }

    function addPosition(uint _id, uint _price) external onlyActive {
        require(ownerOf(_id) == msg.sender);
        require(_price > 0);

        if (positions[_id] == 0) {
            activePositions = activePositions.add(1);
        }
        positions[_id] = _price;
        emit PositionCreated(_id, _price);
    }

    function removePosition(uint _id) external onlyActive {
        require(ownerOf(_id) == msg.sender);
        require(positions[_id] > 0);

        removeFromSell(_id);
        emit PositionRemoved(_id);
    }

    function buyPosition(uint _id, address _to) external onlyActive {
        uint _price = positions[_id];

        require(_price > 0);
        require(IERC20(skyLandsTokenAddress).transferFrom(msg.sender, ownerOf(_id), _price));

        removeFromSell(_id);
        _transfer(ownerOf(_id), _to, _id);
        
        emit PositionBought(_id);
    }

    function getPositions() external view returns (uint[] memory) {
        uint[] memory _positions = new uint[](activePositions);
        uint _position = 0;

        for (uint _i = 0; _i < lands.length; _i++) {
            if (positions[_i] > 0) {
                _positions[_position] = _i;
                _position = _position.add(1);
            }
        }

        return _positions;
    }

    function getLandPrice(uint _id) external view returns (uint) {
        return positions[_id];
    }

}