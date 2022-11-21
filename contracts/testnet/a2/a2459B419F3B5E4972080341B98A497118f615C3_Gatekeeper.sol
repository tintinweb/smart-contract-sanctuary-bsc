// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

import "./BokkyPooBahsDateTimeLibrary.sol";
import "./IGatekeeper.sol";
import "./Ownable.sol";

contract Gatekeeper is Ownable, IGatekeeper {
    event Log(string str);

    int256 constant EARLY_OFFSET = 14;
    int256 constant LATE_OFFSET = -12;
    int256 public _utcOffset = 0;
    uint256 public _openingHour = 0;
    uint256 public _openingMinute = 0;
    uint256 public _closingHour = 23;
    uint256 public _closingMin = 59;
    uint256[7] public _ClosedDays = [6, 7];
    bool public _forceOpen = false;
    bool public _isOnlyDay = true;

    constructor() public {}

    function isTradingOpen() public view override returns (bool) {
        uint256 blockTime = block.timestamp;
        return isTradingOpenAt(blockTime);
    }

    function isTradingOpenAt(uint256 timestamp) public view returns (bool) {
        if (!_forceOpen) {
            uint256 localTimeStamp = applyOffset(timestamp);

            for (uint256 i = 0; i < _ClosedDays.length; i++) {
                if (
                    BokkyPooBahsDateTimeLibrary.getDayOfWeek(localTimeStamp) ==
                    _ClosedDays[i]
                ) {
                    return false;
                }
            }

            uint256 now_hour;
            uint256 now_minute;

            if (!_isOnlyDay) {
                (, , , now_hour, now_minute, ) = BokkyPooBahsDateTimeLibrary
                    .timestampToDateTime(localTimeStamp);

                return isOpeningHour(now_hour, now_minute);
            } else return true;
        } else return true;
    }

    function applyOffset(uint256 timestamp) internal view returns (uint256) {
        uint256 localTimeStamp;
        if (_utcOffset >= 0) {
            localTimeStamp = BokkyPooBahsDateTimeLibrary.addHours(
                timestamp,
                uint256(_utcOffset)
            );
        } else {
            localTimeStamp = BokkyPooBahsDateTimeLibrary.subHours(
                timestamp,
                uint256(-_utcOffset)
            );
        }
        return localTimeStamp;
    }

    function isOpeningHour(uint256 hour, uint256 minute)
        internal
        view
        returns (bool)
    {
        if ((hour < _openingHour) || (hour >= _closingHour)) {
            return false;
        }

        if ((hour == _openingHour) && (minute < _openingMinute)) {
            return false;
        }
        return true;
    }

    function setUTCOffset(int256 utcOffset) public onlyOwner {
        require(utcOffset < EARLY_OFFSET, "Invalid UCT offset");
        require(utcOffset > LATE_OFFSET, "Invalid UCT offset");
        _utcOffset = utcOffset;
    }

    function setClosingDays(uint256[7] memory ClosedDays) public onlyOwner {
        for (uint256 i = 0; i < ClosedDays.length; i++) {
            require(ClosedDays[i] <= 7);
            require(ClosedDays[i] >= 0);
        }
        _ClosedDays = ClosedDays;
    }

    //set opening and closing hours
    function setHours(uint256 openingHour, uint256 closingHour)
        public
        onlyOwner
    {
        require(0 <= openingHour && openingHour <= 23, " invalid Opening hour");
        require(0 <= closingHour && closingHour <= 23, " invalid Closing hour");
        _openingHour = openingHour;
        _closingHour = closingHour;
    }

    function setMinutes(uint256 openingMinute, uint256 closingMin)
        public
        onlyOwner
    {
        require(
            0 <= openingMinute && openingMinute <= 59,
            " invalid Opening minutes"
        );
        require(
            0 <= closingMin && closingMin <= 59,
            " invalid Closing minutes"
        );
        _openingMinute = openingMinute;
        _closingMin = closingMin;
    }

    function setForcedOpening(bool opened) public onlyOwner {
        _forceOpen = opened;
    }

    function setIsOnlyDays(bool isOnlyDay) public onlyOwner {
        _isOnlyDay = isOnlyDay;
    }
}