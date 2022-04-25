// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

struct MeasureSetting {
    string idv;
    uint256 intervalUpdate;
    uint256 defaultValue;
}

struct Measure {
    string idv;
    string value;
    uint64 timestamp;
}

contract Sensor {
    string public name;
    Measure[] measures;
    Measure lastMeasure;
    address public owner;
    mapping(string => MeasureSetting) public settings;

    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
    }

    function insertSettings(MeasureSetting memory _setting) public {
        require(bytes(_setting.idv).length > 0, "Settings empty");
        settings[_setting.idv] = _setting;
    }

    function insertMeasure(Measure[] memory newMeasure) public {
        for (uint256 i; i < newMeasure.length; i++) {
            Measure memory currentMeasure = newMeasure[i];
            MeasureSetting memory currentSettings = settings[
                currentMeasure.idv
            ];
            // bytes memory tempStringId = bytes(currentSettings.idv);
            // require(tempStringId.length == 0, "Settings not found!!");

            if (bytes(lastMeasure.idv).length == 0) {
                measures.push(currentMeasure);
                lastMeasure = currentMeasure;
            } else {
                if (
                    (currentMeasure.timestamp - lastMeasure.timestamp) >=
                    currentSettings.intervalUpdate
                ) {
                    measures.push(currentMeasure);
                    lastMeasure = currentMeasure;
                }
            }
        }
    }

    function getAllMeasure() public view returns (Measure[] memory measure) {
        return measures;
    }

    function getLastMeasure() public view returns (Measure memory measure) {
        return lastMeasure;
    }

    function getSettings(string memory idv)
        public
        view
        returns (MeasureSetting memory setting)
    {
        return settings[idv];
    }
}